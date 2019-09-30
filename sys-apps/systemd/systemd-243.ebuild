# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# Based in part upon 'systemd-242-r6.ebuild' from Gentoo, which is:
#     Copyright 2011-2019 Gentoo Authors

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_PROJ="${PN}-stable"
# https://github.com/systemd/systemd-stable/commits/v243-stable
GITHUB_REF="fab6f01"  # 2019-09-18

## python-.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )

## functions: dsf:eval
inherit dsf-utils

## functions: rindeal:prefix_flags
inherit rindeal-utils

## functions: github:src_unpack
## variables: GITHUB_HOMEPAGE, GITHUB_SRC_URI
inherit github

## EXPORT_FUNCTIONS: pkg_setup
inherit python-any-r1

## EXPORT_FUNCTIONS: pkg_setup
inherit linux-info

## functions: archive:tar:unpack
inherit archive-utils

## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

## functions: getpam_mod_dir
inherit pam

## functions: get_bashcompdir
inherit bash-completion-r1

## functions: systemd_update_catalog
inherit systemd

## functions: get_udevdir, udev_reload
inherit udev

DESCRIPTION="System and service manager for Linux"
HOMEPAGE_A=(
	"https://www.freedesktop.org/wiki/Software/systemd"
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	# ```README:
	#         LGPLv2.1+ for all code
	#         - except src/basic/MurmurHash2.c which is Public Domain
	#         - except src/basic/siphash24.c which is CC0 Public Domain
	#         - except src/journal/lookup3.c which is Public Domain
	#         - except src/udev/* which is (currently still) GPLv2, GPLv2+
	# ```
	'LGPL-2.1-or-later' # most of the code
	'GPL-2.0-only'      # udev
	'GPL-2.0-or-later'  # udev
	'public-domain'     # MurmurHash2, siphash24, lookup3
	'CC0-1.0'           # `src/basic/siphash24.c`

	'MIT'  # some other code not described in the README file
)

# The subslot versioning follows the Gentoo repo.
# Explanation: "incremented for ABI breaks in libudev or libsystemd".
SLOT="0/2"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
	## NOTE >> remember to bump debian patches as well << NOTE
	"https://snapshot.debian.org/archive/debian/20190922T150956Z/pool/main/s/systemd/systemd_243-2.debian.tar.xz"
)

KEYWORDS="~amd64 ~arm ~arm64"
## BEGIN: IUSE
IUSE_A=(
	# NOTE: order of USE-flags is not the same as in meson_options.txt

	+split-usr
	+split-bin
	link-udev-shared
	link-systemctl-shared  # this is quite dangerous, this will brake systemctl on updates
	static-libsystemd
	static-libudev

	memory-accounting-default
	bump-proc-sys-fs-file-max
	bump-proc-sys-fs-nr-open
	valgrind
	log-trace

	+utmp
	hibernate
	+ldconfig
	+resolved
		+resolvconf  # install `resolvconf` symlink to resolvectl
		+nss-resolve
	+efi
		efi-boot-manager
	tpm
	+environment-d
	+binfmt
	+coredump
		stacktrace
	+pstore
	+logind
	+hostnamed
	+localed
		+xkb
	+machined
		+nss-mymachines
	+portabled
	+networkd
	+timedated
	+timesyncd
	remote
	+nss-myhostname
	+nss-systemd
	firstboot
	+random-seed
	+backlight
	+vconsole
	quotacheck
	+sysusers
	+tmpfiles
	importd
	+hwdb
	+rfkill
	man

	adm-group-acl
	wheel-group-acl
	default-kill-user-processes
	+gshadow

	seccomp
	selinux
	apparmor
	smack
	polkit
	ima

	acl
	audit
	+blkid  # should be always enabled unless embedded
	+kmod  # should be always enabled unless embedded
	pam
	cryptsetup
	iptables
	idn
	zlib
	bzip2
	lzma
	lz4
	pcre2

	# ------ custom flags below

	journal-fss  # journal Forward Seal Secrecy

	nls

	+sysv-utils

	dnssec
		$(rindeal:prefix_flags    \
			dnssec_default_       \
				yes               \
				+allow-downgrade  \
				no                \
		)
	dns-over-tls
		$(rindeal:prefix_flags    \
			dot_                  \
				gnutls            \
				+openssl          \
		)
		$(rindeal:prefix_flags    \
			dot_default_          \
				yes               \
				+opportunistic    \
				no                \
		)

	$(rindeal:prefix_flags        \
		default_cgroup_hierarchy_ \
			legacy                \
			hybrid                \
			+unified              \
	)
)
## END: IUSE

## BEGIN: Dependencies
declare -r -A my_deps=(
	['curl']="
		net-misc/curl:0=
	"
	['gnutls']="
		net-libs/gnutls:0=
	"
	['gcrypt']="
		dev-libs/libgcrypt:0=
		dev-libs/libgpg-error:0=
	"
)
CDEPEND_A=(
	# `libmount = dependency('mount',`
	"sys-apps/util-linux:0=[libmount]"

	# `libcap = dependency('libcap'`
	"sys-libs/libcap:0="

	"seccomp?  ( sys-libs/libseccomp:0= )"
	"selinux?  ( sys-libs/libselinux:0= )"
	"apparmor? ( sys-libs/libapparmor:0= )"
	"acl?      ( sys-apps/acl:0= )"
	"audit?    ( sys-process/audit:0= )"
	"blkid?    ( sys-apps/util-linux:0=[libblkid] )"
	"kmod?     ( sys-apps/kmod:0= )"
	"pam?      ( virtual/pam:0= )"
	"remote? ("
		"net-libs/libmicrohttpd:0="
		"${my_deps['curl']}"
		"${my_deps['gnutls']}"
	")"
	"cryptsetup? ( sys-fs/cryptsetup:0= )"
	"importd? ("
		"${my_deps['curl']}"
		"${my_deps['gcrypt']}"
	")"
	"iptables? ( net-firewall/iptables:0= )"
	"journal-fss? ( ${my_deps['gcrypt']} )"
	"resolved? ("
		"dnssec? ( ${my_deps['gcrypt']} )"
		"dns-over-tls? ("
			"dot_gnutls?  ( ${my_deps['gnutls']} )"
			"dot_openssl? ( >=dev-libs/openssl-1.1.0:0= )"
		")"
		"idn? ( net-dns/libidn2:0= )"
	")"
	"$(dsf:eval \
		"coredump & stacktrace" \
			"dev-libs/elfutils:0="
	)"
	"zlib?  ( sys-libs/zlib:0= )"
	"bzip2? ( app-arch/bzip2:0= )"
	"lzma?  ( app-arch/xz-utils:0= )"
	"lz4?   ( app-arch/lz4:0= )"
	"$(dsf:eval \
		"localed & xkb" \
			"x11-libs/libxkbcommon:0="
	)"
	"pcre2? ( dev-libs/libpcre2:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-kernel/linux-headers:*"

	"${PYTHON_DEPS}"
	"sys-apps/sed:*"
	"virtual/awk:*"
	"sys-devel/m4:*"
	# `find_program('gperf')`
	"dev-util/gperf:*"

	"man? ("
		# xsltproc
		"dev-libs/libxslt:*"
		# lxml is for generating the man page index
		"$(python_gen_any_dep 'dev-python/lxml:*[${PYTHON_USEDEP}]')"
		"app-text/docbook-xml-dtd:4.2"
		# `"-//OASIS//DTD DocBook XML V4.5//EN"`
		"app-text/docbook-xml-dtd:4.5"
		# `manpages/docbook.xsl`
		"app-text/docbook-xsl-stylesheets:*"
	")"
	"$(dsf:eval \
		"efi & efi-boot-manager" \
			"sys-boot/gnu-efi:*"
	)"
	# utils for compiling localization files
	"nls? ( sys-devel/gettext:* )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"acct-group/adm"
	"acct-group/wheel"
	"acct-group/kmem"
	"acct-group/tty"
	"acct-group/utmp"
	"acct-group/audio"
	"acct-group/cdrom"
	"acct-group/dialout"
	"acct-group/disk"
	"acct-group/input"
	"acct-group/kvm"
	"acct-group/render"
	"acct-group/tape"
	"acct-group/video"
	"acct-group/systemd-journal"
	"acct-user/systemd-journal-remote"
	"acct-user/systemd-coredump"
	"acct-user/systemd-network"
	"acct-user/systemd-resolve"
	"acct-user/systemd-timesync"

	">=sys-apps/baselayout-2.2"

	"selinux? ( sec-policy/selinux-base-policy[systemd] )"
	"nss-myhostname? ( !sys-auth/nss-myhostname )" # bundled since 197
	"sysv-utils? ( !sys-apps/sysvinit )"
	"resolvconf? ( !net-dns/openresolv )"

	"!<sys-kernel/dracut-044"
	## udev is now part of systemd
	"!sys-fs/eudev"
	"!sys-fs/udev"
)
PDEPEND_A=(
	"polkit? ( sys-auth/polkit[systemd,introspection] )"

	# Gentoo specific suplement of bundled hwdb.d rules + some more
	# Use that instead of systemd's bundled ones.
	"hwdb? ( sys-apps/hwids[udev] )"
	# ">=sys-fs/udev-init-scripts-25" # required for systemd+OpenRC support only
# 	"!vanilla?	( sys-apps/gentoo-systemd-integration )"
)
## END: Dependencies

REQUIRED_USE_A=(
	"efi? ( blkid )"

	# systemd-journal-remote requires systemd-sysusers
	"remote? ( sysusers )"
)

inherit arrays

L10N_LOCALES=( be be@latin bg ca cs da de el es fr gl hr hu id it ja ko lt pl pt_BR ro ru sk sr sv tr uk zh_CN zh_TW )
inherit l10n-r1

MY_DEB_PATCH_DIR="${WORKDIR}/debian-patches"

my_get_rootprefix()
{
	if ! [[ -v _MY_ROOTPREFIX ]]
	then
		declare -g -r -- _MY_ROOTPREFIX="$(usex split-usr "" "/usr")"
	fi
	printf -- "%s" "${_MY_ROOTPREFIX}"
}

pkg_pretend()
{
	if [[ -n "${EPREFIX}" ]]
	then
		die "Gentoo Prefix is not supported"
	fi

	if [[ "${MERGE_TYPE}" != buildonly ]]
	then
		if linux_config_exists
		then
			local -r -- uevent_helper_path="$(linux_chkconfig_string UEVENT_HELPER_PATH)"
			if [[ -n "${uevent_helper_path}" ]] && [[ "${uevent_helper_path}" != '""' ]] ; then
				ewarn "Legacy hotplug slows down the system and confuses udev."
				ewarn "It's recommended to set an empty value to the following kernel config option:"
				ewarn "CONFIG_UEVENT_HELPER_PATH=\"${uevent_helper_path}\""
			fi
		fi

		local CONFIG_CHECK_A=(
			##
			'~DEVTMPFS'
			'~CGROUPS'
			'~INOTIFY_USER'
			'~SIGNALFD'
			'~TIMERFD'
			'~EPOLL'
			'~NET'
			'~SYSFS'
			'~PROC_FS'
			'~FHANDLE'

			"~CRYPTO_USER_API_HASH"
			"~CRYPTO_HMAC"
			"~CRYPTO_SHA256"

			## udev will fail with the deprecated layout present
			'~!SYSFS_DEPRECATED'
			'~!SYSFS_DEPRECATED_V2'

			## Userspace firmware loading is not supported
			'~!FW_LOADER_USER_HELPER'

			## Required for PrivateNetwork= and PrivateDevices=
			'~NET_NS'
			"$(kernel_is -lt 4 7 &>/dev/null && echo '~DEVPTS_MULTIPLE_INSTANCES')"

			# Required for PrivateUsers= in service units:
			"~CONFIG_USER_NS"

			## Required for CPUShares= in resource control unit settings
			'~CGROUP_SCHED'
			'~FAIR_GROUP_SCHED'

			## Required for CPUQuota= in resource control unit settings
			'~CFS_BANDWIDTH'

			## optional
			# Some udev rules and virtualization detection relies on it
			'~DMIID'

			## Support for some SCSI devices serial number retrieval, to
			## create additional symlinks in /dev/disk/ and /dev/tape:
			'~BLK_DEV_BSG'

			## Required for IPAddressDeny= and IPAddressAllow= in resource control unit settings
			"~CGROUP_BPF"

			# ipv6
			'~IPV6'

			# if deselected, systemd issues warning on each boot, but otherwise works the same
			'~AUTOFS4_FS'

			# acl
			'~TMPFS_XATTR'
			"$(use acl && echo '~TMPFS_POSIX_ACL')"
			# seccomp
			"$(use seccomp && echo '~SECCOMP')"
			# for the kcmp() syscall
			'~CHECKPOINT_RESTORE'

			# efi
			"$(use efi && echo '~EFIVAR_FS ~EFI_PARTITION')"

			# real-time group scheduling - see 'README'
			'~!RT_GROUP_SCHED'

			# systemd doesn't like it - see 'README'
			'~!AUDIT'
		)

		CONFIG_CHECK="${CONFIG_CHECK_A[*]}"

		check_extra_config
	fi
}

pkg_setup()
{
	linux-info_pkg_setup
	python-any-r1_pkg_setup

	# check if get_udevdir() returns sane value
	local udevdir="$(get_udevdir)"
	if [[ "${udevdir}" == *"/lib/udev"*"/lib/udev"* ]]
	then
		die "Insane value: get_udevdir() => '${udevdir}'"
	fi
}

src_unpack()
{
	github:src_unpack
	archive:tar:unpack --strip-components=3 debian/patches/debian -- \
		"${DISTDIR}"/${PN}_${PV}*.debian.tar.xz "${MY_DEB_PATCH_DIR}"
}

src_prepare-locales()
{
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	if use nls
	then
		l10n_get_locales locales app off
		for l in ${locales}
		do
			rrm "${dir}/${pre}${l}${post}"
			rsed -e "/${l}/d" -i -- "${dir}/LINGUAS"

			rrm "catalog/systemd.${l}.catalog.in"
			rsed -e "/systemd.${l}.catalog/d" -i -- catalog/meson.build
		done
	else
		rrm -r "${dir}"
		rsed -e "/subdir.*'po'/d" -i -- meson.build

		rrm "catalog/systemd."*".catalog.in"
		rsed -e "/systemd.[^.]*.catalog/d" -i -- catalog/meson.build
	fi
}

src_prepare()
{
	# BEGIN - Custom patches
	# END - Custom patches

	# BEGIN - Debian patches
	local -r -a deb_patches=(
# 		Add-env-variable-for-machine-ID-path.patch
# 		Add-support-for-TuxOnIce-hibernation.patch
# 		Bring-tmpfiles.d-tmp.conf-in-line-with-Debian-defaul.patch
		Don-t-enable-audit-by-default.patch
# 		Drop-seccomp-system-call-filter-for-udev.patch
		Let-graphical-session-pre.target-be-manually-started.patch
# 		Make-run-lock-tmpfs-an-API-fs.patch
		Only-start-logind-if-dbus-is-installed.patch
# 		Re-enable-journal-forwarding-to-syslog.patch
		Revert-core-enable-TasksMax-for-all-services-by-default-a.patch
		Revert-core-one-step-back-again-for-nspawn-we-actual.patch
		Revert-core-set-RLIMIT_CORE-to-unlimited-by-default.patch
		Skip-filesystem-check-if-already-done-by-the-initram.patch
# 		Use-Debian-specific-config-files.patch
# 		fsckd-daemon-for-inter-fsckd-communication.patch
	)
	local p
	for p in "${deb_patches[@]}"
	do
		eapply "${MY_DEB_PATCH_DIR}/${p}"
	done
	# END - Debian patches

	# BEGIN - User patches
	eapply_user
	# END - User patches

	# BEGIN - Scripted modifications
	rsed -r -e "s|^(udevlibexecdir *= *).*|\1'$(get_udevdir)'|" -i -- meson.build

	local -a meson_scripts_to_null=(
		"tools/add-git-hook.sh"
		"tools/meson-check-api-docs.sh"
	)
	local -- s
	for s in "${meson_scripts_to_null[@]}"
	do
		printf "#!/bin/true\n\n" >"${s}"
	done

	rsed -r -e "/('-fdiagnostics-[^']*'|'-fstack-protector[^']*'|'--param=ssp-[^']*')/d" -i -- meson.build

	# do not install LICENSE files
	rsed -r -e "s|'LICENSE.[^']*',||" -i -- meson.build

	# Avoid the log bloat to the user
	rsed -e 's|#SystemMaxUse=|SystemMaxUse=500M|' -i -- src/journal/journald.conf
	# END - Scripted modifications

	src_prepare-locales
}

src_configure()
{
	my_str_opt()
	{
		(( ${#} < 1 )) && die
		local -r -- opt_arg="${1}"
		local -r -- var_arg="${2}"
		local -r -- def_arg="${3}"

		local varname="${var_arg}"
		if [[ -z "${varname}" ]]
		then
			varname="${opt_arg}"
			varname="${varname//-/_}"
			varname="${varname^^}"
			varname="SYSTEMD_${varname}"
		fi

		if (( ${#} == 3 )) && ! [[ -v "${varname}" ]]
		then
			declare -r "${varname}=${def_arg}"
		fi

		if ! [[ -v "${varname}" ]]
		then
			return 0
		fi

		printf -- "-D%s=%s\n" "${opt_arg}" "${!varname}"
	}

	my_use_combo()
	{
		(( ${#} != 2 )) && die
		local -- opt_name="${1}"
		local -- use_prefix="${2}"

		local -- haystack=" ${USE} "
		[[ "${haystack}" =~ " "${use_prefix}([a-zA-Z0-9_-]+)" " ]] || die
		printf -- "-D %s=%s\n" "${opt_name}" "${BASH_REMATCH[1]}"
	}

	local -r -a default_nameservers=(
		1.1.1.1   # Cloudflare
		9.9.9.10  # Quad9
		8.8.8.8   # Google
		2606:4700:4700::1111  # Cloudflare
		2620:fe::10           # Quad9
		2001:4860:4860::8888  # Google
	)
	local -r -a default_timeservers=(
		"$(echo {0..3}".gentoo.pool.ntp.org")"
	)
	local -r -- default_support_url="https://github.com/rindeal/rindeal-ebuild-repo/issues"

	## BEGIN: emesonargs
	local -a emesonargs=(
		# override for some reason
		--localstatedir="/var"

		-D version-tag="${PVR}"

		$(meson_use split-usr)
		$(meson_use split-bin)
# 		-D rootlibdir="$(my_get_rootprefix)/$(get_libdir)"
		-D rootprefix="$(my_get_rootprefix)"
		$(meson_use link-udev-shared)
		$(meson_use link-systemctl-shared)
		$(meson_use static-libsystemd)
		$(meson_use static-libudev)

		## disable sysv compatibility
		-D sysvinit-path=""
		-D sysvrcnd-path=""
		# Avoid infinite exec recursion, gentoo#642724
		-D telinit-path="/lib/sysvinit/telinit"
# 		-D rc-local="/etc/rc.local"  # NOTE: to be deprecated

		"$(my_str_opt quotaon-path)"
		"$(my_str_opt quotacheck-path)"
		"$(my_str_opt kmod-path SYSTEMD_KMOD_PATH "/bin/kmod")"
		"$(my_str_opt kexec-path)"
		"$(my_str_opt sulogin-path SYSTEMD_SULOGIN_PATH "/sbin/sulogin")"
		"$(my_str_opt mount-path SYSTEMD_MOUNT_PATH "/bin/mount")"
		"$(my_str_opt umount-path SYSTEMD_UMOUNT_PATH "/bin/umount")"
		"$(my_str_opt loadkeys-path)"
		"$(my_str_opt setfont-path)"
		"$(my_str_opt nologin-path SYSTEMD_NOLOGIN_PATH "/sbin/nologin")"

		"$(my_str_opt debug-shell)"  # `path to debug shell binary`
		"$(my_str_opt debug-tty)"  # `specify the tty device for debug shell`
		"$(my_str_opt debug-extra)"  # `enable extra debugging`
		$(meson_use memory-accounting-default)
		$(meson_use bump-proc-sys-fs-file-max)
		$(meson_use bump-proc-sys-fs-nr-open)
		$(meson_use valgrind)
		$(meson_use log-trace)

		$(meson_use utmp)
		$(meson_use hibernate)
		$(meson_use ldconfig)
		$(meson_use resolved resolve)
		$(meson_use efi)
		$(meson_use tpm)
		$(meson_use environment-d)
		$(meson_use binfmt)
		$(meson_use coredump)
		$(meson_use pstore)
		$(meson_use logind)
		$(meson_use hostnamed)
		$(meson_use localed)
		$(meson_use machined)
		$(meson_use portabled)
		$(meson_use networkd)
		$(meson_use timedated)
		$(meson_use timesyncd)
		$(meson_use remote)
		-D create-log-dirs=true  # `create /var/log/journal{,/remote}`
		$(meson_use nss-myhostname)
		-D nss-mymachines=false  # override down the road as needed
		-D nss-resolve=false     # override down the road as needed
		$(meson_use nss-systemd)
		$(meson_use firstboot)
		$(meson_use random-seed randomseed)
		$(meson_use backlight)
		$(meson_use vconsole)
		$(meson_use quotacheck)
		$(meson_use sysusers)
		$(meson_use tmpfiles)
		$(meson_use importd)
		$(meson_use hwdb)
		$(meson_use rfkill)
		$(meson_use man)
		-D html=false  # no need for this

# 		$(my_str_opt certificate-root)
# 		$(my_str_opt dbuspolicydir)
# 		$(my_str_opt dbussessionservicedir)
# 		$(my_str_opt dbussystemservicedir)
# 		$(my_str_opt pkgconfigdatadir)
		-D pkgconfigdatadir=
# 		$(my_str_opt pkgconfiglibdir)
# 		$(my_str_opt rpmmacrosdir)
		-D pamlibdir="$(getpam_mod_dir)"
# 		$(my_str_opt pamconfdir)
		-D docdir="/usr/share/doc/${PF}"

		"$(my_str_opt fallback-hostname)"  # `the hostname used if none configured`
		-D compat-gateway-hostname=false
		$(my_use_combo default-hierarchy default_cgroup_hierarchy_)
		"$(my_str_opt default-net-naming-scheme)"  # `default net.naming-scheme= value`
		-D status-unit-format-default=name  # 'use unit name or description in messages by default'
		"$(my_str_opt time-epoch)"  # `time epoch for time clients`, default determined from mtime of 'NEWS' file
		"$(my_str_opt system-uid-max)"  # default determined from '/etc/login.defs' file
		"$(my_str_opt system-gid-max)"  # default determined from '/etc/login.defs' file
		"$(my_str_opt dynamic-uid-min)"
		"$(my_str_opt dynamic-uid-max)"
		"$(my_str_opt container-uid-base-min)"
		"$(my_str_opt container-uid-base-max)"
		"$(my_str_opt tty-gid)"    # `the numeric GID of the "tty" group`
		"$(my_str_opt users-gid)"  # `the numeric GID of the "users" group`
		$(meson_use adm-group-acl adm-group)
		$(meson_use wheel-group-acl wheel-group)
		"$(my_str_opt nobody-user)"   # `The name of the nobody user (the one with UID 65534)`
		"$(my_str_opt nobody-group)"  # `The name of the nobody group (the one with GID 65534)`
		"$(my_str_opt dev-kvm-mode)"
		"$(my_str_opt group-render-mode)"
		$(meson_use default-kill-user-processes)  # `the default value for KillUserProcesses= setting`
		$(meson_use gshadow)
		"$(my_str_opt default-locale)"  # `default locale used when /etc/locale.conf does not exist`

		-D default-dnssec=no        # override down the road as needed
		-D default-dns-over-tls=no  # override down the road as needed
		-D dns-over-tls=false       # override down the road as needed
		"$(my_str_opt dns-servers "" "${default_nameservers[*]}")"
		"$(my_str_opt ntp-servers "" "${default_timeservers[*]}")"
		"$(my_str_opt support-url "" "${default_support_url}")"
# 		-D www-target  # internal option for devs

		$(meson_use seccomp)
		$(meson_use selinux)
		$(meson_use apparmor)
		$(meson_use smack)
		"$(my_str_opt smack-run-label)"
		$(meson_use polkit)
		$(meson_use ima)

		$(meson_use acl)
		$(meson_use audit)
		$(meson_use blkid)
		$(meson_use kmod)
		$(meson_use pam)
		-D microhttpd=false  # override down the road as needed
		$(meson_use cryptsetup libcryptsetup)
		-D libcurl=false   # override down the road as needed
		-D idn=false       # override down the road as needed
		-D libidn2=false   # override down the road as needed
		-D libidn=false    # old, use libidn2 instead
		$(meson_use iptables libiptc)
		-D qrencode=false  # old umaintained crap
		-D gcrypt=false    # override down the road as needed
		-D gnutls=false    # override down the road as needed
		-D openssl=false   # override down the road as needed
		-D elfutils=false  # override down the road as needed
		$(meson_use zlib)
		$(meson_use bzip2)
		$(meson_use lzma xz)
		$(meson_use lz4)
		-D xkbcommon=false  # override down the road as needed
		$(meson_use pcre2)
		-D glib=false # tests-only
		-D dbus=false # tests-only

		-D gnu-efi=false
# 		-D efi-cc=
# 		-D efi-ld=
		-D efi-libdir="/usr/$(get_libdir)"
# 		-D efi-ldsdir=
# 		-D efi-includedir=
# 		-D tpm-pcrindex=

		-D bashcompletiondir="$(get_bashcompdir)"
# 		-D zshcompletiondir=  # TODO: default should be fine?

		-D tests=false
		-D slow-tests=false
		-D install-tests=false

# 		-D ok-color=  # `color of the "OK" status message`

		-D oss-fuzz=false
		-D llvm-fuzz=false
		-D fuzzbuzz=false
# 		-D fuzzbuzz-engine=
# 		-D fuzzbuzz-engine-dir=
	)
	## END: emesonargs

	if use resolved
	then
		if use dnssec
		then
			emesonargs+=(
				$(my_use_combo default-dnssec dnssec_default_)
				-D gcrypt=true
			)
		fi

		if use dns-over-tls
		then
			local -- dot=
			use dot_gnutls  && dot+="gnutls"
			use dot_openssl && dot+="openssl"
			emesonargs+=(
				-D dns-over-tls=${dot}
				-D ${dot}=true

				$(my_use_combo default-dns-over-tls dot_default_)
			)
		fi

		if use idn
		then
			emesonargs+=(
				-D idn=true
				-D libidn2=true
			)
		fi

		if use nss-resolve
		then
			emesonargs+=(
				-D nss-resolve=true
			)
		fi
	fi

	if use remote
	then
		emesonargs+=(
			-D gnutls=true
			-D libcurl=true
			-D microhttpd=true
		)
	fi

	if use journal-fss
	then
		emesonargs+=(
			-D gcrypt=true
		)
	fi

	if use importd
	then
		emesonargs+=(
			-D gcrypt=true
			-D libcurl=true
		)
	fi

	if use coredump && use stacktrace
	then
		emesonargs+=(
			-D elfutils=true
		)
	fi

	if use efi && use efi-boot-manager
	then
		emesonargs+=(
			-D gnu-efi=true
		)
	fi

	if use localed && use xkb
	then
		emesonargs+=(
			-D xkbcommon=true
		)
	fi

	if use machined && use nss-mymachines
	then
		emesonargs+=(
			-D nss-mymachines=true
		)
	fi

	# --------------

	## remove empty elements
	local i
	for (( i = 0 ; i < ${#emesonargs[@]} ; i ++ ))
	do
		if [[ -z "${emesonargs[${i}]}" ]]
		then
			unset "emesonargs[${i}]"
		fi
	done

	meson_src_configure
}

src_install:rm_util_symlinks()
{
	local -a util_symlinks_to_delete=()

	if ! use sysv-utils
	then
		util_symlinks_to_delete+=(
			init
			halt poweroff reboot runlevel shutdown telinit
		)
	fi

	if use resolved && ! use resolvconf
	then
		util_symlinks_to_delete+=(
			resolvconf
		)
	fi

	if (( ${#util_symlinks_to_delete[@]} ))
	then
		einfo "Removing utility symlinks$(usex man " and their manpages:" "")"

		local u
		for u in "${util_symlinks_to_delete[@]}"
		do
			rrm "${ED}$(my_get_rootprefix)"/*bin/${u}
		done
		if use man
		then
			for u in "${util_symlinks_to_delete[@]}"
			do
				rrm "${ED}"/usr/share/man/man?/${u}.?
			done
		fi

		# under some scenarios, `/sbin` will end up empty
		rmdir --verbose --ignore-fail-on-non-empty "${ED}"/sbin || die

		echo
	fi
}

src_install:empty_dirs()
{
	local -a empty_dirs_known=(
		/etc/kernel/install.d
		/etc/systemd/{network,system,user}
		/etc/udev/{hwdb.d,rules.d}
		"$(my_get_rootprefix)"/lib/systemd/{system-shutdown,system-sleep}
		/usr/lib/{binfmt.d,modules-load.d}
		/usr/lib/systemd/user-generators
		/etc/{binfmt.d,modules-load.d,sysctl.d,tmpfiles.d}
		/var/lib/systemd
		/var/log/journal
	)

	if [[ -n "${RINDEAL_DEBUG}" ]]
	then
		local -a empty_dirs_found empty_dirs_unknown empty_dirs_superfluous
		readarray -t empty_dirs_found < <(find "${ED}" -type d -empty | cut -c$(( ${#ED} + 1 ))- | sort) || die

		local d
		for d in "${empty_dirs_found[@]}"
		do
			if ! has "${d}" "${empty_dirs_known[@]}"
			then
				empty_dirs_unknown+=( "${d}" )
			fi
		done
		for d in "${empty_dirs_known[@]}"
		do
			if ! has "${d}" "${empty_dirs_found[@]}"
			then
				empty_dirs_superfluous+=( "${d}" )
			fi
		done

		if (( ${#empty_dirs_unknown[@]} ))
		then
			eqawarn "Unknown empty dirs found:"
			printf "'%s'\n" "${empty_dirs_unknown[@]}"
			echo
		fi

		if (( ${#empty_dirs_superfluous[@]} ))
		then
			eqawarn "Superfluous empty dirs found:"
			printf "'%s'\n" "${empty_dirs_superfluous[@]}"
			echo
		fi
	fi

	# Preserve empty dirs in /etc & /var, bug #437008
	for d in "${empty_dirs_known[@]}"
	do
		keepdir "${d}"
	done
}

src_install()
{
	meson_src_install

	src_install:rm_util_symlinks

	src_install:empty_dirs

	# Symlink /etc/sysctl.conf for easy migration.
	rdosym --rel -- "/etc/sysctl.conf" "/etc/sysctl.d/99-sysctl.conf"

	if use split-usr
	then
		## these programs now reside in `/lib`, install symlinks for backwards compatibility
		local -- b
		for b in systemd{,-shutdown}
		do
			rdosym --rel -- "/lib/systemd/${b}" "/usr/lib/systemd/${b}"
		done
	fi

	if use hwdb
	then
		# remove bundled hwdb and use sys-apps/hwids[ instead
		rrm -r "${ED}$(my_get_rootprefix)/lib/udev/hwdb.d"
	fi

# 	die
}

# this function is taken from the Gentoo ebuild
my_migrate_locale_conf()
{
	local envd_locale_def="${ROOT}/etc/env.d/02locale"
	local envd_locale=( "${ROOT}"/etc/env.d/??locale )
	local locale_conf="${ROOT}/etc/locale.conf"

	local -i FAIL=0

	if [[ ! -L ${locale_conf} && ! -e ${locale_conf} ]]; then
		# If locale.conf does not exist...
		if [[ -e ${envd_locale} ]]; then
			# ...either copy env.d/??locale if there's one
			ebegin "Moving ${envd_locale} to ${locale_conf}"
			mv "${envd_locale}" "${locale_conf}"
			eend ${?} || FAIL=1
		else
			# ...or create a dummy default
			ebegin "Creating ${locale_conf}"
			cat > "${locale_conf}" <<-EOF
				# This file has been created by the sys-apps/systemd ebuild.
				# See locale.conf(5) and localectl(1).

				# LANG=${LANG}
			EOF
			eend ${?} || FAIL=1
		fi
	fi

	if [[ ! -L ${envd_locale} ]]; then
		# now, if env.d/??locale is not a symlink (to locale.conf)...
		if [[ -e ${envd_locale} ]]; then
			# ...warn the user that he has duplicate locale settings
			ewarn
			ewarn "To ensure consistent behavior, you should replace ${envd_locale}"
			ewarn "with a symlink to ${locale_conf}. Please migrate your settings"
			ewarn "and create the symlink with the following command:"
			ewarn "ln -s -n -f ../locale.conf ${envd_locale}"
			ewarn
		else
			# ...or just create the symlink if there's nothing here
			ebegin "Creating ${envd_locale_def} -> ../locale.conf symlink"
			ln -n -s ../locale.conf "${envd_locale_def}"
			eend ${?} || FAIL=1
		fi
	fi

	return ${FAIL}
}

pkg_postinst()
{
	# set to 1 if some pkg_postinst phase fails
	local -i FAIL=0

	# Make sure locales are respected, and ensure consistency with OpenRC.
	# Bug gentoo#465468.
	my_migrate_locale_conf || FAIL=1

	if use resolved
	then
		local -r -- resolv_conf_path="${ROOT}/etc/resolv.conf"
		local -r -- systemd_resolv_conf_path="${ROOT}$(my_get_rootprefix)/lib/systemd/resolv.conf"
		if [[ "$(realpath "${resolv_conf_path}")" != "$(realpath "${systemd_resolv_conf_path}")" ]] && \
			! grep -q "^nameserver *127.0.0.1" "${resolv_conf_path}"
		then
			echo
			ewarn "To allow apps that use '${resolv_conf_path}' to connect to resolved,"
			ewarn "you should replace '${resolv_conf_path}' file with symlink to '${systemd_resolv_conf_path}':"
			ewarn ""
			ewarn "    ln -snf '${systemd_resolv_conf_path}' '${resolv_conf_path}'"
			ewarn ""
			ewarn "Or edit '${resolv_conf_path}' file by setting your nameserver address to loopback:"
			ewarn ""
			ewarn "    nameserver 127.0.0.1"
			echo
		fi
	fi

	local -r -- mtab_path="${ROOT}/etc/mtab"
	local -r -- mounts_path="/proc/self/mounts"
	if [[ -e "${mtab_path}" ]] && [[ "$(readlink "${mtab_path}")" != *"${mounts_path}" ]]
	then
		echo
		ewarn "'${mtab_path}' is not a symlink to '${mounts_path}'! ${PN} may fail to work."
		ewarn "Either delete this file altogether or convert it to a symlink to '${mounts_path}':"
		ewarn ""
		ewarn "    ln -svnf '${mounts_path}' '${mtab_path}'"
		echo
	fi

	# Keep this here in case the database format changes so it gets updated
	# when required. Despite that this file is owned by sys-apps/hwids.
	if use hwdb
	then
		ebegin "Updating hwdb database"
		nonfatal udevadm hwdb --update --root="${ROOT}"
		eend $? || FAIL=1
	fi

	udev_reload || FAIL=1

	systemd_update_catalog || FAIL=1

# 	if [[ -z "${ROOT}" && -d /run/systemd/system ]]
# 	then
# 		ebegin "Reexecuting system manager"
# 		nonfatal systemctl daemon-reexec
# 		eend $? || FAIL=1
# 	fi

	if (( FAIL ))
	then
		eerror "One of the post-installation commands failed. Please check the postinst output"
		eerror "for errors. You may need to clean up your system and/or try installing"
		eerror "${PN} again."
	fi
}

pkg_prerm()
{
	# If removing systemd completely, remove the catalog database.
	if [[ -z "${REPLACED_BY_VERSION}" ]]
	then
		nonfatal rrm "${EROOT}/var/lib/systemd/catalog/database"
	fi
}
