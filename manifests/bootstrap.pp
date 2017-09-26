
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
    $bootstrap_apply = 'puppetapply.ps1'
    $bootstrap_unzip = 'unzip_puppet.ps1'

    file {$bootstrap_dir:
      ensure => directory,
    }

    $puppet_apply = "${bootstrap_dir}/${bootstrap_apply}"
    file {$puppet_apply:
      source => "puppet:///modules/clgxutil/bootstrap/${bootstrap_apply}",
    }

    $puppet_unzip = "${bootstrap_dir}/${bootstrap_unzip}"
    file {$puppet_unzip:
      source => "puppet:///modules/clgxutil/bootstrap/${bootstrap_unzip}",
    }

  }

}
