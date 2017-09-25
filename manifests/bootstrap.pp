
class clgxutil::bootstrap {

  if $::kernel == 'Linux' {
    $bootstrap_dir = '/bootstrap'
    $bootstrap_file = ''

    file {$bootstrap_dir:
      ensure => directory,
    }


  }
  elsif $::kernel == 'Windows' {
    $bootstrap_dir = 'c:/bootstrap'
    $bootstrap_file = 'puppetapply.ps1'

    file {$bootstrap_dir:
      ensure => directory,
    }

    $puppet_apply = "${bootstrap_dir}/${bootstrap_file}"
    file {$puppet_apply:
      source => "puppet:///modules/clgxutil/bootstrap/${bootstrap_file}",
    }

  }

}
