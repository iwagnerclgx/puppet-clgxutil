

define clgxutil::imageprep::install_module {

    $abs_source = global_findmodule($title)
    $abs_dest = "${::clgxutil::imageprep::global_module_dir}/"

    if $facts['kernel'] == 'Linux' {
      $cmd_exec = 'cp -rp '
      $cmd_path = '/bin'

    } elsif $facts['kernel'] == 'Windows' {
      $cmd_exec = 'powershell.exe -executionpolicy bypass copy-item -force -recurse'
      $cmd_path = 'C:/Windows/System32/WindowsPowerShell/v1.0/'
    }



    exec {"copymodule-${title}":
      command => "${cmd_exec} ${abs_source} ${abs_dest}",
      path    => $cmd_path,
    }



}
