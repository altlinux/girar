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

int
main (int ac, char *av[])
{
	const char prefix[] = "git_";
	char   *home;
	struct passwd *pw;
	uid_t   uid = getuid();

	if (!uid)
		error(EXIT_FAILURE, 0, "must be non-root");

	/* setcred */
	if (setuid(uid) < 0)
		error(EXIT_FAILURE, errno, "setuid");

	pw = getpwuid(uid);
	if (!pw)
		error(EXIT_FAILURE, errno, "getpwuid");

	if (strncmp(pw->pw_name, prefix, sizeof(prefix) - 1))
		error(EXIT_FAILURE, 0, "prefix not found");

	if (asprintf(&home, "/people/%s", pw->pw_name + sizeof(prefix) - 1) < 0)
		error(EXIT_FAILURE, errno, "asprintf");

	if (chdir(home) < 0)
		error(EXIT_FAILURE, errno, "chdir");

	/* environ */
	if (clearenv() < 0)
		error(EXIT_FAILURE, errno, "clearenv");

	if (setenv("USER", pw->pw_name, 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: USER");

	if (setenv("LOGNAME", pw->pw_name, 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: LOGNAME");

	if (setenv("HOME", home, 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: HOME");

	if (setenv("PATH", "/bin:/usr/bin", 1) < 0)
		error(EXIT_FAILURE, errno, "setenv: PATH");

	if (3 == ac)
	{
		const char git_receive_pack[] = "git-receive-pack ";
		const char git_upload_pack[] = "git-upload-pack ";
		const char init_db[] = "git-init-db ";
		const char rm_db[] = "git-rm-db ";
		const char clone[] = "git-clone ";

		if (strcmp("-c", av[1]))
			error(EXIT_FAILURE, EINVAL, "%s", av[1]);

		if (!strcmp("help", av[2]))
		{
			printf(
"Available commands:\n"
"%s<directory>\n"
"%s<directory>\n"
"%s<directory>\n"
"%s<directory>\n"
"%s<repository> <directory>\n"
"list\n"
"help\n",
				git_receive_pack,
				git_upload_pack,
				init_db,
				rm_db,
				clone);
			return EXIT_SUCCESS;
		}

		if (!strcmp("list", av[2]))
		{
			const char *args[] = {"ls", "-log", "packages", NULL};
			execv("/bin/ls",
			      (char *const *) args);
			error(EXIT_FAILURE, errno, "execv: %s", args[0]);
		}

		if (!strncmp(git_receive_pack, av[2], sizeof(git_receive_pack) - 1) ||
		    !strncmp(git_upload_pack, av[2], sizeof(git_upload_pack) - 1))
		{
			av[0] = (char *) "git-shell";
			execv("/usr/bin/git-shell", av);
			error(EXIT_FAILURE, errno, "execv: %s", av[0]);
		}

		if (!strncmp(init_db, av[2], sizeof(init_db) - 1))
		{
			const char *args[strlen(av[2])];
			unsigned i = 0;
			char   *p = av[2] + sizeof(init_db) - 1;

			args[i++] = "people-init-db";

			while (*p)
			{
				args[i++] = p++;
				while (*p && !isblank(*p))
					p++;
				if (!*p)
					break;
				*(p++) = '\0';
				while (isblank(*p))
					p++;
			}

			args[i] = 0;
			execv("/usr/local/bin/people-init-db",
			      (char *const *) args);
			error(EXIT_FAILURE, errno, "execv: %s", args[0]);
		}

		if (!strncmp(rm_db, av[2], sizeof(rm_db) - 1))
		{
			const char *args[strlen(av[2])];
			unsigned i = 0;
			char   *p = av[2] + sizeof(rm_db) - 1;

			args[i++] = "people-rm-db";

			while (*p)
			{
				args[i++] = p++;
				while (*p && !isblank(*p))
					p++;
				if (!*p)
					break;
				*(p++) = '\0';
				while (isblank(*p))
					p++;
			}

			args[i] = 0;
			execv("/usr/local/bin/people-rm-db",
			      (char *const *) args);
			error(EXIT_FAILURE, errno, "execv: %s", args[0]);
		}

		if (!strncmp(clone, av[2], sizeof(clone) - 1))
		{
			const char *args[strlen(av[2])];
			unsigned i = 0;
			char   *p = av[2] + sizeof(clone) - 1;

			args[i++] = "people-clone";

			while (*p)
			{
				args[i++] = p++;
				while (*p && !isblank(*p))
					p++;
				if (!*p)
					break;
				*(p++) = '\0';
				while (isblank(*p))
					p++;
			}

			args[i] = 0;
			execv("/usr/local/bin/people-clone",
			      (char *const *) args);
			error(EXIT_FAILURE, errno, "execv: %s", args[0]);
		}

		error(EXIT_FAILURE, EINVAL, "%s", av[2]);
	}

	error(EXIT_FAILURE, 0, "invalid arguments");
	return EXIT_FAILURE;
}
