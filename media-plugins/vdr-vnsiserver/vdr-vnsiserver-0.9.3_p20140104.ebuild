# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit vdr-plugin-2 git-2

GIT_REVISION="9021115ddb5c28a5afe351fff3e848a106a6df47"
GIT_DATE="20140104"

EGIT_REPO_URI="git://github.com/opdenkamp/xbmc-pvr-addons.git"
EGIT_SOURCEDIR="${WORKDIR}"
EGIT_COMMIT="${GIT_REVISION}"

DESCRIPTION="VDR plugin: VNSI Streamserver Plugin (Odenkamp branch)"
HOMEPAGE="https://github.com/opdenkamp/xbmc-pvr-addons"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=media-video/vdr-1.7.14"
RDEPEND="${DEPEND}"

S="${WORKDIR}/addons/pvr.vdr.vnsi/vdr-plugin-vnsiserver"

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
