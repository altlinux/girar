Name: girar
Version: 0.4
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
# due to girar-task-add
Requires: gear
# due to gb-sh-rpmhdrcache
Requires: memcached rpmhdrmemcache

%description
This package contains server engine initially developed for git.alt,
including administration and user utilities, git hooks, email
subscription support and config files.

%prep
%setup

%build
%make_build

%install
%makeinstall_std
echo 0 >%buildroot%_localstatedir/%name/tasks/.max-task-id
mksock %buildroot/var/run/%name/{acl,depot,repo}/socket

%pre
%_sbindir/groupadd -r -f girar
%_sbindir/groupadd -r -f girar-users
%_sbindir/groupadd -r -f girar-admin
%_sbindir/groupadd -r -f tasks
for u in acl depot repo; do
	%_sbindir/groupadd -r -f $u
	%_sbindir/useradd -r -g $u -G girar -d /var/empty -s /dev/null -c 'Girar $u robot' -n $u ||:
done
for u in bull cow; do
	%_sbindir/groupadd -r -f $u
	%_sbindir/useradd -r -g $u -G girar,tasks -d /var/lib/%name/$u -c "Girar $u robot" -n $u ||:
done

%post
%post_service girar-proxyd-acl
%post_service girar-proxyd-depot
%post_service girar-proxyd-repo
%_sbindir/girar-make-template-repos
if [ $1 -eq 1 ]; then
	if grep -Fxqs 'EXTRAOPTIONS=' /etc/sysconfig/memcached; then
		sed -i 's/^EXTRAOPTIONS=$/&"-m 2048"/' /etc/sysconfig/memcached
	fi
	if grep -Fxqs 'AllowGroups wheel users' /etc/openssh/sshd_config; then
		sed -i 's/^AllowGroups wheel users/& girar-users/' /etc/openssh/sshd_config
	fi
fi

%preun
%preun_service girar-proxyd-acl
%preun_service girar-proxyd-depot
%preun_service girar-proxyd-repo

%files
%config(noreplace) %attr(400,root,root) /etc/sudoers.d/girar
%_sysconfdir/%name/
%_usr/libexec/%name/
%_datadir/%name/
%_initdir/girar-proxyd-*
%attr(700,root,root) %_sbindir/*

%defattr(-,root,girar,750)

%dir %attr(755,root,girar) %_localstatedir/%name/
%dir %attr(2775,root,acl) %_localstatedir/%name/acl/
%dir %attr(755,root,root) %_localstatedir/%name/depot/
%dir %attr(770,root,depot) %_localstatedir/%name/depot/.tmp/
%dir %attr(775,root,depot) %_localstatedir/%name/depot/??/
%dir %attr(755,root,root) %_localstatedir/%name/repo/
%dir %attr(755,root,root) %_localstatedir/%name/people/
%dir %attr(775,root,bull) %_localstatedir/%name/gears/
%dir %attr(775,root,bull) %_localstatedir/%name/srpms/
%dir %attr(3775,bull,tasks) %_localstatedir/%name/tasks/
%dir %attr(3775,root,bull) %_localstatedir/%name/tasks/archive/
%dir %attr(775,root,bull) %_localstatedir/%name/tasks/archive/*
%dir %attr(755,root,root) %_localstatedir/%name/tasks/index/
%attr(664,cow,tasks) %config(noreplace) %_localstatedir/%name/tasks/.max-task-id
%_localstatedir/%name/email/

%dir /var/run/%name/
%dir %attr(710,root,girar) /var/run/%name/acl/
%dir %attr(710,root,bull) /var/run/%name/depot/
%dir %attr(710,root,bull) /var/run/%name/repo/
%ghost %attr(666,root,root) /var/run/%name/*/socket

%dir /var/l*/girar/
%attr(770,root,bull) /var/l*/girar/bull/
%attr(770,root,cow) /var/l*/girar/cow/

%changelog
* Fri Nov 16 2012 Dmitry V. Levin <ldv@altlinux.org> 0.4-alt1
- Imported gb-depot.

* Thu Dec 11 2008 Dmitry V. Levin <ldv@altlinux.org> 0.3-alt1
- Added task subcommands.

* Mon Jun 16 2008 Dmitry V. Levin <ldv@altlinux.org> 0.2-alt1
- Rewrote hooks using post-receive.

* Tue Nov 21 2006 Dmitry V. Levin <ldv@altlinux.org> 0.1-alt1
- Specfile cleanup.

* Fri Nov 17 2006 Alexey Gladkov <legion@altlinux.ru> 0.0.1-alt1
- Initial revision.
