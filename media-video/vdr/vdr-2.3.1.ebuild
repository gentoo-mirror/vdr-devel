# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/vdr/vdr-2.2.0.ebuild,v 1.5 2015/03/30 13:25:58 hd_brummy Exp $

EAPI=5

inherit eutils flag-o-matic multilib toolchain-funcs

# Switches supported by extensions-patch
EXT_PATCH_FLAGS="pinplugin graphtft naludump mainmenuhooks menuorg menuselection"
#tmp disabled: alternatechannel permashift_v1 pinplugin ttxtsubs (-> channels) resumereset

# names of the use-flags
EXT_PATCH_FLAGS_RENAMED=""

# names ext-patch uses internally, here only used for maintainer checks
EXT_PATCH_FLAGS_RENAMED_EXT_NAME="bidi no_kbd sdnotify"

IUSE="bidi debug +kbd html systemd vanilla ${EXT_PATCH_FLAGS} ${EXT_PATCH_FLAGS_RENAMED}"

MY_PV="${PV%_p*}"
MY_P="${PN}-${MY_PV}"
S="${WORKDIR}/${MY_P}"

EXT_P="extpng-${P}-gentoo-edition-v3"

DESCRIPTION="Video Disk Recorder - turns a pc into a powerful set top box for DVB"
HOMEPAGE="http://www.tvdr.de/"
SRC_URI="ftp://ftp.tvdr.de/vdr/Developer/${MY_P}.tar.bz2
	http://dev.gentoo.org/~hd_brummy/distfiles/${EXT_P}.patch.bz2"

KEYWORDS="~arm ~amd64 ~ppc ~x86"
SLOT="0"
LICENSE="GPL-2"

COMMON_DEPEND="virtual/jpeg:*
	sys-libs/libcap
	>=media-libs/fontconfig-2.4.2
	>=media-libs/freetype-2"

DEPEND="${COMMON_DEPEND}
	>=virtual/linuxtv-dvb-headers-5.3
	sys-devel/gettext"

RDEPEND="${COMMON_DEPEND}
	dev-lang/perl
	>=media-tv/gentoo-vdr-scripts-2.7
	media-fonts/corefonts
	bidi? ( dev-libs/fribidi )
	systemd? ( sys-apps/systemd )"

CONF_DIR=/etc/vdr
CAP_FILE=${S}/capabilities.sh
CAPS="# Capabilities of the vdr-executable for use by startscript etc."

pkg_setup() {

	use debug && append-flags -g

	PLUGIN_LIBDIR="/usr/$(get_libdir)/vdr/plugins"

	tc-export CC CXX AR
}

add_cap() {
	local arg
	for arg; do
		CAPS="${CAPS}\n${arg}=1"
	done
}

enable_patch() {
	local arg ARG_UPPER
	for arg; do
		ARG_UPPER=$(echo $arg|tr '[:lower:]' '[:upper:]')
		echo "${ARG_UPPER} = 1" >> Make.config

		# codesnippet to bring the extpng defines into the vdr.pc CXXFLAGS CFLAGS
		echo "-DUSE_${ARG_UPPER}" >> "${T}"/defines.tmp
		cat "${T}"/defines.tmp | tr \\\012 ' '  > "${T}"/defines.IUSE
		export DEFINES_IUSE=$( cat ${T}/defines.IUSE )
	done
}

extensions_add_make_conf()
{
	# copy all ifdef for extensions-patch to Make.config
	sed -e '1,/need to touch the following:/d' \
		-e '/need to touch the following/,/^$/d' \
		Make.config.template >> Make.config
}

extensions_all_defines() {
	# extract all possible settings for extensions-patch
	sed -e '/^#\?[A-Z].*= 1/!d' -e 's/^#\?//' -e 's/ .*//' \
		Make.config.template \
		| sort \
		| tr '[:upper:]' '[:lower:]'
}

lang_po() {
	LING_PO=$( ls ${S}/po | sed -e "s:.po::g" | cut -d_ -f1 | tr \\\012 ' ' )
}

src_configure() {
	# support languages, written from right to left
	export "BIDI=$(usex bidi 1 0)"
	# systemd notification support
	export "SDNOTIFY=$(usex systemd 1 0)"
	# with/without keyboard
	export "USE_KBD=$(usex kbd 1 0)"
}

src_prepare() {
	# apply maintainace-patches
	ebegin "Changing paths for gentoo"

	local DVBDIR=/usr/include
	local i
	for i in ${DVB_HEADER_PATH} /usr/include/v4l-dvb-hg /usr/include; do
		[[ -d ${i} ]] || continue
		if [[ -f ${i}/linux/dvb/dmx.h ]]; then
			einfo "Found DVB header files in ${i}"
			DVBDIR=${i}
			break
		fi
	done

	# checking for s2api headers
	local api_version
	api_version=$(awk -F' ' '/define DVB_API_VERSION / {print $3}' "${DVBDIR}"/linux/dvb/version.h)
	api_version=${api_version}*$(awk -F' ' '/define DVB_API_VERSION_MINOR / {print $3}' "${DVBDIR}"/linux/dvb/version.h)

	if [[ ${api_version:-0} -lt 5*3 ]]; then
		eerror "DVB header files do not contain s2api support or too old for ${P}"
		eerror "You cannot compile VDR against old dvb-header"
		die "DVB headers too old"
	fi

	cat > Make.config <<-EOT
		#
		# Generated by ebuild ${PF}
		#
		PREFIX			= /usr
		DVBDIR			= ${DVBDIR}
		PLUGINLIBDIR	= ${PLUGIN_LIBDIR}
		CONFDIR			= ${CONF_DIR}
#		ARGSDIR			= \$(CONFDIR)/conf.d
		VIDEODIR		= /var/vdr/video
		LOCDIR			= \$(PREFIX)/share/locale
		INCDIR			= \$(PREFIX)/include

		DEFINES			+= -DCONFDIR=\"\$(CONFDIR)\"
		INCLUDES		+= -I\$(DVBDIR)

		# >=vdr-1.7.36-r1; parameter only used for compiletime on vdr
		# PLUGINLIBDIR (plugin Makefile old) = LIBDIR (plugin Makefile new)
		LIBDIR			= ${PLUGIN_LIBDIR}
		PCDIR			= /usr/$(get_libdir)/pkgconfig

	EOT
	eend 0

	if ! use vanilla; then

		# Now apply extensions patch
		epatch "${WORKDIR}/${EXT_P}.patch"

		# This allows us to start even if some plugin does not exist
		# or is not loadable.
		enable_patch PLUGINMISSING

		if [[ -n ${VDR_MAINTAINER_MODE} ]]; then
			einfo "Doing maintainer checks:"

			# we do not support these patches
			# (or have them already hard enabled)
			local IGNORE_PATCHES="pluginmissing"

			extensions_all_defines > "${T}"/new.IUSE
			echo $EXT_PATCH_FLAGS $EXT_PATCH_FLAGS_RENAMED_EXT_NAME \
					$IGNORE_PATCHES | \
				tr ' ' '\n' |sort > "${T}"/old.IUSE
			local DIFFS=$(diff -u "${T}"/old.IUSE "${T}"/new.IUSE|grep '^[+-][^+-]')
			if [[ -z ${DIFFS} ]]; then
				einfo "EXT_PATCH_FLAGS is up to date."
			else
				ewarn "IUSE differences!"
				local diff
				for diff in $DIFFS; do
					ewarn "$diff"
				done
			fi
		fi

		ebegin "Enabling selected patches"
		local flag
		for flag in $EXT_PATCH_FLAGS; do
			use $flag && enable_patch ${flag}
		done

		eend 0

		extensions_add_make_conf

		# add defined use-flags compile options to vdr.pc
		sed -e "s:\$(CDEFINES) \$(CINCLUDES) \$(HDRDIR):\$(CDEFINES) \$(CINCLUDES) \$(HDRDIR) \$(DEFINES_IUSE):" \
			-i Makefile

		ebegin "Make depend"
		emake .dependencies >/dev/null
		eend $? "make depend failed"
	fi

	epatch "${FILESDIR}/${P}_gentoo.patch"

	# fix some makefile issues
	sed -e "s:ifndef NO_KBD:ifeq (\$(USE_KBD),1):" \
		-e "s:ifdef BIDI:ifeq (\$(BIDI),1):" \
		-e "s:ifdef SDNOTIFY:ifeq (\$(SDNOTIFY),1):" \
		-i "${S}"/Makefile

	epatch_user

	add_cap CAP_UTF8

	add_cap CAP_IRCTRL_RUNTIME_PARAM \
			CAP_VFAT_RUNTIME_PARAM \
			CAP_CHUID \
			CAP_SHUTDOWN_AUTO_RETRY

	echo -e ${CAPS} > "${CAP_FILE}"

	# LINGUAS support
	einfo "\n \t VDR supports the LINGUAS values"

	lang_po

	einfo "\t Please set one of this values in your sytem make.conf"
	einfo "\t LINGUAS=\"${LING_PO}\"\n"

	if [[ -z ${LINGUAS} ]]; then
		einfo "\n \t No values in LINGUAS="
		einfo "\t You will get only english text on OSD \n"
	fi

	strip-linguas ${LING_PO} en
}

src_install() {
	# trick makefile not to create a videodir by supplying it with an existing
	# directory
	einstall \
	VIDEODIR="/" \
	DESTDIR="${D}" install || die "emake install failed"

	keepdir "${PLUGIN_LIBDIR}"
#	keepdir "${ARGSDIR}"

	# backup for plugins they don't be able to create this dir
	keepdir "${CONF_DIR}"/plugins

	if use html; then
		dohtml *.html
	fi

	nonfatal dodoc MANUAL INSTALL README* HISTORY CONTRIBUTORS

	insinto /usr/share/vdr
	doins "${CAP_FILE}"

#	if use alternatechannel; then
#		insinto /etc/vdr
#		doins "${FILESDIR}"/channel_alternative.conf
#	fi


	chown -R vdr:vdr "${D}/${CONF_DIR}"
}

pkg_postinst() {

	eerror "WARNING:"
	eerror "========\n"

	eerror "This is a *developer* version. Even though *I* use it in my productive"
	eerror "environment, I strongly recommend that you only use it under controlled"
	eerror "conditions and for testing and debugging.\n"

	eerror "*** PLEASE BE VERY CAREFUL WHEN USING THIS DEVELOPER VERSION, ESPECIALLY"
	eerror "*** IF YOU ENABLE THE NEW SVDRP PEERING! KEEP BACKUPS OF ALL YOUR TIMERS"
	eerror "*** AND OBSERVE VERY CLOSELY WHETHER EVERYTHING WORKS AS EXPECTED. THIS"
	eerror "*** VERSION INTRODUCES SOME MAJOR CHANGES IN HANDLING GLOBAL LISTS AND"
	eerror "*** LOCKING, SO ANYTHING CAN HAPPEN! YOU HAVE BEEN WARNED!\n"

	eerror "The main focus of this developer version is on the new locking mechanism"
	eerror "for global lists, and the ability to handle remote timers."
	eerror "Any plugins that access the global lists of timers, channels, schedules"
	eerror "or recordings, will need to be adjusted (see below for details). Please"
	eerror "do initial tests with plain vanilla VDR and just the output plugin you"
	eerror "need.\n"

	elog "It is a good idea to run vdrplugin-rebuild now."

	elog "To get nice symbols in OSD we recommend to install"
	elog "\t1. emerge media-fonts/vdrsymbols-ttf"
	elog "\t2. select font VDRSymbolsSans in Setup"
	elog ""
	elog "To get an idea how to proceed now, have a look at our vdr-guide:"
	elog "\thttps://wiki.gentoo.org/wiki/VDR"
}
