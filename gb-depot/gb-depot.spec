Name: gb-depot
Version: 0.2
Release: alt3

Summary: girar depot
License: GPL
Group: Other

Source: %name-%version.tar

Requires: girar

%description
This package contains %summary.

%prep
%setup

%build
%make_build

%install
%define depodir /usr/libexec/gb-depot
mkdir -p %buildroot%depodir
install -pm755 girar-proxyd-{depot,repo} girar-socket-forward-* \
	girar-repo-copyself girar-repo-savetree %buildroot%depodir/
install -pDm755 girar-proxyd-depot.init %buildroot%_initdir/girar-proxyd-depot
install -pDm755 girar-proxyd-repo.init %buildroot%_initdir/girar-proxyd-repo
install -d %buildroot/etc/%name

%pre
for u in depot repo; do
	/usr/sbin/groupadd -r -f $u
	/usr/sbin/useradd -r -g $u -d /etc/%name -s /dev/null -c "Girar $u robot" -n $u ||:
done

%post
%post_service girar-proxyd-depot
%post_service girar-proxyd-repo

%preun
%preun_service girar-proxyd-depot
%preun_service girar-proxyd-repo

%files
%depodir
%_initdir/girar-proxyd-*
%dir /etc/%name

%changelog
* Thu Nov 15 2012 Dmitry V. Levin <ldv@altlinux.org> 0.2-alt3
- Renamed bull to girar-committer.

* Wed Nov 14 2012 Gleb F-Malinovskiy <glebfm@altlinux.org> 0.2-alt2
- Rewritten %%pre.
- Renamed brain to bull.

* Wed Jul 11 2012 Dmitry V. Levin <ldv@altlinux.org> 0.2-alt1
- Refactored.

* Mon Jul 02 2012 Dmitry V. Levin <ldv@altlinux.org> 0.1-alt1
- Initial revision.
