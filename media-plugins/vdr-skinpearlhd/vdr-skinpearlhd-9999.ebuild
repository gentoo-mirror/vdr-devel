# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit git-2

DESCRIPTION="VDR PearlHD Skin"
HOMEPAGE="http://projects.vdr-developer.org/projects/skin-pearlhd/"
SRC_URI=""
EGIT_REPO_URI="git://projects.vdr-developer.org/skin-pearlhd.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="yaepg +dynamicfonts +hideoclocktext"

RDEPEND="media-plugins/vdr-text2skin"
DEPEND=""

src_prepare() {
	use hideoclocktext && sed -i Make.config -e 's:#\(HIDEOCLOCKTEXT=1\):\1:'
	use dynamicfonts && sed -i Make.config -e 's:#\(DYNAMICFONTS=1\):\1:'
	use yaepg && sed -i Make.config -e 's:#\(YAEPGHD=1\):\1:'
}

src_install() {
	emake DESTDIR="${D}" SKINDIR="/usr/share/vdr/text2skin/PearlHD" install || die
	dodoc HISTORY README
}
