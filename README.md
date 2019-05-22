# Tools Included

- [accelerated_io_tools](https://github.com/Paradigm4/accelerated_io_tools)
- [equi_join](https://github.com/Paradigm4/equi_join)
- [grouped_aggregate](https://github.com/Paradigm4/grouped_aggregate)
- [shim](https://github.com/Paradigm4/shim)
- [stream](https://github.com/Paradigm4/stream)
- [superfunpack](https://github.com/Paradigm4/superfunpack)

# Install Script

* [install.sh](install.sh)

Usage:
```bash
wget -O- https://paradigm4.github.io/extra-scidb-libs/install.sh | sudo sh
```
# Manuall Install

## CentOS 6 & 7

1. Install the Extra Packages for Enterprise Linux (EPEL) repository
   (see [instructions](https://fedoraproject.org/wiki/EPEL)), if not
   already installed.
1. Add the SciDB Extra Libs repository:
   ```bash
   > cat <<EOF | sudo tee /etc/yum.repos.d/scidb-extra.repo
   [scidb-extra]
   name=SciDB extra libs repository
   baseurl=https://downloads.paradigm4.com/extra/$SCIDB_VER/centos6.3
   gpgcheck=0
   enabled=1
   EOF
   ```
1. Install the `extra-scidb-libs` package:
   ```bash
   > sudo yum install extra-scidb-libs-18.1
   ```

## Ubuntu Trusty

1. Install the `apt-transport-https` package (if not already installed):
   ```bash
   > sudo apt-get install apt-transport-https
   ```
1. Add the SciDB Extra Libs repository:
   ```bash
   > cat <<APT_LINE | sudo tee /etc/apt/sources.list.d/scidb-extra.list
   deb https://downloads.paradigm4.com/ extra/$SCIDB_VER/ubuntu14.04/
   APT_LINE
   > sudo apt-get update
   ```
1. Install the `extra-scidb-libs` package:
   ```bash
   > sudo apt-get install extra-scidb-libs-18.1
   ```

# Download

## CentOS 6 & 7

* [extra-scidb-libs-18.1-8-1.x86_64.rpm](extra-scidb-libs-18.1-8-1.x86_64.rpm) (May 22, 2019)
* [extra-scidb-libs-18.1-7-1.x86_64.rpm](extra-scidb-libs-18.1-7-1.x86_64.rpm) (December 27, 2018)
* [extra-scidb-libs-18.1-6-1.x86_64.rpm](extra-scidb-libs-18.1-6-1.x86_64.rpm) (September 21, 2018)
* [extra-scidb-libs-18.1-5-1.x86_64.rpm](extra-scidb-libs-18.1-5-1.x86_64.rpm) (August 5, 2018)
* [extra-scidb-libs-18.1-4-1.x86_64.rpm](extra-scidb-libs-18.1-4-1.x86_64.rpm) (June 1, 2018)
* [extra-scidb-libs-18.1-3-1.x86_64.rpm](extra-scidb-libs-18.1-3-1.x86_64.rpm) (May 13, 2018)
* [extra-scidb-libs-18.1-2-1.x86_64.rpm](extra-scidb-libs-18.1-2-1.x86_64.rpm) (May 8, 2018)
* [extra-scidb-libs-18.1-1-1.x86_64.rpm](extra-scidb-libs-18.1-1-1.x86_64.rpm) (April 13, 2018)
* [extra-scidb-libs-18.1-0-1.x86_64.rpm](extra-scidb-libs-18.1-0-1.x86_64.rpm) (March 21, 2018)

## Ubuntu Trusty

* [extra-scidb-libs-18.1-8.deb](extra-scidb-libs-18.1-8.deb) (May 22, 2019)
* [extra-scidb-libs-18.1-7.deb](extra-scidb-libs-18.1-7.deb) (December 27, 2018)
* [extra-scidb-libs-18.1-6.deb](extra-scidb-libs-18.1-6.deb) (September 21, 2018)
* [extra-scidb-libs-18.1-5.deb](extra-scidb-libs-18.1-5.deb) (August 5, 2018)
* [extra-scidb-libs-18.1-4.deb](extra-scidb-libs-18.1-4.deb) (June 1, 2018)
* [extra-scidb-libs-18.1-3.deb](extra-scidb-libs-18.1-3.deb) (May 13, 2018)
* [extra-scidb-libs-18.1-2.deb](extra-scidb-libs-18.1-2.deb) (May 8, 2018)
* [extra-scidb-libs-18.1-1.deb](extra-scidb-libs-18.1-1.deb) (April 13, 2018)
* [extra-scidb-libs-18.1-0.deb](extra-scidb-libs-18.1-0.deb) (March 5, 2018)

# Change Log

* Version `8`
  * `shim` with fix for `save` argument length (`v18.1.4`)
* Version `7`
  * `accelerated_io_tools` with `result_size_limit` support (`v18.1.3`)
  * `shim` with `result_size_limit` support (`v18.1.3`)
* Version `6`
  * `superfunpack` linked against `libpcre` (Closes: #19)
  * Keep existing shim configuration file on conflict (Closes #18)
* Version `5`
  * `accelerated_io_tools` with `atts_only` support
  * `shim` with `admin` and `atts_only` support
* Version `4`
  * Add dependency to Apache Arrow and OpenSSL
  * Generate self-signed certificate for Shim
* Version `3`
  * Fix empty SciDB version in shim (Closes: #15)
* Version `2`
  * Add `stream` plugin with Apache Arrow
  * Update `accelerated_io_tools` plugin to include Apache Arrow
  * Fix requirements
  * Fix `shim` configuration and start
* Version `1`
  * Support for SciDB `18.1.7`
* Version `0`
  * Initial packages
