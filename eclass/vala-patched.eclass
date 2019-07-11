# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: vala-patched.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal@gmail.com>

case "${EAPI:-0}" in
7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


# gentoo eclass specify vala versions which are not yet present in gentoo repos resulting in repoman complainng about unknown versions
if [[ -z "${VALA_MAX_API_VERSION}" ]] || ver_test "${VALA_MAX_API_VERSION}" -gt "0.42"
then
	VALA_MAX_API_VERSION="0.42"
fi


inherit vala
