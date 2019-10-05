# Copyright  2019  Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit rindeal

##
inherit github

DESCRIPTION=""
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
)

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS_A=(
)
IUSE_A=(
)

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
)

REQUIRED_USE_A=(
)

RESTRICT+=""

inherit arrays

src_unpack()
{
	github:src_unpack
}

