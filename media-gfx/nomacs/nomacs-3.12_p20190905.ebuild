# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_REF="9c58e06"  # 2019 09 05
MY_GITHUB_PLUGINS_REF="0803d3a"  # 2018 11 30

## cmake-utils.eclass:
# ninja build fails at parsing stage with message:
# `ninja: error: build.ninja:845: bad $-escape (literal $ must be written as $$)`
# which complains because of `$(CONFIGURATION)` not being expanded beforehand
# CMAKE_MAKEFILE_GENERATOR="emake"

## functions: rindeal:prefix_flags
inherit rindeal-utils

##
inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="Qt-based image viewer"
HOMEPAGE_A=(
	"https://www.nomacs.org/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"GPL-3.0-or-later"
)

SLOT="0"

github:snap:gen_src_uri PROJ="${PN}-plugins" REF="${MY_GITHUB_PLUGINS_REF}" \
	--url-var plugins_snap_url --distfile-var plugins_distfile
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
	"plugins? ( ${plugins_snap_url} -> ${plugins_distfile} )"
)

KEYWORDS="~amd64"
IUSE_A=(
	debug
	opencv
	+plugins
	heif
	raw
	tiff
	zip
	nls
	$(rindeal:prefix_flags          \
		plugins_                    \
			+fake_miniatures        \
			+affine_transformation  \
			+paint                  \
			page_extraction         \
			simple                  \
	)
)

CDEPEND_A=(
	# qt deps specified in '${S}/cmake/Utils.cmake'
	"dev-qt/qtconcurrent:5"
	"dev-qt/qtcore:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"
	"dev-qt/qtprintsupport:5"
	"dev-qt/qtsvg:5"
	"dev-qt/qtwidgets:5"

	"media-gfx/exiv2:="

	"opencv? ( media-libs/opencv:=[qt5(+)] )"
	"heif? ( media-libs/libde265:0= )"
	"raw? ( media-libs/libraw:= )"
	"tiff? ("
		"media-libs/tiff:0"
		# https://bugs.gentoo.org/630764
		"dev-qt/qtimageformats:5"
	")"
	"zip? ( dev-libs/quazip )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-qt/linguist-tools:5"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"raw? ( opencv )"
	"tiff? ( opencv )"
)

inherit arrays

L10N_LOCALES=( ar ru uk nl de hr es ko fr bg sk pt zh cs bs sr pl als ja it fi hu id sv tr )
L10N_LOCALES_MASK=( br_pt tw_zh )
inherit l10n-r1

S_OLD="${S}"
S="${S}/ImageLounge"

src_unpack()
{
	github:src_unpack

	if use plugins
	then
		github:snap:unpack "${plugins_distfile}" "${S}/plugins"
	fi
}

src_prepare:locales()
{
	local l locales dir='translations' pre="${PN}_" post='.ts'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales}
	do
		rrm "${dir}/${pre}${l}${post}"
	done
}

src_prepare() {
	cd "${S_OLD}"
	eapply_user
	cd "${S}"

	xdg_src_prepare

	src_prepare:locales

	## fix path to plugins directory
	rsed -e 's|QStringList libPaths = QCoreApplication::libraryPaths();|QStringList libPaths;|' \
		-e "s|libPaths.append(QCoreApplication::applicationDirPath() + \"/plugins\");|libPaths.append(\"${EPREFIX}/usr/$(get_libdir)/nomacs-plugins\");|" \
		-i -- src/DkCore/DkPluginManager.cpp
	rsed -e "s|DESTINATION lib/nomacs-plugins|DESTINATION $(get_libdir)/nomacs-plugins|" \
			-i -- plugins/cmake/Utils.cmake

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D USE_SYSTEM_QUAZIP=ON
		# this app uses patched libqpsd + libqpsd is not in the tree, so definitely use the interal one
		-D USE_SYSTEM_LIBQPSD=OFF

		-D ENABLE_OPENCV=$(usex opencv)
		-D ENABLE_RAW=$(usex raw)
		-D ENABLE_TIFF=$(usex tiff)
		-D ENABLE_QT_DEBUG=$(usex debug)
		-D ENABLE_QUAZIP=$(usex zip)
# 		-D ENABLE_INCREMENTER
		-D ENABLE_TRANSLATIONS=$(use nls)
		-D ENABLE_READ_BUILD=OFF
		-D ENABLE_PLUGINS=$(usex plugins)
		-D ENABLE_HEIF=$(usex heif)
		-D ENABLE_CODE_COV=OFF

		### Plugins:
		-D ENABLE_FAKE_MINIATURES=$(usex plugins_fake_miniatures)
		-D ENABLE_TRANSFORM=$(usex plugins_affine_transformation)
		-D ENABLE_PAINT=$(usex plugins_paint)
		-D ENABLE_PAGE=$(usex plugins_page_extraction)
		-D ENABLE_SIMPLE=$(usex plugins_simple)
	)
	cmake-utils_src_configure
}
