# Mac mini 2018 (Macmini8,1, i7-8700B), user satoshi. The only x86_64 host, so
# it builds against the 26.05 inputs in flake.nix rather than unstable.
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = "x86_64-darwin";
  system.primaryUser = "satoshi";

  # herdr is absent from 26.05 and Homebrew will not stand in -- it has
  # declared macOS 15 / x86_64 a Tier 3 configuration and no longer bottles
  # for it, so nothing new can come from there. numtide/llm-agents.nix builds
  # it from source instead: its own `packages` output lists only the three
  # systems it caches for, but `overlays.shared-nixpkgs` builds the same tree
  # against whatever pkgs the consumer has, and herdr's meta.platforms already
  # covers this one. No cache hit follows, so it compiles on the machine
  # (Rust plus a vendored libghostty-vt through zig, about four minutes here).
  #
  # hunk cannot come the same way: it pins meta.platforms without
  # x86_64-darwin because bun-bin, the `bun build --compile` runtime, has no
  # darwin-x64 triple there. cloudflare-speed-cli, hunk and mycli are simply
  # not wanted on this host, so Homebrew installs no formula here at all.
  #
  # herdr's package.nix also takes `installAgentSkills`, a setup hook that
  # exists only in unstable. Backport just its setup-hook.sh: unstable's
  # package.nix pulls hunk and worktrunk into passthru.tests, and referencing
  # the source tree never imports unstable for this system.
  nixpkgs.overlays = [
    inputs.llm-agents.overlays.shared-nixpkgs
    (final: _: {
      installAgentSkills = final.makeSetupHook {
        name = "install-agent-skills";
      } "${inputs.nixpkgs}/pkgs/by-name/in/installAgentSkills/setup-hook.sh";
    })
  ];
  # A home package like every other: /run/current-system/sw holds only what
  # nix-darwin installs itself. useGlobalPkgs carries the overlay above over.
  home-manager.users.${config.system.primaryUser} = { config, ... }: {
    home.packages = [ pkgs.llm-agents.herdr ];
    # The official Rex flake has no x86_64-darwin package; keep the app's CLI.
    programs.rex.package = null;
    home.file.".local/bin/rex".source =
      config.lib.file.mkOutOfStoreSymlink "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex";
  };

  # Wi-Fi firmware can wedge with the link still associated: configd logs
  # `router ARP failure: en1` forever and auto-join never retries because it
  # believes it is connected (2026-11-17 22:46 to 11-18 11:45). Power-cycle
  # the radio after three straight minutes without the gateway.
  launchd.daemons.wifi-watchdog = {
    script = ''
      route=$(/sbin/route -n get default 2>/dev/null) || exit 0
      [ "$(echo "$route" | /usr/bin/awk '/interface:/{print $2}')" = en1 ] || exit 0
      gw=$(echo "$route" | /usr/bin/awk '/gateway:/{print $2}')
      count_file=/var/run/wifi-watchdog.count
      if /sbin/ping -c 3 -t 5 -q "$gw" >/dev/null 2>&1; then
        rm -f "$count_file"; exit 0
      fi
      n=$(( $(cat "$count_file" 2>/dev/null || echo 0) + 1 ))
      if [ "$n" -lt 3 ]; then echo "$n" > "$count_file"; exit 0; fi
      rm -f "$count_file"
      /usr/bin/logger -t wifi-watchdog "gateway $gw unreachable for 3 checks; power-cycling en1"
      /usr/sbin/networksetup -setairportpower en1 off
      sleep 5
      /usr/sbin/networksetup -setairportpower en1 on
    '';
    serviceConfig.StartInterval = 60;
  };

  # Always-on server: never sleep, keep no hibernate image, wake on LAN and
  # come back after a power cut. power.sleep.* goes through systemsetup and
  # cannot reach standby / hibernatemode, so pmset sets the lot directly.
  system.activationScripts.postActivation.text = ''
    /usr/bin/pmset -a sleep 0 disksleep 0 displaysleep 0 standby 0 hibernatemode 0 \
      powernap 0 proximitywake 0 womp 1 autorestart 1 tcpkeepalive 1
  '';
}
