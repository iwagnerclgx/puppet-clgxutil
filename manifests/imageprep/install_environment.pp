# Install a local puppet environment to the system production
# environment
#

class clgxutil::imageprep::install_environment (

  String $local_puppet_dir = undef,
  String $env_code_dir = $clgxutil::imageprep::params::env_code_dir,

) inherits ::clgxutil::imageprep::params {

  file { "install_environment-${local_puppet_dir}":
    ensure  => directory,
    path    => $env_code_dir,
    source  => $local_puppet_dir,
    recurse => true,
  }




}
