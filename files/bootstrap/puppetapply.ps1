

$Env:path="C:\ProgramData\chocolatey\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files\Amazon\cfn-bootstrap\;C:\Program Files\Puppet Labs\Puppet\bin;C:\Program Files\Amazon\AWSCLI\;c:\python27\scripts"



$puppet_temp="c:\windows\temp\puppet"
$puppet_environment="c:\ProgramData\PuppetLabs\code\environments\production"


if( test-path "${puppet_temp}\manifest.pp" ){
  $workdir=$puppet_temp
  $applycmd="puppet apply --modulepath modules --hiera_config hiera.yaml --verbose "
} elseif ( test-path "${puppet_environment}/manifest.pp" ){
  $workdir=$puppet_environment
  $applycmd="puppet apply --verbose "

} else {

  throw "Cannot locate puppet files"
}

cd $workdir

cmd.exe /c "$applycmd -e 'include clgxutil::bootstrap::userdata_customfacts'"
cmd.exe /c $applycmd manifest.pp
