#include "../my_include/superheromod.inc"
#include "zenitsu_inc/zenitsu_charge_funcs.inc"
#include "zenitsu_inc/zenitsu_general_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../my_include/my_author_header.inc"


// GLOBAL VARIABLES
new gHeroName[]="Zenitsu Agatsuma"

new pcvar_after_spawn_cooldown


//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Zenitsu Agatsuma","1.0",AUTHOR)
	
	create_cvar("zenitsu_level", "19" )
	pcvar_after_spawn_cooldown = create_cvar("zenitsu_after_spawn_cooldown", "20.0" )
 
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Thunder Hashira", "When all that is left is you...", true, "zenitsu_level" )

	sh_assign_hero_bit(gHeroID, SH_LIGHTNING_ROD_HERO, true)

}
public plugin_natives(){
	register_native("zenitsu_get_hero_id","_zenitsu_get_hero_id")
	
	
	
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

	if ( sh_get_user_has_hero(id,gHeroID) ) {
		new Float:cooldown_secs=cvar_val(float,pcvar_after_spawn_cooldown)
		sh_assign_id_bit(id, SH_ZENITSU_CHARGE_IS_ON, false)
		sh_set_cooldown(id, cooldown_secs)
		sh_chat_message(id,gHeroID,"You are on cooldown for %0.2f seconds after spawning!",cooldown_secs)

	}
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
	if(heroID!=gHeroID) return

	sh_assign_id_bit(id, SH_ZENITSU_CHARGE_IS_ON, false)
}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

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
	if ( !is_user_alive(id) ) return
	
	if(!sh_get_user_has_hero(id,gHeroID) ) return
	
	if(sh_get_cooldown_flag(id)){

		if(!is_user_bot(id)){
			sh_sound_deny(id)
		}
		return
	}
	if(sh_get_id_bit(id, SH_ZENITSU_CHARGE_IS_ON)){

		if(!is_user_bot(id)){
			sh_sound_deny(id)
			sh_chat_message(id,gHeroID,"Charge mode already used!");
		}
		return
	}
	if(sh_get_id_bit(id, SH_ZENITSU_HAS_STRUCK)){
		if(!is_user_bot(id)){
			sh_sound_deny(id)
			sh_chat_message(id,gHeroID,"You already succeeded in slaying an enemy. Wait for next respawn");
		}
		return
	}
	zenitsu_init_battery(id)
}