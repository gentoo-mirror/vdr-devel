# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font vdr-plugin-2

DESCRIPTION="VDR Plugin: A VDR skinning engine that displays XML based Skins"
HOMEPAGE="https://github.com/vdr-projects/vdr-plugin-skindesigner"
SRC_URI="https://github.com/vdr-projects/vdr-plugin-skindesigner/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+ Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

FONT_SUFFIX="ttf"
FONT_S="${S}/fonts/VDROpenSans"

DEPEND=">=media-video/vdr-2.2.0
	dev-libs/libxml2
	gnome-base/librsvg
	net-misc/curl
	virtual/jpeg
	x11-libs/cairo[svg]"
RDEPEND="${DEPEND}"

S=${WORKDIR}/vdr-plugin-${VDRPLUGIN}-${PV}

# font.eclass functions:
# pkg_setup src_install pkg_postinst pkg_postrm

pkg_setup() {
	vdr-plugin-2_pkg_setup
	font_pkg_setup
}

src_install() {
	vdr-plugin-2_src_install
	font_src_install
}

pkg_postinst() {
	vdr-plugin-2_pkg_postinst
	font_pkg_postinst

	elog "To properly use the skins provided by \"skindesigner\", please follow the most important hints from the README:\n"

	elog "For S2-6400 Users: Disable High Level OSD, otherwise the plugin will not be"
	elog "loaded because lack of true color support\n"

	elog "For Xine-Plugin Users: Set \"Blend scaled Auto\" as OSD display mode to achieve"
	elog "an suitable true color OSD.\n"

	elog "For Xineliboutput Users: Start vdr-sxfe with the --hud option enabled\n"

	elog "If you want \"skindesigner\" to use Channel Logos, please read the \"Channel Logos\" section in the README file.\n"
}

pkg_postrm() {
	vdr-plugin-2_pkg_postrm
	font_pkg_postrm
}
