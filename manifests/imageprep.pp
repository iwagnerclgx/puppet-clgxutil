

class clgxutil::imageprep (
  Boolean $install_puppet_tmpdir = false

) inherits ::clgxutil::imageprep::params {

  # Add bootstrapping files
  include clgxutil::bootstrap

  # configur sysprep
  if $facts['is_ec2'] and $facts['kernel'] == 'Windows' {
    include clgxutil::imageprep::ec2_windows
  }

  # Copy our temporary puppet files to the environmentpath
  if $install_puppet_tmpdir {
    file {"${::settings::environmentpath}/production":
      ensure  => directory,
      recurse => true,
      source  => $puppet_tmpdir
    }
  }

  file {"${os_tmpdir}/${prebake_script}":
    source => "puppet:///modules/clgxutil/imageprep/${prebake_script}",
  }
}
