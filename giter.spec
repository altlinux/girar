Name: giter
Version: 0.0.1
Release: alt1

Summary: gear server
License: GPL
Group: Development/Other
Packager: Alexey Gladkov <legion@altlinux.ru>

Source: %name-%version.tar

Requires: git-core

%description
gear server

%define giter_group giter

%prep
%setup -q

%build
%make_build

%install
%make_install install DESTDIR=%buildroot

%__mkdir -p %buildroot/%_sbindir
mv %buildroot/%_usr/local/sbin/* %buildroot/%_sbindir

%pre
/usr/sbin/groupadd -r -f %giter_group &>/dev/null

%files
%defattr(-,root,%giter_group,755)
%_sbindir/*
%_usr/libexec/%name
%_sysconfdir/%name
%_datadir/%name
%_spooldir/%name
%_localstatedir/%name

%changelog
* Fri Nov 17 2006 Alexey Gladkov <legion@altlinux.ru> 0.0.1-alt1
- Initial revision.
