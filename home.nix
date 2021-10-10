{config, pkgs, ...}:
let 
  pkgsUnstable = import <nixpkgs-unstable> {};
  config_dir = "/home/rambi/conf";
  random_wallpaper = (import ./desktop/random_wallpaper.nix {inherit pkgs;}) ;
in rec {
  home.username = "rambi";
  home.homeDirectory = "/home/rambi";

  home.stateVersion = "21.05";

  home.sessionPath = [ "\$HOME\.cargo/bin" ];

  home.sessionVariables = {
	EDITOR = "nvim";
        START_DISPLAY_COMMAND = "${pkgs.sway}";
        #VISUAL = "gvim";
        BROWSER = "brave";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        TERM = "xterm-256color";
  };
  
  programs.home-manager.enable = true;


  home.packages = with pkgs; let
    dev_tools = [
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
      brave
      pkgsUnstable.vieb
      kitty
      bat
      random_wallpaper
      sway
      wofi
      i3status-rust
      ranger
      baobab
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

  programs.rofi = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;
    plugins = [pkgs.obs-v4l2sink];
  };

  xdg.userDirs = {
    download = "\$HOME/Downloads";
    desktop = "\$HOME";
    pictures = "\$HOME/Pictures";
  };

  services.polybar = {
	enable = false;
	package = pkgs.polybar.override {pulseSupport = true;};
        config = ./desktop/polybar;
        extraConfig =
        ''

        ;https://github.com/polybar/polybar/wiki/User-contributed-modules
        [module/xmonad]
        type = custom/script
        exec = ${pkgs.xmonad-log}/bin/xmonad-log
        tail = true

        [module/wallpaper]
        type = custom/ipc

        hook-0 = echo 🌄 
        hook-1 = ${pkgs.coreutils}/bin/cat /tmp/current_wallpaper
        initial = 1

        click-left = ${pkgs.polybar}/bin/polybar-msg -p %pid% hook wallpaper 1
        click-right = ${pkgs.polybar}/bin/polybar-msg -p %pid% hook wallpaper 2
        '';
	# script to start polybar.
	# Call nix-shell to pass the right applications
        #/nix/store/l7vznaq67365yvd9j2ahzvp3fjp2knsi-system-path/bin/nix-shell
        script =
          ''
          ${random_wallpaper}/bin/random_wallpaper 
          polybar top &
          '';
  };

  services.dunst = {enable=true;}; # CONFIG ?
  services.udiskie = {enable=true; tray="always";};
  services.blueman-applet.enable = true;
  services.network-manager-applet.enable = true;
  services.nextcloud-client= {
    enable = true;
  };

  #xsession.enable = true;

  #xsession.initExtra = builtins.readFile ./desktop/xinitrc;

  # xsession.windowManager.xmonad = {
  #   enable = false;
  #   config = ./desktop/xmonad.hs;
  #   enableContribAndExtras = true;
  #   extraPackages = hp: [hp.dbus hp.monad-logger];
  # };

  # wayland.windowManager.sway = {
  #   enable = true;
  #   systemdIntegration = true;
  #   config = {};
  #   extraConfig = builtins.readFile ./desktop/sway;
  # };

  xdg.configFile = {
    "macchina/macchina.toml"   .source = pkgs.writeText "config"
    ''
    custom_ascii = '${builtins.path {path=./ascii/arco; name="ascii"; }}'
    ${builtins.readFile ./other/macchina}

    '';

    "kitty/kitty.conf"         .source = ./desktop/kitty.conf;
    "i3status-rust/config.toml".source = ./desktop/i3status-rust;
    "i3/config"                .source = ./desktop/i3;
    "picom/picom.conf"         .source = ./desktop/picom.conf;
    "nvim/init.lua"            .source = ./editor/nvim.lua;
    "dunst/dunstrc"            .source = ./desktop/dunstrc;
    "sway/config"              .source = ./desktop/sway;
    "ranger/rc.conf"           .source = ./other/rc.conf;
    # "discord/settings.json"     .text =  '' "SKIP_HOST_UPDATE": true '';
  };

  home.file = { 
     ".vimrc"  .source = ./editor/vimrc;
    ".viebrc"   .source = ./desktop/viebrc;
  };

}
