# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="adsr"
GITHUB_REF="v${PV}"

## self-explanatory usage
inherit github

## functions: append-cflags
inherit flag-o-matic

DESCRIPTION="Small but powerful console text editor written in C"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"Apache-2.0"
	"BSD-1"
)

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"dev-libs/libpcre:*"  # TODO: make it optional
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-libs/termbox:0"
	"dev-libs/uthash:0"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_unpack() {
	github:src_unpack
}

src_prepare() {
	eapply_user

	# flags
	rsed -e '/mle_cflags/ s| -g||g' -i -- Makefile
	rsed -e '/mle_cflags/ s| -O3||g' -i -- Makefile

	# libpcre
	rsed -e "/mle_dynamic_libs/ s|-lpcre| $(pkg-config --libs libpcre)|" -i -- Makefile

	## remove dependency on LUA, because it isn't packaged yet, TODO
	rsed -e '/lua/d' -i -- mle.h
	rsed -r -e '/mle_dynamic_libs/ s|[^ ]*lua[^ ]*||' -i -- Makefile
	rrm *uscript*
	rsed -e '/uscript_run/d' -i -- mle.h
	rsed -e '/uscript_destroy/d' -i -- mle.h
	rsed -e '/uscript/d' -e "/case *'x':/ s|^|/*|" -e "/case *'y':/ s|^|*/|" -i -- editor.c
}

src_configure() {
	append-cflags "-Wno-unused-result"
}

src_install() {
	dobin "${PN}"
	einstalldocs
}
