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

	/* check for prefix, be quiet about failure */
	const char prefix[] = "git_";
	if (strncmp(pw->pw_name, prefix, sizeof(prefix) - 1))
		error(EXIT_FAILURE, 0, "prefix not found");

	char   *home;
	if (asprintf(&home, "%s%s",
		     "/people/", pw->pw_name + sizeof(prefix) - 1) < 0)
		error(EXIT_FAILURE, errno, "asprintf");

	/* chdir to new home, be quiet about failure */
	if (chdir(home) < 0)
		error(EXIT_FAILURE, errno, "chdir");

	const char *tmpdir = getenv("TMPDIR");
	if (tmpdir)
		tmpdir = strdup(tmpdir);

	/* environ */
	if (clearenv() < 0)
		error(EXIT_FAILURE, errno, "clearenv");

	if (setenv("USER", pw->pw_name, 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: %s", "USER");

	if (setenv("LOGNAME", pw->pw_name, 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: %s", "LOGNAME");

	if (setenv("HOME", home, 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: %s", "HOME");

	if (setenv("PATH", "/bin:/usr/bin", 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: %s", "PATH");

	if (tmpdir && *tmpdir && setenv("TMPDIR", tmpdir, 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: %s", "TMPDIR");

	if (3 == ac)
	{
		openlog("giter-sh", LOG_PID, LOG_USER);
		syslog(LOG_INFO, "%s: %s %s",
		       pw->pw_name + sizeof(prefix) - 1, av[1], av[2]);
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
	{"git-init-db", "/usr/local/bin/people-init-db", " <directory>"},
	{"git-mv-db", "/usr/local/bin/people-mv-db", " <source-directory> <dest-directory>"},
	{"git-rm-db", "/usr/local/bin/people-rm-db", " <directory>"},
	{"git-clone", "/usr/local/bin/people-clone", " <repository> [<directory>]"},
	{"ls", "/usr/local/bin/people-ls", " [<directory>]"}
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
	const char *slash = strrchr(cmd->exec, '/');
	if (slash)
		++slash;

	const char *args[strlen(str) + 2];
	unsigned i = 0;
	args[i++] = slash;

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
	execv(cmd->exec, (char *const *) args);
	error(EXIT_FAILURE, errno, "execv: %s", args[0]);
}
