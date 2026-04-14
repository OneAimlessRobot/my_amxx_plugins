#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "my_include/randomx.inc"
#include "my_include/my_author_header.inc"

#define PLUGIN "quick precache testing"
#define VERSION "1.0.0"

stock the_salt_string[34]

public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);
	server_print("What follows^nis a random salt from the ^"RandomX^" library.^nDid it load?^n")
	server_print("The salt:^n")
	generate_salt(the_salt_string)
	server_print("%s^n",the_salt_string)
}


public plugin_precache(){
//add stuff here to test precahing
//Useful when I am trying to see if the sv_downloadurl is correctly set at server.cfg
}