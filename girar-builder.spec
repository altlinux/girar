Name: girar-builder
Version: 0.1
Release: alt1

Summary: builder part of git.alt server engine
License: GPL
Group: System/Servers
Packager: Dmitry V. Levin <ldv@altlinux.org>

BuildRequires: perl(RPM.pm) perl(Date/Format.pm)
Requires: girar memcached rpmhdrmemcache

Source: %name-%version.tar

%description
builder part of git.alt server engine
#This package contains server engine initially developed for git.alt,
#including administration and user utilities, git hooks, email
#subscription support and config files.

%prep
%setup

%install
mkdir -p %buildroot/usr/libexec/%name
cp gb-* %buildroot/usr/libexec/%name/
cp -r remote template tests %buildroot/usr/libexec/%name/
install -d %buildroot/var/lib/%name/{home,lock}/{bull,cow}

%add_findreq_skiplist /usr/libexec/%name/remote/*

%pre
/usr/sbin/groupadd -r -f bull
/usr/sbin/groupadd -r -f cow
/usr/sbin/useradd -r -g bull -d /var/lib/%name/home/bull -c 'girar-builder bull' -n bull >/dev/null 2>&1 ||:
/usr/sbin/useradd -r -g cow -d /var/lib/%name/home/cow -c 'girar-builder cow' -n cow >/dev/null 2>&1 ||:

%files
%doc LICENSE TASK
/usr/libexec/%name/*
%dir /var/lib/%name
%dir /var/lib/%name/*
%attr(2770,root,bull) /var/lib/%name/*/bull
%attr(2770,root,cow) /var/lib/%name/*/cow

%changelog
* Wed Nov 14 2012 Gleb F-Malinovskiy <glebfm@altlinux.org> 0.1-alt1
- initial spec

