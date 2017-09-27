

define clgxutil::imageprep::install_module {

    $abs_source = global_findmodule($title)
    $abs_dest = "${::clgxutil::imageprep::global_module_dir}/${title}"


    file { "modulecopy-${title}":
      ensure  => directory,
      path    => $abs_dest,
      source  => $abs_source,
      recurse => true,
    }



}
