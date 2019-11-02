DESTDIR =
check_dir = /etc/sisyphus_check/check.d
libexecdir = /usr/libexec
localstatedir = /var/lib
lockdir = /var/lock
runtimedir = /var/run
sbindir = /usr/sbin
sysconfdir = /etc
initdir = ${sysconfdir}/rc.d/init.d
sudoers_dir = ${sysconfdir}/sudoers.d

ACL_DIR = ${STATE_DIR}/acl
CMD_DIR = ${libexecdir}/girar
CONF_DIR = ${sysconfdir}/girar
EMAIL_ALIASES = ${CONF_DIR}/aliases
EMAIL_DOMAIN = altlinux.org
GEARS_DIR = /gears
GITWEB_URL = http://git.altlinux.org
WEBAPI_URL = http://192.168.1.13:6080
INCOMING_DIR = ${STATE_DIR}/incoming
MAINTAINERS_GROUP = maintainers
PACKAGES_EMAIL = ALT Devel discussion list <devel@lists.${EMAIL_DOMAIN}>
UPLOAD_DIR = ${STATE_DIR}/upload
PEOPLE_DIR = /people
PLUGIN_DIR = ${libexecdir}/girar
RUNTIME_DIR = ${runtimedir}/girar
PROJECT_PREFIX = @PROJECT_PREFIX@
RUN_AS = @RUN_AS@
SOCKDIR = @SOCKDIR@
SOCKGRP = @SOCKGRP@
SRPMS_DIR = /srpms
STATE_DIR = ${localstatedir}/girar
TASKS_DIR = /tasks
TASKS_GROUP = tasks
USERS_GROUP = girar-users
USER_PREFIX = git_
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
	-DINCOMING_DIR=\"${INCOMING_DIR}\" \
	-DPEOPLE_DIR=\"${PEOPLE_DIR}\" \
	-DPLUGIN_DIR=\"${PLUGIN_DIR}\" \
	-DSRPMS_DIR=\"${SRPMS_DIR}\" \
	-DSOCKDIR=\"${SOCKDIR}\" \
	-DPROJECT_PREFIX=\"${PROJECT_PREFIX}\" \
	-DRUN_AS=\"${RUN_AS}\" \
	-DUSER_PREFIX=\"${USER_PREFIX}\"
CFLAGS = -pipe -O2

bin_TARGETS = \
	bin/girar-acl \
	bin/girar-acl-apply-changes \
	bin/girar-acl-merge-changes \
	bin/girar-acl-notify-changes \
	bin/girar-acl-show \
	bin/girar-build \
	bin/girar-check-acl-item \
	bin/girar-check-acl-leader \
	bin/girar-check-nevr-in-repo \
	bin/girar-check-orphaned \
	bin/girar-check-package-in-repo \
	bin/girar-check-perms \
	bin/girar-check-sid \
	bin/girar-check-superuser \
	bin/girar-get-email-address \
	bin/girar-gpg \
	bin/girar-normalize-repo-name \
	bin/girar-quota \
	bin/girar-repo-copyself \
	bin/girar-repo-savetree \
	bin/girar-scrap-stale-tasks \
	bin/girar-sh \
	bin/girar-sh-config \
	bin/girar-sh-functions \
	bin/girar-sh-json-functions \
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
	bin/girar-task-check-subtask-perms \
	bin/girar-task-delsub \
	bin/girar-task-deps \
	bin/girar-task-find-current \
	bin/girar-task-ls \
	bin/girar-task-make-index-html \
	bin/girar-task-make-info-json \
	bin/girar-task-new \
	bin/girar-task-rm \
	bin/girar-task-run \
	bin/girar-task-share \
	bin/girar-task-show \
	bin/girar-task-update-queues \
	bin/girar-webapi-subtask \
	bin/girar-webapi-task
	#

check_TARGETS = check/091-check-arepo check/101-check-policydeps

init_TARGETS = init/girar-proxyd-acl init/girar-proxyd-depot init/girar-proxyd-repo

lib_TARGETS = lib/rsync.so

admin_TARGETS = \
	admin/girar-add \
	admin/girar-admin-sh-functions \
	admin/girar-auth-add \
	admin/girar-auth-zero \
	admin/girar-branch-gears-from-rip \
	admin/girar-branch-rip \
	admin/girar-clone-repo \
	admin/girar-del \
	admin/girar-disable \
	admin/girar-enable \
	admin/girar-maintainer-add \
	admin/girar-maintainer-del \
	#

sbin_TARGETS = \
	sbin/girar-proxyd-acl \
	sbin/girar-proxyd-depot \
	sbin/girar-proxyd-repo \
	#

sudoers_TARGETS = sudoers/girar

TARGETS = \
	${admin_TARGETS} \
	${bin_TARGETS} \
	${init_TARGETS} \
	${lib_TARGETS} \
	${sbin_TARGETS} \
	${sudoers_TARGETS} \
	#

install-TARGETS = install-bin install-check install-data install-init \
		  install-lib install-sbin install-sudoers install-var

GA_TARGETS = ${GA_sbin_TARGETS} ${GA_init_TARGETS}
GA-install-TARGETS = GA-install-sbin GA-install-init GA-install-var

.PHONY: all install ${install-TARGETS} ${GA-install-TARGETS}

all: ${TARGETS} ${GA_TARGETS}

install: ${install-TARGETS} ${GA-install-TARGETS}

install-bin: ${bin_TARGETS}
	install -d -m750 ${DESTDIR}${CMD_DIR}
	install -pm755 $^ ${DESTDIR}${CMD_DIR}/
	ln -s girar-task-approve ${DESTDIR}${CMD_DIR}/girar-task-disapprove

install-check: ${check_TARGETS}
	install -d -m755 ${DESTDIR}${check_dir}
	install -pm644 $^ ${DESTDIR}${check_dir}/

install-init: ${init_TARGETS}
	install -d -m750 \
		${DESTDIR}${initdir} \
		${DESTDIR}${CONF_DIR} \
		${DESTDIR}${CONF_DIR}/repo \
		#
	install -pm755 $^ ${DESTDIR}${initdir}/

install-lib: ${lib_TARGETS}
	install -d -m750 ${DESTDIR}${PLUGIN_DIR}
	install -pm644 $^ ${DESTDIR}${PLUGIN_DIR}/

install-sbin: ${admin_TARGETS} ${sbin_TARGETS}
	install -d -m755 ${DESTDIR}${girar_sbindir}
	install -pm700 $^ ${DESTDIR}${girar_sbindir}/

install-sudoers: ${sudoers_TARGETS}
	install -d -m700 ${DESTDIR}${sudoers_dir}
	install -pm400 $^ ${DESTDIR}${sudoers_dir}/

install-var:
	install -d -m750 \
		${DESTDIR}${INCOMING_DIR} \
		${DESTDIR}${RUNTIME_DIR} \
		${DESTDIR}${RUNTIME_DIR}/acl \
		${DESTDIR}${RUNTIME_DIR}/depot \
		${DESTDIR}${RUNTIME_DIR}/repo \
		${DESTDIR}${STATE_DIR} \
		${DESTDIR}${STATE_DIR}/acl \
		${DESTDIR}${STATE_DIR}/awaiter \
		${DESTDIR}${STATE_DIR}/awaiter/.cache \
		${DESTDIR}${STATE_DIR}/awaiter/.qa-cache \
		${DESTDIR}${STATE_DIR}/awaiter/.qa-cache/rpmelfsym \
		${DESTDIR}${STATE_DIR}/depot \
		${DESTDIR}${STATE_DIR}/depot/.tmp \
		${DESTDIR}${STATE_DIR}/depot/{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f}{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f} \
		${DESTDIR}${STATE_DIR}/pender \
		${DESTDIR}${STATE_DIR}/repo \
		${DESTDIR}${STATE_DIR}/symlinkery \
		${DESTDIR}${STATE_DIR}/upload/{copy,lockdir,log} \
		${DESTDIR}${TASKS_DIR} \
		${DESTDIR}${TASKS_DIR}/stale \
		${DESTDIR}${TASKS_DIR}/index \
		${DESTDIR}${girar_lockdir} \
		${DESTDIR}${girar_lockdir}/awaiter \
		${DESTDIR}${girar_lockdir}/pender \
		${DESTDIR}/gears \
		${DESTDIR}/srpms \
		#

init/girar-proxyd-acl: SOCKGRP = girar
init/girar-proxyd-depot init/girar-proxyd-repo: SOCKGRP = pender

init/girar-proxyd-acl sbin/girar-proxyd-acl: RUN_AS = acl
init/girar-proxyd-depot sbin/girar-proxyd-depot: RUN_AS = depot
init/girar-proxyd-repo sbin/girar-proxyd-repo: RUN_AS = repo

init/girar-proxyd-acl sbin/girar-proxyd-acl: SOCKDIR = ${RUNTIME_DIR}/acl
init/girar-proxyd-depot sbin/girar-proxyd-depot: SOCKDIR = ${RUNTIME_DIR}/depot
init/girar-proxyd-repo sbin/girar-proxyd-repo: SOCKDIR = ${RUNTIME_DIR}/repo

bin/girar-sh: bin/girar-sh.c

lib/rsync.so: lib/rsync.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -fpic -shared -ldl -o $@

sbin/girar-proxyd-acl sbin/girar-proxyd-depot sbin/girar-proxyd-repo: PROJECT_PREFIX = girar
sbin/girar-proxyd-acl sbin/girar-proxyd-depot sbin/girar-proxyd-repo: sbin/girar-proxyd.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@

init/girar-proxyd-acl init/girar-proxyd-depot init/girar-proxyd-repo: init/girar-proxyd.in
	sed -e 's,@CMD_DIR@,${CMD_DIR},g' \
	    -e 's,@RUN_AS@,${RUN_AS},g' \
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SOCKGRP@,${SOCKGRP},g' \
	    -e 's,@PROJECT_PREFIX@,girar,g' \
		<$< >$@
	chmod --reference=$< $@

%: %.in
	sed \
	    -e 's,@ACL_DIR@,${ACL_DIR},g' \
	    -e 's,@CMD_DIR@,${CMD_DIR},g' \
	    -e 's,@CONF_DIR@,${CONF_DIR},g' \
	    -e 's,@EMAIL_ALIASES@,${EMAIL_ALIASES},g' \
	    -e 's,@EMAIL_DOMAIN@,${EMAIL_DOMAIN},g' \
	    -e 's,@GEARS_DIR@,${GEARS_DIR},g' \
	    -e 's,@GITWEB_URL@,${GITWEB_URL},g' \
	    -e 's,@INCOMING_DIR@,${INCOMING_DIR},g' \
	    -e 's,@PACKAGES_EMAIL@,${PACKAGES_EMAIL},g' \
	    -e 's,@PEOPLE_DIR@,${PEOPLE_DIR},g' \
	    -e 's,@RUNTIME_DIR@,${RUNTIME_DIR},g' \
	    -e 's,@RUN_AS@,${RUN_AS},g' \
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SRPMS_DIR@,${SRPMS_DIR},g' \
	    -e 's,@STATE_DIR@,${STATE_DIR},g' \
	    -e 's,@TASKS_DIR@,${TASKS_DIR},g' \
	    -e 's,@TASKS_GROUP@,${TASKS_GROUP},g' \
	    -e 's,@MAINTAINERS_GROUP@,${MAINTAINERS_GROUP},g' \
	    -e 's,@UPLOAD_DIR@,${UPLOAD_DIR},g' \
	    -e 's,@USERS_GROUP@,${USERS_GROUP},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
	    -e 's,@WEBAPI_URL@,${WEBAPI_URL},g' \
		<$< >$@
	chmod --reference=$< $@

# GA
GA_BIN_DIR = ${libexecdir}/girar-archiver
GA_SBIN_DIR = ${sbindir}
GA_LOG_DIR = /var/log/girar-archiver
GA_RUNTIME_DIR = ${runtimedir}/girar-archiver
GA_KICKER_DIR = ${GA_RUNTIME_DIR}/kicker
GA_STATE_DIR = ${localstatedir}/girar-archiver

GA_CPPFLAGS = -std=gnu99 ${WARNINGS} \
	      -DGA_KICKER_DIR=\"${GA_KICKER_DIR}\" \
	      -DCMD_DIR=\"${GA_BIN_DIR}\" \
	      -DRUN_AS=\"${RUN_AS}\" \
	      -DPROJECT_PREFIX=\"${PROJECT_PREFIX}\" \
	      -DSOCKDIR=\"${SOCKDIR}\"

GA_sbin_TARGETS = ga/ga_kicker-sh ga/ga-proxyd-ga_depot ga/ga-proxyd-ga_repo
GA_init_TARGETS = ga/init/ga-proxyd-ga_depot ga/init/ga-proxyd-ga_repo

ga/ga_kicker-sh: CPPFLAGS = ${GA_CPPFLAGS}
ga/ga_kicker-sh: ga/ga_kicker-sh.c

ga/init/ga-proxyd-ga_depot ga/init/ga-proxyd-ga_repo: SOCKGRP = ga_tasker

ga/init/ga-proxyd-ga_depot ga/ga-proxyd-ga_depot: RUN_AS = ga_depot
ga/init/ga-proxyd-ga_repo ga/ga-proxyd-ga_repo: RUN_AS = ga_repo

ga/init/ga-proxyd-ga_depot ga/ga-proxyd-ga_depot: SOCKDIR = ${GA_RUNTIME_DIR}/depot
ga/init/ga-proxyd-ga_repo ga/ga-proxyd-ga_repo: SOCKDIR = ${GA_RUNTIME_DIR}/repo

ga/ga-proxyd-ga_depot ga/ga-proxyd-ga_repo: CPPFLAGS = ${GA_CPPFLAGS}
ga/ga-proxyd-ga_depot ga/ga-proxyd-ga_repo: PROJECT_PREFIX = ga
ga/ga-proxyd-ga_depot ga/ga-proxyd-ga_repo: ga/ga-proxyd.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@

ga/init/ga-proxyd-ga_depot ga/init/ga-proxyd-ga_repo: ga/init/ga-proxyd.in
	sed -e 's,@CMD_DIR@,${GA_BIN_DIR},g' \
	    -e 's,@RUN_AS@,${RUN_AS},g' \
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SOCKGRP@,${SOCKGRP},g' \
	    -e 's,@PROJECT_PREFIX@,ga,g' \
		<$< >$@
	chmod --reference=$< $@

GA-install-sbin: ${GA_sbin_TARGETS}
	install -d -m755 ${DESTDIR}${GA_SBIN_DIR}
	install -pm700 $^ ${DESTDIR}${GA_SBIN_DIR}/

GA-install-init: ${GA_init_TARGETS}
	install -d -m750 ${DESTDIR}${initdir}
	install -pm755 $^ ${DESTDIR}${initdir}/

GA-install-var:
	install -d -m750 \
		${DESTDIR}${GA_LOG_DIR} \
		${DESTDIR}${GA_RUNTIME_DIR} \
		${DESTDIR}${GA_RUNTIME_DIR}/depot \
		${DESTDIR}${GA_RUNTIME_DIR}/repo \
		${DESTDIR}${GA_KICKER_DIR} \
		${DESTDIR}${GA_STATE_DIR} \
		${DESTDIR}${GA_STATE_DIR}/attic \
		${DESTDIR}${GA_STATE_DIR}/depot \
		${DESTDIR}${GA_STATE_DIR}/depot/.tmp \
		${DESTDIR}${GA_STATE_DIR}/depot/{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f}{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f} \
		${DESTDIR}${GA_STATE_DIR}/repo \
		${DESTDIR}${GA_STATE_DIR}/repo/sisyphus \
		${DESTDIR}${GA_STATE_DIR}/repo/sisyphus/{.tmp,date,task} \
		${DESTDIR}${GA_STATE_DIR}/symlinkery \
		${DESTDIR}${GA_STATE_DIR}/tasker \
		${DESTDIR}${GA_STATE_DIR}/tasks \
		${DESTDIR}${GA_STATE_DIR}/tasks/{.tmp,done} \
		${DESTDIR}${GA_STATE_DIR}/upload/{copy,lockdir,log} \
		#
