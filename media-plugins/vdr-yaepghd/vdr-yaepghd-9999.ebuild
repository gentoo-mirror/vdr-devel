# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit vdr-plugin git-2

DESCRIPTION="yaepghd plugin for nice epg"
HOMEPAGE="http://projects.vdr-developer.org/projects/show/plg-yaepghd"
SRC_URI=""
EGIT_REPO_URI="git://projects.vdr-developer.org/vdr-plugin-yaepghd.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="media-video/vdr[yaepg]"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}/operands.patch"
	vdr-plugin_src_prepare
}

src_install() {
	vdr-plugin_src_install

	dodir /etc/vdr/plugins || die
	insinto /etc/vdr/plugins
	doins -r yaepghd || die
	fowners -R vdr:vdr /etc/vdr || die
}