/*
  Copyright (C) 2010  Dmitry V. Levin <ldv@altlinux.org>

  Connects stdout to a unix domain address and executes a program.

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


#ifndef _GNU_SOURCE
# define _GNU_SOURCE
#endif
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <error.h>
#include <sys/socket.h>
#include <sys/un.h>

static int
connect_socket(const char *fname)
{
	int     fd;
	struct sockaddr_un addr;

	fd = socket(PF_UNIX, SOCK_STREAM, 0);
	if (fd < 0)
		error(EXIT_FAILURE, errno, "socket");

	addr.sun_family = AF_UNIX;
	strncpy(addr.sun_path, fname, sizeof(addr.sun_path) - 1);
	addr.sun_path[sizeof(addr.sun_path) - 1] = '\0';

	if (connect(fd, (struct sockaddr *) &addr, sizeof(addr)))
		error(EXIT_FAILURE, errno, "connect: %s", fname);

	return fd;
}

int
main(int argc, char *argv[])
{
	if (argc < 2)
	{
		fprintf(stderr, "Usage: %s <path to socket> <program>...\n",
			program_invocation_short_name);
		exit(EXIT_FAILURE);
	}

	int fd = connect_socket(argv[1]);

	if (fd != STDOUT_FILENO)
	{
		if (dup2(fd, STDOUT_FILENO) != STDOUT_FILENO)
			error(EXIT_FAILURE, errno, "dup2");
		close(fd);
	}

	execvp(argv[2], argv + 2);
	error(EXIT_FAILURE, errno, "execvp: %s", argv[2]);
}
