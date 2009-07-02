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

typedef struct
{
	const char *name, *exec, *usage;
} cmd_t;

static cmd_t commands[] = {
	{"charset", "girar-charset", " <path to git repository> [<charset>]"},
	{"clone", "girar-clone", " <path to git repository> [<path to directory>]"},
	{"default-branch", "girar-default-branch", " <path to git repository> [<branch>]"},
	{"find-package", "girar-find", " <pattern>"},
	{"init-db", "girar-init-db", " <path to directory>"},
	{"ls", "girar-ls", " [<path to directory>]"},
	{"mv-db", "girar-mv-db", " <path to source directory> <path to destination directory>"},
	{"quota", "girar-quota", ""},
	{"rm-db", "girar-rm-db", " <path to git repository>"},
	{"task", "girar-task", " {--help|ls|show|new|add|delsub|run|share|approve|rm} ..."},
	{"build", "girar-build", " [-b <binary_repository_name>] <gear_repo_1> <gear_tag_1> ..."},
	{"acl", "girar-acl", " {--help|<binary_repository_name> ...}"},
};

static const char git_receive_pack[] = "git-receive-pack";
static const char git_upload_pack[] = "git-upload-pack";
static const char rsync_server[] = "rsync --server";

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

	char   *path;

	if (asprintf(&path, "%s/%s", GIRAR_BINDIR, exec) < 0)
		error(EXIT_FAILURE, errno, "asprintf");
	execv(path, (char *const *) args);
	error(EXIT_FAILURE, errno, "execv: %s", args[0]);
	exit(EXIT_FAILURE);
}

static void
__attribute__((noreturn))
exec_rsync(char *str)
{
	const char *args[strlen(str) + 1];
	unsigned i = 0;
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

	const char *old_home = getenv("HOME");
	char   *home;

	if (asprintf(&home, "%s/incoming", old_home) < 0)
		error(EXIT_FAILURE, errno, "asprintf");
	if (chdir(home) < 0)
		error(EXIT_FAILURE, errno, "chdir");
	if ((setenv("HOME", home, 1) < 0) ||
	    (setenv("LD_PRELOAD", GIRAR_LIBDIR "/rsync.so", 1) < 0))
		error (EXIT_FAILURE, errno, "setenv");

	execv("/usr/bin/rsync", (char *const *) args);
	error(EXIT_FAILURE, errno, "execv: %s", args[0]);
	exit(EXIT_FAILURE);
}

static int
is_command_match(const char *sample, const char *cmd, size_t len)
{
	return !strncmp(cmd, sample, len) &&
		(sample[len] == '\0' || isblank(sample[len]));
}

static void
__attribute__((noreturn))
shell (char *av[])
{
	if (strcmp("-c", av[1]))
		error(EXIT_FAILURE, EINVAL, "%s", av[1]);

	char *cmd = av[2];

	if (!strcmp("help", cmd) || !strcmp("--help", cmd))
		show_help(EXIT_SUCCESS);

	if (is_command_match(cmd, git_receive_pack, sizeof(git_receive_pack) - 1) ||
	    is_command_match(cmd, git_upload_pack, sizeof(git_upload_pack) - 1))
	{
		av[0] = (char *) "git-shell";
		execv("/usr/bin/git-shell", av);
		error(EXIT_FAILURE, errno, "execv: %s", av[0]);
	}

	if (is_command_match(cmd, rsync_server, sizeof(rsync_server) - 1))
		exec_rsync(cmd);

	if (!strncmp(cmd, "git-", 4))
		cmd += 4;

	unsigned i;
	for (i = 0; i < sizeof(commands)/sizeof(commands[0]); ++i)
	{
		size_t len = strlen(commands[i].name);
		if (is_command_match(cmd, commands[i].name, len))
			exec_cmd(commands[i].exec, &cmd[len]);
	}

	error(0, 0, "%s: Invalid command", cmd);
	error(0, 0, "Try `help' command for more information.");
	exit(EXIT_FAILURE);
}

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
	    (setenv("PATH", GIRAR_BINDIR ":/bin:/usr/bin", 1) < 0) ||
	    (setenv("GIRAR_ARCHIVE", GIRAR_ARCHIVE, 1) < 0) ||
	    (setenv("GIRAR_GEARS", GIRAR_GEARS, 1) < 0) ||
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

	error(0, 0, "%s arguments.\r", (ac < 3) ? "Not enough" : "Too many");
	error(0, 0, "Try `help' command for more information.\r");
	return EXIT_FAILURE;
}
