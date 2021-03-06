# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit vdr-plugin-2

HG_REVISION="29b7b5f231c8"
HG_REVISION_DATE="20120815"

DESCRIPTION="VDR Plugin: SoftCAM"
HOMEPAGE="http://www.vdr-wiki.de/wiki/index.php/Sc-plugin"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tar.gz"
#SRC_URI="http://85.17.209.13:6100/archive/${HG_REVISION}.tar.gz -> vdr-sc-0.9.3.${HG_REVISION_DATE}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+cardclient +conax +constcw +cryptoworks +irdeto +nagra +nds
		+sc-conax +sc-cryptoworks +sc-irdeto +sc-nagra +sc-seca
		+sc-viaccess +sc-videoguard2 +seca +shl +viaccess
		dvbsddevice dvbhddevice
		cpu_flags_x86_3dnow cpu_flags_x86_mmx
		cpu_flags_x86_sse cpu_flags_x86_sse2"

DEPEND=">=media-video/vdr-1.7.21
	>=dev-libs/openssl-0.9.7:*
	dvbsddevice? ( >=media-plugins/vdr-dvbsddevice-0.0.5-r1 )
	dvbhddevice? ( >=media-plugins/vdr-dvbhddevice-0.0.4_p20120614 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/sc-${HG_REVISION}"

# dirty fix, fails on more jobserver on FFdecsa
export MAKEOPTS="-j1"

src_configure() {
	# plugin dvbsddevice/dvbhddevice with transfermode support
	export "WITH_DVBSDDEVICE=$(usex dvbsddevice 1 0)"
	export "WITH_DVBHDDEVICE=$(usex dvbhddevice 1 0)"
}

src_prepare() {
	# fix bug 987654 by restoring pre-GCC5 inline semantics
	append-cflags -std=gnu89

	vdr-plugin-2_src_prepare

	if has_version ">=media-video/vdr-2.1.3"; then
		sed -i device.c -e "s:MAXDVBDEVICES:MAXDEVICES:"
	fi

	if has_version ">=media-video/vdr-2.1.4"; then
		eapply "${FILESDIR}"/vdr-sc-0.9.3.20120815_vdr-2.1.4_compilefix.diff
	fi

	sed -e 's:^SINCLUDES += :&-I/usr/include/vdr :' \
		-e 's:^LIBDIR.*$:LIBDIR = ${S}:' \
		-i  Makefile.system || "sed Makefile.system failed"

	sed -e "s: -march=\$(CPUOPT)::" \
		-e "s:\$(CSAFLAGS):\$(CXXFLAGS):" \
		-e "s:ci.c:ci.h:" \
		-i Makefile || die "sed Makefile failed"

	sed -e "s:FLAGS:CXXFLAGS:" \
		-i FFdecsa/Makefile || die "sed FFdecsa Makefile failed"

	sed -e "s:\"../dvbsddevice/dvbsdffdevice.h\":<dvbsdffdevice.h>:" \
		-i device-sd.c || die "sed device-sd.c failed"
	sed -e "s:\"../dvbhddevice/dvbhdffdevice.h\":<dvbhdffdevice.h>:" \
		-i device-hd.c || die "sed device-hd.c failed"

	# Prepare flags for FFdeCSA
	if [ -n "${VDR_SC_PARALLEL}" ]; then
		PARALLEL="${VDR_SC_PARALLEL}"
	else
		# [32/64] Core2 (SSSE3) achieves best results with SSE2 & SSE
		# [64] Athlon64 (SSE2) does much better with 64_LONG
		# [32] Athlon64 (SSE2) does best with MMX
		# [32] Pentium4 & Atom (SSE2) work best with SSE2 & SSE
		# [32] AthlonXP (SSE) has MMX faster

		# To avoid parsing -march=, we use ugly assumption that Intels don't
		# have 3dnow and AMDs do. SSE achieves good results only on Intel CPUs,
		# and LONG is best on 64-bit AMD CPUs.

	if ! use cpu_flags_x86_3dnow && use cpu_flags_x86_sse2; then
		PARALLEL=PARALLEL_128_SSE2
	elif ! use cpu_flags_x86_3dnow && use cpu_flags_x86_sse; then
		PARALLEL=PARALLEL_128_SSE
	elif use amd64; then
		PARALLEL=PARALLEL_64_LONG
	elif use cpu_flags_x86_mmx; then
		PARALLEL=PARALLEL_64_MMX
	else
	# fallback values:
	# PARALLEL_32_INT fails with gcc4.4 on x86&amd64
	# PARALLEL_64_2INT fails with gcc4.4 on x86
	# PARALLEL_128_4INT seems to be the fastest non-failing fallback

		PARALLEL=PARALLEL_128_4INT
	fi

		ewarn "VDR_SC_PARALLEL not set, guessing value from USEflags (${PARALLEL})."
		ewarn "This setting may be suboptimal, so you'll probably want to tweak it yourself."
		ewarn "More info in docs/FFdecsa/how_to_compile.txt."
	fi

	export PARALLEL

	eapply -p0 "${FILESDIR}/${P}_makefile.diff"

	#gcc-5 compile fix
	sed -e "s:int config:unsigned int config:" -i log.c

	# Remove unwanted plugins
	cd systems/ || die "cd systems/ failed"

	local fl
	for fl in *; do

	# Remember to update IUSE when bumping!
		if ! use "${fl}"; then
			einfo "Removing ${fl} plugin"
			rm -r -- "${fl}"
		fi
	done
}

src_install() {
	vdr-plugin-2_src_install

	exeinto "${VDR_PLUGIN_DIR}"
	doexe libsc-*.so.* || die "doexe failed"

	docinto FFdecsa
	nonfatal dodoc FFdecsa/docs/*

	docinto examples
	nonfatal dodoc examples/*
}

pkg_postinst() {
	vdr-plugin-2_pkg_postinst

	elog "This software might be illegal in some countries or violate"
	elog "rules of your DVB provider"
	elog "Please respect these rules."
	elog
	elog "We do not offer support of any kind"
	elog "Asking for keys or for installation help will be ignored by gentoo developers!"
	elog
}
