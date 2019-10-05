# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_NS="mbunkus"
GITLAB_REF="release-${PV}"

##
inherit gitlab

## functions: eautoreconf
inherit autotools

## functions: qt5_get_bindir
inherit qmake-utils

## functions: append-cppflags
inherit flag-o-matic

## functions: makeopts_jobs
inherit multiprocessing

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE_A=(
	"https://mkvtoolnix.download/"
	"${GITLAB_HOMEPAGE}"
)
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=(
	"${GITLAB_SRC_URI}"
)

KEYWORDS="~amd64"
IUSE_A=(
	debug
	+pch
	+gui
	flac
	+magic
	nls
	+tools
)

# check NEWS.md for build system changes entries for boost/libebml/libmatroska
# version requirement updates and other packaging info
CDEPEND_A=(
	## order based on configure.ac include order

	# ac/ogg.m4
	"media-libs/libogg:0="

	# ac/vorbis.m4
	"media-libs/libvorbis:0="

	# ac/flac.m4
	"flac? ( media-libs/flac:0= )"

	# ac/matroska.m4
	">=dev-libs/libebml-1.3.7:="
	">=media-libs/libmatroska-1.5.0:="

	# ac/pugixml.m4
	"dev-libs/pugixml:0="

	# ac/fmt.m4
	"dev-libs/libfmt:0="

	# ac/zlib.m4
	"sys-libs/zlib:0="

	# ac/qt5.m4
	"gui? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtnetwork:5"
		"dev-qt/qtwidgets:5"
		"dev-qt/qtconcurrent:5"
		"dev-qt/qtmultimedia:5"
		"dev-qt/qtdbus:5"
	")"

	# ac/cmark.m4
	"app-text/cmark:0="

	# ac/magic.m4
	"magic? ( sys-apps/file:0= )"

	# ac/ax_boost*
	# ac/boost.m4
	">=dev-libs/boost-1.49.0:="
)
DEPEND_A=( "${CDEPEND_A[@]}"
	## order based on configure.ac include order

	# ac/nlohmann_jsoncpp.m4
	"<dev-cpp/nlohmann_json-4:0"

	# ac/utf8cpp.m4
	"dev-libs/utfcpp:0"

	# ac/ax_docbook.m4
	"app-text/docbook-xsl-stylesheets:*"  # manpages/docbook.xsl
	"dev-libs/libxslt:*"  # xsltproc

	# ac/po4a.m4
	# ac/translations.m4
	# ac/manpages_translations.m4
	"nls? ("
		"sys-devel/gettext"
		"app-text/po4a"
	")"

	# -------------

	"dev-ruby/rake"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
)

inherit arrays

L10N_LOCALES=( ca cs de es eu fr it ja ko lt nl pl pt pt_BR ro ru sr_RS sr_RS@latin sv tr uk zh_CN zh_TW )
inherit l10n-r1

src_unpack()
{
	gitlab:src_unpack
}

src_prepare:locales()
{
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales}
	do
		rrm "${dir}/${pre}${l}${post}"
		rrm -f "doc/man/po4a/po/${pre}${l}${post}"
	done
}

src_prepare()
{
	eapply_user
	xdg_src_prepare

	src_prepare:locales

	## prevent internal copies from being used
	NO_V=1 rrm -r lib/nlohmann-json
	NO_V=1 rrm -r lib/pugixml
	NO_V=1 rrm -r lib/utf8-cpp

	# automagic dep, for devs only
	rsed -e "/pandoc.m4/d" -i -- configure.ac

	# do not append `-stack-protector.*` to CFLAGS
	rsed -r -e '/^ *(cflags_common|ldflags) .*= *stack_protector/d' -i -- Rakefile

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
	local -- qt_bin_dir="$(qt5_get_bindir)"

	# source files just try to include <utf8.h> directly
	append-cppflags "-I${EPREFIX}/usr/include/utf8cpp"

	local -a my_econf_args=(
# 		--docdir="${EPREFIX}/usr/share/doc/${PF}"

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
		--with-moc="${qt_bin_dir}/moc"
		--with-uic="${qt_bin_dir}/uic"
		--with-rcc="${qt_bin_dir}/rcc"
		--with-qmake="${qt_bin_dir}/qmake"
		--with-boost="${EPREFIX}/usr"
		--with-boost-libdir="${EPREFIX}/usr/$(get_libdir)"
# 		--with-boost-system=
# 		--with-boost-filesystem=
# 		--with-boost-regex=
# 		--with-boost-date-time=
# 		--with-docbook-xsl-root=
# 		--with-xsltproc=prog
# 		--with-po4a=prog
# 		--with-po4a-translate=prog
		$(use_with nls gettext)
		$(use_with tools)
	)

	econf "${my_econf_args[@]}"
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
