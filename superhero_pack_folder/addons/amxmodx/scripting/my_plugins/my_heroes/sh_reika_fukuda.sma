#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"

#define BLOCK_FRACTION 0.80

// GLOBAL VARIABLES
new gHeroID
new gHeroName[]="Reika Fukuda"
new reika_is_parrying_mask = 0
new reika_parried_tg[SH_MAXSLOTS+1] = {0, ...}
new Float:reika_stored_damage[SH_MAXSLOTS+1] = { 0.0, ...}
new Float:reika_parry_mode_time
new Float:reika_explosion_cooldown
new Float:reika_explosion_radius
new Float:reika_explosion_force
new Float:reika_explosion_damage

new REIKA_PARRY_TURN_OFF_DELAY_TASKID

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
    register_cvar("reika_parry_mode_time","6.0")


    // FIRE THE EVENT TO CREATE THIS SUPERHERO!
    gHeroID=shCreateHero(gHeroName, "Kinetic Demon!", "Release large blasts on keybind! Parry melee strikes!", true, "reika_level" )

    register_event("ResetHUD","newRound","b")
    register_srvcmd("reika_init", "reika_init")
    shRegHeroInit(gHeroName, "reika_init")

    RegisterHam(Ham_TakeDamage,"player","reika_parry_damage_timer_trigger",_,true)

    register_srvcmd("reika_kd", "reika_kd")
    shRegKeyDown(gHeroName, "reika_kd")

    REIKA_PARRY_TURN_OFF_DELAY_TASKID=allocate_typed_task_id(player_task)

    init_explosion_defaults()

}
parry_user(id, Float:blocked_damage, tg){

    if(!is_user_connected(id)) return

    if(!sh_user_has_hero(id,gHeroID)) return
    
    Set_BitVar(reika_is_parrying_mask,id);
    reika_stored_damage[id]=blocked_damage
    reika_parried_tg[id]=tg

    sh_chat_message(id,gHeroID,
                        "You parried their melee strike and stored %0.1f damage! Melee 'em within %0.1f seconds for more damage!",
                        blocked_damage,
                        reika_parry_mode_time)
                
    set_task(reika_parry_mode_time,"parry_mode_turn_off_task",
                        id+REIKA_PARRY_TURN_OFF_DELAY_TASKID)

}
unparry_user(id){

    if(!is_user_connected(id)) return
    
    remove_task(id + REIKA_PARRY_TURN_OFF_DELAY_TASKID)
    
    UnSet_BitVar(reika_is_parrying_mask,id);
    
    reika_parried_tg[id]=0
    
    reika_stored_damage[id]=0.0;

}
public reika_parry_damage_timer_trigger(id, idinflictor, attacker, Float:damage, damagebits)
{


    if ( !sh_is_active() || !client_hittable(id)||!client_hittable(attacker)){

    return HAM_IGNORED
    }
    if(!sh_user_has_hero(id,gHeroID)&&!sh_user_has_hero(attacker,gHeroID)) return HAM_IGNORED

    if((sh_clients_are_same_team(id,attacker))||(attacker==id)) return HAM_IGNORED

    new result= HAM_IGNORED

    new weapon=get_user_weapon(attacker)
    if(sh_user_has_hero(id,gHeroID)){
        if(!Get_BitVar(reika_is_parrying_mask,id)){

            if(weapon==CSW_KNIFE){
                
                new Float:blocked_damage= (BLOCK_FRACTION*damage)
                SetHamParamFloat(4,damage-blocked_damage)
                parry_user(id,blocked_damage,attacker)
                
                result=HAM_HANDLED
            }
        }
    }

    if(sh_user_has_hero(attacker,gHeroID)){

        if(Get_BitVar(reika_is_parrying_mask,attacker)){
            if((weapon==CSW_KNIFE)&&(id==reika_parried_tg[attacker])){
                
                new Float:total_damage = damage+reika_stored_damage[attacker]

                SetHamParamFloat(4,total_damage)
                
                sh_chat_message(attacker,gHeroID,
                                "Counter strike! %d xtra dmg dealt on strike",
                                reika_stored_damage[attacker],
                                reika_parry_mode_time)

                unparry_user(attacker)

                result= HAM_HANDLED
            }
        }
    }
    return result
   
}
public parry_mode_turn_off_task(id){

    if(!sh_is_active()) return
    if(!sh_is_inround()) return

    id-=REIKA_PARRY_TURN_OFF_DELAY_TASKID

    if(!is_user_connected(id)) return

    sh_chat_message(id,gHeroID,"Your parry timer has fully run out!")
    
    unparry_user(id)

}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
    if(!client_hittable(id)||!sh_is_active()){
        
        return PLUGIN_CONTINUE
    }
    if ( sh_user_has_hero(id,gHeroID) ) {
        
        unparry_user(id)
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
    reika_explosion_cooldown=get_cvar_float("reika_explosion_cooldown")
    reika_explosion_radius=get_cvar_float("reika_explosion_radius")
    reika_explosion_force=get_cvar_float("reika_explosion_force")
    reika_explosion_damage=get_cvar_float("reika_explosion_damage")
    reika_parry_mode_time=get_cvar_float("reika_parry_mode_time")
}
//----------------------------------------------------------------------------------------------
public reika_init()
{
    // First Argument is an id
    new temp[6]
    read_argv(1,temp,5)
    new id=str_to_num(temp)

    unparry_user(id)

}
//----------------------------------------------------------------------------------------------
public reika_kd()
{
    new temp[6]

    read_argv(1,temp,5)
    new id=str_to_num(temp)

    if ( !client_hittable(id) ) return PLUGIN_HANDLED

    if(!sh_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED

    if(sh_get_cooldown_flag(id)){

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

    if(!sh_user_has_hero(victim,gHeroID)&&!sh_user_has_hero(attacker,gHeroID)) return DMG_FWD_PASS

    if((sh_clients_are_same_team(victim,attacker))||(attacker==victim)) return DMG_FWD_PASS

    new bool:is_melee=false;

    if(new_dmg_type!=SH_NEW_DMG_DARK_ARTS){

        if(is_valid_custom_dmg_source(custom_weapon_id)){
            is_melee = (bool:xmod_is_melee_wpn(custom_weapon_id))
        }
        else {
            is_melee = is_generic_dmg_source(custom_weapon_id)
        }
    }

    if(sh_user_has_hero(victim,gHeroID)){
        
        if(!Get_BitVar(reika_is_parrying_mask,victim)){

            if(is_melee){
                
                new blocked_damage= floatround((BLOCK_FRACTION*float(damage)))
                
                damage-=blocked_damage


                parry_user(victim,float(blocked_damage),attacker)

            }
        }
    }

    if(sh_user_has_hero(attacker,gHeroID)){

        if(Get_BitVar(reika_is_parrying_mask,attacker)){
            if(is_melee&&(victim==reika_parried_tg[attacker])){
                
                new total_damage = damage+floatround(reika_stored_damage[attacker])

                damage = total_damage
                
                sh_chat_message(attacker,gHeroID,
                                "Counter strike! %d xtra dmg dealt on strike",
                                floatround(reika_stored_damage[attacker]),
                                reika_parry_mode_time)

                unparry_user(attacker)
            }
        }
    }
    return DMG_FWD_PASS
}