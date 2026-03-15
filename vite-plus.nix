{ lib, stdenv, fetchurl, autoPatchelfHook, gcc }:

let
  version = "0.1.11";
  src = fetchurl {
    url = "https://registry.npmjs.org/@voidzero-dev/vite-plus-cli-linux-x64-gnu/-/vite-plus-cli-linux-x64-gnu-${version}.tgz";
    hash = "sha256-1lwr2c6y0mhvh6n23i7yyr9g7ifrbscyphydxpkk0bzkzq64sxaa";
  };
in
stdenv.mkDerivation {
  pname = "vite-plus";
  inherit version;

  inherit src;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ gcc.cc.lib ];

  sourceRoot = ".";
  
  installPhase = ''
    mkdir -p $out/bin
    cp vp $out/bin/
    chmod +x $out/bin/vp
  '';

  meta = with lib; {
    description = "The Unified Toolchain for the Web";
    homepage = "https://vite.plus";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "vp";
  };
}