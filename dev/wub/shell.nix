with import <nixpkgs> {};
  ruby.withPackages (
    ps:
      with ps; [
        nokogiri
        pry
      ]
  )
# with (import <nixpkgs> {}); let
#   gems = bundlerEnv {
#     name = "your-package";
#     inherit ruby;
#     gemdir = ./.;
#   };
# in
#   stdenv.mkDerivation {
#     name = "your-package";
#     buildInputs = [gems ruby];
#   }
# {pkgs ? import <nixpkgs> {}}:
# pkgs.mkShell {
#   packages = with pkgs; [
#     ruby_3_5
#   ];
#
#   shellHook = ''
#   '';
# }

