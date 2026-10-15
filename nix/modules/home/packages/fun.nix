# Terminal toys. Nothing depends on these.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bk
    cbonsai
    cmatrix
    lolcat
    nyancat
    ponysay
    sl
  ];
}
