$ErrorActionPreference="Stop"
if (Test-Path variable:global:ProgressPreference){
  $ProgressPreference='SilentlyContinue'
}
chcp 437

function check_lastexitcode
{

    param([array]$allowableCodes)
    if ($allowableCodes -notcontains $LASTEXITCODE ){
      throw "Last Process wasn't Successful. Exited with ${LASTEXITCODE}"
    }
}

trap {
  break
}

$Env:path +=";c:\Python27;c:\Python27\scripts;C:\Program Files\Puppet Labs\Puppet\bin"

$passargs = $args
write-host "Running bootstrap.py ${passargs}"
& python.exe $PSScriptRoot/bootstrap.py $passargs
check_lastexitcode -allowableCodes @(0)

exit 0
