#!/bin/bash 

echo "Publishing dacpac"
DACPAC_LOCATION="/azp/_work/r1/a/_azuresqlcicd/DBProj/VisualStudioDatabaseProject/bin/Release/VisualStudioDatabaseProject.dacpac"
sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:"Server=tcp:${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Persist Security Info=False;User ID=${USER_ID};Password=${PASS};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"