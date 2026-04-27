#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "girlb_includes/girlb_get_set.inc"
#include "girlb_includes/girlb_ice_glob_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../my_include/my_author_header.inc"
#include "freeze_fx/freeze_fx.inc"
#include "custom_grenades/custom_grenades.inc"

// GLOBAL VARIABLES
new gHeroID
new gHeroName[]="Girl B"
new gNumGlobs[SH_MAXSLOTS+1] = {0, ...}
new girlb_held_down_mask = 0
new girlb_projectile_ammo,
    Float:girlb_projectile_fire_period

new SHOOT_GLOB_TASKID
//----------------------------------------------------------------------------------------------
public plugin_init()
{
    // Plugin Info
    register_plugin("SUPERHERO GirlB","1.0",AUTHOR)

    register_cvar("girlb_level", "29" )
    register_cvar("girlb_projectile_ammo","30")
    register_cvar("girlb_projectile_fire_period","0.3")


    // FIRE THE EVENT TO CREATE THIS SUPERHERO!
    gHeroID=shCreateHero(gHeroName, "Ice skater!!", "Fire projectiles to freeze enemies! Skate on ice in the ground where they land!", true, "girlb_level" )

    register_event("ResetHUD","newRound","b")
    register_srvcmd("girlb_init", "girlb_init")
    shRegHeroInit(gHeroName, "girlb_init")

    register_srvcmd("girlb_kd", "girlb_kd")
    shRegKeyDown(gHeroName, "girlb_kd")
    register_srvcmd("girlb_ku", "girlb_ku")
    shRegKeyUp(gHeroName, "girlb_ku")
    SHOOT_GLOB_TASKID=allocate_typed_task_id(player_task)
}
public plugin_natives(){
	
	
	register_native("girlb_dec_num_globs","_girlb_dec_num_globs",0);
	register_native("girlb_get_num_globs","_girlb_get_num_globs",0);
	register_native("girlb_set_num_globs","_girlb_set_num_globs",0);
	
	register_native("girlb_get_hero_id","_girlb_get_hero_id",0);
	
	
}

public _girlb_get_hero_id(iPlugin,iParams){
	return gHeroID
}
public _girlb_set_num_globs(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	gNumGlobs[id]=value_to_set;
}
public _girlb_get_num_globs(iPlugin,iParams){
	
	
	new id= get_param(1)
	return gNumGlobs[id]
	
}

public _girlb_dec_num_globs(iPlugin,iParams){
	
	
	new id= get_param(1)
	gNumGlobs[id]-= (gNumGlobs[id]>0)? 1:0
	
}

//----------------------------------------------------------------------------------------------
public newRound(id)
{
    if(!client_hittable(id)||!sh_is_active()){
        
        return PLUGIN_CONTINUE
    }
    if ( sh_user_has_hero(id,gHeroID) ) {
        
        gNumGlobs[id]=girlb_projectile_ammo
        give_custom_grenades(id,GREN_FREEZE,2)
        sh_unset_cooldown_flag(id)
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
    girlb_projectile_fire_period=get_cvar_float("girlb_projectile_fire_period")
    girlb_projectile_ammo=get_cvar_num("girlb_projectile_ammo")
}
//----------------------------------------------------------------------------------------------
public girlb_init()
{
    // First Argument is an id
    new temp[6]
    read_argv(1,temp,5)
    new id=str_to_num(temp)

    gNumGlobs[id]=girlb_projectile_ammo

}
public sh_round_end(){

    remove_entity_name(GLOB_CLASSNAME)
}
//----------------------------------------------------------------------------------------------
public girlb_kd()
{
    if(!sh_is_active()||!sh_is_inround()) return PLUGIN_CONTINUE
    
    new temp[6]

    read_argv(1,temp,5)
    new id=str_to_num(temp)

    if ( !client_hittable(id) ) return PLUGIN_HANDLED

    if(!sh_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED

    if(sh_get_cooldown_flag(id)){

        sh_sound_deny(id)
        return PLUGIN_HANDLED
    }
    Set_BitVar(girlb_held_down_mask,id)
    launch_ice_glob(id)
    set_task(girlb_projectile_fire_period,"shoot_glob_task",id+SHOOT_GLOB_TASKID)
    //sh_set_cooldown(id,girlb_projectile_fire_period)
    return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public girlb_ku()
{
    if(!sh_is_active()||!sh_is_inround()) return PLUGIN_CONTINUE
    
    new temp[6]

    read_argv(1,temp,5)
    new id=str_to_num(temp)

    if ( !client_hittable(id) ) return PLUGIN_HANDLED

    if(!sh_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED;

    UnSet_BitVar(girlb_held_down_mask,id);

    return PLUGIN_HANDLED
}
public shoot_glob_task(id){

    if(!sh_is_active()||!sh_is_inround()) return
    
    id-=SHOOT_GLOB_TASKID

    if ( !client_hittable(id) ) return 
    
    if(Get_BitVar(girlb_held_down_mask,id)){

        launch_ice_glob(id)
        set_task(girlb_projectile_fire_period,"shoot_glob_task",id+SHOOT_GLOB_TASKID)

    }
    

}
public plugin_precache(){


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

    if(!sh_user_has_hero(victim,gHeroID)&&!sh_user_has_hero(attacker,gHeroID)) return DMG_FWD_PASS

    return DMG_FWD_PASS

}