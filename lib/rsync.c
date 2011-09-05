#ifndef _GNU_SOURCE
# define _GNU_SOURCE
#endif

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <sys/types.h>
#include <dlfcn.h>

static void *load_sym(const char *name)
{
	void *addr;
	const char *msg;

	(void) dlerror();
	addr = dlsym(RTLD_NEXT, name);
	if ((msg = dlerror()))
	{
		fprintf(stderr, "dlsym(%s): %s\n", name, msg);
		_exit(1);
	}
	return addr;
}

int link(const char *oldpath, const char *newpath)
{
	errno = EINVAL;
	return -1;
}

int mkdir(const char *pathname, mode_t mode)
{
	errno = EINVAL;
	return -1;
}

int symlink(const char *oldpath, const char *newpath)
{
	errno = EINVAL;
	return -1;
}

int chmod(const char *path, mode_t mode)
{
	static int (*next_chmod)(const char *, mode_t);

	if (!next_chmod)
		next_chmod = load_sym("chmod");

	if (path && !strstr(path, ".src.rpm"))
	{
		errno = EINVAL;
		return -1;
	}

	return next_chmod(path, 0644);
}

int fchmod(int fd, mode_t mode)
{
	static int (*next_fchmod)(int, mode_t);

	if (!next_fchmod)
		next_fchmod = load_sym("fchmod");

	return next_fchmod(fd, 0644);
}

int chdir(const char *path)
{
	errno = 0;
	return 0;
}

int mkstemp(char *template)
{
	static int (*next_mkstemp)(char *);

	if (!next_mkstemp)
		next_mkstemp = load_sym("mkstemp");

	char *t;
	if (template && (t = strrchr(template, '/')))
		template = t + 1;

	if (template && !strstr(template, ".src.rpm"))
	{
		errno = EINVAL;
		return -1;
	}

	return next_mkstemp(template);
}

int open(const char *path, int flags, mode_t mode)
{
	static int (*next_open)(const char *, int, mode_t);

	if (!next_open)
		next_open = load_sym("open");

	if (path && (flags & 3) && !strstr(path, ".src.rpm"))
	{
		errno = EINVAL;
		return -1;
	}

	return next_open(path, flags, mode);
}

char *getcwd(char *buf, size_t size)
{
	if (!buf)
	{
		errno = EFAULT;
		return NULL;
	}
	if (size < 2)
	{
		errno = ERANGE;
		return NULL;
	}
	buf[0] = '.';
	buf[1] = '\0';
	return buf;
}
