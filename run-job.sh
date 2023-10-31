#!/bin/bash

# Helpful
# az containerapp job start --name "sample-job" --resource-group "RG-TEST"
# az containerapp job show --name "sample-job" --resource-group "RG-TEST" --query "properties.template" --output yaml > my-job-template.yaml
# az containerapp job start --name "sample-job" --resource-group "RG-TEST" --yaml my-job-template.yaml

az containerapp job start --name "sample-job" --resource-group "RG-TEST" --yaml my-job-template.yaml