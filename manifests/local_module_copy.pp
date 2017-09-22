
class clgxutil::local_module_copy (
  String $install_dir = $clgxutil::local_module_copy::params::install_dir,
  $module_list = []
) inherits clgxutil::local_module_copy::params {


  # function call with lambda:
  $module_list.each |String $module_name| {
    clgxutil::local_module_copy::module { $module_name: }
  }

}
