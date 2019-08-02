#!/bin/bash

EAPI=7

. ./tests-common.sh

DEPEND_A=( {1,2,3} )
RDEPEND_A=( r{1,2,3} )
PDEPEND_A=( p{1,2,3} )
CDEPEND_A=( c{1,2,3} )

inherit arrays

DEPEND_A=( "${DEPEND}" {1,2,3} )
RDEPEND_A=( "${RDEPEND}" r{1,2,3} )
PDEPEND_A=( "${PDEPEND}" p{1,2,3} )
CDEPEND_A=( "${CDEPEND}" c{1,2,3} )

inherit arrays

for v in {,R,P,C}DEPEND ; do
    echo "${v}=${!v}"
done
