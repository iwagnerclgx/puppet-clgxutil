
class clgxutil::bootstrap {

  if $::kernel == 'Linux' {
    $bootstrap_dir = '/bootstrap'

    file {$bootstrap_dir:
      ensure => directory,
    }


  }
  elsif $::kernel == 'Windows' {
    $bootstrap_dir = 'c:/bootstrap'

    file {$bootstrap_dir:
      ensure => directory,
    }
    # -> file {join([$bootstrap_dir, 'LinuxPreBake.sh'],'/'):
    #   source => 'puppet:///modules/clgxutil/bootstrap/WindowsPreBake.sh',
    # }

  }



}
