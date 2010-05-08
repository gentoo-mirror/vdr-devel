# Copyright 2004-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit vdr-plugin eutils

DESCRIPTION="VDR Plugin: displaying, recording and replaying teletext based subtitles"
HOMEPAGE="http://projects.vdr-developer.org/projects/show/plg-ttxtsubs"
SRC_URI="http://projects.vdr-developer.org/attachments/download/309/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-1.7.13[ttxtsubs]"
RDEPEND="${DEPEND}"
