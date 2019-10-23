# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## NOTE: this package should really be called "dbeaver-ce-bin", source-based "dbeaver-ce"
##       and the commercial one "dbeaver-ee"

PN_NB="${PN%-bin}"

## github.eclass:
GITHUB_NS="${PN_NB}"
GITHUB_PROJ="${GITHUB_NS}"

##
inherit github

## functions: newicon, make_desktop_entry
inherit desktop

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="Free universal database manager and SQL client"
HOMEPAGE_A=(
	"https://dbeaver.io/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"Apache-2.0"
)

MY_SLOT="$(ver_cut 1)"
SLOT="${MY_SLOT}"
PN_NBS="${PN_NB}${MY_SLOT}"

SRC_URI_A=(
	"amd64? ( ${GITHUB_HOMEPAGE}/releases/download/${PV}/dbeaver-ce-${PV}-linux.gtk.x86_64.tar.gz )"
)

KEYWORDS="-* ~amd64"

RDEPEND_A=(
	">=virtual/jre-1.8"
	"!dev-db/dbeaver"
	"!dev-db/dbeaver-ce"
	"!dev-db/dbeaver-ee"
)

RESTRICT+=" mirror strip test"

inherit arrays

S="${WORKDIR}/${PN_NB}"

src_compile() { : ;}

src_install (){
	local -r -- install_dir="/opt/${PN_NBS}"
	local -r -- bin="/usr/bin/${PN_NBS}"

	insinto "${install_dir}"
	doins -r *

	fperms a+x "${install_dir}/${PN_NB}"
	dosym "${install_dir}/${PN_NB}" "${bin}"

	newicon -s 128 "${PN_NB}.png" "${bin##*/}.png"

	local -r -a make_desktop_entry_args=(
		"${bin##*/} %U"  # exec
		"DBeaver Community Edition ${MY_SLOT}"  # name
		"${bin##*/}"  # icon
		"Development;Database;IDE;"  # categories
	)
	local -a make_desktop_entry_extras=(
		"MimeType=application/x-sqlite3;application/sql;"  # MUST end with semicolon
		"StartupWMClass=DBeaver"
		"StartupNotify=true"
		"GenericName=Universal Database Manager"
		"Keywords=Database;SQL;IDE;JDBC;ODBC;MySQL;PostgreSQL;"
	)
	make_desktop_entry \
		"${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
