#!/bin/bash 

docker container rm -f azp-agent-linux;
docker run --name "azp-agent-linux" --env-file .agent-env kingmoh/azp-agent:linux 