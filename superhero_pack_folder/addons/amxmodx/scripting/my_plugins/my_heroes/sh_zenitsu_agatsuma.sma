#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "zenitsu_inc/zenitsu_charge_funcs.inc"
#include "zenitsu_inc/zenitsu_general_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../my_include/my_author_header.inc"


// GLOBAL VARIABLES
new gHeroName[]="Zenitsu Agatsuma"
new gChargeModeEngagedMask = 0

new gHeroID

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Zenitsu Agatsuma","1.0",AUTHOR)
	
	register_cvar("zenitsu_level", "19" )
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Thunder Hashira", "When all that is left is you...", true, "shinobu_level" )

}
public plugin_natives(){
	register_native("zenitsu_get_hero_id","_zenitsu_get_hero_id",0)
	register_native("zenitsu_get_charge_mode_engaged","_zenitsu_get_charge_mode_engaged",0)
	register_native("zenitsu_set_charge_mode_engaged","_zenitsu_set_charge_mode_engaged",0)
	
	
	
}

public _zenitsu_get_charge_mode_engaged(iPlugins, iParms){
	new id=get_param(1)
	return Get_BitVar(gChargeModeEngagedMask,id)
	
}
public _zenitsu_set_charge_mode_engaged(iPlugins, iParms){
	new id=get_param(1)
	new value=get_param(2)
	if(value){
		Set_BitVar(gChargeModeEngagedMask,id)
	}
	else{
		UnSet_BitVar(gChargeModeEngagedMask,id)
	}
	
}

public _zenitsu_get_hero_id(iPlugins, iParms){
	
	return gHeroID
	
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}

	if ( sh_user_has_hero(id,gHeroID) ) {
		
		UnSet_BitVar(gChargeModeEngagedMask,id)

	}
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode){
	if(heroID!=gHeroID) return

	UnSet_BitVar(gChargeModeEngagedMask,id)
}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, key)
{
if ( gHeroID != heroID ||!sh_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		zenitsu_kd(id)
	}
}
}
//----------------------------------------------------------------------------------------------
public zenitsu_kd(id)
{	
	if ( !is_user_alive(id) ) return PLUGIN_HANDLED
	
	if(!sh_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED
	

	// Let them know they already used their ultimate if they have
	
	if(Get_BitVar(gChargeModeEngagedMask,id)){

		if(!is_user_bot(id)){
			playSoundDenySelect(id)
			sh_chat_message(id,gHeroID,"Charge mode already used!");
		}
		return PLUGIN_HANDLED
	}
	if(zenitsu_get_has_touched_player(id)){
		if(!is_user_bot(id)){
			playSoundDenySelect(id)
			sh_chat_message(id,gHeroID,"You already succeeded in slaying an enemy. Wait for next respawn");
		}
		return PLUGIN_HANDLED
	}
	Set_BitVar(gChargeModeEngagedMask,id)
	sh_sleep_user(id,id,gHeroID)
	return PLUGIN_HANDLED
}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,  &my_hitpoint_enum:bodypart,&dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type, custom_weapon_id){
	if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
	
		return DMG_FWD_PASS
	}
	new result= DMG_FWD_PASS
	if((new_dmg_type==SH_NEW_DMG_ENERGY_BLAST)||(new_dmg_type==SH_NEW_DMG_SHOCK)){
		if(sh_user_has_hero(victim,gHeroID) ){
			result=DMG_FWD_BLOCK
		}
	}
	if(Get_BitVar(gChargeModeEngagedMask, attacker)&&sh_user_has_hero(attacker,gHeroID) ){

		damage*=2
	}
	return result
}
