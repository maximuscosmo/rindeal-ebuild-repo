# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:tstack"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

## functions: eautoreconf
inherit autotools

DESCRIPTION="Curses-based tool for viewing and analyzing log files"
HOMEPAGE="https://lnav.org ${GH_HOMEPAGE}"
LICENSE="BSD-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( pcre readline static unicode )

# system-wide yajl cannot be used, because lnav uses custom-patched version
CDEPEND_A=(
	"app-arch/bzip2"
	"net-misc/curl"
	"sys-libs/ncurses:0=[unicode?]"
	"dev-libs/openssl:0"
	"sys-libs/readline:0"
	"dev-db/sqlite:3"
	"sys-libs/zlib"

	"pcre? ( dev-libs/libpcre[cxx] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-util/re2c"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

RESTRICT+=" test"

src_prepare() {
	eapply_user

	# respect AR
	# https://github.com/tstack/lnav/pull/356
	esed -e '/^AC_PROG_RANLIB/ a AM_PROG_AR' -i -- configure.ac

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--disable-static
		# experimental support, available since v0.7.3
		--without-jemalloc
		--with-ncurses

		$(use_enable static)

		$(use_with pcre)
		$(use_with readline)
		$(use_with unicode ncursesw)
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	# the text that appears after pressing `?` in TUI
	dodoc src/help.txt
}
