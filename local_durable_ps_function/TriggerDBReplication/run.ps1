using namespace System.Net

# Input bindings are passed in via param block.
param($name)

Import-Module Az.ContainerInstance;

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


# Env Vars
$source_server_env = New-AzContainerInstanceEnvironmentVariableObject -Name "SOURCE_SERVER" -Value $source_server
$source_db_env = New-AzContainerInstanceEnvironmentVariableObject -Name "SOURCE_DB" -Value $source_db
$source_port_env = New-AzContainerInstanceEnvironmentVariableObject -Name "SOURCE_PORT" -Value $source_port
$target_server_env = New-AzContainerInstanceEnvironmentVariableObject -Name "TARGET_SERVER" -Value $target_server
$target_db_env = New-AzContainerInstanceEnvironmentVariableObject -Name "TARGET_DB" -Value $target_db
$target_port_env = New-AzContainerInstanceEnvironmentVariableObject -Name "TARGET_PORT" -Value $target_port
$tables_to_replicate_env = New-AzContainerInstanceEnvironmentVariableObject -Name "USER_DEFINED_TABLES_TO_REPLICATE" -Value $tables_to_replicate
$number_of_records_to_replicate_env = New-AzContainerInstanceEnvironmentVariableObject -Name "NUMBER_OF_RECORDS_TO_REPLICATE" -Value $number_of_records_to_replicate

# Container Details
$container = New-AzContainerInstanceObject -Name $container_guid -Image $Env:container_image -RequestCpu 4 -RequestMemoryInGb 16 -EnvironmentVariable @($source_server_env, $source_db_env, $source_port_env, $target_server_env, $target_db_env, $target_port_env, $tables_to_replicate_env, $number_of_records_to_replicate_env);
$containerGroup = New-AzContainerGroup -ResourceGroupName $resource_group_name -Name $container_group_name -Location $location -Container $container -OsType Linux -RestartPolicy "Never" -IdentityType "UserAssigned" -IdentityUserAssignedIdentity @{"/subscriptions/$Env:subscription/resourceGroups/$resource_group_name/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$Env:azure_role" = @{}} -SubnetId $subnet_id

# Send container logs
$cg_logs = Get-AzContainerInstanceLog -ResourceGroupName $resource_group_name -ContainerGroupName $container_group_name -ContainerName $container_guid

# Invoke container group 
Stop-AzContainerGroup -Name $container_group_name -ResourceGroupName $resource_group_name;

# Remove container
Remove-AzContainerGroup -Name $container_group_name -ResourceGroupName $resource_group_name;

$cg_logs