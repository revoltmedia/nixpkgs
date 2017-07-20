{ stdenv, fetchFromGitHub, qmake, qtscript, readline, poco, openssl, unixODBC, perl, lua4 }:

stdenv.mkDerivation rec {
  name    = "toggl-desktop-${version}";
  version = "2017-06-19";

  src = fetchFromGitHub {
    owner  = "toggl";
    repo   = "toggldesktop";
    rev    = "058a54c9751728dfe247fd24144a5b10fb03cfbf";
    sha256 = "0daf9hq30q6szcjdc70g3f2gycp8a752df4q92plzff333ll6m1h";
  };


  buildInputs = [ qtscript poco openssl unixODBC perl readline lua4 ];

  nativeBuildInputs = [ qmake ];

  dontUseQmakeConfigure = true;

  patches = [
    ./patches/toggl-desktop-buildprep.patch
  ];


  preConfigure = ''
    # Apply the patches.
    for p in "./patches/"*; do
      echo "applying \`$p' ..."
      patch --verbose -p1 < "$p"
    done

    #ls -al third_party
    #mkdir -p "third_party"
    #cp -R $src/third_party/* third_party

    substituteInPlace Makefile \
      --replace "openssldir=third_party/openssl" "openssldir=${openssl.dev}" \
      --replace "pocodir=third_party/poco" "pocodir=${poco}" \

    makeFlags="PREFIX=$out"
  '';

  meta = with stdenv.lib; {
    description = "Toggl Desktop";

    longDescription = ''
    Toggl Desktop is a small desktop application that will help you track time more conveniently. It sits quietly in your system tray and when you need it (to start/stop/edit your work), it’s quickly accessible. It does what it’s designed to do best – tracks time.

    Toggl Desktop is an open source project so if you feel like looking under the hood or contributing check out the public github repo: https://github.com/toggl/toggldesktop
    '';

    homepage    = https://toggl.github.io/toggldesktop/;
    maintainers = with maintainers; [ revolt ];
    platforms   = platforms.linux;
    licenses     = with licenses; [ bsd3 ];
  };
}
