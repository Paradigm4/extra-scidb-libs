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

    wget --output-document /etc/yum.repos.d/bintray-rvernica-rpm.repo \
         https://bintray.com/rvernica/rpm/rpm

    echo "Step 2. Install prerequisites"
    for pkg in arrow-devel-$ARROW_VER.el6 \
               gcc                        \
               git                        \
               libpqxx-devel              \
               pcre-devel                 \
               rpm-build                  \
               rpmdevtools
    do
        yum install --assumeyes $pkg
    done
else
    # Debian/Ubuntu

    echo "Step 1. Configure prerequisites repositories"
    cat <<APT_LINE | tee /etc/apt/sources.list.d/bintray-rvernica.list
deb https://dl.bintray.com/rvernica/deb trusty universe
APT_LINE
    apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 46BD98A354BA5235

    echo "Step 2. Install prerequisites"
    apt-get update
    apt-get install             \
        --assume-yes            \
        --no-install-recommends \
        gcc                     \
        git                     \
        libarrow-dev=$ARROW_VER \
        libpcre3-dev            \
        libpqxx-dev             \
        m4
fi
