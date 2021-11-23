{ arch, lib, sources }:
with sources;
let
  attr-table = {
    AMD64 = {
      suffix = {
        common = "AMD64";
        cc = "amd64";
        catm = "AMD64";
        elf = "amd64";
        defs = "amd64";
      };
      base-address = "0x00600000";
      normal = "amd64";
    };
  };
in rec {
  attr = attr-table.${arch};
  suffix = attr.suffix;
  is64Bit = if arch == "x86" then false else true;

  helpers = rec {
    concatSrcs = lib.concatMapStringsSep " " (s: "-f ${s}");

    M2' = m2:
      { srcs, output, bootstrap-mode ? false, debug ? true }: ''
        ${m2} --architecture ${attr.normal} \
            ${concatSrcs srcs} \
            ${lib.optionalString bootstrap-mode "--bootstrap-mode"} ${
              lib.optionalString debug "--debug"
            } -o ${output}
      '';
    M2 = M2' "./M2";
    M2-Planet = M2' "./M2-Planet";

    blood-elf' = elf: srcs: output:
      "${elf} ${lib.optionalString is64Bit "--64"} --little-endian ${
        concatSrcs srcs
      } -o ${output}";
    blood-elf-0 = blood-elf' "./blood-elf-0";
    blood-elf = blood-elf' "./blood-elf";

    M1' = m1:
      { srcs, output }: ''
        ${m1} --architecture ${attr.normal} \
        	--little-endian \
            ${concatSrcs srcs} \
            -o ${output}
      '';
    M1-0 = M1' "./M1-0";
    M1 = M1' "./M1";

    hex2' = hex:
      { srcs, output }: ''
        ${hex} --architecture ${attr.normal} \
        	--little-endian \
        	--base-address ${attr.base-address} \
            ${concatSrcs srcs} \
            -o ${output}
      '';
    hex2-1 = hex2' "./hex2-1";
    hex2 = hex2' "./hex2";

    common-build = { name, srcs }: ''
      ${M2-Planet {
        inherit srcs;
        output = "${name}.M1";
      }}
      ${blood-elf [ "${name}.M1" ] "${name}-footer.M1"} --entry _start
      ${M1 {
        srcs = [
          "${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1"
          "${m2-libc}/${attr.normal}/libc-full.M1"
          "./${name}.M1"
          "./${name}-footer.M1"
        ];
        output = "${name}.hex2";
      }}
      ${hex2 {
        srcs = [
          "${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2"
          "./${name}.hex2"
        ];
        output = "${name}";
      }}
    '';
    m2-build = { name, srcs, bootstrappable ? true }:
      common-build {
        inherit name;
        srcs = [
          "${m2-libc}/sys/types.h"
          "${m2-libc}/${attr.normal}/Linux/sys/stat.h"
          "${m2-libc}/stddef.h"
          "${m2-libc}/${attr.normal}/Linux/unistd.h"
          "${m2-libc}/stdlib.c"
          "${m2-libc}/${attr.normal}/Linux/fcntl.h"
          "${m2-libc}/stdio.c"
          "${m2-libc}/string.c"
        ] ++ (lib.optional bootstrappable "${m2-libc}/bootstrappable.c")
          ++ srcs;
      };
  };
}
