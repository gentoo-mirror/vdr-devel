# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

RESTRICT="mirror"

inherit eutils

DESCRIPTION="eHD PCI card: headers svn r${PN}"
HOMEPAGE="http://www.reel-multimedia.com"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
		>=media-video/vdr-1.7.12"

S=${WORKDIR}

src_prepare() {

	sed -e "s:\#include \"../driver/:\#include \":" \
		-i "${S}"/bspshm/include/bspshmlib.h \
		-i "${S}"/hdshm3/src/include/hdshmlib.h
}

src_install() {

	insinto /usr/include
	doins "${S}"/bspshm/include/*.h
	doins "${S}"/bspshm/driver/*.h
	doins "${S}"/hdshm3/src/include/*.h
	doins "${S}"/hdshm3/src/driver/*.h
	doins "${S}"/vdr-reelbox-3/*.h

	insinto /usr/include/vdr
	doins "${WORKDIR}"/vdr-1.4/*
	doins "${FILESDIR}"/Make.common
}