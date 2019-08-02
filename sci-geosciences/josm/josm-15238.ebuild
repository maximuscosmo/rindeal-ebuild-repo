# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## java-utils-2.eclass:
## java-pkg-2.eclass
EANT_GENTOO_CLASSPATH="
	commons-logging
	commons-compress
	commons-codec
	error-prone-annotations
	jmapviewer
	gettext-commons
	gettext-ant-tasks
	signpost
"
## java-ant-2.eclass:
JAVA_ANT_ENCODING=UTF-8

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2

## EXPORT_FUNCTIONS: src_configure
inherit java-ant-2

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

## functions: make_desktop_entry, doicon, newicon
inherit desktop

DESCRIPTION="Java-based editor for the OpenStreetMap project"
HOMEPAGE="https://josm.openstreetmap.de/"
LICENSE="GPL-2"

SLOT="0"
MY_P="${PN}_0.0.svn${PV}"

SRC_URI_A=(
	# Upstream doesn't provide versioned tarballs so check for debian tarballs at:
	#
	#     https://snapshot.debian.org/binary/josm/
	#

	## josm 0.0.svn15238+dfsg-1
	"https://snapshot.debian.org/archive/debian/20190711T090247Z/pool/main/j/josm/josm_0.0.svn15238%2Bdfsg-1.debian.tar.xz"
	"https://snapshot.debian.org/archive/debian/20190711T090247Z/pool/main/j/josm/josm_0.0.svn15238%2Bdfsg.orig.tar.gz"
)

KEYWORDS="~amd64"

CDEPEND_A=(
	"dev-java/commons-compress:0"
	"dev-java/commons-logging:0"
	"dev-java/error-prone-annotations:0"
	"dev-java/jmapviewer:0"
	">=dev-java/gettext-commons-0.9.6:0"
	"dev-java/gettext-ant-tasks:0"
	">=dev-java/signpost-1.2:0"

	"dev-java/commons-codec:0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.8"  # TODO: lift this to 1.9 when available in Gentoo repo
	"dev-java/javacc:0"
	"dev-java/ant-contrib:0"
	"app-text/xmlstarlet" # required for build files patching
	"dev-lang/perl"
	"dev-perl/TermReadKey"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.8"  # TODO: lift this to 1.9 when available in Gentoo repo
	"media-fonts/noto"
)

RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}/${MY_P//_/-}"

L10N_LOCALES=(
	# format cmd:
	#
	#     tr '[[:space:]]' '\n' | sort | sed -r '/^$/d' | tr '\n' ' ' | fold -s -w 100
	#
	af ak am ar as ast awa az be bg bn br bs ca ca@valencia ceb co cs cy da de de_DE dv el en_AU en_CA
	en_GB en_US eo es et eu fa ff fi fil fo fr ga gl gu ha he hi hil hne hr ht hu hy ia id is it ja jv
	ka kk km kn ko ku ky la lb lo lt lv mg mk ml mr ms my nb nds ne nl nn ny oc om or pa pl ps pt pt_BR
	rm ro ru rw sd si sk skr sl so sq sr st sv ta te th tk tl tr ug uk ur uz vi wae xh yo zh_CN zh_HK
	zh_TW zu
)
inherit l10n-r1

src_prepare-locales() {
	local l locales dir="i18n/po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales}
	do
		NO_V=1 rrm "${dir}/${pre}${l}${post}"
		rsed -e "/languages\.put.*\"${l}\"/d" \
			-i -- src/org/openstreetmap/josm/tools/{I18n,LanguageInfo}.java || die
	done
}

src_prepare() {
	local -a -r debian_patches=(
		"00-build.patch"
# 		"01-bts.patch"  # don't use - using custom patching for that
# 		"03-default_look_and_feel.patch"  # don't use - using custom patching for that
		"04-use_system_jmapviewer.patch"
		"05-fix_version.patch"
		"06-move_data_out_of_jar.patch"
		"07-use_system_fonts.patch"
		"08-use_noto_font.patch"
# 		"09-no-java-8.patch"  # java 9+ not available in Gentoo repos and not really needed yet
	)
	local p
	for p in "${debian_patches[@]}"
	do
		eapply "${WORKDIR}/debian/patches/${p}"
	done

	xdg_src_prepare

	src_prepare-locales

	## fix debian paths
	local xmlstarlet=(
		xmlstarlet ed --inplace
		-d "project/target[@name='init-properties']/path[@id='classpath']/fileset"
		build.xml
	)
	echo "${xmlstarlet[@]}"
	"${xmlstarlet[@]}" || die
	local p f
	for p in ${EANT_GENTOO_CLASSPATH}
	do
		for f in $(java-pkg_getjars "${p}" | tr ':' ' ')
		do
			local base_xpath="project/target[@name='init-properties']/path[@id='classpath']"
			local xmlstarlet=(
				xmlstarlet ed --inplace
				-s "${base_xpath}" -t elem -n "pathelement"
				-i "${base_xpath}/pathelement[last()]" -t attr -n location -v "${f}"
				build.xml
			)
			echo "${xmlstarlet[@]}"
			"${xmlstarlet[@]}" || die
		done
	done
	rsed -e "s,/usr/share/java/ant-contrib.jar,$(java-pkg_getjars --build-only ant-contrib),g" \
		-i -- build.xml i18n/build.xml || die
	rsed -e "s,/usr/share/java/gettext-ant-tasks.jar,$(java-pkg_getjars --build-only gettext-ant-tasks),g" \
		-i -- i18n/build.xml || die

	## print stats for EPSG compilation
	rsed -e "s|printStats *= *false|printStats = true|" \
		-i -- scripts/BuildProjectionDefinitions.java || die

	## fix font path
	rsed -e 's,/usr/share/fonts/truetype/noto,/usr/share/fonts/noto,g' \
		-i -- src/org/openstreetmap/josm/tools/FontsManager.java || die

	## change default look and feel to GTK
	rsed -e 's|"javax.swing.plaf.metal.MetalLookAndFeel"|"com.sun.java.swing.plaf.gtk.GTKLookAndFeel"|' \
		-i -- src/org/openstreetmap/josm/tools/PlatformHookUnixoid.java || die

	## don't leak through user-agent
	rsed -r -e 's|(String *result *= *"JOSM/1.5 \(").*|\1 + v + ")";|' \
		-i -- src/org/openstreetmap/josm/data/Version.java || die
	rsed -e '/if *( *includeOsDetails/ s|includeOsDetails|false|' -i -- src/org/openstreetmap/josm/data/Version.java || die
	rsed -r -e 's|(getAgentString\(\)) *\+.*|\1;|' -i -- src/org/openstreetmap/josm/data/Version.java || die

	## do not display MOTD by default, as it requires calling home
	rsed -e 's|getBoolean("help.displaymotd", true)|getBoolean("help.displaymotd", false)|' \
		-i -- src/org/openstreetmap/josm/gui/GettingStarted.java || die

	# update `REVISION` entry
	xmlstarlet ed --inplace -u "project/target[@name='create-revision']/echo[@file='\${revision.dir}/REVISION']" \
		-v "$(cat <<-_EOF_
			# automatically generated by JOSM build.xml - do not edit
			Revision: \${version.entry.commit.revision}
			Is-Local-Build: true
			Build-Date: \${build.tstamp}
			Build-Name: rindeal-ebuild
			Ebuild-Version: ${PVR}
			_EOF_
		)" build.xml || die

	java-pkg-2_src_prepare

	java-ant_rewrite-classpath
	java-ant_rewrite-classpath i18n/build.xml
}

src_compile() {
	EANT_GENTOO_CLASSPATH_EXTRA="${S}/src"
	EANT_GENTOO_CLASSPATH_EXTRA+=":$(java-pkg_getjars --build-only "ant-contrib")"
	# `dist-optimized` requires non-free obfuscator
	EANT_BUILD_TARGET="dist"
	# removes dependency on OpenJFX/Oracle JFX, but audio player will cease to work
	EANT_EXTRA_ARGS="-DnoJavaFX=true"

	java-pkg-2_src_compile
}

src_install() {
	### Main
	java-pkg_newjar "dist/${PN}-custom.jar" "${PN}.jar"

	java-pkg_dolauncher "${PN}" --jar "${PN}.jar" --java_args "-Dawt.useSystemAAFontSettings=lcd"

	### Data
	insinto /usr/share/${PN}
	doins -r images styles data

	local -- share_src_dir="linux/tested/usr/share"

	### Icons
	newicon -s scalable "${share_src_dir}/icons/hicolor/scalable/apps/org.openstreetmap.josm.svg" "${PN}.svg"
	local -i s
	# unsupported sizes: 8 40 42 80
	for s in 16 22 24 32 36 48 64 72 96 128 192 256 512
	do
		newicon -s ${s} "${share_src_dir}/icons/hicolor/${s}x${s}/apps/org.openstreetmap.josm.png" "${PN}.png"
	done

	### Docs
	doman "${share_src_dir}/man/man1/${PN}.1"
	einstalldocs

	### Misc
	insinto /usr/share/appdata
	doins "${share_src_dir}/metainfo/org.openstreetmap.josm.appdata.xml"

	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} %F"	# exec
		"${PN^^}"	# name
		"${PN}"	# icon
		"Education;Science;Geoscience;Maps" # categories; https://standards.freedesktop.org/menu-spec/latest/apa.html
	)
	local make_desktop_entry_extras=(
		"StartupWMClass=org-openstreetmap-josm-Main"
		"MimeType=application/x-osm+xml;application/x-gpx+xml;x-scheme-handler/geo;"
		"GenericName=Java OpenStreetMap Editor"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
