#!/bin/bash 

echo "Publishing dacpac"
DACPAC_LOCATION="./DBProj/VSDBProj/bin/Release/VSDBProj.dacpac"

# For local dev
# ADJUSTED_DACPAC_LOCATION="./bin/Release/VSDBProj.dacpac"
# target_db_conn_azure_str="tcp:Server=${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Encrypt=True;Authentication=Active Directory Managed Identity;TrustServerCertificate=True;Connection Timeout=360;User Id=${CLIENT_ID};"


# sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:"Server=tcp:${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Persist Security Info=False;User ID=${CLIENT_ID};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:"Server=tcp:${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Persist Security Info=False;User ID=${USER_ID};Password=${PASS};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"