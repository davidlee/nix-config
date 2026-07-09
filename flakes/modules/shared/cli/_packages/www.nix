{pkgs, ...}: {
  common = with pkgs; [
    w3m-full
    browsh
    lynx
  ];
}
