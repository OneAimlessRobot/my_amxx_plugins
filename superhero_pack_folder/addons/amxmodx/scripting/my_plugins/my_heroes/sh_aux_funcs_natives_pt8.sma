#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt8: safeguard forward tools for shmod"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt8.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt8.inc"

public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);


}
public sh_client_spawn(id){

	if(!user_has_weapon(id,CSW_KNIFE)){
		sh_give_weapon(id,CSW_KNIFE,true)
	}
		
}