#!/bin/sh

set -o errexit

ARROW_VER=3.0.0
BASEDIR=$(dirname "$0")

install_lsb_release()
{
    echo "Step 0. Install lsb_release"

    # Check if yum or apt-get is available
    ( yum --version                                                     \
      >  /dev/null                                                      \
      2>&1 )                                                            \
    || ( apt-get --version                                              \
         >  /dev/null                                                   \
         2>&1 )                                                         \
    || ( echo "yum or apt-get not detected. Unsuported distribution."   \
         && exit 1 )

    # Assume RedHat/CentOS first. If it fails assume Ubuntu/Debian.
    ( yum --version                                     \
      >  /dev/null                                      \
      2>&1                                              \
      && yum install --assumeyes redhat-lsb-core )      \
    || ( apt-get --version                              \
         >  /dev/null                                   \
         2>&1                                           \
         && apt-get update                              \
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

    echo "-- - --"
    echo "Step 1/5. Configure prerequisites repositories"
    echo "-- - --"
    yum repolist               \
    |  grep epel               \
    || yum install --assumeyes \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-$rel.noarch.rpm

    yum install --assumeyes yum-utils
    yum-config-manager --add-repo                               \
        https://yum.repos.intel.com/mkl/setup/intel-mkl.repo
    sed --in-place 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/intel-mkl.repo

    yum install --assumeyes \
        https://downloads.paradigm4.com/devtoolset-3/centos/7/sclo/x86_64/rh/devtoolset-3/scidb-devtoolset-3.noarch.rpm

    yum install --assumeyes \
        https://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-3.noarch.rpm

    cat <<EOF | tee /etc/yum.repos.d/scidb.repo
[scidb]
name=SciDB repository
baseurl=https://downloads.paradigm4.com/community/$SCIDB_VER/centos7
gpgkey=https://downloads.paradigm4.com/key
gpgcheck=1
enabled=1

[scidb-extra]
name=SciDB extra libs repository
baseurl=https://downloads.paradigm4.com/extra/$SCIDB_VER/centos7
gpgcheck=0
enabled=1
EOF

    echo "-- - --"
    echo "Step 2/5. Install prerequisites"
    echo "-- - --"
    for pkg in cmake3                           \
               devtoolset-3-runtime             \
               devtoolset-3-toolchain           \
               gcc                              \
               git                              \
               libcurl-devel                    \
               libpqxx-devel                    \
               log4cxx-devel                    \
               openssl-devel                    \
               pcre-devel                       \
               protobuf-devel-2.4.1             \
               rpm-build                        \
               rpmdevtools                      \
               scidb-$SCIDB_VER                 \
               scidb-$SCIDB_VER-dev             \
               scidb-$SCIDB_VER-libboost-devel
    do
        yum install --assumeyes $pkg
    done

    echo "-- - --"
    echo "Step 3/5. Download, Build, and Install Arrow"
    echo "-- - --"
    # Arrow
    curl --location \
        "https://www.apache.org/dyn/closer.lua?action=download&filename=arrow/arrow-3.0.0/apache-arrow-3.0.0.tar.gz" \
        | tar --extract --gzip --directory=$BASEDIR
    old_path=`pwd`
    cd $BASEDIR/apache-arrow-3.0.0/cpp
    mkdir build
    cd build
    scl enable devtoolset-3                                             \
        "cmake3 ..                                                      \
             -DARROW_WITH_LZ4=ON                                        \
             -DARROW_WITH_ZLIB=ON                                       \
             -DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-3/root/usr/bin/g++ \
             -DCMAKE_C_COMPILER=/opt/rh/devtoolset-3/root/usr/bin/gcc   \
             -DCMAKE_INSTALL_PREFIX=/opt/apache-arrow"
    make
    make install
    cd ..
    rm -rf build
    cd $old_path

    echo "-- - --"
    echo "Step 4/5. Download, Build, and Install cURL"
    echo "-- - --"
    # cURL
    curl https://curl.se/download/curl-7.72.0.tar.gz    \
        | tar --extract --gzip --directory=$BASEDIR

    old_path=`pwd`
    cd $BASEDIR/curl-7.72.0
    ./configure --prefix=/opt/curl
    make
    make install
    make clean
    cd $old_path

    echo "-- - --"
    echo "Step 5/5. Download, Build and Install AWS SDK"
    echo "-- - --"
    # AWS SDK
    curl --location https://github.com/aws/aws-sdk-cpp/archive/1.8.3.tar.gz \
        | tar --extract --gzip --directory=$BASEDIR
    old_path=`pwd`
    cd $BASEDIR/aws-sdk-cpp-1.8.3
    mkdir build
    cd build
    scl enable devtoolset-3                                             \
        "cmake3 ..                                                      \
             -DBUILD_ONLY=s3                                            \
             -DBUILD_SHARED_LIBS=ON                                     \
             -DCMAKE_BUILD_TYPE=RelWithDebInfo                          \
             -DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-3/root/usr/bin/g++ \
             -DCMAKE_C_COMPILER=/opt/rh/devtoolset-3/root/usr/bin/gcc   \
             -DCMAKE_INSTALL_PREFIX=/opt/aws-sdk-cpp"
    make
    make install
    cd ..
    rm -rf build
    cd $old_path

else
    # Debian/Ubuntu

    echo "-- - --"
    echo "Step 1/3. Configure prerequisites repositories"
    echo "-- - --"
    sed --in-place                                                  \
        "\#deb http://deb.debian.org/debian jessie-updates main#d"  \
        /etc/apt/sources.list
    apt-get update
    apt-get install                             \
        --assume-yes                            \
        --no-install-recommends                 \
        apt-transport-https                     \
        ca-certificates                         \
        gnupg-curl                              \
        wget


    cat <<APT_LINE | tee /etc/apt/sources.list.d/intel-mkl.list
deb https://downloads.paradigm4.com/ mkl/
APT_LINE

    if [ "$dist" = "Debian" ]
    then
        cat <<APT_LINE | tee /etc/apt/sources.list.d/trusty-main.list
deb http://archive.ubuntu.com/ubuntu/ trusty main
APT_LINE
        apt-key adv --keyserver keyserver.ubuntu.com  --recv-keys \
            3B4FE6ACC0B21F32
    fi

    id=`lsb_release --id --short`
    codename=`lsb_release --codename --short`
    if [ "$codename" = "stretch" ]
    then
        cat > /etc/apt/sources.list.d/backports.list <<EOF
deb http://deb.debian.org/debian $codename-backports main
EOF
    fi
    wget https://apache.jfrog.io/artifactory/arrow/$(
        echo $id | tr 'A-Z' 'a-z'
         )/apache-arrow-archive-keyring-latest-$codename.deb
    apt install --assume-yes ./apache-arrow-archive-keyring-latest-$codename.deb
    sed --in-place                                      \
        's#bintray.com#jfrog.io/artifactory#'           \
        /etc/apt/sources.list.d/apache-arrow.sources


    cat <<APT_LINE | tee /etc/apt/sources.list.d/scidb.list
deb https://downloads.paradigm4.com/ community/$SCIDB_VER/xenial/
deb https://downloads.paradigm4.com/ extra/$SCIDB_VER/ubuntu16.04/
APT_LINE
    apt-key adv --fetch-keys https://downloads.paradigm4.com/key

    echo "-- - --"
    echo "Step 2/3. Install prerequisites"
    echo "-- - --"
    apt-get update
    apt-get upgrade --assume-yes
    apt-get install                             \
        --assume-yes                            \
        --no-install-recommends                 \
        bc                                      \
        cmake                                   \
        g++                                     \
        git                                     \
        libarrow-dev=$ARROW_VER-1               \
        libboost-system1.58-dev                 \
        libboost1.58-dev                        \
        libcurl4-openssl-dev                    \
        liblog4cxx10-dev                        \
        libpcre3-dev                            \
        libpqxx-dev                             \
        libprotobuf-dev                         \
        m4                                      \
        make                                    \
        scidb-$SCIDB_VER                        \
        scidb-$SCIDB_VER-dev

    echo "-- - --"
    echo "Step 3/3. Download, Build and Install AWS SDK"
    echo "-- - --"
    # AWS SDK
    wget --no-verbose --output-document -                               \
         https://github.com/aws/aws-sdk-cpp/archive/1.8.3.tar.gz        \
        | tar --extract --gzip --directory=$BASEDIR
    old_path=`pwd`
    cd $BASEDIR/aws-sdk-cpp-1.8.3
    mkdir build
    cd build
    cmake ..                                    \
        -DBUILD_ONLY=s3                         \
        -DBUILD_SHARED_LIBS=ON                  \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo       \
        -DCMAKE_INSTALL_PREFIX=/opt/aws-sdk-cpp
    make
    make install
    cd ..
    rm -rf build
    cd $old_path
fi
