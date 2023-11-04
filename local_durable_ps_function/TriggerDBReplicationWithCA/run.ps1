using namespace System.Net

# Input bindings are passed in via param block.
param($name)

Import-Module Az.App;

# Login using MSI
# This function has CONTRIBUTOR access in the rg-test resource group
# Without this, it won't be able to spin up and tear down the container instances
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
$container_guid = New-Guid
$container_group_name = "${container_guid}-cg"
$resource_group_name = "rg-test"
$location = "australiaeast"
$subnet_name = "default"
$vnet_name = "sample-virtual-network"
$subnet_id = @{
    Id = "/subscriptions/$Env:subscription/resourceGroups/$resource_group_name/providers/Microsoft.Network/virtualNetworks/$vnet_name/subnets/$subnet_name"
    Name = 'default-subnet'
}
$source_server_env = @{
    Name = "SOURCE_SERVER"
    Value = $source_server
}
$managed_environment_name = "managedEnvironment-RGTEST-8994"
$container_app_name = "azps-containerapp"

# Container App Template Object
$container_app_template = New-AzContainerAppTemplateObject -Name $container_guid -Image $Env:container_image -ResourceCpu 2.0 -ResourceMemory 4.0Gi -Env @($source_server_env)
$container_app_managed_env_id = (Get-AzContainerAppManagedEnv -ResourceGroupName $resource_group_name -EnvName $managed_environment_name).Id
$container_apps_logs = New-AzContainerApp -Name $container_app_name -ResourceGroupName $resource_group_name -Location $location -ManagedEnvironmentId $container_app_managed_env_id -TemplateContainer $container_app_template

# Check Status
if ($?) {
    return $container_apps_logs
} 
else {
    "An error occurred while creating ${container_app_name}: $container_apps_logs"
}
