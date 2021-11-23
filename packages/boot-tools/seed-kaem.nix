{ sources, arch, rootDir, suffix }:
with sources;
let
  ###############################################
  # Phase-0 Build hex0 from bootstrapped binary #
  ###############################################
  phase0 = ''
    ${bootstrap-seeds}/POSIX/${arch}/hex0-seed ${rootDir}/hex0_${suffix.common}.hex0 ./hex0
  '';
  # hex0 should have the exact same checksum as hex0-seed as they are both supposed
  # to be built from hex0_amd64.hex0 and by definition must be identical

  #########################################
  # Phase-0b Build minimal kaem from hex0 #
  #########################################
  phase0b = ''
    ./hex0 ${rootDir}/kaem-minimal.hex0 ./kaem-0
  '';
in builtins.toFile "seed-kaem.kaem" ''
  ${phase0}
  ${phase0b}
''
