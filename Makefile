DESTDIR =
datadir = /usr/share
libexecdir = /usr/libexec
localstatedir = /var/lib
lockdir = /var/lock
runtimedir = /var/run
sbindir = /usr/sbin
sysconfdir = /etc
initdir = ${sysconfdir}/rc.d/init.d

ACL_DIR = ${STATE_DIR}/acl
CMD_DIR = ${libexecdir}/girar
CONF_DIR = ${sysconfdir}/girar
EMAIL_ALIASES = ${CONF_DIR}/aliases
EMAIL_DIR = ${STATE_DIR}/email
EMAIL_DOMAIN = altlinux.org
GEARS_DIR = ${STATE_DIR}/gears
GITWEB_URL = http://git.altlinux.org
GIT_TEMPLATE_DIR = ${girar_datadir}/templates
HOOKS_DIR = ${girar_datadir}/hooks
PACKAGES_EMAIL = ALT Devel discussion list <devel@lists.${EMAIL_DOMAIN}>
PEOPLE_DIR = ${STATE_DIR}/people
PLUGIN_DIR = ${libexecdir}/girar
REPO_CONF_DIR = ${CONF_DIR}/repo
REPO_LIST = ${CONF_DIR}/repositories
RUNTIME_DIR = ${runtimedir}/girar
RUN_AS = @RUN_AS@
SOCKDIR = @SOCKDIR@
SOCKGRP = @SOCKGRP@
SRPMS_DIR = ${STATE_DIR}/srpms
STATE_DIR = ${localstatedir}/girar
TASKS_DIR = ${STATE_DIR}/tasks
TASKS_DONE_DIR = ${TASKS_DIR}/archive/done
TASKS_GROUP = tasks
USER_PREFIX = git_
girar_datadir = ${datadir}/girar
girar_lockdir = ${lockdir}/girar
girar_sbindir = ${sbindir}

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS} \
	-DCMD_DIR=\"${CMD_DIR}\" \
	-DGEARS_DIR=\"${GEARS_DIR}\" \
	-DPEOPLE_DIR=\"${PEOPLE_DIR}\" \
	-DPLUGIN_DIR=\"${PLUGIN_DIR}\" \
	-DSRPMS_DIR=\"${SRPMS_DIR}\" \
	-DSOCKDIR=\"${SOCKDIR}\" \
	-DRUN_AS=\"${RUN_AS}\" \
	-DUSER_PREFIX=\"${USER_PREFIX}\"
CFLAGS = -pipe -O2

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
	bin/girar-acl-show \
	bin/girar-build \
	bin/girar-charset \
	bin/girar-check-acl-item \
	bin/girar-check-acl-leader \
	bin/girar-check-nevr-in-repo \
	bin/girar-check-orphaned \
	bin/girar-check-package-in-repo \
	bin/girar-check-perms \
	bin/girar-check-superuser \
	bin/girar-clone \
	bin/girar-default-branch \
	bin/girar-find \
	bin/girar-get-email-address \
	bin/girar-hooks-sh-functions \
	bin/girar-init-db \
	bin/girar-ls \
	bin/girar-mv-db \
	bin/girar-normalize-repo-name \
	bin/girar-proxyd-acl \
	bin/girar-proxyd-depot \
	bin/girar-proxyd-repo \
	bin/girar-quota \
	bin/girar-repack \
	bin/girar-repo-copyself \
	bin/girar-repo-savetree \
	bin/girar-rm-db \
	bin/girar-sh \
	bin/girar-sh-tmpdir \
	bin/girar-socket-forward-acl \
	bin/girar-socket-forward-depot \
	bin/girar-socket-forward-repo \
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

conf_TARGETS = conf/girar-proxyd-acl conf/girar-proxyd-depot conf/girar-proxyd-repo

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
	install -d -m750 ${DESTDIR}${CMD_DIR}
	install -pm755 $^ ${DESTDIR}${CMD_DIR}/

install-sbin: ${sbin_TARGETS}
	install -d -m755 ${DESTDIR}${girar_sbindir}
	install -pm700 $^ ${DESTDIR}${girar_sbindir}/

install-lib: ${lib_TARGETS}
	install -d -m750 ${DESTDIR}${PLUGIN_DIR}
	install -pm644 $^ ${DESTDIR}${PLUGIN_DIR}/

install-conf: ${conf_TARGETS}
	install -d -m750 \
		${DESTDIR}${initdir} \
		${DESTDIR}${CONF_DIR} \
		${DESTDIR}${REPO_CONF_DIR}
	install -pm755 $^ ${DESTDIR}${initdir}/

install-data: ${hooks_TARGETS} ${hooks_update_TARGETS} ${hooks_receive_TARGETS}
	install -d -m750 \
		${DESTDIR}${girar_datadir} \
		${DESTDIR}${HOOKS_DIR} \
		${DESTDIR}${HOOKS_DIR}/update.d \
		${DESTDIR}${HOOKS_DIR}/post-receive.d \
		${DESTDIR}${GIT_TEMPLATE_DIR} \
		#
	install -pm750 ${hooks_TARGETS} ${DESTDIR}${HOOKS_DIR}/
	install -pm750 ${hooks_update_TARGETS} ${DESTDIR}${HOOKS_DIR}/update.d/
	install -pm750 ${hooks_receive_TARGETS} ${DESTDIR}${HOOKS_DIR}/post-receive.d/
	ln -snf ${HOOKS_DIR} ${DESTDIR}${GIT_TEMPLATE_DIR}/hooks

install-var:
	install -d -m750 \
		${DESTDIR}${EMAIL_DIR} \
		${DESTDIR}${EMAIL_DIR}/packages \
		${DESTDIR}${EMAIL_DIR}/private \
		${DESTDIR}${EMAIL_DIR}/public \
		${DESTDIR}${STATE_DIR} \
		${DESTDIR}${STATE_DIR}/acl \
		${DESTDIR}${STATE_DIR}/bull \
		${DESTDIR}${STATE_DIR}/cow \
		${DESTDIR}${STATE_DIR}/depot \
		${DESTDIR}${STATE_DIR}/depot/.tmp \
		${DESTDIR}${STATE_DIR}/depot/{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f}{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f} \
		${DESTDIR}${STATE_DIR}/gears \
		${DESTDIR}${STATE_DIR}/people \
		${DESTDIR}${STATE_DIR}/repo \
		${DESTDIR}${STATE_DIR}/srpms \
		${DESTDIR}${STATE_DIR}/tasks \
		${DESTDIR}${RUNTIME_DIR} \
		${DESTDIR}${RUNTIME_DIR}/acl \
		${DESTDIR}${RUNTIME_DIR}/depot \
		${DESTDIR}${RUNTIME_DIR}/repo \
		${DESTDIR}${girar_lockdir} \
		${DESTDIR}${girar_lockdir}/bull \
		${DESTDIR}${girar_lockdir}/cow \

bin/girar-proxyd-acl conf/girar-proxyd-acl: SOCKDIR = ${RUNTIME_DIR}/acl
bin/girar-proxyd-depot conf/girar-proxyd-depot: SOCKDIR = ${RUNTIME_DIR}/depot
bin/girar-proxyd-repo conf/girar-proxyd-repo: SOCKDIR = ${RUNTIME_DIR}/repo
bin/girar-proxyd-acl conf/girar-proxyd-acl: RUN_AS = acl
bin/girar-proxyd-depot conf/girar-proxyd-depot: RUN_AS = depot
bin/girar-proxyd-repo conf/girar-proxyd-repo: RUN_AS = repo
conf/girar-proxyd-acl: SOCKGRP = girar
conf/girar-proxyd-depot conf/girar-proxyd-repo: SOCKGRP = bull

bin/girar-sh: bin/girar-sh.c

lib/rsync.so: lib/rsync.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -fpic -shared -ldl -o $@

bin/girar-proxyd-acl bin/girar-proxyd-depot bin/girar-proxyd-repo: bin/girar-proxyd.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@

conf/girar-proxyd-acl conf/girar-proxyd-depot conf/girar-proxyd-repo: conf/girar-proxyd.in
	sed -e 's,@CMD_DIR@,${CMD_DIR},g' \
	    -e 's,@RUN_AS@,${RUN_AS},g' \
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SOCKGRP@,${SOCKGRP},g' \
		<$< >$@
	chmod --reference=$< $@

%: %.in
	sed \
	    -e 's,@ACL_DIR@,${ACL_DIR},g' \
	    -e 's,@CMD_DIR@,${CMD_DIR},g' \
	    -e 's,@CONF_DIR@,${CONF_DIR},g' \
	    -e 's,@EMAIL_ALIASES@,${EMAIL_ALIASES},g' \
	    -e 's,@EMAIL_DIR@,${EMAIL_DIR},g' \
	    -e 's,@EMAIL_DOMAIN@,${EMAIL_DOMAIN},g' \
	    -e 's,@GEARS_DIR@,${GEARS_DIR},g' \
	    -e 's,@GITWEB_URL@,${GITWEB_URL},g' \
	    -e 's,@GIT_TEMPLATE_DIR@,${GIT_TEMPLATE_DIR},g' \
	    -e 's,@HOOKS_DIR@,${HOOKS_DIR},g' \
	    -e 's,@PACKAGES_EMAIL@,${PACKAGES_EMAIL},g' \
	    -e 's,@PEOPLE_DIR@,${PEOPLE_DIR},g' \
	    -e 's,@REPO_CONF_DIR@,${REPO_CONF_DIR},g' \
	    -e 's,@REPO_LIST@,${REPO_LIST},g' \
	    -e 's,@RUNTIME_DIR@,${RUNTIME_DIR},g' \
	    -e 's,@RUN_AS@,${RUN_AS},g' \
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SRPMS_DIR@,${SRPMS_DIR},g' \
	    -e 's,@STATE_DIR@,${STATE_DIR},g' \
	    -e 's,@TASKS_DIR@,${TASKS_DIR},g' \
	    -e 's,@TASKS_DONE_DIR@,${TASKS_DONE_DIR},g' \
	    -e 's,@TASKS_GROUP@,${TASKS_GROUP},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
		<$< >$@
	chmod --reference=$< $@
