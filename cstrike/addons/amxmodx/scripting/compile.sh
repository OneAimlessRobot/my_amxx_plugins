#!/bin/bash

# AMX Mod X
#
# by the AMX Mod X Development Team
#  originally developed by OLO
#
# This file is part of AMX Mod X.

# new code contributed by \malex\


for sourcefile in cshop*.sma
do
        nameoffile="`echo $sourcefile | sed -e 's/\.sma$//'`"
        echo -n "Compiling $nameoffile ..."
        bash ./comp.sh $nameoffile
done
