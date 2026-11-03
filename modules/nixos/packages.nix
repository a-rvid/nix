{ config, lib, pkgs, ... }:
let
  firefoxExtensions = {
    "uBlock0@raymondhill.net" = "ublock-origin";
    "jid1-BoFifL9Vbdl2zQ@jetpack" = "decentraleyes";
    "foxyproxy-basic@eric.h.jung" = "foxyproxy-basic";
    "sponsorBlocker@ajay.app" = "sponsorblock";
    "gdpr@cavi.au.dk" = "consent-o-matic";
  };
in
{
  config = lib.mkMerge [
    (lib.mkIf config.my.browser.librewolf.enable {
      programs.firefox = {
        enable = true;
        package = pkgs.librewolf;

        policies = {
          DisableAppUpdate = true;
          DisableFirefoxStudies = true;
          DisableFormHistory = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;

          EnableTrackingProtection = {
            Value = true;
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
          };

          HttpsOnlyMode = "force_enabled";
          NetworkPrediction = false;
          NewTabPage = false;
          NoDefaultBookmarks = true;
          SearchSuggestEnabled = false;

          FirefoxHome = {
            Search = false;
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Pocket = false;
            SponsoredPocket = false;
            Snippets = false;
            Locked = true;
          };

          UserMessaging = {
            ExtensionRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            FirefoxLabs = false;
          };

          ExtensionSettings = lib.mapAttrs (_id: slug: {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
          }) firefoxExtensions;

          Preferences = {
            "privacy.resistFingerprinting" = {
              Value = true;
              Status = "locked";
            };

            "privacy.partition.network_state" = {
              Value = true;
              Status = "locked";
            };

            "network.cookie.cookieBehavior" = {
              Value = 5;
              Status = "locked";
            };

            "browser.nova.enabled" = {
              Value = !config.my.browser.disableNova;
              Status = "locked";
            };

            "browser.cache.disk.enable" = {
              Value = false;
              Status = "locked";
            };

            "toolkit.legacyUserProfileCustomizations.stylesheets" = {
              Value = true;
              Status = "locked";
            };
          };
        };
      };
    })

    (lib.mkIf config.my.features.development.enable {
      environment.systemPackages = with pkgs; [
        emacs
        vscodium
      ];
    })

    (lib.mkIf config.my.features.spotify.enable {
      environment.systemPackages = [ pkgs.spotify ];
    })
  ];
}
