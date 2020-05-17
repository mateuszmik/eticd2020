properties {
  $helloMessage = 'Saying hello. This can be used for cleanup or something!'
  $framework = "4.5"
  $buildDir = "$PSScriptRoot\build" 
  $zipFrom = "$PSScriptRoot\src\LazyService\LazyService\bin\Release\"
  $zipTo = "$buildDir\LazyService.zip"
}

cls

task default -depends Verify

task Hello { 
  $helloMessage
}

task Compile -depends Hello { 
  Exec { msbuild "$PSScriptRoot/src/LazyService/LazyService.sln" /p:Configuration=Release  }
}

task Test -depends Compile, Hello { 
    exec { 
        & "$PSScriptRoot\tools\NUnit.Console.3.0.0\nunit3-console.exe" "$PSScriptRoot\src\LazyService\LazyService.Tests\bin\Release\LazyService.Tests.dll" --teamcity --noheader
    }
}


task Lint -depends Test { 
  "LINTING.... "
  "LINTING.... "
  "LINTING.... "
  "LINTING.... "
  "LINTING.... "
  "LINTING.... "
}


task Pack -depends Lint{

    #=== removing old stuff 
    if(Test-Path $zipTo){
        write-host "Removing $zipTo"
        remove-item $zipTo
    }

    #=== adding some folder
    write-host "Checking if dir $buildDir is created"
    if(-not (test-path $buildDir)){
        write-host "Creating direcotyr $buildDir"
        New-Item -ItemType Directory -Force -Path $buildDir
    }

    #=== compressing
    Add-Type -assembly "system.io.compression.filesystem"

    write-host "Zipping $zipFrom ==> $zipTo"
    [io.compression.zipfile]::CreateFromDirectory($zipFrom, $zipTo)
}   

task Verify -depends Pack{
  "Veryfing... "
}