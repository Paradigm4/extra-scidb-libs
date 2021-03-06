Name:           extra-scidb-libs-20.10
Version:        1
Release:        1
License:	GPLv3
Summary:        Several prototype operators and functions for SciDB
URL:            https://github.com/Paradigm4/%{name}
Source0:        %{name}/%{name}.tar.gz

%define _scidb_install_path $SCIDB_INSTALL_PATH
%define _scidb_version $SCIDB_VER

%global _clientlibs libscidbclient[.]so.*
%global __provides_exclude ^(%{_clientlibs})$
%global __requires_exclude ^(%{_clientlibs})$

# Note: 'global' evaluates NOW, 'define' allows recursion later...
%global _use_internal_dependency_generator 0
%global __find_requires_orig %{__find_requires}
%define __find_requires %{_builddir}/find-requires %{__find_requires_orig}

Requires: /opt/scidb/20.10/bin/scidb, openssl-devel, arrow-libs >= 0.16.0-1, arrow-libs < 0.17.0-1
Requires(post): info
Requires(preun): info

%description
Extra SciDB libraries submitted to our Paradigm4 github repository.

%prep

%autosetup

%build
make SCIDB=%{_scidb_install_path} %{?_smp_mflags}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp accelerated_io_tools/libaccelerated_io_tools.so %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp equi_join/libequi_join.so                       %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp grouped_aggregate/libgrouped_aggregate.so       %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp stream/libstream.so                             %{buildroot}%{_scidb_install_path}/lib/scidb/plugins
cp superfunpack/src/libsuperfunpack.so             %{buildroot}%{_scidb_install_path}/lib/scidb/plugins

mkdir -p %{buildroot}%{_scidb_install_path}/shim
sed "s!XXX_SCIDB_VER_XXX!%{_scidb_version}!g" shim/init.d/after-install.sh > %{buildroot}%{_scidb_install_path}/shim/after-install.sh
chmod a+rx %{buildroot}%{_scidb_install_path}/shim/after-install.sh
cp shim/init.d/before-remove.sh %{buildroot}%{_scidb_install_path}/shim/before-remove.sh
chmod a+rx %{buildroot}%{_scidb_install_path}/shim/before-remove.sh
cp shim/init.d/setup-conf.sh %{buildroot}%{_scidb_install_path}/shim/setup-conf.sh
chmod a+rx %{buildroot}%{_scidb_install_path}/shim/setup-conf.sh
sed "s!XXX_SCIDB_VER_XXX!%{_scidb_version}!g" shim/init.d/shimsvc.service > %{buildroot}%{_scidb_install_path}/shim/shimsvc.service
sed "s!XXX_SCIDB_VER_XXX!%{_scidb_version}!g" shim/init.d/shimsvc.initd > %{buildroot}%{_scidb_install_path}/shim/shimsvc.initd
chmod a+rx %{buildroot}%{_scidb_install_path}/shim/shimsvc.initd

mkdir -p %{buildroot}%{_scidb_install_path}/bin
cp shim/shim "%{buildroot}/%{_scidb_install_path}/bin"
mkdir -p %{buildroot}/var/lib/shim
cp -aR shim/wwwroot %{buildroot}/var/lib/shim
chmod -R 755 %{buildroot}/var/lib/shim
mkdir -p %{buildroot}/usr/local/share/man/man1
cp shim/man/shim.1 %{buildroot}/usr/local/share/man/man1
mkdir -p %{buildroot}/var/lib/shim

echo %{_scidb_install_path}/lib/scidb/plugins/libaccelerated_io_tools.so >  files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libequi_join.so            >> files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libgrouped_aggregate.so    >> files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libstream.so               >> files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libsuperfunpack.so         >> files.lst
echo %{_scidb_install_path}/shim/after-install.sh                        >> files.lst
echo %{_scidb_install_path}/shim/before-remove.sh                        >> files.lst
echo %{_scidb_install_path}/shim/setup-conf.sh                           >> files.lst
echo %{_scidb_install_path}/shim/shimsvc.initd                           >> files.lst
echo %{_scidb_install_path}/shim/shimsvc.service                         >> files.lst

echo %{_scidb_install_path}/bin/shim >> files.lst
echo /var/lib/shim/wwwroot >> files.lst
echo /usr/local/share/man/man1/shim.1 >> files.lst

%post
# Stop any existing service
# SystemD
if test -n "$(which systemctl 2>/dev/null)"; then
  systemctl -q stop shimsvc 2>/dev/null || true
# InitD Ubuntu
elif test -n "$(which update-rc.d 2>/dev/null)"; then
  service shimsvc stop 2>/dev/null||true
# InitD Fedora
elif test -n "$(which chkconfig 2>/dev/null)"; then
  service shimsvc stop 2>/dev/null||true
fi

if [ -z "$SCIDB_INSTALL_PATH" ]
then
    export SCIDB_INSTALL_PATH=/opt/scidb/20.10
fi

$SCIDB_INSTALL_PATH/shim/after-install.sh


%preun
$SCIDB_INSTALL_PATH/shim/before-remove.sh


%files -f files.lst

%doc

%changelog
* Tue Jan 5 2021 Jason Kinchen <jkinchen@paradigm4.com>
- Port plugins to SciDB 20.10

* Thu Jul 23 2020 Rares Vernica <rvernica@gmail.com>
- accelerated_io_tools with fix for dangling reference
- equi_join with minor fixes
- grouped_aggregate with minor fixes
- shim with fixes for configuration file, installation failures,
  auto-commit queries, make service, and CXX flags

* Thu Jun 27 2020 Rares Vernica <rvernica@gmail.com>
- accelerated_io_tools with support for Apache Arrow 0.16.0
- stream with support for Apache Arrow 0.16.0

* Thu Jun 18 2020 Rares Vernica <rvernica@gmail.com>
- accelerated_io_tools fix read bug, Arrow optional

* Thu Apr 30 2020 Rares Vernica <rvernica@gmail.com>
- shim with fix for side effects

* Thu Apr 30 2020 Rares Vernica <rvernica@gmail.com>
- accelerated_io_tools with fix for aio_input cancel

* Thu Apr 30 2020 Rares Vernica <rvernica@gmail.com>
- Port plugins to SciDB 19.11

* Wed Apr 29 2020 Rares Vernica <rvernica@gmail.com>
- accelerated_io_tools with fix for settings addressing
- superfunpack with MurmurHash support and null fix

* Mon Feb 17 2020 Rares Vernica <rvernica@gmail.com>
- equi_join with fix for parameter parsing
- stream with fix for fork issue

* Tue Nov 5 2019  Rares Vernica <rvernica@gmail.com>
- shim with service support

* Thu Sep 26 2019 Rares Vernica <rvernica@gmail.com>
- Shim systemd support
- accelerated_io_tools fix cleanup after query cancellation

* Tue Jul 9 2019 Rares Vernica <rvernica@gmail.com>
- Port plugins to SciDB 19.3

* Wed May 22 2019 Rares Vernica <rvernica@gmail.com>
- Shim with fix for save argument length

* Thu Dec 27 2018 Rares Vernica <rvernica@gmail.com>
- accelerated_io_tools with result_size_limit support
- Shim with result_size_limit support

* Fri Sep 21 2018 Rares Vernica <rvernica@gmail.com>
- superfunpack linked against libpcre

* Sun Aug 5 2018 Rares Vernica <rvernica@gmail.com>
- accelerated_io_tools with atts_only support
- Shim with admin and atts_only support

* Fri Jun 1 2018 Rares Vernica <rvernica@gmail.com>
- Add dependency to Apache Arrow and OpenSSL
- Generate self-signed certificate for Shim

* Sun May 13 2018 Rares Vernica <rvernica@gmail.com>
- Fix empty SciDB version in shim (Closes: #15)

* Tue May 8 2018 Rares Vernica <rvernica@gmail.com>
- Add stream plugin with Apache Arrow
- Update accelerated_io_tools to include Apache Arrow
- Fix requirements
- Fix shim configuration and start

* Fri Apr 13 2018 Jason Kinchen <jkinchen@paradigm4.com>
- Support for 18.1.7

* Tue Sep 26 2017 Jason Kinchen <jkinchen@paradigm4.com>
- Initial version of the package
