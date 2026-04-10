#include "../my_include/superheromod.inc"
#include "zenitsu_inc/zenitsu_charge_funcs.inc"
#include "zenitsu_inc/zenitsu_general_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"
#include "../my_include/my_author_header.inc"


// GLOBAL VARIABLES
new gHeroName[]="Zenitsu Agatsuma"
new gChargeModeEngaged[SH_MAXSLOTS+1]

new gHeroID

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Zenitsu Agatsuma","1.0",AUTHOR)
	
	register_cvar("zenitsu_level", "19" )
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Thunder Hashira", "When all that is left is you...", true, "shinobu_level" )
	
	register_event("ResetHUD","zenitsu_newRound","b")
	register_srvcmd("zenitsu_init", "zenitsu_init")
	shRegHeroInit(gHeroName, "zenitsu_init")

	
	register_srvcmd("zenitsu_kd", "zenitsu_kd")
	shRegKeyDown(gHeroName, "zenitsu_kd")

	init_hud_syncs()
}
public plugin_natives(){
	register_native("zenitsu_get_hero_id","_zenitsu_get_hero_id",0)
	register_native("zenitsu_get_charge_mode_engaged","_zenitsu_get_charge_mode_engaged",0)
	register_native("zenitsu_set_charge_mode_engaged","_zenitsu_set_charge_mode_engaged",0)
	
	
	
}

public _zenitsu_get_charge_mode_engaged(iPlugins, iParms){
	new id=get_param(1)
	return gChargeModeEngaged[id]
	
}
public _zenitsu_set_charge_mode_engaged(iPlugins, iParms){
	new id=get_param(1)
	new value=get_param(2)
	gChargeModeEngaged[id]=value
	
}

public _zenitsu_get_hero_id(iPlugins, iParms){
	
	return gHeroID
	
}

//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
    //nothing for now

}
//----------------------------------------------------------------------------------------------
public zenitsu_newRound(id)
{
	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}

	if ( sh_user_has_hero(id,gHeroID) ) {
		
		gChargeModeEngaged[id]=0

	}
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public zenitsu_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	
	gChargeModeEngaged[id]=0
}
//----------------------------------------------------------------------------------------------
public zenitsu_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !client_hittable(id) ) return PLUGIN_HANDLED
	
	if(!sh_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED
	
	if(sh_get_user_is_asleep(id)) return PLUGIN_HANDLED
	if(sh_get_user_is_chaffed(id)) return PLUGIN_HANDLED

	// Let them know they already used their ultimate if they have
	
	if(gChargeModeEngaged[id]){

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
	gChargeModeEngaged[id]=1
	sh_sleep_user(id,id,zenitsu_get_hero_id())
	return PLUGIN_HANDLED
}