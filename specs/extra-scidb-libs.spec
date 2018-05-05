Name:           extra-scidb-libs-18.1
Version:        2
Release:        1
License:	GPLv3
Summary:        Several prototype operators and functions for SciDB
URL:            https://github.com/Paradigm4/%{name}
Source0:        %{name}/%{name}.tar.gz

%define _scidb_install_path $SCIDB_INSTALL_PATH

%global _clientlibs libscidbclient[.]so.*
%global __provides_exclude ^(%{_clientlibs})$
%global __requires_exclude ^(%{_clientlibs})$

# Note: 'global' evaluates NOW, 'define' allows recursion later...
%global _use_internal_dependency_generator 0
%global __find_requires_orig %{__find_requires}
%define __find_requires %{_builddir}/find-requires %{__find_requires_orig}

Requires: /opt/scidb/18.1/bin/scidb
Requires(post): info
Requires(preun): info

%description
The Paradigm4 github repository has several prototype operators and functions for SciDB: equi_join, grouped aggregate, accelerated I/O tools, superfunpack, stream and shim.  The package contains the latest version for the current SciDB version.

%prep

%autosetup

%build
make SCIDB=%{_scidb_install_path} %{?_smp_mflags}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp superfunpack/src/libsuperfunpack.so %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp grouped_aggregate/libgrouped_aggregate.so %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp accelerated_io_tools/libaccelerated_io_tools.so %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp equi_join/libequi_join.so %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
#cp stream/libstream.so %{buildroot}%{_scidb_install_path}/lib/scidb/plugins

mkdir -p %{buildroot}%{_scidb_install_path}/bin
cp shim/shim "%{buildroot}/%{_scidb_install_path}/bin"
mkdir -p %{buildroot}/var/lib/shim
cp -aR shim/wwwroot %{buildroot}/var/lib/shim
chmod -R 755 %{buildroot}/var/lib/shim
mkdir -p %{buildroot}/usr/local/share/man/man1
cp shim/man/shim.1 %{buildroot}/usr/local/share/man/man1

mkdir -p %{buildroot}/etc/init.d
cp shim/init.d/shimsvc %{buildroot}/etc/init.d
chmod 0755 %{buildroot}/etc/init.d/shimsvc
mkdir -p %{buildroot}/var/lib/shim
cp shim/conf %{buildroot}/var/lib/shim/conf

echo %{_scidb_install_path}/lib/scidb/plugins/libsuperfunpack.so > files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libgrouped_aggregate.so >> files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libaccelerated_io_tools.so >> files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libequi_join.so >> files.lst
#echo %{_scidb_install_path}/lib/scidb/plugins/libstream.so >> files.lst
echo %{_scidb_install_path}/bin/shim >> files.lst
echo /var/lib/shim/wwwroot >> files.lst
echo /usr/local/share/man/man1/shim.1 >> files.lst
echo /etc/init.d/shimsvc >> files.lst
# echo /var/lib/shim/conf >> files.lst


%post
if test -z "$SCIDB_INSTALL_PATH"; then export SCIDB_INSTALL_PATH=/opt/scidb/18.1; fi
if test -x /etc/init.d/shimsvc; then /etc/init.d/shimsvc stop;fi
scidbuser=`ps axfo user:64,cmd | grep scidb | grep dbname | head -n 1 | cut -d ' ' -f 1`
sed -i "s/LOGNAME/$scidbuser/" /var/lib/shim/conf
basepath=$(cat $SCIDB_INSTALL_PATH/etc/config.ini | grep base-path | cut -d= -f2)
sed -i "s:\[INSTANCE_0_DATA_DIR\]:$basepath/0/0/tmp:" /var/lib/shim/conf
if test -f /etc/init.d/shimsvc; then /etc/init.d/shimsvc start;fi

%preun
if test -f /etc/init.d/shimsvc; then /etc/init.d/shimsvc stop; rm -f /etc/init.d/shimsvc;fi

%files -f files.lst

%config(noreplace) /var/lib/shim/conf

%doc

%changelog
* Fri Apr 13 2018 Jason Kinchen <jkinchen@paradigm4.com>
- Support for 18.1.7
* Tue Sep 26 2017 Jason Kinchen <jkinchen@paradigm4.com> 18.1-1
- Initial version of the package
