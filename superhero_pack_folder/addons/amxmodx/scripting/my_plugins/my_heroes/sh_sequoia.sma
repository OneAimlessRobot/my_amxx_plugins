
#define I_WANT_MISC_FUNCS
#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MATH_FUNCS

#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_BASIC_MACROS
#define I_WANT_PDATA_ALIASES
#define I_WANT_MATH_VECTORS
#include <float>
#include <xs>
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "shock_fx_inc/shock_fx.inc"
#include "wet_fx_inc/wet_fx.inc"
#include "sequoia_inc/sequoia.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt9.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt13.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"

#include "../my_include/my_author_header.inc"

#define PLUGIN_NAME "Superhero Sequoia"
#define PLUGIN_VERSION "0.99prerelease"

#define SEQUOIA_START_ANGLE ((45.0))
#define SEQUOIA_BEAM_THINK_PERIOD 0.1
#define SEQUOIA_ACTIVE_TASK_TIME_PERIOD 0.1
#define SEQUOIA_PASSIVE_TASK_TIME_PERIOD 1.0
#define SEQUOIA_SWEEP_TIME 5.0

#define SEQUOIA_ANGLE_LINEAR_INC ((SEQUOIA_START_ANGLE/SEQUOIA_SWEEP_TIME)*SEQUOIA_BEAM_THINK_PERIOD)

#define SEQUOIA_BEAM_TERMINAL_ENT_CLASS "sequoia_terminal"

#define HYDROCVTTR_CHARGING_SOUND "shmod/flora/fields/field_charging.wav"

new HYDROCVTTR_wpn_id
new dmg_source_name_short_HYDROCVTTR[SAFE_BUFFER_SIZE+1]="HYDROCVTTR"
new dmg_source_name_log_HYDROCVTTR[SAFE_BUFFER_SIZE+1]="HYDROCVTTR"

new ANNIHILATION_wpn_id
new dmg_source_name_short_ANNIHILATION[SAFE_BUFFER_SIZE+1]="ANNIHILATION"
new dmg_source_name_log_ANNIHILATION[SAFE_BUFFER_SIZE+1]="ANNIHILATION"


#define SEQUOIA_HEALTHCAP 30.0
#define SEQUOIA_HEALTHCAP_INT_VERSION 30

stock const gHeroName[] = "Sequoia"

new user_is_keydown_mask = 0,
    user_is_inattack = 0,
    user_attack_ready = 0,
    user_floating_mode_on = 0

enum attack_phase{

    none,
    select,
    aim,
    COAGULATION,
    ANNIHILATION

}

new const attack_phase_names[attack_phase][128]={
    "N/A",
    "Select",
    "AIM",
    "COAGULATION",
    "ANNIHILATION"

}
new Float:g_sequoia_look_direction[SH_MAXSLOTS+1][3],
        g_sequoia_current_aimed_at_player[SH_MAXSLOTS+1]

new attack_phase:g_sequoia_attack_phase[SH_MAXSLOTS+1]
new Float:g_sequoia_damage_battery[SH_MAXSLOTS+1]
new Float:g_sequoia_damage_stamina[SH_MAXSLOTS+1]
new Float:g_sequoia_last_gravity[SH_MAXSLOTS+1]
new Float:g_sequoia_display_cooldown[SH_MAXSLOTS+1]
new Float:g_sequoia_last_max_speed[SH_MAXSLOTS+1]
new Float:g_sequoia_charging_origin[SH_MAXSLOTS+1][3]



//floats
new pcvar_sequoia_gravity,
    pcvar_sequoia_base_cooldown,
    pcvar_min_alpha,
    pcvar_max_alpha,
    pcvar_min_damage_battery,
    pcvar_max_damage_battery,
    pcvar_sweep_min_damage,
    pcvar_sweep_max_damage,
    pcvar_max_stamina,
    pcvar_stamina_persec_min,
    pcvar_stamina_persec_max,
    pcvar_min_charge_rate,
    pcvar_max_charge_rate,
    pcvar_sweep_min_radius,
    pcvar_sweep_max_radius,
    pcvar_sequoia_endeavour_hp

    

new Sequoia_hudsync

new SABLINA_PASSIVE_TASKID = -1,
    SABLINA_ACTIVE_TASKID = -1

public plugin_init(){

    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, AUTHOR)

    create_cvar("sequoia_level", "14")

    pcvar_sequoia_gravity = create_cvar("sequoia_gravity", "0.25")

    pcvar_sequoia_endeavour_hp = create_cvar("sequoia_sequoia_endeavour_hp", "0.25")

    pcvar_sequoia_base_cooldown = create_cvar("sequoia_base_cooldown", "10.0")

    pcvar_min_alpha = create_cvar("sequoia_min_alpha", "10.0")

    pcvar_max_alpha = create_cvar("sequoia_max_alpha", "200.0")

    pcvar_min_damage_battery = create_cvar("sequoia_min_damage_battery", "500.0")

    pcvar_max_damage_battery = create_cvar("sequoia_max_damage_battery", "2000.0")

    pcvar_min_charge_rate = create_cvar("sequoia_min_charge_rate", "500.0")

    pcvar_max_charge_rate = create_cvar("sequoia_max_charge_rate", "2000.0")

    pcvar_max_stamina = create_cvar("sequoia_max_stamina", "2000.0")

    pcvar_stamina_persec_min = create_cvar("sequoia_stamina_persec_min", "600.0")

    pcvar_stamina_persec_max = create_cvar("sequoia_stamina_persec_max", "1200.0")

    pcvar_sweep_min_damage = create_cvar("sequoia_sweep_min_damage", "50.0")

    pcvar_sweep_max_damage = create_cvar("sequoia_sweep_max_damage", "250.0")

    pcvar_sweep_min_radius = create_cvar("sequoia_sweep_mix_radius", "250.0")

    pcvar_sweep_max_radius = create_cvar("sequoia_sweep_max_radius", "700.0")

    gHeroID=shCreateHero(gHeroName, "Water probe!", "Summon HYDROCVTTR! A devastating water attack. Become ethereal as well...", true, "sequoia_level" )

    sh_register_admin_only_hero(gHeroID,ADMIN_IMMUNITY,1,
                    "Do you know what happens to very experimental, hard to explain or just overall unfinished heroes? Take a guess")

    sh_register_elemental_probe_hero(gHeroID, SEQUOIA_HEALTHCAP, pcvar_sequoia_gravity)


    RegisterHam(Ham_TakeDamage,"player","sequoia_no_instant_kill",_, true)


    sh_register_superheromod_model(gHeroID,
                                "models/player/sablina/sablina.mdl",
                                "models/player/sablina/sablina.mdl",
                                "sablina",
                                "Between heaven and hell is the sea of doubt",
                                "The waters have parted. My fate has been sealed")

                                

    register_think(SEQUOIA_BEAM_TERMINAL_ENT_CLASS,"sequoia_beam_terminal_think")


    register_forward(FM_CmdStart,"fw_Sequoia_aim_button")

    init_progress_bar_msg_var()

    HYDROCVTTR_wpn_id=sh_log_custom_damage_source(
                                gHeroID,
                                dmg_source_name_short_HYDROCVTTR,
                                dmg_source_name_log_HYDROCVTTR,
                                0)

    ANNIHILATION_wpn_id=sh_log_custom_damage_source(
                                gHeroID,
                                dmg_source_name_short_ANNIHILATION,
                                dmg_source_name_log_ANNIHILATION,
                                0)


    SABLINA_PASSIVE_TASKID = allocate_typed_task_id(generic_task)

    SABLINA_ACTIVE_TASKID = allocate_typed_task_id(generic_task)

    set_task( SEQUOIA_PASSIVE_TASK_TIME_PERIOD, "sequoia_passive_loop", SABLINA_PASSIVE_TASKID, _, _, "b")
    set_task( SEQUOIA_ACTIVE_TASK_TIME_PERIOD, "sequoia_active_loop", SABLINA_ACTIVE_TASKID, _, _, "b")




    init_gravity_pcvar()

    Sequoia_hudsync = CreateHudSyncObj()
}
bool:sequoia_user_target_is_valid(id,the_player_to_evaluate){


    if(is_user_alive(the_player_to_evaluate)){
        
        if(!sh_clients_are_same_team(the_player_to_evaluate,id)&&can_see_fm(id, the_player_to_evaluate)){

            return true
        }

    }
    return false
}
Float:get_ratio(Float:the_current, Float:the_max){

	return clamp_macro(( the_current/ the_max),0.1,0.99)

}
Float:get_user_charge_inc(owner){
    

      return  cvar_val(float, pcvar_min_charge_rate)
                                        
                                        +

                ((cvar_val(float, pcvar_max_charge_rate) - cvar_val(float, pcvar_min_charge_rate))
                    
                                    *
                    (1.0 - ( get_ratio(g_sequoia_damage_stamina[owner] ,cvar_val(float, pcvar_max_stamina)))))


}
Float:get_user_stamina_inc(owner){
    
    static Float:nontimed_charge_rate; nontimed_charge_rate = cvar_val(float, pcvar_stamina_persec_min)
                                        
                                        +

                ((cvar_val(float, pcvar_stamina_persec_max) - cvar_val(float, pcvar_stamina_persec_min))
                    
                                    *
                    (1.0 - ( get_ratio(g_sequoia_damage_stamina[owner] ,cvar_val(float, pcvar_max_stamina)))))
                    

    return nontimed_charge_rate*SEQUOIA_ACTIVE_TASK_TIME_PERIOD


}
Float:get_user_charge_dec(owner){
    

      return  cvar_val(float, pcvar_min_charge_rate)
                                        
                                        +

                ((cvar_val(float, pcvar_max_charge_rate) - cvar_val(float, pcvar_min_charge_rate))
                    
                                    *
                    get_ratio(g_sequoia_damage_stamina[owner] ,cvar_val(float, pcvar_max_stamina)))


}
Float:get_user_stamina_dec(owner){
    

    static Float:nontimed_charge_rate; nontimed_charge_rate = cvar_val(float, pcvar_stamina_persec_min)
                                        
                                        +

                ((cvar_val(float, pcvar_stamina_persec_max) - cvar_val(float, pcvar_stamina_persec_min))
                    
                                    *
                    get_ratio(g_sequoia_damage_stamina[owner] ,cvar_val(float, pcvar_max_stamina)))
                    
    return nontimed_charge_rate*SEQUOIA_ACTIVE_TASK_TIME_PERIOD


}
Float:get_user_sweep_damage(owner){
    

      return cvar_val(float, pcvar_sweep_min_damage)
                                        
                                        +

                ((cvar_val(float, pcvar_sweep_max_damage) - cvar_val(float, pcvar_sweep_min_damage))
                    
                                    *
                    get_ratio(g_sequoia_damage_battery[owner] ,cvar_val(float, pcvar_max_damage_battery)))


}


Float:get_user_sweep_radius(owner){
    

      return  cvar_val(float, pcvar_sweep_min_radius)
                                        
                                        +

                ((cvar_val(float, pcvar_sweep_max_radius) - cvar_val(float, pcvar_sweep_min_radius))
                    
                                    *
                   (1.0- get_ratio(g_sequoia_damage_battery[owner] ,cvar_val(float, pcvar_max_damage_battery))))


}
regulate_user_float(id , bool:remove_please = false){
    if(Get_BitVar(user_floating_mode_on,id)&&!remove_please){

        entity_set_vector( id, EV_VEC_velocity, NULL_VECTOR )

        entity_set_origin(id,g_sequoia_charging_origin[id])

        set_user_gravity(id,0.01)

        set_user_maxspeed_controlled(id, 0.0,true, false)
    }
    else if(is_user_alive(id)){

        sh_reset_min_gravity(id)
        sh_reset_max_speed(id)
    
    }
}
//----------------------------------------------------------------------------------------------
public sequoia_active_loop(taskid)
{	
    if ( !sh_is_active() || sh_is_freezetime() || !sh_is_inround() ) return

    new the_players[SH_MAXSLOTS], pnum, id		
    get_players(the_players, pnum, "a")
    for (new i = 0; i < pnum; i++) {
        
        id = the_players[i]

        if ( !sh_get_user_has_hero(id,gHeroID)){
            
            continue

        }


        static Float:max_charge; max_charge=  cvar_val(float, pcvar_max_damage_battery)


        static Float:stamina_inc_to_use; stamina_inc_to_use= min_macro(get_user_stamina_inc(id),cvar_val(float, pcvar_max_stamina)-g_sequoia_damage_stamina[id])

        regulate_user_float(id)

        if((g_sequoia_attack_phase[id]<COAGULATION)){
                
            if(floatround(stamina_inc_to_use)>0){

                g_sequoia_damage_stamina[id] += stamina_inc_to_use
            
            }
            else{
                
            
                Assign_BitVar(user_attack_ready,id, true_for_macro)
            
            }

            if(g_sequoia_attack_phase[id]<=none){
                continue
            }
            
            if(!sequoia_user_target_is_valid(id,g_sequoia_current_aimed_at_player[id])){
                
                g_sequoia_attack_phase[id] = none
                continue
            
            }
            point_player_towards_other_player(id,g_sequoia_current_aimed_at_player[id])
        }
        entity_set_vector( id, EV_VEC_angles, g_sequoia_look_direction[id] )
        entity_set_vector( id, EV_VEC_v_angle, g_sequoia_look_direction[id] )
        entity_set_int( id, EV_INT_fixangle, 1 )


        if(g_sequoia_attack_phase[id]<=select){

            continue
        }

        
        if((g_sequoia_attack_phase[id]!=COAGULATION)){
            if(g_sequoia_attack_phase[id]==ANNIHILATION){
                
                if(!Get_BitVar(user_is_inattack,id)){
                    Assign_BitVar(user_is_inattack,id,true_for_macro)
                    if(!sh_get_cooldown_flag(id)){
                        set_sequoia_user_cooldown(id)
                        sequoia_summon_beam(id)
                    }
                }
            }
            continue
        }

        if((g_sequoia_damage_battery[id]< max_charge)&&(g_sequoia_damage_stamina[id]>0.0)){


            static Float:inc_to_use; inc_to_use=  min_macro(get_user_charge_inc(id), cvar_val(float,pcvar_max_damage_battery)-g_sequoia_damage_battery[id])*SEQUOIA_ACTIVE_TASK_TIME_PERIOD
            
            
            g_sequoia_damage_battery[id] += inc_to_use
            g_sequoia_damage_stamina[id] -= min_macro(g_sequoia_damage_stamina[id],get_user_stamina_dec(id))
            

            //g_sequoia_damage_battery[id] += 60.0
            
            client_print(id,print_center,"[SH] %s: %s charge: %0.2f",gHeroName,dmg_source_name_short_HYDROCVTTR,(g_sequoia_damage_battery[id]/max_charge)*100.0)
            
        }






    }
}
//----------------------------------------------------------------------------------------------
public sequoia_passive_loop(taskid)
{	
	if ( !sh_is_active() || sh_is_freezetime() ) return

	new the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new i = 0; i < pnum; i++) {
		
        id = the_players[i]


        new Float:the_alpha_floated  = 0.0,
            the_actual_alpha = 0

        if ( !sh_get_user_has_hero(id,gHeroID)){
            
            continue

        }


        static Float:max_stamina; max_stamina=  cvar_val(float, pcvar_max_stamina)

        the_alpha_floated = 
                        
                        cvar_val(float, pcvar_min_alpha)
                                        
                                        +

                ((cvar_val(float, pcvar_max_alpha) - cvar_val(float, pcvar_min_alpha))
                    
                                    *
                    get_ratio(g_sequoia_damage_stamina[id] ,max_stamina))





        the_actual_alpha = floatround( the_alpha_floated, floatround_round)

        set_render_with_color_const(id,CHUCKY_BLUE,1,the_actual_alpha,
                            20,
                            _,_,
                            SEQUOIA_PASSIVE_TASK_TIME_PERIOD,0,_,_,PRIO_RENDER_INVISIBILITY,gHeroID)

        
        if(!is_user_bot(id)){
            static print_buff[512]
            
            if(g_sequoia_display_cooldown[id] > 0.0){
                g_sequoia_display_cooldown[id] -= min_macro(SEQUOIA_PASSIVE_TASK_TIME_PERIOD,g_sequoia_display_cooldown[id])
            }


            formatex(print_buff,charsmax(print_buff),"[SH] %s info hud:^nAttack phase: %s^nCurrent cooldown: %0.2f^nCurrent charge: %0.2f^nCurrent stamina: %0.2f^nAttack ready? %s^nIn attack? %s^nFloating mode: %s^n",
                                            gHeroName,
                                            attack_phase_names[g_sequoia_attack_phase[id]],
                                            g_sequoia_display_cooldown[id],
                                            g_sequoia_damage_battery[id],
                                            g_sequoia_damage_stamina[id],
                                            Get_BitVar(user_attack_ready,id)?"Yes!":"No...",
                                            Get_BitVar(user_is_inattack,id)?"Yes!":"No...",
                                            Get_BitVar(user_floating_mode_on, id)?"Yes!":"No...")



            set_hudmessage(LineColors[CHUCKY_BLUE][0],LineColors[CHUCKY_BLUE][1],LineColors[CHUCKY_BLUE][2],0.0,0.35,0,0.0,SEQUOIA_PASSIVE_TASK_TIME_PERIOD,0.0,0.0,-1,255)

            ShowSyncHudMsg(id,Sequoia_hudsync, "%s", print_buff)

        }





    }
}
public plugin_natives(){

    register_native("sequoia_get_hero_id","_sequoia_get_hero_id")

}


public _sequoia_get_hero_id(iPlugins, iParams){


    return gHeroID

}
public fw_Sequoia_aim_button(id, uc_handle)
{
    if(!sh_is_active()||sh_is_freezetime()){
        return FMRES_IGNORED
    }
    if (!is_user_alive(id)){
        return FMRES_IGNORED
    }

    if(!sh_get_user_has_hero(id,gHeroID)){

        return FMRES_IGNORED
    }

    static button; button = get_uc(uc_handle, UC_Buttons);
    static bool:remove_buttons_from_mask = false

    if(!Get_BitVar(user_is_keydown_mask,id)){

        return FMRES_IGNORED


    }

    static alive = 0, dead = 0;
    
    sh_get_player_counts(id,2, alive, dead)

    if(alive <=0){

        return FMRES_IGNORED

    }

    static prev_button; prev_button = entity_get_int(id, EV_INT_oldbuttons)

    if((button & IN_ATTACK) && (!(prev_button & IN_ATTACK)) && (g_sequoia_attack_phase[id]==select))
    {
        do_player_iteration(id)
        remove_buttons_from_mask = true
        
    }
    if((button & IN_ATTACK2) && (!(prev_button & IN_ATTACK2)))
    {

        switch(g_sequoia_attack_phase[id]){
            case(select):{
                if(sequoia_user_target_is_valid(id,g_sequoia_current_aimed_at_player[id])){
                    g_sequoia_attack_phase[id]=aim
                }
            }
            case(aim):{
                
                emit_sound(id, CHAN_ITEM, HYDROCVTTR_CHARGING_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)


                g_sequoia_attack_phase[id]=COAGULATION


            }
            default:{
                
                if(g_sequoia_damage_battery[id] >= cvar_val(float, pcvar_min_damage_battery)){
                
                
                    g_sequoia_attack_phase[id]=ANNIHILATION
                
                }

            }
        }

        remove_buttons_from_mask = true
        
    }
    if(remove_buttons_from_mask){

        return FMRES_SUPERCEDE
    }
    return FMRES_IGNORED
}
player_iterator_next(owner_id,curr_iter_player=-1){
	
    curr_iter_player = find_ent_by_class(curr_iter_player, "player")
    while(curr_iter_player) {

        if(is_valid_ent(curr_iter_player)){

            if(sequoia_user_target_is_valid(owner_id,curr_iter_player)){

                return curr_iter_player

            }
        }
        curr_iter_player = find_ent_by_class(curr_iter_player, "player")
    }
    return -1;
	
}

bool:do_player_iteration(id){


    do{
            

        g_sequoia_current_aimed_at_player[id] = player_iterator_next(id,g_sequoia_current_aimed_at_player[id])
    

    }
    while((g_sequoia_current_aimed_at_player[id]==id));
    
    return is_user_alive(g_sequoia_current_aimed_at_player[id])?true:false;
}
point_player_towards_other_player(handled_player, target_player){
    static Float:the_raw_carthesian_vector_to_store[3]

    //the output of this is a carthesian vector!
    get_entity_direction_vector_raw(handled_player,target_player, the_raw_carthesian_vector_to_store)

    //Normalize it!
    vector_norm(the_raw_carthesian_vector_to_store,the_raw_carthesian_vector_to_store)

    vector_to_angle(the_raw_carthesian_vector_to_store,g_sequoia_look_direction[handled_player])


    g_sequoia_look_direction[handled_player][0] = -g_sequoia_look_direction[handled_player][0]


}
sequoia_haramball_shield_react_primitive(id,attacker, Float:damage){

            
    set_user_health(id,floatround(cvar_val(float, pcvar_sequoia_endeavour_hp)))

    sh_chat_message(id,gHeroID,"We blocked an instant kill! The damage received would have been: %0.2f",damage)
    
    if(!sh_get_id_bit(id,SH_IS_SHOCKED)){
        sh_shock_user(id,attacker)
    }

}
//----------------------------------------------------------------------------------------------
public sequoia_no_instant_kill(this, inflictor, attacker, Float:damage, damagebits)
{   
    //already ethereal. resists any conventional damage that isnt a grenade
    //lets just take care of grenades.
    //more details in sh_aux_funcs_natives_pt13.sma
    //the hero (bit) property based damage gating module
    //we can assume the damage is a grenade
    //as the handle in the other plugin will take care of the rest
    //sequoia cannot be insta killed AT full health.


    if(!sh_is_active()||sh_is_freezetime() ||!is_user_alive(this)) return HAM_IGNORED

    if(!is_valid_ent(inflictor)){

        return HAM_IGNORED
    }

    //alright FINE. lets check...

    static inflictor_classname[64];

    entity_get_string(inflictor,EV_SZ_classname,inflictor_classname,63)
    static bool:it_was_a_grenade; it_was_a_grenade = bool:equal(inflictor_classname,"grenade")
    static user_hp; user_hp = get_user_health(this);
    if( it_was_a_grenade){

        if((user_hp >= SEQUOIA_HEALTHCAP_INT_VERSION) && ( floatround(damage) > SEQUOIA_HEALTHCAP_INT_VERSION) ){
            
            sequoia_haramball_shield_react_primitive(this, attacker, damage)

            SetHamParamFloat(4,0.0)
            
            return HAM_SUPERCEDE
        }

        
    }
    return HAM_IGNORED
}

//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
    if(heroID!=gHeroID) return

    if(mode==SH_HERO_ADD){

        sh_chat_message(id,gHeroID,"Warning: Any firearms you carry will get destroyed in the start of the next round")


    }
    reset_sequoia(id)

}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
	if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID)|| sh_is_freezetime() ||!sh_is_inround()|| !is_user_alive(id) ) return

	switch(key)
	{
		case SH_KEYDOWN: {
			sequoia_kd(id)
		}
	}
}

sequoia_delete_charging_sound(id){

	if(is_user_connected(id)){
		emit_sound(id, CHAN_ITEM, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(id, CHAN_ITEM, HYDROCVTTR_CHARGING_SOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	}
}

public plugin_precache(){

    engfunc(EngFunc_PrecacheModel, SPHERE_MODEL)

    engfunc(EngFunc_PrecacheSound,HYDROCVTTR_CHARGING_SOUND)

}
sequoia_summon_beam(id){

    if(!is_user_alive(id)){
        return;
    }

    if(!sh_get_user_has_hero(id,gHeroID) ){

        return

    }

    new ent_id = create_entity("info_target")
    if (!is_valid_ent(ent_id)){
        console_print(id,"Error while creating hitter entity!^n")
        return    
    }

    entity_set_string(ent_id, EV_SZ_classname, SEQUOIA_BEAM_TERMINAL_ENT_CLASS)
    entity_set_edict(ent_id,EV_ENT_owner,id)

    entity_set_int(ent_id,EV_INT_rendermode, kRenderTransAlpha)
    entity_set_float(ent_id,EV_FL_renderamt,0.0)


        
    entity_set_model(ent_id,SPHERE_MODEL)


    entity_set_int(ent_id, EV_INT_solid, SOLID_NOT)

    if(!is_valid_ent(ent_id)){

        return
    }
    g_sequoia_look_direction[id][0] = SEQUOIA_START_ANGLE*(get_ratio(g_sequoia_damage_battery[id],cvar_val(float, pcvar_max_damage_battery)));

    entity_set_vector( id, EV_VEC_angles, g_sequoia_look_direction[id] )
    entity_set_vector( id, EV_VEC_v_angle, g_sequoia_look_direction[id] )
    entity_set_int( id, EV_INT_fixangle, 1 )


    entity_set_float(ent_id,EV_FL_nextthink,get_gametime()+SEQUOIA_BEAM_THINK_PERIOD)

}
public sequoia_beam_terminal_think(ent_id){


    if(!is_valid_ent(ent_id)){

        return PLUGIN_CONTINUE
    }
    
    static owner;

    owner= entity_get_edict(ent_id,EV_ENT_owner)

    if(!is_user_alive(owner)){
    
    
        remove_entity(ent_id);
        reset_sequoia(owner)
        return PLUGIN_CONTINUE
    
    
    }
    if(!sh_get_user_has_hero(owner,gHeroID) ){

        remove_entity(ent_id);
        reset_sequoia(owner)
        return PLUGIN_CONTINUE

    }

    static Float:gametime;
    
    gametime=get_gametime()

    static Float:aim_dest_coords[3],
            Float:max_charge,
            Float:curr_charging_inc

    max_charge = cvar_val(float, pcvar_max_damage_battery)
    my_get_aim_origin(owner,aim_dest_coords)

    if(!is_valid_ent(ent_id)){

        return PLUGIN_CONTINUE
    }
    entity_set_origin(ent_id,aim_dest_coords)
    static bool:is_held; is_held= bool:((Get_BitVar(user_is_keydown_mask,owner))&&(g_sequoia_look_direction[owner][0]>=0.0)&&(floatround(g_sequoia_damage_battery[owner])>0))&&sh_is_inround();
    

    curr_charging_inc = get_user_charge_dec(owner)*(SEQUOIA_BEAM_THINK_PERIOD)

    
    static Float:the_damage,Float:stored_damage, Float:the_radius

    the_damage = min_macro(get_user_sweep_damage(owner), g_sequoia_damage_battery[owner] )*(SEQUOIA_BEAM_THINK_PERIOD)

    the_radius = get_user_sweep_radius(owner)

    if(!is_valid_ent(ent_id)){

        return PLUGIN_CONTINUE
    }
    explosion(gHeroID,ent_id,the_radius,the_damage,10.0,1,1,_,
                        (explosion_sfx_show_shockwave|explosion_sfx_show_burn_decal|explosion_sfx_show_shockwave|explosion_sfx_show_fireball),
                        CHUCKY_BLUE,_,HYDROCVTTR_wpn_id)

    


    explosion_custom_entity(ent_id,the_radius,the_damage,"func_breakable",10.0,enum_zero)
    
    if(!is_valid_ent(ent_id)){

        return PLUGIN_CONTINUE
    }
    static entlist[33];
    new numfound = find_sphere_class(ent_id,"player",
                    the_radius,
                    entlist,
                    charsmax(entlist));

    for( new i= 0;(i< numfound);i++){

        new pid = entlist[i];
        if( !is_user_alive(pid) ) continue
        if( pid == owner ) continue
        
        sh_wet_user(pid,owner)
    }
//native directed_spark(init_id, end_id,girth=10,veins=10,glowing=255,ramming_pace=8,color_constant=GREEN, life=1, make_sound=1)
    
    if(!is_valid_ent(ent_id)){

        return PLUGIN_CONTINUE
    }
    if(is_held){

        g_sequoia_look_direction[owner][0] -=  SEQUOIA_ANGLE_LINEAR_INC

        g_sequoia_damage_battery[owner] -= (curr_charging_inc)

        //lets store the damage we output before the beam ends
        stored_damage = entity_get_float(ent_id,EV_FL_fuser1)
        entity_set_float(ent_id,EV_FL_fuser1,stored_damage + the_damage)

        client_print(owner,print_center,"[SH] %s: %s charge: %0.2f",gHeroName,dmg_source_name_short_HYDROCVTTR,(g_sequoia_damage_battery[owner]/max_charge)*100.0)


        directed_spark(ent_id, owner,100,1,255,100,CHUCKY_BLUE,1,0)
        entity_set_float(ent_id,EV_FL_nextthink, gametime + SEQUOIA_BEAM_THINK_PERIOD)
    }
    else{

        stored_damage = entity_get_float(ent_id,EV_FL_fuser1)

        new Float:the_percentage = max_macro(0.1,(stored_damage/cvar_val(float, pcvar_max_damage_battery)))

        new the_health_to_take_away = max_macro(1, floatround(entity_get_float(owner,EV_FL_health) * clamp_macro(the_percentage, 0.2, 0.78)))


        sh_extra_damage(owner,owner,the_health_to_take_away,
                        _,_,_,_,_,
                        SH_NEW_DMG_DRAIN,
                        ANNIHILATION_wpn_id)

        remove_entity(ent_id)
        reset_sequoia(owner)
    }
    return PLUGIN_CONTINUE;

}
set_sequoia_user_cooldown(id){

    static Float:the_cooldown;

    the_cooldown = cvar_val(float, pcvar_sequoia_base_cooldown)
    sh_set_cooldown(id,the_cooldown)
    g_sequoia_display_cooldown[id] = the_cooldown

}

public sequoia_kd(id){


    if ( sh_get_cooldown_flag(id)||!Get_BitVar(user_attack_ready,id)) {
        
        if(!is_user_bot(id)){

            sh_sound_deny(id)
        }
        return
    }

    static alive = 0, dead = 0;
    
    sh_get_player_counts(id,2, alive, dead)

    if(alive <=0){

        sh_chat_message(id,gHeroID,"No enemies were detected. Nothing to do")
        return

    }

    static flags = 0; flags = entity_get_int(id, EV_INT_flags);

    if((flags & FL_INGROUND2)){

        sh_chat_message(id,gHeroID,"You must not be in the ground when using your powers!")
        return


    }
    if(!Get_BitVar(user_is_keydown_mask,id)){

        Assign_BitVar(user_floating_mode_on, id, true_for_macro);


        if(Get_BitVar(user_floating_mode_on, id)){
            g_sequoia_last_gravity[id]=get_user_gravity(id)
            g_sequoia_last_max_speed[id]=get_user_maxspeed(id)
            entity_get_vector(id, EV_VEC_origin,g_sequoia_charging_origin[id])
        }
        Assign_BitVar(user_is_keydown_mask,id, true_for_macro);

        Assign_BitVar(user_is_inattack,id,false_for_macro)

        g_sequoia_current_aimed_at_player[id] = -1
        g_sequoia_attack_phase[id] = select

        do_player_iteration(id)
    }
    else{

        reset_sequoia(id,false,true)
    }
}
clean_sequoia_slate(){

    arrayset(g_sequoia_attack_phase,none,sizeof(g_sequoia_attack_phase))
    arrayset(g_sequoia_current_aimed_at_player,-1,sizeof(g_sequoia_current_aimed_at_player))
    arrayset(g_sequoia_damage_battery,0.0,sizeof(g_sequoia_damage_battery))

    user_is_keydown_mask = 0

    user_attack_ready = 0
    
    user_is_inattack = 0
    
    user_floating_mode_on = 0

    remove_entity_name(SEQUOIA_BEAM_TERMINAL_ENT_CLASS)
}

public sh_round_end(){
    
    clean_sequoia_slate()

}
public sh_round_new(){


    clean_sequoia_slate()

}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
    if(sh_is_active()){
        if ( sh_get_user_has_hero(id,gHeroID) ) {
            
            reset_sequoia(id,true)
        }
	}
	
}
//----------------------------------------------------------------------------------------------
public sh_client_death(id)
{	
    if(sh_is_active()){
        if ( sh_get_user_has_hero(id,gHeroID) ) {
            

            reset_sequoia(id,true)
        }
    }
	
}

reset_sequoia(id,bool:reset_stamina=false, bool:reset_floating_mode=true){
    if(!client_is_within_range(id)){
        return
    }
    Assign_BitVar(user_is_inattack,id,false_for_macro);
    Assign_BitVar(user_attack_ready,id, false_for_macro);
    Assign_BitVar(user_is_keydown_mask,id, false_for_macro);
    if(reset_floating_mode){
        Assign_BitVar(user_floating_mode_on,id, false_for_macro);
    }
    g_sequoia_current_aimed_at_player[id] = -1
    g_sequoia_attack_phase[id] = none
    g_sequoia_damage_battery[id] = 0.0
    if(reset_stamina){
        g_sequoia_damage_stamina[id] = 0.0
    }

    regulate_user_float(id,true)

    sequoia_delete_charging_sound(id)
}


public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type, custom_weapon_id){
    if ( !sh_is_active() || !is_user_alive(victim)||(victim==attacker)){

        return DMG_FWD_PASS
    }

    //ethereal players can ONLY be damaged by a very sparse selection of SH_NEW_DMG types
    //AND hand grenades, unless they have the ANTI_GRENADES_HERO property active


    if(!sh_get_user_has_hero(victim,gHeroID)){
        return DMG_FWD_PASS
    }
    new dmg_fwd_ret_id:the_return_value=DMG_FWD_PASS

    new user_hp = get_user_health(victim);

    if((user_hp >= SEQUOIA_HEALTHCAP_INT_VERSION) && ( damage > SEQUOIA_HEALTHCAP_INT_VERSION) ){
            
            sequoia_haramball_shield_react_primitive(victim, attacker,float(damage))

            the_return_value = DMG_FWD_BLOCK
    }

    return the_return_value
}