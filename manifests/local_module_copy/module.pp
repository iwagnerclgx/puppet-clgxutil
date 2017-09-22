

define clgxutil::local_module_copy::module {

    $abs_source = global_findmodule($title)
    $abs_dest = "${::clgxutil::local_module_copy::install_dir}/${title}"


    file { "modulecopy-${title}":
      ensure  => directory,
      path    => $abs_dest,
      source  => $abs_source,
      recurse => true,
    }



}
