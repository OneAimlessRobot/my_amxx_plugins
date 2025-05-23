// kzam
/* CVARS - copy and paste to shconfig.cfg

//
kzam_level 12
kzam_target_radius 2000.0
kzam_spore_damage 100.0
kzam_spore_speed 900.0
kzam_track_time 5.0
kzam_follow_time 5.0
kzam_max_victims 4
kzam_heal_coeff 0.5
*/


#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "kzam_inc/kzam_particle.inc"
#include "kzam_inc/kzam_global.inc"
#include "kzam_inc/kzam_spore_launcher.inc"

// GLOBAL VARIABLES
new gHeroName[]="kzam"
new bool:gHasKzam[SH_MAXSLOTS+1]
new Float:cooldown
new gHeroID
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO kzam","1.1","MilkChanThaGOAT")
	
	register_cvar("kzam_level", "12" )
	register_cvar("kzam_cooldown", "10.0" )
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Spore Launcher", "Launch spores that follow enemies!", true, "kzam_level" )
	register_event("ResetHUD","newRound","b")
	
	
	// INIT
	register_srvcmd("kzam_init", "kzam_init")
	shRegHeroInit(gHeroName, "kzam_init")
	
	register_srvcmd("kzam_kd", "kzam_kd")
	shRegKeyDown(gHeroName, "kzam_kd")
}
public plugin_natives(){
	
	
	
	register_native("spores_has_kzam","_spores_has_kzam",0)
	register_native("spores_cooldown","_spores_cooldown",0)
	
	
	
}

public _spores_has_kzam(iPlugins, iParms){
	
	new id= get_param(1)
	return gHasKzam[id]
	
}public Float:_spores_cooldown(iPlugins, iParms){
	
	return cooldown
	
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
	if(!is_user_connected(id)||!sh_is_active()||!id){
		
		return PLUGIN_CONTINUE
	}
	spores_reset_user(id)
	if ( spores_has_kzam(id)) {
		sh_end_cooldown(id+SH_COOLDOWN_TASKID)
		init_hud_tasks(id)
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	cooldown= get_cvar_float("kzam_cooldown")
	
}
//----------------------------------------------------------------------------------------------
public kzam_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	
	gHasKzam[id] = (hasPowers!=0)
	if ( gHasKzam[id] )
	{
		spores_reset_user(id)
		init_cooldown_update_tasks(id)
		init_hud_tasks(id)
	}
	else{
		spores_reset_user(id)
		delete_cooldown_update_tasks(id)
		delete_hud_tasks(id)
	}
}
//----------------------------------------------------------------------------------------------
public kzam_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !client_hittable(id) || !spores_has_kzam(id) ) return PLUGIN_HANDLED
	
	// Let them know they already used their ultimate if they have
	if ( gPlayerUltimateUsed[id] ) {
		playSoundDenySelect(id)
		sh_chat_message(id,gHeroID,"Spore launcher still in cooldown!");
		return PLUGIN_HANDLED
	}
	else if(spores_busy(id)){
		
		playSoundDenySelect(id)
		sh_chat_message(id,gHeroID,"Some launched spores still busy!");
		return PLUGIN_HANDLED
		
		
	}
	
	ultimateTimer(id, cooldown)
	
	// colussus Messsage
	new message[128]
	format(message, 127, SEARCH_MSG )
	set_hudmessage(255,0,255,-1.0,0.3,0,0.25,1.0,0.0,0.0,4)
	show_hudmessage(id, message)
	spores_reset_user(id)
	spores_gather_targets(id)
	spores_launch(id)
	
	return PLUGIN_HANDLED
}
