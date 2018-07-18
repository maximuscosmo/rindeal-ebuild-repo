# Copyright 1999-2014 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="bitbucket:heldercorreia"
# GH_REF="release-${PV}"
GH_REF="d95a640"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

## functions: doicon
inherit desktop

DESCRIPTION="Fast and usable calculator for power users"
HOMEPAGE="http://speedcrunch.org/ https://speedcrunch.blogspot.com/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( )

CDEPEND_A=(
	"dev-qt/qtcore:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtwidgets:5"
	"dev-qt/qthelp:5"
	"dev-qt/qtsql:5"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

L10N_LOCALES=( ar ca_ES cs_CZ da de_DE el en_GB en_US es_AR es_ES et_EE eu_ES fi_FI fr_FR he_IL hu_HU
	id_ID it_IT ja_JP ko_KR lt lv_LV nb_NO nl_NL pl_PL pt_BR pt_PT ro_RO ru_RU sk sv_SE tr_TR uz_Latn_UZ
	vi zh_CN
)
inherit l10n-r1

S_OLD="${S}"
S="${S_OLD}/src"

src_prepare-locales() {
	local l locales dir='resources/locale' pre='' post='.qm'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		rrm "${dir}/${pre}${l}${post}"
		rsed -e "s|<file>locale/${l}.qm</file>||" \
			-i -- resources/speedcrunch.qrc
	done
}

src_prepare() {
	eapply_user

	src_prepare-locales

	xdg_src_prepare

	# NOTE: remove when a new release is available
	rsed -e "/^set.*speedcrunch_VERSION/ s|\"master\"|\"${PV} (${GH_REF})\"|" -i -- CMakeLists.txt

	rsed -e '/^enable_testing/d' -i -- CMakeLists.txt

	cmake-utils_src_prepare
}

src_install() {
	cmake-utils_src_install

	cd "${S_OLD}" || die

	einstalldocs
	doicon -s scalable gfx/${PN}.svg
}
