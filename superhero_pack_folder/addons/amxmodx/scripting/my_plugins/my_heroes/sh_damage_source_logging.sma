#include "../my_include/superheromod.inc"


#define PLUGIN "Superhero damage source logging"
#define VERSION "1.0.0"
#define AUTHOR "ThrashBrat"
#define Struct				enum



public plugin_init(){
	
    register_plugin(PLUGIN, VERSION, AUTHOR);
    server_print("Superhero source logging plugin loaded!^nBut It's still just a stub...^n")
}