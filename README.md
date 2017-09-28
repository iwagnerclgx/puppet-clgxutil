# Clgxutil

#### Table of Contents

1. [Description](#description)
1. [Reference](#reference)

## Description

This module is a set of utilities that handle bootstrapping and image prepping
an image build pipeline. It is primarily used to decouple the logic and steps
of a puppet masterless setup from the image factory.


## Reference

* [Functions](#functions)


### Functions

#### `global_findmodule`

Returns the absolute path of the module. Like stdlib/get_module_path but not limited to the environment.

Argument: Module name.

*Type*: String

#### `clgxutil::get_userdata_customfacts`

Looks for a string custom_facts=```<data>``` in EC2 userdata, and sets static external facts.

The ```<data>``` should be a base64 encoded JSON Hash.

#### `clgxutil::reboot_pending`

Returns Boolean if reboot is pending on Windows. Same logic as puppetlabs-reboot, but no reboot action applied.
