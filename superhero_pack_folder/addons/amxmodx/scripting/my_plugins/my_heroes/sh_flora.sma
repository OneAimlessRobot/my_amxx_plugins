

#include "../my_include/superheromod.inc"
#include "flora_inc/flora_field.inc"
#include "flora_inc/flora_global.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"


stock const debug_hud_mode= false


// GLOBAL VARIABLES
new gHeroName[]="Flora"
new g_flora_num_of_fields[SH_MAXSLOTS+1]
new gFloraHeroLvl
new gHeroID
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO flora","1.1",AUTHOR)
	
	register_cvar("flora_level", "39" )
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Sprawling Garden", "Create biohazard fields which weaken enemies!", true, "flora_level" )
	sh_register_superheromod_model(gHeroID,
							FLORA_PLAYER_MODEL,
							FLORA_PLAYER_MODEL,
							"Flora",
							"",
							"")

	register_event("ResetHUD","newRound","b")
	
	// INIT
	register_srvcmd("flora_init", "flora_init")
	shRegHeroInit(gHeroName, "flora_init")
	
	register_srvcmd("flora_kd", "flora_kd")
	shRegKeyDown(gHeroName, "flora_kd")
	register_srvcmd("flora_ku", "flora_ku")
	shRegKeyUp(gHeroName, "flora_ku")
}





public plugin_natives(){

	register_native("flora_get_hero_id","_flora_get_hero_id",0);
	register_native("flora_get_user_num_fields","_flora_get_user_num_fields",0)
	register_native("flora_set_user_num_fields","_flora_set_user_num_fields",0)
	register_native("flora_dec_user_num_fields","_flora_dec_user_num_fields",0)
	register_native("flora_get_hero_lvl","_flora_get_hero_lvl",0)
	

	

}
public _flora_get_hero_lvl(iPlugins,iParams){
	
	
	return gFloraHeroLvl
	
	
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
public _flora_get_hero_id(iPlugin,iParams){
	
	return gHeroID

}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}
	if ( sh_user_has_hero(id,gHeroID) ) {
		reset_flora_user(id)
		flora_set_user_num_fields(id,flora_start_fields())
	}
	return PLUGIN_CONTINUE
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
	
}
//----------------------------------------------------------------------------------------------
public flora_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( sh_user_has_hero(id,gHeroID)  )
	{
		flora_set_user_num_fields(id,flora_start_fields())
	}
	reset_flora_user(id)
}

public client_disconnected(id){
	
	reset_flora_user(id)

}
//----------------------------------------------------------------------------------------------
public flora_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id) ||!sh_user_has_hero(id,gHeroID) ) {
		return PLUGIN_CONTINUE
	}
	if (sh_get_user_is_asleep(id)){

		return PLUGIN_HANDLED;
	}
	if(!field_loaded(id)){
		if(!is_user_bot(id)){
			sh_sound_deny(id)
			sh_chat_message(id, flora_get_hero_id(), "Field deployment still in cooldown! Wait %0.2f more seconds!",field_get_user_field_cooldown(id))
		
		}
		return PLUGIN_HANDLED
		
		
	}
	
	if(flora_get_user_num_active_fields(id)>=flora_max_fields()){
		
		
		if(!is_user_bot(id)){
				sh_chat_message(id, flora_get_hero_id(), "Already at %d fields out of %d (the max)",flora_get_user_num_active_fields(id),flora_max_fields())
		}
		return PLUGIN_HANDLED
		
	}
	form_field(id)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public flora_ku()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !client_hittable(id) ||!sh_user_has_hero(id,gHeroID) ) {
		return PLUGIN_HANDLED
	}
	
	if(flora_get_user_num_active_fields(id)<flora_max_fields()){
		
		field_uncharge_user(id)
		
		return PLUGIN_HANDLED
	}
	
	
	return PLUGIN_HANDLED
}


public sh_client_death(id,killer,headshot,const wpnDescription[])
{
if(is_user_connected(id)){
	if(sh_user_has_hero(id,gHeroID) ){
		reset_flora_user(id)
	}
}
}