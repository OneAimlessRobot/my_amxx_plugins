#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero yakui pt2 pt1"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


const fPainShock = 108


new gLastWeapon[SH_MAXSLOTS+1]
new gLastClipCount[SH_MAXSLOTS+1]
new m_spriteTexture
public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
new wpnName[32]
for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
{
	if ( !(NO_RECOIL_WEAPONS_BITSUM & (1<<wpnId)) && get_weaponname(wpnId, wpnName, charsmax(wpnName)) )
	{
			RegisterHam(Ham_Weapon_PrimaryAttack, wpnName, "Ham_Weapon_PrimaryAttack_Post", 1,true) 
	}
}

RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", 1,true) 
register_event("Damage", "crack_damage", "b", "2!0")
register_event("CurWeapon", "fire_weapon", "be", "1=1", "3>0")
}
public plugin_precache(){


	m_spriteTexture = precache_model("sprites/laserbeam.spr")
	precache_explosion_fx()

}
public plugin_natives(){


	register_native("sh_effect_user","_sh_effect_user",0);
	register_native("sh_gen_effect","_get_fx_num",0);
	register_native("sh_effect_user_direct","_sh_effect_user_direct",0);
	register_native("sh_uneffect_user","_sh_uneffect_user",0);
	register_native("sh_get_fx_color_name","_sh_get_fx_color_name",0);
}


public crack_damage(id)
{
	if ( !shModActive() || !is_user_alive(id)||!is_user_connected(id)) return
	
	new  Float:damage= float(read_data(2))
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	if ( attacker <= 0 || attacker > SH_MAXSLOTS ||!(gatling_get_fx_num(id)==POISON)) return
	
	
	new Float:extraDamage = damage * POISON_DMG_MULT - damage
	if (floatround(extraDamage)>0){
		shExtraDamage(id, attacker, floatround(extraDamage), "Crackhead rage", headshot)
			
	}
}

public fire_weapon(id)
{
	
	if (!is_user_connected(id)||!is_user_alive(id)||!(gatling_get_fx_num(id)==POISON)) return PLUGIN_CONTINUE 
	new wpnid = read_data(2)		// id of the weapon 
	new ammo = read_data(3)		// ammo left in clip 
	
	if (gLastWeapon[id] == 0) gLastWeapon[id] = wpnid
	
	if ((gLastClipCount[id] > ammo)&&(gLastWeapon[id] == wpnid)) 
	{
		new vec1[3], vec2[3]
		get_user_origin(id, vec1, 1) // origin; your camera point.
		get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)
		
		
		//BEAMENTPOINTS
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte (0)     //TE_BEAMENTPOINTS 0
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2])
		write_coord(vec2[0])
		write_coord(vec2[1])
		write_coord(vec2[2])
		write_short( m_spriteTexture )
		write_byte(1) // framestart
		write_byte(5) // framerate
		write_byte(2) // life
		write_byte(10) // width
		write_byte(0) // noise
		write_byte( poison_color[0] )     // r, g, b
		write_byte( poison_color[1] )       // r, g, b
		write_byte( poison_color[2])
		write_byte(255) // brightness
		write_byte(300) // speed
		message_end()
	}
	gLastClipCount[id] = ammo
	gLastWeapon[id]=wpnid;
	return PLUGIN_CONTINUE 
	
}

//----------------------------------------------------------------------------------------------
public Ham_Weapon_PrimaryAttack_Post(weapon_ent)
{
	if ( !sh_is_active() ) return HAM_IGNORED

	new owner = get_pdata_cbase(weapon_ent, m_pPlayer, XO_WEAPON)
	if(!client_hittable(owner)){
		return HAM_IGNORED
	}
	if ( gatling_get_fx_num(owner)==METYLPHENIDATE) {
		set_pev(owner, pev_punchangle, {0.0, 0.0, 0.0})
	}

	return HAM_IGNORED
}
public Player_TakeDamage(id)
{
 if ( !shModActive() || !is_user_alive(id) || !( gatling_get_fx_num(id)==BATH)) return
 
 set_pdata_float(id, fPainShock, 1.0, 5)
} 

public _sh_get_fx_color_name(iPlugins,iParams){
	
	new fx_num=get_param(1)
	switch(fx_num){
	
		case KILL:{
			
			set_array(2,kill_color,4)
			set_array(3,"cyanide",128)
		
		
		}
		case GLOW:{
		
			set_array(2,stun_color,4)
			set_array(3,"glowstick juice",128)
		
		
		}
		case STUN:{
		
		
			set_array(2,stun_color,4)
			set_array(3,"stunner",128)
		
		}
		case POISON:{
		
		
			set_array(2,poison_color,4)
			set_array(3,"poison",128)
		
		}
		case RADIOACTIVE:{
		
		
			set_array(2,radioactive_color,4)
			set_array(3,"uranium",128)
		
		}
		case MORPHINE:{
		
		
			set_array(2,morphine_color,4)
			set_array(3,"morphine",128)
		
		}
		case WEED:{
		
		
			set_array(2,weed_color,4)
			set_array(3,"weed",128)
		
		}
		case COCAINE:{
		
		
			set_array(2,cocaine_color,4)
			set_array(3,"cocaine",128)
		
		}
		case BLIND:{
		
		
			set_array(2,blind_color,4)
			set_array(3,"blindness",128)
		
		}
		case METYLPHENIDATE:{
		
		
			set_array(2,focus_color,4)
			set_array(3,"metylphenidate",128)
		
		}
		case BATH:{
		
		
			set_array(2,bath_color,4)
			set_array(3,"bath salts",128)
		
		}
		default:{
		
			
			set_array(2,no_color,4)
			set_array(3,"no drug",128)
		}
	
	
	
	
	}



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
	if(chance< 0.95){
	
		return BATH;
	
	}
	return BATH +1
	
	//return RADIOACTIVE




}
public _sh_effect_user_direct(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new fx_num=get_param(3)
	new gHeroID=get_param(4)
	if(user==attacker){
	
		
		sh_chat_message(attacker,gHeroID,"Hehe...")
	
	}
	switch(fx_num){
		case KILL:{
			if(user==attacker){
				new attacker_name[128]
				get_user_name(attacker,attacker_name,127)
				sh_chat_message(0,gHeroID,"%s: Dont worry guys! Momma Yakui has everything under control... what doesnt kill me can only... *thud*",attacker_name)
			
			}
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
		case BATH:{
		
		
			bath_user(user)
		
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
	sh_effect_user_direct(user,attacker,fx_num,gHeroID)
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
		case BATH:{
		
		
			sh_chat_message(user,gHeroID,"Removed ur spicy college pills!")
			unbath_user(user)
		
		}
		default:{
		
			return 0;
		
		}
	
	
	
	
	}
	gatling_set_fx_num(user,0)
	return fx_num;




}
kill_user(id,attacker){
	
	
	sh_screen_fade(id, 0.1, 0.9, kill_color[0], kill_color[1], kill_color[2], 50)
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
	gatling_set_fx_num(id,0)
	return 0



}

unpoison_user(id){
	remove_task(id+UNPOISON_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+POISON_TASKID)
	gatling_set_fx_num(id,0)
	return 0



}
unstun_user(id){

	sh_screen_fade(id, 0.1, 0.9, stun_color[0], stun_color[1], stun_color[2],  50)
	sh_set_stun(id,0.0,1.0)
	sh_screen_shake(id,0.0,0.0,0.0)
	return 0



}

radioactive_user(id,attacker){
	new players[SH_MAXSLOTS]
	new team_name[32]
	new client_name[128]
	new team_mate_name[128]
	new enemy_name[128]
	new player_count;
	
	get_user_name(id,enemy_name,127)
	get_user_name(attacker,client_name,127)
	
	get_user_team(attacker,team_name,32)
	get_players(players,player_count,"ea",team_name)
	
	for(new i=0;i<player_count;i++){
		
		get_user_name(players[i],team_mate_name,127)
		sh_chat_message(players[i],gatling_get_hero_id(),"Your yakui using teamate %s has revealed %s's position in the radar!",client_name,enemy_name)
		sh_chat_message(attacker,gatling_get_hero_id(),"%s knows!!!",team_mate_name)
	
	}
	new array[3+33]
	array[0] = attacker
	array[1] = CreateHudSyncObj()
	array[2] = player_count
	for(new i=0;i<player_count;i++){
	
		array[3+i]=players[i]
	}
	set_task(RADIOACTIVE_PERIOD,"radioactive_task",id+RADIOACTIVE_TASKID,array, sizeof(array),  "a",RADIOACTIVE_TIMES)
	set_task(floatsub(floatmul(RADIOACTIVE_PERIOD,float(RADIOACTIVE_TIMES)),0.1),"unradioactive_task",id+UNRADIOACTIVE_TASKID,"", 0,  "a",1)
	return 0



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
	remove_task(id+WEED_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	sh_reset_min_gravity(id)
	return 0

}
public unweed_task(id){
	id-=UNWEED_TASKID
	remove_task(id+WEED_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
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
	remove_task(id+COCAINE_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	sh_reset_max_speed(id)
	return 0

}
public uncocaine_task(id){
	id-=UNCOCAINE_TASKID
	remove_task(id+COCAINE_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
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
	gatling_set_fx_num(id,BATH+1)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+FOCUS_TASKID)
	return 0

}

unfocus_user(id){
	remove_task(id+UNFOCUS_TASKID)
	gatling_set_fx_num(id,BATH+1)
	remove_task(id+FOCUS_TASKID)
	return 0

}
bath_user(id){

	set_task(BATH_PERIOD,"bath_task",id+BATH_TASKID,"", 0,  "a",BATH_TIMES)
	set_task(floatsub(floatmul(BATH_PERIOD,float(BATH_TIMES)),0.1),"unbath_task",id+UNBATH_TASKID,"", 0,  "a",1)
	return 0

}
public bath_task(id){
	id-=BATH_TASKID
	sh_set_rendering(id, bath_color[0],bath_color[1], bath_color[2], bath_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, BATH_PERIOD, bath_color[0],bath_color[1], bath_color[2], 50)
	return 0

}

public unbath_task(id){
	id-=UNBATH_TASKID
	gatling_set_fx_num(id,BATH+1)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+BATH_TASKID)
	return 0

}

unbath_user(id){
	remove_task(id+UNBATH_TASKID)
	gatling_set_fx_num(id,BATH+1)
	remove_task(id+BATH_TASKID)
	return 0

}
