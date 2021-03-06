# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

RESTRICT="strip"

inherit eutils

DESCRIPTION="Reelbox player for the Reel eHD PCI card SVN"
HOMEPAGE="http://www.reel-multimedia.com"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=media-video/reelbox-ehd-tools-14440"
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

	insinto /etc/init.d
	newinitd "${FILESDIR}/reelbox-ehd" reelbox-ehd
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
