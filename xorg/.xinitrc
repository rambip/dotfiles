setxkbmap typo,fr 
xkbcomp -w 0 ~/.xkb/layout.xkb $DISPLAY
exec i3 
