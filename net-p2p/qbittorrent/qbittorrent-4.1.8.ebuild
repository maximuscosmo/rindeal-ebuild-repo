# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

# TODO: revamp systemd service files and possibly fork them into a separate repo

## github.eclass:
GITHUB_PROJ="qBittorrent"
GITHUB_REF="release-${PV}"

## functions: append-cppflags
inherit flag-o-matic

## functions: eqmake5
inherit qmake-utils

inherit github

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

## functions: eautoreconf
inherit autotools

## functions: rindeal:expand_vars
inherit rindeal-utils

## functions: systemd_dounit systemd_douserunit
inherit systemd

## functions: multibuild_foreach_variant multibuild_copy_sources run_in_build_dir
inherit multibuild

DESCRIPTION="BitTorrent client in C++/Qt based on libtorrent-rasterbar"
HOMEPAGE_A=(
	"https://www.qbittorrent.org/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( +dbus debug nls +gui webui stacktrace )

CDEPEND_A=(
	"dev-libs/boost:="
	">=net-libs/libtorrent-rasterbar-1.1.10:0="
	"<net-libs/libtorrent-rasterbar-1.3:0="
	">=dev-libs/openssl-1.0:0="
	"sys-libs/zlib:0"

	"dev-qt/qtcore:5"
	"dev-qt/qtnetwork:5[ssl]"
	"dev-qt/qtxml:5"

	"dev-qt/qtsingleapplication"

	"gui? ("
		"dev-qt/qtgui:5"
		"dev-qt/qtsvg:5"
		"dev-qt/qtwidgets:5"

		"dbus? ( dev-qt/qtdbus:5 )"

		"dev-qt/qtsingleapplication[X]"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"nls? ( dev-qt/linguist-tools:5 )"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	# TODO python deps
)

REQUIRED_USE_A=(
	"|| ( gui webui )"
)

inherit arrays

pkg_setup()
{
	declare -g -r -a MULTIBUILD_VARIANTS=(
		$(usev gui)
		$(usev webui)
	)
}

src_unpack()
{
	github:src_unpack
}

src_prepare-locales()
{
	if ! use nls
	then
		NO_V=1 rrm -r src/lang || die
		rsed -e "\|lang/lang.qrc|d" -i -- src/src.pro
		rsed -e "/lang.pri/d" -i -- qbittorrent.pro  # TODO: change in 4.1.9+

		NO_V=1 rrm -r src/webui/www/translations || die
		rsed -e "/RESOURCES[^=]*=/ s|[^ ]*www/translations[^ ]*||" -i -- src/webui/webui.pri
	fi
}

src_prepare()
{
	eapply_user

	xdg_src_prepare

	src_prepare-locales

	# make build verbose
	rsed -r -e '/^CONFIG[ \+]*=/ s|silent||' -i -- src/src.pro

	# disable AUTOMAKE as no Makefile.am is present
	rsed -e '/^AM_INIT_AUTOMAKE/d' -i -- configure.ac

	# disable qmake call inside ./configure script,
	# we'll call it ourselves from eqmake wrapper
	rsed -e '/^$QT_QMAKE/ s|^|true |' -i -- configure.ac

	eautoreconf

	multibuild_copy_sources
}

my_multi_src_configure()
{
	local econf_args=(
		--with-qtsingleapplication=system
		--disable-systemd # we have services of our own
		--disable-qt-dbus  # enable down the road as needed

		$(use_enable stacktrace)
		$(use_enable debug)
	)

	case "${MULTIBUILD_VARIANT}" in
	'gui' )
		econf_args+=( --enable-gui --disable-webui )
		econf_args+=( $(use_enable dbus qt-dbus) )
		;;
	'webui' )
		econf_args+=( --disable-gui --enable-webui )
		;;
	* ) die ;;
	esac

	econf "${econf_args[@]}"

	eqmake5 -r ./qbittorrent.pro
}

src_configure()
{
	multibuild_foreach_variant run_in_build_dir \
		my_multi_src_configure
}

src_compile()
{
	multibuild_foreach_variant run_in_build_dir \
		default_src_compile
}

src_install()
{
	my_multi_src_install()
	{
		emake INSTALL_ROOT="${D}" install
	}
	multibuild_foreach_variant run_in_build_dir \
		my_multi_src_install

	einstalldocs

	EXPAND_BINDIR="${EPREFIX}/usr/bin"
	if use webui
	then
		rindeal:expand_vars "${FILESDIR}/qbittorrent-nox@.service.in" "${T}/qbittorrent-nox@.service"
		rindeal:expand_vars "${FILESDIR}/qbittorrent-nox.user-service.in" "${T}/qbittorrent-nox.service"

		systemd_dounit "${T}/qbittorrent-nox@.service"
		systemd_douserunit "${T}/qbittorrent-nox.service"
	fi
	if use gui
	then
		rindeal:expand_vars "${FILESDIR}/qbittorrent.user-service.in" "${T}/qbittorrent.service"
		systemd_douserunit "${T}/qbittorrent.service"
	fi
}
