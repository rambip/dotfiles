{config, pkgs, ...}:
let 
  pkgsUnstable = import <nixpkgs-unstable> {};
  config_dir = "/home/rambi/conf";
  custom_scripts = (import ./scripts/scripts.nix {inherit pkgs;}) ;
in rec {
  home.username = "rambi";
  home.homeDirectory = "/home/rambi";

  home.stateVersion = "21.05";

  home.sessionPath = [ "\$HOME\.cargo/bin" ];

  home.sessionVariables = {
	EDITOR = "nvim";
        XDG_SESSION_TYPE="wayland";
        #VISUAL = "gvim";
        BROWSER = "brave";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        #TERM = "xterm-256color";
  };
  
  programs.home-manager.enable = true;


  home.packages = with pkgs; let
    dev_tools = [
      toilet
      figlet
      python3
      tree
      tldr
      macchina
      rust-analyzer
      crate2nix
      yarn
      wabt
      any-nix-shell
      ocaml
      (import ./tools/idris2-pkgs).default # idris2 compiler
      (import ./tools/idris2-pkgs).packages.x86_64-linux.lsp # idris2 lsp
      gcc
      bash
      pkgsUnstable.neovim
      pkgsUnstable.ttyper
      cargo
    ];
    desktop_tools = [
      pkgsUnstable.vieb
      kitty
      bat
      custom_scripts
      gnome.seahorse
      gnome.nautilus
      wofi
      i3status-rust
      ranger
      udiskie
    ];

  in dev_tools ++ desktop_tools;

  programs.git = {
    enable = true;
    userName = "rambip";
    userEmail = "apero1808@gmail.com";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      v = "nvim";
      HM = "home-manager";
      c = "clear";
    };
    interactiveShellInit = ''
    set fish_greeting
    fish_vi_key_bindings
    macchina
    '';
    promptInit = ''
    any-nix-shell fish --info-right | source
    '';
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    clock24 = true;
    keyMode = "vi";
    extraConfig = builtins.readFile ./editor/tmux.conf;
  };

  programs.obs-studio = {
    enable = true;
    plugins = [pkgs.obs-v4l2sink];
  };

  programs.mako = {
    enable = true;
    defaultTimeout = 3000;
  };

  gtk = {
    enable = true;
    theme.package = pkgs.arc-theme;
    theme.name = "Arc";
  };

  wayland.windowManager.sway = 
  let tmux_init = pkgs.writeShellScriptBin "tmux_init" ''
  ${pkgs.sway}/bin/swaymsg "move scratchpad"
  ${pkgs.tmux}/bin/tmux 
  ''; in {
    # TODO: https://nixos.wiki/wiki/Sway
    #package = pkgsUnstable.sway;
    enable = true;
    wrapperFeatures.gtk = true;
    config= {
      startup = [
        {command="${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";}
        {command="${pkgs.kitty}/bin/kitty ${tmux_init}/bin/tmux_init";}
      ];
      focus.forceWrapping = true;
      keybindings = {};
      bars = [];

    };
    extraConfig = builtins.readFile ./desktop/sway;
  };

  xdg.userDirs = {
    download = "\$HOME/Downloads";
    desktop = "\$HOME";
    pictures = "\$HOME/Pictures";
  };

  #services.polybar = {
	#enable = false;
	#package = pkgs.polybar.override {pulseSupport = true;};
  #      config = ./desktop/polybar;
  #      extraConfig =
  #      ''

  #      ;https://github.com/polybar/polybar/wiki/User-contributed-modules
  #      [module/xmonad]
  #      type = custom/script
  #      exec = ${pkgs.xmonad-log}/bin/xmonad-log
  #      tail = true

  #      [module/wallpaper]
  #      type = custom/ipc

  #      hook-0 = echo 🌄 
  #      hook-1 = ${pkgs.coreutils}/bin/cat /tmp/current_wallpaper
  #      initial = 1

  #      click-left = ${pkgs.polybar}/bin/polybar-msg -p %pid% hook wallpaper 1
  #      click-right = ${pkgs.polybar}/bin/polybar-msg -p %pid% hook wallpaper 2
  #      '';
	## script to start polybar.
	## Call nix-shell to pass the right applications
  #      #/nix/store/l7vznaq67365yvd9j2ahzvp3fjp2knsi-system-path/bin/nix-shell
  #      script =
  #        ''
  #        ${random_wallpaper}/bin/random_wallpaper 
  #        polybar top &
  #        '';
  #};

  services.udiskie = {enable=true;};
  #services.blueman-applet.enable = true;
  #services.network-manager-applet.enable = true;
   services.nextcloud-client= {
     enable = true;
     #startInBackground = true;
   };

  # xsession.windowManager.xmonad = {
  #   enable = false;
  #   config = ./desktop/xmonad.hs;
  #   enableContribAndExtras = true;
  #   extraPackages = hp: [hp.dbus hp.monad-logger];
  # };

  xdg.configFile = {
    "macchina/macchina.toml"   .source = pkgs.writeText "config"
    ''
    custom_ascii = '${builtins.path {path=./ascii/arco; name="ascii"; }}'
    ${builtins.readFile ./other/macchina}

    '';

    "kitty/kitty.conf"         .source = ./desktop/kitty.conf;
    "i3status-rust/config.toml".source = ./desktop/i3status-rust;
    # "i3/config"                .source = ./desktop/i3;
    "nvim/init.lua"            .source = ./editor/nvim.lua;
    #"sway/config"              .source = ./desktop/sway;
    "ranger/rc.conf"           .source = ./other/rc.conf;
    # "discord/settings.json"     .text =  '' "SKIP_HOST_UPDATE": true '';
  };

  home.file = { 
     ".vimrc"  .source = ./editor/vimrc;
    ".viebrc"   .source = ./desktop/viebrc;
  };

}
