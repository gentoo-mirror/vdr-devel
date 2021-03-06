# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit vdr-plugin-2

GIT_REVISION="5dc5601576c617516ec41c9c4899d3e18c0cc030"
#GIT_DATE="20150310" #yyyymmdd

DESCRIPTION="VDR Plugin: Software and GPU emulated HD output device"
HOMEPAGE="http://projects.vdr-developer.org/projects/show/plg-softhddevice"
SRC_URI="http://projects.vdr-developer.org/git/vdr-plugin-softhddevice.git/snapshot/vdr-plugin-softhddevice-${GIT_REVISION}.tar.bz2"
KEYWORDS="~amd64 ~x86"

LICENSE="AGPL-3"
SLOT="0"
IUSE="alsa debug opengl oss vaapi vdpau -xscreensaver"

RDEPEND=">=media-video/vdr-2
	x11-libs/libX11
	>=x11-libs/libxcb-1.8
	x11-libs/xcb-util-wm
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	alsa? ( media-libs/alsa-lib )
	opengl? ( virtual/opengl )
	vaapi? ( x11-libs/libva
			virtual/ffmpeg[vaapi] )
	vdpau? ( x11-libs/libvdpau
			virtual/ffmpeg[vdpau] )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-libs/xcb-util"

REQUIRED_USE="opengl? ( vaapi )
			|| ( vaapi vdpau )
			|| ( alsa oss )"

VDR_CONFD_FILE="${FILESDIR}/confd-0.6.0"
VDR_RCADDON_FILE="${FILESDIR}/rc-addon-0.6.0.sh"

S="${WORKDIR}/vdr-plugin-softhddevice-${GIT_REVISION}"

pkg_setup() {
	vdr-plugin-2_pkg_setup

	append-cppflags -DHAVE_PTHREAD_NAME

	use debug && append-cppflags -DDEBUG -DOSD_DEBUG
}

src_prepare() {
	vdr-plugin-2_src_prepare

	BUILD_PARAMS+=" ALSA=$(usex alsa 1 0)"
	BUILD_PARAMS+=" OPENGL=$(usex opengl 1 0)"
	BUILD_PARAMS+=" OSS=$(usex oss 1 0)"
	BUILD_PARAMS+=" VAAPI=$(usex vaapi 1 0)"
	BUILD_PARAMS+=" VDPAU=$(usex vdpau 1 0)"
	BUILD_PARAMS+=" SCREENSAVER=$(usex xscreensaver 1 0)"

	if has_version ">=media-video/ffmpeg-0.8"; then
		BUILD_PARAMS+=" SWRESAMPLE=1"
	fi

	if has_version ">=media-video/libav-0.8"; then
		BUILD_PARAMS+=" AVRESAMPLE=1"
	fi
}
