Name: girar
Version: 0.2
Release: alt1

Summary: git.alt server engine
License: GPL
Group: System/Servers
Packager: Dmitry V. Levin <ldv@altlinux.org>

Source: %name-%version.tar

Requires(pre): shadow-utils
# due to "enable -f /usr/lib/bash/lockf lockf"
Requires: bash-builtin-lockf >= 0:0.2
# due to post-receive hook
Requires: git-core >= 0:1.5.1

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
%defattr(-,root,%girar_group,750)
%_sbindir/*
%_usr/libexec/%name
%dir %_sysconfdir/%name
%dir %attr(750,%girar_user,%girar_group) %_sysconfdir/%name/acl
%_datadir/%name
%dir %_spooldir/%name
%dir %_spooldir/%name/people
%dir %attr(770,root,%girar_group) %_spooldir/%name/people/.timestamp
%dir %attr(1770,%girar_user,%girar_group) %_spooldir/%name/tasks
%_localstatedir/%name

%changelog
* Mon Jun 16 2008 Dmitry V. Levin <ldv@altlinux.org> 0.2-alt1
- Rewrote hooks using post-receive.

* Tue Nov 21 2006 Dmitry V. Levin <ldv@altlinux.org> 0.1-alt1
- Specfile cleanup.

* Fri Nov 17 2006 Alexey Gladkov <legion@altlinux.ru> 0.0.1-alt1
- Initial revision.
