#!/bin/bash

export PATH=$PATH:/opt/puppetlabs/bin

SCRIPT_DIR=$(cd $(dirname $0) && pwd -P)
python $SCRIPT_DIR/bootstrap.py $@
