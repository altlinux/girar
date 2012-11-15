EXECDIR = /usr/libexec/gb-depot
SOCKDIR = /var/run/gb-depot
SOCKGRP = bull
USER =

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS} \
	   -DEXECDIR=\"${EXECDIR}\" -DSOCKDIR=\"${SOCKDIR}\" -DUSER=\"${USER}\"
CFLAGS = -pipe -O2

all: girar-proxyd-depot girar-proxyd-repo girar-proxyd-depot.init girar-proxyd-repo.init

girar-proxyd-depot: USER = depot
girar-proxyd-repo: USER = repo

girar-proxyd-depot girar-proxyd-repo: girar-proxyd.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@

girar-proxyd-depot.init: USER = depot
girar-proxyd-repo.init: USER = repo

girar-proxyd-depot.init girar-proxyd-repo.init: girar-proxyd.in
	sed -e 's,@EXECDIR@,${EXECDIR},g' \
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SOCKGRP@,${SOCKGRP},g' \
	    -e 's,@USER@,${USER},g' \
		<$< >$@
	chmod --reference=$< $@
