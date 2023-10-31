#!/bin/bash

# Change the platform to run locally (arm)
docker rm -f extract_and_load;
docker rmi extract_and_load:v3;
docker build -t extract_and_load:v3 Scripts/setup/create_local_env/;
docker tag extract_and_load:v3 kingmoh/extract_and_load:v3;
docker push kingmoh/extract_and_load:v3;
# docker run --rm --name extract_and_load:amd --env-file ./.env extract_and_load:v3
