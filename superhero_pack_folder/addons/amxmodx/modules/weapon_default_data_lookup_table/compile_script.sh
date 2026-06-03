#!/bin/bash

g++ -fPIC -g -ggdb -std=gnu++98  -c weapon_lookup_table.cpp amxxmodule.cpp -m32 -Wall -Wextra -Wsign-conversion -Wshadow -Wpedantic -Wconversion
g++ -shared -o weapon_lookup_table_amxx_i386.so weapon_lookup_table.o amxxmodule.o -m32

