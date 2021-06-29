TARGET=$1
if [ "$TARGET" == "rpm" ]
then
    BUILD_IMG=centos:7
    DEPLOY_IMG=-centos-7
else
    BUILD_IMG=ubuntu:xenial
    DEPLOY_IMG=-xenial
fi
export BUILD_IMG DEPLOY_IMG TARGET
export SCIDB_VER=19.11 PKG_VER=8 ARROW_VER_PART=300
