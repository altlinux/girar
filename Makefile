DESTDIR =
libexecdir = /usr/libexec
sbindir = /usr/local/sbin
datadir = /usr/share
sysconfdir = /etc
localstatedir = /var/lib

giter_bindir = ${libexecdir}/giter
giter_sbindir = ${sbindir}
giter_confdir = ${sysconfdir}/giter
giter_datadir = ${datadir}/giter
giter_statedir = ${localstatedir}/giter
giter_hooks_dir = ${giter_datadir}/hooks
giter_templates_dir = ${giter_datadir}/templates
giter_email_dir = ${giter_statedir}/email

USER_PREFIX = git_
GITER_HOME = /people
GITER_EMAIL_ALIASES = /etc/postfix/git.aliases
GITER_FAKE_HOME = ${giter_datadir}/home
EMAIL_DOMAIN = altlinux.org

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

TARGETS = bin/giter-sh bin/people-clone bin/people-init-db bin/find-subscribers \
	sbin/giter-add sbin/giter-auth-add sbin/giter-auth-zero \
	sbin/giter-disable sbin/giter-enable hooks/update

.PHONY: all clean install install-data install-bin install-sbin

all: ${TARGETS}

clean:
	${RM} ${TARGETS}

install: install-data install-bin install-sbin install-var

install-data: hooks
	install -d -m750 \
		${DESTDIR}${giter_datadir} \
		${DESTDIR}${giter_templates_dir} \
		${DESTDIR}${GITER_FAKE_HOME}
	-chgrp giter \
		${DESTDIR}${giter_datadir} \
		${DESTDIR}${giter_templates_dir} \
		${DESTDIR}${GITER_FAKE_HOME}
	install -p hooks/* ${DESTDIR}${giter_hooks_dir}/
	ln -snf ${giter_hooks_dir} ${DESTDIR}${giter_templates_dir}/hooks

install-bin: bin/giter-sh bin/people-clone bin/people-find bin/people-init-db bin/people-ls bin/people-mv-db bin/people-quota bin/people-rm-db bin/find-subscribers
	install -d -m750 ${DESTDIR}${giter_bindir}
	-chgrp giter ${DESTDIR}${giter_bindir}
	install -pm755 $^ ${DESTDIR}${giter_bindir}/

install-sbin: sbin/giter-add sbin/giter-auth-add sbin/giter-auth-zero sbin/giter-disable sbin/giter-enable
	install -d -m755 ${DESTDIR}${giter_sbindir}
	install -pm700 $^ ${DESTDIR}${giter_sbindir}/

install-var:
	install -d -m750 \
		${DESTDIR}${giter_statedir} \
		${DESTDIR}${giter_email_dir}
	-chgrp giter \
		${DESTDIR}${giter_statedir} \
		${DESTDIR}${giter_email_dir}

bin/giter-sh: bin/giter-sh.c

%: %.in
	sed -e 's,@CMDDIR@,${giter_bindir},g' \
	    -e 's,@GITER_HOOKS_DIR@,${giter_hooks_dir},g' \
	    -e 's,@GITER_TEMPLATES_DIR@,${giter_templates_dir},g' \
	    -e 's,@GITER_EMAIL_DIR@,${giter_email_dir},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
	    -e 's,@GITER_HOME@,${GITER_HOME},g' \
	    -e 's,@GITER_FAKE_HOME@,${GITER_FAKE_HOME},g' \
	    -e 's,@EMAIL_DOMAIN@,${EMAIL_DOMAIN},g' \
	    -e 's,@GITER_EMAIL_ALIASES@,${GITER_EMAIL_ALIASES},g' \
		<$< >$@
	chmod --reference=$< $@
