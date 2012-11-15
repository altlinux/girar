DESTDIR =
datadir = /usr/share
libexecdir = /usr/libexec
localstatedir = /var/lib
runtimedir = /var/run
sbindir = /usr/sbin
spooldir = /var/spool
sysconfdir = /etc
initdir = ${sysconfdir}/rc.d/init.d

girar_bindir = ${libexecdir}/girar
girar_libdir = ${libexecdir}/girar
girar_sbindir = ${sbindir}
girar_confdir = ${sysconfdir}/girar
girar_datadir = ${datadir}/girar
girar_runtimedir = ${runtimedir}/girar
girar_spooldir = ${spooldir}/girar
girar_statedir = ${localstatedir}/girar
girar_hooks_dir = ${girar_datadir}/hooks
girar_templates_dir = ${girar_datadir}/templates
girar_packages_dir = ${girar_datadir}/packages.git
girar_private_dir = ${girar_datadir}/private.git
girar_public_dir = ${girar_datadir}/public.git
girar_email_dir = ${girar_statedir}/email
girar_acl_state_dir = ${girar_statedir}/acl
girar_acl_pub_dir = ${girar_statedir}/acl.pub
girar_repo_conf_dir = ${girar_confdir}/repo

EMAIL_DOMAIN = altlinux.org
GB_GROUP = girar-tasks
GB_TASKS = ${girar_spooldir}/tasks
GB_TASKS_DONE_DIR = ${GB_TASKS}/archive/done
GIRAR_ACL_SOCKET = ${girar_runtimedir}/acl/socket
GIRAR_SRPMS = /srpms
GIRAR_EMAIL_ALIASES = ${girar_confdir}/aliases
GIRAR_FAKE_HOME = ${girar_datadir}/home
GIRAR_GEARS = /gears
GIRAR_HOME = /people
GIRAR_PACKAGES_LIST = ${girar_statedir}/people-packages-list
GIRAR_PEOPLE_QUEUE = ${girar_spooldir}/people
GIRAR_REPO_LIST = ${girar_confdir}/repositories
GITWEB_URL = http://git.altlinux.org
PACKAGES_EMAIL = ALT Devel discussion list <devel@lists.${EMAIL_DOMAIN}>
USER_PREFIX = git_

GIRAR_ACL_USER = girar-acl

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS} \
	-DGIRAR_ACL_SOCKET=\"${GIRAR_ACL_SOCKET}\" \
	-DGIRAR_ACL_USER=\"${GIRAR_ACL_USER}\" \
	-DGIRAR_BINDIR=\"${girar_bindir}\" \
	-DGIRAR_GEARS=\"${GIRAR_GEARS}\" \
	-DGIRAR_HOME=\"${GIRAR_HOME}\" \
	-DGIRAR_LIBDIR=\"${girar_libdir}\" \
	-DGIRAR_SRPMS=\"${GIRAR_SRPMS}\" \
	-DUSER_PREFIX=\"${USER_PREFIX}\"
CFLAGS = -pipe -Wall -O2

bin_auto_TARGETS = \
	bin/girar-sh-config \
	bin/girar-sh-functions \
	#

bin_TARGETS = \
	${bin_auto_TARGETS} \
	bin/find-subscribers \
	bin/girar-acl \
	bin/girar-acl-apply-changes \
	bin/girar-acl-merge-changes \
	bin/girar-acl-notify-changes \
	bin/girar-acl-proxyd \
	bin/girar-acl-show \
	bin/girar-build \
	bin/girar-charset \
	bin/girar-check-acl-item \
	bin/girar-check-acl-leader \
	bin/girar-check-orphaned \
	bin/girar-check-nevr-in-repo \
	bin/girar-check-package-in-repo \
	bin/girar-check-perms \
	bin/girar-check-superuser \
	bin/girar-clone \
	bin/girar-connect-stdout \
	bin/girar-default-branch \
	bin/girar-find \
	bin/girar-get-email-address \
	bin/girar-hooks-sh-functions \
	bin/girar-init-db \
	bin/girar-ls \
	bin/girar-mv-db \
	bin/girar-normalize-repo-name \
	bin/girar-quota \
	bin/girar-repack \
	bin/girar-rm-db \
	bin/girar-sh \
	bin/girar-sh-tmpdir \
	bin/girar-task \
	bin/girar-task-abort \
	bin/girar-task-add \
	bin/girar-task-approve \
	bin/girar-task-change-state \
	bin/girar-task-check-git-inheritance \
	bin/girar-task-delsub \
	bin/girar-task-deps \
	bin/girar-task-find-current \
	bin/girar-task-ls \
	bin/girar-task-make-index-html \
	bin/girar-task-new \
	bin/girar-task-rm \
	bin/girar-task-run \
	bin/girar-task-share \
	bin/girar-task-show \
	bin/girar-task-update-queues \
	#

conf_TARGETS = conf/girar-acl-proxyd

lib_TARGETS = lib/rsync.so

sbin_TARGETS = \
	sbin/girar-add \
	sbin/girar-del \
	sbin/girar-auth-add \
	sbin/girar-auth-zero \
	sbin/girar-build-disable \
	sbin/girar-build-enable \
	sbin/girar-disable \
	sbin/girar-enable \
	sbin/girar-make-template-repos \
	#

hooks_TARGETS = \
	hooks/post-receive \
	hooks/post-update \
	hooks/update \
	#

hooks_update_TARGETS = \
	hooks/update.d/girar-update-check-refs \
	hooks/update.d/girar-update-etc \
	#

hooks_receive_TARGETS = \
	hooks/post-receive.d/girar-etc \
	hooks/post-receive.d/girar-sendmail \
	#

TARGETS = ${bin_TARGETS} ${sbin_TARGETS} ${lib_TARGETS} ${conf_TARGETS} \
	  ${hooks_TARGETS} ${hooks_update_TARGETS} ${hooks_receive_TARGETS}

.PHONY: all clean install install-bin install-conf install-data install-sbin install-var

all: ${TARGETS}

clean:
	${RM} ${bin_auto_TARGETS} ${sbin_TARGETS} ${lib_TARGETS}

install: install-bin install-conf install-data install-lib install-sbin install-var

install-bin: ${bin_TARGETS}
	install -d -m750 ${DESTDIR}${girar_bindir}
	install -pm755 $^ ${DESTDIR}${girar_bindir}/

install-sbin: ${sbin_TARGETS}
	install -d -m755 ${DESTDIR}${girar_sbindir}
	install -pm700 $^ ${DESTDIR}${girar_sbindir}/

install-lib: ${lib_TARGETS}
	install -d -m750 ${DESTDIR}${girar_libdir}
	install -pm644 $^ ${DESTDIR}${girar_libdir}/

install-conf: ${conf_TARGETS}
	install -d -m750 \
		${DESTDIR}${initdir} \
		${DESTDIR}${girar_confdir} \
		${DESTDIR}${girar_acl_pub_dir} \
		${DESTDIR}${girar_acl_state_dir} \
		${DESTDIR}${girar_repo_conf_dir}
	install -pm755 $^ ${DESTDIR}${initdir}/

install-data: ${hooks_TARGETS} ${hooks_update_TARGETS} ${hooks_receive_TARGETS}
	install -d -m750 \
		${DESTDIR}${girar_datadir} \
		${DESTDIR}${girar_hooks_dir} \
		${DESTDIR}${girar_hooks_dir}/update.d \
		${DESTDIR}${girar_hooks_dir}/post-receive.d \
		${DESTDIR}${girar_templates_dir} \
		${DESTDIR}${GIRAR_FAKE_HOME}
	install -pm750 ${hooks_TARGETS} ${DESTDIR}${girar_hooks_dir}/
	install -pm750 ${hooks_update_TARGETS} ${DESTDIR}${girar_hooks_dir}/update.d/
	install -pm750 ${hooks_receive_TARGETS} ${DESTDIR}${girar_hooks_dir}/post-receive.d/
	ln -snf ${girar_hooks_dir} ${DESTDIR}${girar_templates_dir}/hooks

install-var:
	install -d -m750 \
		${DESTDIR}${girar_statedir} \
		${DESTDIR}${girar_email_dir} \
		${DESTDIR}${girar_email_dir}/packages \
		${DESTDIR}${girar_email_dir}/private \
		${DESTDIR}${girar_email_dir}/public \
		${DESTDIR}${girar_runtimedir} \
		${DESTDIR}${girar_runtimedir}/acl \
		${DESTDIR}${girar_spooldir} \
		${DESTDIR}${GB_TASKS} \
		${DESTDIR}${GIRAR_PEOPLE_QUEUE}

install-perms:
	chgrp girar \
		${DESTDIR}${girar_bindir} \
		${DESTDIR}${girar_confdir} \
		${DESTDIR}${girar_datadir} \
		${DESTDIR}${girar_statedir} \
		${DESTDIR}${girar_runtimedir} \
		${DESTDIR}${girar_spooldir}

bin/girar-acl-proxyd: bin/girar-acl-proxyd.c

bin/girar-connect-stdout: bin/girar-connect-stdout.c

bin/girar-sh: bin/girar-sh.c

lib/rsync.so: lib/rsync.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -fpic -shared -ldl -o $@

%: %.in
	sed -e 's,@CMDDIR@,${girar_bindir},g' \
	    -e 's,@EMAIL_DOMAIN@,${EMAIL_DOMAIN},g' \
	    -e 's,@GB_GROUP@,${GB_GROUP},g' \
	    -e 's,@GB_TASKS@,${GB_TASKS},g' \
	    -e 's,@GB_TASKS_DONE_DIR@,${GB_TASKS_DONE_DIR},g' \
	    -e 's,@GIRAR_ACL_PUB_DIR@,${girar_acl_pub_dir},g' \
	    -e 's,@GIRAR_ACL_STATE_DIR@,${girar_acl_state_dir},g' \
	    -e 's,@GIRAR_ACL_SOCKET@,${GIRAR_ACL_SOCKET},g' \
	    -e 's,@GIRAR_ACL_USER@,${GIRAR_ACL_USER},g' \
	    -e 's,@GIRAR_SRPMS@,${GIRAR_SRPMS},g' \
	    -e 's,@GIRAR_EMAIL_ALIASES@,${GIRAR_EMAIL_ALIASES},g' \
	    -e 's,@GIRAR_EMAIL_DIR@,${girar_email_dir},g' \
	    -e 's,@GIRAR_FAKE_HOME@,${GIRAR_FAKE_HOME},g' \
	    -e 's,@GIRAR_GEARS@,${GIRAR_GEARS},g' \
	    -e 's,@GIRAR_HOME@,${GIRAR_HOME},g' \
	    -e 's,@GIRAR_HOOKS_DIR@,${girar_hooks_dir},g' \
	    -e 's,@GIRAR_PACKAGES_DIR@,${girar_confdir}/packages.git,g' \
	    -e 's,@GIRAR_PACKAGES_LIST@,${GIRAR_PACKAGES_LIST},g' \
	    -e 's,@GIRAR_PEOPLE_QUEUE@,${GIRAR_PEOPLE_QUEUE},g' \
	    -e 's,@GIRAR_PRIVATE_DIR@,${girar_confdir}/private.git,g' \
	    -e 's,@GIRAR_PUBLIC_DIR@,${girar_confdir}/public.git,g' \
	    -e 's,@GIRAR_REPO_CONF_DIR@,${girar_repo_conf_dir},g' \
	    -e 's,@GIRAR_REPO_LIST@,${GIRAR_REPO_LIST},g' \
	    -e 's,@GIRAR_TEMPLATES_DIR@,${girar_templates_dir},g' \
	    -e 's,@GITWEB_URL@,${GITWEB_URL},g' \
	    -e 's,@PACKAGES_EMAIL@,${PACKAGES_EMAIL},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
		<$< >$@
	chmod --reference=$< $@
