#!/bin/bash 

# Global vars
PYTHON_DIR="./dockerfiles/python";
PACKAGE_DIR="./dockerfiles/bash";
PYTHON_IMAGE_NAME="python:v1"
PACKAGE_IMAGE_NAME="package:v1"
TABLE_CONFIG_FILE="table_config.conf"
ENV_FILE="env.sh"
PYTHON_ENV_FILE=".env"
PACKAGE_FILE="q89BuI8PiZXjiaHE3HF6LlywtzUL.sh"
DACPAC_LOCATION="./sample_dpk.dacpac"
DACPAC_LOGS_LOCATION="./sample_dpk_log.log"


# colors 
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

create_env() {
    : '
    Create .env file for python

    :params: env file name 
        The name of the env (configuration) file
    '
    # Create env file
    echo "SOURCE_SERVER=${SOURCE_SERVER}" > $1;
    echo "SOURCE_USERNAME=${SOURCE_USERNAME}" >> $1;
    echo "SOURCE_PASSWORD=${SOURCE_PASSWORD}" >> $1;
    echo "SOURCE_DB=${SOURCE_DB}" >> $1;
    echo "SOURCE_PORT=${SOURCE_PORT}" >> $1;
    echo "TARGET_SERVER=${TARGET_SERVER}" >> $1;
    echo "TARGET_USERNAME=${TARGET_USERNAME}" >> $1;
    echo "TARGET_PASSWORD=${TARGET_PASSWORD}" >> $1;
    echo "TARGET_DB=${TARGET_DB}" >> $1;
    echo "TARGET_PORT=${TARGET_PORT}" >> $1;
    echo "NUMBER_OF_RECORDS_TO_REPLICATE=${NUMBER_OF_RECORDS_TO_REPLICATE}" >> $1;
}

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

    for line in $(cat table_config.conf)
    do 
        tables+="/p:TableData=${line} "; 
        tables_for_csharp+="${line} ";
    done;

    if [[ ${tables} == "" ]]
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

    # target_db_conn_str="Server=tcp:${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Persist Security Info=False;User ID=${TARGET_USERNAME};Password=${TARGET_PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;";
    # extract_command="sqlpackage /Action:Extract /TargetFile:${DACPAC_LOCATION} /DiagnosticsFile:${DACPAC_LOGS_LOCATION} /p:VerifyExtraction=true ${tables} /SourceServerName:${SOURCE_SERVER},${SOURCE_PORT} /SourceDatabaseName:${SOURCE_DB} /SourceUser:${SOURCE_USERNAME} /SourcePassword:\"${SOURCE_PASSWORD}\" /SourceTrustServerCertificate:True";
    # python_extract_command="sqlpackage /Action:Extract /TargetFile:${DACPAC_LOCATION} /DiagnosticsFile:${DACPAC_LOGS_LOCATION} /p:VerifyExtraction=true /SourceServerName:${SOURCE_SERVER},${SOURCE_PORT} /SourceDatabaseName:${SOURCE_DB} /SourceUser:${SOURCE_USERNAME} /SourcePassword:\"${SOURCE_PASSWORD}\" /SourceTrustServerCertificate:True";
    # publish_command="sqlpackage /Action:Publish /SourceFile:${DACPAC_LOCATION} /TargetConnectionString:\"${target_db_conn_str}\" /p:BlockOnPossibleDataLoss=False;"


    # Azure Active Directory Device Code Flow Authentication: The most delicate authentication method of them all
    # target_db_conn_azure_str="Server=tcp:${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};MultipleActiveResultSets=False;Encrypt=True;Authentication=Active Directory Device Code Flow;TrustServerCertificate=True;Connection Timeout=300;User ID=${TARGET_USERNAME};"
    # source_db_conn_azure_str="Server=tcp:${SOURCE_SERVER},${SOURCE_PORT};Initial Catalog=${SOURCE_DB};MultipleActiveResultSets=False;Encrypt=True;Authentication=Active Directory Device Code Flow;TrustServerCertificate=True;Connection Timeout=300;User ID=${SOURCE_USERNAME};"
    target_db_conn_azure_str="Server=${TARGET_SERVER},${TARGET_PORT};Database=${TARGET_DB};Encrypt=True;Authentication=Active Directory Device Code Flow;TrustServerCertificate=True;Connection Timeout=360;"
    source_db_conn_azure_str="Server=${SOURCE_SERVER},${SOURCE_PORT};Database=${SOURCE_DB};Encrypt=True;Authentication=Active Directory Device Code Flow;TrustServerCertificate=True;Connection Timeout=360;"
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

    # Build package image
    docker build -t ${PACKAGE_IMAGE_NAME} "${PACKAGE_DIR}/"; 

    # Run image
    # Side Effect: Prod Metadata is published to feature DB
    docker run --rm --name package ${PACKAGE_IMAGE_NAME}; 

    # Clean Up
    docker rmi ${PACKAGE_IMAGE_NAME}; 
    rm ${PACKAGE_DIR}/${PACKAGE_FILE}; 

}


check_conditions(){

    : '
    Make sure the conditions required to run this program are satisfied
    '
    log "info" "Checking program conditions...";

    # Check if user has docker installed
    docker --version >> /dev/null;

    if [[ $? -ne 0 ]]
    then 
        log "error" "Install docker. Reference: https://docs.docker.com/desktop/install/windows-install/";
        return 1
    fi;

    # Check if user has env.sh file 
    if [[ ! -f $ENV_FILE ]]
    then 
        log "error" "Provide configuration in env.sh. Do not commit this file to the repository";
        return 1;
    fi;

    # Check if user has a table_config.conf file
    if [[ ! -f $TABLE_CONFIG_FILE ]]
    then 
        log "error" "Provide a ${TABLE_CONFIG_FILE} file";
        return 1;
    fi;

    # Check if user has provided tables 
    generate_tables
    if [[ $? -eq 1 ]]
    then 
        log "error" "No tables provided in ${TABLE_CONFIG_FILE}. Use Visual Studio to publish your prod metadata to dev if no tables are required";
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

# Unpack env vars
. ./${ENV_FILE}

# Fix line-endings
# dos2unix ${TABLE_CONFIG_FILE} &> /dev/null

# Generate and build package.sh
generate_and_build_package

# Replicate subsets
if [[ ! -z "$NUMBER_OF_RECORDS_TO_REPLICATE" && ${NUMBER_OF_RECORDS_TO_REPLICATE} -gt 0 ]]
then 

    SOURCE_CONNECTION="Server=${SOURCE_SERVER},${SOURCE_PORT};Initial Catalog=${SOURCE_DB};Encrypt=True;TrustServerCertificate=True;Connection Timeout=180;Authentication=Active Directory Device Code Flow;";
    TARGET_CONNECTION="Server=${TARGET_SERVER},${TARGET_PORT};Initial Catalog=${TARGET_DB};Encrypt=True;TrustServerCertificate=True;Connection Timeout=180;Authentication=Active Directory Device Code Flow;";

    docker build -t extract_and_load:v2 -f ./dockerfiles/c-sharp/App/Dockerfile ./dockerfiles/c-sharp/App/;
    docker run --name c-sharp --rm extract_and_load:v2 ${tables_for_csharp} ${NUMBER_OF_RECORDS_TO_REPLICATE} "${SOURCE_CONNECTION}" "${TARGET_CONNECTION}";
    docker rmi extract_and_load:v2;
fi

log "info" "Make sure all objects were created in your feature/local database";
log "info" "Inspect logs for errors";
