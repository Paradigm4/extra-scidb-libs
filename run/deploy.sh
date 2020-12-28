#/bin/bash

set -o errexit

source `dirname $0`/common.sh

docker run                                              \
       --detach                                         \
       --env EXTRA_SCIDB_LIBS_SYSTEMCTL_FAIL_OK=true    \
       --env http_proxy=$SQUID_PROXY                    \
       --name deploy-$TARGET                            \
       --tmpfs /run                                     \
       --tty                                            \
       --volume /sys/fs/cgroup:/sys/fs/cgroup:ro        \
       --volume `pwd`:/this                             \
       rvernica/scidb:$SCIDB_VER$DEPLOY_IMG

if [ "$TARGET" == "rpm" ]
then
    docker exec deploy-$TARGET /opt/scidb/$SCIDB_VER/bin/scidbctl.py start scidb
fi

docker exec deploy-$TARGET sh /this/install.sh --only-prereq

if [ "$TARGET" == "rpm" ]
then
    docker exec deploy-$TARGET yum install \
           --assumeyes \
           /this/extra-scidb-libs-$SCIDB_VER-$PKG_VER-1.x86_64.rpm
else
    docker exec deploy-$TARGET apt-get install      \
           --assume-yes                             \
           --no-install-recommends                  \
           libarrow$ARROW_VER_PART                  \
           libcurl3

    docker exec deploy-$TARGET dpkg --install                   \
           /this/extra-scidb-libs-$SCIDB_VER-$PKG_VER.deb
fi

docker cp ~/.aws deploy-$TARGET:/root/.aws

docker exec deploy-$TARGET sh /this/try.sh

if [ "$TARGET" == "rpm" ]
then
    docker exec deploy-$TARGET yum remove --assumeyes   \
           extra-scidb-libs-$SCIDB_VER
else
    docker exec deploy-$TARGET apt-get remove       \
           --assume-yes                             \
           --purge                                  \
           extra-scidb-libs-$SCIDB_VER
fi


docker stop deploy-$TARGET
docker rm deploy-$TARGET
