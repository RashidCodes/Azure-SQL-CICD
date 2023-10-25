FROM --platform=linux/amd64 python:3.8-slim-buster

WORKDIR /usr/src/app

COPY ["requirements.txt", "script.py", "table_config.conf", "./"]

RUN apt-get update -y && apt-get install -y gcc curl gnupg build-essential
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update -y && apt-get install -y unixodbc unixodbc-dev tdsodbc freetds-common freetds-bin freetds-dev postgresql
RUN apt-get update && ACCEPT_EULA=Y apt-get -y install mssql-tools msodbcsql18
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN apt-get update

RUN pip install --no-cache-dir -r requirements.txt


CMD [ "python", "./script.py" ]