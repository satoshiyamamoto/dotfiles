# MacBook Pro M4 Max, user a12019. The one formula that was only here,
# graphviz, is deliberately not carried over.
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "a12019";

  # AC 接続中だけスリープを止めて herdr / mosh を保つ（-s はバッテリー駆動では効かない）。
  # pmset disablesleep 1 は蓋閉じも止めて持ち運び中に発熱するため、こちらに置き換えた。
  launchd.user.agents.caffeinate.serviceConfig = {
    ProgramArguments = [ "/usr/bin/caffeinate" "-s" ];
    KeepAlive = true;
    RunAtLoad = true;
  };
}
