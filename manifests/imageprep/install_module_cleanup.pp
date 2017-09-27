

class clgxutil::imageprep::install_module_cleanup (
    $module_install_list = []
) {

    $module_install_list.each |String $module_name| {
      $abs_source = global_findmodule($module_name)
      file { $abs_source:
        ensure => absent,
        force  => true,
      }
    }

}
