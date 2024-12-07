#include "../my_include/superheromod.inc"
#include "MINE_grenade_inc/sh_teliko_get_set.inc"
#include "MINE_grenade_inc/sh_MINE_fx.inc"


#define PLUGIN "Superhero MINE fx"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new g_msgFade

new bool:gIsMineed[SH_MAXSLOTS+1]
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	arrayset(gIsMined,false,SH_MAXSLOTS+1)
	
}

public plugin_natives(){
	
	
	register_native("sh_mine_user","_sh_mine_user",0);
	register_native("sh_unmine_user","_sh_unmine_user",0);
}
public _sh_mine_user(iPlugin,iParams){
	
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!gIsMineed[user]){
		if((user==attacker)){
			if(CAN_SELF_MINE){
				sh_chat_message(user,gHeroID,"%s has mined you!!!",attacker_name)
				sh_chat_message(attacker,gHeroID,"You mined %s!!!",user_name)
				mine_user(user,attacker)
			}
		}
		else{
			sh_chat_message(user,gHeroID,"%s has mined you!!!",attacker_name)
			sh_chat_message(attacker,gHeroID,"You mined %s!!!",user_name)
			mine_user(user,attacker)
		}
	}
	
	
	
}
public plugin_precache(){
	
}

public _sh_unMINE_user(iPlugin,iParams){
	
	new user=get_param(1)
	unMINE_user(user)
	
	
	
	
}
fade_screen_user(id){
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client" 
	write_short(1<<12); // fade lasts this long duration 
	write_short(0); // fade lasts this long hold time 
	write_short(FADE_HOLD); // fade type 
	write_byte( MINE_color[0] )
	write_byte( MINE_color[1] )
	write_byte( MINE_color[2] )
	write_byte( MINE_color[3 ]); // fade alpha  
	message_end(); 
	
}
unfade_screen_user(id){
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client"  
	write_short(1<<12); // fade lasts this long duration  
	write_short(1<<8); // fade lasts this long hold time  
	write_short(FADE_OUT); // fade type
	write_byte( MINE_color[0])
	write_byte( MINE_color[1] )
	write_byte( MINE_color[2] )
	write_byte( MINE_color[3] ) 
	message_end();	
	
}
public MINE_task(array[],id){
	id-=MINE_TASKID
	
	sh_set_rendering(id, MINE_color[0], MINE_color[1], MINE_color[2], MINE_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	
	
	
}
MINE_user(id,attacker){
	new array[1]
	array[0] = attacker
	fade_screen_user(id)
	new Float:maxspeed= get_user_maxspeed(id)
	sh_screen_shake(id,10.0,floatmul(MINE_PERIOD,float(MINE_TIMES)),10.0)
	sh_set_stun(id,floatmul(MINE_PERIOD,float(MINE_TIMES)),maxspeed)
	gIsMINEed[id]=true
	set_task(MINE_PERIOD,"MINE_task",id+MINE_TASKID,array, sizeof(array),  "a",MINE_TIMES)
	set_task(DISORIENT_PERIOD,"disorient_user",id+DISORIENT_TASKID,"", 0,  "a",DISORIENT_TIMES)
	set_task(floatsub(floatmul(MINE_PERIOD,float(MINE_TIMES)),0.1),"unMINE_task",id+UNMINE_TASKID,"", 0,  "a",1)
	return 0
	
	
	
}
public unMINE_task(id){
	id-=UNMINE_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+MINE_TASKID)
	unfade_screen_user(id)
	
	sh_set_stun(id,0.0)
	gIsMINEed[id]=false
	remove_task(id+DISORIENT_TASKID)
	entity_set_int( id, EV_INT_fixangle, 0 );
	return 0
	
	
	
}

unMINE_user(id){
	remove_task(id+UNMINE_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+MINE_TASKID)
	sh_set_stun(id,0.0)
	gIsMINEed[id]=false
	remove_task(id+DISORIENT_TASKID)
	entity_set_int( id, EV_INT_fixangle, 0 );
	return 0
	
	
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
