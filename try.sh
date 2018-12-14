#!/bin/sh

set -o errexit

QUERY="iquery --afl --query"

$QUERY "load_library('accelerated_io_tools')"
$QUERY "load_library('equi_join')"
$QUERY "load_library('grouped_aggregate')"
$QUERY "load_library('stream')"
$QUERY "load_library('superfunpack')"

echo "SciDB version in Shim..."
shim -version | grep "SciDB Version: $SCIDB_VER"

echo "HTTPS in Shim..."
wget --quiet --no-check-certificate --output-document=- \
    https://localhost:8083/version
echo

echo "regex()..."
$QUERY "filter(list('operators'), regex(name,'(.*)q(.*)'));"
$QUERY "filter(
          build(<x:string>[i], '[(a),(b),(c)]', true),
          regex(x, '(.)q(.)'))"

echo "rsub()..."
$QUERY "apply(
          build(
            <x:string>[i=0:0],
            '[(\'Paul Brown is a serious serious man.\')]',
            true),
          y, rsub(x,'s/serious/silly/'))"

echo "aio_save() w/ Arrow..."
$QUERY "aio_save(
          filter(
            build(<x:int64> [i=0:20:0:4], i),
            x % 2 = 0),
          '/tmp/try-1.arrow',
          'format=arrow')"
