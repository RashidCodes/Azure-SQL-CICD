# Create a container App Managed Environment with ARM
# Global Vars
$parameterFileName = "parameters.json"
$templateFileName = "template.json"
$subscriptionId = "<subscription>"
$location = "australiaeast"
$environmentName = "managedEnvironment-ca"
$workspace = "log-analytics" # workspace name
$workspaceLocation = "australiaeast"
$environmentApiVersion = "2023-05-02-preview"
$workSpaceApiVersion = "2020-08-01"
$deploymentApiVersion = "2020-06-01"
$subnetsApiVersion = "2020-07-01"
$resourceGroupName = "rg-test"
$vnetName = "sample-virtual-network"
$subnetName = "sample-subnet"

# Templates
# Uses Workload profiles (Consumption)
$managedEnvTemplate = @"
{
    "`$schema`": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "subscriptionId": {
            "type": "string"
        },
        "location": {
            "type": "string"
        },
        "secrets": {
            "type": "secureObject",
            "defaultValue": {
                "arrayValue": []
            }
        },
        "environmentName": {
            "type": "string"
        },
        "workspaceName": {
            "type": "string"
        },
        "workspaceLocation": {
            "type": "string"
        }
    },
    "resources": [
        {
            "apiVersion": "${environmentApiVersion}",
            "name": "[parameters('environmentName')]",
            "type": "Microsoft.App/managedEnvironments",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]",
                "Microsoft.Resources/deployments/updateSubnetTemplate"
            ],
            "properties": {
                "appLogsConfiguration": {
                    "destination": "${workspace}",
                    "logAnalyticsConfiguration": {
                        "customerId": "[reference(concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName')), '${workSpaceApiVersion}').customerId]",
                        "sharedKey": "[listKeys(concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName')), '${workSpaceApiVersion}').primarySharedKey]"
                    }
                },
                "workloadProfiles": [
                    {
                        "name": "Consumption",
                        "workloadProfileType": "Consumption"
                    }
                ],
                "vnetConfiguration": {
                    "infrastructureSubnetId": "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName",
                    "internal": true
                },
                "zoneRedundant": false
            }
        },
        {
            "apiVersion": "${workspaceApiVersion}",
            "name": "[parameters('workspaceName')]",
            "type": "Microsoft.OperationalInsights/workspaces",
            "location": "[parameters('workspaceLocation')]",
            "dependsOn": [],
            "properties": {
                "sku": {
                    "name": "PerGB2018"
                },
                "retentionInDays": 30,
                "workspaceCapping": {}
            }
        },
        {
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "${deploymentApiVersion}",
            "name": "updateSubnetTemplate",
            "resourceGroup": "${resourceGroupName}",
            "subscriptionId": "[parameters('subscriptionId')]",
            "properties": {
                "mode": "Incremental",
                "template": {
                    "`$schema`": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
                    "contentVersion": "1.0.0.0",
                    "parameters": {},
                    "variables": {},
                    "resources": [
                        {
                            "type": "Microsoft.Network/virtualNetworks/subnets",
                            "apiVersion": "${subnetsApiVersion}",
                            "name": "${vnetName}/${subnetName}",
                            "properties": {
                                "provisioningState": "Succeeded",
                                "addressPrefix": "10.0.2.0/23",
                                "ipConfigurations": [
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG1"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG10"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG11"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG12"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG13"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG14"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG15"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG16"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG17"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG18"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG19"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG2"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG20"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG21"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG22"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG23"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG24"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG25"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG26"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG27"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG28"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG29"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG3"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG4"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG5"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG6"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG7"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG8"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG9"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG1"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG10"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG11"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG12"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG13"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG14"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG15"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG16"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG17"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG18"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG19"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG2"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG20"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG21"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG22"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG23"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG24"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG25"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG26"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG27"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG28"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG29"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG3"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG4"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG5"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG6"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG7"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG8"
                                    },
                                    {
                                        "id": "/subscriptions/4e4591da-c6df-48ad-817c-27d8422fa0e1/resourceGroups/MC_BLUECOAST-5DDAB2B8-RG_BLUECOAST-5DDAB2B8_AUSTRALIAEAST/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEMPOOL-41320590-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEMPOOL-41320590-VMSS/ipConfigurations/IPCONFIG9"
                                    }
                                ],
                                "serviceEndpoints": [],
                                "delegations": [
                                    {
                                        "name": "Microsoft.App.environments",
                                        "id": "/subscriptions/${subscriptionId}/resourceGroup/${resourceGroupName}/providers/Microsoft.Network/availableDelegations/Microsoft.App.environments",
                                        "type": "Microsoft.Network/availableDelegations",
                                        "properties": {
                                            "serviceName": "Microsoft.App/environments",
                                            "actions": [
                                                "Microsoft.Network/virtualNetworks/subnets/join/action"
                                            ]
                                        }
                                    }
                                ],
                                "privateEndpointNetworkPolicies": "Disabled",
                                "privateLinkServiceNetworkPolicies": "Enabled"
                            }
                        }
                    ]
                }
            },
            "dependsOn": []
        }
    ]
}
"@


$parametersRawJSON = @"
{
    "`$schema`": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "subscriptionId": {
            "value": "${subscriptionId}"
        },
        "location": {
            "value": "${workspaceLocation}"
        },
        "secrets": {
            "value": {
                "arrayValue": []
            }
        },
        "environmentName": {
            "value": "${environmentName}"
        },
        "workspaceName": {
            "value": "${workspace}"
        },
        "workspaceLocation": {
            "value": "${location}"
        }
    }
}
"@

# Parameters
$parametersJSON = $parametersRawJSON;
Write-Output $parametersJSON > $parameterFileName;

# Template 
$templateJSON = $managedEnvTemplate;
Write-Output $templateJSON > $templateFileName

New-AzResourceGroupDeployment `
    -Name managed-env-arm `
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