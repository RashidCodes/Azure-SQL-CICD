using System;
using System.Data;
using System.Text;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace sqltest
{
    class Program
    {
        static void Main(string[] args) 
        {

            using var loggerFactory = LoggerFactory.Create(builder =>
            {
                builder
                    .AddFilter("Microsoft", LogLevel.Warning)
                    .AddFilter("System", LogLevel.Warning)
                    .AddFilter("LoggingConsoleApp.Program", LogLevel.Debug)
                    .AddConsole();
            });
            ILogger logger = loggerFactory.CreateLogger<Program>();



            // connection strings
            string connectionString = args[args.Length - 2];
            string destinationConnectionString = args[args.Length - 1];
            string numberOfRecords = args[args.Length - 3];
            string[] tablesToReplicated = args[0..(args.Length -3)];

            logger.LogInformation($"Source connection string: {connectionString}");
            logger.LogInformation($"Destination connection string: {destinationConnectionString}");
            logger.LogInformation($"Number of records to be replicated: {numberOfRecords}");

            // Unable to run script from docker without the Config builder
            // May not be necessary
            var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>()
            {
                ["sourceConnectionString"] = connectionString,
                ["destinationConnectionString"] = destinationConnectionString
            })
            .Build();


            logger.LogInformation("Commencing replication");
            foreach (string tableName in tablesToReplicated)
            {
                // connect to source
                using (SqlConnection sourceConnection = new SqlConnection(configuration["sourceConnectionString"]))
                {
                    sourceConnection.Open();

                    // Perform an initial count on the source table
                    SqlCommand sourceCommandRowCount = new SqlCommand(
                        "SELECT COUNT(*) FROM " + $"{tableName};",
                        sourceConnection);

                    long numberOfRecordsInSource = System.Convert.ToInt32(
                        sourceCommandRowCount.ExecuteScalar());

                    logger.LogInformation("Number of records in Source = {0}", numberOfRecordsInSource);

                    // Get data from the source table as a SqlDataReader
                    SqlCommand commandSourceData = new SqlCommand(
                        $"SELECT TOP {numberOfRecords} * FROM {tableName}", sourceConnection);

                    SqlDataReader reader = commandSourceData.ExecuteReader();


                    using (SqlConnection destinationConnection = new SqlConnection(configuration["destinationConnectionString"]))
                    {
                        destinationConnection.Open();

                        SqlCommand deleteCommand = new SqlCommand(
                            $"delete from {tableName}", destinationConnection
                        );

                        deleteCommand.ExecuteNonQuery();

                        using (SqlBulkCopy bulkCopy = new SqlBulkCopy(destinationConnection))
                        {
                            bulkCopy.DestinationTableName = tableName;

                            try
                            {
                                bulkCopy.WriteToServer(reader);
                            }
                            catch (Exception ex)
                            {
                                logger.LogError(ex.Message);
                            }
                            finally
                            {
                                reader.Close();
                            }
                        }

                        SqlCommand destinationCommandRowCount = new SqlCommand(
                        "SELECT COUNT(*) FROM " +
                        $"{tableName};",
                        destinationConnection);

                        long numberOfRecordsInDestination = System.Convert.ToInt32(destinationCommandRowCount.ExecuteScalar());

                        logger.LogInformation("Number of records in destination - {0}: {1}", tableName, numberOfRecordsInDestination);
                    }

                }
            }
        }
    }
}