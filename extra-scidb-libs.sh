#!/bin/bash

set -xe

function usage
{
    cat - 1>&2 << EOF
Usage: $0 <rpm|deb|both> <working directory> <result directory> <package version>

This script creates a package for the SciDB Community Edition installer.
Specify debian, rpm, or both kinds of packages.
The working directory is where the build procedure will take place.
The result directory is where the script will write the package(s).
Obviously, both directories must be writable.

In addition, the environment variables SCIDB_VER and SCIDB_INSTALL_PATH
must be set to their appropriate values.
EOF

    exit 1
}

function die
{
    echo 1>&2 "Fatal: $1"
    exit 1
}

if [ -z "$SCIDB_INSTALL_PATH" ]; then
    echo "Need to set SCIDB_INSTALL_PATH - it is usually /opt/scidb/\$SCIDB_VER"
    exit 1
fi

function downloadLibs ()
{
    cd $work_dir
    params=("$@")
    for i in $(seq 1 "$((${#params[@]}/2))")
    do
        lib_name=${params[0]}
        arch_name=${params[1]}
        dir_name=$lib_name

        params=("${params[@]:2}")

        git clone https://github.com/Paradigm4/$lib_name.git
        cd $work_dir/$lib_name
        git checkout $arch_name
        cd ..
        mv $work_dir/$lib_name $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/
        rm -rf $work_dir/$lib_name
    done
}

function create_makefile()
{
    make_dir=$1
    cd $make_dir ; dirs=($(ls))

    echo "all:" > $make_dir/Makefile
    for lib_name in "${dirs[@]}"
    do
        makefiles=($(find . -name Makefile | sort | grep $lib_name | xargs -n1 dirname))
        echo -e "\t\$(MAKE) -C ${makefiles[0]}" >> $make_dir/Makefile
    done
    cd $work_dir
}

# Main script starts here.
[ $# -lt 4 ] && usage
[[ "$1" != "rpm" && "$1" != "deb" && "$1" != "both" ]] && usage

work_dir=$2
result_dir=$3
PKG_VER=$4

echo "Work dir is at: $work_dir"
echo "Result dir is at: $result_dir"
echo "Package version: $PKG_VER"

source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

[ -d $work_dir -a -w $work_dir ] || die "Working directory $work_dir does not exist or is not writable."
[ -d $result_dir -a -w $result_dir ] || die "Results directory $result_dir does not exist or is not writable."

rm -rf $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER
mkdir -p $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER

# The following array should contain tuples of the repo name and the branch to get.
declare -a libs=(
    "accelerated_io_tools" "v18.1.3"
    "equi_join"            "v18.1.0"
    "grouped_aggregate"    "v18.1.0"
    "shim"                 "v18.1.3"
    "stream"               "v18.1.0"
    "superfunpack"         "v18.1.2"
)

downloadLibs "${libs[@]}"

if [[ "$1" == "rpm" || "$1" == "both" ]]; then

    cd $work_dir
    rm -rf rpmbuild
    rpmdev-setuptree

    cp $source_dir/specs/extra-scidb-libs.spec $work_dir/rpmbuild/SPECS

    create_makefile $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER

    cp $source_dir/specs/conf $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/shim/conf

    tar -zcvf extra-scidb-libs-${SCIDB_VER:=18.1}.tar.gz extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER

    until ls -l $work_dir/rpmbuild/SOURCES > /dev/null; do sleep 1; done

    mv extra-scidb-libs-${SCIDB_VER:=18.1}.tar.gz $work_dir/rpmbuild/SOURCES

    rm -rf extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER

    cd $work_dir/rpmbuild/SPECS
    export SCIDB_INSTALL_PATH=/opt/scidb/${SCIDB_VER:=18.1}; QA_RPATHS=$[ 0x0002|0x0010 ] rpmbuild -ba extra-scidb-libs.spec

    cp $work_dir/rpmbuild/RPMS/x86_64/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER-1.x86_64.rpm $result_dir
    cp $work_dir/rpmbuild/RPMS/x86_64/extra-scidb-libs-${SCIDB_VER:=18.1}-debuginfo-$PKG_VER-1.x86_64.rpm $result_dir
    cp $work_dir/rpmbuild/SRPMS/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER-1.src.rpm $result_dir

fi

if [[ "$1" == "deb" || "$1" == "both" ]]; then
    create_makefile $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER
    cd $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER
    make SCIDB=$SCIDB_INSTALL_PATH

    if [ $? -eq 0 ]; then
        mkdir -p $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/$SCIDB_INSTALL_PATH/lib/scidb/plugins
        cp */*.so $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/$SCIDB_INSTALL_PATH/lib/scidb/plugins

        mkdir -p $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/$SCIDB_INSTALL_PATH/bin
        cp shim/shim $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/$SCIDB_INSTALL_PATH/bin

        mkdir -p $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/etc/init.d
        cp shim/init.d/shimsvc $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/etc/init.d
        chmod 755 $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/etc/init.d/shimsvc

        mkdir -p $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/var/lib/shim
        cp $source_dir/specs/conf $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/var/lib/shim
        cp -aR shim/wwwroot $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/var/lib/shim

        mkdir $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/DEBIAN
        m4 -DVERSION=${SCIDB_VER:=18.1} $source_dir/debian/control > $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/DEBIAN/control
        hname=$(hostname); hname="$hname.$(hostname -d)"
        m4 -DVERSION=${SCIDB_VER:=18.1} -DDATE="$(date)" -DHOSTNAME=$hname $source_dir/debian/copyright > $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/DEBIAN/copyright

        userinfo=$(getent passwd $(whoami) | cut -d: -f 5)
        [[ $userinfo == "" ]] && userinfo=$(whoami)
        userinfo="$userinfo <$(whoami)@paradigm4.com>"
        m4 -DVERSION=${SCIDB_VER:=18.1} -DUSERINFO="$userinfo" $source_dir/debian/changelog > $work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/DEBIAN/changelog

        dest=$work_dir/extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/DEBIAN
        cp -p $source_dir/debian/conffiles $dest
        cp -p $source_dir/debian/compat    $dest
        cp -p $source_dir/debian/postinst  $dest
        cp -p $source_dir/debian/prerm     $dest
        chmod a+rx $dest/{postinst,prerm}

        cd $work_dir

        params=("${libs[@]}")
        for i in `seq 1 "$((${#params[@]}/2))"`
        do
            lib_name=${params[0]}
            rm -rf ./extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER/$lib_name
            params=("${params[@]:2}")
        done

        dpkg-deb --build ./extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER
        mv ./extra-scidb-libs-${SCIDB_VER:=18.1}-$PKG_VER.deb $result_dir


    fi
fi
