#/bin/bash

set -o errexit

source `dirname $0`/common.sh

docker run                                              \
       --detach                                         \
       --env SCIDB_INSTALL_PATH=/opt/scidb/$SCIDB_VER   \
       --env SCIDB_VER=$SCIDB_VER                       \
       --env http_proxy=$SQUID_PROXY                    \
       --name script-$TARGET                            \
       --tty                                            \
       --volume `pwd`:/this                             \
       $BUILD_IMG

docker exec script-$TARGET sh /this/setup.sh


if [ "$TARGET" == "deb" ]
then
    docker exec script-$TARGET apt-get install  \
           --assume-yes                         \
           --no-install-recommends              \
           openssh-client
fi

docker exec script-$TARGET mkdir /root/.ssh
docker cp ~/.ssh/id_rsa.github     script-$TARGET:/root/.ssh/id_rsa
docker cp ~/.ssh/id_rsa.github.pub script-$TARGET:/root/.ssh/id_rsa.pub
docker exec script-$TARGET ssh-agent > ssh-agent.out

AUTH=`grep SSH_AUTH ssh-agent.out | cut --delimiter ';' --fields 1`
AGENT=`grep SSH_AGENT ssh-agent.out | cut --delimiter ';' --fields 1`

docker exec                                     \
       --tty                                    \
       --interactive                            \
       --env $AGENT                             \
       --env $AUTH                              \
       script-$TARGET                           \
       ssh-add /root/.ssh/id_rsa

docker exec                                                     \
       --env $AGENT                                             \
       --env $AUTH                                              \
       script-$TARGET                                           \
       /this/extra-scidb-libs.sh $TARGET /root /this $PKG_VER

docker stop script-$TARGET
docker rm script-$TARGET
