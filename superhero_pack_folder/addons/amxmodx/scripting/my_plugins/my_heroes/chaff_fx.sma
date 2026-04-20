#include "../my_include/superheromod.inc"
#include "chaff_grenade_inc/sh_teliko_get_set.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"


#define PLUGIN "Superhero chaff fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new CHAFF_TASKID
new DISORIENT_TASKID
new bool:gIsChaffed[SH_MAXSLOTS+1]
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	arrayset(gIsChaffed,false,SH_MAXSLOTS+1)
	CHAFF_TASKID=allocate_typed_task_id(player_task)
	DISORIENT_TASKID=allocate_typed_task_id(player_task)
	register_event("DeathMsg","on_death_chaffed","a")
	register_event("ResetHUD","chaff_newRound","b")
	init_explosion_defaults()

}

//----------------------------------------------------------------------------------------------
public chaff_newRound(id)
{	
	if(shModActive()&&client_hittable(id)){
		if(gIsChaffed[id]){
			sh_unchaff_user(id)
		}

	}
	
}

public plugin_natives(){
	
	
	register_native("sh_chaff_user","_sh_chaff_user",0);
	register_native("sh_unchaff_user","_sh_unchaff_user",0);
	register_native("sh_get_user_is_chaffed","_sh_get_user_is_chaffed",0);
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
	xAngles[0]-=generate_float(-CHAFF_AIM_RANDOMNESS,CHAFF_AIM_RANDOMNESS)
	xAngles[1]-=generate_float(-CHAFF_AIM_RANDOMNESS,CHAFF_AIM_RANDOMNESS)
	xMoveDir[0]=floatclamp(generate_float(-CHAFF_MOVE_RANDOMNESS,CHAFF_MOVE_RANDOMNESS)*xMoveDir[0],-floatmul(velocity,floatsqroot(2.0)/2.0),floatmul(velocity,floatsqroot(2.0)/2.0))
	xMoveDir[1]=floatclamp(generate_float(-CHAFF_MOVE_RANDOMNESS,CHAFF_MOVE_RANDOMNESS)*xMoveDir[1],-floatmul(velocity,floatsqroot(2.0)/2.0),floatmul(velocity,floatsqroot(2.0)/2.0))
	entity_set_vector(id, EV_VEC_velocity, xMoveDir)
	entity_set_vector(id, EV_VEC_angles, xAngles)
	entity_set_int( id, EV_INT_fixangle, 1);
	if(array[0]<=DISORIENT_TIMES){
		array[0]++
		set_task(DISORIENT_PERIOD,"disorient_user",id+DISORIENT_TASKID,array, sizeof(array),  "a",1)
	}
	return PLUGIN_CONTINUE
}
public _sh_get_user_is_chaffed(iPlugin,iParams){
	new id= get_param(1);
	return gIsChaffed[id]
}
public _sh_chaff_user(iPlugin,iParams){
	
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!gIsChaffed[user]){
		if((user==attacker)){
			if(CAN_SELF_CHAFF&&user){
				
				if(!is_user_bot(user)){
					sh_chat_message(user,gHeroID,"%s has chaffed you!!!",attacker_name)
				}
				
				if(!is_user_bot(attacker)){
					sh_chat_message(attacker,gHeroID,"You chaffed %s!!!",user_name)
				}
				chaff_user(user)
			}
		}
		else{

			if(!is_user_bot(user)){
				sh_chat_message(user,gHeroID,"%s has chaffed you!!!",attacker_name)
			}
			
			if(!is_user_bot(attacker)){
				sh_chat_message(attacker,gHeroID,"You chaffed %s!!!",user_name)
			}
			chaff_user(user)
		}
	}
	
	
	
}
public plugin_precache(){
	
}

public _sh_unchaff_user(iPlugin,iParams){
	
	new user=get_param(1)
	unchaff_user(user)
	
	
	
	
}
public chaff_task(array[1],id){
	id-=CHAFF_TASKID
	
	sh_set_rendering(id, chaff_color[0], chaff_color[1], chaff_color[2], chaff_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	
	if(array[0]<=CHAFF_TIMES){
		array[0]++
		set_task(CHAFF_PERIOD,"chaff_task",id+CHAFF_TASKID,array, sizeof(array),  "a",1)
	}
	else{

		callfunc_begin_i(get_func_id("unchaff_user"))
		callfunc_push_int(id)
		callfunc_end()
	}
	
}
chaff_user(id){
	if(!sh_is_active()||!client_hittable(id)) return
	new array[1]
	array[0] = 0
	sh_screen_shake(id,10.0,floatmul(CHAFF_PERIOD,float(CHAFF_TIMES)),10.0)
	sh_set_stun(id,floatmul(CHAFF_PERIOD,float(CHAFF_TIMES)),default_stun_speed)
	gIsChaffed[id]=true
	set_damage_icon(id,2,DMG_ICON_SHOCK,LineColors[LTBLUE])
	set_task(CHAFF_PERIOD,"chaff_task",id+CHAFF_TASKID,array, sizeof(array),  "a",1)
	set_task(DISORIENT_PERIOD,"disorient_user",id+DISORIENT_TASKID,array, sizeof(array), "a",1)
	
	
	
}
public unchaff_user(id){
	
	set_user_rendering(id)
	gIsChaffed[id]=false
	set_damage_icon(id,0,DMG_ICON_SHOCK)
	entity_set_int( id, EV_INT_fixangle, 0 );
	
	
	
}

public on_death_chaffed()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		sh_unchaff_user(id)
	
	}
	
}