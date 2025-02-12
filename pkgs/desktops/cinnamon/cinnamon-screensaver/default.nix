{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, pkg-config
, meson
, ninja
, glib
, dbus
, gettext
, cinnamon-desktop
, cinnamon-common
, intltool
, libxslt
, gtk3
, libgnomekbd
, gnome
, libtool
, wrapGAppsHook
, gobject-introspection
, python3
, pam
, accountsservice
, cairo
, xapp
, xdotool
, xorg
, iso-flags-png-320x420
}:

stdenv.mkDerivation rec {
  pname = "cinnamon-screensaver";
  version = "5.4.1";

  patches = [
    # Add missing gio-unix-2.0 dependency, can be removed on next update
    # https://github.com/linuxmint/cinnamon-screensaver/pull/411
    (fetchpatch {
      url = "https://github.com/linuxmint/cinnamon-screensaver/commit/8d658e7f313879579322dce666551f132795540b.patch";
      sha256 = "sha256-HjVQSX2yYqgZVIio2I8GBWLYOddvaFiqZzf0zaYf+OE=";
    })
  ];

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = pname;
    rev = version;
    hash = "sha256-PpBtLAIboXMnX5V/u06aoZ6WfPrn4mdCu0NXTGb6pAE=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
    gettext
    intltool
    dbus # for meson.build
    libxslt
    libtool
    meson
    ninja
  ];

  buildInputs = [
    # from meson.build
    gobject-introspection
    gtk3
    glib

    xorg.libXext
    xorg.libXinerama
    xorg.libX11
    xorg.libXrandr

    (python3.withPackages (pp: with pp; [
      pygobject3
      setproctitle
      python3.pkgs.xapp # The scope prefix is required
      pycairo
    ]))
    xapp
    xdotool
    pam
    accountsservice
    cairo
    cinnamon-desktop
    cinnamon-common
    libgnomekbd
    gnome.caribou

    # things
    iso-flags-png-320x420
  ];

  postPatch = ''
    # cscreensaver hardcodes absolute paths everywhere. Nuke from orbit.
    find . -type f -exec sed -i \
      -e s,/usr/share/locale,/run/current-system/sw/share/locale,g \
      -e s,/usr/lib/cinnamon-screensaver,$out/lib,g \
      -e s,/usr/share/cinnamon-screensaver,$out/share,g \
      -e s,/usr/share/iso-flag-png,${iso-flags-png-320x420}/share/iso-flags-png,g \
      {} +

    sed "s|/usr/share/locale|/run/current-system/sw/share/locale|g" -i ./src/cinnamon-screensaver-main.py
  '';

  meta = with lib; {
    homepage = "https://github.com/linuxmint/cinnamon-screensaver";
    description = "The Cinnamon screen locker and screensaver program";
    license = [ licenses.gpl2 licenses.lgpl2 ];
    platforms = platforms.linux;
    maintainers = teams.cinnamon.members;
  };
}
