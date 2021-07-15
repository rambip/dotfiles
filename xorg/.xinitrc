cat ~/.config/xkb/config.xkb | xkbcomp -I$HOME/.config/xkb - $DISPLAY
exec i3 
