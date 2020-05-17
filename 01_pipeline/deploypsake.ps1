properties {
  $framework = "4.5"
  $deploymentTarget = $env:DEPLOYMENT_TARGET
  $target_path = "c:\lazysystem\"
  $roundhouse_path= ".\tools\roundhouse\rh.exe"
}

Add-Type -assembly "system.io.compression.filesystem"

Import-Module $PSScriptRoot\tools\psake\psake.psm1  
Import-Module $PSScriptRoot\tools\poweryaml\poweryaml.psm1


task default -depends VerifyTask

task InitializeTask{
  write-host "Starting deployment of LazySystem!"
  write-host "ENVIRONMENT: $($deploymentTarget)"
}


task CleanTask -depends InitializeTask{ 
  write-host "Cleaning up..."  

  if(test-path "$PSScriptRoot\build\unpack"){
    remove-item "$PSScriptRoot\build\unpack\" -force -recurse
  }
}

task UninstallServiceTask -depends CleanTask { 
  UninstallService "LazyService" $deploymentTarget
}


task DeployDBTask -depends UninstallServiceTask { 
  
   $connectionString = GetYmlValue "lazydb" "config.connectionstring.$deploymentTarget"
   exec {& $roundhouse_path /debug /cs=$connectionString /dt=sqlserver /o=".\database\logs" /f="$PSScriptRoot\database" /u=upgrade /vf=.\database\version.xml /vx=/version /r=/lazysystem /ct=18000 /cta=18000 /simple /silent /donotbackupdatabase}
}   

task DeployServiceTask -depends DeployDBTask { 
  DeployService "LazyService" $deploymentTarget
  
}


task VerifyTask -depends DeployServiceTask{ 
  write-host "Veryfying..."  
}




function UninstallService($service, $env){
    
    #======= setting paths
    $path_to_installed_service = "$target_path$env\$service"
    write-host "Uninstalling Service [$service] to environment $env (path $path_to_installed_service\$service.exe)"
    $pathToUninstall = "$path_to_installed_service\$service.exe"
    

    #=======per environment configuration
    $serviceNameInThisEnv = GetYmlValue $service "config.serviceName.$env"


    #======= running uninstallation
    exec { &"$path_to_installed_service\$service.exe" uninstall -servicename:$serviceNameInThisEnv}  
}

function DeployService($service, $env){
    
    #====== setting some paths
    $path_to_installed_service = "$target_path$env\$service"
    write-host "Deploying Service [$service] to environment $env (under path $path_to_installed_service)"
    
    #====== copying binaries
    CopyService $service $path_to_installed_service
    $serviceNameInThisEnv = GetYmlValue $service "config.serviceName.$env"

    #====== running install
    write-host "Trying to install service $serviceNameInThisEnv (on $path_to_installed_service\$service.exe)"
    exec { &"$path_to_installed_service\$service.exe" install -servicename:$serviceNameInThisEnv -displayname:$serviceNameInThisEnv}

    #====== running start
    write-host "Trying to start service $serviceNameInThisEnv"
    exec { &"$path_to_installed_service\$service.exe" start -servicename:$serviceNameInThisEnv}
}


function GetYmlValue($serviceName, $pathToYml){
  write-host resolving $serviceName $pathToYml
  $yml = Get-Yaml -FromFile (Resolve-Path $PSScriptRoot\config.yml)

  $component = ($yml.components | where {$_.component -eq $serviceName})
  $var = "`$component.$pathToYml"
  $value = invoke-expression $var
  write-host "value: $value"
  $value
}

#===================


function CopyService($service, $destination_path){
    $base_unpack_path = "$PSScriptRoot\build"
    $unpackFrom = "$base_unpack_path\$service.zip"
    $unpackTo = "$base_unpack_path\unpack\"
    write-host "Unpacking $unpackFrom ==> $unpackTo"
    [io.compression.zipfile]::ExtractToDirectory($unpackFrom, $unpackTo)

    CreateDirIfDoesNotExist "$destination_path\"


    write-host "Copying all from folder $unpackTo to $destination_path\"
    copy-item "$unpackTo\*" "$destination_path\" -recurse -force
}

function CreateDirIfDoesNotExist($dir){
  write-host "Checking if path exists ($dir)"
  if(-not (Test-Path "$dir")){
      write-host "Creating path ($dir)"
      New-Item -ItemType Directory -Force -Path "$dir"
    }
}
     