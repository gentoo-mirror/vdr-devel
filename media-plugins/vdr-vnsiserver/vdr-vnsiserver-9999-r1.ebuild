# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

RESTRICT=""

inherit vdr-plugin

DESCRIPTION="VDR plugin: VNSI Streamserver Plugin"
HOMEPAGE="http://xbmc.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

pkg_setup() {

	eerror "vdr-vnsiserver is dead on upstream"
	eerror "project has changed to:"
	eerror "https://github.com/pipelka/vdr-plugin-xvdr"
	eerror "See detailed info for this"
	eerror "https://github.com/pipelka/vdr-plugin-vnsiserver/blob/master/README"
	eerror "Please use media-plugins/vdr-xvdr from portage"

	die || "dead on upstream, use media-plugins/vdr-xvdr"
}
