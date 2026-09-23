{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "clockface-font";
  version = "unstable-2026-05-15";

  src = fetchFromGitHub {
    owner = "ocodo";
    repo = "ClockFace-font";
    rev = "bad11070c962d328679e9bfec7769fb920097615";
    hash = "sha256-2+kiG5apYMKI5P1o1ahr9BsV87UVWjSmM8S+Vf5MAO0=";
  };

  dontUnpack = false;

  installPhase = ''
    runHook preInstall
    install -Dm444 -t $out/share/fonts/truetype *.ttf
    runHook postInstall
  '';

  meta = with lib; {
    description = "Icon font for displaying the time";
    homepage = "https://github.com/ocodo/ClockFace-font";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
