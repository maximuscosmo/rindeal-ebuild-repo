# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

if ! (( _E2FSPROGS_ECLASS ))
then

case "${EAPI:-0}" in
'7' ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac

inherit rindeal


## git-hosting.eclass:
GH_RN="kernel:fs/ext2:e2fsprogs"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE, SRC_URI
inherit git-hosting

## functions: eautoreconf
inherit autotools

## functions: append-cppflags
inherit flag-o-matic

## functions: tc-getCC, tc-getBUILD_CC, tc-getBUILD_LD
inherit toolchain-funcs

## functions: prune_libtool_files
inherit ltprune

## functions: get_udevdir
inherit udev

## functions: systemd_get_systemunitdir
inherit systemd


HOMEPAGE_A=(
	"http://e2fsprogs.sourceforge.net/"
	"${GH_HOMEPAGE}"
	"https://github.com/tytso/e2fsprogs"
)
LICENSE_A=(
	"GPL-2"
	"BSD"
)

SLOT="0"

IUSE_A=(
	static-libs debug threads
)

inherit arrays


EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install


e2fsprogs_src_unpack() {
	git-hosting_src_unpack
}

e2fsprogs_src_prepare() {
	default

	rcp doc/RelNotes/v${PV}.txt ChangeLog

	## don't bother with docs, Gentoo-Bug: 305613
	printf 'all:\n%%:;@:\n' > doc/Makefile.in || die

	NO_V=1 rrm -r doc

	eautoreconf
}

e2fsprogs_src_configure() {
	# needs open64() prototypes and friends
	append-cppflags -D_GNU_SOURCE

	export ac_cv_path_LDCONFIG=:
	export CC="$(tc-getCC)"
	export BUILD_CC="$(tc-getBUILD_CC)"
	export BUILD_LD="$(tc-getBUILD_LD)"

	local _econf_args=(
		--enable-option-checking
		--disable-maintainer-mode
		--enable-symlink-install  # use symlinks when installing instead of hard links
		--enable-relative-symlinks  # use relative symlinks when installing
		--enable-symlink-build  # use symlinks while building instead of hard links
		--enable-verbose-makecmds
		$(tc-is-static-only || echo --enable-elf-shlibs)
		--disable-bsd-shlibs
		--disable-profile
		--disable-gcov
		--disable-hardening  # these are just compiler and linker flags
		$(use_enable debug jbd-debug)
		$(use_enable debug blkid-debug)
		$(use_enable debug testio-debug)
		--disable-libuuid  # using newer and better versions from util-linux
		--disable-libblkid  # using newer and better versions from util-linux
		--disable-subset  # enable if needed
		--disable-backtrace
		--disable-debugfs  # enable if needed
		--disable-imager  # enable if needed
		--disable-resizer  # enable if needed
		--disable-defrag  # enable if needed
		--disable-fsck  # using newer and better versions from util-linux
		--disable-e2initrd-helper  # enable if needed
		$(tc-has-tls || echo --disable-tls)
		--disable-uuidd  # using newer and better versions from util-linux
		--disable-mmp  # enable if needed
		--disable-tdb  # enable if needed
		--disable-bmap-stats  # enable if needed
		--disable-bmap-stats-ops  # enable if needed
		--disable-nls  # enable if needed
		$(usex threads "--enable-threads=posix" "--disable-threads")
		--disable-rpath
		--disable-fuse2fs  # enable if needed
		--disable-lto  # we can enable it ourselves
		$(use_enable debug ubsan)
		$(use_enable debug addrsan)
		$(use_enable debug threadsan)
		--with-udev-rules-dir="$(get_udevdir)"
		--without-crond-dir
		--with-systemd-unit-dir="$(systemd_get_systemunitdir)"

		--with-root-prefix="${EPREFIX}/"  # ??

		"${@}"
	)

	econf "${_econf_args[@]}"
}

e2fsprogs_src_compile() {
	local _emake_args=(
		V=1
		"${@}"
	)
	emake "${_emake_args[@]}"
}

e2fsprogs_src_install() {
	local _emake_args=(
		STRIP=:
		DESTDIR="${D}"
		install
		"${@}"
	)

	emake "${_emake_args[@]}"

	einstalldocs

	prune_libtool_files

	# configure doesn't have an option to disable static libs :/
	if ! use static-libs
	then
		find "${D}" -name '*.a' -delete || die
	fi
}


_E2FSPROGS_ECLASS=1
fi
