#!/bin/bash

# -nofbo (makes rendering similar to how it used to be and removes anti-aliasing)
# -noforcemparms (if not used, windows will uncheck "enhanced pointer precision every time you load CS)
# -freq X or possibly -refresh X (sets your refresh rate to X; command was brought back)
# -stretchaspect removes blackbars so you can use a 4:3 aspect ratio resolution in widescreen
# -nomsaa: Disables anti-aliasing.
# -gl: Forces OpenGL mode.
# -noforcemaccel
# -noforcemparms
# -noforcemspd
# -freq 144
# -nosync
# -nojoy
# -w 800 -h 600
# -dev – Developer mode
# -dxlevel 9
SteamEnv=1 ./hl.sh -dev -dxlevel 9 -nosync -nofbo -nomsaa -gl -freq 60 -stretchaspect -noforcemparms -game cstrike +port "27020" -windowed -32bit

