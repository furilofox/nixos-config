# Discord is a popular chat application.
{
  inputs,
  config,
  ...
}: {
  imports = [inputs.nixcord.homeModules.nixcord];

  xdg.configFile."Vencord/themes" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/vesktop/themes";
  };

  programs.nixcord = {
    enable = true;
    vesktop.enable = true;
    dorion.enable = false;

    config = {
      frameless = true;
      plugins = {
        anonymiseFileNames.enable = true;
        callTimer.enable = true;
        biggerStreamPreview.enable = true;
        blurNSFW.enable = true;
        betterSessions.enable = true;
        copyFileContents.enable = true;
        vcNarrator.enable = true;
        betterSettings.enable = true;
        whoReacted.enable = true;
        validReply.enable = true;
        summaries.enable = true;
        spotifyCrack.enable = true;
        silentTyping.enable = true;
        showHiddenThings.enable = true;
        showHiddenChannels.enable = true;
        showMeYourName.enable = true;
        shikiCodeblocks.enable = true;
        sendTimestamps.enable = true;
        serverInfo.enable = true;
        roleColorEverywhere.enable = true;
        relationshipNotifier.enable = true;
        platformIndicators.enable = true;
        permissionsViewer.enable = true;
        fixCodeblockGap.enable = true;
        clearURLs.enable = true;
        forceOwnerCrown.enable = true;
        translate.enable = true;
        showConnections.enable = true;
        reviewDB.enable = true;
        reverseImageSearch.enable = true;
        pinDMs.enable = true;
        mentionAvatars.enable = true;
        memberCount.enable = true;
        imageZoom.enable = true;
        friendsSince.enable = true;
        fakeNitro.enable = true;

        messageLogger = {
          enable = true;
          collapseDeleted = true;
        };
        customRPC = {
          enable = true;
          appID = "69";
          type = "playing";
          appName = "Something probably";
          details = "...";
          state = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

          buttonOneText = "My Github";
          buttonOneURL = "https://github.com/furilofox";

          buttonTwoText = "My Steam";
          buttonTwoURL = "https://steamcommunity.com/id/furilofox/";

          timestampMode = "customTime";
          startTime = 1;
          endTime = 1000000000000000000;
        };
      };
    };
  };
}
