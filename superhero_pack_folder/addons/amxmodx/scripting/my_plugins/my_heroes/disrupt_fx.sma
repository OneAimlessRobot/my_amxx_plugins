#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "disrupt_fx_inc/disrupt_fx.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


#define PLUGIN "Superhero disrupt fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new DISRUPT_TASKID
new DISORIENT_TASKID
new gIsDisruptedMask = 0
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	DISRUPT_TASKID=allocate_typed_task_id(player_task)
	DISORIENT_TASKID=allocate_typed_task_id(player_task)
	register_event("DeathMsg","on_death_disrupted","a")
	register_event("ResetHUD","disrupt_newRound","b")
	init_explosion_defaults()

}

//----------------------------------------------------------------------------------------------
public disrupt_newRound(id)
{	
	undisrupt_user(id)
	
}

public plugin_natives(){
	
	
	register_native("sh_disrupt_user","_sh_disrupt_user",0);
	register_native("sh_undisrupt_user","_sh_undisrupt_user",0);
	register_native("sh_get_user_is_disrupted","_sh_get_user_is_disrupted",0);
}
public disorient_user(array[1],id)
{
	id-=DISORIENT_TASKID
	new Float:xAngles[3]
	new Float:xMoveDir[3]
	entity_set_int( id, EV_INT_fixangle, 0 );
	entity_get_vector(id, EV_VEC_angles, xAngles)
	entity_get_vector(id, EV_VEC_velocity, xMoveDir)
	new Float:velocity=vector_length(xMoveDir)
	xAngles[0]-=generate_float(-DISRUPT_AIM_RANDOMNESS,DISRUPT_AIM_RANDOMNESS)
	xAngles[1]-=generate_float(-DISRUPT_AIM_RANDOMNESS,DISRUPT_AIM_RANDOMNESS)
	xMoveDir[0]=floatclamp(generate_float(-DISRUPT_MOVE_RANDOMNESS,DISRUPT_MOVE_RANDOMNESS)*xMoveDir[0],-floatmul(velocity,floatsqroot(2.0)/2.0),floatmul(velocity,floatsqroot(2.0)/2.0))
	xMoveDir[1]=floatclamp(generate_float(-DISRUPT_MOVE_RANDOMNESS,DISRUPT_MOVE_RANDOMNESS)*xMoveDir[1],-floatmul(velocity,floatsqroot(2.0)/2.0),floatmul(velocity,floatsqroot(2.0)/2.0))
	entity_set_vector(id, EV_VEC_velocity, xMoveDir)
	entity_set_vector(id, EV_VEC_angles, xAngles)
	entity_set_int( id, EV_INT_fixangle, 1);
	if(array[0]<=DISORIENT_TIMES){
		array[0]++
		set_task(DISORIENT_PERIOD,"disorient_user",id+DISORIENT_TASKID,array, sizeof(array))
	}
	return PLUGIN_CONTINUE
}
public _sh_get_user_is_disrupted(iPlugin,iParams){
	new id= get_param(1);
	return Get_BitVar(gIsDisruptedMask,id)
}
public _sh_disrupt_user(iPlugin,iParams){
	
	new user=get_param(1)
	if(!Get_BitVar(gIsDisruptedMask,user)){
		new attacker=get_param(2)
		new gHeroID=get_param(3)
		new attacker_name[128]
		get_user_name(attacker,attacker_name,127)
		new user_name[128]
		get_user_name(user,user_name,127)
		if((user==attacker)){
			if(CAN_SELF_DISRUPT&&user){
				
				if(!is_user_bot(user)){
					sh_chat_message(user,gHeroID,"%s has disrupted you!!!",attacker_name)
				}
				
				if(!is_user_bot(attacker)){
					sh_chat_message(attacker,gHeroID,"You disrupted %s!!!",user_name)
				}
				disrupt_user(user)
			}
		}
		else{

			if(!is_user_bot(user)){
				sh_chat_message(user,gHeroID,"%s has disrupted you!!!",attacker_name)
			}
			
			if(!is_user_bot(attacker)){
				sh_chat_message(attacker,gHeroID,"You disrupted %s!!!",user_name)
			}
			disrupt_user(user)
		}
	}
	
	
	
}

public _sh_undisrupt_user(iPlugin,iParams){
	
	new user=get_param(1)
	undisrupt_user(user)
	
	
	
	
}
public disrupt_task(array[1],id){
	id-=DISRUPT_TASKID
	
	if(!sh_is_active()||!is_user_alive(id)){
		
		undisrupt_user(id)
		return
	}
	sh_set_rendering(id, disrupt_color[0], disrupt_color[1], disrupt_color[2], disrupt_color[3],kRenderFxGlowShell, kRenderTransColor)
	remove_glow_user(id,DISRUPT_PERIOD)
	
	if(Get_BitVar(gIsDisruptedMask,id)&&(array[0]<=DISRUPT_TIMES)){
		array[0]++
		set_task(DISRUPT_PERIOD,"disrupt_task",id+DISRUPT_TASKID,array, sizeof(array))
	}
	else{

		undisrupt_user(id)
	}
	
}
disrupt_user(id){
	if(!sh_is_active()||!is_user_alive(id)) return
	new array[1]
	array[0] = 0
	sh_screen_shake(id,10.0,floatmul(DISRUPT_PERIOD,float(DISRUPT_TIMES)),10.0)
	sh_set_stun(id,floatmul(DISRUPT_PERIOD,float(DISRUPT_TIMES)),default_stun_speed)
	Set_BitVar(gIsDisruptedMask,id)
	set_damage_icon(id,2,DMG_ICON_SHOCK,LineColors[LTBLUE])
	set_task(DISRUPT_PERIOD,"disrupt_task",id+DISRUPT_TASKID,array, sizeof(array))
	set_task(DISORIENT_PERIOD,"disorient_user",id+DISORIENT_TASKID,array, sizeof(array))
	
	
	
}
public undisrupt_user(id){
	
	if(!sh_is_active()||!is_user_connected(id)) return

	if(Get_BitVar(gIsDisruptedMask,id)){
		sh_set_rendering(id)
		UnSet_BitVar(gIsDisruptedMask,id)
		set_damage_icon(id,0,DMG_ICON_SHOCK)
		entity_set_int( id, EV_INT_fixangle, 0 );
	}
	
	
}

public on_death_disrupted()
{	
	new id = read_data(2)
	undisrupt_user(id)
	
}