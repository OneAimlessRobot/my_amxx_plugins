#!/bin/bash

# -nofbo (makes rendering similar to how it used to be and removes anti-aliasing)
# -noforcemparms (if not used, windows will uncheck "enhanced pointer precision every time you load CS)
# -freq X or possibly -refresh X (sets your refresh rate to X; command was brought back)
# -stretchaspect removes blackbars so you can use a 4:3 aspect ratio resolution in widescreen

SteamEnv=1 ./hl.sh -nofbo freq 60  -stretchaspect -noforcemparms -game cstrike +port "27020" -w 800 -h 600 -windowed

