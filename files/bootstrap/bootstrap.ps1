set-executionpolicy Bypass -force
$Env:path +=";c:\Python27;C:\Program Files\Puppet Labs\Puppet\bin"

# AWSCLI cant handle codepage in packer
chcp 437

Start-Transcript -Path "C:\windows\temp\transcript.txt"

$passargs = $args
& python.exe $PSScriptRoot/bootstrap.py $passargs
$python_return = $LastExitCode

stop-transcript
Get-Content "C:\windows\temp\transcript.txt"

exit $LastExitCode
