/*
 * The girar-archiver kicker shell.
 *
 * Copyright (c) 2006-2019  Dmitry V. Levin <ldv@altlinux.org>
 * All rights reserved.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#define _GNU_SOURCE

#include <ctype.h>
#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#include <unistd.h>

#ifndef GA_KICKER_DIR
# define GA_KICKER_DIR "/var/run/girar-archiver/kicker"
#endif

int
main (int ac, char *av[])
{
	if (chdir(GA_KICKER_DIR))
		err(EXIT_FAILURE, "%s", GA_KICKER_DIR);

	if (3 != ac)
		errx(EXIT_FAILURE, "%s arguments.\r", (ac < 3) ? "Not enough" : "Too many");

	if (strcmp("-c", av[1])) {
		errno = EINVAL;
		err(EXIT_FAILURE, "%s", av[1]);
	}

	const char *target = av[2];

	openlog("ga_kicker-sh", LOG_PID, LOG_USER);
	syslog(LOG_INFO, "%s", target);
	closelog();

	if (!isalnum(target[0]) || strchr(target, '/')) {
		errno = EINVAL;
		err(EXIT_FAILURE, "%s", target);
	}

	if (open(target, O_RDONLY|O_APPEND) < 0)
		err(EXIT_FAILURE, "%s", target);

	return 0;
}
