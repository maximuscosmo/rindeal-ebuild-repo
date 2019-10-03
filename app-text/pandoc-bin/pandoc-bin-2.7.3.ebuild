# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

PN_NB="${PN//-bin/}"
P_NB="${PN_NB}-${PV}"

DESCRIPTION="Universal markup converter"
HOMEPAGE_A=(
	"https://pandoc.org"
	"https://github.com/jgm/pandoc"
)
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=(
	"https://github.com/jgm/${PN_NB}/releases/download/${PV}/${P_NB}-linux.tar.gz"
)

KEYWORDS="-* amd64"
IUSE_A=( citeproc )

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-libs/gmp:*"
	"sys-libs/zlib:*"

	"!app-text/${PN_NB}"
	"citeproc? ( !dev-haskell/${PN_NB}-citeproc )"
)

RESTRICT+=" primaryuri"

inherit arrays

S="${WORKDIR}/${P_NB}"

src_unpack()
{
	default

	# docs/manpages are gzipped
	find . -name "*.gz" | xargs gunzip
	assert
}

src_configure(){ :;}
src_compile(){ :;}

src_install()
{
	cd "${S}/bin" || die
	dobin "${PN_NB}"
	use citeproc && dobin "${PN_NB}-citeproc"

	cd "${S}/share/man/man1" || die
	doman "${PN_NB}.1"
	use citeproc && doman "${PN_NB}-citeproc.1"
}

QA_PRESTRIPPED="usr/bin/.*"
