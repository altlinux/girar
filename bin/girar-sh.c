/*
  Copyright (C) 2006  Dmitry V. Levin <ldv@altlinux.org>

  The girar shell.

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

static void shell(char *av[]);

int
main (int ac, char *av[])
{
	uid_t   uid = getuid();

	if (!uid)
		error(EXIT_FAILURE, 0, "must be non-root");

	struct passwd *pw = getpwuid(uid);

	if (!pw)
		error(EXIT_FAILURE, errno, "getpwuid");

	const char *girar_user = pw->pw_name + sizeof(USER_PREFIX) - 1;

	if (strncmp(pw->pw_name, USER_PREFIX, sizeof(USER_PREFIX) - 1) ||
	    girar_user[0] == '\0')
		error(EXIT_FAILURE, 0, "invalid account name");

	char   *home;

	if (asprintf(&home, "%s/%s", GIRAR_HOME, girar_user) < 0)
		error(EXIT_FAILURE, errno, "asprintf");

	if (chdir(home) < 0)
		error(EXIT_FAILURE, errno, "chdir");

	const char *tmpdir = getenv("TMPDIR");

	if (tmpdir)
		tmpdir = strdup(tmpdir);

	if (clearenv() < 0)
		error(EXIT_FAILURE, errno, "clearenv");

	if ((setenv("USER", pw->pw_name, 1) < 0) ||
	    (setenv("LOGNAME", pw->pw_name, 1) < 0) ||
	    (setenv("HOME", home, 1) < 0) ||
	    (setenv("PATH", "/bin:/usr/bin", 1) < 0) ||
	    (setenv("GIRAR_ARCHIVE", GIRAR_ARCHIVE, 1) < 0) ||
	    (setenv("GIRAR_HOME", GIRAR_HOME, 1) < 0) ||
	    (setenv("GIRAR_USER", girar_user, 1) < 0) ||
	    (setenv("GIRAR_USER_PREFIX", USER_PREFIX, 1) < 0) ||
	    (tmpdir && *tmpdir && setenv("TMPDIR", tmpdir, 1) < 0))
		error(EXIT_FAILURE, errno, "setenv");

	if (3 == ac)
	{
		openlog("girar-sh", LOG_PID, LOG_USER);
		syslog(LOG_INFO, "%s: %s %s", girar_user, av[1], av[2]);
		closelog();
		shell(av);
	}

	error(EXIT_FAILURE, 0, "invalid arguments");
	return EXIT_FAILURE;
}

typedef struct
{
	const char *name, *exec, *usage;
} cmd_t;

static cmd_t commands[] = {
	{"git-clone", "girar-clone", " <git-repository> [<directory>]"},
	{"git-init-db", "girar-init-db", " <directory>"},
	{"git-mv-db", "girar-mv-db", " <source-directory> <dest-directory>"},
	{"git-rm-db", "girar-rm-db", " <git-repository>"},
	{"build", "girar-build", " <git-repository> <tag> <binary-package-repository> [<project-name>]"},
	{"find-package", "girar-find", " <pattern>"},
	{"ls", "girar-ls", " [<directory>]"},
	{"quota", "girar-quota", ""}
};

static void exec_cmd(cmd_t *cmd, char *str);

static void
shell (char *av[])
{
	const char git_receive_pack[] = "git-receive-pack ";
	const char git_upload_pack[] = "git-upload-pack ";

	if (strcmp("-c", av[1]))
		error(EXIT_FAILURE, EINVAL, "%s", av[1]);

	unsigned i;
	if (!strcmp("help", av[2]))
	{
		printf("Available commands:\n"
		       "help\n"
		       "%s<directory>\n"
		       "%s<directory>\n",
		       git_receive_pack,
		       git_upload_pack);
		for (i = 0; i < sizeof(commands)/sizeof(commands[0]); ++i)
			printf("%s%s\n", commands[i].name, commands[i].usage);
		exit(EXIT_SUCCESS);
	}

	if (!strncmp(git_receive_pack, av[2], sizeof(git_receive_pack) - 1) ||
	    !strncmp(git_upload_pack, av[2], sizeof(git_upload_pack) - 1))
	{
		av[0] = (char *) "git-shell";
		execv("/usr/bin/git-shell", av);
		error(EXIT_FAILURE, errno, "execv: %s", av[0]);
	}

	for (i = 0; i < sizeof(commands)/sizeof(commands[0]); ++i)
	{
		size_t len = strlen(commands[i].name);
		if (!strncmp(commands[i].name, av[2], len) &&
		    (av[2][len] == '\0' || isblank(av[2][len])))
			exec_cmd(&commands[i], &av[2][len]);
	}

	error(EXIT_FAILURE, EINVAL, "%s", av[2]);
}

static void exec_cmd(cmd_t *cmd, char *str)
{
	const char *args[strlen(str) + 2];
	unsigned i = 0;

	args[i++] = cmd->exec;

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

	char   *path;

	if (asprintf(&path, "%s/%s", GIRAR_BINDIR, cmd->exec) < 0)
		error(EXIT_FAILURE, errno, "asprintf");
	execv(path, (char *const *) args);
	error(EXIT_FAILURE, errno, "execv: %s", args[0]);
}
