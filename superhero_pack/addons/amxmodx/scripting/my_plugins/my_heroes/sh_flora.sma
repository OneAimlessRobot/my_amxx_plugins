

#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "flora_inc/flora_field.inc"
#include "flora_inc/flora_global.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"

// GLOBAL VARIABLES
new gHeroName[]="Flora"
new gHasFlora[SH_MAXSLOTS+1]
new gmorphed[SH_MAXSLOTS+1]
new g_flora_num_of_fields[SH_MAXSLOTS+1]
new g_flora_num_of_fields_prev[SH_MAXSLOTS+1]
new g_flora_previous_weapon[SH_MAXSLOTS+1]
new gFloraHeroLvl
new teamglow_on
new gHeroID
new hud_sync_stats
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO flora","1.1","MilkChanThaGOAT")
	
	register_cvar("flora_level", "39" )
	register_cvar("flora_teamglow_on", "1")
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Sprawling Garden", "Create biohazard fields which weaken enemies!", true, "flora_level" )
	register_event("ResetHUD","newRound","b")
	//register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	register_event("DeathMsg","death","a")
	// INIT
	register_srvcmd("flora_init", "flora_init")
	shRegHeroInit(gHeroName, "flora_init")
	
	hud_sync_stats=CreateHudSyncObj()
	register_srvcmd("flora_kd", "flora_kd")
	shRegKeyDown(gHeroName, "flora_kd")
	register_srvcmd("flora_ku", "flora_ku")
	shRegKeyUp(gHeroName, "flora_ku")
	// REGISTER EVENTS THIS HERO WILL RESPOND TO!
}





public plugin_natives(){

	register_native("flora_get_has_flora","_flora_get_has_flora",0);
	register_native("flora_get_hero_id","_flora_get_hero_id",0);
	register_native("flora_set_prev_weapon","_flora_set_prev_weapon",0)
	register_native("flora_get_prev_weapon","_flora_get_prev_weapon",0)
	register_native("flora_get_user_num_fields","_flora_get_user_num_fields",0)
	register_native("flora_set_user_num_fields","_flora_set_user_num_fields",0)
	register_native("flora_dec_user_num_fields","_flora_dec_user_num_fields",0)
	register_native("flora_get_hero_lvl","_flora_get_hero_lvl",0)
	
	//register_native("flora_inc_user_num_fields","_flora_inc_user_num_fields",0)

	

}
public _flora_set_prev_weapon(iPlugins,iParams){
	new id=get_param(1)
	new value=get_param(2)
	
	g_flora_previous_weapon[id]=value
	

}
public _flora_get_prev_weapon(iPlugins,iParams){
	new id=get_param(1)
	
	return g_flora_previous_weapon[id]
	

}
public _flora_get_hero_lvl(iPlugins,iParams){
	
	
	return gFloraHeroLvl
	
	
}
delete_hud_tasks(id){
	
	sh_chat_message(id,flora_get_hero_id(),"Hud removido!!!^n")
	remove_task(id+STATUS_UPDATE_TASKID)
	
	
	
}

init_hud_tasks(id){
	set_task(STATUS_UPDATE_PERIOD,"status_hud",id+STATUS_UPDATE_TASKID,"",0,"b")
	
	
}
public _flora_get_user_num_fields(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_num_of_fields[id]
}
public _flora_set_user_num_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)
	
	g_flora_num_of_fields[id]=value

}
public _flora_dec_user_num_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_fields[id]= (g_flora_num_of_fields[id]>0)? (g_flora_num_of_fields[id]-value):0

}
public _flora_get_has_flora(iPlugin,iParams){
	
	new id= get_param(1)
	
	return gHasFlora[id]

}
public _flora_get_hero_id(iPlugin,iParams){
	
	return gHeroID

}
/*public _flora_inc_user_num_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_fields[id]=((flora_max+value)>=flora_field_max_ammount)? flora_field_max_ammount:g_flora_num_of_fields[id]+value

}*/
public status_hud(id){
	id-=STATUS_UPDATE_TASKID
	if(!flora_get_has_flora(id)||!client_hittable(id)||!sh_is_active()){
		
		delete_hud_tasks(id)
		return
		
	}
	new hud_msg[301];
	format(hud_msg,300,"[SH] flora:^nNumber active fields: %d^nNumber of fields left: %d^n",
					flora_get_user_num_active_fields(id),
					flora_get_user_num_fields(id));
	
	new color[3];
	color[0]=LineColors[GREEN][0]
	color[1]=LineColors[GREEN][1]
	color[2]=LineColors[GREEN][2]
	if(!field_loaded(id)){
			
		format(hud_msg,300,"%s^nCooldown_remaining_value: %0.2f^n",hud_msg,
		field_get_user_field_cooldown(id));
	}
	else{
		
		
		format(hud_msg,300,"%s^nnext field ready^n",hud_msg)
		
			
			
	}
	set_hudmessage(color[0], color[1], color[2],1.0, 0.3, 0, 0.0, 2.0,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_stats, "%s", hud_msg)
		
}

//----------------------------------------------------------------------------------------------
public newRound(id)
{
	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}
	if ( flora_get_has_flora(id)) {
		reset_flora_user(id)
		init_hud_tasks(id)
		flora_set_user_num_fields(id,flora_start_fields())
		flora_morph(id+FLORA_MORPH_TASKID)
	}
	return PLUGIN_CONTINUE
}
public sh_round_end(){

	//clear_fields()

}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	gFloraHeroLvl=get_cvar_num("flora_level")
	teamglow_on=get_cvar_num("flora_teamglow_on")
	
}
//----------------------------------------------------------------------------------------------
public flora_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	
	gHasFlora[id] = (hasPowers!=0)
	if ( gHasFlora[id] )
	{
		
		reset_flora_user(id)
		init_hud_tasks(id)
		flora_set_user_num_fields(id,flora_start_fields())
		flora_morph(id+FLORA_MORPH_TASKID)
	}
	else{
		reset_flora_user(id)
		delete_hud_tasks(id)
		flora_unmorph(id+FLORA_MORPH_TASKID)
	}
}


public plugin_precache(){
	
	precache_model(FLORA_PLAYER_MODEL)

}
//----------------------------------------------------------------------------------------------
public flora_model(id)
{
	if ( !client_hittable(id)||!flora_get_has_flora(id) ) return
	
	set_task(1.0, "flora_morph", id+FLORA_MORPH_TASKID)
	if( teamglow_on){
		set_task(1.0, "flora_glow", id+FLORA_MORPH_TASKID, "", 0, "b" )
	}

}
//----------------------------------------------------------------------------------------------
public flora_morph(id)
{
	id-=FLORA_MORPH_TASKID
	if ( gmorphed[id] || !client_hittable(id)||!flora_get_has_flora(id) ) return
	
	// Message
	/*set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 7)
	show_hudmessage(id, "flora: 'h- hey! hhello!'")*/
	cs_set_user_model(id,"flora")

	gmorphed[id] = true
	
}
//----------------------------------------------------------------------------------------------
public flora_unmorph(id)
{
	id-=FLORA_MORPH_TASKID
	if(!is_user_connected(id) ) return
	if ( gmorphed[id] ) {

		cs_reset_user_model(id)

		gmorphed[id] = false

		if ( teamglow_on ) {
			remove_task(id+FLORA_MORPH_TASKID)
			set_user_rendering(id)
		}
	}
}
public client_disconnected(id){
	
	reset_flora_user(id)
	delete_hud_tasks(id)
	flora_unmorph(id+FLORA_MORPH_TASKID)
	gHasFlora[id]=0;

}
//----------------------------------------------------------------------------------------------
public flora_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id) ||!flora_get_has_flora(id)) {
		return PLUGIN_CONTINUE
	}
	if(!field_loaded(id)){
		
		sh_sound_deny(id)
		sh_chat_message(id, flora_get_hero_id(), "Field deployment still in cooldown! Wait %0.2f more seconds!",field_get_user_field_cooldown(id))
		return PLUGIN_HANDLED
		
		
	}
	
	if(flora_get_user_num_active_fields(id)>=flora_max_fields()){
		
		sh_chat_message(id, flora_get_hero_id(), "Already at %d fields out of %d (the max)",flora_get_user_num_active_fields(id),flora_max_fields())
		return PLUGIN_HANDLED
		
	}
	new clip, ammo, weaponID = get_user_weapon(id, clip, ammo)
	flora_set_prev_weapon(id,weaponID)

	g_flora_num_of_fields_prev[id]=g_flora_num_of_fields[id]
	form_field(id)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public flora_ku()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !!client_hittable(id) ||!flora_get_has_flora(id)) {
		return PLUGIN_HANDLED
	}
	
	if(flora_get_user_num_active_fields(id)<flora_max_fields()){
		if(g_flora_num_of_fields_prev[id]==g_flora_num_of_fields[id]){
			sh_chat_message(id,flora_get_hero_id(),"Field not deployed. Action interrupted");
		}
		field_uncharge_user(id)
		
		return PLUGIN_HANDLED
	}
	
	
	return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------
public flora_glow(id)
{
	id -= FLORA_MORPH_TASKID

	if ( !client_hittable(id) ) {
		//Don't want any left over residuals
		remove_task(id+FLORA_MORPH_TASKID)
		return
	}

	if ( flora_get_has_flora(id) && is_user_alive(id)) {
		if ( get_user_team(id) == 1 ) {
			shGlow(id, 0, 255, 255)
		}
		else {
			shGlow(id, 0, 0, 255)
		}
	}
}

public death()
{
new id = read_data(2)
if(is_user_connected(id)){
	if(flora_get_has_flora(id)){
		reset_flora_user(id)
		flora_unmorph(id+FLORA_MORPH_TASKID)
		delete_hud_tasks(id)
}
}
}