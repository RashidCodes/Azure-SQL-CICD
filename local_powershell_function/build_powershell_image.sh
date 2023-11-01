#!/bin/bash 

# Build and push image
docker rmi kingmoh/local_powershell_function:v5;
docker build --tag kingmoh/local_powershell_function:v5 .
docker push kingmoh/local_powershell_function:v5

# Registry username and password not required (image is public)
az functionapp config container set --image kingmoh/local_powershell_function:v5 --name localpowershellfunction --resource-group RG-TEST