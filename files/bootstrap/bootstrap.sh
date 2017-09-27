#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd -P)
python $SCRIPT_DIR/bootstrap.py $@
