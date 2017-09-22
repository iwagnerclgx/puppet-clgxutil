
class clgxutil::local_module_copy (
  String $install_dir = $clgxutil::local_module_copy::params::install_dir,
  $module_list = {}
) inherits clgxutil::local_module_copy::params {

  create_resources('clgxutil::local_module_copy::module', $module_list)

}
