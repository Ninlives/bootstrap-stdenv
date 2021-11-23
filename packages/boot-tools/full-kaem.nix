{ sources, helpers, suffix, attr }:
with sources;
with helpers;
let
  #################################################
  # Phase-12 Build final blood-elf from C sources #
  #################################################
  phase12 = ''
    ${M2 {
      srcs = [
        "${m2-libc}/sys/types.h"
        "${m2-libc}/stddef.h"
        "${m2-libc}/${attr.normal}/Linux/unistd.h"
        "${m2-libc}/stdlib.c"
        "${m2-libc}/${attr.normal}/Linux/fcntl.h"
        "${m2-libc}/stdio.c"
        "${m2-libc}/bootstrappable.c"
        "${mescc-tools}/stringify.c"
        "${mescc-tools}/blood-elf.c"
      ];
      output = "./blood-elf-1.M1";
    }}

    ${blood-elf-0 [ "./blood-elf-1.M1" ] "./blood-elf-1-footer.M1"}
    ${M1 {
      srcs = [
        "${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1"
        "${m2-libc}/${attr.normal}/libc-full.M1"
        "./blood-elf-1.M1"
        "./blood-elf-1-footer.M1"
      ];
      output = "./blood-elf-1.hex2";
    }}

    ${hex2 {
      srcs = [
        "${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2"
        "./blood-elf-1.hex2"
      ];
      output = "./blood-elf";
    }}
  '';
  # Now we have our shipping debuggable blood-elf, the rest will be down hill from
  # here as we have ALL of the core pieces of compiling and assembling debuggable
  # programs in a debuggable form with corresponding C source code.

  #############################################
  # Phase-13 Build get_machine from C sources #
  #############################################
  # phase13 = ''
  #   ${M2 {
  #     srcs = [
  #       "${m2-libc}/sys/types.h"
  #       "${m2-libc}/stddef.h"
  #       "${m2-libc}/${attr.normal}/Linux/unistd.h"
  #       "${m2-libc}/stdlib.c"
  #       "${m2-libc}/${attr.normal}/Linux/fcntl.h"
  #       "${m2-libc}/stdio.c"
  #       "${m2-libc}/bootstrappable.c"
  #       "${mescc-tools}/get_machine.c"
  #     ];
  #     output = "./get_machine.M1";
  #   }}

  #   ${blood-elf [ "./get_machine.M1" ] "get_machine-footer.M1"}

  #   ${M1 {
  #     srcs = [
  #       "${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1"
  #       "${m2-libc}/${attr.normal}/libc-full.M1"
  #       "./get_machine.M1"
  #       "./get_machine-footer.M1"
  #     ];
  #     output = "./get_machine.hex2";
  #   }}

  #   ${hex2 {
  #     srcs = [
  #       "${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2"
  #       "./get_machine.hex2"
  #     ];
  #     output = "./get_machine";
  #   }}
  # '';

  ############################################
  # Phase-14 Build M2-Planet from M2-Planet  #
  ############################################

  phase14 = ''
    ${M2 {
      srcs = [
        "${m2-libc}/sys/types.h"
        "${m2-libc}/stddef.h"
        "${m2-libc}/${attr.normal}/Linux/unistd.h"
        "${m2-libc}/stdlib.c"
        "${m2-libc}/${attr.normal}/Linux/fcntl.h"
        "${m2-libc}/stdio.c"
        "${m2-libc}/bootstrappable.c"
        "${m2-planet}/cc.h"
        "${m2-planet}/cc_globals.c"
        "${m2-planet}/cc_reader.c"
        "${m2-planet}/cc_strings.c"
        "${m2-planet}/cc_types.c"
        "${m2-planet}/cc_core.c"
        "${m2-planet}/cc_macro.c"
        "${m2-planet}/cc.c"
      ];
      output = "./M2-1.M1";
    }}

    ${blood-elf [ "./M2-1.M1" ] "./M2-1-footer.M1"}

    ${M1 {
      srcs = [
        "${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1"
        "${m2-libc}/${attr.normal}/libc-full.M1"
        "./M2-1.M1"
        "./M2-1-footer.M1"
      ];
      output = "./M2-1.hex2";
    }}

    ${hex2 {
      srcs = [
        "${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2"
        "./M2-1.hex2"
      ];
      output = "./M2-Planet";
    }}
  '';
in builtins.toFile "full-kaem.kaem" ''
  ${phase12}
  ${phase14}
''
