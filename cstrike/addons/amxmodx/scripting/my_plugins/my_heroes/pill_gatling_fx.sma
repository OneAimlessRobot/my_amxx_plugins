#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"


#define PLUGIN "Superhero yakui pt1"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);


}

public plugin_natives(){


	register_native("sh_effect_user","_sh_effect_user",0);
	register_native("sh_uneffect_user","_sh_uneffect_user",0);
	


}
get_fx_num(){

	new Float:chance=random_float(0.0,1.0)
	if(chance<0.01){
	
		return 1;
	
	}
	if(chance< 0.38){
	
		return 2;
	
	}
	if(chance< 0.46){
	
		return 3;
	
	}
	if(chance< 0.50){
	
		return 4;
	
	}
	if(chance< 0.58){
	
		return 5;
	
	}
	if(chance< 0.64){
	
		return 6;
	
	}
	if(chance< 0.71){
	
		return 7;
	
	}
	if(chance< 0.79){
	
		return 8;
	
	}
	if(chance< 0.85){
	
		return 9;
	
	}
	
	return 10




}
public _sh_effect_user(iPlugin,iParams){

	new fx_num=get_fx_num()
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	if(user==attacker){
	
		
		sh_chat_message(attacker,gHeroID,"Hehe...")
	
	}
	switch(fx_num){
		case 1:{
		
			sh_chat_message(attacker,gHeroID,"Here is your kill bro!")
			kill_user(user,attacker)
			
		
		
		}
		case 2:{
		
			sh_chat_message(attacker,gHeroID,"Here is your glow bro!")
			glow_user(user)
		
		
		}
		case 3:{
		
		
			sh_chat_message(attacker,gHeroID,"Here is your stun bro!")
			stun_user(user)
		
		}
		case 4:{
		
		
			sh_chat_message(attacker,gHeroID,"Here is your crack bro!")
			poison_user(user,attacker)
		
		}
		case 5:{
		
		
			sh_chat_message(attacker,gHeroID,"Here is your radioactive bro!")
			radioactive_user(user,attacker)
		
		}
		case 6:{
		
		
			sh_chat_message(attacker,gHeroID,"Here is your morphine bro!")
			morphine_user(user)
		
		}
		case 7:{
		
		
			sh_chat_message(attacker,gHeroID,"Here is your weed bro!")
			weed_user(user)
		
		}
		case 8:{
		
		
			sh_chat_message(attacker,gHeroID,"Here is your cocaine bro!")
			cocaine_user(user)
		
		}
		case 9:{
		
		
			sh_chat_message(attacker,gHeroID,"Here is your blindness bro!")
			blind_user(user)
		
		}
		default:{
		
			sh_chat_message(attacker,gHeroID,"No fx was applied bro sorry")
			return 0;
		
		}
	
	
	
	
	}
	return fx_num;




}



public _sh_uneffect_user(iPlugin,iParams){

	new user=get_param(1)
	new fx_num=get_param(2)
	new gHeroID=get_param(3)
	switch(fx_num){
		
		case 2:{
		
			sh_chat_message(user,gHeroID,"Removed ur glow bro!")
			unglow_user(user)
		
		
		}
		case 3:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur stun bro!")
			unstun_user(user)
		
		}
		case 4:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur poisan!")
			unpoison_user(user)
		
		}
		case 5:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur chernobyl!")
			unradioactive_user(user)
		
		}
		case 7:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur weed!")
			unweed_user(user)
		
		}
		case 8:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur 80s!")
			uncocaine_user(user)
		
		}
		case 9:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur blindess!")
			unblind_user(user)
		
		}
		default:{
		
			sh_chat_message(user,gHeroID,"No fx was removed sorry")
			return 0;
		
		}
	
	
	
	
	}
	
	return fx_num;




}
kill_user(id,attacker){
	
	
	sh_extra_damage(id,attacker,1,"Cyanide Pill",0,SH_DMG_KILL)
	return 0


}

glow_user(id){
	
	sh_set_rendering(id, 100, 8, 100, 255,kRenderFxGlowShell, kRenderTransAlpha)
	return 0


}
stun_user(id){

	
	sh_set_stun(id, STUN_PERIOD, STUN_SPEED)
	sh_screen_shake(id, 16.0, (STUN_PERIOD), 2.0)
	return 0



}
public poison_task(array[],id){
	id-=POISON_TASKID

	sh_set_rendering(id, 80, 240, 100, 255,kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, 80, 240, 100, 50)
	sh_extra_damage(id,array[0],POISON_DAMAGE,"Crack pill",0,SH_DMG_NORM)
	
	


}

poison_user(id,attacker){
	new array[1]
	array[0] = attacker
	set_task(POISON_PERIOD,"poison_task",id+POISON_TASKID,array, sizeof(array),  "a",POISON_TIMES)
	return 0



}
unpoison_user(id){
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+POISON_TASKID)
	return 0



}

unglow_user(id){
	
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	return 0


}
unstun_user(id){

	sh_set_stun(id,0.0,1.0)
	sh_screen_shake(id,0.0,0.0,0.0)
	return 0



}


public radioactive_task(array[],id){
	id-=RADIOACTIVE_TASKID
	new hud_msg[128]
	new client_name[128]
	new distance, origin[3], eorigin[3]
	get_user_name(id,client_name,127)
	get_user_origin(array[0], origin)
	
	get_user_origin(id, eorigin)
			
	distance = get_distance(eorigin, origin)
	format(hud_msg,127,"%s.^nDistance: %d",client_name,distance);
		
	set_hudmessage(80, 240, 100, 0.0, 0.2, 0, 0.0, 1.0)
	ShowSyncHudMsg(array[0],array[1], "%s", hud_msg)
	sh_set_rendering(id, 240, 80, 30, 255,kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, 240, 80, 30, 50)
	radioactive_aura(id)
	sh_extra_damage(id,array[0],RADIOACTIVE_DAMAGE,"Uranium Pill",0,SH_DMG_NORM)
	
	

}

radioactive_user(id,attacker){
	new array[2]
	array[0] = attacker
	array[1] = CreateHudSyncObj()
	set_task(RADIOACTIVE_PERIOD,"radioactive_task",id+RADIOACTIVE_TASKID,array, sizeof(array),  "a",RADIOACTIVE_TIMES)
	return 0



}

unradioactive_user(id){
	
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+RADIOACTIVE_TASKID)
	return 0



}


radioactive_aura(id){

	new origin[3]

	get_user_origin(id, origin, 1)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(15)
	write_byte(240)			// r, g, b
	write_byte(80)		// r, g, b
	write_byte(30)			// r, g, b
	write_byte(3)			// life
	write_byte(1)			// decay
	message_end()

}

public blind_task(id){
	id-=BLIND_TASKID
	sh_screen_fade(id, 0.1, BLIND_PERIOD, 255, 255, 255, 255)
	return 0

}
blind_user(id){
	
	set_task(BLIND_PERIOD,"blind_task",id+BLIND_TASKID,"", 0,  "a",BLIND_TIMES)
	return 0

}
unblind_user(id){
	
	remove_task(id+BLIND_TASKID)
	return 0

}
morphine_user(id){
	
	sh_add_hp(id,MORPHINE_HP_ADD,sh_get_max_hp(id))
	return 0

}
public weed_task(id){
	id-=WEED_TASKID
	sh_set_rendering(id, 80, 240, 30, 255,kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, WEED_PERIOD, 80, 240, 30, 50)
	set_user_gravity(id,WEED_GRAVITY)
	return 0

}
weed_user(id){
	
	set_task(WEED_PERIOD,"weed_task",id+WEED_TASKID,"", 0,  "a",WEED_TIMES)
	return 0

}
unweed_user(id){
	
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+WEED_TASKID)
	sh_reset_min_gravity(id)
	return 0

}
public cocaine_task(id){
	id-=COCAINE_TASKID
	sh_set_rendering(id, 250, 10, 30, 255,kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, COCAINE_PERIOD, 250, 10, 30, 50)
	set_user_maxspeed(id,COCAINE_SPEED)
	return 0

}
cocaine_user(id){
	
	set_task(COCAINE_PERIOD,"cocaine_task",id+COCAINE_TASKID,"", 0,  "a",COCAINE_TIMES)
	return 0

}
uncocaine_user(id){
	
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+COCAINE_TASKID)
	sh_reset_max_speed(id)
	return 0

}
