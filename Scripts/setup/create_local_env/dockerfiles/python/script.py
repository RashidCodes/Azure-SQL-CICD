import pyodbc 
import logging 
import asyncio
from os import getenv

logging.basicConfig(
    format="%(asctime)s %(levelname)s: %(message)s", 
    datefmt="%Y-%m-%d %I:%M:%S %p", 
    level=logging.DEBUG
)

class AzureDBClient:
    """
    Azure SQL DB Client
    
    An azure sql database client. Use this class to
    peform various operations on an SQL Server Database
    
    :params ...
    """

    def __init__(
        self, 
        server: str,
        db: str,
        username: "str|None"=None,
        password: "str|None"=None,
        port: str="1433"
    ):
        
        self.server = server
        self.db = db
        self.username = username
        self.password = password
        self.port = port


    
    def __create_connection(self):
        """
        Create connection to SQL Server
        
        :returns conection: pyodbc.Connection
            PyODBC connection
        """
        # Currently dysfunctional
        cnxn_string = (f'Driver={{ODBC Driver 18 for SQL Server}};Server={self.server},'
                       f'{self.port};Database={self.db};'
                       'Encrypt=yes;TrustServerCertificate=yes;Authentication=Active Directory Device Code Flow;'
                       'Connection Timeout=180;') 
        
        cnxn = pyodbc.connect(cnxn_string)
        return cnxn


    async def get_table_data(
        self, 
        table_name: str,
        count: int=10
    ):
        """
        Get a subset of data from a table 

        :params table_name: str 
            The name of the table

        :returns (columns, data)
            A tuple of the table attributes and table data
        
        """

        if table_name == '' or table_name is None:
            logging.error("Provide a table to be replicated")
            return 
    
        query = f"select top {count} * from {table_name}"
        cnxn = self.__create_connection()
        cursor = cnxn.cursor()

        try:
            data = cursor.execute(query).fetchall()
            columns = [column[0] for column in cursor.description]
        except pyodbc.IntegrityError as err:
            logging.error(err)
        else:
            cnxn.commit()
        finally:
            cnxn.close()

        return columns, data
    

    async def insert_table_data(
        self,
        table_name: str,
        columns: list,
        data: "list[tuple]",
        has_identity_column: bool=False
    ):
        
        """
        Insert data into a table 
        
        :params table_name: str 
            The name of the table 
            
        :params: columns: str 
            The columns in the table
        
        :params data: list<tuple>
            Data to be inserted
        
        """
        if table_name == '' or table_name is None:
            logging.error("Provide a table to be replicated")
            return 
        

        mks = (len(columns) - 1) * "?," + "?"
        query = f"insert into {table_name}({columns}) values ({mks})".replace("[", "").replace("]", "").replace("'", "")
        cnxn = self.__create_connection()
        cursor = cnxn.cursor()

        try:

            # Empty the table
            cursor.execute(f"delete from {table_name};")

            if has_identity_column:
                cursor.execute(f"set identity_insert {table_name} on;")
                cursor.executemany(query, data)
                cursor.execute(f"set identity_insert {table_name} off;")
                
            else:
                cursor.executemany(query, data)

            logging.info(f"Number of records inserted into {table_name}: {len(data)}")
            
        except pyodbc.IntegrityError as err:
            logging.error(err)
        else:
            cnxn.commit()
        finally:
            cnxn.close()


class Util:

    """
    Utillity class
    """

    @staticmethod
    async def get_and_insert(
        source_db_client: AzureDBClient,
        target_db_client: AzureDBClient,
        table_name: str,
        number_of_records_to_replicate: int=10000
    ):

        if table_name is None or table_name == "":
            logging.error("Provide a table")
            return 
        
        columns, data = await source_db_client.get_table_data(table_name=table_name, count=number_of_records_to_replicate)
        await target_db_client.insert_table_data(table_name, columns, data, has_identity_column=True)


#yeend st
async def main():

    # Env Vars
    source_server = getenv('SOURCE_SERVER')
    source_db = getenv('SOURCE_DB')
    source_username = getenv('SOURCE_USERNAME')
    source_password = getenv('SOURCE_PASSWORD')
    source_port = getenv('SOURCE_PORT')
    target_server = getenv('TARGET_SERVER')
    target_db = getenv('TARGET_DB')
    target_username = getenv('TARGET_USERNAME')
    target_password = getenv('TARGET_PASSWORD')
    target_port = getenv('TARGET_PORT')
    number_of_records_to_replicate = getenv('NUMBER_OF_RECORDS_TO_REPLICATE')

    all_values = all([
        source_server is not None and source_server != '',
        source_db is not None and source_db != '',
        source_username is not None and source_username != '',
        source_password is not None and source_password != '',
        source_port is not None and source_port != '',
        target_server is not None and target_server != '',
        target_db is not None and target_db != '',
        target_username is not None and target_username != '',
        target_password is not None and target_password != '',
        target_port is not None and target_port != ''
    ])

    if all_values is False:
        logging.error(f"Making sure all environment variables are"
                      f" provided in the env.sh file")
        return
    
    # Prod DB Client
    source_azure_sql_db_client = AzureDBClient(
        server=source_server,
        db=source_db,
        username=source_username,
        password=source_password,
        port=source_port
    )

    # Feature DB Client
    target_azure_sql_db_client = AzureDBClient(
        server=target_server,
        db=target_db,
        username=target_username,
        password=target_password,
        port=target_port
    )


    # get tables 
    with open('./table_config.conf', 'r') as table_config:
        tables = [table.strip() for table in table_config.readlines() if table.strip() != ""]

    # load tables concurrently
    _ = await asyncio.gather(*[
        Util.get_and_insert(
            source_azure_sql_db_client, 
            target_azure_sql_db_client, 
            table,
            number_of_records_to_replicate
        ) for table in tables]
    )



if __name__ == "__main__":
    asyncio.run(main())