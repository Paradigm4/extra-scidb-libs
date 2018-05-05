This repository contains the scripts and control files to build a
single package file for Debian/Ubuntu (`.deb`) or CentOS/Red Hat
Enterprise Linux (RHEL) (`.rpm`) containing the built libraries and
tools from other GitHub.com repositories.

Currently, the following tools are included:

- [accelerated_io_tools](https://github.com/Paradigm4/accelerated_io_tools)
- [equi_join](https://github.com/Paradigm4/equi_join)
- [grouped_aggregate](https://github.com/Paradigm4/grouped_aggregate)
- [shim](https://github.com/Paradigm4/shim)
- [superfunpack](https://github.com/Paradigm4/superfunpack)

The packages themselves have also been uploaded here for convenience,
but to be sure to have gotten the latest, one should clone the
repository and run the script:
```bash
./extra-scidb-libs <rpm|deb|both> <working directory> <result directory> <package version>
```
* `<working dir>` and `<result dir>` need to be absolute paths
* Due to constraints in the tool used to build CentOS/RHEL packages,
  `<working dir>` has to be the user's home directory (i.e., `~`)
* The `<package version>` number has to be the one specified in the
  package configuration files. See below for how to
  [bump the version number](#bump-version)

e.g. Build the CentOS/RHEL package, deposit it in `/tmp` using the home
directory as the place to do the compiling and packaging.  The version
is 0:
```bash
./extra-scidb-libs rpm ~ /tmp 0
```

To build the CentOS/RHEL package, one should build on a CentOS `6`
system as most of our plugins need to be compiled on the same platform
as SciDB itself - which is CentOS `6`. Also see dependencies below.

Similarly, for Debian/Ubuntu packages, one should run the script on
Ubuntu `14.04`.

All the requirements for building plugins are present here - no magic
happens to make plugins compile with this script, if they do not
compile on a cloned repository on their own.

To specify the plugins included in the package, edit the
`extra-scidb-libs.sh` file.  There is an array declared there that
looks like:

```sh
# The following array should contain tuples of the repo name and the branch to get.
declare -a libs=("superfunpack" "master"
                 "grouped_aggregate" "master"
                 "accelerated_io_tools" "master"
                 "equi_join" "master"
                 "shim" "master"
                )
```

To add a new plugin, e.g. foobar, just add it and the attendant branch
you would like to use so the array look like this:

```sh
# The following array should contain tuples of the repo name and the branch to get.
declare -a libs=("superfunpack" "master"
                 "grouped_aggregate" "master"
                 "accelerated_io_tools" "master"
                 "equi_join" "master"
                 "shim" "master"
                 "foobar" "my_dev_branch" # <-- NEW PLUGIN
                )
```

This should work for any plugin that builds a `.so` and wants it
copied to `$SCIDB_INSTALL_PATH/lib/scidb/plugins`.  For more
complicated installations, like `shim`, the package build files need
to be updated. You will have to modify the the build scripts, `.spec`
file, and `control` file.  appropriately.

# Dependencies

You might need to install `rpmdevtools` for CentOS

```sh
sudo yum install rpm-build rpmdevtools
```
