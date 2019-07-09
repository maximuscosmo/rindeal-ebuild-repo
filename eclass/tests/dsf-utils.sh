source tests-common.sh

EAPI=7

inherit dsf-utils

dsf:eval "$1" 'payload'
