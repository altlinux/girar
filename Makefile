DESTDIR =
PREFIX = /usr/local
WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 $(WARNINGS)
CFLAGS = -pipe -Wall -O2

.PHONY: all clean install install-conf install-bin install-sbin

all: bin/giter-sh

clean:
	$(RM) bin/giter-sh

install: install-conf install-bin install-sbin

install-conf: conf
	rsync -vrlpt --delete-after conf/ ${DESTDIR}/etc/giter/
	install -d -m755 ${DESTDIR}/etc/giter/people
	install -d -m750 ${DESTDIR}/etc/giter/people/etc
	-chgrp -hR wheel ${DESTDIR}/etc/giter/people

install-bin: bin/giter-sh bin/people-clone bin/people-init-db bin/people-ls bin/people-find bin/people-mv-db bin/people-rm-db
	install -pm750 -oroot -ggiter $^ ${DESTDIR}${PREFIX}/bin/

install-sbin: sbin/giter-add sbin/giter-auth-add sbin/giter-auth-zero sbin/giter-disable sbin/giter-enable
	install -pm700 -oroot -groot $^ ${DESTDIR}${PREFIX}/sbin/

bin/giter-sh: bin/giter-sh.c
