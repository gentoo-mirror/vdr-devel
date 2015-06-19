# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vdr-plugin-2

GIT_REVISION="b38c057267c53b93137a422c14d86236788dc121"
GIT_DATE="20140220"

DESCRIPTION="VDR Plugin: VDR OSD on TFT"
HOMEPAGE="http://projects.vdr-developer.org/projects/plg-graphtftng"
SRC_URI="http://projects.vdr-developer.org/git/vdr-plugin-graphtftng.git/snapshot/vdr-plugin-graphtftng-${GIT_REVISION}.tar.bz2 ->
		${P}.tar.bz2"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="GPL-2"

IUSE_THEMES="+theme_deepblue theme_avp"
IUSE="${IUSE_THEMES} graphtft-fe touchscreen X"

DEPEND=">=media-video/vdr-2.0.0[graphtft]
		media-libs/imlib2[jpeg,png]
		gnome-base/libgtop
		>=virtual/ffmpeg-0.4.8_p20090201
		graphtft-fe? ( media-libs/imlib2[jpeg,png,X] )
		!media-plugins/vdr-graphtft"
# rdepend for X install missing here!
RDEPEND="${DEPEND}"

PDEPEND="theme_deepblue? ( >=x11-themes/vdrgraphtft-deepblue-0.3.1 )
		theme_avp? ( >=x11-themes/vdrgraphtft-avp-0.3.1 )"

# use depends unclear :(
#REQUIRED_USE="graphtft-fe? ( !X )
#			X? ( !graphtft-fe )"

PATCHES=( "${FILESDIR}/${P}_gentoo.diff" )

S="${WORKDIR}/vdr-plugin-graphtftng-${GIT_REVISION}"

src_prepare() {

	use touchscreen && sed -i Makefile  \
		-e "s:#WITH_TOUCH = 1:WITH_TOUCH = 1:"

	! use graphtft-fe && sed -i Makefile \
		-e "s:WITH_TCPCOM = 1:#WITH_TCPCOM:"

	! use X && sed -i Makefile \
		-e "s:WITH_X = 1:#WITH_X:"

	vdr-plugin-2_src_prepare

	sed -i Makefile -e "s:-I\$(VDRINCDIR)::"

	# UINT64_C is needed by ffmpeg headers
	append-cxxflags -D__STDC_CONSTANT_MACROS
}

src_install() {
	vdr-plugin-2_src_install

	dodoc "${S}"/documents/{README,HISTORY,README.themes}

	if use graphtft-fe; then
		cd "${S}"/graphtft-fe
		dobin graphtft-fe
		doinitd "${FILESDIR}/graphtft-fe"
	fi
}

pkg_postinst() {
	vdr-plugin-2_pkg_postinst

	if use graphtft-fe; then
		einfo "Graphtft-fe user:"
		einfo "Edit /etc/conf.d/vdr.graphtftng"
		einfo "/etc/init.d/graphtft-fe start"
	fi
}
