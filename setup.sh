#!/bin/sh

set -o errexit

ARROW_VER=0.9.0-1


install_lsb_release()
{
    echo "Step 0. Install lsb_release"

    # Check if yum or apt-get is available
    ( which yum                                                       \
      >  /dev/null                                                    \
      2>&1 )                                                          \
    || ( which apt-get                                                \
         >  /dev/null                                                 \
         2>&1 )                                                       \
    || ( echo "yum or apt-get not detected. Unsuported distribution." \
         && exit 1 )

    # Assume RedHat/CentOS first. If it fails assume Ubuntu/Debian.
    ( which yum                                    \
      >  /dev/null                                 \
      2>&1                                         \
      && yum install --assumeyes redhat-lsb-core ) \
    || ( which apt-get                             \
         >  /dev/null                              \
         2>&1                                      \
         && apt-get update                         \
         && apt-get install --assume-yes lsb-release )
}


which lsb_release      \
>  /dev/null           \
2>&1                   \
|| install_lsb_release

dist=`lsb_release --id | cut --fields=2`
rel=`lsb_release --release | cut --fields=2 | cut --delimiter=. --fields=1`


if [ "$dist" = "CentOS" ]
then
    # CentOS

    echo "Step 1. Configure prerequisites repositories"
    yum repolist               \
    |  grep epel               \
    || yum install --assumeyes \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rel.noarch.rpm

    yum install --assumeyes    \
        https://downloads.paradigm4.com/devtoolset-3/centos/6/sclo/x86_64/rh/devtoolset-3/scidb-devtoolset-3.noarch.rpm

    yum install --assumeyes \
        https://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-3.noarch.rpm

    cat <<EOF | tee /etc/yum.repos.d/scidb.repo
[scidb]
name=SciDB repository
baseurl=https://downloads.paradigm4.com/community/$SCIDB_VER/centos6.3
gpgkey=https://downloads.paradigm4.com/key
gpgcheck=1
enabled=1

[scidb-extra]
name=SciDB extra libs repository
baseurl=https://downloads.paradigm4.com/extra/$SCIDB_VER/centos6.3
gpgcheck=0
enabled=1
EOF

    echo "Step 2. Install prerequisites"
    for pkg in arrow-devel-$ARROW_VER.el6       \
               devtoolset-3-runtime             \
               devtoolset-3-toolchain           \
               gcc                              \
               git                              \
               libpqxx-devel                    \
               log4cxx-devel                    \
               pcre-devel                       \
               protobuf-devel-2.4.1             \
               rpm-build                        \
               rpmdevtools                      \
               scidb-$SCIDB_VER                 \
               scidb-$SCIDB_VER-dev             \
               scidb-$SCIDB_VER-libboost-devel  \
               zlib-devel
    do
        yum install --assumeyes $pkg
    done

else
    # Debian/Ubuntu

    echo "Step 1. Configure prerequisites repositories"
    apt-get update
    apt-get install                             \
        --assume-yes                            \
        --no-install-recommends                 \
        apt-transport-https                     \
        ca-certificates                         \
        gnupg-curl

    if [ "$dist" = "Debian" ]
    then
        cat <<APT_LINE | tee /etc/apt/sources.list.d/trusty-main.list
deb http://archive.ubuntu.com/ubuntu/ trusty main
APT_LINE
        apt-key adv --keyserver keyserver.ubuntu.com  --recv-keys \
            3B4FE6ACC0B21F32
    else
        cat <<APT_LINE | tee /etc/apt/sources.list.d/ubuntu-toolchain-r-test-trusty.list
deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu trusty main
APT_LINE
        apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv \
            1E9377A2BA9EF27F
    fi

    cat <<APT_LINE | tee /etc/apt/sources.list.d/scidb.list
deb https://downloads.paradigm4.com/ community/$SCIDB_VER/ubuntu14.04/
deb https://downloads.paradigm4.com/ extra/$SCIDB_VER/ubuntu14.04/
APT_LINE
     apt-key adv --fetch-keys https://downloads.paradigm4.com/key

    echo "Step 2. Install prerequisites"
    apt-get update
    apt-get install                                     \
        --assume-yes                                    \
        --no-install-recommends                         \
        g++                                             \
        git                                             \
        libarrow-dev=$ARROW_VER                         \
        liblog4cxx10-dev                                \
        libpcre3-dev                                    \
        libpqxx-dev                                     \
        libprotobuf-dev=2.5.0-9ubuntu1                  \
        m4                                              \
        make                                            \
        scidb-$SCIDB_VER                                \
        scidb-$SCIDB_VER-dev                            \
        scidb-$SCIDB_VER-libboost-system1.54-dev        \
        scidb-$SCIDB_VER-libboost1.54-dev

    if [ "$dist" = "Ubuntu" ]
    then
        apt-get install                         \
            --assume-yes                        \
            --no-install-recommends             \
            g++-4.9
    fi
fi
