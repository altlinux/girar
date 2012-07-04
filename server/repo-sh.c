/*
  Copyright (C) 2012  Dmitry V. Levin <ldv@altlinux.org>

  The repo shell.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
*/

#define _GNU_SOURCE

#include <stdio.h>
#include <errno.h>
#include <error.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/types.h>
#include <pwd.h>
#include <syslog.h>

typedef struct
{
	const char *name, *exec, *usage;
} cmd_t;

static cmd_t commands[] = {
	{"reposit", "/usr/libexec/repo/reposit", " <reponame> <taskno>"},
};

static void
__attribute__((noreturn))
show_help(int rc)
{
	FILE *fp = (EXIT_SUCCESS == rc) ? stdout : stderr;
	fprintf(fp, "%s", "Available commands:\nhelp\n");
	unsigned i;
	for (i = 0; i < sizeof(commands) / sizeof(commands[0]); ++i)
		fprintf(fp, "%s%s\n", commands[i].name, commands[i].usage);
	exit(rc);
}

static void
__attribute__((noreturn))
exec_cmd(const char *exec, char *str)
{
	const char *args[strlen(str) + 2];
	unsigned i = 0;

	args[i++] = exec;

	char   *p = str;

	while (*p && isblank(*p))
		++p;
	while (*p)
	{
		args[i++] = p++;
		while (*p && !isblank(*p))
			++p;
		if (!*p)
			break;
		*(p++) = '\0';
		while (isblank(*p))
			++p;
	}

	args[i] = 0;

	putenv("PATH=/usr/libexec/repo:/bin:/usr/bin:/usr/local/bin");
	execv(exec, (char *const *) args);
	error(EXIT_FAILURE, errno, "execv: %s", args[0]);
	exit(EXIT_FAILURE);
}

static void
__attribute__((noreturn))
try_help(void)
{
	error(0, 0, "Try `help' command for more information.\r");
	exit(EXIT_FAILURE);
}

static int
is_command_match(const char *sample, const char *cmd, size_t len)
{
	return !strncmp(cmd, sample, len) &&
		(sample[len] == '\0' || isblank(sample[len]));
}

int
main (int ac, char *av[])
{
	if (3 != ac)
	{
		error(0, 0, "%s arguments.\r", (ac < 3) ? "Not enough" : "Too many");
		try_help();
	}

	if (strcmp("-c", av[1]))
		error(EXIT_FAILURE, EINVAL, "%s", av[1]);

	char *cmd = av[2];

	if (!strcmp("help", cmd) || !strcmp("--help", cmd))
		show_help(EXIT_SUCCESS);

	openlog("repo-sh", LOG_PID, LOG_USER);
	syslog(LOG_INFO, "%s", cmd);
	closelog();

	unsigned i;
	for (i = 0; i < sizeof(commands)/sizeof(commands[0]); ++i)
	{
		size_t len = strlen(commands[i].name);
		if (is_command_match(cmd, commands[i].name, len))
			exec_cmd(commands[i].exec, &cmd[len]);
	}

	error(0, 0, "%s: Invalid command", cmd);
	try_help();
}
