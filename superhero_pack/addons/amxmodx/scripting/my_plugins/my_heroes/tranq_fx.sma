#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"


#define PLUGIN "Superhero tranq fx"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new g_msgFade

new bool:gIsAsleep[SH_MAXSLOTS+1]
public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
arrayset(gIsAsleep,false,SH_MAXSLOTS+1)
g_msgFade = get_user_msgid("ScreenFade");
new wpnName[32]
for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
{
	if ( get_weaponname(wpnId, wpnName, charsmax(wpnName)) )
	{
			RegisterHam(Ham_Weapon_PrimaryAttack, wpnName, "Ham_Weapon_PrimaryAttack_Post")
			RegisterHam(Ham_Weapon_SecondaryAttack, wpnName, "Ham_Weapon_PrimaryAttack_Post")
	}
}

}

public plugin_natives(){


	register_native("sh_sleep_user","_sh_sleep_user",0);
	register_native("sh_unsleep_user","_sh_unsleep_user",0);
}

public Ham_Weapon_PrimaryAttack_Post(weapon_ent)
{
	if ( !sh_is_active()||!is_valid_ent(weapon_ent) ) return HAM_IGNORED

	new owner = get_pdata_cbase(weapon_ent, m_pPlayer, XO_WEAPON)

	if ( gIsAsleep[owner]) {
		return HAM_SUPERCEDE
	}

	return HAM_IGNORED
}
public _sh_sleep_user(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!gIsAsleep[user]){
		if((user==attacker)){
			if(CAN_SELF_SLEEP){
				sh_chat_message(user,gHeroID,"%s has put you to sleep!!!",attacker_name)
				sh_chat_message(attacker,gHeroID,"You just put %s to sleep!!!",user_name)
				sleep_user(user,attacker)
			}
		}
		else{
			sh_chat_message(user,gHeroID,"%s has put you to sleep!!!",attacker_name)
			sh_chat_message(attacker,gHeroID,"You just put %s to sleep!!!",user_name)
			sleep_user(user,attacker)
		}
	}



}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound, SLEEP_SFX)

}

public _sh_unsleep_user(iPlugin,iParams){

	new user=get_param(1)
	unsleep_user(user)




}
fade_screen_user(id){
		message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client" 
		write_short(0); // fade lasts this long duration 
		write_short(0); // fade lasts this long hold time 
		write_short(FADE_HOLD); // fade type 
		write_byte(0); // fade red 
		write_byte(0); // fade green 
		write_byte(0); // fade blue  
		write_byte(255); // fade alpha  
		message_end(); 

}
unfade_screen_user(id){
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client"  
	write_short(1<<12); // fade lasts this long duration  
	write_short(1<<8); // fade lasts this long hold time  
	write_short(FADE_OUT); // fade type
	write_byte(0); // fade red  
	write_byte(0); // fade green  
	write_byte(0); // fade blue	 
	write_byte(255); // fade alpha	 
	message_end();	

}
public sleep_task(array[],id){
	id-=SLEEP_TASKID

	sh_set_stun(id,5.0,0.1)
	sh_set_rendering(id, sleep_color[0], sleep_color[1], sleep_color[2], sleep_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	emit_sound(id, CHAN_VOICE, SLEEP_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	


}
sleep_user(id,attacker){
	new array[1]
	array[0] = attacker
	fade_screen_user(id)
	gIsAsleep[id]=true
	set_task(SLEEP_PERIOD,"sleep_task",id+SLEEP_TASKID,array, sizeof(array),  "a",SLEEP_TIMES)
	set_task(floatsub(floatmul(SLEEP_PERIOD,float(SLEEP_TIMES)),0.1),"unsleep_task",id+UNSLEEP_TASKID,"", 0,  "a",1)
	return 0



}
public unsleep_task(id){
	id-=UNSLEEP_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+SLEEP_TASKID)
	unfade_screen_user(id)
	
	sh_set_stun(id,0.0)
	gIsAsleep[id]=false
	return 0



}

unsleep_user(id){
	remove_task(id+UNSLEEP_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+SLEEP_TASKID)
	sh_set_stun(id,0.0)
	gIsAsleep[id]=false
	return 0



}
