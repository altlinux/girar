Name: girar
Version: 0.1
Release: alt1

Summary: git.alt server engine
License: GPL
Group: System/Servers
Packager: Dmitry V. Levin <ldv@altlinux.org>

Source: %name-%version.tar

Requires(pre): shadow-utils
# due to "enable -f /usr/lib/bash/lockf lockf"
Requires: bash-builtin-lockf >= 0:0.2

%define girar_group girar
%define girar_user girar

%description
This package contains server engine initially developed for git.alt,
including administration and user utilities, git hooks, email subscription
support and config files.

%prep
%setup -q

%build
%make_build

%install
%make_install install DESTDIR=%buildroot

%pre
/usr/sbin/groupadd -r -f %girar_group
/usr/sbin/useradd -r -g %girar_group -d /dev/null -s /dev/null -c 'The girar spool processor' -n %girar_user >/dev/null 2>&1 ||:

%files
%defattr(-,root,%girar_group,755)
%_sbindir/*
%_usr/libexec/%name
%_sysconfdir/%name
%_datadir/%name
%dir %_spooldir/%name
%dir %_spooldir/%name/people
%dir %attr(755,%girar_user,%girar_group) %_spooldir/%name/private
%dir %attr(1775,%girar_user,%girar_group) %_spooldir/%name/public
%_localstatedir/%name

%changelog
* Tue Nov 21 2006 Dmitry V. Levin <ldv@altlinux.org> 0.1-alt1
- Specfile cleanup.

* Fri Nov 17 2006 Alexey Gladkov <legion@altlinux.ru> 0.0.1-alt1
- Initial revision.
