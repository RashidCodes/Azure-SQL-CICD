using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)


# Login using MSI
Az login --identity;

# Write to the Azure Functions log stream.
Write-Host "Commencing Data replication"

# Body
$source_server = $Request.Body.source_server
$source_db = $Request.Body.source_db
$source_port = $Request.Body.source_port
$target_server = $Request.Body.target_server
$target_db = $Request.Body.target_db
$target_port = $Request.Body.target_port
$tables_to_replicate = $Request.Body.tables_to_replicate
$number_of_records_to_replicate = $Request.Body.number_of_records_to_replicate

$yaml = @”
containers:
- command: []
  image: docker.io/kingmoh/extract_and_load:v3
  name: sample-job
  resources:
    cpu: 0.5
    memory: 1Gi
  env:
  - name: SOURCE_SERVER
    value: $source_server
  - name: SOURCE_DB
    value: $source_db
  - name: SOURCE_PORT
    value: $source_port
  - name: TARGET_SERVER
    value: $target_server
  - name: TARGET_DB
    value: $target_db
  - name: TARGET_PORT
    value: $target_port
  - name: USER_DEFINED_TABLES_TO_REPLICATE
    value: $tables_to_replicate
  - name: NUMBER_OF_RECORDS_TO_REPLICATE
    value: $number_of_records_to_replicate
initContainers: null
volumes: null
“@

# echo to a temp file 
echo $yaml > my-job-template.yaml;

# Trigger the job
Az containerapp job start --name "sample-job" --resource-group "RG-TEST" --yaml my-job-template.yaml > out

# Clean up: Remove config 
rm my-job-template.yaml;

$body = $(echo out);

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
