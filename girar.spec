# --no-sisyphus-check-out=fhs

Name: girar
Version: 0.5
Release: alt1

Summary: git.alt server engine
License: GPLv2+
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
# due to cron jobs
Requires: stmpclean
# due to "locale -m"
Requires: glibc-i18ndata
# due to gb-task-repo-unmets
Requires: qa-robot >= 0.3.5-alt1
# due to gb-y-repo-regen-basedir
Requires: deepsolver-repo >= 0.3.3-alt1

Obsoletes: girar-builder

BuildRequires: perl(RPM.pm) perl(Date/Format.pm)

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
echo 0 >%buildroot/var/lib/girar/tasks/.max-task-id
mksock %buildroot/var/run/girar/{acl,depot,repo}/socket
mkdir -p %buildroot/var/spool/cron
touch %buildroot/var/spool/cron/{pender,awaiter}

mkdir -p %buildroot/usr/libexec/girar-builder
cp -a gb/gb-* gb/remote gb/template %buildroot/usr/libexec/girar-builder/
%add_findreq_skiplist /usr/libexec/girar-builder/remote/*
touch %buildroot/var/lib/girar/cache/people-packages-list
cat > %buildroot/etc/girar/aliases <<'EOF'
git-update-subscribers: /dev/null
acl:		root
awaiter:	root
depot:		root
pender:		root
repo:		root
EOF

%check
cd gb/tests
./run

%pre
%_sbindir/groupadd -r -f girar
%_sbindir/groupadd -r -f girar-users
%_sbindir/groupadd -r -f girar-admin
%_sbindir/groupadd -r -f tasks
%_sbindir/groupadd -r -f maintainers
for u in acl depot repo cacher; do
	%_sbindir/groupadd -r -f $u
	%_sbindir/useradd -r -g $u -G girar -d /var/empty -s /dev/null -c 'Girar $u robot' -n $u ||:
done
for u in pender awaiter; do
	%_sbindir/groupadd -r -f $u
	%_sbindir/useradd -r -g $u -G girar,tasks -d /var/lib/girar/$u -c "Girar $u robot" -n $u ||:
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
	crontab -u pender - <<-'EOF'
	#1	*	*	*	*	/usr/libexec/girar-builder/gb-toplevel-commit sisyphus
	40	1	*	*	*	/usr/libexec/girar/girar-scrap-archived-tasks
	EOF
	crontab -u awaiter - <<-'EOF'
	#1	*	*	*	*	/usr/libexec/girar-builder/gb-toplevel-build sisyphus
	40	7	*	*	*	/usr/sbin/stmpclean -t 14d $HOME/.cache
	EOF
	crontab -u cacher - <<-'EOF'
	#20	*	*	*	*	/usr/libexec/girar/girar-gen-people-packages-list
	EOF
fi

%preun
%preun_service girar-proxyd-acl
%preun_service girar-proxyd-depot
%preun_service girar-proxyd-repo

%files
%config(noreplace) %attr(400,root,root) /etc/sudoers.d/girar
%config(noreplace) /etc/sisyphus_check/check.d/*
%config(noreplace) /etc/girar/aliases
/etc/girar/
/usr/libexec/girar/
/usr/libexec/girar-builder/
%_datadir/girar/
%_initdir/girar-proxyd-*
%attr(700,root,root) %_sbindir/*

%doc LICENSE TASK gb/conf/

# all the rest should be listed explicitly
%defattr(0,0,0,0)

%dir %attr(755,root,root) /var/lib/girar/
%dir %attr(2775,root,acl) /var/lib/girar/acl/
%dir %attr(770,root,pender) /var/lib/girar/pender/
%dir %attr(770,root,awaiter) /var/lib/girar/awaiter/
%dir %attr(770,root,awaiter) /var/lib/girar/awaiter/.cache/
%dir %attr(770,root,awaiter) /var/lib/girar/awaiter/.qa-cache/
%dir %attr(770,root,awaiter) /var/lib/girar/awaiter/.qa-cache/rpmelfsym/
%dir %attr(755,root,root) /var/lib/girar/depot/
%dir %attr(770,root,depot) /var/lib/girar/depot/.tmp/
%dir %attr(775,root,depot) /var/lib/girar/depot/??/
%dir %attr(755,root,root) /var/lib/girar/repo/
%dir %attr(755,root,root) /people/
%dir %attr(775,root,pender) /gears/
%dir %attr(775,root,pender) /srpms/

%dir %attr(3775,pender,tasks) /var/lib/girar/tasks/
%dir %attr(3775,root,pender) /var/lib/girar/tasks/archive/
%dir %attr(700,pender,pender) /var/lib/girar/tasks/archive/.trash/
%dir %attr(775,root,pender) /var/lib/girar/tasks/archive/*
%dir %attr(755,root,root) /var/lib/girar/tasks/index/
%config(noreplace) %attr(664,pender,tasks) /var/lib/girar/tasks/.max-task-id

%dir %attr(1771,root,cacher) /var/lib/girar/cache
%config(noreplace) %attr(644,cacher,cacher) /var/lib/girar/cache/people-packages-list

%dir %attr(750,root,girar) /var/lib/girar/email/
%dir %attr(755,root,root) /var/lib/girar/email/*

%dir %attr(750,root,girar) /var/lock/girar/
%dir %attr(770,root,pender) /var/lock/girar/pender/
%dir %attr(770,root,awaiter) /var/lock/girar/awaiter/

%dir %attr(750,root,girar) /var/run/girar/
%dir %attr(710,root,girar) /var/run/girar/acl/
%dir %attr(710,root,pender) /var/run/girar/depot/
%dir %attr(710,root,pender) /var/run/girar/repo/
%ghost %attr(666,root,root) /var/run/girar/*/socket

%config(noreplace) %ghost %attr(600,pender,crontab) /var/spool/cron/pender
%config(noreplace) %ghost %attr(600,awaiter,crontab) /var/spool/cron/awaiter

%changelog
* Wed Nov 21 2012 Dmitry V. Levin <ldv@altlinux.org> 0.5-alt1
- Imported girar-builder.

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
