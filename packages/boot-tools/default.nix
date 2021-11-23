{ system, arch, lib, sources, utility }:
with sources;
with utility;
let
  rootDir = "${stage0-posix}/${arch}";
  build-essential-tools = with helpers;
    builtins.toFile "essential-tools.kaem" ''
      ${
        m2-build {
          name = "mkdir";
          srcs = [ "${mescc-tools-extra}/mkdir.c" ];
          bootstrappable = false;
        }
      } 
      ${
        m2-build {
          name = "cp";
          srcs = [ "${mescc-tools-extra}/cp.c" ];
        }
      } 
      ${
        m2-build {
          name = "chmod";
          srcs = [ "${mescc-tools-extra}/chmod.c" ];
        }
      } 
    '';

  bindir = "\${out}/bin";
  install = builtins.toFile "install.kaem" ''
    ./mkdir ${bindir}
      ${
        lib.concatMapStringsSep "\n" (e: ''
          ./cp ./${e} ${bindir}/${e}
          ./chmod 555 ${bindir}/${e}
        '') [ "blood-elf" "chmod" "cp" "hex2" "kaem" "mkdir" "M1" "M2-Planet" ]
      }
  '';
  script = builtins.toFile "script.kaem" ''
    ${sources.bootstrap-seeds}/POSIX/${arch}/kaem-optional-seed ${
      import ./seed-kaem.nix { inherit sources arch rootDir suffix; }
    }
    ./kaem-0 ${
      import ./mini-kaem.nix {
        inherit sources rootDir suffix attr helpers lib;
      }
    }
    ./kaem --verbose --strict -f ${
      import ./full-kaem.nix { inherit sources helpers suffix attr; }
    }
    ./kaem --verbose --strict -f ${build-essential-tools}
    ./kaem --verbose --strict -f ${install}
  '';
in derivation {
  inherit system;
  name = "boot-tools";
  builder = "${bootstrap-seeds}/POSIX/${arch}/kaem-optional-seed";
  args = [ script ];
}
