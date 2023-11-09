#!/bin/bash

# Change the platform to run locally (arm)
version="v5-ga"
docker rm -f extract_and_load:$version;
docker rmi extract_and_load:$version;
docker build -t extract_and_load:$version Scripts/setup/create_local_env/;
docker tag extract_and_load:$version kingmoh/extract_and_load:$version;
docker push kingmoh/extract_and_load:$version;
# docker run --rm --name extract_and_load:amd --env-file ./.env extract_and_load:v3
