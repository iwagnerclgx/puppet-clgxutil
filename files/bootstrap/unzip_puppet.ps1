

$Env:path =  "C:\ProgramData\chocolatey\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;"
$Env:path += "C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files\Amazon\cfn-bootstrap\;"
$Env:path += "C:\Program Files\Puppet Labs\Puppet\bin;C:\Program Files\Amazon\AWSCLI\;c:\python27\scripts"


if ( test-path c:/windows/temp/puppet ) {
  remove-item -recurse c:/windows/temp/puppet
}

& 'C:\Program Files\7-Zip\7z.exe' x -oc:\windows\temp\ c:\windows\temp\puppet.zip 
