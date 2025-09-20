#include "superheromod.inc"
#include "sh_gatling_special_fx.inc"
#include "sh_gatling_funcs.inc"


#define PLUGIN "Superhero yakui pt1"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
new wpnName[32]
for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
{
	if ( !(NO_RECOIL_WEAPONS_BITSUM & (1<<wpnId)) && get_weaponname(wpnId, wpnName, charsmax(wpnName)) )
	{
			RegisterHam(Ham_Weapon_PrimaryAttack, wpnName, "Ham_Weapon_PrimaryAttack_Post", 1)
	}
}

}

public plugin_natives(){


	register_native("sh_effect_user","_sh_effect_user",0);
	register_native("sh_gen_effect","_get_fx_num",0);
	register_native("sh_effect_user_direct","_sh_effect_user_direct",0);
	register_native("sh_uneffect_user","_sh_uneffect_user",0);
	register_native("sh_get_pill_color","_sh_get_pill_color",0);
}


//----------------------------------------------------------------------------------------------
public Ham_Weapon_PrimaryAttack_Post(weapon_ent)
{
	if ( !sh_is_active() ) return HAM_IGNORED

	new owner = get_pdata_cbase(weapon_ent, m_pPlayer, XO_WEAPON)

	if ( gatling_get_fx_num(owner)==METYLPHENIDATE) {
		set_pev(owner, pev_punchangle, {0.0, 0.0, 0.0})
	}

	return HAM_IGNORED
}
public _get_fx_num(iPlugin,iParams){

	new Float:chance=random_float(0.0,1.0)
	if(chance<0.01){
	
		return KILL;
	
	}
	if(chance< 0.38){
	
		return GLOW;
	
	}
	if(chance< 0.46){
	
		return STUN;
	
	}
	if(chance< 0.50){
	
		return POISON;
	
	}
	if(chance< 0.58){
	
		return RADIOACTIVE;
	
	}
	if(chance< 0.64){
	
		return MORPHINE;
	
	}
	if(chance< 0.71){
	
		return WEED;
	
	}
	if(chance< 0.79){
	
		return COCAINE;
	
	}
	if(chance< 0.85){
	
		return BLIND;
	
	}
	if(chance< 0.90){
	
		return METYLPHENIDATE;
	
	}
	
	return METYLPHENIDATE +1




}public _sh_get_pill_color(iPlugin,iParams){

	new pillid=get_param(1)
	new attacker=get_param(2)
	new color[4];
	arrayset(color,0,3)
	color[3]=255
	switch(gatling_get_pill_fx_num(pillid)){
		case KILL:{
			sh_chat_message(attacker,gHeroID,"Here is your kill bro!")
			copy(color,4,kill_color)
			
		
		}
		case GLOW:{
			sh_chat_message(attacker,gHeroID,"Here is your glow bro!")
			copy(color,4,glow_color)
			
		
		}
		case STUN:{
			sh_chat_message(attacker,gHeroID,"Here is your stun bro!")
			copy(color,4,stun_color)
		
		
		}
		case POISON:{
			sh_chat_message(attacker,gHeroID,"Here is your crack bro!")
			copy(color,4,poison_color)
		
		
		
		}
		case RADIOACTIVE:{
			sh_chat_message(attacker,gHeroID,"Here is your radioactive bro!")
			copy(color,4,radioactive_color)
		
		
		
		}
		case MORPHINE:{
			sh_chat_message(attacker,gHeroID,"Here is your morphine bro!")
			copy(color,4,morphine_color)
		
		
		
		}
		case WEED:{
		
			sh_chat_message(attacker,gHeroID,"Here is your weed bro!")
			copy(color,4,weed_color)
		
		}
		case COCAINE:{
			sh_chat_message(attacker,gHeroID,"Here is your cocaine bro!")
			copy(color,4,cocaine_color)
		
		
		
		}
		case BLIND:{
			sh_chat_message(attacker,gHeroID,"Here is your blindness bro!")
			copy(color,4,blind_color)
		
		
		}
		case METYLPHENIDATE:{
			sh_chat_message(attacker,gHeroID,"Here is your college pills bro!")
			copy(color,4,focus_color)
		
		
		}
		default:{
			sh_chat_message(attacker,gHeroID,"No fx will be applied bro sorry")
			color[3]=0
		
		}
	

	
	}
	
	set_array(3,color,4)




}

public _sh_effect_user_direct(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	new fx_num=get_param(4)
	if(user==attacker){
	
		
		sh_chat_message(attacker,gHeroID,"Hehe...")
	
	}
	switch(fx_num){
		case KILL:{
		
			kill_user(user,attacker)
			
		
		
		}
		case GLOW:{
		
			glow_user(user)
		
		
		}
		case STUN:{
		
		
			stun_user(user)
		
		}
		case POISON:{
		
		
			poison_user(user,attacker)
		
		}
		case RADIOACTIVE:{
		
		
			radioactive_user(user,attacker)
		
		}
		case MORPHINE:{
		
		
			morphine_user(user)
		
		}
		case WEED:{
		
		
			weed_user(user)
		
		}
		case COCAINE:{
		
		
			cocaine_user(user)
		
		}
		case BLIND:{
		
		
			blind_user(user)
		
		}
		case METYLPHENIDATE:{
		
		
			focus_user(user)
		
		}
		default:{
		
			return 0;
		
		}
	
	
	
	
	}
	return fx_num;




}

public _sh_effect_user(iPlugin,iParams){

	new fx_num=sh_gen_effect()
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	sh_effect_user_direct(user,attacker,gHeroID,fx_num)
	return fx_num;




}



public _sh_uneffect_user(iPlugin,iParams){

	new user=get_param(1)
	new fx_num=get_param(2)
	new gHeroID=get_param(3)
	switch(fx_num){
		
		case GLOW:{
		
			sh_chat_message(user,gHeroID,"Removed ur glow bro!")
			unglow_user(user)
		
		
		}
		case STUN:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur stun bro!")
			unstun_user(user)
		
		}
		case POISON:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur poisan!")
			unpoison_user(user)
		
		}
		case RADIOACTIVE:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur chernobyl!")
			unradioactive_user(user)
		
		}
		case MORPHINE:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur heals!")
			unmorphine_user(user)
		
		}
		case WEED:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur weed!")
			unweed_user(user)
		
		}
		case COCAINE:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur 80s!")
			uncocaine_user(user)
		
		}
		case BLIND:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur blindess!")
			unblind_user(user)
		
		}
		case METYLPHENIDATE:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur college pills!")
			unfocus_user(user)
		
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


public glow_task(id){
	id-=GLOW_TASKID

	sh_set_rendering(id, glow_color[0], glow_color[1], glow_color[2], glow_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	aura(id,glow_color)
	
	


}

glow_user(id){
	set_task(GLOW_PERIOD,"glow_task",id+GLOW_TASKID,"", 0,  "a",GLOW_TIMES)
	set_task(floatsub(floatmul(GLOW_PERIOD,float(GLOW_TIMES)),0.1),"unglow_task",id+UNGLOW_TASKID,"", 0,  "a",1)
	return 0



}
public unglow_task(id){
	id-=UNGLOW_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+GLOW_TASKID)
	return 0



}

unglow_user(id){
	remove_task(id+UNGLOW_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+GLOW_TASKID)
	return 0



}
stun_user(id){

	
	sh_set_stun(id, STUN_PERIOD, STUN_SPEED)
	sh_screen_shake(id, 16.0, (STUN_PERIOD), 2.0)
	return 0



}
public poison_task(array[],id){
	id-=POISON_TASKID

	sh_set_rendering(id, poison_color[0], poison_color[1], poison_color[2], poison_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, poison_color[0], poison_color[1], poison_color[2], 50)
	sh_extra_damage(id,array[0],POISON_DAMAGE,"Crack pill",0,SH_DMG_NORM)
	
	


}

poison_user(id,attacker){
	new array[1]
	array[0] = attacker
	set_task(POISON_PERIOD,"poison_task",id+POISON_TASKID,array, sizeof(array),  "a",POISON_TIMES)
	set_task(floatsub(floatmul(POISON_PERIOD,float(POISON_TIMES)),0.1),"unpoison_task",id+UNPOISON_TASKID,"", 0,  "a",1)
	return 0



}
public unpoison_task(id){
	id-=UNPOISON_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+POISON_TASKID)
	return 0



}

unpoison_user(id){
	remove_task(id+UNPOISON_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+POISON_TASKID)
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
		
	set_hudmessage(240, 80, 30,  0.0, 0.2, 0, 0.0, 1.0)
	ShowSyncHudMsg(array[0],array[1], "%s", hud_msg)
	sh_set_rendering(id, radioactive_color[0],  radioactive_color[1], radioactive_color[2], radioactive_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, radioactive_color[0], radioactive_color[1], radioactive_color[2],  50)
	aura(id,radioactive_color)
	sh_extra_damage(id,array[0],RADIOACTIVE_DAMAGE,"Uranium Pill",0,SH_DMG_NORM)
	
	

}

radioactive_user(id,attacker){
	new array[2]
	array[0] = attacker
	array[1] = CreateHudSyncObj()
	set_task(RADIOACTIVE_PERIOD,"radioactive_task",id+RADIOACTIVE_TASKID,array, sizeof(array),  "a",RADIOACTIVE_TIMES)
	set_task(floatsub(floatmul(RADIOACTIVE_PERIOD,float(RADIOACTIVE_TIMES)),0.1),"unradioactive_task",id+UNRADIOACTIVE_TASKID,"", 0,  "a",1)
	return 0



}

unradioactive_user(id){
	
	remove_task(id+UNRADIOACTIVE_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+RADIOACTIVE_TASKID)
	return 0



}

public unradioactive_task(id){
	id-=UNRADIOACTIVE_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+RADIOACTIVE_TASKID)
	return 0



}


aura(id,const color[4]){

	new origin[3]

	get_user_origin(id, origin, 1)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(15)
	write_byte(color[0])			// r, g, b
	write_byte(color[1])		// r, g, b
	write_byte(color[2])			// r, g, b
	write_byte(3)			// life
	write_byte(1)			// decay
	message_end()

}

public blind_task(id){
	id-=BLIND_TASKID
	sh_screen_fade(id, 0.1, BLIND_PERIOD, blind_color[0], blind_color[1], blind_color[2], blind_color[3])
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

public morphine_task(id){
	id-=MORPHINE_TASKID
	sh_set_rendering(id,morphine_color[0], morphine_color[1], morphine_color[2], morphine_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, MORPHINE_PERIOD, morphine_color[0], morphine_color[1], morphine_color[2],  50)
	sh_add_hp(id,MORPHINE_HP_ADD,sh_get_max_hp(id))
	return 0

}
morphine_user(id){
	
	set_task(MORPHINE_PERIOD,"morphine_task",id+MORPHINE_TASKID,"", 0,  "a",MORPHINE_TIMES)
	set_task(floatsub(floatmul(MORPHINE_PERIOD,float(MORPHINE_TIMES)),0.1),"unmorphine_task",id+UNMORPHINE_TASKID,"", 0,  "a",1)
	return 0

}
public unmorphine_user(id){
	remove_task(id+UNMORPHINE_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+MORPHINE_TASKID)
	return 0

}
public unmorphine_task(id){
	id-=UNMORPHINE_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+MORPHINE_TASKID)
	return 0

}
public weed_task(id){
	id-=WEED_TASKID
	sh_set_rendering(id, weed_color[0],  weed_color[1],  weed_color[2],  weed_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, WEED_PERIOD, weed_color[0],  weed_color[1],  weed_color[2], 50)
	set_user_gravity(id,WEED_GRAVITY)
	return 0

}
weed_user(id){
	
	set_task(WEED_PERIOD,"weed_task",id+WEED_TASKID,"", 0,  "a",WEED_TIMES)
	set_task(floatsub(floatmul(WEED_PERIOD,float(WEED_TIMES)),0.1),"unweed_task",id+UNWEED_TASKID,"", 0,  "a",1)
	return 0

}
unweed_user(id){
	remove_task(id+UNWEED_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+WEED_TASKID)
	sh_reset_min_gravity(id)
	return 0

}
public unweed_task(id){
	id-=UNWEED_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+WEED_TASKID)
	sh_reset_min_gravity(id)
	return 0

}
public cocaine_task(id){
	id-=COCAINE_TASKID
	sh_set_rendering(id, cocaine_color[0], cocaine_color[1], cocaine_color[2], cocaine_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, COCAINE_PERIOD, cocaine_color[0], cocaine_color[1], cocaine_color[2], 50)
	set_user_maxspeed(id,COCAINE_SPEED)
	return 0

}
cocaine_user(id){
	
	set_task(COCAINE_PERIOD,"cocaine_task",id+COCAINE_TASKID,"", 0,  "a",COCAINE_TIMES)
	set_task(floatsub(floatmul(COCAINE_PERIOD,float(COCAINE_TIMES)),0.1),"uncocaine_task",id+UNCOCAINE_TASKID,"", 0,  "a",1)
	return 0

}
uncocaine_user(id){
	remove_task(id+UNCOCAINE_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+COCAINE_TASKID)
	sh_reset_max_speed(id)
	return 0

}
public uncocaine_task(id){
	id-=UNCOCAINE_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+COCAINE_TASKID)
	sh_reset_max_speed(id)
	return 0

}


focus_user(id){

	set_task(FOCUS_PERIOD,"focus_task",id+FOCUS_TASKID,"", 0,  "a",FOCUS_TIMES)
	set_task(floatsub(floatmul(FOCUS_PERIOD,float(FOCUS_TIMES)),0.1),"unfocus_task",id+UNFOCUS_TASKID,"", 0,  "a",1)
	return 0

}
public focus_task(id){
	id-=FOCUS_TASKID
	sh_set_rendering(id, focus_color[0], focus_color[1], focus_color[2], focus_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, FOCUS_PERIOD, focus_color[0], focus_color[1], focus_color[2], 50)
	return 0

}

public unfocus_task(id){
	id-=UNFOCUS_TASKID
	gatling_set_fx_num(id,METYLPHENIDATE+1)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+FOCUS_TASKID)
	return 0

}

unfocus_user(id){
	remove_task(id+UNFOCUS_TASKID)
	gatling_set_fx_num(id,METYLPHENIDATE+1)
	remove_task(id+FOCUS_TASKID)
	return 0

}
