

class clgxutil::imageprep::cleanup_module (
  Array  $module_list         = [],
  String $cmd_recurse_del     = $clgxutil::imageprep::params::cmd_recurse_del,
  String $cmd_test_dir        = $clgxutil::imageprep::params::cmd_test_dir,
  String $cmd_path            = $clgxutil::imageprep::params::cmd_path,
  String $puppet_tmpdir       = $clgxutil::imageprep::params::puppet_tmpdir,
  String $global_module_dir   = $clgxutil::imageprep::params::global_module_dir,

) inherits ::clgxutil::imageprep::params {


    $module_list.each |String $modname| {

      exec {"removemodule-${modname}":
        command => "${cmd_recurse_del} ${puppet_tmpdir}/modules/${modname}",
        path    => $cmd_path,
        onlyif  => "${cmd_test_dir} ${puppet_tmpdir}/modules/${modname}",
      }
    }

}
