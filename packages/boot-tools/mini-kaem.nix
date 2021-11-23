{ sources, rootDir, suffix, attr, helpers, lib }:
with sources;
with helpers;
let
  phases = {
    ######################################################
    # Phase-1 Build hex1 from hex0, Build catm from hex0 #
    ######################################################
    phase1 = ''
      ./hex0 ${rootDir}/hex1_${suffix.common}.hex0 ./hex1
      ./hex0 ${rootDir}/catm_${suffix.catm}.hex0 ./catm
    '';
    # hex1 adds support for single character labels and is available in various froms
    # in mescc-tools/amd64_bootstrap to allow you various ways to verify correctness
    # catm removes the need for cat or shell support for redirection by providing
    # equivalent functionality via catm output_file input1 input2 ... inputN

    #################################
    # Phase-2 Build hex2 from hex1  #
    #################################
    phase2 = ''
      ./hex1 ${rootDir}/hex2_${suffix.common}.hex1 ./hex2-0
    '';
    # hex2 adds support for long labels and absolute addresses thus allowing it
    # to function as an effective linker for later stages of the bootstrap
    # This is a minimal version which will be used to bootstrap a much more advanced
    # version in a later stage.

    ###############################
    # Phase-3 Build M0 from hex2  #
    ###############################
    phase3 = ''
      ./catm ./M0.hex2 ${rootDir}/ELF-${suffix.elf}.hex2 ${rootDir}/M0_${suffix.common}.hex2
      ./hex2-0 ./M0.hex2 ./M0
    '';
    # M0 is the architecture specific version of M1 and is by design single
    # architecture only and will be replaced by the C code version of M1

    ###################################
    # Phase-4 Build cc from M0  #
    ###################################
    phase4 = ''
      ./M0 ${rootDir}/cc_${suffix.cc}.M1 ./cc_${suffix.cc}.hex2
      ./catm ./cc_${suffix.cc}-0.hex2 ${rootDir}/ELF-${suffix.elf}.hex2 ./cc_${suffix.cc}.hex2
      ./hex2-0 ./cc_${suffix.cc}-0.hex2 ./cc_${suffix.cc}
    '';

    cc = "./cc_${suffix.cc}";

    #########################################
    # Phase-5 Build M2-Planet from cc #
    #########################################
    phase5 = ''
      ./catm ./M2-0.c \
      	${m2-libc}/${attr.normal}/Linux/bootstrap.c \
      	${m2-planet}/cc.h \
      	${m2-libc}/bootstrappable.c \
      	${m2-planet}/cc_globals.c \
      	${m2-planet}/cc_reader.c \
      	${m2-planet}/cc_strings.c \
      	${m2-planet}/cc_types.c \
      	${m2-planet}/cc_core.c \
      	${m2-planet}/cc_macro.c \
      	${m2-planet}/cc.c
      ./cc_amd64 ./M2-0.c ./M2-0.M1
      ./catm ./M2-0-0.M1 ${rootDir}/${suffix.defs}_defs.M1 ${rootDir}/libc-core.M1 ./M2-0.M1
      ./M0 ./M2-0-0.M1 ./M2-0.hex2
      ./catm ./M2-0-0.hex2 ${rootDir}/ELF-${suffix.elf}.hex2 ./M2-0.hex2
      ./hex2-0 ./M2-0-0.hex2 ./M2
    '';

    #############################################
    # Phase-6 Build blood-elf-0 from C sources  #
    #############################################
    phase6 = ''
      ${M2 {
        srcs = [
          "${m2-libc}/${attr.normal}/Linux/bootstrap.c"
          "${m2-libc}/bootstrappable.c"
          "${mescc-tools}/stringify.c"
          "${mescc-tools}/blood-elf.c"
        ];
        output = "./blood-elf-0.M1";
        bootstrap-mode = true;
        debug = false;
      }}

      ./catm ./blood-elf-0-0.M1 ${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1 ${m2-libc}/${attr.normal}/libc-core.M1 ./blood-elf-0.M1
      ./M0 ./blood-elf-0-0.M1 ./blood-elf-0.hex2
      ./catm ./blood-elf-0-0.hex2 ${m2-libc}/${attr.normal}/ELF-${suffix.elf}.hex2 ./blood-elf-0.hex2
      ./hex2-0 ./blood-elf-0-0.hex2 ./blood-elf-0
    '';
    # This is the last stage where the binaries will not have debug info
    # and the last piece built that isn't part of the output binaries

    #####################################
    # Phase-7 Build M1-0 from C sources #
    #####################################
    phase7 = ''
      ${M2 {
        srcs = [
          "${m2-libc}/${attr.normal}/Linux/bootstrap.c"
          "${m2-libc}/bootstrappable.c"
          "${mescc-tools}/stringify.c"
          "${mescc-tools}/M1-macro.c"
        ];
        output = "./M1-macro-0.M1";
        bootstrap-mode = true;
      }}

      ${blood-elf-0 [ "./M1-macro-0.M1" ] "./M1-macro-0-footer.M1"}
      ./catm ./M1-macro-0-0.M1 ${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1 ${m2-libc}/${attr.normal}/libc-core.M1 ./M1-macro-0.M1 ./M1-macro-0-footer.M1
      ./M0 ./M1-macro-0-0.M1 ./M1-macro-0.hex2
      ./catm ./M1-macro-0-0.hex2 ${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2 ./M1-macro-0.hex2
      ./hex2-0 ./M1-macro-0-0.hex2 ./M1-0
    '';
    # This is the last stage where catm will need to be used and the last stage where
    # M0 is used, as we will being using it's much more powerful and cross-platform
    # version with a bunch of extra goodies.

    #######################################
    # Phase-8 Build hex2-1 from C sources #
    #######################################
    phase8 = ''
      ${M2 {
        srcs = [
          "${m2-libc}/sys/types.h"
          "${m2-libc}/${attr.normal}/Linux/sys/stat.h"
          "${m2-libc}/stddef.h"
          "${m2-libc}/${attr.normal}/Linux/unistd.h"
          "${m2-libc}/stdlib.c"
          "${m2-libc}/${attr.normal}/Linux/fcntl.h"
          "${m2-libc}/stdio.c"
          "${m2-libc}/bootstrappable.c"
          "${mescc-tools}/hex2.h"
          "${mescc-tools}/hex2_linker.c"
          "${mescc-tools}/hex2_word.c"
          "${mescc-tools}/hex2.c"
        ];
        output = "./hex2_linker-1.M1";
      }}

      ${blood-elf-0 [ "./hex2_linker-1.M1" ] "./hex2_linker-1-footer.M1"}
      ${M1-0 {
        srcs = [
          "${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1"
          "${m2-libc}/${attr.normal}/libc-full.M1"
          "./hex2_linker-1.M1"
          "./hex2_linker-1-footer.M1"
        ];
        output = "./hex2_linker-1.hex2";
      }}

      ./catm ./hex2_linker-1-0.hex2 ${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2 ./hex2_linker-1.hex2
      ./hex2-0 ./hex2_linker-1-0.hex2 ./hex2-1
    '';
    # This is the last stage where we will be using the handwritten hex2 and instead
    # be using the far more powerful, cross-platform version with a bunch more goodies

    ###################################
    # Phase-9 Build M1 from C sources #
    ###################################
    phase9 = ''
      ${M2 {
        srcs = [
          "${m2-libc}/sys/types.h"
          "${m2-libc}/stddef.h"
          "${m2-libc}/string.c"
          "${m2-libc}/${attr.normal}/Linux/unistd.h"
          "${m2-libc}/stdlib.c"
          "${m2-libc}/${attr.normal}/Linux/fcntl.h"
          "${m2-libc}/stdio.c"
          "${m2-libc}/bootstrappable.c"
          "${mescc-tools}/stringify.c"
          "${mescc-tools}/M1-macro.c"
        ];
        output = "./M1-macro-1.M1";
      }}

      ${blood-elf-0 [ "./M1-macro-1.M1" ] "./M1-macro-1-footer.M1"}

      ${M1-0 {
        srcs = [
          "${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1"
          "${m2-libc}/${attr.normal}/libc-full.M1"
          "./M1-macro-1.M1"
          "./M1-macro-1-footer.M1"
        ];
        output = "./M1-macro-1.hex2";
      }}

      ${hex2-1 {
        srcs = [
          "${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2"
          "./M1-macro-1.hex2"
        ];
        output = "./M1";
      }}
    '';

    ######################################
    # Phase-10 Build hex2 from C sources #
    ######################################
    phase10 = ''
      ${M2 {
        srcs = [
          "${m2-libc}/sys/types.h"
          "${m2-libc}/${attr.normal}/Linux/sys/stat.h"
          "${m2-libc}/stddef.h"
          "${m2-libc}/${attr.normal}/Linux/unistd.h"
          "${m2-libc}/stdlib.c"
          "${m2-libc}/${attr.normal}/Linux/fcntl.h"
          "${m2-libc}/stdio.c"
          "${m2-libc}/bootstrappable.c"
          "${mescc-tools}/hex2.h"
          "${mescc-tools}/hex2_linker.c"
          "${mescc-tools}/hex2_word.c"
          "${mescc-tools}/hex2.c"
        ];
        output = "./hex2_linker-2.M1";
      }}

      ${blood-elf-0 [ "./hex2_linker-2.M1" ] "./hex2_linker-2-footer.M1"}

      ${M1 {
        srcs = [
          "${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1"
          "${m2-libc}/${attr.normal}/libc-full.M1"
          "./hex2_linker-2.M1"
          "./hex2_linker-2-footer.M1"
        ];
        output = "./hex2_linker-2.hex2";
      }}

      ${hex2-1 {
        srcs = [
          "${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2"
          "./hex2_linker-2.hex2"
        ];
        output = "./hex2";
      }}
    '';

    #####################################
    # Phase-11 Build kaem from C sources#
    #####################################
    phase11 = ''
      ${M2 {
        srcs = [
          "${m2-libc}/sys/types.h"
          "${m2-libc}/stddef.h"
          "${m2-libc}/string.c"
          "${m2-libc}/${attr.normal}/Linux/unistd.h"
          "${m2-libc}/stdlib.c"
          "${m2-libc}/${attr.normal}/Linux/fcntl.h"
          "${m2-libc}/stdio.c"
          "${m2-libc}/bootstrappable.c"
          "${mescc-tools}/Kaem/kaem.h"
          "${mescc-tools}/Kaem/variable.c"
          "${mescc-tools}/Kaem/kaem_globals.c"
          "${mescc-tools}/Kaem/kaem.c"
        ];
        output = "./kaem.M1";
      }}
        
      ${blood-elf-0 [ "./kaem.M1" ] "./kaem-footer.M1"}

      ${M1 {
        srcs = [
          "${m2-libc}/${attr.normal}/${suffix.defs}_defs.M1"
          "${m2-libc}/${attr.normal}/libc-full.M1"
          "./kaem.M1"
          "./kaem-footer.M1"
        ];
        output = "./kaem.hex2";
      }}

      ${hex2 {
        srcs = [
          "${m2-libc}/${attr.normal}/ELF-${suffix.elf}-debug.hex2"
          "./kaem.hex2"
        ];
        output = "./kaem";
      }}
    '';
  };
in builtins.toFile "mini-kaem.kaem"
(lib.concatMapStringsSep "\n" (n: phases."phase${toString n}") (lib.range 1 11))
