#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include <fakemeta_util>
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "shinobu_knife/shinobu_general.inc"
#include "shinobu_knife/shinobu_knife_funcs.inc"

#define PLUGIN "Shinobu nani behind player pt1"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new TELEPORT_CHECK_TASKID

new g_shinobu_positions[SH_MAXSLOTS+1][3],
	g_shinobu_dst_positions[SH_MAXSLOTS+1][3]


new Float:g_shinobu_angles[SH_MAXSLOTS+1][3],
	Float:g_shinobu_dst_angles[SH_MAXSLOTS+1][3]


new Float:g_shinobu_v_angles[SH_MAXSLOTS+1][3],
	Float:g_shinobu_dst_v_angles[SH_MAXSLOTS+1][3]

enum{
	
	TELEPORT_TASK_TARGET,
	TELEPORT_TASK_NUM_INIT_ARGS	
}


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	TELEPORT_CHECK_TASKID=allocate_typed_task_id(player_task)
	register_event("DeathMsg","on_death_cleanup","a")
	register_event("ResetHUD","teleport_newRound","b")

    
	
}
				
public plugin_natives(){


	register_native("nani_behind_player","_nani_behind_player",0)
}


//----------------------------------------------------------------------------------------------
public teleport_newRound(id)
{
	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}

	if ( shinobu_get_has_shinobu(id)) {
		
		sh_end_cooldown(id+SH_COOLDOWN_TASKID)
		remove_task(id+TELEPORT_CHECK_TASKID)
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
shinobu_teleport(id,attacker)
{

	orient_user(attacker,g_shinobu_dst_angles[attacker],g_shinobu_dst_v_angles[attacker])
	set_user_origin(attacker,g_shinobu_dst_positions[attacker])
	
	ultimateTimer(attacker, shinobu_get_cooldown())

	positionChangeTimer(id,attacker)
	
	

}


//----------------------------------------------------------------------------------------------
positionChangeTimer(id,attacker)
{
	if ( !client_hittable(id)||!client_hittable(attacker) ) return

	new Float:velocity[3]
	Entvars_Get_Vector(attacker, EV_VEC_velocity, velocity)

	if ( velocity[0]==0.0 && velocity[1]==0.0 ) {
		// Force a Move (small jump)
		velocity[0] += 20.0
		velocity[2] += 100.0
		Entvars_Set_Vector(attacker, EV_VEC_velocity, velocity)
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

	if(!shinobu_get_has_shinobu(attacker)) return


	new tg=array[TELEPORT_TASK_TARGET]
	new origin[3]
	get_user_origin(attacker, origin)

	// Kill this player if Stuck in Wall!
	if ( g_shinobu_dst_positions[attacker][0] == origin[0] && g_shinobu_dst_positions[attacker][1] == origin[1] && g_shinobu_dst_positions[attacker][2] == origin[2]) {
		set_user_origin(attacker,g_shinobu_positions[attacker])
		orient_user(attacker,g_shinobu_angles[attacker],g_shinobu_v_angles[attacker])
		sh_chat_message(attacker,shinobu_get_hero_id(),"Finalizing teleport would have gotten you stuck! Aborting...")
		sh_end_cooldown(attacker+SH_COOLDOWN_TASKID)
		return
	}
	sh_chat_message(tg,shinobu_get_hero_id(),"%s",fwend_sentences[shinobu_fwend_sentence_id:random_num(0,_:MAX_SHINOBU_FWEND_SENTENCES-1)])	
	sh_chat_message(attacker,shinobu_get_hero_id(),"%s",fwend_sentences[shinobu_fwend_sentence_id:random_num(0,_:MAX_SHINOBU_FWEND_SENTENCES-1)])	
	Entvars_Set_Vector(attacker, EV_VEC_velocity, null_vector)
	shinobu_set_user_tagged_player(attacker,0)
}
//native nani_player_behind_player(tele_player,tg_player,Float: distance_tele_tg=SHINOBU_DEFAULT_TELE_DIST)
public _nani_behind_player(iPlugin,iParams){
	new tele_player= get_param(1),
	tg_player= get_param(2),
	Float:distance_tele_tg=get_param_f(3)

	if(!client_hittable(tele_player)||!client_hittable(tg_player)){

		return
	}
	if ( gPlayerUltimateUsed[tele_player] ) {
		if(!is_user_bot(tele_player)){
			playSoundDenySelect(tele_player)
			sh_chat_message(tele_player,shinobu_get_hero_id(),"Teleport canceled. Still on cooldown!");
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


public on_death_cleanup()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		if(shinobu_get_has_shinobu(id)){

			remove_task(id+TELEPORT_CHECK_TASKID)
		}
	}
	
}