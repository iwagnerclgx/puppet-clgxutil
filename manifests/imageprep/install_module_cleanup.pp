

class clgxutil::imageprep::install_module_cleanup (
    $module_cleanup_list = []
) {

  if $facts['kernel'] == 'Linux' {
    $cmd_exec = '/bin/rm -Rf'
    $cmd_test = '/usr/bin/test -d'
    $cmd_path =  undef


  } elsif $facts['kernel'] == 'Windows' {
    $cmd_exec = 'powershell.exe -executionpolicy bypass remove-item -force -recurse -path'
    $cmd_test = 'powershell.exe -executionpolicy bypass Test-Path -PathType Container -Path'
    $cmd_path = 'C:/Windows/System32/WindowsPowerShell/v1.0/'
  }



    $module_cleanup_list.each |String $module_name| {
      $abs_source = global_findmodule($module_name)
      exec {"remove-${module_name}":
        command => "${cmd_exec} ${abs_source}",
        path    => $cmd_path,
        onlyif  => "${cmd_test} ${abs_source}",
      }
    }

}
