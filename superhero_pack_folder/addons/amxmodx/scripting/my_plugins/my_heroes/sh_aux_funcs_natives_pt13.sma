#define I_WANT_CONSTANTS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt13: superhero property enforcing pt2: damage gating"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt13.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "../my_include/auxiliar_stuff.inc"


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);


	RegisterHam(Ham_TakeDamage,"player","ham_Superhero_Falldamage",_, true)

}

public plugin_cfg(){


	server_print("%s innited!^n",LIBRARY_NAME)
	
}

//----------------------------------------------------------------------------------------------
public ham_Superhero_Falldamage(this, inflictor, attacker, Float:damage, damagebits)
{
	if(!sh_is_active()||sh_is_freezetime() ||!is_user_alive(this)) return HAM_IGNORED

	if ( damagebits & DMG_FALL && sh_get_player_has_hero_prop(this,SH_ANTI_FALL_DAMAGE_HERO) ){
		SetHamParamFloat(4,0.0)
		return HAM_SUPERCEDE
	}
	if(!is_valid_ent(inflictor)){

		return HAM_IGNORED
	}
	static inflictor_classname[64];

	entity_get_string(inflictor,EV_SZ_classname,inflictor_classname,63)

	if(equal(inflictor_classname,"grenade") &&
				sh_get_player_has_hero_prop(this,SH_ANTI_GRENADES_HERO) ){
		
		SetHamParamFloat(4,0.0)
		
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}
