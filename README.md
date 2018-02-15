This repository contains the scripts and control files to build a single package file for debian or rpm containing the built librarys and tools from other github repositories.

Currently, the following tools are included:

superfunpack
accelerated_io_tools
grouped_aggregate
equi_join
shim

The packages themselves have also been uploaded here for convenience, but to be sure to have gotten the latest, one should clone the repository and run the script:

./extra-scidb-libs <rpm|deb> <working dir> <result dir> <pkg ver>

e.g.

./extra-scidb-libs rpm ~ /tmp 0  # builds and rpm package, deposits it in /tmp using the home directory as the place to do the 
                                 # compling and packaging.  The version is 0.

To build for rpm, one should build on a CentOS 6 system as most of our plugins need to be compiled on the same platfrom as SciDB itself - which is CentOS 6.
Similarly, for debian packages, one should run the script on Ubuntu 14.04.

All the requirements for building plugins are present here - no magic happens to make plugins compile with this script, if they do not compile on a cloned repository on their own.

