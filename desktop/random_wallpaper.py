from os import environ, listdir
from subprocess import Popen, PIPE, call
import random
from wand.image import Image

folder = environ['HOME']+'/Wallpapers/'
choice = random.choice(listdir(folder))
path = folder + choice

# set image to bg
call(['swaymsg', 'output', '*', 'bg' , path, 'fill'])

# calculate the average color
with Image(filename=path) as img:
    img.sample(5, 5)
    img.sample(1, 1)

    pix = img[0][0]
    r, g, b = [min(150, max(15, col)) for col in (pix.red_int8, pix.green_int8, pix.blue_int8)]
    print(r, g, b)

# send report to xrdb, which store the x color informations (Xressources)
call(['swaymsg', 'bar', '0', 'colors', 'background', f'#{r:02x}{g:02x}{b:02x}'])

with open('/tmp/current_wallpaper', 'w') as f:
    f.write(choice)
