WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS}
CFLAGS = -pipe -O2

server/depot-sh: server/depot-sh.c
