# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass
GH_RN="github:zealdocs"
# GH_REF="v${PV}"
GH_REF="419ef8d"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="Offline documentation browser inspired by Dash"
HOMEPAGE="https://zealdocs.org/ ${GH_HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=()

CDEPEND_A=(
	## src/app/CMakeLists.txt:
	##   - `find_package(Qt5Core REQUIRED)`
	##   - `find_package(Qt5 COMPONENTS Widgets REQUIRED)`
	"dev-qt/qtcore:5"
	"dev-qt/qtwidgets:5"

	## src/libs/core/CMakeLists.txt:
	##   - `find_package(Qt5 COMPONENTS Network WebKit Widgets REQUIRED)`
	##   - `find_package(LibArchive REQUIRED)`
	"dev-qt/qtnetwork:5"
	"dev-qt/qtwebkit:5"
	"dev-qt/qtwidgets:5"
	"app-arch/libarchive"

	## src/libs/registry/CMakeLists.txt:
	##   - `find_package(Qt5 COMPONENTS Concurrent Gui Network REQUIRED)`
	"dev-qt/qtconcurrent:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"

	## src/libs/ui/CMakeLists.txt:
	##   - `find_package(Qt5 COMPONENTS WebKitWidgets REQUIRED)`
	"dev-qt/qtwebkit:5"

	## src/libs/ui/qxtglobalshortcut/CMakeLists.txt:
	##   - `find_package(X11)`
	##   - `find_package(Qt5Gui REQUIRED)`
	##   - `find_package(Qt5 COMPONENTS X11Extras REQUIRED)`
	##   - `find_package(XCB COMPONENTS XCB KEYSYMS REQUIRED)`
	"x11-libs/libX11"
	"dev-qt/qtgui:5"
	"dev-qt/qtx11extras:5"
	"x11-libs/libxcb"
	"x11-libs/xcb-util-keysyms"

	## src/libs/util/CMakeLists.txt:
	##   - `find_package(Qt5Core REQUIRED)`
	##   - `find_package(SQLite REQUIRED)`
	"dev-qt/qtcore:5"
	"dev-db/sqlite:3"

	# previous versions are buggy
	">=dev-qt/qtwebkit-5.212.0_pre20180120:5"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"kde-frameworks/extra-cmake-modules"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"x11-themes/hicolor-icon-theme"
)

src_prepare() {
	eapply_user

	## disable update checks
	rsed -e '/ReleasesApiUrl/ s|".*"|""|' -i -- src/libs/core/application.cpp
	rsed -e '/QUrl(ReleasesApiUrl)/i return;' -i -- src/libs/core/application.cpp

	## change default settings
	rsed -e '/"check_for_update"/ s|true|false|' -i -- src/libs/core/settings.cpp
	rsed -e '/"smooth_scrolling"/ s|false|true|' -i -- src/libs/core/settings.cpp
	rsed -e '/"fuzzy_search_enabled"/ s|false|true|' -i -- src/libs/core/settings.cpp

	## disable tracking and analytics
	rsed -e '/installId =/,+2d' -i -- src/libs/core/settings.cpp
	rsed -e '/setValue.*"install_id"/d' -i -- src/libs/core/settings.cpp
	rsed -e '/Application::userAgentJson/ {n;a return QString(); '$'\n''}' -i -- src/libs/core/application.cpp

	xdg_src_prepare
	cmake-utils_src_prepare
}
