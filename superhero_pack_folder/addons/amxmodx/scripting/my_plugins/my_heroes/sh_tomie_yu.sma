#define I_WANT_QUICK_CHECKS
#include "../my_include/superheromod.inc"
#include "tomie_yu_inc/tomie_yu.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "custom_grenades/custom_grenades.inc"
#include "../my_include/my_author_header.inc"

#define TOMIE_YU_RADIUS 400.0

// GLOBAL VARIABLES
new gHeroName[]="Tomie Yu"
new gHeroID
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Tomie Yu","1.1",AUTHOR)

	create_cvar("tomie_level", "5" )

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Boring, Anime fan", "Fire retardant hair! Drain resistance! You wont spread fire! CO2 lasts longer!", false, "tomie_level")

}





public plugin_natives(){

	register_native("tomie_yu_hero_id","_tomie_yu_hero_id");
	

	

}
public _tomie_yu_hero_id(iPlugin,iParams){
	
	return gHeroID

}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
    if(!is_user_alive(id)||!sh_is_active()){
        
        return
    }
    if ( sh_get_user_has_hero(id,gHeroID) ) {
        
        give_custom_grenades(id,GREN_CO2,5)

    }
}
public sh_gore_effect_pre(&gored_id, Float:vic_origin[3],Float:origin[3]){
	if ( !sh_is_active() || !is_user_connected(gored_id)){

		return gore_fwd_pass
	}
	new bool:gored_id_has_tomie = bool:sh_get_user_has_hero(gored_id,gHeroID)
	new gore_fwd_return_type:gore_result= gored_id_has_tomie?gore_fwd_block:gore_fwd_pass
	
	static entlist[33];
	new numfound = find_sphere_class(gored_id,"player", TOMIE_YU_RADIUS ,entlist, charsmax(entlist));
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		if( !is_user_alive(pid) ) continue
		
		if(sh_clients_are_same_team(pid,gored_id)||((gored_id==pid)&&gored_id_has_tomie)) continue

		if(sh_get_user_has_hero(pid,gHeroID)){
			
			sh_chat_message(pid,gHeroID,"(reacting to gore): Wooow! Thats so coool... I- I mean-- oh nooo")
		
		}
	}
	return gore_result

}
public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,  &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type, custom_weapon_id){
	if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
	
		return DMG_FWD_PASS
	}
	new bool:headshot = (bodypart==MY_HIT_HEAD)
	if(sh_get_user_has_hero(victim,gHeroID) ){
		switch(new_dmg_type){
			
			case SH_NEW_DMG_FIRE:{
				
				damage= (headshot?0:floatround(float(damage)*0.5))

			}
			case SH_NEW_DMG_DRAIN:{
				
				damage = floatround(float(damage)*0.5)

			}
		}
	}
	return DMG_FWD_PASS
}