#!/bin/bash 

# Use this script to start a SQL Server 2022 container
# Global vars
ENV_FILE="env.sh"
AZURE_SQL_EDGE_IMAGE="mcr.microsoft.com/azure-sql-edge"
SQL_SERVER_IMAGE="mcr.microsoft.com/mssql/server:2022-latest"
CONTAINER_NAME="sql-server"

# Colors
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

    # Everything looks good
    log "info" "All set";
    return 0

}

# Check conditions
check_conditions

if [[ $? -eq 1 ]]
then 
    log "warning" "Make sure you're in the create_sql_server directory";
    exit 1;
fi;


# Unpack env vars
. ./${ENV_FILE}

# remove any exisitng containers
docker container rm -f ${CONTAINER_NAME}

if [[ $(arch) == "x86_64" ]]
then 
    winpty docker run -it -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=${PASSWORD}" -p ${PORT}:1433 --name ${CONTAINER_NAME} -d ${SQL_SERVER_IMAGE};
    if [[ $? -eq 0 ]] then
        log "success" "Successfully started SQL Server 2022 - container_name: ${CONTAINER_NAME}";
    fi;
elif [[ $(arch) == "arm64" ]]
then 
    # use azure sql edge
    docker run --cap-add SYS_PTRACE -e "ACCEPT_EULA=1" -e "MSSQL_SA_PASSWORD=${PASSWORD}" -p ${PORT}:1433 --name ${CONTAINER_NAME} -d ${AZURE_SQL_EDGE_IMAGE};
    if [[ $? -eq 0 ]] then
        log "success" "Successfully started Azure SQL Edge - container_name: ${CONTAINER_NAME}";
    fi;
else
    docker run -it -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=${PASSWORD}" -p ${PORT}:1433 --name ${CONTAINER_NAME} -d ${SQL_SERVER_IMAGE}
    if [[ $? -eq 0 ]] then
        log "success" "Successfully started SQL Server 2022 - container_name: ${CONTAINER_NAME}";
    fi;
fi;

