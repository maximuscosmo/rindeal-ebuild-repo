# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:maxmind"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## functions: eautoreconf
inherit autotools

## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="C library for the MaxMind DB file format"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	rsed -r -e '/AM_CFLAGS=/ s,-(O[0-9]?|g[0-9]?),,g' -i -- common.mk

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--enable-shared
		--disable-static

		--disable-tests
		--disable-debug
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	prune_libtool_files
}
