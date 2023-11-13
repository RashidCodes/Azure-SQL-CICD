#!/bin/bash 

docker container rm -f azp-agent-linux;
docker rmi kingmoh/azp-agent:linux
docker build --tag "kingmoh/azp-agent:linux" .
# docker push kingmoh/azp-agent:linux