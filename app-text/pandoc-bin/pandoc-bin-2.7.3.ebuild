# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

# to unpack .deb archive
## EXPORT_FUNCTIONS: src_unpack
inherit unpacker

PN_NB="${PN//-bin/}"

DESCRIPTION="Universal markup converter"
HOMEPAGE_A=(
	"https://pandoc.org"
	"https://github.com/jgm/pandoc"
)
LICENSE="GPL-2"

SLOT="0"
SRC_URI="amd64? ( https://github.com/jgm/${PN_NB}/releases/download/${PV}/${PN_NB}-${PV}-1-amd64.deb )"

KEYWORDS="-* amd64"
IUSE_A=( citeproc )

CDEPEND_A=(
	"dev-libs/gmp:*"
	"sys-libs/zlib:*"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!app-text/${PN_NB}"
	"citeproc? ( !dev-haskell/${PN_NB}-citeproc )"
)

RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}"

src_prepare() {
	eapply_user

	# docs are gzipped
	find -name "*.gz" | xargs gunzip
	assert
}

src_configure() { : ; }
src_compile() { : ; }

src_install() {
	cd "${S}"/usr/bin || die
	dobin "${PN_NB}"
	use citeproc && dobin "${PN_NB}-citeproc"

	cd "${S}"/usr/share/man/man1 || die
	doman "${PN_NB}.1"
	use citeproc && doman "${PN_NB}-citeproc.1"
}

QA_EXECSTACK="usr/bin/.*"
QA_PRESTRIPPED="usr/bin/.*"
