param($Context)

$output = @()

$output += Invoke-DurableActivity -FunctionName 'TriggerDBReplicationWithCA' -Input $Context.Input

$output
