#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "flora_inc/flora_field.inc"
#include "flora_inc/flora_global.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "./superheromod_help_files_includes/superheromod_help_files.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"


stock const debug_hud_mode= false


// GLOBAL VARIABLES
new gHeroName[]="Flora"
new g_flora_num_of_fields[SH_MAXSLOTS+1]
new pcvar_gFloraHeroLvl
new gHeroID

new pcvar_flora_field_start_ammount,
	pcvar_flora_field_max_active_ammount
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO flora","1.1",AUTHOR)
	
	pcvar_gFloraHeroLvl = register_cvar("flora_level", "39" )
	pcvar_flora_field_start_ammount = register_cvar("flora_field_start_ammount", "10" )
	pcvar_flora_field_max_active_ammount = register_cvar("flora_field_max_active_ammount", "10" )
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Sprawling Garden", "Create biohazard fields which weaken enemies!", true, "flora_level", true )
	sh_register_superheromod_model(gHeroID,
							FLORA_PLAYER_MODEL,
							FLORA_PLAYER_MODEL_T,
							"Flora",
							"",
							"")
	static hero_name_arr[STRLEN_FOR_NAMES];
	arrayset(hero_name_arr,0,sizeof hero_name_arr)
	add(hero_name_arr,charsmax(hero_name_arr),gHeroName,charsmax(gHeroName))
	superheromod_help_link_hero(gHeroID, "Flora: Help file","flora_folder/","flora_help_file.html",hero_name_arr)
	
}





public plugin_natives(){

	register_native("flora_get_hero_id","_flora_get_hero_id",0);
	register_native("flora_get_user_num_fields","_flora_get_user_num_fields",0)
	register_native("flora_set_user_num_fields","_flora_set_user_num_fields",0)
	register_native("flora_dec_user_num_fields","_flora_dec_user_num_fields",0)
	register_native("flora_get_hero_lvl","_flora_get_hero_lvl",0)
	

	

}
public _flora_get_hero_lvl(iPlugins,iParams){
	
	
	return cvar_val(num, pcvar_gFloraHeroLvl)
	
	
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
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}
	if ( sh_user_has_hero(id,gHeroID) ) {
		reset_flora_user(id)
		g_flora_num_of_fields[id]=cvar_val(num,pcvar_flora_field_start_ammount)
	}
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode){
	if(heroID!=gHeroID) return

	if(sh_user_has_hero(id, gHeroID)){

		g_flora_num_of_fields[id]=cvar_val(num,pcvar_flora_field_start_ammount)
	}
	reset_flora_user(id)
}

public client_disconnected(id){
	
	reset_flora_user(id)

}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, key)
{
if ( gHeroID != heroID ||!sh_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		flora_kd(id)
	}
	
	case SH_KEYUP: {
		
		flora_ku(id)
	}
}
}
//----------------------------------------------------------------------------------------------
public flora_kd(id)
{
	if ( !is_user_alive(id) ||!sh_user_has_hero(id,gHeroID) ) {
		return PLUGIN_CONTINUE
	}

	if(!field_loaded(id)){
		if(!is_user_bot(id)){
			sh_sound_deny(id)
			sh_chat_message(id, gHeroID, "Field deployment still in cooldown! Wait %0.2f more seconds!",field_get_user_field_cooldown(id))
		
		}
		return PLUGIN_HANDLED
		
		
	}
	
	if(flora_get_user_num_active_fields(id)>=cvar_val(num,pcvar_flora_field_max_active_ammount)){
		
		
		if(!is_user_bot(id)){
				sh_chat_message(id, gHeroID, "Already at %d fields out of %d (the max)",flora_get_user_num_active_fields(id),
							cvar_val(num,pcvar_flora_field_max_active_ammount))
		}
		return PLUGIN_HANDLED
		
	}
	form_field(id)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public flora_ku(id)
{
	
	if ( !is_user_alive(id) ||!sh_user_has_hero(id,gHeroID) ) {
		return PLUGIN_HANDLED
	}
	
	if(flora_get_user_num_active_fields(id)<
			cvar_val(num,pcvar_flora_field_max_active_ammount)){
		
		field_uncharge_user(id)
		
		return PLUGIN_HANDLED
	}
	
	
	return PLUGIN_HANDLED
}


public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &my_hitpoint_enum:bodypart,&dmgMode, &sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
	
		return DMG_FWD_PASS
	}
	new result= DMG_FWD_PASS
	if((new_dmg_type==SH_NEW_DMG_FIRE)){
		if(sh_user_has_hero(victim,gHeroID) ){
			damage*=3
		}
	}
	return result
}

public sh_client_death(id,killer,headshot,const wpnDescription[])
{
if(is_user_connected(id)){
	if(sh_user_has_hero(id,gHeroID) ){
		reset_flora_user(id)
	}
}
}