# Copyright 1999-2017 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:clbr"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

inherit toolchain-funcs

DESCRIPTION="Utility to view Radeon GPU utilization"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( nls )

CDEPEND_A=(
	"x11-libs/libpciaccess"
	">=x11-libs/libdrm-2.4.63"
	"x11-libs/libxcb"
	"sys-libs/ncurses:0="

	"nls? ("
		"sys-libs/ncurses:0=[unicode]"
		"virtual/libintl"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"nls? ( sys-devel/gettext )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

XCBLIB_DIR="/usr/libexec/${PN}"

src_prepare() {
	eapply "${FILESDIR}/65.patch"
	eapply_user

	esed -e "/dlopen(/ s|\"\(libradeontop_xcb.so\)\"|\"${EPREFIX}${XCBLIB_DIR}/\1\"|" -i -- auth.c

	cat > include/version.h <<-_EOF_ || die
		#ifndef VER_H
		# define VER_H

		# define VERSION "${PV}"

		#endif
	_EOF_
}

src_configure() {
	tc-export CC
	export LIBDIR=$(get_libdir)
	export nls=$(usex nls 1 0)
	export amdgpu=1
	export xcb=1
	# Do not add -g or -s to CFLAGS
	export plain=1
}

src_compile() {
	emake verh=
}

src_install() {
	dosbin "${PN}"

	into "${XCBLIB_DIR}"
	dolib.so "libradeontop_xcb.so"

	doman "${PN}.1"

	einstalldocs
}
