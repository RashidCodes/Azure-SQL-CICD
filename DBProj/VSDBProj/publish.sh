#!/bin/bash 

echo "Publishing dacpac"
DACPAC_LOCATION="$(System.DefaultWorkingDirectory)/_azuresqlcicd/DBProj/VSDBProj/bin/Release/VSDBProj.dacpac"
target_db_conn_azure_str="Server=${TARGET_SERVER},${TARGET_PORT};Database=${TARGET_DB};Encrypt=True;Authentication=Active Directory MSI;TrustServerCertificate=True;Connection Timeout=360;User Id=${CLIENT_ID};"
sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:\"${target_db_conn_azure_str}\" /p:BlockOnPossibleDataLoss=False /p:DropConstraintsNotInSource='False'