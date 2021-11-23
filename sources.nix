{
  bootstrap-seeds = builtins.fetchGit rec {
    name = "bootstrap-seeds";
    url = "https://github.com/oriansj/bootstrap-seeds.git";
    ref = "refs/heads/master";
    rev = "4715ae5292a6551a7d6e3ba2a2f1586a6bc5cb7d";
  };
  m2-planet = builtins.fetchGit rec {
    name = "M2-Planet";
    url = "https://github.com/oriansj/M2-Planet.git";
    ref = "refs/heads/master";
    rev = "55929d4ddf27a51bcbad47c2f6d618ce629aa5e6";
  };
  m2-libc = builtins.fetchGit rec {
    name = "M2libc";
    url = "https://github.com/oriansj/M2libc.git";
    ref = "refs/heads/main";
    rev = "ff549d1424ad0061a177b3826497ce71d415c005";
  };
  mescc-tools = builtins.fetchGit rec {
    name = "mescc-tools";
    url = "https://github.com/oriansj/mescc-tools.git";
    ref = "refs/heads/master";
    rev = "0cc8fd02e0b6f72d279a339f6a729fa2b069313b";
  };
  mescc-tools-extra = builtins.fetchGit rec {
    name = "mescc-tools-extra";
    url = "https://github.com/Ninlives/mescc-tools-extra.git";
    ref = "refs/heads/master";
    rev = "2a9ac880af0f1cc36860eff9d6046528033323b4";
  };
  stage0-posix = builtins.fetchGit rec {
    name = "stage0-posix";
    url = "https://github.com/oriansj/stage0-posix.git";
    ref = "refs/heads/master";
    rev = "46192d42ceb52e2b0951f31bc7bb38e70bf9a423";
  };
  live-bootstrap = builtins.fetchGit {
    name = "live-bootstrap";
    url = "https://github.com/fosslinux/live-bootstrap.git";
    ref = "refs/heads/master";
    rev = "12f3cc3138f940b2c203f322a15c778705a25345";
  };
  mes-m2 = builtins.fetchGit rec {
    name = "mes-m2";
    url = "https://github.com/oriansj/mes-m2.git";
    ref = "refs/heads/master";
    rev = "b2143add588e443e55828f6ddf4dcb3720cd36fb";
  };
  nyacc = builtins.fetchTarball {
    url = "https://download.savannah.gnu.org/releases/nyacc/nyacc-1.00.2.tar.gz";
    sha256 = "";
  };
}
