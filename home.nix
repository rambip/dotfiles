{config, pkgs, ...}:

{
  home.username = "rambi";
  home.homeDirectory = "/home/rambi";

  home.stateVersion = "21.05";

  home.keyboard = null;



  # dev packages
  home.packages = with pkgs; let
    dev_tools = [
    tldr
    macchina
    emscripten
    llvmPackages_12.llvm
    rust-analyzer
    rustup
    wabt
  ];
    desktop_tools = [
      kbdd
      #python38Packages.Wand
    ];
  in dev_tools ++ desktop_tools;

  programs.i3status-rust.enable = true;

  # TODO:

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      lightline-vim
      vim-surround
      vim-repeat
      rust-vim
      vim-nix
      idris2-vim
      elm-vim
    ];
  };

  home.file =     
  let 
    dot_config_folder = {
      ".config/macchina"        .source          = ./macchina;
      ".config/kitty/kitty.conf".source          = ./kitty/kitty.conf;
      ".config/i3status-rust/config.toml".source = ./i3status-rust/config.toml;
      ".config/i3/".source                       = ./i3;
      #".config/nvim/init.lua"   .source = ./vim/init.lua;
      #".i3/config"               = ./
    };

    dot_files = {
      ".vimrc"  .source = ./vim/.vimrc;
      ".xinitrc".source = ./xorg/.xinitrc;
    };

  in dot_config_folder // dot_files;
}
