
class clgxutil::local_module_copy (
  String $install_dir = $clgxutil::local_module_copy::params::install_dir,
  String $env_dir = $clgxutil::local_module_copy::params::env_dir,
  $module_list = [],

) inherits clgxutil::local_module_copy::params {

  $install_environment = lookup('clgxutil::local_module_copy::install_puppet_environment',{default_value => false })

  stage { 'cleanup':
    require => Stage['main'],
  }


  # function call with lambda:
  $module_list.each |String $module_name| {
    notice($module_name)
    clgxutil::local_module_copy::module { $module_name: }
  }

  class {'clgxutil::local_module_copy::cleanup':
    module_list => $module_list,
    stage       => cleanup
  }


}
