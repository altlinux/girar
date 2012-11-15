EXECDIR = /usr/libexec/gb-depot
SOCKDIR = /var/run/gb-depot
SOCKGRP = girar-committer
USER =

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS} \
	   -DEXECDIR=\"${EXECDIR}\" -DSOCKDIR=\"${SOCKDIR}\" -DUSER=\"${USER}\"
CFLAGS = -pipe -O2

all: gb-proxyd-depot gb-proxyd-repo gb-proxyd-depot.init gb-proxyd-repo.init

gb-proxyd-depot: USER = depot
gb-proxyd-repo: USER = repo

gb-proxyd-depot gb-proxyd-repo: gb-proxyd.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@

gb-proxyd-depot.init: USER = depot
gb-proxyd-repo.init: USER = repo

gb-proxyd-depot.init gb-proxyd-repo.init: gb-proxyd.in
	sed -e 's,@EXECDIR@,${EXECDIR},g' \
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SOCKGRP@,${SOCKGRP},g' \
	    -e 's,@USER@,${USER},g' \
		<$< >$@
	chmod --reference=$< $@
