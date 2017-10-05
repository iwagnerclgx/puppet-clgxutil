# Install a local puppet environment to the system production
# environment
#

class clgxutil::imageprep::install_environment (
  Array  $module_list         = [],
  String $env_code_dir        = $clgxutil::imageprep::params::env_code_dir,
  String $cmd_recurse_copy    = $clgxutil::imageprep::params::cmd_recurse_copy,
  String $cmd_recurse_del     = $clgxutil::imageprep::params::cmd_recurse_del,
  String $cmd_test_dir        = $clgxutil::imageprep::params::cmd_test_dir,
  String $cmd_path            = $clgxutil::imageprep::params::cmd_path,
  String $puppet_tmpdir       = $clgxutil::imageprep::params::puppet_tmpdir,
  String $global_module_dir   = $clgxutil::imageprep::params::global_module_dir,

) inherits ::clgxutil::imageprep::params {

    exec {'remove_environment':
      command => "${cmd_recurse_del} ${env_code_dir}",
      path    => $cmd_path,
      onlyif  => "${cmd_test_dir} ${env_code_dir}",
    }
    -> exec {'install_environment':
      command => "${cmd_recurse_copy} ${puppet_tmpdir} ${env_code_dir}",
      path    => $cmd_path,
    }


}
