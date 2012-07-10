
/*
  Copyright (C) 2004-2012  Dmitry V. Levin <ldv@altlinux.org>

  The girar-builder proxy daemon.

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
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#ifndef _GNU_SOURCE
# define _GNU_SOURCE
#endif
#include <stdio.h>
#include <errno.h>
#include <error.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <syslog.h>
#include <fcntl.h>
#include <pwd.h>
#include <grp.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <sys/wait.h>

static void __attribute__ ((noreturn))
bind_failed(const char *address, int code)
{
	error(EXIT_FAILURE, code, "bind: %s", address);
	exit(EXIT_FAILURE);
}

static int
address_is_dead(const char *address)
{
	struct sockaddr_un sun;

	memset(&sun, 0, sizeof(sun));
	sun.sun_family = AF_UNIX;
	strcpy(sun.sun_path, address);

	int     fd = socket(PF_UNIX, SOCK_STREAM, 0);

	if (fd < 0)
		error(EXIT_FAILURE, errno, "socket");

	int     rc = connect(fd, (struct sockaddr *) &sun, sizeof(sun));

	if (rc && errno != ECONNREFUSED)
		rc = 0;

	close(fd);
	return rc;
}

static int
bind_address(const char *address)
{
	struct sockaddr_un sun;

	if (strlen(address) >= sizeof(sun.sun_path))
		bind_failed(address, ENAMETOOLONG);

	memset(&sun, 0, sizeof(sun));
	sun.sun_family = AF_UNIX;
	strcpy(sun.sun_path, address);

	int     fd = socket(PF_UNIX, SOCK_STREAM, 0);

	if (fd < 0)
		error(EXIT_FAILURE, errno, "socket");

	umask(0);

	if (bind(fd, (struct sockaddr *) &sun, sizeof(sun)))
	{
		if (errno != EADDRINUSE)
			bind_failed(address, errno);
		if (!address_is_dead(address))
			bind_failed(address, EADDRINUSE);
		if (unlink(address))
			error(EXIT_FAILURE, errno, "unlink: %s", address);
		if (bind(fd, (struct sockaddr *) &sun, sizeof(sun)))
			bind_failed(address, errno);
	}

	umask(022);

	if (listen(fd, SOMAXCONN) < 0)
		error(EXIT_FAILURE, errno, "listen");

	int     flags;

	if ((flags = fcntl(fd, F_GETFD, 0)) == -1)
		error(EXIT_FAILURE, errno, "fcntl: F_GETFD");

	flags |= FD_CLOEXEC;

	if (fcntl(fd, F_SETFD, flags) == -1)
		error(EXIT_FAILURE, errno, "fcntl: F_SETFD");

	return fd;
}

static void
handle_socket(int listen_fd)
{
	struct sockaddr_un sun;

	memset(&sun, 0, sizeof(sun));
	sun.sun_family = AF_UNIX;
	socklen_t sunlen = sizeof(sun);
	int     fd = accept(listen_fd, (struct sockaddr *) &sun, &sunlen);

	if (fd < 0)
	{
		if (errno != EINTR)
			syslog(LOG_ERR, "accept: %m");
		return;
	}

	struct ucred sucred;
	socklen_t credlen = sizeof(struct ucred);

	if (getsockopt(fd, SOL_SOCKET, SO_PEERCRED, &sucred, &credlen))
	{
		close(fd);
		syslog(LOG_ERR, "getsockopt: SO_PEERCRED: %m");
		return;
	}

	pid_t   pid = fork();

	if (pid < 0)
	{
		close(fd);
		syslog(LOG_ERR, "fork: %m");
		return;
	}

	if (pid)
	{
		close(fd);
		return;
	}

	syslog(LOG_INFO, "request from [pid=%d, uid=%u, gid=%u]",
	       sucred.pid, sucred.uid, sucred.gid);

	dup2(fd, 0);
	dup2(fd, 1);
	dup2(fd, 2);
	close(fd);

	const char *file = "socket-forward-" USER;

	const char *const args[] = {
		file, NULL
	};
	execvp(file, (char * const*) args);
	syslog(LOG_ERR, "execvp: %s: %m", file);
	exit(EXIT_FAILURE);
}

static void
nocldwait(void)
{
	struct sigaction sa;

	sa.sa_handler = SIG_DFL;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_NOCLDWAIT;
	if (sigaction(SIGCHLD, &sa, NULL))
		error(EXIT_FAILURE, errno, "sigaction");
}

int
main(int argc, __attribute__ ((unused))
     const char *argv[])
{
	if (argc > 1)
		error(EXIT_FAILURE, 0, "Too many arguments");

	if (clearenv() < 0)
		error(EXIT_FAILURE, errno, "clearenv");

	struct passwd *pw;

	if (!(pw = getpwnam(USER)))
		error(EXIT_FAILURE, 0, "getpwnam: %s", USER);

	if ((setenv("USER", USER, 1)) ||
	    (setenv("HOME", pw->pw_dir, 1)) ||
	    (setenv("PATH", EXECDIR ":/bin:/usr/bin", 1)))
		error(EXIT_FAILURE, errno, "setenv");

	if (chdir(SOCKDIR))
		error(EXIT_FAILURE, errno, "chdir: %s", pw->pw_dir);

	int     fd = bind_address(USER);

	if (initgroups(USER, pw->pw_gid))
		error(EXIT_FAILURE, errno, "initgroups: %u", pw->pw_gid);

	if (setgid(pw->pw_gid))
		error(EXIT_FAILURE, errno, "setgid: %u", pw->pw_gid);

	if (setuid(pw->pw_uid))
		error(EXIT_FAILURE, errno, "setuid: %u", pw->pw_uid);

	endpwent();

	if (daemon(0, 0))
		error(EXIT_FAILURE, errno, "daemon");

	nocldwait();

	openlog("gb-proxyd-" USER, LOG_PERROR | LOG_PID, LOG_DAEMON);
	syslog(LOG_INFO, "waiting for requests");

	for (;;)
	{
		fd_set  r;

		FD_ZERO(&r);
		FD_SET(fd, &r);

		int     rc = select(1 + fd, &r, 0, 0, 0);

		if (rc < 0)
		{
			if (errno == EINTR)
				continue;

			syslog(LOG_ERR, "select: %m");
			sleep(1);
			continue;
		}

		if (FD_ISSET(fd, &r))
			handle_socket(fd);
	}
}
