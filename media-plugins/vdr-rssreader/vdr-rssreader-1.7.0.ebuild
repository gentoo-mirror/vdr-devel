# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit vdr-plugin

DESCRIPTION="VDR Plugin: RSS reader"
HOMEPAGE="http://www.saunalahti.fi/~rahrenbe/vdr/rssreader/"
SRC_URI="http://www.saunalahti.fi/~rahrenbe/vdr/rssreader/files/${P}.tgz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=media-video/vdr-1.7.13
		>=dev-libs/expat-1.95.8
		>=net-misc/curl-7.15.1-r1"

RDEPEND="${DEPEND}"

PATCHES=("${FILESDIR}/${P}-gentoo.diff")

src_install() {
	vdr-plugin_src_install

	insinto /etc/vdr/plugins/rssreader
	doins "${S}/rssreader/rssreader.conf"
}
