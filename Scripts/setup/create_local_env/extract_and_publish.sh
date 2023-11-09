#!/usr/bin/env bash

# Global vars
PYTHON_DIR="/src/dockerfiles/python";
PACKAGE_DIR="/src/dockerfiles/bash";
PYTHON_IMAGE_NAME="python:v1"
PACKAGE_IMAGE_NAME="package:v1"
TABLE_CONFIG_FILE="table_config.conf"
ENV_FILE="env.sh"
PYTHON_ENV_FILE=".env"
PACKAGE_FILE="b9d3fd3e-ab9a-43ab-bde1-bdc44c3c804d.sh"
DACPAC_LOCATION="/src/sample_dpk.dacpac"
DACPAC_LOGS_LOCATION="/src/sample_dpk_log.log"


# colors 
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"


log() {
    severity=$1;
    message=$2;

    if [[ $severity == "warning" ]]
    then 
        echo -e "${YELLOW}$(date +%F:%H-%M-%S) [WARNING]: ${message}${ENDCOLOR}";
    elif [[ $severity == "info" ]]
    then 
        echo -e "${BLUE}$(date +%F:%H-%M-%S) [INFO]: ${message}${ENDCOLOR}";
    elif [[ $severity == "error" ]]
    then 
        echo -e "${RED}$(date +%F:%H-%M-%S) [ERROR]: ${message}${ENDCOLOR}";
    elif [[ $severity == "success" ]]
    then 
        echo -e "${GREEN}$(date +%F:%H-%M-%S) [SUCCESS]: ${message}${ENDCOLOR}";
    fi
}


generate_tables(){
    : '
    Generate the string of tables
    '

    tables="";
    tables_for_csharp="";

    user_defined_tables=$(echo ${USER_DEFINED_TABLES_TO_REPLICATE} | tr ";" " ");
    echo $user_defined_tables > /src/tables.config;

    for line in $(echo $user_defined_tables)
    do 
        tables+="/p:TableData=${line} "; 
        tables_for_csharp+="${line} ";
    done;

    if [[ -z ${tables} ]]
    then 
        return 1;
    fi 
}


generate_and_build_package(){
    : '
    Generate and build package script. The package script uses sqlpackage to either generate
    a schema-only or schema-only/data dacpac.
    '
    log "info" "Generating and publishing dacpac."

    # Create tables var
    generate_tables

    # target_db_conn_azure_str="Server=${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Persist Security Info=False;User ID=${TARGET_USERNAME};Password=${TARGET_PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;";
    # source_db_conn_azure_str="Server=${SOURCE_SERVER},${SOURCE_PORT};Initial Catalog=${SOURCE_DB};Persist Security Info=False;User ID=${SOURCE_USERNAME};Password=${SOURCE_PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;";
    # extract_command="sqlpackage /Action:Extract /TargetFile:${DACPAC_LOCATION} /DiagnosticsFile:${DACPAC_LOGS_LOCATION} /p:VerifyExtraction=true ${tables} /SourceServerName:${SOURCE_SERVER},${SOURCE_PORT} /SourceDatabaseName:${SOURCE_DB} /SourceUser:${SOURCE_USERNAME} /SourcePassword:\"${SOURCE_PASSWORD}\" /SourceTrustServerCertificate:True";
    # python_extract_command="sqlpackage /Action:Extract /TargetFile:${DACPAC_LOCATION} /DiagnosticsFile:${DACPAC_LOGS_LOCATION} /p:VerifyExtraction=true /SourceServerName:${SOURCE_SERVER},${SOURCE_PORT} /SourceDatabaseName:${SOURCE_DB} /SourceUser:${SOURCE_USERNAME} /SourcePassword:\"${SOURCE_PASSWORD}\" /SourceTrustServerCertificate:True";
    # publish_command="sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:\"${target_db_conn_str}\" /p:BlockOnPossibleDataLoss=False;"


    # Azure Active Directory Device Code Flow Authentication: The most delicate authentication method of them all
    target_db_conn_azure_str="Server=${TARGET_SERVER},${TARGET_PORT};Database=${TARGET_DB};Encrypt=True;Authentication=Active Directory MSI;TrustServerCertificate=True;Connection Timeout=360;User Id=${CLIENT_ID};"
    source_db_conn_azure_str="Server=${SOURCE_SERVER},${SOURCE_PORT};Database=${SOURCE_DB};Encrypt=True;Authentication=Active Directory MSI;TrustServerCertificate=True;Connection Timeout=360;User Id=${CLIENT_ID};"
    extract_command_for_azure_auth="sqlpackage /Action:Extract /TargetFile:${DACPAC_LOCATION} ${tables} /SourceConnectionString:\"${source_db_conn_azure_str}\" /DiagnosticsFile:${DACPAC_LOGS_LOCATION} /p:VerifyExtraction=true;"
    extract_command_metadata_only="sqlpackage /Action:Extract /TargetFile:${DACPAC_LOCATION} /DiagnosticsFile:${DACPAC_LOGS_LOCATION} /SourceConnectionString:\"${source_db_conn_azure_str}\";"
    publish_command_for_azure_auth="sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:\"${target_db_conn_azure_str}\" /p:BlockOnPossibleDataLoss=False /p:DropConstraintsNotInSource='False'"


    # Generate run script
    echo "#!/bin/bash" > "${PACKAGE_DIR}/${PACKAGE_FILE}"
    echo "" >> "${PACKAGE_DIR}/${PACKAGE_FILE}"

    if [[ ! -z "$NUMBER_OF_RECORDS_TO_REPLICATE" && ${NUMBER_OF_RECORDS_TO_REPLICATE} -gt 0 ]]
    then    
        echo $extract_command_metadata_only >> "${PACKAGE_DIR}/${PACKAGE_FILE}";
    else
        echo $extract_command_for_azure_auth >> "${PACKAGE_DIR}/${PACKAGE_FILE}";
    fi;

    echo $publish_command_for_azure_auth >> "${PACKAGE_DIR}/${PACKAGE_FILE}";

    # run the package file
    . /${PACKAGE_DIR}/${PACKAGE_FILE}

    # Replicate subsets
    if [[ ! -z "$NUMBER_OF_RECORDS_TO_REPLICATE" && ${NUMBER_OF_RECORDS_TO_REPLICATE} -gt 0 ]]
    then 
        cd /src/dockerfiles/c-sharp/App;
        # dotnet restore;
        dotnet publish -c Release -o out --use-current-runtime;
        cd out;
        dotnet DotNet.Docker.dll ${tables_for_csharp} ${NUMBER_OF_RECORDS_TO_REPLICATE} "${source_db_conn_azure_str}" "${target_db_conn_azure_str}";
    fi

}



check_conditions(){

    : '
    Make sure the conditions required to run this program are satisfied
    '
    log "info" "Checking program conditions...";

    # Check if user has env.sh file 
    if [[ -z $SOURCE_SERVER ]]
    then 
        log "error" "Provide configuration in a .env file. Do not commit this file to the repository";
        return 1;
    fi;

    # Check if user has a table_config.conf file
    if [[ -z $USER_DEFINED_TABLES_TO_REPLICATE ]]
    then 
        log "error" "Provide tables to replicate";
        return 1;
    fi;

    # Check if user has provided tables 
    generate_tables
    if [[ $? -eq 1 ]]
    then 
        log "error" "No tables provided. Use Visual Studio to publish your prod metadata to dev if no tables are required";
        return 1;
    fi;

    # Everything looks good
    log "info" "All set";
    return 0

}

# Check conditions
check_conditions

if [[ $? -eq 1 ]]
then 
    log "warning" "Make sure you're in the create_local_env directory";
    exit 1;
fi;

# Generate and build package.sh
generate_and_build_package

log "info" "Make sure all objects were created in your feature/local database";
log "info" "Inspect logs for errors";
