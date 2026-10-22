# CyberAgent-issued Mac (Apple Silicon), user a12019.
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "a12019";

  # Keep herdr / mosh alive by blocking sleep only while on AC (-s has no effect on battery).
  # Replaces pmset disablesleep 1, which also blocked lid-close sleep and overheated in a bag.
  launchd.user.agents.caffeinate.serviceConfig = {
    ProgramArguments = [
      "/usr/bin/caffeinate"
      "-s"
    ];
    KeepAlive = true;
    RunAtLoad = true;
  };

  # cycloud VM names also have a public DNS zone, so a lookup before the VPN is back from
  # sleep gets an NXDOMAIN cached for 15 minutes. Always ask the VPN's DNS to avoid that.
  environment.etc."resolver/tky02a.cycloud.io".text = "nameserver 10.97.32.55\n";
}
