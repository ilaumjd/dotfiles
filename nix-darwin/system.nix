{
  system = {

    tools = {
      darwin-rebuild.enable = true;
    };

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleInterfaceStyle = "Dark";
        InitialKeyRepeat = 12;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.enableSecondaryClick" = true;
        "com.apple.trackpad.scaling" = 2.0;
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          WebKitDeveloperExtras = true;
        };
        "com.apple.desktopservices" = {
          DSDonntWriteNetworkStores = true;
          DSDonntWriteUSBStores = true;
        };
        "com.raycast.macos" = {
          NSNavLastRootDirectory = "~/src/scripts/raycast";
          "NSStatusItem Visible raycastIcon" = 0;
          commandsPreferencesExpandedItemIds = [
            "extension_noteplan-3__00cda425-a991-4e4e-8031-e5973b8b24f6"
            "builtin_package_navigation"
            "builtin_package_scriptCommands"
            "builtin_package_floatingNotes"
          ];
          "emojiPicker_skinTone" = "mediumLight";
          initialSpotlightHotkey = "Command-49";
          navigationCommandStyleIdentifierKey = "legacy";
          "onboarding_canShowActionPanelHint" = 0;
          "onboarding_canShowBackNavigationHint" = 0;
          "onboarding_completedTaskIdentifiers" = [
            "startWalkthrough"
            "calendar"
            "setHotkeyAndAlias"
            "snippets"
            "quicklinks"
            "installFirstExtension"
            "floatingNotes"
            "windowManagement"
            "calculator"
            "raycastShortcuts"
            "openActionPanel"
          ];
          organizationsPreferencesTabVisited = 1;
          popToRootTimeout = 60;
          raycastAPIOptions = 8;
          raycastGlobalHotkey = "Command-49";
          raycastPreferredWindowMode = "default";
          raycastShouldFollowSystemAppearance = 1;
          raycastWindowPresentationMode = 1;
          showGettingStartedLink = 0;
          "store_termsAccepted" = 1;
          suggestedPreferredGoogleBrowser = 1;
        };
      };

      controlcenter = {
        AirDrop = false;
        BatteryShowPercentage = true;
        Bluetooth = true;
        Display = false;
        FocusModes = false;
        NowPlaying = false;
        Sound = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        expose-animation-duration = 0.2;
        launchanim = false;
        mru-spaces = false;
        orientation = "right";
        show-recents = false;
        show-process-indicators = true;
        static-only = true;
        tilesize = 48;
        wvous-br-corner = 1;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        NewWindowTarget = "Home";
        QuitMenuItem = true;
        ShowPathbar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        _FXSortFoldersFirstOnDesktop = true;
      };

      trackpad = {
        ActuationStrength = 0;
        Clicking = true;
        TrackpadRightClick = true;
      };

      loginwindow.GuestEnabled = false;
      menuExtraClock.ShowSeconds = true;
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    startup.chime = false;
  };
}
