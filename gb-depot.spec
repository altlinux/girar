Name: gb-depot
Version: 0.2
Release: alt1

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

%pre
id depot > /dev/null 2>&1 ||
	useradd -s %depodir/depot-sh -c 'girar-builder depot server' depot
id repo > /dev/null 2>&1 ||
	useradd -s %depodir/repo-sh -c 'girar-builder repo server' repo

%post
%post_service gb-proxyd-depot
%post_service gb-proxyd-repo

%preun
%preun_service gb-proxyd-depot
%preun_service gb-proxyd-repo

%files
%depodir
%_initdir/gb-proxyd-*

%changelog
* Wed Jul 11 2012 Dmitry V. Levin <ldv@altlinux.org> 0.2-alt1
- Refactored.

* Mon Jul 02 2012 Dmitry V. Levin <ldv@altlinux.org> 0.1-alt1
- Initial revision.
