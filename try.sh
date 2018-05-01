#!/bin/sh

iquery --afl --query "load_library('accelerated_io_tools')"
iquery --afl --query "load_library('grouped_aggregate')"
iquery --afl --query "load_library('equi_join')"
iquery --afl --query "load_library('superfunpack')"
