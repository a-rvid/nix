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
      ]
      ++ (with pkgs; [
        grim
        slurp
        wl-clipboard
      ]);

      system.activationScripts.emacsConfig = {
        deps = [ "users" ];
        text = ''
          userHome=${config.users.users.${config.my.username}.home}
          initFile="$userHome/.emacs.d/init.el"
          install -d -o ${config.my.username} \
            -g ${config.users.users.${config.my.username}.group} \
            -m 0755 "$userHome/.emacs.d"

          if [ ! -e "$initFile" ] || \
             { [ -L "$initFile" ] && [[ "$(readlink "$initFile")" == /nix/store/* ]]; }; then
            ln -sfnT ${../../home/.config/emacs/init.el} "$initFile"
            chown -h ${config.my.username}:${config.users.users.${config.my.username}.group} "$initFile"
          else
            echo "Keeping existing Emacs init file at $initFile" >&2
          fi
        '';
      };

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
            WebSuggestions = false;
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
          SearchSuggestEnabled = false;
          ShowHomeButton = true;
          UserMessaging = {
            ExtensionRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            FirefoxLabs = true;
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
