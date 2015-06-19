# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

RESTRICT="strip"

inherit eutils

DESCRIPTION="Reelbox player for the Reel eHD PCI card SVN"
HOMEPAGE="http://www.reel-multimedia.com"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=media-video/reelbox-ehd-tools-${PV}"
RDEPEND=${DEPEND}

S="${WORKDIR}/precompiled"

src_unpack() {
	unpack ${A}
	cd "${S}"

	gzip -d linux.bin.gz
	gzip -d hdplayer.gz
}

src_install() {

	insinto /opt/reelbox-ehd/hdplayer
	doins hdplayer

	insinto /opt/reelbox-ehd
	doins linux.bin

	newinitd "${FILESDIR}/reelbox-ehd-v2" reelbox-ehd
}

pkg_postinst() {

	echo
	einfo "The hdplayer binary was installed in /opt/reelbox-ehd/hdplayer"
	einfo "You need to install a tftp-server an let him point to /opt/reelbox-ehd."
	echo
	einfo "For a working Reel eHD you need the tun and hdshm module"
	einfo "in modules autoload file"
	echo
	einfo "Since svn-rel 5720 or higher the conf.d/reelbox-ehd is not longer"
	einfo "needed."
	echo
}
