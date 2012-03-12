# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit vdr-plugin

DESCRIPTION="VDR Plugin: will replace the noepg-patch with the new cEpgHandler"
HOMEPAGE="https://github.com/flensrocker/vdr-plugin-noepg"
SRC_URI="https://github.com/downloads/flensrocker/vdr-plugin-noepg/${P}.tgz"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-1.7.26"
RDEPEND="${DEPEND}"
