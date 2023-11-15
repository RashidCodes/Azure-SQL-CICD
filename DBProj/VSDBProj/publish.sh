#!/bin/bash 
# Run in release
echo "Publishing dacpac"
DACPAC_LOCATION="/azp/_work/r1/a/_azuresqlcicd/DBProj/VisualStudioDatabaseProject/bin/Debug/VisualStudioDatabaseProject.dacpac"

# For local dev
# ADJUSTED_DACPAC_LOCATION="./bin/Release/VSDBProj.dacpac"
# target_db_conn_azure_str="tcp:Server=${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Encrypt=True;Authentication=Active Directory Managed Identity;TrustServerCertificate=True;Connection Timeout=360;User Id=${CLIENT_ID};"


sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:"Server=tcp:${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Authentication=Active Directory MSI;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;User ID=${CLIENT_ID};"
# sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:"Server=tcp:${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Persist Security Info=False;User ID=${USER_ID};Password=${PASS};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"