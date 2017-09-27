

class clgxutil::imageprep (
  Boolean $install_puppet_tmpdir = false,

  String $global_module_dir = $clgxutil::imageprep::params::global_module_dir,
  String $env_code_dir = $clgxutil::imageprep::params::env_code_dir,
  $module_install_list = [],

) inherits ::clgxutil::imageprep::params {

  # Used to cleanup installed modules
  stage { 'cleanup_module':
    require => Stage['main'],
  }

  # Add bootstrapping files
  include clgxutil::bootstrap

  # configure sysprep
  if $facts['is_ec2'] and $facts['kernel'] == 'Windows' {
    include clgxutil::imageprep::ec2_windows
  }


  # function call with lambda:
  $module_install_list.each |String $module_name| {
    clgxutil::imageprep::install_module { $module_name: }
  }

  class {'clgxutil::imageprep::install_module_cleanup':
    module_install_list => $module_install_list,
    stage               => cleanup_module,
  }




}
