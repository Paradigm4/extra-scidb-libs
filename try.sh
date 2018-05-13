#!/bin/sh

set -o errexit

iquery --afl --query "load_library('accelerated_io_tools')"
iquery --afl --query "load_library('equi_join')"
iquery --afl --query "load_library('grouped_aggregate')"
iquery --afl --query "load_library('stream')"
iquery --afl --query "load_library('superfunpack')"

echo "SciDB version in shim..."
shim -version | grep "SciDB Version: $SCIDB_VER"
