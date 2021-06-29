#/bin/bash

set -o errexit

if [ "$#" -ne 2 ]
then
    echo "Need target parameter:"
    echo "$0 rpm|deb local|github|repo"
    exit 64
fi

source `dirname $0`/common.sh

MODE=$2


echo "==============="
echo "== = START = =="
echo "==============="
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


echo "================="
echo "== = INSTALL = =="
echo "================="
case "$MODE" in
    "local")
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
        ;;
    "github")
        docker exec deploy-$TARGET sh -c                                        \
          "wget -O- https://paradigm4.github.io/extra-scidb-libs/install.sh     \
           |  sh -s -- --github"
        ;;
    "repo")
        docker exec deploy-$TARGET sh -c                                        \
          "wget -O- https://paradigm4.github.io/extra-scidb-libs/install.sh     \
           |  sh"
        ;;
    *)
        echo "Unknown mode '$MODE'"
        exit 64
esac


echo "============="
echo "== = TRY = =="
echo "============="
docker cp ~/.aws deploy-$TARGET:/root/.aws
docker exec deploy-$TARGET sed --in-place 's#io-paths-list=/tmp#io-paths-list=/tmp:s3/p4tests/bridge_test/extra_scidb_libs#' /opt/scidb/19.11/etc/config.ini
docker exec deploy-$TARGET /opt/scidb/$SCIDB_VER/bin/scidbctl.py stop scidb
docker exec deploy-$TARGET /opt/scidb/$SCIDB_VER/bin/scidbctl.py start scidb
docker exec deploy-$TARGET sh /this/try.sh


echo "==================="
echo "== = UNINSTALL = =="
echo "==================="
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


echo "=============="
echo "== = STOP = =="
echo "=============="
docker stop deploy-$TARGET
docker rm deploy-$TARGET
aws s3 rm --recursive s3://p4tests/bridge_test/extra_scidb_libs
