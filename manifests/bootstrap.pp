
class clgxutil::bootstrap {



  if $::kernel == 'Linux' {
    $bootstrap_dir = '/bootstrap'

    file {$bootstrap_dir:
      ensure  => directory,
    }

    file {"${bootstrap_dir}/bootstrap.sh":
      source  => 'puppet:///modules/clgxutil/bootstrap/bootstrap.sh',
      mode    => '0775',
      owner   => 'root',
      group   => 'root',
      require => File[$bootstrap_dir]
    }

    file {"${bootstrap_dir}/bootstrap.py":
      source  => 'puppet:///modules/clgxutil/bootstrap/bootstrap.py',
      mode    => '0664',
      owner   => 'root',
      group   => 'root',
      require => File[$bootstrap_dir]
    }

  }
  elsif $::kernel == 'Windows' {
    $bootstrap_dir = 'c:/bootstrap'

    file {$bootstrap_dir:
      ensure  => directory,
    }

    file {"${bootstrap_dir}/bootstrap.ps1":
      source  => 'puppet:///modules/clgxutil/bootstrap/bootstrap.ps1',
      require => File[$bootstrap_dir]
    }

    file {"${bootstrap_dir}/bootstrap.py":
      source  => 'puppet:///modules/clgxutil/bootstrap/bootstrap.py',
      require => File[$bootstrap_dir]
    }

  } else {
    fail('Unknown OS')
  }





}
