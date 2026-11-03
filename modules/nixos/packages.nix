{
  config,
  lib,
  pkgs,
  ...
}:
let
  firefoxPackage = pkgs.firefox.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      mkdir -p "$out/lib/firefox/browser/defaults/profile/chrome"
      ln -s ${../../home/.config/firefox/userChrome.css} \
        "$out/lib/firefox/browser/defaults/profile/chrome/userChrome.css"
    '';
  });

  firefoxExtensions = {
    "uBlock0@raymondhill.net" = "ublock-origin";
    "jid1-BoFifL9Vbdl2zQ@jetpack" = "decentraleyes";
    "foxyproxy-basic@eric.h.jung" = "foxyproxy-basic";
    "sponsorBlocker@ajay.app" = "sponsorblock";
    "addon@darkreader.org" = "darkreader";
    "gdpr@cavi.au.dk" = "consent-o-matic";
  };

  foxyProxySettings = builtins.fromJSON (
    builtins.readFile ../../home/.config/firefox/foxyproxy-basic.json
  );

  configuredEmacs = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (
    epkgs: with epkgs; [
      evil
      evil-commentary
      geiser
      gruvbox-theme
      lsp-mode
      magit
      marginalia
      nord-theme
      orderless
      rustic
      undo-fu
      undo-fu-session
      use-package
      vertico
      vertico-posframe
      vterm
    ]
  );
in
{
  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        age
        btop
        curl
        fd
        file
        # programs.git.enable already installs Git.
        gnupg
        jq
        man-pages
        neovim
        nh
        ripgrep
        sops
        tree
        unzip
        wget
      ];

      programs.git.enable = true;
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
    }
    (lib.mkIf config.my.desktop.enable {
      environment.systemPackages = [
        configuredEmacs
        pkgs.vscodium
        pkgs.spotify
      ]
      ++ (with pkgs; [
        grim
        slurp
        wl-clipboard
      ]);

      programs.firefox = {
        enable = true;
        package = firefoxPackage;
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
          ExtensionSettings = lib.mapAttrs (id: slug: {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
          }) firefoxExtensions;
          "3rdparty".Extensions."foxyproxy-basic@eric.h.jung" = foxyProxySettings;
          FirefoxHome = {
            Search = true;
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Pocket = false;
            SponsoredPocket = false;
            Snippets = false;
            Locked = true;
          };
          FirefoxSuggest = {
            WebSuggestions = true;
            SponsoredSuggestions = false;
            ImproveSuggest = false;
            Locked = true;
          };
          Homepage.URL = "https://duckduckgo.com";
          HttpsOnlyMode = "force_enabled";
          NetworkPrediction = false;
          NewTabPage = false;
          NoDefaultBookmarks = true;
          OverrideFirstRunPage = "https://duckduckgo.com";
          SearchEngines = {
            Remove = [
              "DuckDuckGo"
              "Google"
              "Bing"
              "Ecosia"
            ];
            Add = [
              {
                Name = "DuckDuckGo";
                URLTemplate = "https://duckduckgo.com/?q={searchTerms}&ia=web";
                Method = "GET";
                IconURL = "https://duckduckgo.com/favicon.ico";
                Alias = "ddg";
              }
            ];
            Default = "DuckDuckGo";
          };
          SearchSuggestEnabled = true;
          ShowHomeButton = true;
          UserMessaging = {
            ExtensionRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            FirefoxLabs = true;
          };
          Preferences."browser.cache.disk.enable" = {
            Value = false;
            Status = "locked";
          };
          Preferences."browser.cache.disk.capacity" = {
            Value = 0;
            Status = "locked";
          };
          Preferences."browser.cache.disk.smart_size.enabled" = {
            Value = false;
            Status = "locked";
          };
          Preferences."browser.cache.offline.enable" = {
            Value = false;
            Status = "locked";
          };
          Preferences."browser.search.suggest.enabled" = {
            Value = true;
            Status = "locked";
          };
          Preferences."browser.urlbar.suggest.searches" = {
            Value = true;
            Status = "locked";
          };
          Preferences."toolkit.legacyUserProfileCustomizations.stylesheets" = {
            Value = true;
            Status = "locked";
          };
        };
      };
    })
  ];
}
