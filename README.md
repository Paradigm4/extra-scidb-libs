# Overview

This repository contains the scripts and control files to build a
single package file for Debian/Ubuntu (`.deb`) or CentOS/Red Hat
Enterprise Linux (RHEL) (`.rpm`) containing the built libraries and
tools from other GitHub.com repositories.

Currently, the following tools are included:

- [accelerated_io_tools](https://github.com/Paradigm4/accelerated_io_tools)
- [equi_join](https://github.com/Paradigm4/equi_join)
- [grouped_aggregate](https://github.com/Paradigm4/grouped_aggregate)
- [shim](https://github.com/Paradigm4/shim)
- [stream](https://github.com/Paradigm4/stream)
- [superfunpack](https://github.com/Paradigm4/superfunpack)

# Build

The packages themselves have also been uploaded
[here](https://paradigm4.github.io/extra-scidb-libs/) for convenience,
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

# Dependencies

A convenience script is provided which installs all the dependencies
required to build the packages for Debian/Ubuntu or CentOS/RHEL
systems. The script can be run with:

```bash
sudo sh setup.sh
```

# Add New Plugin

To specify the plugins included in the package, edit the
`extra-scidb-libs.sh` file.  There is an array declared there that
looks like:

```bash
# The following array should contain tuples of the repo name and the tag to get.
declare -a libs=(
    "accelerated_io_tools" "v18.1.0"
    "equi_join"            "v18.1.0"
)
```

To add a new plugin, e.g. foobar, just add it and the attendant tag
you would like to use so the array look like this:

```bash
# The following array should contain tuples of the repo name and the tag to get.
declare -a libs=(
    "accelerated_io_tools" "v18.1.0"
    "equi_join"            "v18.1.0"
    "foobar"               "foobar_tag" # <-- NEW PLUGIN
)
```

Moreover, edit the `%install` section of the
`specs/extra-scidb-libs.spec` file to:

1. Copy the `.so` file of the new plugin to `buildroot`.
1. Add the `.so` file to `files.lst`.

This should work for any plugin that builds a `.so` and wants it
copied to `$SCIDB_INSTALL_PATH/lib/scidb/plugins`.  For more
complicated installations, like `shim`, the package build files need
to be updated. You will have to modify the the build scripts, `.spec`
file, and `control` file.  appropriately. Finally, add a
`load_library` command to the `try.sh` script in order for Travis to
try to load the plugin once the `extra-scidb-libs` package is
installed.

Make sure to also add the new plugin to the list of tools included in 
the `README.md` file on the `master` and `gh-pages` branches.

# Update Plug-in

To update one of the included plugins do the following:

1. Create a tag in the pugin repository. Bump the plugin tag version 
   accordingly.
1. Update `extra-scidb-libs.sh` and use the new tag.
1. Bump package version (see next)

# Bump Version

In order to increase the version number of the package do the
following:

1. Edit the `specs/extra-scidb-libs.spec` file and update the `Version:` line. Optionally, update the `%changelog` section.
1. Edit the `debian/control` file and update the `Version:` line.
1. Edit the `debian/copyright` file and update the `Version:` line.
1. Optionally, update the `debian/changelog` file.
1. Edit the `.travis.yml` file and update the `PKG_VER=` line.
1. Use the new version number when building the packages.

# Publish

After building a new version of the packages, do the following to
publish them:

1. Edit the `install.sh` file and update the `PKG_VER=` line. Commit
   the change in the `master` branch.
1. Create a new Release on GitHub.com
1. Copy the `install.sh` file to the `gh-pages` branch.
1. Copy the `.rpm` and `.deb` files to the `gh-pages` branch.
1. Update the `README.md` in the `gh-pages` branch to list the new packages.
