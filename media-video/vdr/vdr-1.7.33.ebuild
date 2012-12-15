# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/vdr/vdr-1.6.0_p1.ebuild,v 1.6 2008/05/21 05:50:50 zzam Exp $

EAPI="5"

inherit eutils flag-o-matic multilib toolchain-funcs

# Switches supported by extensions-patch
EXT_PATCH_FLAGS="alternatechannel ddepgentry dvlvidprefer graphtft jumpplay
	liemikuutio lircsettings mainmenuhooks menuorg naludump
	rotor setup ttxtsubs volctrl wareagleicon yaepg"
# pinplugin, broken yet

# names of the use-flags
EXT_PATCH_FLAGS_RENAMED=""

# names ext-patch uses internally, here only used for maintainer checks
EXT_PATCH_FLAGS_RENAMED_EXT_NAME="jumpingseconds"

IUSE="debug html vanilla dxr3 ${EXT_PATCH_FLAGS} ${EXT_PATCH_FLAGS_RENAMED}"

MY_PV="${PV%_p*}"
MY_P="${PN}-${MY_PV}"
S="${WORKDIR}/${MY_P}"

EXT_P="extpng-${P}-gentoo-edition-v11"

DESCRIPTION="Video Disk Recorder - turns a pc into a powerful set top box for DVB"
HOMEPAGE="http://www.tvdr.de/"
SRC_URI="ftp://ftp.tvdr.de/vdr/Developer/${MY_P}.tar.bz2
	http://dev.gentoo.org/~hd_brummy/distfiles/${EXT_P}.patch.bz2"

KEYWORDS="~arm ~amd64 ~ppc ~x86"
SLOT="0"
LICENSE="GPL-2"

REQUIRED_USE="setup? ( !menuorg )
	menuorg? ( !setup )"

COMMON_DEPEND="virtual/jpeg
	sys-libs/libcap
	>=media-libs/fontconfig-2.4.2
	>=media-libs/freetype-2
	setup? ( >=dev-libs/tinyxml-2.6.1[stl] )"

DEPEND="${COMMON_DEPEND}
	>=virtual/linuxtv-dvb-headers-5.3
	sys-devel/gettext"

RDEPEND="${COMMON_DEPEND}
	dev-lang/perl
	>=media-tv/gentoo-vdr-scripts-0.4.10
	media-fonts/corefonts"

# pull in vdr-setup to get the xml files, else menu will not work
PDEPEND="setup? ( >=media-plugins/vdr-setup-0.3.1-r3 )
		dxr3? ( >=media-plugins/vdr-dxr3-0.2.13 )"

CONF_DIR=/etc/vdr
CAP_FILE=${S}/capabilities.sh
CAPS="# Capabilities of the vdr-executable for use by startscript etc."

pkg_setup() {
	if [ -n "${VDR_LOCAL_PATCHES_DIR}" ]; then
		eerror "Using VDR_LOCAL_PATCHES_DIR is deprecated!"
		eerror "Please move all your patches into"
		eerror "${EROOT}/etc/portage/patches/${CATEGORY}/${P}"
		eerror "and remove or unset the VDR_LOCAL_PATCHES_DIR variable."
		die
	fi

	use debug && append-flags -g
	PLUGIN_LIBDIR="/usr/$(get_libdir)/vdr/plugins"

	tc-export CC CXX
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
	done
}

extensions_add_make_conf()
{
	# copy all ifdef for extensions-patch to Make.config
	sed -e '1,/need to touch the following:/d' \
		-e '/ifdef DVBDIR/,/^$/d' \
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

src_prepare() {
	#applying maintainace-patches

	ebegin "Changing pathes for gentoo"

	sed \
	  -e 's-ConfigDirectory = VideoDirectory;-ConfigDirectory = CONFDIR;-' \
	  -i vdr.c

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
		eerror "DVB header files do not contain s2api support or to old for ${P}"
		eerror "You cannot compile VDR against old dvb-headers"
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
		VIDEODIR		= /var/vdr/video
		LOCDIR			= \$(PREFIX)/share/locale

		DEFINES			+= -DCONFDIR=\"\$(CONFDIR)\"
		INCLUDES		+= -I\$(DVBDIR)

	EOT
	eend 0

	epatch "${FILESDIR}/${PN}-1.7.22-makefile-install-header.diff"
	epatch "${FILESDIR}/${PN}-1.7.27_linguas-v2.diff"
	epatch "${FILESDIR}/${P}_parallelmake.patch"

	# Do not install runvdr script and plugins
	sed -i Makefile \
		-e 's/runvdr//' \
		-e 's/ install-plugins//'

	if ! use vanilla; then
		# Now apply extensions patch
		epatch "${WORKDIR}/${EXT_P}.patch"

		# This allows us to start even if some plugin does not exist
		# or is not loadable.
		enable_patch PLUGINMISSING
		enable_patch CHANNELBIND

		# was default enabled in old versions of extpatch
		enable_patch MCLI

		if [[ -n ${VDR_MAINTAINER_MODE} ]]; then
			einfo "Doing maintainer checks:"

			# these patches we do not support
			# (or have them already hard enabled)
			local IGNORE_PATCHES="pluginmissing mcli channelbind"

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

		# patches that got renamed
		use liemikuutio && enable_patch jumpingseconds

		eend 0

		extensions_add_make_conf

		ebegin "Make depend"
		emake .dependencies >/dev/null
		eend $? "make depend failed"
	fi

	epatch_user

	if [[ -n "${VDRSOURCE_DIR}" ]]; then
		cp -r "${S}" "${T}"/source-tree
	fi

	add_cap CAP_UTF8

	add_cap CAP_IRCTRL_RUNTIME_PARAM \
			CAP_VFAT_RUNTIME_PARAM \
			CAP_CHUID \
			CAP_SHUTDOWN_AUTO_RETRY

	echo -e ${CAPS} > "${CAP_FILE}"

	# some new improvments for LINGUAS handling
	einfo "\n \t VDR supports the LINGUAS values"

	lang_po

	einfo "\t Please set one of this values in /etc/make.conf or /etc/portage/make.conf"
	einfo "\t LINGUAS=\"${LING_PO}\"\n"

	if [[ -z ${LINGUAS} ]]; then
		eerror "\n \t No values in LINGUAS="
		eerror "\t you will get only english text on OSD \n"
	fi

	strip-linguas ${LING_PO} en
}

src_install() {
	# trick makefile not to create a videodir by supplying it with an existing
	# directory
	emake install DESTDIR="${D}" VIDEODIR="/" || die "emake install failed"

	keepdir "${CONF_DIR}"/plugins
	keepdir "${CONF_DIR}"/themes

	keepdir "${PLUGIN_LIBDIR}"

	exeinto /usr/share/vdr/bin

	if use html; then
		dohtml *.html
	fi

	dodoc MANUAL INSTALL README* HISTORY CONTRIBUTORS

	insinto /usr/share/vdr
	doins "${CAP_FILE}"

	if [[ -n "${VDRSOURCE_DIR}" ]]; then
		local SOURCES_DEST="${VDRSOURCE_DIR}/${P/_p/-}"
		einfo "Installing sources"
		insinto "${SOURCES_DEST}"
		doins -r "${T}"/source-tree/*
		keepdir "${SOURCES_DEST}"/PLUGINS/lib
	fi

	if use alternatechannel; then
		insinto /etc/vdr
		doins "${FILESDIR}"/channel_alternative.conf
	fi

	if use setup; then
		insinto /usr/share/vdr/setup
		doins "${S}"/menu.c
	fi
	chown -R vdr:vdr "${D}/${CONF_DIR}"
}

pkg_preinst() {
	has_version "<${CATEGORY}/${PN}-1.6.0_p2-r8"
	previous_less_than_1_6_0_p2_r8=$?

	has_version "<${CATEGORY}/${PN}-1.7.27"
	previous_less_than_1_7_27=$?
}

pkg_postinst() {
	elog "This is a *developer* version."
	elog "We strongly recommend that you only use it under controlled"
	elog "conditions and for testing and debugging."

	if [[ previous_less_than_1_6_0_p2_r8=$? = 0 ]] ; then
		elog "  Upgrade Info:"

		elog "  The recording format is now Transport Stream. Existing recordings in PES format"
		elog "  can still be replayed and edited, but new recordings are done in TS."

		elog "  The support for full featured DVB cards of the TT/FuSi design has been moved"
		elog "  into the new plugins 'dvbsddevice' 'dvbhddevice'. On systems that use such a card as their"
		elog "  primary device, this plugin now needs to be loaded when running VDR in order"
		elog "  to view live or recorded video. If the plugin is not loaded, the card will"
		elog "  be treated like a budget DVB card, and there will be no OSD or viewing"
		elog "  capability."

		elog "  The index file for TS recordings is now regenerated on-the-fly if a"
		elog "  recording is replayed that has no index. This can also be used to"
		elog "  re-create a broken index file by manually deleting the index file and then"
		elog "  replaying the recording."

		elog "  The files \"commands.conf\" and \"reccmd.conf\" can now contain nested lists of"
		elog "  commands. See man vdr.5 for information about the new file format."

		elog "  The option \"Setup/DVB/Use Dolby Digital\" now only controls whether Dolby Digital"
		elog "  tracks appear in the 'Audio' menu. Dolby Digital is always recorded"

		elog "  The default SVDRP port is now 6419"
	fi

	if [[ previous_less_than_1_7_27=$? = 0 ]] ; then
		elog "In vdr releases >=vdr-1.7.27 the depricated i18n handling is removed"
		elog "This results now in a lot of not working plugins on compile process"
		elog "Please visit for more infos:"
		elog "https://bugs.gentoo.org/show_bug.cgi?id=414177"
		elog "and depended bugs"
	fi

	elog "It is a good idea to run vdrplugin-rebuild now."

	if use setup; then
		if ! has_version media-plugins/vdr-setup || \
			! egrep -q '^setup$' "${ROOT}/etc/conf.d/vdr.plugins"; then

			echo
			ewarn "You have compiled media-video/vdr with USE=\"setup\""
			ewarn "It is very important to emerge media-plugins/vdr-setup now!"
			ewarn "and you have to loaded it in /etc/conf.d/vdr.plugins"
		fi
	fi

	local keysfound=0
	local key
	local warn_keys="JumpFwd JumpRew JumpFwdSlow JumpRewSlow"
	local remote_file="${ROOT}"/etc/vdr/remote.conf

	if [[ -e ${remote_file} ]]; then
		for key in ${warn_keys}; do
			if grep -q -i "\.${key} " "${remote_file}"; then
				keysfound=1
				break
			fi
		done
		if [[ ${keysfound} == 1 ]]; then
			ewarn "Your /etc/vdr/remote.conf contains keys which are no longer usable"
			ewarn "Please remove these keys or vdr will not start:"
			ewarn "#  ${warn_keys}"
		fi
	fi

	elog "To get nice symbols in OSD we recommend to install"
	elog "\t1. emerge media-fonts/vdrsymbols-ttf"
	elog "\t2. select font VDRSymbolsSans in Setup"
	elog ""
	elog "To get an idea how to proceed now, have a look at our vdr-guide:"
	elog "\thttp://www.gentoo.org/doc/en/vdr-guide.xml"
}
