
#define I_WANT_MISC_FUNCS
#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MATH_FUNCS

#include "../my_include/superheromod.inc"
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_BASIC_MACROS
#define I_WANT_PDATA_ALIASES
#include <float>
#include <xs>
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "shock_fx_inc/shock_fx.inc"
#include "sequoia_inc/sequoia.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"

#include "../my_include/my_author_header.inc"

#define PLUGIN_NAME "Superhero Sequoia"
#define PLUGIN_VERSION "0.1alpha"

#define SEQUOIA_START_ANGLE ((70.0))
#define SEQUOIA_BEAM_THINK_PERIOD 0.05
#define SEQUOIA_SWEEP_TIME 5.0

#define SEQUOIA_ANGLE_LINEAR_INC ((SEQUOIA_START_ANGLE/SEQUOIA_SWEEP_TIME)*SEQUOIA_BEAM_THINK_PERIOD)

#define SEQUOIA_BEAM_TERMINAL_ENT_CLASS "sequoia_terminal"

new HYDROCVTTR_wpn_id
new dmg_source_name_short_HYDROCVTTR[SAFE_BUFFER_SIZE+1]="HYDROCVTTR"
new dmg_source_name_log_HYDROCVTTR[SAFE_BUFFER_SIZE+1]="HYDROCVTTR"


#define SEQUOIA_HEALTHCAP 30.0
#define SEQUOIA_HEALTHCAP_INT_VERSION 30

stock const gHeroName[] = "Sequoia"

new user_is_keydown_mask = 0

//floars
new pcvar_sequoia_gravity,
    pcvar_sequoia_base_cooldown

enum attack_phase{

    none,
    select,
    aim,
    fire

}
new Float:g_sequoia_look_direction[SH_MAXSLOTS+1][3],
        g_sequoia_current_aimed_at_player[SH_MAXSLOTS+1]

new attack_phase:g_sequoia_attack_phase[SH_MAXSLOTS+1]


public plugin_init(){

    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, AUTHOR)

    create_cvar("sequoia_level", "14")

    pcvar_sequoia_gravity = create_cvar("sequoia_gravity", "0.25")

    pcvar_sequoia_base_cooldown = create_cvar("sequoia_base_cooldown", "10.0")

    gHeroID=shCreateHero(gHeroName, "Water probe!", "Summon HYDROCVTTR! A devastating water attack. Long recharging...", true, "sequoia_level" )

    RegisterHam(Ham_TakeDamage,"player","sequoia_no_instant_kill",_, true)

    sh_set_hero_grav(gHeroID, pcvar_sequoia_gravity)

    register_think(SEQUOIA_BEAM_TERMINAL_ENT_CLASS,"sequoia_beam_terminal_think")

    sh_register_hero_healthcap(gHeroID, SEQUOIA_HEALTHCAP)

    register_forward(FM_PlayerPreThink, "Fwd_PlayerPreThink")

    register_forward(FM_CmdStart,"fw_Sequoia_aim_button")

    sh_assign_hero_bit(gHeroID, SH_UNHEALABLE_HERO, true)

    sh_assign_hero_bit(gHeroID, SH_ETHEREAL_HERO, true)

    sh_assign_hero_bit(gHeroID, SH_ELEMENTAL_PROBE_HERO, true)

    HYDROCVTTR_wpn_id=sh_log_custom_damage_source(
                                gHeroID,
                                dmg_source_name_short_HYDROCVTTR,
                                dmg_source_name_log_HYDROCVTTR,
                                0)
    init_gravity_pcvar()
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
    if(!Get_BitVar(user_is_keydown_mask,id)){


        return FMRES_IGNORED


    }

    static alive=0,dead=0

    sh_get_player_counts(id,1, alive, dead)

    if(alive<=0){

        return FMRES_IGNORED

    }
    static player_name[128]
    static button; button = get_uc(uc_handle, UC_Buttons);
    static prev_button; prev_button = entity_get_int(id, EV_INT_oldbuttons)
    if((button & IN_ATTACK) && (!(prev_button & IN_ATTACK)) && (g_sequoia_attack_phase[id]==select))
    {
        do_player_iteration(id)

        get_user_name(g_sequoia_current_aimed_at_player[id],player_name, charsmax(player_name))

        sh_chat_message(id,gHeroID,"The aimed-at player is named: %s",player_name)

        return FMRES_SUPERCEDE
        
    }
    else if((button & IN_ATTACK2) && (!(prev_button & IN_ATTACK2)))
    {
        if(g_sequoia_attack_phase[id]==select){
            g_sequoia_attack_phase[id]=aim
        }
        else{


            g_sequoia_attack_phase[id]=fire
            sequoia_summon_beam(id)

        }

        return FMRES_SUPERCEDE
        
    }
    return FMRES_IGNORED
}
player_iterator_next(owner_id,curr_iter_player=-1){
    
    
    sh_chat_message(owner_id,gHeroID,"Is this even getting called?")
	
    curr_iter_player = find_ent_by_class(curr_iter_player, "player")
    while(curr_iter_player) {

        if(is_valid_ent(curr_iter_player)){
            static player_name[128]
            
            get_user_name(curr_iter_player,player_name, charsmax(player_name))

            sh_chat_message(owner_id,gHeroID,"The currently iterated player is named: %s",player_name)

            if(is_user_alive(curr_iter_player)){

                if(!sh_clients_are_same_team(curr_iter_player,owner_id)){

                    return curr_iter_player
                }

            }
        }
        curr_iter_player = find_ent_by_class(curr_iter_player, "player")
    }
    return -1;
	
}

do_player_iteration(id){


        do{
                

            g_sequoia_current_aimed_at_player[id] = player_iterator_next(id,g_sequoia_current_aimed_at_player[id])
        

        }
        while((g_sequoia_current_aimed_at_player[id]<=0)||(g_sequoia_current_aimed_at_player[id]==id));

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
public Fwd_PlayerPreThink(id)
{
    if(!is_user_alive(id)){
        return FMRES_IGNORED
    }

    if(g_sequoia_attack_phase[id]<=none){
        return FMRES_IGNORED
    }
    if(g_sequoia_attack_phase[id]<fire){
        point_player_towards_other_player(id,g_sequoia_current_aimed_at_player[id])
    }
    entity_set_vector( id, EV_VEC_angles, g_sequoia_look_direction[id] )
    entity_set_vector( id, EV_VEC_v_angle, g_sequoia_look_direction[id] )
    entity_set_int( id, EV_INT_fixangle, 1 )
    return FMRES_IGNORED
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
            

            sh_chat_message(this,gHeroID,"We blocked an instant kill! The damage received would have been: %0.2f",damage)
            
            if(!sh_get_id_bit(this,SH_IS_SHOCKED)){
                sh_shock_user(this,attacker)
            }

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


    Assign_BitVar(user_is_keydown_mask,id,false_for_macro)
    g_sequoia_current_aimed_at_player[id] = -1
    g_sequoia_attack_phase[id] = none

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
		case SH_KEYUP: {
			sequoia_ku(id)
		}
	}
}
public plugin_precache(){

    engfunc(EngFunc_PrecacheModel, SPHERE_MODEL)
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
    g_sequoia_look_direction[id][0] = SEQUOIA_START_ANGLE

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
        return PLUGIN_CONTINUE
    
    
    }
    if(!sh_get_user_has_hero(owner,gHeroID) ){

        remove_entity(ent_id);
        return PLUGIN_CONTINUE

    }
    static Float:gametime;
    
    gametime=get_gametime()

    static Float:aim_dest_coords[3]

    my_get_aim_origin(owner,aim_dest_coords)

    entity_set_origin(ent_id,aim_dest_coords)
    static bool:is_held; is_held= bool:((Get_BitVar(user_is_keydown_mask,owner))&&(g_sequoia_look_direction[owner][0]>=0.0));
    
    explosion(gHeroID,ent_id,is_held?50.0:1000.0,is_held?60.0:600.0,10.0,1,1,_,
                        is_held ?  (explosion_sfx_show_burn_decal|explosion_sfx_show_shockwave):(explosion_sfx_show_shockwave| explosion_sfx_show_fireball),
                        CHUCKY_BLUE,_,HYDROCVTTR_wpn_id)

    explosion_custom_entity(ent_id,is_held?50.0:1000.0,is_held?60.0:600.0,"func_breakable",10.0,enum_zero)

//native directed_spark(init_id, end_id,girth=10,veins=10,glowing=255,ramming_pace=8,color_constant=GREEN, life=1, make_sound=1)
    
    if(!is_valid_ent(ent_id)){

        return PLUGIN_CONTINUE
    }
    if(is_held){

        g_sequoia_look_direction[owner][0] -=  SEQUOIA_ANGLE_LINEAR_INC

        client_print(owner,print_center,"Our direction vector is: yaw,pitch,roll: (%0.2f, %0.2f, %0.2f)",
                                                                                                            g_sequoia_look_direction[owner][0],
                                                                                                            g_sequoia_look_direction[owner][1],
                                                                                                            g_sequoia_look_direction[owner][2])

        directed_spark(ent_id, owner,100,1,255,100,CHUCKY_BLUE,1,1)
        entity_set_float(ent_id,EV_FL_nextthink, gametime + SEQUOIA_BEAM_THINK_PERIOD)
    }
    else{

        remove_entity(ent_id)
    }
    return PLUGIN_CONTINUE;

}

public sequoia_kd(id){


    if ( sh_get_cooldown_flag(id)||Get_BitVar(user_is_keydown_mask,id)||(g_sequoia_attack_phase[id]!=none)) {
        
        if(!is_user_bot(id)){

            sh_sound_deny(id)
        }
        return
    }
    
    Assign_BitVar(user_is_keydown_mask,id, true_for_macro);

    sh_set_cooldown(id, cvar_val(float, pcvar_sequoia_base_cooldown))

    g_sequoia_current_aimed_at_player[id] = -1
    g_sequoia_attack_phase[id]++

    do_player_iteration(id)
    //sequoia_summon_beam(id)
    
}

public sequoia_ku(id){



    Assign_BitVar(user_is_keydown_mask,id, false_for_macro);
    g_sequoia_current_aimed_at_player[id] = -1
    g_sequoia_attack_phase[id] = none
    
}

public sh_round_end(){

    arrayset(g_sequoia_attack_phase,none,sizeof(g_sequoia_attack_phase))
    arrayset(g_sequoia_current_aimed_at_player,-1,sizeof(g_sequoia_current_aimed_at_player))

    user_is_keydown_mask = 0
    
    remove_entity_name(SEQUOIA_BEAM_TERMINAL_ENT_CLASS)

}

public sh_round_new(){


    arrayset(g_sequoia_attack_phase,none,sizeof(g_sequoia_attack_phase))

    arrayset(g_sequoia_current_aimed_at_player,-1,sizeof(g_sequoia_current_aimed_at_player))
    user_is_keydown_mask = 0
    remove_entity_name(SEQUOIA_BEAM_TERMINAL_ENT_CLASS) 

}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
    if(sh_is_active()){
        if ( sh_get_user_has_hero(id,gHeroID) ) {
            
            Assign_BitVar(user_is_keydown_mask,id,false_for_macro);
            g_sequoia_current_aimed_at_player[id] = -1
            g_sequoia_attack_phase[id] = none
        }
	}
	
}
//----------------------------------------------------------------------------------------------
public sh_client_death(id)
{	
    if(sh_is_active()){
        if ( sh_get_user_has_hero(id,gHeroID) ) {
            

            Assign_BitVar(user_is_keydown_mask,id,false_for_macro);
            g_sequoia_current_aimed_at_player[id] = -1
            g_sequoia_attack_phase[id] = none
        }
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

    if((user_hp >= SEQUOIA_HEALTHCAP_INT_VERSION) && ( damage > SEQUOIA_HEALTHCAP_INT_VERSION) ){
            sh_chat_message(victim,gHeroID,"We blocked an instant kill! The damage received would have been: %0.2f",float(damage))
            if(!sh_get_id_bit(victim,SH_IS_SHOCKED)){
                sh_shock_user(victim,attacker)
            }
            the_return_value = DMG_FWD_BLOCK
    }

    return the_return_value
}