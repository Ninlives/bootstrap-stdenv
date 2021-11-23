{ system, utility, sources, boot-tools }:
with sources;
with utility;
let
  script = builtins.toFile "build.kaem" ''
    ''${TOOLS}/mkdir ''${BINDIR}
    BUILDDIR=''${NIX_BUILD_TOP}
    cd ''${TOOLS_EXTRA}
    ''${TOOLS}/kaem --verbose --strict -f ''${TOOLS_EXTRA}/mescc-tools-extra.kaem
  '';
in derivation {
  inherit system;
  name = "extra-tools";
  builder = "${boot-tools}/bin/kaem";
  args = [ "--verbose" "--strict" "-f" script ];
  ARCH = attr.normal;
  M2LIBC = m2-libc;
  TOOLS = "${boot-tools}/bin";
  TOOLS_EXTRA = mescc-tools-extra;
  BLOOD_FLAG = if is64Bit then "--64" else "";
  BASE_ADDRESS = attr.base-address;
  BINDIR = "${placeholder "out"}/bin";
  ENDIAN_FLAG = "--little-endian";
}
