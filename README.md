This repository contains the scripts and control files to build a single package file for debian or rpm containing the built librarys and tools from other github repositories.

Currently, the following tools are included:

- [accelerated_io_tools](https://github.com/Paradigm4/accelerated_io_tools)
- [grouped_aggregate](https://github.com/Paradigm4/grouped_aggregate)
- [equi_join](https://github.com/Paradigm4/equi_join)
- [superfunpack](https://github.com/Paradigm4/superfunpack)
- [shim](https://github.com/Paradigm4/shim)

The packages themselves have also been uploaded here for convenience, but to be sure to have gotten the latest, one should clone the repository and run the script:

```sh
./extra-scidb-libs <rpm|deb> <working dir> <result dir> <pkg ver>
```

e.g.

```sh
./extra-scidb-libs rpm ~ /tmp 0  # builds and rpm package, deposits it in /tmp using the home directory as the place to do the
                                 # compling and packaging.  The version is 0.
```

To build for rpm, one should build on a CentOS 6 system as most of our plugins need to be compiled on the same platfrom as SciDB itself - which is CentOS 6. Also see dependencies below.

Similarly, for debian packages, one should run the script on Ubuntu 14.04.

All the requirements for building plugins are present here - no magic happens to make plugins compile with this script, if they do not compile on a cloned repository on their own.

To specify the plugins included in the package, edit the `extra-scidb-libs.sh` file.  There is an array declared there that looks like:

```sh
# The following array should contain tuples of the repo name and the branch to get.
declare -a libs=("superfunpack" "master"
		 "grouped_aggregate" "master"
                 "accelerated_io_tools" "master"
                 "equi_join" "master"
                 "shim" "master"
		)
```

To add a new plugin, e.g. foobar, just add it and the attendant branch you'd like to use so the array look like this:

```sh
# The following array should contain tuples of the repo name and the branch to get.
declare -a libs=("superfunpack" "master"
		 "grouped_aggregate" "master"
                 "accelerated_io_tools" "master"
                 "equi_join" "master"
                 "shim" "master"
                 "foobar" "my_dev_branch"
		)
```

This should work for any plugin that builds a `.so` and wants it copied to `$SCIDB_INSTALL_PATH/lib/scidb/plugins`.  For more complicated installations, like `shim`, you are on your own.  You'll have to modify the scripts, spec files and control files appropriately.

# Dependencies

You might need to install `rpmdevtools` for Centos

```sh
sudo yum install rpm-build rpmdevtools
```
