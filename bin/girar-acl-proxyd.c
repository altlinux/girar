/*
  Copyright (C) 2004,2010  Dmitry V. Levin <ldv@altlinux.org>

  The girar acl proxy daemon.

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

static void
sigchld_handler(__attribute__ ((unused)) int signo)
{
	while (waitpid(-1, 0, WNOHANG) > 0)
		;
}

static int
bind_address(const char *address)
{
	struct sockaddr_un sun;

	if (strlen(address) >= sizeof(sun))
		error(EXIT_FAILURE, EINVAL, "cannot bind socket `%s'",
		      address);

	memset(&sun, 0, sizeof(sun));
	sun.sun_family = AF_UNIX;
	strcpy(sun.sun_path, address);

	int     fd = socket(PF_UNIX, SOCK_STREAM, 0);

	if (fd < 0)
		error(EXIT_FAILURE, errno, "cannot create socket `%s'",
		      address);

	if (bind(fd, (struct sockaddr *) &sun, sizeof(sun)))
	{
		unlink(address);

		if (bind(fd, (struct sockaddr *) &sun, sizeof(sun)))
			error(EXIT_FAILURE, errno, "cannot bind socket `%s'",
			      address);
	}

	if (chmod(address, 0666))
		error(EXIT_FAILURE, errno,
		      "cannot set permissions of socket `%s'", address);

	if (listen(fd, 5) < 0)
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

	struct passwd *pw = getpwuid(sucred.uid);

	if (!pw)
	{
		close(fd);
		syslog(LOG_ERR,
		       "getsockopt: request from (uid=%u), unknown user rejected",
		       sucred.uid);
		exit(EXIT_FAILURE);
	}

	const char *girar_user = pw->pw_name + sizeof(USER_PREFIX) - 1;

	if (strncmp(pw->pw_name, USER_PREFIX, sizeof(USER_PREFIX) - 1) ||
	    girar_user[0] == '\0')
		girar_user = "root";

	if (setenv("GIRAR_USER", girar_user, 1))
	{
		syslog(LOG_ERR, "setenv: %m");
		exit(EXIT_FAILURE);
	}
	dup2(fd, 0);
	close(fd);
	syslog(LOG_INFO, "request from %s (uid=%u) forwarded via %s%s",
	       pw->pw_name, sucred.uid, USER_PREFIX, girar_user);

	const char *file = "girar-acl-merge-changes";
	const char *const args[] = { file, NULL };
	execvp(file, args);
	syslog(LOG_ERR, "execvp: %s: %m", file);
	exit(EXIT_FAILURE);
}

int
main(int argc, __attribute__ ((unused)) const char *argv[])
{
	if (argc > 1)
		error(EXIT_FAILURE, 0, "Too many arguments");

	struct passwd *pw;

	if (!(pw = getpwnam(GIRAR_USER)))
		error(EXIT_FAILURE, 0, "user `%s' lookup failed", GIRAR_USER);

	int     fd = bind_address(GIRAR_ACL_SOCKET);

	if (clearenv() < 0)
		error(EXIT_FAILURE, errno, "clearenv");

	if ((setenv("USER", GIRAR_USER, 1) < 0) ||
	    (setenv("HOME", "/var/empty", 1) < 0) ||
	    (setenv("PATH", GIRAR_BINDIR ":/bin:/usr/bin", 1) < 0))
		error(EXIT_FAILURE, errno, "setenv");

	if (initgroups(GIRAR_USER, pw->pw_gid))
		error(EXIT_FAILURE, errno, "initgroups");

	if (setgid(pw->pw_gid))
		error(EXIT_FAILURE, errno, "setgid");

	if (setuid(pw->pw_uid))
		error(EXIT_FAILURE, errno, "setuid");

	endpwent();

	if (daemon(0, 0))
		error(EXIT_FAILURE, errno, "daemon");

	openlog("girar-acl-proxyd", LOG_PERROR | LOG_PID, LOG_DAEMON);

	signal(SIGCHLD, sigchld_handler);

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
