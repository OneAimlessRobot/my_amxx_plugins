#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#define I_WANT_CONSTANTS
#include "../../include/float.inc"
#include <xs>
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "shinobu_knife/shinobu_general.inc"
#include "shinobu_knife/shinobu_knife_funcs.inc"
#include "shinobu_knife/shinobu_usp_funcs.inc"

#define PLUGIN "Shinobu knife funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new gHeroID = -1

new TELEPORT_CHECK_TASKID
new SHINOBU_GLOBAL_KNIFE_CLOAK_TASKID

//nums
new pcvar_shinobu_alpha

new g_shinobu_positions[SH_MAXSLOTS+1][3],
	g_shinobu_dst_positions[SH_MAXSLOTS+1][3]


new Float:g_shinobu_angles[SH_MAXSLOTS+1][3],
	Float:g_shinobu_dst_angles[SH_MAXSLOTS+1][3]


new Float:g_shinobu_v_angles[SH_MAXSLOTS+1][3],
	Float:g_shinobu_dst_v_angles[SH_MAXSLOTS+1][3]


new g_prev_shinobu_cloaked_mask=0,
 	g_curr_shinobu_cloaked_mask=0,
	g_shinobu_using_knife_mask = 0

enum{
	
	TELEPORT_TASK_TARGET,
	TELEPORT_TASK_NUM_INIT_ARGS	
}


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	TELEPORT_CHECK_TASKID = allocate_typed_task_id(player_task)
	SHINOBU_GLOBAL_KNIFE_CLOAK_TASKID = allocate_typed_task_id(generic_task)

	pcvar_shinobu_alpha = create_cvar("shinobu_alpha","10")
	set_pcvar_bounds(pcvar_shinobu_alpha,CvarBound_Lower,true,0.0)
	set_pcvar_bounds(pcvar_shinobu_alpha,CvarBound_Upper,true,255.0)
	register_event("CurWeapon", "on_Knife_Weapon_Change", "be", "1=1")

    
	set_task(1.0,"shinobu_cloak_apply",SHINOBU_GLOBAL_KNIFE_CLOAK_TASKID,_,_,"b")
}
public plugin_cfg(){

	gHeroID = shinobu_get_hero_id()
}
public on_Knife_Weapon_Change(id)
{
	if ( !sh_is_active()) return
	if(!sh_get_user_has_hero(id,gHeroID)) return

	new wpnid = read_data(2)

	Assign_BitVar(g_shinobu_using_knife_mask, id, (wpnid == CSW_KNIFE))
}
public plugin_natives(){


	register_native("nani_behind_player","_nani_behind_player")
	register_native("uncloak_shinobu","_uncloak_shinobu")
}

public _uncloak_shinobu(id){

	new id= get_param(1)

	if ( !is_user_alive(id)||!sh_is_active()) return

	
	Assign_BitVar(g_curr_shinobu_cloaked_mask, id, false_for_macro);
	Assign_BitVar(g_prev_shinobu_cloaked_mask, id, true_for_macro);

	apply_cloak(id)
}
public shinobu_cloak_apply(task_id){


	if (! sh_is_active()) return
	new the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]
		if(sh_get_user_has_hero(id,gHeroID) ){


			Assign_BitVar(g_prev_shinobu_cloaked_mask, id, Get_BitVar(g_curr_shinobu_cloaked_mask, id));

			new button = entity_get_int(id, EV_INT_button)
			
			Assign_BitVar(g_curr_shinobu_cloaked_mask,id, ((button & IN_DUCK ))||Get_BitVar(g_shinobu_using_knife_mask, id))
	
			apply_cloak(id)
		}
	}
}
apply_cloak(id){
	
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)){
		
		Assign_BitVar(g_curr_shinobu_cloaked_mask,id,false_for_macro);
		Assign_BitVar(g_prev_shinobu_cloaked_mask,id,false_for_macro);
		return 

	}
	if(Get_BitVar(g_curr_shinobu_cloaked_mask,id)==Get_BitVar(g_prev_shinobu_cloaked_mask,id)){

		return
	}

	if(Get_BitVar(g_curr_shinobu_cloaked_mask,id)){
		
		sh_set_rendering(id,0,0,0,cvar_val(num, pcvar_shinobu_alpha),kRenderFxGlowShell,kRenderTransColor);

	}
	else{
		
		sh_set_rendering(id)
	}
}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}

	if ( sh_get_user_has_hero(id,gHeroID)) {
		
		sh_end_cooldown(id+SH_COOLDOWN_TASKID)
		remove_task(id+TELEPORT_CHECK_TASKID)
	}
}
//----------------------------------------------------------------------------------------------
shinobu_teleport(id,attacker)
{

	orient_user(attacker,g_shinobu_dst_angles[attacker],g_shinobu_dst_v_angles[attacker])
	set_user_origin(attacker,g_shinobu_dst_positions[attacker])
	
	sh_set_cooldown(attacker, shinobu_get_cooldown())

	positionChangeTimer(id,attacker)
	
	

}


//----------------------------------------------------------------------------------------------
positionChangeTimer(id,attacker)
{
	if ( !is_user_alive(id)||!is_user_alive(attacker) ) return

	new Float:velocity[3]
	entity_get_vector(attacker, EV_VEC_velocity, velocity)

	if ( velocity[0]==0.0 && velocity[1]==0.0 ) {
		// Force a Move (small jump)
		velocity[0] += 20.0
		velocity[2] += 100.0
		entity_set_vector(attacker, EV_VEC_velocity, velocity)
	}
	new parm[TELEPORT_TASK_NUM_INIT_ARGS]
	parm[TELEPORT_TASK_TARGET]=id
	set_task(0.4, "positionChangeCheck", attacker+TELEPORT_CHECK_TASKID,parm,sizeof parm)



}


//----------------------------------------------------------------------------------------------
public positionChangeCheck(array[], attacker)
{
	attacker -= TELEPORT_CHECK_TASKID

	if(!is_user_alive(attacker) ) return

	if(!sh_get_user_has_hero(attacker,gHeroID)) return


	new tg=array[TELEPORT_TASK_TARGET]
	new origin[3]
	get_user_origin(attacker, origin)

	// Kill this player if Stuck in Wall!
	if ( g_shinobu_dst_positions[attacker][0] == origin[0] && g_shinobu_dst_positions[attacker][1] == origin[1] && g_shinobu_dst_positions[attacker][2] == origin[2]) {
		set_user_origin(attacker,g_shinobu_positions[attacker])
		orient_user(attacker,g_shinobu_angles[attacker],g_shinobu_v_angles[attacker])
		sh_chat_message(attacker,gHeroID,"Finalizing teleport would have gotten you stuck! Aborting...")
		sh_end_cooldown(attacker+SH_COOLDOWN_TASKID)
		return
	}
	sh_chat_message(tg,gHeroID,"%s",fwend_sentences[shinobu_fwend_sentence_id:generate_int(0,sizeof(fwend_sentences)-1)])	
	sh_chat_message(attacker,gHeroID,"%s",fwend_sentences[shinobu_fwend_sentence_id:generate_int(0,sizeof(fwend_sentences)-1)])	
	entity_set_vector(attacker, EV_VEC_velocity, null_vector)
	shinobu_set_user_tagged_player(attacker,0)
}
//native nani_player_behind_player(tele_player,tg_player,Float: distance_tele_tg=SHINOBU_DEFAULT_TELE_DIST)
public _nani_behind_player(iPlugin,iParams){
	new tele_player= get_param(1),
	tg_player= get_param(2),
	Float:distance_tele_tg=get_param_f(3)

	if(!is_user_alive(tele_player)||!is_user_alive(tg_player)){

		return
	}
	if ( sh_get_cooldown_flag(tele_player) ) {
		if(!is_user_bot(tele_player)){
			sh_sound_deny(tele_player)
			sh_chat_message(tele_player,gHeroID,"Teleport canceled. Still on cooldown!");
		}
		return
	}

	arrayset(g_shinobu_dst_positions[tele_player],0,sizeof g_shinobu_dst_positions)
	arrayset(g_shinobu_positions[tele_player],0,sizeof g_shinobu_positions)

	arrayset(g_shinobu_dst_angles[tele_player],0.0,sizeof g_shinobu_dst_angles)
	arrayset(g_shinobu_angles[tele_player],0.0,sizeof g_shinobu_angles)

	arrayset(g_shinobu_dst_v_angles[tele_player],0.0,sizeof g_shinobu_dst_v_angles)
	arrayset(g_shinobu_v_angles[tele_player],0.0,sizeof g_shinobu_v_angles)

	new Float: tg_player_aiming[3];
	new Float:tg_player_curr_origin[3]

	new Float:tele_player_dst_origin[3]


	entity_get_vector(tg_player,EV_VEC_origin,tg_player_curr_origin)
	entity_get_vector(tg_player,EV_VEC_angles,g_shinobu_dst_angles[tele_player])
	entity_get_vector(tg_player,EV_VEC_v_angle,g_shinobu_dst_v_angles[tele_player])
	velocity_by_aim( tg_player,1, tg_player_aiming );


	xs_vec_normalize(tg_player_aiming,tg_player_aiming)

	entity_get_vector(tg_player,EV_VEC_origin,tg_player_curr_origin)


	xs_vec_add_scaled(tg_player_curr_origin,tg_player_aiming, -1.0*floatabs(distance_tele_tg),tele_player_dst_origin)

	FVecIVec(tele_player_dst_origin,g_shinobu_dst_positions[tele_player])
	
	g_shinobu_dst_positions[tele_player][2]+=4
	
	get_user_origin(tele_player,g_shinobu_positions[tele_player])

	entity_get_vector(tele_player,EV_VEC_angles,g_shinobu_angles[tele_player])
	
	entity_get_vector(tele_player,EV_VEC_v_angle,g_shinobu_v_angles[tele_player])

	shinobu_teleport(tg_player,tele_player)

}


public sh_client_death(id){
	
	if(is_user_connected(id)&&sh_is_active()){
		if(sh_get_user_has_hero(id,gHeroID)){

			remove_task(id+TELEPORT_CHECK_TASKID)
		}
	}
	
}