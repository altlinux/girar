DESTDIR =
datadir = /usr/share
libexecdir = /usr/libexec
localstatedir = /var/lib
sbindir = /usr/sbin
spooldir = /var/spool
sysconfdir = /etc

giter_bindir = ${libexecdir}/giter
giter_sbindir = ${sbindir}
giter_confdir = ${sysconfdir}/giter
giter_datadir = ${datadir}/giter
giter_spooldir = ${spooldir}/giter
giter_statedir = ${localstatedir}/giter
giter_hooks_dir = ${giter_datadir}/hooks
giter_templates_dir = ${giter_datadir}/templates
giter_packages_dir = ${giter_datadir}/packages.git
giter_email_dir = ${giter_statedir}/email

EMAIL_DOMAIN = altlinux.org
GITER_ACL = ${giter_confdir}/acl
GITER_EMAIL_ALIASES = ${giter_confdir}/aliases
GITER_FAKE_HOME = ${giter_datadir}/home
GITER_HOME = /people
GITER_PRIVATE_QUEUE = ${giter_spooldir}/private
GITER_PUBLIC_QUEUE = ${giter_spooldir}/public
GITER_RELEASES = ${giter_confdir}/releases
USER_PREFIX = git_

UPRAVDOM_ACCOUNT = build-factory
UPRAVDOM_QUEUE = ${spooldir}/build-factory

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS} \
	-DGITER_BINDIR=\"${giter_bindir}/\" \
	-DUSER_PREFIX=\"${USER_PREFIX}\" \
	-DGITER_HOME=\"${GITER_HOME}\"
CFLAGS = -pipe -Wall -O2

bin_build_TARGETS = \
	bin/acl-cronjob \
	bin/find-subscribers \
	bin/giter-queue-release \
	bin/giter-sh \
	bin/people-clone \
	bin/people-init-db \
	bin/people-queue-build

bin_TARGETS = $(bin_build_TARGETS) \
	bin/giter-sh-functions \
	bin/people-find \
	bin/people-ls \
	bin/people-mv-db \
	bin/people-quota \
	bin/people-rm-db

sbin_TARGETS = \
	sbin/giter-add \
	sbin/giter-del \
	sbin/giter-auth-add \
	sbin/giter-auth-zero \
	sbin/giter-disable \
	sbin/giter-enable \
	sbin/giter-forwarder

TARGETS = ${bin_TARGETS} ${sbin_TARGETS} hooks/update

.PHONY: all clean install install-bin install-conf install-data install-sbin install-var

all: ${TARGETS}

clean:
	${RM} ${bin_build_TARGETS} ${sbin_TARGETS} hooks/update

install: install-bin install-conf install-data install-sbin install-var install-perms

install-bin: ${bin_TARGETS}
	install -d -m750 ${DESTDIR}${giter_bindir}
	install -pm755 $^ ${DESTDIR}${giter_bindir}/

install-sbin: ${sbin_TARGETS}
	install -d -m755 ${DESTDIR}${giter_sbindir}
	install -pm700 $^ ${DESTDIR}${giter_sbindir}/

install-conf:
	install -d -m750 \
		${DESTDIR}${giter_confdir} \
		${DESTDIR}${GITER_ACL}
	ln -sn ${giter_packages_dir} ${DESTDIR}${giter_confdir}/packages.git ||:

install-data: hooks
	install -d -m750 \
		${DESTDIR}${giter_datadir} \
		${DESTDIR}${giter_hooks_dir} \
		${DESTDIR}${giter_templates_dir} \
		${DESTDIR}${GITER_FAKE_HOME}
	install -p hooks/* ${DESTDIR}${giter_hooks_dir}/
	${RM} -- ${DESTDIR}${giter_hooks_dir}/*.in
	ln -snf ${giter_hooks_dir} ${DESTDIR}${giter_templates_dir}/hooks

install-var:
	install -d -m750 \
		${DESTDIR}${giter_statedir} \
		${DESTDIR}${giter_email_dir} \
		${DESTDIR}${giter_spooldir} \
		${DESTDIR}${GITER_PUBLIC_QUEUE} \
		${DESTDIR}${GITER_PRIVATE_QUEUE}

install-perms:
	-chgrp giter \
		${DESTDIR}${giter_bindir} \
		${DESTDIR}${giter_confdir} \
		${DESTDIR}${giter_datadir} \
		${DESTDIR}${giter_statedir} \
		${DESTDIR}${giter_spooldir}

bin/giter-sh: bin/giter-sh.c

%: %.in
	sed -e 's,@CMDDIR@,${giter_bindir},g' \
	    -e 's,@EMAIL_DOMAIN@,${EMAIL_DOMAIN},g' \
	    -e 's,@GITER_ACL@,${GITER_ACL},g' \
	    -e 's,@GITER_EMAIL_ALIASES@,${GITER_EMAIL_ALIASES},g' \
	    -e 's,@GITER_EMAIL_DIR@,${giter_email_dir},g' \
	    -e 's,@GITER_FAKE_HOME@,${GITER_FAKE_HOME},g' \
	    -e 's,@GITER_HOME@,${GITER_HOME},g' \
	    -e 's,@GITER_HOOKS_DIR@,${giter_hooks_dir},g' \
	    -e 's,@GITER_PACKAGES_DIR@,${giter_confdir}/packages.git,g' \
	    -e 's,@GITER_PRIVATE_QUEUE@,${GITER_PRIVATE_QUEUE},g' \
	    -e 's,@GITER_PUBLIC_QUEUE@,${GITER_PUBLIC_QUEUE},g' \
	    -e 's,@GITER_RELEASES@,${GITER_RELEASES},g' \
	    -e 's,@GITER_TEMPLATES_DIR@,${giter_templates_dir},g' \
	    -e 's,@UPRAVDOM_ACCOUNT@,${UPRAVDOM_ACCOUNT},g' \
	    -e 's,@UPRAVDOM_QUEUE@,${UPRAVDOM_QUEUE},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
		<$< >$@
	chmod --reference=$< $@
