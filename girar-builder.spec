Name: girar-builder
Version: 0.2
Release: alt1

Summary: builder part of girar server engine
License: GPL
Group: System/Servers
Packager: Dmitry V. Levin <ldv@altlinux.org>

BuildRequires: perl(RPM.pm) perl(Date/Format.pm)
Requires: girar memcached rpmhdrmemcache

Source: %name-%version.tar

%description
This package contains %summary.

%prep
%setup

%install
mkdir -p %buildroot/usr/libexec/%name
cp -a gb-* remote template %buildroot/usr/libexec/%name/
%add_findreq_skiplist /usr/libexec/%name/remote/*

%check
cd tests
./run

%files
/usr/libexec/%name/*
%doc LICENSE TASK conf/

%changelog
* Thu Nov 15 2012 Dmitry V. Levin <ldv@altlinux.org> 0.2-alt1
- Packaged example config files.

* Wed Nov 14 2012 Gleb F-Malinovskiy <glebfm@altlinux.org> 0.1-alt1
- initial spec

