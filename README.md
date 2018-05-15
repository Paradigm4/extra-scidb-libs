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
wget -O - https://paradigm4.github.io/extra-scidb-libs/install.sh | sudo sh
```

# CentOS 6 & 7

* [extra-scidb-libs-18.1-3-1.x86_64.rpm](extra-scidb-libs-18.1-3-1.x86_64.rpm) (May 13, 2018)
* [extra-scidb-libs-18.1-2-1.x86_64.rpm](extra-scidb-libs-18.1-2-1.x86_64.rpm) (May 8, 2018)
* [extra-scidb-libs-18.1-1-1.x86_64.rpm](extra-scidb-libs-18.1-1-1.x86_64.rpm) (April 13, 2018)
* [extra-scidb-libs-18.1-0-1.x86_64.rpm](extra-scidb-libs-18.1-0-1.x86_64.rpm) (March 21, 2018)

# Ubuntu Trusty

* [extra-scidb-libs-18.1-3.deb](extra-scidb-libs-18.1-3.deb) (May 13, 2018)
* [extra-scidb-libs-18.1-2.deb](extra-scidb-libs-18.1-2.deb) (May 8, 2018)
* [extra-scidb-libs-18.1-1.deb](extra-scidb-libs-18.1-1.deb) (April 13, 2018)
* [extra-scidb-libs-18.1-0.deb](extra-scidb-libs-18.1-0.deb) (March 5, 2018)

# Change Log

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
