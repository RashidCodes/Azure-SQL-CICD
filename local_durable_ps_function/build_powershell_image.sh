#!/bin/bash 

# Build and push image
version="v3"
docker rmi kingmoh/local_powershell_function:$version;
docker build --tag kingmoh/local_powershell_function:$version .
docker push kingmoh/local_powershell_function:$version

# Registry username and password not required (image is public)
az functionapp config container set --image kingmoh/local_powershell_function:$version --name localpowershellfunction --resource-group RG-TEST