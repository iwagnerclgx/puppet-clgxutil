
class clgxutil::imageprep::params {


  if $facts['kernel'] == 'Linux' {
    $puppet_tmpdir  = '/tmp/puppet'
    $os_tmpdir = '/tmp'
    $prebake_script = 'LinuxPreBake.sh'
    $path_sep = ':'

  } elsif $facts['kernel'] == 'Windows' {
    $puppet_tmpdir  = 'c:/windows/temp/puppet'
    $os_tmpdir = 'c:/windows/temp'
    $prebake_script = 'WindowsPreBake.ps1'
    $path_sep = ';'
  }





}
