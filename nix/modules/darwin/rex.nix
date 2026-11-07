{ config, lib, ... }:
{
  system.defaults.CustomUserPreferences."com.superlogical.rex" = {
    "Workspace.appearance" = "dark";
    "Workspace.lightThemeID" = "merino-light";
    "Workspace.darkThemeID" = "custom-91657586-A225-4004-82D6-46482E371DCB";
    "Workspace.darkUsesExtendedThemePalette" = true;
    "Workspace.interfaceStyle" = "modern";
    "Workspace.usesPaneGlass" = true;
    "Workspace.terminalUsesDisplayP3" = true;
    "Workspace.terminalUseThemePalette" = false;
    "Workspace.terminalImproveTextContrast" = false;
    "Workspace.terminalFontName" = "Operator Mono SSm Lig";
    "Workspace.terminalFontPointSize" = 12.0;
    "Workspace.terminalFallbackFontNames" = [ ];
    "Workspace.terminalFontSmoothing" = false;
    "Workspace.terminalCellHeightPercent" = 24.0;
    "Workspace.terminalCharacterSpacing" = "0";
    "Workspace.terminalSmoothScrolling" = true;
    "Workspace.terminalOptionKeyBehavior" = "actsAsAlt";
    "Workspace.tabStyle" = "vertical";
    "Workspace.sidebarPosition" = "left";
    "Workspace.tabIconCount" = 3;
    "Workspace.tabIconTintMode" = "off";
    "Workspace.shellIconTheme" = "default";
    "Workspace.showsPaneHeaders" = true;
    "Workspace.paneDensity" = "comfortable";
    "Workspace.inactivePaneFadeMode" = "both";
    "Workspace.usesStandardInactiveWindowPaneStyles" = true;
    "Workspace.animationStyle" = "natural";
  };

  # Rex stores custom themes as JSON data; CustomUserPreferences cannot write NSData.
  system.activationScripts.userDefaults.text = lib.mkAfter ''
    launchctl asuser "$(id -u -- ${lib.escapeShellArg config.system.primaryUser})" \
      sudo --user=${lib.escapeShellArg config.system.primaryUser} -- \
      /usr/bin/defaults write com.superlogical.rex Workspace.customThemes -data \
      "$(/usr/bin/od -An -v -tx1 ${../../../rex/custom-themes.json} | /usr/bin/tr -d ' \n')"
  '';
}
