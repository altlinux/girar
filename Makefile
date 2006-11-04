DESTDIR =
libexecdir = /usr/libexec
sbindir = /usr/local/sbin
datadir = /usr/share
sysgiter_confdir = /etc

giter_bindir = ${libexecdir}/giter
giter_sbindir = ${sbindir}
giter_confdir = ${sysconfdir}/giter
giter_datadir = ${datadir}/giter

USER_PREFIX = git_
GITER_HOME = /people
GITER_FAKE_HOME = /home/giter
EMAIL_DOMAIN = altlinux.org

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS} \
	-DCMD_PREFIX=\"${giter_bindir}/\" \
	-DUSER_PREFIX=\"${USER_PREFIX}\" \
	-DGITER_HOME=\"${GITER_HOME}\"
CFLAGS = -pipe -Wall -O2

.PHONY: all clean install install-conf install-bin install-sbin

all: bin/giter-sh sbin/giter-add

clean:
	${RM} bin/giter-sh sbin/giter-add

install: install-conf install-bin install-sbin
	install -d -m755 ${GITER_FAKE_HOME}

install-conf: conf
	rsync -vrlpt --delete-after conf/ ${DESTDIR}${giter_confdir}/
	install -d -m755 ${DESTDIR}${giter_confdir}/people
	install -d -m750 ${DESTDIR}${giter_confdir}/people/etc
	-chgrp -hR wheel ${DESTDIR}${giter_confdir}/people

install-bin: bin/giter-sh bin/people-clone bin/people-find bin/people-init-db bin/people-ls bin/people-mv-db bin/people-quota bin/people-rm-db
	install -pm750 -oroot -ggiter $^ ${DESTDIR}${giter_bindir}/

install-sbin: sbin/giter-add sbin/giter-auth-add sbin/giter-auth-zero sbin/giter-disable sbin/giter-enable
	install -pm700 -oroot -groot $^ ${DESTDIR}${giter_sbindir}/

bin/giter-sh: bin/giter-sh.c

%: %.in
	sed -e 's,@CMDDIR@,${giter_bindir},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
	    -e 's,@GITER_HOME@,${GITER_HOME},g' \
	    -e 's,@GITER_FAKE_HOME@,${GITER_FAKE_HOME},g' \
	    -e 's,@EMAIL_DOMAIN@,${EMAIL_DOMAIN},g' \
		<$< >$@
	chmod --reference=$< $@
