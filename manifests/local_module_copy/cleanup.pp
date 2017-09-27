

class clgxutil::local_module_copy::cleanup (
    $module_list = []
) {

    $module_list.each |String $module_name| {
      $abs_source = global_findmodule($module_name)
      file { $abs_source:
        ensure => absent,
        force  => true,
      }
    }

}
