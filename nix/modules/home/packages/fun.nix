# Terminal toys. Nothing depends on these.
{ available, pkgs, ... }:
{
  home.packages = available (
    with pkgs;
    [
      bk
      cbonsai
      cmatrix
      lolcat
      nyancat
      ponysay
      sl
    ]
  );
}
