{config, pkgs, ...}:

let custom_layout = pkgs.stdenv.mkDerivation {
  # my custom layout: create a binary file layout.xkm
  # from a layout (./xorg/beprog) and a description file (./xorg/config.xkb)
  name = "beprog";
  src = ./xorg;
  buildInputs = [pkgs.xorg.xkbcomp];
  buildPhase = ''
  mkdir symbols
  cp beprog symbols/
  xkbcomp config.xkb -I./ -xkb -o result.xkb
  '';
  installPhase = ''
  mkdir $out
  sed -i 's/pc_beprog_fr_2/pc+beprog+fr:2/' result.xkb
  mv result.xkb $out/layout.xkb
  '';
};

in
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
      vimPlugins.Vundle-vim
      vim
      i3status-rust
      kbdd
      dunst
      # TODO: picom ?
      #python38Packages.Wand
    ];
  in dev_tools ++ desktop_tools;

  #programs.vim = {
  #  enable = true;
  #  plugins = with pkgs.vimPlugins; [
  #    lightline-vim
  #    vim-surround
  #    vim-repeat
  #    rust-vim
  #    vim-nix
  #    idris2-vim
  #    elm-vim
  #  ];
  #};

  xdg.userDirs = {
    download = "\$HOME/Downloads";
    desktop = "\$HOME";
    pictures = "\$HOME/Pictures";
  };

xdg.configFile = {
    "macchina"                 .source = ./macchina;
    "kitty/kitty.conf"         .source = ./kitty/kitty.conf;
    "i3status-rust/config.toml".source = ./i3status-rust/config.toml;
    "i3/"                      .source = ./i3;
    "picom/picom.conf"         .source = ./picom/picom.conf;
    };

    home.file = { 
      ".vimrc"  .source = ./vim/.vimrc;
      ".xinitrc".source = ./xorg/.xinitrc;
      ".xkb".source     = custom_layout;
      ".bashrc".source =  ./shell/.bashrc;
    };
  }
