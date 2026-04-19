#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


// GLOBAL VARIABLES
new gHeroID
new gHeroName[]="Reika Fukuda"
new Float:reika_explosion_cooldown
new Float:reika_explosion_radius
new Float:reika_explosion_force
new Float:reika_explosion_damage

//----------------------------------------------------------------------------------------------
public plugin_init()
{
    // Plugin Info
    register_plugin("SUPERHERO Reika Fukuda","1.0",AUTHOR)

    register_cvar("reika_level", "12" )
    register_cvar("reika_explosion_cooldown","30.0")
    register_cvar("reika_explosion_radius","300.0")
    register_cvar("reika_explosion_force","250.0")
    register_cvar("reika_explosion_damage","80.0")


    // FIRE THE EVENT TO CREATE THIS SUPERHERO!
    gHeroID=shCreateHero(gHeroName, "Kinetic Demon!", "Release large concussive blasts on keybind!", true, "reika_level" )

    register_event("ResetHUD","newRound","b")
    register_srvcmd("reika_init", "reika_init")
    shRegHeroInit(gHeroName, "reika_init")

    register_srvcmd("reika_kd", "reika_kd")
    shRegKeyDown(gHeroName, "reika_kd")

    init_explosion_defaults()

}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
    if(!client_hittable(id)||!sh_is_active()){
        
        return PLUGIN_CONTINUE
    }
    if ( sh_user_has_hero(id,gHeroID) ) {
        
        gPlayerUltimateUsed[id]=false
        sh_end_cooldown(id+SH_COOLDOWN_TASKID)
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
    reika_explosion_cooldown=get_cvar_float("reika_explosion_cooldown")
    reika_explosion_radius=get_cvar_float("reika_explosion_radius")
    reika_explosion_force=get_cvar_float("reika_explosion_force")
    reika_explosion_damage=get_cvar_float("reika_explosion_damage")
}
//----------------------------------------------------------------------------------------------
public reika_init()
{
	// First Argument is an id
	/*new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	*/
}
//----------------------------------------------------------------------------------------------
public reika_kd()
{
    new temp[6]

    read_argv(1,temp,5)
    new id=str_to_num(temp)

    if ( !client_hittable(id) ) return PLUGIN_HANDLED

    if(!sh_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED

    if(gPlayerUltimateUsed[id]){

        sh_sound_deny(id)
        return PLUGIN_HANDLED
    }
    explosion(gHeroID,id,reika_explosion_radius,
                        reika_explosion_damage,
                        reika_explosion_force,1,1)


    sh_set_cooldown(id,reika_explosion_cooldown)
    return PLUGIN_HANDLED
}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &headshot,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if ( !sh_is_active() || !client_hittable(victim) || !client_hittable(attacker)){
	
		return DMG_FWD_PASS
	}
	if(new_dmg_type==SH_NEW_DMG_IVE_STUDIED_THE_BLADE){
		if(sh_user_has_hero(victim,gHeroID) ){
			return DMG_FWD_BLOCK
		}
	}
	
	return DMG_FWD_PASS
}

//----------------------------------------------------------------------------------------------
public sh_client_death(victim)
{
    if(sh_is_active()||!is_user_connected(victim)) return
    if ( sh_user_has_hero(victim,gHeroID) ) {
        
        gPlayerUltimateUsed[victim]=false
        sh_end_cooldown(victim+SH_COOLDOWN_TASKID)
    }
}