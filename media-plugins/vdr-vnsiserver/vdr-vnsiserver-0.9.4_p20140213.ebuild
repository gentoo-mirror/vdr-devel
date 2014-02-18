# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vdr-plugin-2 git-2

GIT_REVISION="71e5b8c1da7acf726d00bde30da8554662cf97e1"
GIT_DATE="20140213"

EGIT_REPO_URI="git://github.com/opdenkamp/xbmc-pvr-addons.git"
EGIT_SOURCEDIR="${WORKDIR}"
EGIT_COMMIT="${GIT_REVISION}"

DESCRIPTION="VDR plugin: VNSI Streamserver Plugin (Opdenkamp branch)"
HOMEPAGE="https://github.com/opdenkamp/xbmc-pvr-addons"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

DEPEND=">=media-video/vdr-1.7.14"
RDEPEND="${DEPEND}
		=media-plugins/xbmc-addon-pvr-0.0.1_p20140213"
# Maintainer, please add also media-plugins/xbmc-addon-pvr with the same patchlevel
# to the tree, so it is guaranteed that the server and the addon fit together

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
