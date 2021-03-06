

class clgxutil::imageprep::install_module (
  Array  $module_list         = [],
  String $cmd_recurse_copy    = $clgxutil::imageprep::params::cmd_recurse_copy,
  String $cmd_path            = $clgxutil::imageprep::params::cmd_path,
  String $puppet_tmpdir       = $clgxutil::imageprep::params::puppet_tmpdir,
  String $global_module_dir   = $clgxutil::imageprep::params::global_module_dir,

) inherits ::clgxutil::imageprep::params {


    $module_list.each |String $modname| {

      exec {"copymodule-${modname}":
        command => "${cmd_recurse_copy} ${puppet_tmpdir}/modules/${modname} ${global_module_dir}/",
        path    => $cmd_path,
      }
    }

}
