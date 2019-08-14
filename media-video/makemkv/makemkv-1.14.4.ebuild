# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_NS="rindeal-ns/makemkv"
GITLAB_REF="v${PV}"

## functions: gitlab:snap:gen_src_uri, gitlab:snap:unpack
inherit gitlab

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

## functions: make_desktop_entry, newicon
inherit desktop

## functions: make_wrapper
inherit eutils

DESCRIPTION="Tool for ripping and streaming Blu-ray, HD-DVD and DVD discs"
HOMEPAGE_A=( "https://www.makemkv.com" )
LICENSE_A=( "LGPL-2.1" "MPL-1.1" "MakeMKV-EULA" "openssl" )

declare -g -r -- MY_S_OSS="${WORKDIR}/${PN}-oss"
declare -g -r -- MY_S_BIN="${WORKDIR}/${PN}-bin"
declare -g -r -- MY_S_EXTRA="${WORKDIR}/${PN}-extra"

SLOT="0"

gitlab:snap:gen_src_uri PROJ="${PN}-oss" --url-var MY_OSS_URL --distfile-var MY_OSS_DISTFILE
gitlab:snap:gen_src_uri PROJ="${PN}-bin" --url-var MY_BIN_URL --distfile-var MY_BIN_DISTFILE
gitlab:snap:gen_src_uri PROJ="${PN}-extra" REF="v0.1.0" --url-var MY_EXTRA_URL --distfile-var MY_EXTRA_DISTFILE
readonly MY_OSS_DISTFILE MY_BIN_DISTFILE MY_EXTRA_DISTFILE
SRC_URI_A=(
# 	https://www.makemkv.com/download{,/old}/${PN}-oss-${PV}.tar.gz
# 	https://www.makemkv.com/download{,/old}/${PN}-bin-${PV}.tar.gz
	"${MY_OSS_URL} -> ${MY_OSS_DISTFILE}"
	"${MY_BIN_URL} -> ${MY_BIN_DISTFILE}"
	"${MY_EXTRA_URL} -> ${MY_EXTRA_DISTFILE}"
)
unset MY_OSS_URL MY_BIN_URL MY_EXTRA_URL

KEYWORDS_A=( '-*' '~amd64' )
IUSE_A=( '+gui' )

CDEPEND_A=(
	"dev-libs/expat"
	"virtual/libc"
	"dev-libs/openssl:0[-bindist(-)]"
	"sys-libs/zlib"
	"media-video/ffmpeg:0="

	"gui? ("
		"dev-qt/qtcore:5"
		"dev-qt/qtdbus:5"
		"dev-qt/qtgui:5"
		"dev-qt/qtwidgets:5"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	# used for http downloads, see 'HTTP_Download()' in '${MY_S_OSS}/libabi/src/httplinux.cpp'
	"net-misc/wget"
)

RESTRICT+=" test"

inherit arrays

declare -A L10N_LOCALES_MAP=(
	['zh']='chi'
	['da']='dan'
	['de']='deu'
	['nl']='dut'
	['fr']='fra'
	['it']='ita'
	['ja']='jpn'
	['no']='nor'
	['fa']='per'
	['pl']='pol'
	['pt_BR']='ptb'
	['es']='spa'
	['sv']='swe'
)
L10N_LOCALES=( "${!L10N_LOCALES_MAP[@]}" )
MY_LOC_DIR="${MY_S_BIN}"/src/share
MY_LOC_PRE='makemkv_'
MY_LOC_POST='.mo.gz'
inherit l10n-r1

S="${MY_S_OSS}"

src_unpack() {
	gitlab:snap:unpack "${MY_OSS_DISTFILE}" "${MY_S_OSS}"
	gitlab:snap:unpack "${MY_BIN_DISTFILE}" "${MY_S_BIN}"
	gitlab:snap:unpack "${MY_EXTRA_DISTFILE}" "${MY_S_EXTRA}"
}

src_prepare() {
	eapply "${FILESDIR}"/path.patch
	eapply_user

	xdg_src_prepare

	l10n_find_changes_in_dir "${MY_LOC_DIR}" "${MY_LOC_PRE}" "${MY_LOC_POST}"
}

src_configure() {
	local econf_args=(
		--enable-debug # do not strip symbols -- this will be done by portage itself
		--disable-noec # use openssl instead of custom crypto
		--disable-qt4 # Qt4 is no longer supported in Gentoo repos
		$(use_enable gui qt5)
		$(use_enable gui)
	)

	econf "${econf_args[@]}"
}

src_install-oss() {
	### Install OSS components
	cd "${MY_S_OSS}" || die

	local lib
	for lib in libdriveio libmakemkv libmmbd
	do
		local path="$(echo "out/${lib}.so."?)"
		local name="${path##"out/"}"
		dolib.so "${path}"
		## these symlinks are not installed by upstream
		## TODO: are they still necessary?
		dosym "${name}"	"/usr/$(get_libdir)/${name}.${PV}"
		dosym "${name}"	"/usr/$(get_libdir)/${lib}.so"
	done

	find -type d -name "inc" | \
	while read -r dir
	do
		local insdir="/usr/include/makemkv"
		local libdirname="$( basename "$( dirname "${dir}" )" )"

		insinto "${insdir}/${libdirname}"
		doins -r "${dir}"

		instincdir="${ED}/${insdir}/${libdirname}/inc"
		rmv "${instincdir}"/* "${instincdir%%"/inc"}"
		rrmdir "${instincdir}"
	done
	assert

	if use gui
	then
		dobin "out/${PN}"

		local s
		for s in 16 22 32 64 128
		do
			newicon -s "${s}" "makemkvgui/share/icons/${s}x${s}/makemkv.png" "${PN}.png"
		done

		# Although upstream supplies .desktop file in '${MY_S_OSS}/makemkvgui/share/makemkv.desktop',
		# the generated one is slightly better.
		make_desktop_entry "${PN}" "MakeMKV" "${PN}" 'Qt;AudioVideo;Video'
	fi
}

src_install-bin() {
	### Install binary/pre-compiled/pre-generated components
	cd "${MY_S_BIN}" || die

	local -r -- my_base_dir="/opt/${PN}"

	## BEGIN: Install prebuilt bins

	exeinto "${my_base_dir}"/bin
	doexe bin/amd64/makemkvcon
	make_wrapper makemkvcon "${my_base_dir}"/bin/makemkvcon

	## END

	## BEGIN: Install misc files

	# this directory is hardcoded in the binaries
	insinto "${my_base_dir}"/share/MakeMKV

	# Install locales
	# locale files are used by makemkvcon so they're not `gui` USE-flag dependent
	local l locales
	l10n_get_locales locales app on
	for l in ${locales}
	do
		doins "${MY_LOC_DIR}/${MY_LOC_PRE}${l}${MY_LOC_POST}"
	done
	NO_V=1 rrm "${MY_LOC_DIR}"/${MY_LOC_PRE}*${MY_LOC_POST}

	# Install the rest
	doins src/share/*

	## END
}

src_install-extra() {
	cd "${MY_S_EXTRA}" || die

	exeinto "usr/libexec/${PN}"
	doexe "update-beta-key.sh"
}

my_install_envd() {
	newenvd <(cat <<-_EOF_
			## Installed by ${CATEGORY}/${PF} ebuild package on $(date --utc -Iminutes)
			##
			## MakeMKV can act as a drop-in replacement for libaacs and libbdplus allowing
			## transparent decryption of a wider range of titles under players like VLC and mplayer.
			##
			LIBAACS_PATH=libmmbd
			LIBBDPLUS_PATH=libmmbd

			_EOF_
		) "20-${PN}-libmmbd"
}

src_install() {
	src_install-oss
	src_install-bin
	src_install-extra

	my_install_envd
}

QA_PREBUILT="opt/${PN}/bin/makemkvcon"

pkg_postinst() {
	xdg_pkg_postinst

	elog ""
	elog "While MakeMKV is in beta mode, upstream has provided a license"
	elog "to use if you do not want to purchase one."
	elog "See this forum thread for more information, including the key:"
	elog "  https://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053"
	elog "Note that beta license has an expiration date and you will"
	elog "need to check for newer licenses/releases. But you can do so"
	elog "automatically by using '/usr/libexec/makemkv/update-beta-key.sh'"
	elog "script."
	elog ""
	elog "MakeMKV can also act as a drop-in replacement for libaacs and"
	elog "libbdplus, allowing transparent decryption of a wider range of"
	elog "titles under players like VLC and mplayer."
	elog "See '/etc/env.d/20-makemkv-libmmbd'."
	elog ""
}
