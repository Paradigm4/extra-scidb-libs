Name:           extra-scidb-libs-18.1
Version:        7
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

Requires: /opt/scidb/18.1/bin/scidb, openssl, arrow-libs >= 0.9.0-1
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

echo %{_scidb_install_path}/lib/scidb/plugins/libaccelerated_io_tools.so >  files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libequi_join.so            >> files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libgrouped_aggregate.so    >> files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libstream.so               >> files.lst
echo %{_scidb_install_path}/lib/scidb/plugins/libsuperfunpack.so         >> files.lst
echo %{_scidb_install_path}/bin/shim >> files.lst
echo /var/lib/shim/wwwroot >> files.lst
echo /usr/local/share/man/man1/shim.1 >> files.lst
echo /etc/init.d/shimsvc >> files.lst
# echo /var/lib/shim/conf >> files.lst


%post
if [ -x /etc/init.d/shimsvc ]
then
    /etc/init.d/shimsvc stop
fi

if [ -z "$SCIDB_INSTALL_PATH" ]
then
    export SCIDB_INSTALL_PATH=/opt/scidb/18.1
fi


scidbuser=$(                                    \
    ps axfo user:64,cmd                         \
    |  grep scidb                               \
    |  grep dbname                              \
    |  head -n 1                                \
    |  cut -d ' ' -f 1)
basepath=$(                                     \
    cat $SCIDB_INSTALL_PATH/etc/config.ini      \
    | grep base-path                            \
    | cut -d = -f 2)

sed -i "s/LOGNAME/$scidbuser/"                        /var/lib/shim/conf
sed -i "s:\[INSTANCE_0_DATA_DIR\]:$basepath/0/0/tmp:" /var/lib/shim/conf


if [ ! -f /var/lib/shim/ssl_cert.pem ]
then
    openssl req                                                         \
        -new                                                            \
        -newkey rsa:4096                                                \
        -days 3650                                                      \
        -nodes                                                          \
        -x509                                                           \
        -subj "/C=US/ST=MA/L=Waltham/O=Paradigm4/CN=$(hostname)"        \
        -keyout /var/lib/shim/ssl_cert.pem                              \
    2> /dev/null                                                        \
    >> /var/lib/shim/ssl_cert.pem
fi


if [ ! -e /var/lib64/libssl.so ]
then
   ln --symbolic /usr/lib64/libssl.so.1.0.2k /usr/lib64/libssl.so
fi

if [ ! -e /usr/lib64/libcrypto.so ]
then
   ln --symbolic /usr/lib64/libcrypto.so.1.0.2k /usr/lib64/libcrypto.so
fi


if [ -x /etc/init.d/shimsvc ]
then
    /etc/init.d/shimsvc start
fi

%preun
if [ -x /etc/init.d/shimsvc ]
then
    /etc/init.d/shimsvc stop
fi

%files -f files.lst

%config(noreplace) /var/lib/shim/conf

%doc

%changelog

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
