# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit vdr-plugin

DESCRIPTION="VDR Plugin: output device for the 'Full Featured' Card"
HOMEPAGE="http://www.tvdr.de/"
SRC_URI="ftp://ftp.tvdr.de/vdr/Developer/vdr-${PV}.tar.bz2"

KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND="=media-video/vdr-1.7.11"
RDEPEND="${DEPEND}"

S="${WORKDIR}/vdr-${PV}/PLUGINS/src/${VDRPLUGIN}"