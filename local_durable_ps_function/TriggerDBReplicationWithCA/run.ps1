using namespace System.Net

# Input bindings are passed in via param block.
param($name)

Import-Module Az.App;

# Login using MSI
# This function has CONTRIBUTOR access in the rg-test resource group
# Without this, it won't be able to spin up and tear down the container apps
Connect-AzAccount -Identity

# Write to the Azure Functions log stream.
Write-Host "Commencing Data replication"

# Body
$source_server = $name.source_server
$source_db = $name.source_db
$source_port = $name.source_port
$target_server = $name.target_server
$target_db = $name.target_db
$target_port = $name.target_port
$tables_to_replicate = $name.tables_to_replicate
$number_of_records_to_replicate = $name.number_of_records_to_replicate

# Environment Vars
$subscriptionId = $Env:subscriptionId
$resourceGroup = $Env:resourceGroup
$managedEnvName = $Env:managedEnvName
$userAssignedIdentity = $Env:userAssignedIdentity
$containerImageName = $Env:containerImageName
$location = $Env:location
$parameterFileName = $Env:parameterFileName
$templateFileName = $Env:templateFileName 
$azureSqlRoleClientId = $Env:azureSqlRoleClientId
$logWorkSpaceName = $Env:logWorkspaceName

# Global Vars
$guid = New-Guid
$randomStr = $guid.ToString().substring(0, 23);
$containerAppName = "fg-${randomStr}-ca"
$containerName = "extract-and-load"
$apiVersion = "2023-05-02-preview" # Use GA Api Version
$identityResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$identity"
$managedEnvironmentId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.App/managedEnvironments/$managedEnvName"

# Templates
$parametersRawJSON = @"
{
    "`$schema`": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "subscriptionId": {
            "value": "$subscriptionId"
        },
        "name": {
            "value": "$containerAppName"
        },
        "location": {
            "value": "$location"
        },
        "environmentId": {
            "value": "$managedEnvironmentId"
        },
        "containers": {
            "value": [
                {
                    "name": "$containerName",
                    "image": "$containerImageName",
                    "command": [],
                    "resources": {
                        "cpu": "2.5",
                        "memory": "5Gi"
                    },
                    "env": [
                        {
                            "name": "SOURCE_SERVER",
                            "value": "${source_server}"
                        },
                        {
                            "name": "SOURCE_DB",
                            "value": "${source_db}"
                        },
                        {
                            "name": "SOURCE_PORT",
                            "value": "${source_port}"
                        },
                        {
                            "name": "TARGET_SERVER",
                            "value": "${target_server}"
                        },
                        {
                            "name": "TARGET_DB",
                            "value": "${target_db}"
                        },
                        {
                            "name": "TARGET_PORT",
                            "value": "${target_port}"
                        },
                        {
                            "name": "USER_DEFINED_TABLES_TO_REPLICATE",
                            "value": "${tables_to_replicate}"
                        },
                        {
                            "name": "NUMBER_OF_RECORDS_TO_REPLICATE",
                            "value": "${number_of_records_to_replicate}"
                        },
                        {
                            "name": "CLIENT_ID",
                            "value": "${azureSqlRoleClientId}"
                        }
                    ]
                }
            ]
        },
        "registries": {
            "value": []
        },
        "secrets": {
            "value": {
                "arrayValue": []
            }
        }
    }
}
"@


$templateRawJSON = @"
{
    "`$schema`": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "subscriptionId": {
            "type": "string"
        },
        "name": {
            "type": "string"
        },
        "location": {
            "type": "string"
        },
        "environmentId": {
            "type": "string"
        },
        "containers": {
            "type": "array"
        },
        "secrets": {
            "type": "secureObject",
            "defaultValue": {
                "arrayValue": []
            }
        },
        "registries": {
            "type": "array"
        }
    },
    "resources": [
        {
            "apiVersion": "$apiVersion",
            "name": "[parameters('name')]",
            "type": "Microsoft.App/containerapps",
            "kind": "containerapps",
            "location": "[parameters('location')]",
            "identity": {
                "type": "UserAssigned",
                "userAssignedIdentities": {
                    "$identityResourceId": {}
                }
            },
            "dependsOn": [],
            "properties": {
                "environmentId": "[parameters('environmentId')]",
                "configuration": {
                    "secrets": "[parameters('secrets').arrayValue]",
                    "registries": "[parameters('registries')]",
                    "activeRevisionsMode": "Single"
                },
                "template": {
                    "containers": "[parameters('containers')]",
                    "scale": {
                        "minReplicas": 1,
                        "maxReplicas": 1
                    }
                },
                "workloadProfileName": "Consumption"
            }
        }
    ]
}
"@


# Parameters
$parametersJSON = $parametersRawJSON;
Write-Output $parametersJSON > $parameterFileName;

# Template 
$templateJSON = $templateRawJSON;
Write-Output $templateJSON > $templateFileName


$resourceDeploymentStatus = New-AzResourceGroupDeployment `
    -Name sample-container-app-arm `
    -ResourceGroupName rg-test `
    -TemplateFile $templateFileName `
    -TemplateParameterFile $parameterFileName


# Check Status and clean up
if ($?) {
    # Clean up 
    Remove-Item ./$templateFileName;
    Remove-Item ./$parameterFileName;
    return "Successfully created containerapp: $containerAppName"
} 
else {
    # Clean up 
    Remove-Item ./$templateFileName;
    Remove-Item ./$parameterFileName;
    return "An error occurred while creating ${containerAppName}"
}


# Remove a container app after the container completes execution
$appRevisions = Get-AzContainerAppRevision -ContainerAppName ${containerAppName} -ResourceGroupName $resourceGroup;
$revisions = ($appRevisions | Where-Object active -eq false).name
$activeRevision = $revisions.split(" ")[0]
Write-Host "Active revision: $activeRevision"

# check the logs in the operational insights workspace
$query = @"
ContainerAppConsoleLogs_CL
| where RevisionName_s == "${activeRevision}"
| where Log_s has ("Inspect logs for errors")
"@
$workSpaceCustomerId = (Get-AzOperationalInsightsWorkspace -Name $logWorkSpaceName -ResourceGroupName $resourceGroup).CustomerId


# May the polling begin
while ([string]::IsNullOrEmpty((Invoke-AzOperationalInsightsQuery -WorkspaceId $workSpaceCustomerId -Query $query).Results.Log_s)){
    Write-Host "Polling in the next $pollingTime seconds";
    Start-Sleep -Seconds $pollingTime;
} 

if ((Invoke-AzOperationalInsightsQuery -WorkspaceId $workSpaceCustomerId -Query $query).Results.Log_s)
{
    $results = Invoke-AzOperationalInsightsQuery -WorkspaceId $workSpaceCustomerId -Query $query
    $logs = $results.Results.Log_s;
    Write-Host "Logs: ${logs}";
    Write-Host "Container execution completed. Removing container app"
    Remove-AzContainerApp -Name ${containerAppName} -ResourceGroupName $resourceGroup
}