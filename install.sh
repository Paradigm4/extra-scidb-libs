#!/bin/sh

# Args:
#     --only-prereq: only install prerequisites, skip installing
#                    extra-scidb-libs

set -o errexit


PKG_VER=3
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

    cat <<EOF | tee /etc/yum.repos.d/scidb-extra.repo
[scidb-extra]
name=SciDB extra libs repository
baseurl=https://downloads.paradigm4.com/extra/$SCIDB_VER/centos6.3
gpgcheck=0
enabled=1
EOF

    echo "Step 2. Install prerequisites"
    yum install --assumeyes arrow-devel-$ARROW_VER.el6

    if [ "$1" != "--only-prereq" ]
    then
        echo "Step 3. Install extra-scidb-libs"
        yum install --assumeyes \
            https://paradigm4.github.io/extra-scidb-libs/extra-scidb-libs-18.1-$PKG_VER-1.x86_64.rpm
    fi
else
    # Debian/Ubuntu

    echo "Step 1. Configure prerequisites repositories"
    apt-get update
    apt-get install                             \
        --assume-yes                            \
        --no-install-recommends                 \
        apt-transport-https                     \
        ca-certificates                         \
        gnupg-curl                              \
        wget

    cat <<APT_LINE | tee /etc/apt/sources.list.d/scidb-extra.list
deb https://downloads.paradigm4.com/ extra/$SCIDB_VER/ubuntu14.04/
APT_LINE

    echo "Step 2. Install prerequisites"
    apt-get update
    apt-get install --assume-yes --no-install-recommends libarrow-dev=$ARROW_VER

    if [ "$1" != "--only-prereq" ]
    then
        echo "Step 3. Install extra-scidb-libs"
        wget --output-document /tmp/extra-scidb-libs-18.1-$PKG_VER.deb \
            https://paradigm4.github.io/extra-scidb-libs/extra-scidb-libs-18.1-$PKG_VER.deb
        dpkg --install /tmp/extra-scidb-libs-18.1-$PKG_VER.deb
    fi
fi
