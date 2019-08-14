# Copyright 1999-2017 Gentoo Foundation
# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_NS="mbunkus"
GITLAB_REF="release-${PV}"

## functions: gitlab:src_unpack
## variables: GITLAB_HOMEPAGE, GITLAB_SRC_URI
inherit gitlab

## functions: eautoreconf
inherit autotools

## functions: makeopts_jobs
inherit multiprocessing

DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE_A=(
	"https://mkvtoolnix.download/"
	"${GITLAB_HOMEPAGE}"
)
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=( "${GITLAB_SRC_URI}" )

KEYWORDS="~amd64"
IUSE_A=( debug +pch test +gui flac +magic nls +tools )

# check NEWS.md for build system changes entries for boost/libebml/libmatroska
# version requirement updates and other packaging info
CDEPEND_A=(
	"dev-libs/libfmt:="
	">=dev-libs/boost-1.49.0:="
	">=dev-libs/libebml-1.3.7:="
	"dev-libs/jsoncpp:="
	"dev-libs/pugixml"
	"flac? ( media-libs/flac )"
	">=media-libs/libmatroska-1.5.0:="
	"media-libs/libogg"
	"media-libs/libvorbis"
	"magic? ( sys-apps/file )"
	"sys-libs/zlib"
	"gui? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtnetwork:5"
		"dev-qt/qtwidgets:5"
		"dev-qt/qtconcurrent:5"
		"dev-qt/qtmultimedia:5"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-ruby/rake"
	"app-text/cmark"
	"nls? ("
		"sys-devel/gettext"
		"app-text/po4a"
	")"
	"virtual/pkgconfig"
	"dev-libs/libxslt"
	"app-text/docbook-xsl-stylesheets"

	"test? ( dev-cpp/gtest )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

L10N_LOCALES=( ca cs de es eu fr it ja ko lt nl pl pt pt_BR ro ru sr_RS sr_RS@latin sv tr uk zh_CN zh_TW )
inherit l10n-r1

src_unpack() {
	gitlab:src_unpack
}

src_prepare-locales() {
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		rrm "${dir}/${pre}${l}${post}"
		rrm -f "doc/man/po4a/po/${pre}${l}${post}"
	done
}

src_prepare() {
	default

	src_prepare-locales

	# do not append `-stack-protector.*` to CFLAGS
	rsed -r -e '/^ *(cflags_common,ldflags) .*stack_protector/d' -i -- Rakefile

	### COC
	rrm CODE_OF_CONDUCT.md

	rsed -e '/CODE_OF_CONDUCT.md/d' -i -- src/mkvtoolnix-gui/qt_resources.qrc
	rsed -e '/actionHelpCodeOfConduct/d' -i -- src/mkvtoolnix-gui/main_window/main_window.cpp

	# TODO: debug diff
	xmlstarlet ed --inplace --delete "//addaction[@name='actionHelpCodeOfConduct']" src/mkvtoolnix-gui/forms/main_window/main_window.ui
	xmlstarlet ed --inplace --delete "//action[@name='actionHelpCodeOfConduct']" src/mkvtoolnix-gui/forms/main_window/main_window.ui

	touch config.sub || die

	eautoreconf
}

src_configure() {
	# ac/qt5.m4 finds default Qt version set by qtchooser, bug #532600
	export PATH="${EROOT}usr/$(get_libdir)/qt5/bin:${PATH}"

	local myconf=(
		### Optional Features:
		--disable-update-check
		--disable-appimage
		$(use_enable debug)
		--disable-profiling
		--disable-optimization
		--disable-addrsan
		--disable-ubsan
		$(use_enable pch precompiled-headers)
		--disable-static
		$(use_enable gui qt)
		--disable-static-qt
		$(use_enable magic)

		### Optional Packages:
		$(use_with flac)
# 		--with-qt-pkg-config-modules=modules  # the built-in list is ok
		--with-qt-pkg-config
		$(use_with nls gettext)

		--docdir="${EPREFIX}"/usr/share/doc/${PF}

		--with-boost="${EPREFIX}"/usr
		--with-boost-libdir="${EPREFIX}"/usr/$(get_libdir)

		$(use_with tools)
	)

	econf "${myconf[@]}"
}

my_rake() {
	rake V=1 -j$(makeopts_jobs) "${@}" || die
}

src_compile() {
	my_rake
}

src_install() {
	DESTDIR="${D}" my_rake install

	einstalldocs
	doman doc/man/*.1
}
