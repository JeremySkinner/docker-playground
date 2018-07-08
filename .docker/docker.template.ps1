param(
  [string]
  $command,

  [parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Parameters
)

. "$PSScriptRoot\..\.docker\docker.ps1"

Invoke-Docker $command @Parameters