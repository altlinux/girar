Name: gb-depot
Version: 0.2
Release: alt2

Summary: girar-builder depot
License: GPL
Group: Other

Source: %name-%version.tar

# due to "enable -f /usr/lib/bash/lockf lockf"
Requires: bash-builtin-lockf >= 0:0.2

%description
This package contains %summary.

%prep
%setup

%build
%make_build

%install
%define depodir /usr/libexec/gb-depot
mkdir -p %buildroot%depodir
install -pm755 gb-proxyd-{depot,repo} socket-forward-* copyself savetree \
	%buildroot%depodir/
install -pDm755 gb-proxyd-depot.init %buildroot%_initdir/gb-proxyd-depot
install -pDm755 gb-proxyd-repo.init %buildroot%_initdir/gb-proxyd-repo
install -d %buildroot/etc/%name

%pre
/usr/sbin/groupadd -r -f bull
for u in depot repo; do
	/usr/sbin/groupadd -r -f $u
	/usr/sbin/useradd -r -g $u -d /etc/%name -s /dev/null -c "girar-builder $ server" -n $u ||:
done

%post
%post_service gb-proxyd-depot
%post_service gb-proxyd-repo

%preun
%preun_service gb-proxyd-depot
%preun_service gb-proxyd-repo

%files
%depodir
%_initdir/gb-proxyd-*
%dir /etc/%name

%changelog
* Wed Nov 14 2012 Gleb F-Malinovskiy <glebfm@altlinux.org> 0.2-alt2
- Rewritten %%pre.
- Renamed brain to bull.

* Wed Jul 11 2012 Dmitry V. Levin <ldv@altlinux.org> 0.2-alt1
- Refactored.

* Mon Jul 02 2012 Dmitry V. Levin <ldv@altlinux.org> 0.1-alt1
- Initial revision.
