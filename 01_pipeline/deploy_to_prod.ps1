$env:DEPLOYMENT_TARGET="PROD"
Import-Module $PSScriptRoot\tools\psake\psake.psm1
Invoke-psake .\deploypsake.ps1
