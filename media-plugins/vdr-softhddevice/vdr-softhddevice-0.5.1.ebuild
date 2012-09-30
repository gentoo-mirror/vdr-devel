# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit flag-o-matic toolchain-funcs vdr-plugin-2

VERSION="1000" # every bump, new version

DESCRIPTION="VDR Plugin: Software and GPU emulated HD output device"
HOMEPAGE="http://projects.vdr-developer.org/projects/show/plg-softhddevice"
SRC_URI="mirror://vdr-developerorg/${VERSION}/${P}.tgz"
KEYWORDS="~amd64 ~x86"

LICENSE="AGPL-3"
SLOT="0"
IUSE="alsa jpeg opengl oss vaapi vdpau yaepg xscreensaver"

DEPEND=">=media-video/vdr-1.7
		>=virtual/ffmpeg-0.7
		x11-libs/libX11
		>=x11-libs/libxcb-1.8
		x11-libs/xcb-util-wm
		virtual/pkgconfig
		opengl? ( virtual/opengl )
		alsa? ( media-libs/alsa-lib )
		vdpau? ( x11-libs/libvdpau )
		vaapi? ( x11-libs/libva[opengl?] )
		alsa? ( media-libs/alsa-lib )
		yaepg? ( >=media-video/vdr-1.7[yaepg] )"
RDEPEND="${DEPEND}"
RDEPEND="x11-libs/xcb-util
		sys-devel/gettext
		jpeg? ( virtual/jpeg )"

VDR_CONFD_FILE="${FILESDIR}/confd-${PV}"
VDR_RCADDON_FILE="${FILESDIR}/rc-addon-${PV}.sh"

src_prepare() {
	vdr-plugin-2_src_prepare

	epatch "${FILESDIR}/${P}_Makefile.patch"
}

src_compile() {
	local myconf

	myconf+=" ALSA=$(usex alsa 1 0)"
	myconf+=" JPEG=$(usex jpeg 1 0)"
	myconf+=" GLX=$(usex opengl 1 0)"
	myconf+=" OSS=$(usex oss 1 0)"
	myconf+=" VAAPI=$(usex vaapi 1 0)"
	myconf+=" VDPAU=$(usex vdpau 1 0)"
	myconf+=" YAEPG=$(usex yaepg 1 0)"
	myconf+=" SCREENSAVER=$(usex xscreensaver 1 0)" # FIXME: screensaver is currently always enabled

	append-cflags -DHAVE_PTHREAD_NAME
	append-cxxflags -DHAVE_PTHREAD_NAME
	tc-export CC CXX

	emake all LIBDIR="." $myconf || die "emake failed"
}