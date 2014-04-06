# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vdr-plugin-2

DESCRIPTION="VDR Plugin: integrates SAT>IP network devices seamlessly into VDR"
HOMEPAGE="http://www.saunalahti.fi/~rahrenbe/vdr/satip/"
SRC_URI="http://www.saunalahti.fi/~rahrenbe/vdr/satip/files/${P}.tgz"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-2.1.4
		net-misc/curl
		|| ( dev-libs/pugixml
			dev-libs/tinyxml )"
RDEPEND="${DEPEND}"

src_prepare() {
	vdr-plugin-2_src_prepare

	if has_version "dev-libs/tinyxml" ; then
		sed "s:#SATIP_USE_TINYXML:SATIP_USE_TINYXML:" Makefile
		#BUILD_PARAMS+=" SATIP_USE_TINYXML = 1 "
	fi
}
