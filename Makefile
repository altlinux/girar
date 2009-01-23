DESTDIR =
datadir = /usr/share
libexecdir = /usr/libexec
localstatedir = /var/lib
sbindir = /usr/sbin
spooldir = /var/spool
sysconfdir = /etc

girar_bindir = ${libexecdir}/girar
girar_sbindir = ${sbindir}
girar_confdir = ${sysconfdir}/girar
girar_datadir = ${datadir}/girar
girar_spooldir = ${spooldir}/girar
girar_statedir = ${localstatedir}/girar
girar_hooks_dir = ${girar_datadir}/hooks
girar_templates_dir = ${girar_datadir}/templates
girar_packages_dir = ${girar_datadir}/packages.git
girar_private_dir = ${girar_datadir}/private.git
girar_public_dir = ${girar_datadir}/public.git
girar_email_dir = ${girar_statedir}/email
girar_acl_conf_dir = ${girar_confdir}/acl
girar_acl_pub_dir = ${girar_statedir}/acl.pub
girar_acl_state_dir = ${girar_statedir}/acl

EMAIL_DOMAIN = altlinux.org
GB_GROUP = girar-builder
GB_TASKS = ${girar_spooldir}/tasks
GIRAR_ARCHIVE = /archive
GIRAR_EMAIL_ALIASES = ${girar_confdir}/aliases
GIRAR_FAKE_HOME = ${girar_datadir}/home
GIRAR_GEARS = /gears
GIRAR_HOME = /people
GIRAR_PACKAGES_LIST = ${girar_statedir}/people-packages-list
GIRAR_PEOPLE_QUEUE = ${girar_spooldir}/people
GIRAR_REPOSITORIES = ${girar_confdir}/repositories
GITWEB_URL = http://git.altlinux.org
PACKAGES_EMAIL = ALT Devel discussion list <devel@lists.${EMAIL_DOMAIN}>
USER_PREFIX = git_

UPRAVDOM_ACCOUNT = factory
UPRAVDOM_QUEUE = ${spooldir}/build-factory

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS} \
	-DGIRAR_ARCHIVE=\"${GIRAR_ARCHIVE}\" \
	-DGIRAR_BINDIR=\"${girar_bindir}\" \
	-DGIRAR_GEARS=\"${GIRAR_GEARS}\" \
	-DGIRAR_HOME=\"${GIRAR_HOME}\" \
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
	bin/girar-build \
	bin/girar-charset \
	bin/girar-check-acl-leader \
	bin/girar-check-orphaned \
	bin/girar-check-perms \
	bin/girar-clone \
	bin/girar-find \
	bin/girar-hooks-sh-functions \
	bin/girar-init-db \
	bin/girar-ls \
	bin/girar-merge-acl \
	bin/girar-mv-db \
	bin/girar-quota \
	bin/girar-rm-db \
	bin/girar-sh \
	bin/girar-task \
	bin/girar-task-add \
	bin/girar-task-approve \
	bin/girar-task-find-current \
	bin/girar-task-ls \
	bin/girar-task-new \
	bin/girar-task-rm \
	bin/girar-task-run \
	bin/girar-task-share \
	bin/girar-task-show \
	#

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

TARGETS = ${bin_TARGETS} ${sbin_TARGETS} ${hooks_TARGETS} ${hooks_update_TARGETS} ${hooks_receive_TARGETS}

.PHONY: all clean install install-bin install-conf install-data install-sbin install-var

all: ${TARGETS}

clean:
	${RM} ${bin_auto_TARGETS} ${sbin_TARGETS}

install: install-bin install-conf install-data install-sbin install-var

install-bin: ${bin_TARGETS}
	install -d -m750 ${DESTDIR}${girar_bindir}
	install -pm755 $^ ${DESTDIR}${girar_bindir}/

install-sbin: ${sbin_TARGETS}
	install -d -m755 ${DESTDIR}${girar_sbindir}
	install -pm700 $^ ${DESTDIR}${girar_sbindir}/

install-conf:
	install -d -m750 \
		${DESTDIR}${girar_confdir} \
		${DESTDIR}${girar_acl_conf_dir}

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
		${DESTDIR}${girar_acl_state_dir} \
		${DESTDIR}${girar_email_dir} \
		${DESTDIR}${girar_email_dir}/packages \
		${DESTDIR}${girar_email_dir}/private \
		${DESTDIR}${girar_email_dir}/public \
		${DESTDIR}${girar_spooldir} \
		${DESTDIR}${GB_TASKS} \
		${DESTDIR}${GIRAR_PEOPLE_QUEUE} \
		${DESTDIR}${GIRAR_PEOPLE_QUEUE}/.timestamp

install-perms:
	chgrp girar \
		${DESTDIR}${girar_bindir} \
		${DESTDIR}${girar_confdir} \
		${DESTDIR}${girar_datadir} \
		${DESTDIR}${girar_statedir} \
		${DESTDIR}${girar_spooldir}

bin/girar-sh: bin/girar-sh.c

%: %.in
	sed -e 's,@CMDDIR@,${girar_bindir},g' \
	    -e 's,@EMAIL_DOMAIN@,${EMAIL_DOMAIN},g' \
	    -e 's,@GB_GROUP@,${GB_GROUP},g' \
	    -e 's,@GB_TASKS@,${GB_TASKS},g' \
	    -e 's,@GIRAR_ACL_CONF_DIR@,${girar_acl_conf_dir},g' \
	    -e 's,@GIRAR_ACL_PUB_DIR@,${girar_acl_pub_dir},g' \
	    -e 's,@GIRAR_ACL_STATE_DIR@,${girar_acl_state_dir},g' \
	    -e 's,@GIRAR_ARCHIVE@,${GIRAR_ARCHIVE},g' \
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
	    -e 's,@GIRAR_REPOSITORIES@,${GIRAR_REPOSITORIES},g' \
	    -e 's,@GIRAR_TEMPLATES_DIR@,${girar_templates_dir},g' \
	    -e 's,@GITWEB_URL@,${GITWEB_URL},g' \
	    -e 's,@PACKAGES_EMAIL@,${PACKAGES_EMAIL},g' \
	    -e 's,@UPRAVDOM_ACCOUNT@,${UPRAVDOM_ACCOUNT},g' \
	    -e 's,@UPRAVDOM_QUEUE@,${UPRAVDOM_QUEUE},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
		<$< >$@
	chmod --reference=$< $@
