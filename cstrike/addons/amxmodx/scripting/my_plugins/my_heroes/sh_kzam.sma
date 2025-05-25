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
new gmorphed[SH_MAXSLOTS+1]
new Float:cooldown
new teamglow_on
new gHeroID
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO kzam","1.1","MilkChanThaGOAT")
	
	register_cvar("kzam_level", "12" )
	register_cvar("kzam_teamglow_on", "1")
	register_cvar("kzam_cooldown", "10.0" )
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Spore Launcher", "Launch spores that follow enemies!", true, "kzam_level" )
	register_event("ResetHUD","newRound","b")
	register_event("DeathMsg","death","a")
	
	
	// INIT
	register_srvcmd("kzam_init", "kzam_init")
	shRegHeroInit(gHeroName, "kzam_init")
	
	register_srvcmd("kzam_kd", "kzam_kd")
	shRegKeyDown(gHeroName, "kzam_kd")
}
public plugin_natives(){
	
	
	
	register_native("spores_has_kzam","_spores_has_kzam",0)
	register_native("spores_cooldown","_spores_cooldown",0)
	register_native("spores_kzam_hero_id","_spores_kzam_hero_id",0)
	
	
	
}

public _spores_kzam_hero_id(iPlugins, iParms){

	return gHeroID
}
public _spores_has_kzam(iPlugins, iParms){
	
	new id= get_param(1)
	return gHasKzam[id]
	
}public Float:_spores_cooldown(iPlugins, iParms){
	
	return cooldown
	
}
kzam_weapons(id)
{
if ( sh_is_active() && client_hittable(id) && spores_has_kzam(id)) {
	sh_give_weapon(id, CSW_M4A1)
}
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}
	spores_reset_user(id)
	if ( spores_has_kzam(id)) {
		kzam_weapons(id)
		kzam_model(id)
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
	teamglow_on=get_cvar_num("kzam_teamglow_on")
	
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
		kzam_model(id)
		init_cooldown_update_tasks(id)
		init_hud_tasks(id)
	}
	else{
		spores_reset_user(id)
		delete_cooldown_update_tasks(id)
		delete_hud_tasks(id)
		kzam_unmorph(id+KZAM_MORPH_TASKID)
		sh_drop_weapon(id, CSW_M4A1, true)
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

public plugin_precache()
{
	precache_model(KZAM_PLAYER_MODEL)

}

//----------------------------------------------------------------------------------------------
public kzam_model(id)
{
	set_task(1.0, "kzam_morph", id+KZAM_MORPH_TASKID)
	if( teamglow_on){
		set_task(1.0, "kzam_glow", id+KZAM_MORPH_TASKID, "", 0, "b" )
	}

}
//----------------------------------------------------------------------------------------------
public kzam_morph(id)
{
	id-=KZAM_MORPH_TASKID
	if ( gmorphed[id] || !is_user_alive(id)||!spores_has_kzam(id) ) return
	
	// Message
	set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 7)
	show_hudmessage(id, "kzam: '...'")
	cs_set_user_model(id,"kzam")

	gmorphed[id] = true
	
}
//----------------------------------------------------------------------------------------------
public kzam_unmorph(id)
{
	id-=KZAM_MORPH_TASKID
	if(!is_user_connected(id) ) return
	if ( gmorphed[id] ) {

		cs_reset_user_model(id)

		gmorphed[id] = false

		if ( teamglow_on ) {
			remove_task(id+KZAM_MORPH_TASKID)
			set_user_rendering(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public kzam_glow(id)
{
	id -= KZAM_MORPH_TASKID

	if ( !is_user_connected(id) ) {
		//Don't want any left over residuals
		remove_task(id+KZAM_MORPH_TASKID)
		return
	}

	if ( spores_has_kzam(id) && is_user_alive(id)) {
		if ( get_user_team(id) == 1 ) {
			shGlow(id, 255, 0, 0)
		}
		else {
			shGlow(id, 0, 0, 255)
		}
	}
}

public death()
{
	new id = read_data(2)
	if(client_hittable(id)&&spores_has_kzam(id)){
		
		kzam_unmorph(id+KZAM_MORPH_TASKID)
	}
}