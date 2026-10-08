# MacBook Air 13" M4 (2025), user a12019.
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "a12019";

  # AC 接続中だけスリープを止めて herdr / mosh を保つ（-s はバッテリー駆動では効かない）。
  # pmset disablesleep 1 は蓋閉じも止めて持ち運び中に発熱したため、こちらに置き換えた。
  launchd.user.agents.caffeinate.serviceConfig = {
    ProgramArguments = [ "/usr/bin/caffeinate" "-s" ];
    KeepAlive = true;
    RunAtLoad = true;
  };
}
