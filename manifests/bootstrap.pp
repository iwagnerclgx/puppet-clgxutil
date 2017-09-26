
class clgxutil::bootstrap {

  if $::kernel == 'Linux' {
    $bootstrap_dir = '/bootstrap'
    $bootstrap_file = '' # Not implemented
    $bootstrap_unzip = '' # Not implemented
    $bootstrap_prebake = 'LinuxPreBake.sh'


  }
  elsif $::kernel == 'Windows' {
    $bootstrap_dir = 'c:/bootstrap'
    $bootstrap_apply = 'puppetapply.ps1'
    $bootstrap_unzip = 'unzip_puppet.ps1'
    $bootstrap_prebake = 'WindowsPreBake.ps1'


  } else {
    fail('Unknown OS')
  }

  $puppet_apply = "${bootstrap_dir}/${bootstrap_apply}"
  $puppet_unzip = "${bootstrap_dir}/${bootstrap_unzip}"
  $puppet_prebake = "${bootstrap_dir}/${bootstrap_prebake}"


  file {$bootstrap_dir:
    ensure => directory,
  }
  -> file {$puppet_apply:
    source => "puppet:///modules/clgxutil/bootstrap/${bootstrap_apply}",
  }
  -> file {$puppet_unzip:
    source => "puppet:///modules/clgxutil/bootstrap/${bootstrap_unzip}",
  }
  -> file {$puppet_prebake:
    source => "puppet:///modules/clgxutil/imageprep/${bootstrap_prebake}",
  }
}
