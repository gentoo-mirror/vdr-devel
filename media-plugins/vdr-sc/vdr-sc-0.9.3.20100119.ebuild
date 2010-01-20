# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

RESTRICT="mirror"

inherit vdr-plugin

DESCRIPTION="VDR Plugin: SoftCAM"
HOMEPAGE="http://207.44.152.197/vdr2.htm#sc"
#SRC_URI="http://207.44.152.197/${P}.tar.gz"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="3dnow +cardclient +conax +constcw +cryptoworks +irdeto mmx
	+nagra +nds +sc-conax +sc-cryptoworks +sc-irdeto +sc-nagra +sc-seca
	+sc-viaccess +sc-videoguard2 +seca +shl sse sse2 +viaccess"

DEPEND=">=media-video/vdr-1.7.11
	>=dev-libs/openssl-0.9.7"
RDEPEND="${DEPEND}"

src_prepare() {
	vdr-plugin_src_prepare

	# Respect environment CXXFLAGS in FFdeCSA
	epatch "${FILESDIR}"/${P}-makefile-csaflags.diff

	# This is needed in order to compile viaccess plugin
	sed -i -e 's:^SINCLUDES += :&-I/usr/include/vdr :' \
		Makefile.system || die "sed failed"

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

		if ! use 3dnow && use sse2; then
			PARALLEL=PARALLEL_128_SSE2
		elif ! use 3dnow && use sse; then
			PARALLEL=PARALLEL_128_SSE
		elif use amd64; then
			PARALLEL=PARALLEL_64_LONG
		elif use mmx; then
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

src_test() {
	cd FFdecsa/ || die "cd failed"

	# We don't need to care about PARALLEL or FLAGS, FFdecsa itself is already
	# compiled and FFdecsa_test uses almost no code of its' own.

	emake FLAGS="${CXXFLAGS}" FFdecsa_test || die "emake failed"
	./FFdecsa_test || die "FFdeCSA selftest failed, please try other VDR_SC_PARALLEL"
}

src_install() {
	vdr-plugin_src_install

	exeinto "${VDR_PLUGIN_DIR}"
	doexe libsc-*.so.* || die "doexe failed"

	docinto FFdecsa
	dodoc FFdecsa/docs/* || die "dodoc FFdecsa failed"

	docinto examples
	dodoc examples/* || die "dodoc examples failed"
}

pkg_postinst() {
	vdr-plugin_pkg_postinst

	elog "To use this Software is perhaps in some countries, illegal,"
	elog "or disturb their rule against DVB provider."
	elog "Please respect these rules."
	echo
	elog "We will support anything"
	elog "Ask for keys or for the installation help are ignored by gentoo developer."
}

