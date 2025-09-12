#include "../my_include/superheromod.inc"
#include "chaff_grenade_inc/sh_teliko_get_set.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"


#define PLUGIN "Superhero chaff fx"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new g_msgFade

new bool:gIsChaffed[SH_MAXSLOTS+1]
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	arrayset(gIsChaffed,false,SH_MAXSLOTS+1)
	g_msgFade = get_user_msgid("ScreenFade");
	
}

public plugin_natives(){
	
	
	register_native("sh_chaff_user","_sh_chaff_user",0);
	register_native("sh_unchaff_user","_sh_unchaff_user",0);
}
public disorient_user(id)
{
	id-=DISORIENT_TASKID
	new Float:xAngles[3]
	new Float:xMoveDir[3]
	entity_set_int( id, EV_INT_fixangle, 0 );
	entity_get_vector(id, EV_VEC_angles, xAngles)
	entity_get_vector(id, EV_VEC_velocity, xMoveDir)
	new Float:velocity=vector_length(xMoveDir)
	xAngles[0]-=random_float(-CHAFF_AIM_RANDOMNESS,CHAFF_AIM_RANDOMNESS)
	xAngles[1]-=random_float(-CHAFF_AIM_RANDOMNESS,CHAFF_AIM_RANDOMNESS)
	xMoveDir[0]=floatclamp(random_float(-CHAFF_MOVE_RANDOMNESS,CHAFF_MOVE_RANDOMNESS)*xMoveDir[0],-floatmul(velocity,floatsqroot(2.0)/2.0),floatmul(velocity,floatsqroot(2.0)/2.0))
	xMoveDir[1]=floatclamp(random_float(-CHAFF_MOVE_RANDOMNESS,CHAFF_MOVE_RANDOMNESS)*xMoveDir[1],-floatmul(velocity,floatsqroot(2.0)/2.0),floatmul(velocity,floatsqroot(2.0)/2.0))
	entity_set_vector(id, EV_VEC_velocity, xMoveDir)
	entity_set_vector(id, EV_VEC_angles, xAngles)
	entity_set_int( id, EV_INT_fixangle, 1);
	
	return PLUGIN_CONTINUE
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
				sh_chat_message(user,gHeroID,"%s has chaffed you!!!",attacker_name)
				sh_chat_message(attacker,gHeroID,"You chaffed %s!!!",user_name)
				chaff_user(user,attacker)
			}
		}
		else{
			sh_chat_message(user,gHeroID,"%s has chaffed you!!!",attacker_name)
			sh_chat_message(attacker,gHeroID,"You chaffed %s!!!",user_name)
			chaff_user(user,attacker)
		}
	}
	
	
	
}
public plugin_precache(){
	
}

public _sh_unchaff_user(iPlugin,iParams){
	
	new user=get_param(1)
	unchaff_user(user)
	
	
	
	
}
fade_screen_user(id){
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client" 
	write_short(1<<12); // fade lasts this long duration 
	write_short(0); // fade lasts this long hold time 
	write_short(FADE_HOLD); // fade type 
	write_byte( chaff_color[0] )
	write_byte( chaff_color[1] )
	write_byte( chaff_color[2] )
	write_byte( chaff_color[3 ]); // fade alpha  
	message_end(); 
	
}
unfade_screen_user(id){
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client"  
	write_short(1<<12); // fade lasts this long duration  
	write_short(1<<8); // fade lasts this long hold time  
	write_short(FADE_OUT); // fade type
	write_byte( chaff_color[0])
	write_byte( chaff_color[1] )
	write_byte( chaff_color[2] )
	write_byte( chaff_color[3] ) 
	message_end();	
	
}
public chaff_task(array[],id){
	id-=CHAFF_TASKID
	
	sh_set_rendering(id, chaff_color[0], chaff_color[1], chaff_color[2], chaff_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	
	
	
}
chaff_user(id,attacker){
	new array[1]
	array[0] = attacker
	fade_screen_user(id)
	new Float:maxspeed= get_user_maxspeed(id)
	sh_screen_shake(id,10.0,floatmul(CHAFF_PERIOD,float(CHAFF_TIMES)),10.0)
	sh_set_stun(id,floatmul(CHAFF_PERIOD,float(CHAFF_TIMES)),maxspeed)
	gIsChaffed[id]=true
	set_task(CHAFF_PERIOD,"chaff_task",id+CHAFF_TASKID,array, sizeof(array),  "a",CHAFF_TIMES)
	set_task(DISORIENT_PERIOD,"disorient_user",id+DISORIENT_TASKID,"", 0,  "a",DISORIENT_TIMES)
	set_task(floatsub(floatmul(CHAFF_PERIOD,float(CHAFF_TIMES)),0.1),"unchaff_task",id+UNCHAFF_TASKID,"", 0,  "a",1)
	return 0
	
	
	
}
public unchaff_task(id){
	id-=UNCHAFF_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+CHAFF_TASKID)
	unfade_screen_user(id)
	
	sh_set_stun(id,0.0)
	gIsChaffed[id]=false
	remove_task(id+DISORIENT_TASKID)
	entity_set_int( id, EV_INT_fixangle, 0 );
	return 0
	
	
	
}

unchaff_user(id){
	remove_task(id+UNCHAFF_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+CHAFF_TASKID)
	sh_set_stun(id,0.0)
	gIsChaffed[id]=false
	remove_task(id+DISORIENT_TASKID)
	entity_set_int( id, EV_INT_fixangle, 0 );
	return 0
	
	
	
}
