#include "../include/amxmodx.inc"
#include "../include/fakemeta.inc"
#include "my_include/my_author_header.inc"
#include "my_include/auxiliar_stuff.inc"

#define PLUGIN "quick precache testing"
#define VERSION "1.0.0"

public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);
	server_print("Macro test: %d^n",MUL_TWO(8,9))
}


public plugin_precache(){
//add stuff here to test precahing
//Useful when I am trying to see if the sv_downloadurl is correctly set at server.cfg

	engfunc(EngFunc_PrecacheModel,"models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/bustmetal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/bustmetal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
}