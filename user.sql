-- Assign the SQL DB Contributor Role
use master, sample-database, sample-development-database;
go 

-- Run this for the source and destination databases
-- Potentially the master database as well? Not too sure
CREATE USER [azure-sql-role] FROM EXTERNAL PROVIDER;
EXEC sp_addrolemember 'db_owner', [azure-sql-role]; -- db_owner might be a bit much

-- Azure Services are allowed to talk to the Azure SQL DB (otherwise you have to whitelist IPs)