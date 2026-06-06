#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_WEAPONS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt14: delegated tracer logic"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt14.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt14.inc"
#include "../my_include/auxiliar_stuff.inc"


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

}


public plugin_cfg(){


	server_print("%s innited!^n",LIBRARY_NAME)
	
}
public plugin_natives(){

    
	register_native("generic_weapon_tracer_logic", "_generic_weapon_tracer_logic")


}
public bool:_generic_weapon_tracer_logic(iPlugins, iParams){
	new Attacker = get_param(1),
		bool:custom_boolean = bool:get_param(2),
		weapon_id = get_param(3),
		hero_id = get_param(4),
		bool:exclude_custom_weapons = bool:get_param(5)

	static sh_custom_color:color_vector_indices[3],
			shoot_sound_sample[128]

	get_array(6,color_vector_indices, sizeof( color_vector_indices))

	new weapon_tracer_fx_flags:the_bitsum_flags = weapon_tracer_fx_flags:get_param(7)

	get_string(8,shoot_sound_sample, charsmax(shoot_sound_sample))

	if(!is_user_alive(Attacker)){
		return false
	}
	if(hero_id>=0){
		if(!sh_get_user_has_hero(Attacker, hero_id)){
			return false
		}
	}
	if(!custom_boolean){

		return false
	}
	static item; item = get_pdata_cbase(Attacker, m_pActiveItem, XTRA_OFS_PLAYER)

	if(pev_valid(item)!=2){
		return false
	}

	static iId; iId = get_pdata_int(item, m_iId, XO_WEAPON)

	if((iId==CSW_KNIFE)){

		return false
	}
	if(cs_is_valid_itemid(weapon_id,true)){
		
		
		if(iId!=weapon_id){
			return false
		}
	}

	static weapon_secret_code = -1
	weapon_secret_code = get_weapon_secret_code(item)
	if(exclude_custom_weapons && (weapon_secret_code >=0 )){

		return false
	}
	static Float:fvec1[3], Float:fvec2[3],vec1[3],vec2[3]
	if(the_bitsum_flags<=tracer_sfx_show_nothing){

		return false
	}
	if(the_bitsum_flags & tracer_sfx_show_laser_line){
		get_user_origin(Attacker, vec1, 1) // origin; your camera point.
		get_user_origin(Attacker, vec2, 3) // termina; where your bullet goes (4 is cs-only)
		IVecFVec(vec1,fvec1)
		IVecFVec(vec2,fvec2)
		laser_line(Attacker,fvec1, fvec2,true,color_vector_indices,false,
					bool:(the_bitsum_flags & tracer_sfx_show_play_shoot_sound),
					shoot_sound_sample)
	}

	if(the_bitsum_flags & tracer_sfx_show_glow_aura){
		aura(Attacker,LineColors[((cs_get_user_team(Attacker)==CS_TEAM_CT)?color_vector_indices[1]:color_vector_indices[0])])
	}
	return true

}