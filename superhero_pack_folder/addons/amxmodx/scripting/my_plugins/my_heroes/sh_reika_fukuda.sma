#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_BASIC_MACROS
#define I_WANT_PDATA_ALIASES
#define I_WANT_ENTITY_VECTORS
#include <amxconst>
#include <csx>
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt13.inc"
#include "custom_grenades/custom_grenades.inc"

#define BLOCK_FRACTION 0.76

#define reika_parry_successful_sfx "shmod/reika/parry_sfx.wav"
#define reika_parry_knife_blocked_sfx "shmod/reika/sword_break.wav"
#define reika_parry_equip_sfx "shmod/reika/parry_on_sound.wav"

// GLOBAL VARIABLES

#define gHeroName "Reika Fukuda"

new mode_change_button_pressed_mask = 0
/*
    reika_mode_blast=0,
    reika_mode_parry
*/
new mode_mask = 0
new Float:reika_stored_damage[SH_MAXSLOTS+1] = { 0.0, ...}

//Floats
new pcvar_reika_counter_mode_time
new pcvar_reika_post_explosion_cooldown
new pcvar_reika_post_counter_cooldown
new pcvar_reika_explosion_radius
new pcvar_reika_explosion_force
new pcvar_reika_explosion_damage
new pcvar_reika_hp
new pcvar_reika_ap
new pcvar_reika_speed
new pcvar_reika_max_melee_dmg_mult
new pcvar_reika_battery_saturation_value

new REIKA_COUNTER_TURN_OFF_DELAY_TASKID

new const DEBUG = 0
//----------------------------------------------------------------------------------------------
public plugin_init()
{
    // Plugin Info
    register_plugin("SUPERHERO Reika Fukuda","1.0",AUTHOR)

    create_cvar("reika_level", "12" )
    pcvar_reika_post_explosion_cooldown = create_cvar("reika_post_explosion_cooldown","30.0")
    pcvar_reika_post_counter_cooldown = create_cvar("reika_post_counter_cooldown","10.0")
    pcvar_reika_explosion_radius = create_cvar("reika_explosion_radius","300.0")
    pcvar_reika_explosion_force = create_cvar("reika_explosion_force","250.0")
    pcvar_reika_explosion_damage = create_cvar("reika_explosion_damage","80.0")
    pcvar_reika_counter_mode_time = create_cvar("reika_counter_mode_time","20.0")
    pcvar_reika_battery_saturation_value = create_cvar("reika_battery_saturation_value","2000.0",_,_,true,500.0,true,5000.0)

    pcvar_reika_max_melee_dmg_mult = create_cvar("reika_max_melee_dmg_mult","2.0",_,_,true,1.5,true,10.0)

    pcvar_reika_hp = create_cvar("reika_hp","300.0")
    pcvar_reika_ap = create_cvar("reika_ap","400.0")
    pcvar_reika_speed = create_cvar("reika_speed","400.0")



    // FIRE THE EVENT TO CREATE THIS SUPERHERO!
    gHeroID=shCreateHero(gHeroName, "Kinetic Demon!", "Release blasts or parry melee and retaliate 3-fold! Switch between and trigger them with knife deployed", true, "reika_level" )
    
    sh_register_hero_with_demonic_prepackage(gHeroID,pcvar_reika_ap, pcvar_reika_hp, pcvar_reika_speed)

    sh_assign_hero_bit(gHeroID,SH_EXPLOSION_POWERS, true)


    RegisterHam(Ham_TakeDamage,"player","reika_parry_damage_timer_trigger",_,true)

    register_forward(FM_CmdStart, "reika_parry_switch_cmdstart_hook");

    REIKA_COUNTER_TURN_OFF_DELAY_TASKID=allocate_typed_task_id(player_task)


}
//----------------------------------------------------------------------------------------------
public reika_parry_switch_cmdstart_hook(id, uc_handle)
{   

    if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
    if ( !is_user_alive(id) || !sh_get_user_has_hero(id,gHeroID) ) return FMRES_IGNORED;

    if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)) return FMRES_IGNORED

    static button;
    button= get_uc(uc_handle, UC_Buttons);
    static prev_button; prev_button = entity_get_int(id, EV_INT_oldbuttons)
    if((button & IN_ALT1)&&!(prev_button & IN_ALT1)){

        if(!Get_BitVar(mode_change_button_pressed_mask,id)){

            new wpnid=get_user_weapon(id)
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
                                prev_mode_value?"Counter":"Blast",
                                new_mode_value?"Counter":"Blast")
            }
        }
    }
    else{

        UnSet_BitVar(mode_change_button_pressed_mask,id)
    }
    return FMRES_IGNORED;
}

prepare_counter(id){

    if(!is_user_connected(id)) return

    if(!sh_get_user_has_hero(id,gHeroID)) return

    if(!sh_get_id_bit(id, SH_REIKA_IS_STORING_ENERGY)){
        
        sh_chat_message(id,gHeroID,"Counter engaged! Absorbing melee damage for %0.2f secs!",cvar_val(float, pcvar_reika_counter_mode_time))
        emit_sound(id,CHAN_WEAPON,reika_parry_equip_sfx,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
        sh_assign_id_bit(id, SH_REIKA_IS_STORING_ENERGY,true)
        set_task(
            cvar_val(float, pcvar_reika_counter_mode_time),"counter_mode_turn_off_task",
                                id+REIKA_COUNTER_TURN_OFF_DELAY_TASKID)
    
    }
    
}

public client_disconnected(id){

    task_safeguard_macro_for_player_task(id,REIKA_COUNTER_TURN_OFF_DELAY_TASKID,SH_MAXSLOTS)
    uncounter_user(id)
    UnSet_BitVar(mode_change_button_pressed_mask, id);
	
}
public client_connect(id){


    task_safeguard_macro_for_player_task(id,REIKA_COUNTER_TURN_OFF_DELAY_TASKID,SH_MAXSLOTS)
    uncounter_user(id)
    UnSet_BitVar(mode_change_button_pressed_mask, id);
}
/*

    defaults to absorbing into normal damage
    absorb_normal_or_shero =true -> absorb normal
    absorb_normal_or_shero =false -> absorb shero

*/
Float:absorb_user(id, Float:the_damage, tg){

    if(!is_user_connected(id)) return -1.0

    if(!sh_get_user_has_hero(id,gHeroID)) return -1.0
    
    static Float:damage_to_absorb,
            Float:battery_left_to_fill_up;
    
    battery_left_to_fill_up = max_macro(0.0,cvar_val(float,pcvar_reika_battery_saturation_value)-reika_stored_damage[id])
    damage_to_absorb = clamp_macro(the_damage,0.0,battery_left_to_fill_up)

    if(floatround(damage_to_absorb)<=0){

        sh_chat_message(id,gHeroID,
                        "Your battery is saturated at %0.2f damage! No absorption happens!",
                        reika_stored_damage[id])
        return -1.0
    }
    reika_stored_damage[id]+=damage_to_absorb


    sh_chat_message(id,gHeroID,
                        "You absorbed their melee strike and stored %0.2f damage!",
                        damage_to_absorb)
    
    sh_chat_message(id,gHeroID,
                        "You now have %0.2f damage stored on your battery!",
                        reika_stored_damage[id])

    emit_sound(id,CHAN_WEAPON,reika_parry_successful_sfx,VOL_NORM,ATTN_NORM,0,PITCH_NORM)

    if(DEBUG){
        sh_chat_message(tg,gHeroID,
                            "Your melee attack got absorbed! %0.2f damage was blocked",
                            damage_to_absorb)
    }
    emit_sound(tg,CHAN_WEAPON,reika_parry_knife_blocked_sfx,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
    
    return damage_to_absorb

}
uncounter_user(id, bool:delete_battery = true){

    if(!is_user_connected(id)) return
    
    remove_task(id + REIKA_COUNTER_TURN_OFF_DELAY_TASKID)
    
    sh_assign_id_bit(id,SH_REIKA_IS_STORING_ENERGY,false);
    if(delete_battery){
        reika_stored_damage[id]=0.0
    }
}

public reika_parry_damage_timer_trigger(id, idinflictor, attacker, Float:damage, damagebits)
{
    if(damage <= 0.0){

        return HAM_IGNORED
    }


    if ( !sh_is_active() || !is_user_alive(id)||!is_user_alive(attacker)){

    return HAM_IGNORED
    }
    if(!sh_get_user_has_hero(id,gHeroID)&&!sh_get_user_has_hero(attacker,gHeroID)) return HAM_IGNORED

    if((sh_clients_are_same_team(id,attacker))||(attacker==id)) return HAM_IGNORED

    new result= HAM_IGNORED

    static weapon;
    
    weapon = get_user_weapon(attacker)
    
    if(sh_get_user_has_hero(id,gHeroID)){

        if(sh_get_id_bit(id, SH_REIKA_IS_STORING_ENERGY)){

            if(weapon==CSW_KNIFE){
                
                static Float:blocked_damage,
                        Float:actual_absorption = 0.0;
                
                actual_absorption = 0.0
                blocked_damage = (BLOCK_FRACTION*damage)
                
                actual_absorption = absorb_user(id, blocked_damage, attacker)
                if(floatround(actual_absorption)>0){

                    damage-=actual_absorption // keep this reduction in the code until the very end

                    SetHamParamFloat(4,damage)
                    
                    result=HAM_HANDLED
                }
            }
        }
    }


    if ( sh_get_user_has_hero(attacker,gHeroID) && (weapon==CSW_KNIFE) &&((floatround(reika_stored_damage[attacker])>0))) {
        
        static Float:damage_to_actually_do,
                Float:previous_battery = 0.0

        previous_battery = reika_stored_damage[attacker]
        damage_to_actually_do = clamp_macro((cvar_val(float, pcvar_reika_max_melee_dmg_mult)*damage)-damage,0.0,reika_stored_damage[attacker])

        if(floatround(damage_to_actually_do)>0){
        
            SetHamParamFloat(4,damage+damage_to_actually_do) // the very end is here. we shouldnt set ham params too early
            
            reika_stored_damage[attacker]-=damage_to_actually_do

            if(DEBUG){

                sh_chat_message(attacker,gHeroID,"The multiplied damage was: %0.2f",
                                (cvar_val(float, pcvar_reika_max_melee_dmg_mult)*damage))

                sh_chat_message(attacker,gHeroID,"The raw damage was: %0.2f",
                                (damage))

                sh_chat_message(attacker,gHeroID,"The extra damage delivered was: %0.2f",
                                (cvar_val(float, pcvar_reika_max_melee_dmg_mult)*damage)-damage)


                sh_chat_message(attacker,gHeroID,"Your current battery is: %0.2f",reika_stored_damage[attacker])

                sh_chat_message(attacker,gHeroID,"Your previous battery was: %0.2f",previous_battery)
            
            }

            result=HAM_HANDLED
        }
    }
    return result
   
}
public counter_mode_turn_off_task(id){

    if(!sh_is_active()) return

    id-=REIKA_COUNTER_TURN_OFF_DELAY_TASKID

    if(!is_user_connected(id)) return

    sh_chat_message(id,gHeroID,"Counter mode has ended!")
    

    uncounter_user(id,false)

}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
    if(!is_user_alive(id)||!sh_is_active()){
        
        return
    }
    if ( sh_get_user_has_hero(id,gHeroID) ) {
        
        give_custom_grenades(id,GREN_CONC,5)
        
        uncounter_user(id)
        UnSet_BitVar(mode_change_button_pressed_mask, id);

    }
	
}

//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
    if(heroID!=gHeroID) return

    uncounter_user(id)
    UnSet_BitVar(mode_change_button_pressed_mask, id);

}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		reika_kd(id)
	}
}
}
//----------------------------------------------------------------------------------------------
public reika_kd(id)
{
    if(!sh_is_active()||!sh_is_inround()||sh_is_freezetime()) return

    if ( !is_user_alive(id) ) return

    if(!sh_get_user_has_hero(id,gHeroID) ) return

    if(sh_get_cooldown_flag(id)){

        sh_sound_deny(id)
        return
    }
    new bool:curr_mode = bool:Get_BitVar(mode_mask, id)
    static pcvar_to_use;
    pcvar_to_use = pcvar_reika_post_explosion_cooldown

    if(!curr_mode){
        
        static Float:damage_to_actually_do
        damage_to_actually_do = clamp_macro((cvar_val(float, pcvar_reika_explosion_damage)),0.0,reika_stored_damage[id])

        if(floatround(damage_to_actually_do)>0){
            explosion(gHeroID,id,
                            cvar_val(float, pcvar_reika_explosion_radius),
                            damage_to_actually_do,
                            cvar_val(float, pcvar_reika_explosion_force)
                            ,1,1)
            
        }
        else{
            
            sh_chat_message(id,gHeroID,"There is no damage in the battery! You can't explode")
            sh_sound_deny(id)
            return
        }
        
        pcvar_to_use = pcvar_reika_post_explosion_cooldown
    
    }
    else if(!sh_get_id_bit(id, SH_REIKA_IS_STORING_ENERGY)){
        if(floatround(cvar_val(float, pcvar_reika_battery_saturation_value))<=floatround(reika_stored_damage[id])){

            sh_chat_message(id,gHeroID,"You cannot counter while your battery is saturated! Go unload it first!")
            sh_sound_deny(id)
            return


        }
        prepare_counter(id)
        pcvar_to_use = pcvar_reika_post_counter_cooldown
        
    }
    else{
            
        sh_chat_message(id,gHeroID,"Counter mode is already active! Wait until it ends")
        sh_sound_deny(id)
        return


    }
    sh_set_cooldown(id,cvar_val(float, pcvar_to_use))

}
public plugin_precache(){

    engfunc(EngFunc_PrecacheSound, reika_parry_successful_sfx)
    engfunc(EngFunc_PrecacheSound, reika_parry_knife_blocked_sfx)
    engfunc(EngFunc_PrecacheSound, reika_parry_equip_sfx)

}
public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage,  &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,const sh_thrash_brat_dmg_type:new_dmg_type,const custom_weapon_id){
	
    if(damage <= 0){
            
        return DMG_FWD_PASS
    }


    if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){

        return DMG_FWD_PASS
    }
    if(new_dmg_type==SH_NEW_DMG_IVE_STUDIED_THE_BLADE){
        if(sh_get_user_has_hero(victim,gHeroID) ){
            return DMG_FWD_BLOCK
        }
    }

    if(!sh_get_user_has_hero(victim,gHeroID)&&!sh_get_user_has_hero(attacker,gHeroID)) return DMG_FWD_PASS

    if((sh_clients_are_same_team(victim,attacker))||(attacker==victim)) return DMG_FWD_PASS

    new bool:is_melee=false;

    if(new_dmg_type!=SH_NEW_DMG_DARK_ARTS){

        if(is_valid_custom_dmg_source(custom_weapon_id)){
            is_melee = (bool:xmod_is_melee_wpn(custom_weapon_id))
        }
    }

    new dmg_fwd_ret_id:return_result = DMG_FWD_PASS

    if(sh_get_user_has_hero(victim,gHeroID)){
        
        if(sh_get_id_bit(victim, SH_REIKA_IS_STORING_ENERGY)){

            if(is_melee){
                
                static Float:absorb_result = 0.0;
                static blocked_damage;
                blocked_damage = floatround((BLOCK_FRACTION*float(damage)))
                absorb_result = absorb_user(victim, float(blocked_damage), attacker)

                if(floatround(absorb_result)>0){

                    damage-=floatround(absorb_result)

                    return_result = DMG_FWD_HANDLED
                }
            }
        }
    }
    if(sh_get_user_has_hero(attacker,gHeroID)){


        if(is_melee &&((floatround(reika_stored_damage[attacker])>0))){
            
            static Float:damage_to_actually_do,
                Float:previous_battery = 0.0

            previous_battery = reika_stored_damage[attacker]
            
            damage_to_actually_do = clamp_macro((cvar_val(float, pcvar_reika_max_melee_dmg_mult)*float(damage))-float(damage),0.0,reika_stored_damage[attacker])
            
            if(floatround(damage_to_actually_do)>0){

                damage+=floatround(damage_to_actually_do)

                reika_stored_damage[attacker]-=damage_to_actually_do
                if(DEBUG){
                    sh_chat_message(attacker,gHeroID,"The multiplied damage was: %0.2f",
                                    (cvar_val(float, pcvar_reika_max_melee_dmg_mult)*damage))

                    sh_chat_message(attacker,gHeroID,"The raw damage was: %0.2f",
                                    float(damage))

                    sh_chat_message(attacker,gHeroID,"The extra damage delivered was: %0.2f",
                                    (cvar_val(float, pcvar_reika_max_melee_dmg_mult)*damage)-damage)


                    sh_chat_message(attacker,gHeroID,"Your current battery is: %0.2f",reika_stored_damage[attacker])

                    sh_chat_message(attacker,gHeroID,"Your previous battery was: %0.2f",previous_battery)
                }

                return_result = DMG_FWD_HANDLED
            }
            
        }
    }
    return return_result
}