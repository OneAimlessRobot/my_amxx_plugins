#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "my_include/my_author_header.inc"
#define STRING_SIZE 128
#define BIG_STRING_SIZE (STRING_SIZE*4)

#define PLUGIN "quick precache testing"
#define VERSION "1.0.0"

public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);

}


public plugin_precache(){
//add stuff here to test precahing
//Useful when I am trying to see if the sv_downloadurl is correctly set at server.cfg
}