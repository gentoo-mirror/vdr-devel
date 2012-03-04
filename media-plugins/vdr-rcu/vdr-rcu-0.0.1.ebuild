# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit vdr-plugin

DESCRIPTION="VDR plugin: Remote Control Unit consists mainly of an infrared receiver, controlled by a PIC 16C84"
HOMEPAGE="http://www.tvdr.de/remote.htm"
SRC_URI="mirror://gentoo/${P}.tar.gz
		http://dev.gentoo.org/~hd_brummy/distfiles/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-1.7.25"
