#/bin/bash

set -o errexit

if [ "$#" -ne 1 ]
then
    echo "Need target parameter:"
    echo "$0 rpm|deb"
    exit 64
fi

source `dirname $0`/common.sh

docker run                                              \
       --detach                                         \
       --env SCIDB_INSTALL_PATH=/opt/scidb/$SCIDB_VER   \
       --env SCIDB_VER=$SCIDB_VER                       \
       --env http_proxy=$SQUID_PROXY                    \
       --name build-$TARGET                             \
       --tty                                            \
       --volume `pwd`:/this                             \
       $BUILD_IMG

docker exec build-$TARGET sh /this/setup.sh


if [ "$TARGET" == "deb" ]
then
    docker exec build-$TARGET apt-get install   \
           --assume-yes                         \
           --no-install-recommends              \
           openssh-client
fi


# -- - Private GitHub Setup - --

# docker exec build-$TARGET mkdir /root/.ssh
# docker cp ~/.ssh/id_rsa.github     build-$TARGET:/root/.ssh/id_rsa
# docker cp ~/.ssh/id_rsa.github.pub build-$TARGET:/root/.ssh/id_rsa.pub
# docker exec build-$TARGET ssh-agent > ssh-agent.out

# AUTH=`grep SSH_AUTH ssh-agent.out | cut --delimiter ';' --fields 1`
# AGENT=`grep SSH_AGENT ssh-agent.out | cut --delimiter ';' --fields 1`

# docker exec                                     \
#        --tty                                    \
#        --interactive                            \
#        --env $AGENT                             \
#        --env $AUTH                              \
#        build-$TARGET                            \
#        ssh-add /root/.ssh/id_rsa

# docker exec                                                     \
#        --env $AGENT                                             \
#        --env $AUTH                                              \
#        build-$TARGET                                            \
#        /this/extra-scidb-libs.sh $TARGET /root /this $PKG_VER


docker exec                                                     \
       build-$TARGET                                            \
       /this/extra-scidb-libs.sh $TARGET /root /this $PKG_VER

docker stop build-$TARGET
docker rm build-$TARGET
