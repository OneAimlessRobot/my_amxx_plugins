#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "custom_grenades/custom_grenades.inc"

#define BLOCK_FRACTION 0.76

#define reika_parry_successful_sfx "shmod/reika/parry_sfx.wav"
#define reika_parry_knife_blocked_sfx "shmod/reika/sword_break.wav"
#define reika_parry_equip_sfx "shmod/reika/parry_on_sound.wav"

// GLOBAL VARIABLES
new gHeroID
new gHeroName[]="Reika Fukuda"
new reika_is_parrying_mask = 0
new mode_change_button_pressed_mask = 0
/*
    reika_mode_blast=0,
    reika_mode_parry
*/
new mode_mask = 0
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
    gHeroID=shCreateHero(gHeroName, "Kinetic Demon!", "Release blasts or parry melee and retaliate 3-fold! Switch between and trigger them with knife deployed", true, "reika_level" )

    register_srvcmd("reika_init", "reika_init")
    shRegHeroInit(gHeroName, "reika_init")

    RegisterHam(Ham_TakeDamage,"player","reika_parry_damage_timer_trigger",_,true)

    register_srvcmd("reika_kd", "reika_kd")
    shRegKeyDown(gHeroName, "reika_kd")

    register_forward(FM_CmdStart, "reika_parry_switch_cmdstart_hook");

    REIKA_PARRY_TURN_OFF_DELAY_TASKID=allocate_typed_task_id(player_task)

    init_explosion_defaults()

}
//----------------------------------------------------------------------------------------------
public reika_parry_switch_cmdstart_hook(id, uc_handle)
{
    if ( !is_user_alive(id)||!is_user_alive(id)||!sh_user_has_hero(id,gHeroID) ) return FMRES_IGNORED;

    static button;
    button= get_uc(uc_handle, UC_Buttons);
    new wpnid=get_user_weapon(id)
    if(button & IN_ALT1){

        button &= ~IN_ALT1
        set_uc(uc_handle, UC_Buttons, button)
        if(!Get_BitVar(mode_change_button_pressed_mask,id)){
            if(wpnid==CSW_KNIFE){
                Set_BitVar(mode_change_button_pressed_mask,id)
                static bool:prev_mode_value,
                            bool:new_mode_value
                
                prev_mode_value= bool:Get_BitVar(mode_mask,id)
                if(prev_mode_value){
                    
                    UnSet_BitVar(mode_mask,id)

                }
                else{

                    Set_BitVar(mode_mask,id)

                }
                new_mode_value= bool:Get_BitVar(mode_mask,id)
                sh_chat_message(id,gHeroID,"Mode changed from %s to %s!",
                                prev_mode_value?"Parry":"Blast",
                                new_mode_value?"Parry":"Blast")
            }
        }
    }
    else{

        UnSet_BitVar(mode_change_button_pressed_mask,id)
    }
    return FMRES_IGNORED;
}

prepare_parry(id){

    if(!is_user_connected(id)) return

    if(!sh_user_has_hero(id,gHeroID)) return

    if(!Get_BitVar(reika_is_parrying_mask,id)){
        
        sh_chat_message(id,gHeroID,"Preparing to parry!")
        emit_sound(id,CHAN_WEAPON,reika_parry_equip_sfx,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
        Set_BitVar(reika_is_parrying_mask,id);
        set_task(reika_parry_mode_time,"parry_mode_turn_off_task",
                                id+REIKA_PARRY_TURN_OFF_DELAY_TASKID)
    
    }
    
}
absorb_user(id, Float:the_damage, tg){

    if(!is_user_connected(id)) return

    if(!sh_user_has_hero(id,gHeroID)) return
    
    reika_stored_damage[id]=the_damage
    reika_parried_tg[id]=tg

    sh_chat_message(id,gHeroID,
                        "You parried their melee strike and stored %0.1f damage!",
                        the_damage)
    emit_sound(id,CHAN_WEAPON,reika_parry_successful_sfx,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
    sh_chat_message(tg,gHeroID,
                        "Your melee attack got parried! %0.1f damage was blocked",
                        the_damage)
    emit_sound(tg,CHAN_WEAPON,reika_parry_knife_blocked_sfx,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
                

}
unparry_user(id){

    if(!is_user_connected(id)) return
    
    remove_task(id + REIKA_PARRY_TURN_OFF_DELAY_TASKID)
    
    UnSet_BitVar(reika_is_parrying_mask,id);
    

}
clear_retaliate(id){

    reika_stored_damage[id]=0.0
    reika_parried_tg[id]=0

}
public reika_parry_damage_timer_trigger(id, idinflictor, attacker, Float:damage, damagebits)
{


    if ( !sh_is_active() || !is_user_alive(id)||!is_user_alive(attacker)){

    return HAM_IGNORED
    }
    if(!sh_user_has_hero(id,gHeroID)&&!sh_user_has_hero(attacker,gHeroID)) return HAM_IGNORED

    if((sh_clients_are_same_team(id,attacker))||(attacker==id)) return HAM_IGNORED

    new result= HAM_IGNORED

    new weapon=get_user_weapon(attacker)
    if(sh_user_has_hero(id,gHeroID)){
        if(Get_BitVar(reika_is_parrying_mask,id)){

            if(weapon==CSW_KNIFE){
                
                new Float:blocked_damage= (BLOCK_FRACTION*damage)
                SetHamParamFloat(4,damage-blocked_damage)
                
                absorb_user(id, blocked_damage, attacker)

                unparry_user(id)
                
                result=HAM_HANDLED
            }
        }
    }

    if(sh_user_has_hero(attacker,gHeroID)){

    
        if((weapon==CSW_KNIFE)&&(id==reika_parried_tg[attacker])){
            
            new Float:total_damage = damage+3.0*reika_stored_damage[attacker]

            SetHamParamFloat(4,total_damage)
            
            sh_chat_message(attacker,gHeroID,
                            "Counter strike! %0.1f xtra dmg dealt on strike",
                            reika_stored_damage[attacker],
                            reika_parry_mode_time)

            clear_retaliate(attacker)

            result= HAM_HANDLED
        }
    }
    return result
   
}
public parry_mode_turn_off_task(id){

    if(!sh_is_active()) return

    id-=REIKA_PARRY_TURN_OFF_DELAY_TASKID

    if(!is_user_connected(id)) return

    sh_chat_message(id,gHeroID,"You missed your parry!")
    
    unparry_user(id)

}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
    if(!is_user_alive(id)||!sh_is_active()){
        
        return
    }
    if ( sh_user_has_hero(id,gHeroID) ) {
        
        give_custom_grenades(id,GREN_CO2,5)
        unparry_user(id)
        sh_unset_cooldown_flag(id)
        sh_end_cooldown(id+SH_COOLDOWN_TASKID)

    }
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
    if(!sh_is_active()||!sh_is_inround()) return PLUGIN_CONTINUE
    
    new temp[6]

    read_argv(1,temp,5)
    new id=str_to_num(temp)

    if ( !is_user_alive(id) ) return PLUGIN_HANDLED

    if(!sh_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED

    if(sh_get_cooldown_flag(id)){

        sh_sound_deny(id)
        return PLUGIN_HANDLED
    }
    new bool:curr_mode = bool:Get_BitVar(mode_mask, id)
    if(!curr_mode){

        explosion(gHeroID,id,reika_explosion_radius,
                            reika_explosion_damage,
                            reika_explosion_force,1,1,_,sfx_show_shockwave)
    
    }
    else{

        prepare_parry(id)
        
    }

    sh_set_cooldown(id,reika_explosion_cooldown)
    return PLUGIN_HANDLED
}
public plugin_precache(){

    engfunc(EngFunc_PrecacheSound, reika_parry_successful_sfx)
    engfunc(EngFunc_PrecacheSound, reika_parry_knife_blocked_sfx)
    engfunc(EngFunc_PrecacheSound, reika_parry_equip_sfx)

}
public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &headshot,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	
    if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){

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
    }

    if(sh_user_has_hero(victim,gHeroID)){
        
        if(Get_BitVar(reika_is_parrying_mask,victim)){

            if(is_melee){
                
                new blocked_damage= floatround((BLOCK_FRACTION*float(damage)))
                
                damage-=blocked_damage

                absorb_user(victim, float(blocked_damage), attacker)

                unparry_user(victim)
                
            }
        }
    }

    if(sh_user_has_hero(attacker,gHeroID)){

        if(is_melee&&(victim==reika_parried_tg[attacker])){
            
            new total_damage = damage+3*floatround(reika_stored_damage[attacker])

            damage = total_damage
            
            sh_chat_message(attacker,gHeroID,
                            "Counter strike! %d xtra dmg dealt on strike",
                            floatround(reika_stored_damage[attacker]),
                            reika_parry_mode_time)

            clear_retaliate(attacker)
        }
    }
    return DMG_FWD_PASS
}