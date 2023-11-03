param($Context)

$output = @()

$output += Invoke-DurableActivity -FunctionName 'TriggerDBReplication' -Input $Context.Input

$output
