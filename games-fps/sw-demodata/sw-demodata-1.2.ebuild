# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Shadow Warrior 1.2 shareware data"
HOMEPAGE="http://legacy.3drealms.com/sw/"
SRC_URI="ftp://ftp.3drealms.com/share/3dsw12.zip"

LICENSE="SW3DR"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+fluidsynth -timidity"

RESTRICT_USE="?? ( fluidsynth timidity )"

RDEPEND="games-fps/jfsw[fluidsynth?,timidity?]"

S=${WORKDIR}

src_unpack() {
	default
	rm LICENSE.TXT || die
	mv SWSW12.SHR SWSW12.SHR.zip || die
	unpack ./SWSW12.SHR.zip
}

src_install() {
	insinto /usr/share/games/sw

	# convert to lowercase
	find . \( -iname "*.CON" -o -iname "*.DMO" -o -iname "*.RTS" -o -iname "*.GRP" -o -iname "*.PCK" -o -iname "*.INI" \) \
		-exec sh -c 'echo "${1}"
	mv "${1}" "$(echo "${1}" | tr [:upper:] [:lower:])"' - {} \;

	doins sw.rts sw.grp modem.pck ultramid.ini

	dodoc FILE_ID.DIZ CREDITS.TXT
}

pkg_postinst() {
	echo
	einfo "Please note that addons for Shadow Warrior require the registered version!"
	einfo "This version is available free of charge from Steam and GoG"
	echo
}
