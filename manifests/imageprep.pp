

class clgxutil::imageprep (
  Boolean $install_puppet_to_env = false,  # Whether to move the temp puppet code to the environmentpath
  Array   $module_install_list   = [],     # list of modules to move to the global module dir

) inherits ::clgxutil::imageprep::params {

  # Used to cleanup installed modules
  stage { 'cleanup_module':
    require => Stage['main'],
  }
  -> stage { 'install_environment':
    require => Stage['cleanup_module'],
  }

  # configure sysprep
  if $facts['is_ec2'] and $facts['kernel'] == 'Windows' {
    include clgxutil::imageprep::ec2_windows
  }

  class {'static_custom_facts':
    purge_unmanaged => true,
    custom_facts    => {}
  }

  # Install selected modules to the global module dir
  class {'clgxutil::imageprep::install_module':
    module_list => $module_install_list
  }

  # Remove the global modules from the local dir
  class {'clgxutil::imageprep::cleanup_module':
    module_list => $module_install_list,
    stage       => cleanup_module,
  }

  if( $install_puppet_to_env ) {
    class {'clgxutil::imageprep::install_environment':
      stage   => install_environment,
    }
  }




}
