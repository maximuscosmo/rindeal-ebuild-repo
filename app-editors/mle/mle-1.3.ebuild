# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:adsr"
GH_REF="v${PV}"
## git-r3.eclass (part of git-hosting.eclass):
[[ "${PV}" == *9999* ]] && \
	EGIT_SUBMODULES=() # no submodules please

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## functions: append-cflags
inherit flag-o-matic

DESCRIPTION="Small but powerful console text editor written in C"
LICENSE="Apache-2.0 BSD-1"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-libs/termbox:0"
	"dev-libs/uthash:0"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	# flags
	rsed -e '/mle_cflags/ s| -g||g' -i -- Makefile
	rsed -e '/mle_cflags/ s| -O3||g' -i -- Makefile

	# libpcre
	rsed -e "/mle_libs/ s| -lpcre| $(pkg-config --libs libpcre)|" -i -- Makefile

	## remove dependency on LUA, because it isn't packaged yet
	rsed -e '/lua/d' -i -- mle.h
	rsed -r -e '/mle_libs/ s|[^ ]*lua[^ ]*||' -i -- Makefile
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
