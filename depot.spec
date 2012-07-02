Name: depot
Version: 0.1
Release: alt1

Summary: git.alt depot
License: GPL
Group: Other

Source: %name-%version.tar

%description
This package contains %summary.

%package server
Summary: git.alt depot - server components
Group: Other
# due to "enable -f /usr/lib/bash/lockf lockf"
Requires: bash-builtin-lockf >= 0:0.2

%description server
This package contains git.alt depot server components.

%package client
Summary: git.alt depot - client components
Group: Other

%description client
This package contains git.alt depot client components.

%prep
%setup

%build
%make_build

%install
%define depodir /usr/libexec/depot
mkdir -p %buildroot%depodir
install -pm755 server/{deposit,depot-sh} %buildroot%depodir/
mkdir -p %buildroot%_bindir
install -pm755 client/deposit-file %buildroot%_bindir/

%pre server
id depot > /dev/null 2>&1 ||
	useradd -s %depodir/depot-sh -c 'git.alt depot server' depot

%files server
%defattr(-,root,depot,750)
%depodir/

%files client
%_bindir/*

%changelog
* Mon Jul 02 2012 Dmitry V. Levin <ldv@altlinux.org> 0.1-alt1
- Initial revision.
