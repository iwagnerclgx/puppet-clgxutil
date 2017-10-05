
class clgxutil::imageprep::params {

  $global_module_dir = "${::settings::codedir}/modules"
  $env_code_dir = "${::settings::environmentpath}/${::settings::environment}"

  if $facts['kernel'] == 'Linux' {

    $puppet_tmpdir  = '/tmp/puppet'
    $os_tmpdir = '/tmp'
    $cmd_recurse_copy = 'cp -rp'
    $cmd_recurse_del = 'rm -Rf'
    $cmd_test_dir = '/usr/bin/test -d'
    $cmd_path = '/bin'

  } elsif $facts['kernel'] == 'Windows' {

    $puppet_tmpdir  = 'c:/windows/temp/puppet'
    $os_tmpdir = 'c:/windows/temp'
    $cmd_recurse_copy = 'powershell.exe -executionpolicy bypass copy-item -force -recurse'
    $cmd_recurse_del = 'powershell.exe -executionpolicy bypass remove-item -force -recurse -path'
    $cmd_test_dir = 'powershell.exe -executionpolicy bypass Test-Path -PathType Container -Path'
    $cmd_path = 'C:/Windows/System32/WindowsPowerShell/v1.0/'
  }




}
