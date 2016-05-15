# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit vdr-plugin-2 git-r3

EGIT_REPO_URI="git://github.com/FernetMenta/vdr-plugin-vnsiserver.git"

DESCRIPTION="VDR plugin: VNSI Streamserver Plugin (FernetMenta branch)"
HOMEPAGE="https://github.com/FernetMenta/vdr-plugin-vnsiserver"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=media-video/vdr-1.7.14"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_prepare() {
	vdr-plugin-2_src_prepare

	fix_vdr_libsi_include demuxer.c
	fix_vdr_libsi_include videoinput.c
}

src_install() {
	vdr-plugin-2_src_install

	insinto /etc/vdr/plugins/vnsiserver
	doins vnsiserver/allowed_hosts.conf
	diropts -gvdr -ovdr
}
