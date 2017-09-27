set-executionpolicy Bypass -force
$Env:path +=";c:\Python27;C:\Program Files\Puppet Labs\Puppet\bin"

# AWSCLI cant handle codepage in packer
chcp 437

$passargs = $args
& python.exe $PSScriptRoot/bootstrap.py $passargs
