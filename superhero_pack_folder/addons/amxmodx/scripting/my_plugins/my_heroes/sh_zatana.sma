
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
#include "zatana_inc/zatana.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt9.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt13.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"

#include "../my_include/my_author_header.inc"

#define PLUGIN_NAME "Superhero Zatana"
#define PLUGIN_VERSION "1.0release"


#define ZATANA_SOUND "shmod/zatana/ghostly_acknowledgement.wav"


#define ZATANA_CHASE_CAMERA_CLASSNAME "zatana_camera"


enum attack_phase{

    none,
    select,
    STRIKE

}

new fury_swipes_wpn_id
new dmg_source_name_short_fury_swipes[SAFE_BUFFER_SIZE+1]="pester strikes!"
new dmg_source_name_log_fury_swipes[SAFE_BUFFER_SIZE+1]="pester strikes!"

stock const gHeroName[] = "Zatana"

static const DEBUG = 0

new user_is_keydown_mask = 0,
    user_is_inattack = 0,
    user_floating_mode_on = 0,
    user_is_mouse_one = 0,
    user_is_mouse_two = 0,
    user_is_mouse_three = 0


//odd period + even period

new const Float:periods[2] = {0.4, 0.2}

new const attack_phase_names[attack_phase][128]={
    "N/A",
    "Select",
    "STRIKE!"

}
new g_zatana_current_aimed_at_player[SH_MAXSLOTS+1]

new attack_phase:g_zatana_attack_phase[SH_MAXSLOTS+1]
new Float:g_zatana_last_gravity[SH_MAXSLOTS+1]
new Float:g_zatana_display_cooldown[SH_MAXSLOTS+1]
new Float:g_zatana_last_max_speed[SH_MAXSLOTS+1]
new Float:g_zatana_charging_origin[SH_MAXSLOTS+1][3]

new g_zatana_damage_times_left[SH_MAXSLOTS+1]
new camera[SH_MAXSLOTS+1]

//floats
new pcvar_zatana_gravity,
    pcvar_zatana_base_cooldown,
    pcvar_min_alpha,
    pcvar_max_alpha,
    pcvar_endeavour_hp,
    pcvar_post_attack_stun_time,
    pcvar_post_attack_stun_movespeed,
    pcvar_strikes_damage,
    pcvar_strikes_final_damage_additional,
    pcvar_pester_strike_on_strike_stun_speed,
    pcvar_pester_strike_on_strike_stun_time

//ints
new pcvar_num_normal_strikes
    

new Zatana_hudsync

new ZATANA_PASSIVE_TASKID = -1,
    ZATANA_ACTIVE_TASKID = -1,
    ZATANA_HURT_TASKID = -1

public plugin_init(){

    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, AUTHOR)

    create_cvar("zatana_level", "14")

    pcvar_strikes_damage = create_cvar("zatana_strikes_damage", "10.0")
    
    pcvar_strikes_final_damage_additional = create_cvar("zatana_strikes_final_damage_additional", "5.0")
    
    pcvar_num_normal_strikes = create_cvar("zatana_num_normal_strikes", "6")

    pcvar_zatana_gravity = create_cvar("zatana_gravity", "0.25")

    pcvar_endeavour_hp = create_cvar("zatana_endeavour_hp", "0.25")

    pcvar_zatana_base_cooldown = create_cvar("zatana_base_cooldown", "10.0")

    pcvar_min_alpha = create_cvar("zatana_min_alpha", "10.0")

    pcvar_max_alpha = create_cvar("zatana_max_alpha", "200.0")

    pcvar_post_attack_stun_time = create_cvar("zatana_post_attack_stun_time", "10.0")

    pcvar_post_attack_stun_movespeed = create_cvar("zatana_post_attack_stun_movespeed", "100.0")

    pcvar_pester_strike_on_strike_stun_speed = create_cvar("zatana_pester_strike_on_strike_stun_speed", "1.0")

    pcvar_pester_strike_on_strike_stun_time = create_cvar("zatana_pester_strike_on_strike_stun_time", "1.0")
    


    gHeroID=shCreateHero(gHeroName, "Wind probe!", "Pester strikes! Attack anyone on the map for small damage. Long cooldown", true, "zatana_level" )

    sh_register_admin_only_hero(gHeroID,ADMIN_IMMUNITY,1,
                    "Do you know what happens to very experimental, hard to explain or just overall unfinished heroes? Take a guess")

    sh_register_elemental_probe_hero(gHeroID, ZATANA_HEALTHCAP, pcvar_zatana_gravity)


    RegisterHam(Ham_TakeDamage,"player","zatana_no_instant_kill",_, true)

    register_think(ZATANA_CHASE_CAMERA_CLASSNAME, "zatana_camera_think")

    sh_register_superheromod_model(gHeroID,
                                "models/player/sablina/sablina.mdl",
                                "models/player/sablina/sablina.mdl",
                                "sablina",
                                "...",
                                "...")



    register_forward(FM_CmdStart,"fw_Zatana_aim_button")

    init_progress_bar_msg_var()

    fury_swipes_wpn_id=sh_log_custom_damage_source(
                                gHeroID,
                                dmg_source_name_short_fury_swipes,
                                dmg_source_name_log_fury_swipes,
                                0)

    ZATANA_PASSIVE_TASKID = allocate_typed_task_id(generic_task)

    ZATANA_ACTIVE_TASKID = allocate_typed_task_id(generic_task)

    ZATANA_HURT_TASKID = allocate_typed_task_id(player_task)

    set_task( ZATANA_PASSIVE_TASK_TIME_PERIOD, "zatana_passive_loop", ZATANA_PASSIVE_TASKID, _, _, "b")
    set_task( ZATANA_ACTIVE_TASK_TIME_PERIOD, "zatana_active_loop", ZATANA_ACTIVE_TASKID, _, _, "b")




    init_gravity_pcvar()

    Zatana_hudsync = CreateHudSyncObj()
}

public zatana_camera_think(camera_ent_id){

    if(!is_valid_ent(camera_ent_id)){

        return PLUGIN_CONTINUE;

    }

    static owner; owner= entity_get_edict(camera_ent_id, EV_ENT_owner)
    
    if(!is_user_alive(owner)){
        
        attach_view(owner,owner)
        remove_entity(camera_ent_id)
        return PLUGIN_CONTINUE
    }
    if(!sh_is_inround()){
        
        attach_view(owner,owner)
        remove_entity(camera_ent_id)
        return PLUGIN_CONTINUE
    }
    if(!sh_get_user_has_hero(owner, gHeroID)){

        attach_view(owner,owner)
        remove_entity(camera_ent_id)
        return PLUGIN_CONTINUE
    }

    if(!zatana_user_target_is_valid(owner, g_zatana_current_aimed_at_player[owner])){
        
        attach_view(owner,owner)
        remove_entity(camera_ent_id)
        return PLUGIN_CONTINUE
    }

    static Float:online_time_left = 0.0;
    online_time_left = entity_get_float(camera[owner], EV_FL_fuser1)

    if(online_time_left <= 0.0){

        attach_view(owner,owner)
        remove_entity(camera_ent_id)
        return PLUGIN_CONTINUE

    }
    static the_tg_id_to_check; the_tg_id_to_check= g_zatana_current_aimed_at_player[owner]

    static Float:tg_origin[3],
            Float:tg_velocity[3],
            Float:tg_velocity2[3]


    entity_get_vector(the_tg_id_to_check, EV_VEC_origin, tg_origin)

    velocity_by_aim(the_tg_id_to_check,floatround(ZATANA_CAMERA_DISTANCE),tg_velocity)


    new Float:length=vector_length(tg_velocity)

    
    
    tg_origin[1]+=tg_velocity[1]*(ZATANA_CAMERA_DISTANCE/length)
    tg_origin[2]+=tg_velocity[2]*(ZATANA_CAMERA_DISTANCE/length)
    tg_origin[2]+=40.0
    tg_origin[0]+=tg_velocity[0]*(ZATANA_CAMERA_DISTANCE/length)
    multiply_3d_vector_by_scalar(tg_velocity,-1.0,tg_velocity2)
    vector_to_angle(tg_velocity2,tg_velocity2)
    entity_set_vector(camera[owner], EV_VEC_angles, tg_velocity2)
    entity_set_origin(camera[owner],  tg_origin)

    entity_set_float(camera[owner], EV_FL_fuser1, online_time_left - ZATANA_CAMERA_THINK_PERIOD)
    entity_set_float(camera[owner], EV_FL_nextthink, get_gametime()+ ZATANA_CAMERA_THINK_PERIOD)
    return PLUGIN_CONTINUE

}
zatana_spawn_enemy_camera(owner){
    
    
    if(!is_user_alive(owner)){

        return
    }

    if(!sh_get_user_has_hero(owner, gHeroID)){

        return
    }

    if(!zatana_user_target_is_valid(owner, g_zatana_current_aimed_at_player[owner])){

        return
    }
    static the_tg_id_to_check; the_tg_id_to_check= g_zatana_current_aimed_at_player[owner]

    if(!is_user_alive(the_tg_id_to_check)){

        return
    }
    camera[owner] = create_entity("info_target")



    if(camera[owner] > 0)
    {

        entity_set_string(camera[owner], EV_SZ_classname, ZATANA_CHASE_CAMERA_CLASSNAME)
        entity_set_int(camera[owner], EV_INT_solid, SOLID_NOT)
        entity_set_int(camera[owner], EV_INT_movetype, MOVETYPE_NOCLIP)
        entity_set_size(camera[owner], Float:{-1.0,-1.0,-1.0}, Float:{1.0,1.0,1.0})
        entity_set_model(camera[owner], ZATANA_CAMERA_MODEL)
        set_rendering(camera[owner], kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0)

        entity_set_edict(camera[owner], EV_ENT_owner, owner)

        static Float:tg_origin[3],
                Float:tg_velocity[3],
                Float:tg_velocity2[3]


        entity_get_vector(the_tg_id_to_check, EV_VEC_origin, tg_origin)

        velocity_by_aim(the_tg_id_to_check,floatround(ZATANA_CAMERA_DISTANCE),tg_velocity)


        new Float:length=vector_length(tg_velocity)

        
        
        tg_origin[1]+=tg_velocity[1]*(ZATANA_CAMERA_DISTANCE/length)
        tg_origin[2]+=tg_velocity[2]*(ZATANA_CAMERA_DISTANCE/length)
        tg_origin[2]+=40.0
        tg_origin[0]+=tg_velocity[0]*(ZATANA_CAMERA_DISTANCE/length)
        multiply_3d_vector_by_scalar(tg_velocity,-1.0,tg_velocity2)
        vector_to_angle(tg_velocity2,tg_velocity2)
        entity_set_vector(camera[owner], EV_VEC_angles, tg_velocity2)
        entity_set_origin(camera[owner],  tg_origin)
        
        
        attach_view(owner, camera[owner])


        entity_set_float(camera[owner], EV_FL_fuser1, ZATANA_CAMERA_ONLINE_TIME)
        entity_set_float(camera[owner], EV_FL_nextthink, get_gametime()+ ZATANA_CAMERA_THINK_PERIOD)
    }
}
bool:zatana_user_target_is_valid(id,the_player_to_evaluate){


    if(is_user_alive(the_player_to_evaluate)){
        
        if(!sh_clients_are_same_team(the_player_to_evaluate,id)&&(the_player_to_evaluate!=id)){

            return true
        }

    }
    return false
}
Float:get_ratio(Float:the_current, Float:the_max){

	return clamp_macro(( the_current/ the_max),0.1,0.99)

}
regulate_user_float(id){

    if(Get_BitVar(user_floating_mode_on,id)){

        entity_set_vector( id, EV_VEC_velocity, NULL_VECTOR )

        entity_set_origin(id,g_zatana_charging_origin[id])

        set_user_gravity(id,0.01)

        set_user_maxspeed_controlled(id, 0.3,true, false)
        return
    }
}
remove_user_float(id){

    if(is_user_alive(id)&&Get_BitVar(user_floating_mode_on,id)){

        sh_reset_min_gravity(id)
        if(!sh_get_stun(id)){
            sh_reset_max_speed(id)
        }
        Assign_BitVar(user_floating_mode_on,id, false_for_macro)
    }
}
//----------------------------------------------------------------------------------------------
public zatana_active_loop(taskid)
{	
    if ( !sh_is_active() || sh_is_freezetime() || !sh_is_inround() ) return

    new the_players[SH_MAXSLOTS], pnum, id		
    get_players(the_players, pnum, "a")
    for (new i = 0; i < pnum; i++) {
        
        id = the_players[i]

        if ( !sh_get_user_has_hero(id,gHeroID)){
            
            continue

        }

        regulate_user_float(id)


        if((g_zatana_attack_phase[id]<STRIKE)){

            if(g_zatana_attack_phase[id]<=none){
                continue
            }
            
            if(!zatana_user_target_is_valid(id,g_zatana_current_aimed_at_player[id])){
                new bool:result = do_player_iteration(id);
                
                if(!result){
                    
                    g_zatana_attack_phase[id] = none
                    continue

                }
                else{
                    static player_name[128];

                    get_user_name(g_zatana_current_aimed_at_player[id],player_name, charsmax(player_name))
                    sh_chat_message(id,gHeroID,"The current target player's name is: %s",player_name)
                }

            }
        }

        if(g_zatana_attack_phase[id]==STRIKE){
                
            if(!Get_BitVar(user_is_inattack,id)){
                Assign_BitVar(user_is_inattack,id,true_for_macro)
                if(!sh_get_cooldown_flag(id)){
                    set_zatana_user_cooldown(id)
                    zatana_summon_strike(id)
                }
            }
            continue
        }






    }
}
//----------------------------------------------------------------------------------------------
public zatana_passive_loop(taskid)
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


        static alive = 0, dead = 0;
        
        sh_get_player_counts(id,2, alive, dead)

        if((alive<=0)&&Get_BitVar(user_is_keydown_mask,id)){
            
            sh_chat_message(id,gHeroID,"No enemies were detected. Your powers have been taken away")
            reset_zatana(id,true)

        }

        static Float:max_health; max_health = float(sh_get_max_hp(id))

        the_alpha_floated = 
                        
                        cvar_val(float, pcvar_min_alpha)
                                        
                                        +

                ((cvar_val(float, pcvar_max_alpha) - cvar_val(float, pcvar_min_alpha))
                    
                                    *
                    (1.0 - get_ratio(entity_get_float(id, EV_FL_health) ,max_health)))





        the_actual_alpha = floatround( the_alpha_floated, floatround_round)

        set_render_with_color_const(id,FX_NONE,1,the_actual_alpha,
                            20,
                            _,_,
                            ZATANA_PASSIVE_TASK_TIME_PERIOD,0,_,_,PRIO_RENDER_INVISIBILITY,gHeroID)

        
        if(!is_user_bot(id)){
            static print_buff[512]
            
            if(g_zatana_display_cooldown[id] > 0.0){
                g_zatana_display_cooldown[id] -= min_macro(ZATANA_PASSIVE_TASK_TIME_PERIOD,g_zatana_display_cooldown[id])
            }

            (DEBUG?
                    (formatex(print_buff,charsmax(print_buff),"[SH] %s info hud:^nAttack phase: %s^nCurrent cooldown: %0.2f^nTimes left: %d^nIn attack? %s^nFloating mode: %s^n",
                                            gHeroName,
                                            attack_phase_names[g_zatana_attack_phase[id]],
                                            g_zatana_display_cooldown[id],
                                            g_zatana_damage_times_left[id],
                                            Get_BitVar(user_is_inattack,id)?"Yes!":"No...",
                                            Get_BitVar(user_floating_mode_on, id)?"Yes!":"No..."))

                                        :

                    (formatex(print_buff,charsmax(print_buff),"[SH] %s info hud:^nAttack phase: %s^nCurrent cooldown: %0.2f^n",
                                            gHeroName,
                                            attack_phase_names[g_zatana_attack_phase[id]],
                                            g_zatana_display_cooldown[id])))


            set_hudmessage(LineColors[FX_STUN][0],LineColors[FX_STUN][1],LineColors[FX_STUN][2],0.0,0.35,0,0.0,ZATANA_PASSIVE_TASK_TIME_PERIOD,0.0,0.0,-1,255)

            ShowSyncHudMsg(id,Zatana_hudsync, "%s", print_buff)

        }




    }
}
public plugin_natives(){

    register_native("zatana_get_hero_id","_zatana_get_hero_id")

}


public _zatana_get_hero_id(iPlugins, iParams){


    return gHeroID

}
public fw_Zatana_aim_button(id, uc_handle)
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
    static bool:remove_buttons_from_mask; remove_buttons_from_mask = false

    if(!Get_BitVar(user_is_keydown_mask,id)){

        return FMRES_IGNORED


    }

    static alive = 0, dead = 0;
    
    sh_get_player_counts(id,2, alive, dead)

    if(alive <=0){

        return FMRES_IGNORED

    }

    static prev_button; prev_button = entity_get_int(id, EV_INT_oldbuttons)
    static mask_to_take_off = 0 ; mask_to_take_off = 0
    
    if(DEBUG){
        if((button & IN_ALT1) && (!(prev_button & IN_ALT1)) && (g_zatana_attack_phase[id]==select))
        {   
            mask_to_take_off |= (IN_ATTACK)
            remove_buttons_from_mask = true
            if(!Get_BitVar(user_is_mouse_three,id)){
                Assign_BitVar(user_is_mouse_three,id,true_for_macro)
                
                g_zatana_attack_phase[id]=STRIKE
                emit_sound(id, CHAN_ITEM, ZATANA_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                g_zatana_current_aimed_at_player[id] = id
                sh_chat_message(id,gHeroID,"Self strike selected!")
            }
        }
        else{


            Assign_BitVar(user_is_mouse_three, id, false_for_macro)
        }
    }
    if((button & IN_ATTACK) && (!(prev_button & IN_ATTACK)) && (g_zatana_attack_phase[id]==select))
    {   
        mask_to_take_off |= (IN_ATTACK)
        remove_buttons_from_mask = true
        if(!Get_BitVar(user_is_mouse_one,id)){
            Assign_BitVar(user_is_mouse_one,id,true_for_macro)
            if(do_player_iteration(id)){
                static player_name[128];

                get_user_name(g_zatana_current_aimed_at_player[id],player_name, charsmax(player_name))
                sh_chat_message(id,gHeroID,"The current target player's name is: %s",player_name)
            }
        }
    }
    else{


        Assign_BitVar(user_is_mouse_one, id, false_for_macro)
    }
    if((button & IN_ATTACK2) && (!(prev_button & IN_ATTACK2)))
    {

        mask_to_take_off |= (IN_ATTACK2)
        remove_buttons_from_mask = true

        if(!Get_BitVar(user_is_mouse_two,id)){

            Assign_BitVar(user_is_mouse_two,id, true_for_macro)

            switch(g_zatana_attack_phase[id]){
                case(select):{
                    if(zatana_user_target_is_valid(id,g_zatana_current_aimed_at_player[id])){
                        g_zatana_attack_phase[id]=STRIKE
                        emit_sound(id, CHAN_ITEM, ZATANA_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                    }
                }
                default:{
                    

                }
            }
        }
        
    }
    else{


        Assign_BitVar(user_is_mouse_two, id, false_for_macro)
    }
    if(remove_buttons_from_mask){
        
        button &= (~(mask_to_take_off))

        set_uc(uc_handle,UC_Buttons,button)
        return FMRES_SUPERCEDE
    }
    return FMRES_IGNORED
}
player_iterator_next(owner_id,curr_iter_player=-1){
	
    curr_iter_player = find_ent_by_class(curr_iter_player, "player")
    while(curr_iter_player) {

        if(is_valid_ent(curr_iter_player)){

            if(zatana_user_target_is_valid(owner_id,curr_iter_player)){

                return curr_iter_player

            }
        }
        curr_iter_player = find_ent_by_class(curr_iter_player, "player")
    }
    return -1;
	
}

bool:do_player_iteration(id){


    g_zatana_current_aimed_at_player[id] = player_iterator_next(id,g_zatana_current_aimed_at_player[id])
    
    new bool:result = zatana_user_target_is_valid(id,g_zatana_current_aimed_at_player[id])
    if(result){
        emit_sound(id, CHAN_ITEM, GENERIC_MENU_PROMPT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    }
    return result
}
zatana_haramball_shield_react_primitive(id,attacker, Float:damage){

            
    set_user_health(id,floatround(cvar_val(float, pcvar_endeavour_hp)))

    sh_chat_message(id,gHeroID,"We blocked an instant kill! The damage received would have been: %0.2f",damage)
    
    if(!sh_get_id_bit(id,SH_IS_SHOCKED)){
        sh_shock_user(id,attacker)
    }

}
//----------------------------------------------------------------------------------------------
public zatana_no_instant_kill(this, inflictor, attacker, Float:damage, damagebits)
{   
    //already ethereal. resists any conventional damage that isnt a grenade
    //lets just take care of grenades.
    //more details in sh_aux_funcs_natives_pt13.sma
    //the hero (bit) property based damage gating module
    //we can assume the damage is a grenade
    //as the handle in the other plugin will take care of the rest
    //zatana cannot be insta killed AT full health.


    if(!sh_is_active()||sh_is_freezetime() ||!is_user_alive(this)) return HAM_IGNORED

    if(!is_valid_ent(inflictor)){

        return HAM_IGNORED
    }

    if(!sh_get_user_has_hero(this,gHeroID)){

        return FMRES_IGNORED
    }

    //alright FINE. lets check...

    static inflictor_classname[64];

    entity_get_string(inflictor,EV_SZ_classname,inflictor_classname,63)
    static bool:it_was_a_grenade; it_was_a_grenade = bool:equal(inflictor_classname,"grenade")
    static user_hp; user_hp = get_user_health(this);
    if( it_was_a_grenade){

        if((user_hp >= ZATANA_HEALTHCAP_INT_VERSION) && ( floatround(damage) > ZATANA_HEALTHCAP_INT_VERSION) ){
            
            zatana_haramball_shield_react_primitive(this, attacker, damage)

            SetHamParamFloat(4,0.0)
            
            return HAM_SUPERCEDE
        }

        
    }
    return HAM_IGNORED
}

//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
    if(heroID!=gHeroID) return

    reset_zatana(id,true)

}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
	if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID)|| sh_is_freezetime() ||!sh_is_inround()|| !is_user_alive(id) ) return

	switch(key)
	{
		case SH_KEYDOWN: {
			zatana_kd(id)
		}
	}
}

public plugin_precache(){

    engfunc(EngFunc_PrecacheSound, ZATANA_SOUND)

    engfunc(EngFunc_PrecacheSound, WOUND_SFX)

    engfunc(EngFunc_PrecacheSound, GENERIC_MENU_PROMPT_SFX)

    engfunc(EngFunc_PrecacheSound, GENERIC_MENU_DISMISS_SFX)

    engfunc(EngFunc_PrecacheModel, ZATANA_CAMERA_MODEL)


}
zatana_summon_strike(id){

    if(!is_user_alive(id)){
        return;
    }

    if(!sh_get_user_has_hero(id,gHeroID) ){

        return

    }

    
    g_zatana_damage_times_left[id] = cvar_val(num, pcvar_num_normal_strikes) + 1
    new array[2];
    array[0] = g_zatana_current_aimed_at_player[id]
    array[1] = true
    set_task(ZATANA_HURT_TASK_BEGIN_DELAY, "zatana_hurt_task", id + ZATANA_HURT_TASKID, array, sizeof(array))


}
public zatana_hurt_task(array[2],task_id){

    new id = task_id - ZATANA_HURT_TASKID

    new tg_id = array[0],
        bool:just_begun = bool:array[1]

    if(just_begun){
        zatana_spawn_enemy_camera(id)
        array[1] = false
        set_task(ZATANA_CAMERA_THINK_PERIOD, "zatana_hurt_task", id + ZATANA_HURT_TASKID, array, 1)
        return
    }

    if(!is_user_alive(id)){
        return
    }
    if(!is_user_alive(tg_id) ){

        reset_zatana(id,true)
        return
    }
    if(!sh_get_user_has_hero(id,gHeroID) ){

        reset_zatana(id,true)
        return

    }

    new even_or_odd = (g_zatana_damage_times_left[id]%2)

    new Float:the_damage_to_do = ( cvar_val(float, pcvar_strikes_damage) + ( (g_zatana_damage_times_left[id] == 1) ? cvar_val(float, pcvar_strikes_final_damage_additional) : 0.0 ) )
    
    static origin[3],Float:forigin[3]

    entity_get_vector(tg_id,EV_VEC_origin,forigin)

    FVecIVec(forigin,origin)



    if((g_zatana_damage_times_left[id] == 1)){

        sh_bleed_user(tg_id,id,BLEED_NORMAL,gHeroID,0)
        fx_blood_large(origin,2)
        blood_spray(forigin,4)

    }
    else{
        fx_blood_small(origin,2)
        blood_spray(forigin,2)
    }




    static Float:the_micro_stun_time; the_micro_stun_time = cvar_val(float, pcvar_pester_strike_on_strike_stun_time)

    set_damage_icon(tg_id,1,
    DMG_ICON_DROWN,
    LineColors[FX_STUN],
    the_micro_stun_time)

    sh_set_stun(tg_id, the_micro_stun_time, cvar_val(float, pcvar_pester_strike_on_strike_stun_speed))

    emit_sound(tg_id, CHAN_STATIC, WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    emit_sound(tg_id, CHAN_STATIC, PIERCE_WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

    sh_extra_damage(tg_id,id,floatround(the_damage_to_do, floatround_ceil),
                                    _,_,_,_,_,
                                    SH_NEW_DMG_DARK_ARTS,
                                    fury_swipes_wpn_id)



    if(!is_user_alive(tg_id)){

        reset_zatana(id,true,true)
        return
    }
    g_zatana_damage_times_left[id]--

    if(g_zatana_damage_times_left[id]>0){
    
        set_task(periods[even_or_odd], "zatana_hurt_task", id + ZATANA_HURT_TASKID, array, 1)
    
    }
    else{

        reset_zatana(id,true,true)
    }
    

}
set_zatana_user_cooldown(id){

    static Float:the_cooldown;

    the_cooldown = cvar_val(float, pcvar_zatana_base_cooldown)
    sh_set_cooldown(id,the_cooldown)
    g_zatana_display_cooldown[id] = the_cooldown

}

public zatana_kd(id){


    if ( sh_get_cooldown_flag(id)) {
        
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



        g_zatana_last_gravity[id]=get_user_gravity(id)
        g_zatana_last_max_speed[id]=get_user_maxspeed(id)
        entity_get_vector(id, EV_VEC_origin,g_zatana_charging_origin[id])
        
        Assign_BitVar(user_is_keydown_mask,id, true_for_macro);

        Assign_BitVar(user_is_inattack,id,false_for_macro)

        g_zatana_current_aimed_at_player[id] = -1
        g_zatana_attack_phase[id] = select

        if(do_player_iteration(id)){

            static player_name[128];

            get_user_name(g_zatana_current_aimed_at_player[id],player_name, charsmax(player_name))
            sh_chat_message(id,gHeroID,"The current target player's name is: %s",player_name)
        }
    }
    else{

        reset_zatana(id,true)
    }
}
clean_zatana_slate(){

    arrayset(g_zatana_attack_phase,none,sizeof(g_zatana_attack_phase))
    arrayset(g_zatana_current_aimed_at_player,-1,sizeof(g_zatana_current_aimed_at_player))
    arrayset(g_zatana_damage_times_left,0,sizeof(g_zatana_damage_times_left))

    user_is_keydown_mask = 0
    
    user_is_inattack = 0
    
    user_floating_mode_on = 0
}

public sh_round_end(){
    
    clean_zatana_slate()

}
public sh_round_new(){


    clean_zatana_slate()

}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
    if(sh_is_active()){
        if ( sh_get_user_has_hero(id,gHeroID) ) {
            
            g_zatana_display_cooldown[id] = 0.0
            reset_zatana(id)
        }
	}
	
}
//----------------------------------------------------------------------------------------------
public sh_client_death(id)
{	
    if(sh_is_active()){
        if ( sh_get_user_has_hero(id,gHeroID) ) {
            
            reset_zatana(id)
        }
    }
	
}

reset_zatana(id,bool:reset_floating_mode=false, bool:stun_user=false){
    if(!client_is_within_range(id)){
        return
    }
    if(DEBUG){

        sh_chat_message(id,gHeroID,"Reset function called on you with parameters:")
        sh_chat_message(id,gHeroID,"Reset floating mode? %s",reset_floating_mode?"Yes!":"No...")
    }
    Assign_BitVar(user_is_inattack,id,false_for_macro);
    Assign_BitVar(user_is_keydown_mask,id, false_for_macro);
    if(reset_floating_mode){
        remove_user_float(id)
    }
    g_zatana_current_aimed_at_player[id] = -1

    g_zatana_attack_phase[id] = none
    
    g_zatana_damage_times_left[id] = 0

    if(stun_user && !sh_get_stun(id)){

        new Float:stun_time = cvar_val(float, pcvar_post_attack_stun_time),
                Float:stun_movespeed = cvar_val(float, pcvar_post_attack_stun_movespeed)
        
        set_damage_icon(id,1,
            DMG_ICON_DROWN,
            LineColors[FX_STUN],
            stun_time)
        
        sh_set_stun(id,stun_time,stun_movespeed)


    }
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

    if((user_hp >= ZATANA_HEALTHCAP_INT_VERSION) && ( damage > ZATANA_HEALTHCAP_INT_VERSION) && (dmgMode!= SH_DMG_KILL)){
            
            zatana_haramball_shield_react_primitive(victim, attacker,float(damage))

            the_return_value = DMG_FWD_BLOCK
    }

    return the_return_value
}