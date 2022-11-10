#!/bin/bash

usage() {
    echo "Usage: $(basename $0) <build directory>"
    exit 0
}

[ -z $1 ] && { usage; }

packer build \
    -var-file ./variables.pkrvars.hcl \
    ./$1
