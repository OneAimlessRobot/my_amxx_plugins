#!/bin/bash

find cstrike -type f \( -name '*.bsp' -o -name '*.mdl' -o -name '*.wav'   -o -name '*.spr' -o -name '*.tga' \) -exec bzip2 -k {} \;
