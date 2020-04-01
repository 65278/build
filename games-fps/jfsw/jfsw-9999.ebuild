# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3
EGIT_REPO_URI="https://github.com/jonof/jfsw.git"

DESCRIPTION="A port of Shadow Warrior"
HOMEPAGE="http://www.jonof.id.au/jfsw/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# sdl is non optional on linux
IUSE="+vorbis +alsa fluidsynth +opengl +gtk +polymost demo"

# Todo: report bug in polymost
REQUIRED_USE="
	polymost? ( opengl )
"

# there are no tests
RESTRICT="test"

BDEPEND="
	virtual/pkgconfig
"

DEPEND="
	vorbis? ( media-libs/libvorbis )
	alsa? (
		media-libs/alsa-lib
		media-libs/libsdl2[alsa]
	)
	|| (
		media-libs/libsdl2[sound,video,X,opengl?]
		media-libs/libsdl2[sound,video,wayland,opengl?]
	)
	gtk?
	( ||
		(
			>=x11-libs/gtk+-3.4.0[X]
			>=x11-libs/gtk+-3.4.0[wayland]
		)
	)
	fluidsynth? ( media-sound/fluidsynth )
"

RDEPEND="
	${DEPEND}
	demo? ( games-fps/sw-demodata )
	fluidsynth? ( media-sound/fluid-soundfont )
"

src_prepare()
{
	# EROOT is reserved by portage
	sed "s/EROOT/JFROOT/" -i "${S}/Makefile" || \
		die "Failed to set game build path"

	# force build to respect cflags
	sed "s/debug=.*/debug=/" -i "${S}/Makefile" "${S}/jfbuild/Makefile" || \
		die "Failed to fix cflags"

	# Hacks around autoenabling features with pkgconfig
	if ! use gtk
	then
		sed "s/HAVE_GTK=1/HAVE_GTK=0/" -i "${S}/jfbuild/Makefile.shared" || \
			die "Failed to disable GTK!"
	fi

	if ! use alsa
	then
		sed 's/alsa && echo yes/alsa \&\& echo no/' \
			-i "${S}/jfaudiolib/Makefile.shared" || \
			die "Failed to disable alsa!"
	fi

	if ! use vorbis
	then
		sed 's/vorbisfile && echo yes/vorbisfile \&\& echo no/' \
			-i "${S}/jfaudiolib/Makefile.shared" || \
			die "Failed to disable libvorbis!"
	fi

	if ! use fluidsynth
	then
		sed 's/fluidsynth && echo yes/fluidsynth \&\& echo no/' \
			-i "jfaudiolib/Makefile.shared" || \
			die "Failed to disable fluidsynth!"
	fi

	# PREFIX actually sets the searchpath for jfsw/build
	# the Makefile doesn't have an install target
	echo PREFIX=/usr/share/games/sw > Makefile.user
	# Inline assembly is forced off as it wouldn't even work on X86
	echo USE_ASM=0 >> Makefile.user
	# Debug flags could interfere with our cflags
	echo RELEASE=1 >> Makefile.user

	use polymost || echo USE_POLYMOST=0 >> Makefile.user
	use opengl || echo USE_OPENGL=0 >> Makefile.user

	eapply_user
}

src_install()
{
	dobin sw
	dodoc readme.txt
	dodoc releasenotes.html
	keepdir /usr/share/games/sw
}

pkg_postinst()
{
	echo
	einfo The standard search path for gamefiles is /usr/share/games/sw
	einfo Also, the current working directory is scanned for additional files.
	echo
	einfo Remember:
	einfo Playing game is only way to preserve honour\!
	echo
}
