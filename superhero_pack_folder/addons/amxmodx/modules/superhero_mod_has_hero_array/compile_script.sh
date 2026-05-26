#!/bin/bash

g++ -fPIC -g -ggdb -std=gnu++98  -c hero_array_module.cpp amxxmodule.cpp -m32
g++ -shared -o hero_array_module_amxx_i386.so hero_array_module.o amxxmodule.o -m32
#g++ -o hero_array_module_amxx_i386.so hero_array_module.cpp amxxmodule.cpp
