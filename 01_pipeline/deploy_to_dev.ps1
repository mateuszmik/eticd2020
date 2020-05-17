$env:DEPLOYMENT_TARGET="DEV"
Import-Module $PSScriptRoot\tools\psake\psake.psm1
Invoke-psake .\deploypsake.ps1
