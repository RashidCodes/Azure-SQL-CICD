-- Assign the SQL DB Contributor Role
use master;
go 

CREATE USER [sample-job] FROM EXTERNAL PROVIDER;

-- Azure Services are allowed to talk to the Azure SQL DB (otherwise you have to whitelist IPs)