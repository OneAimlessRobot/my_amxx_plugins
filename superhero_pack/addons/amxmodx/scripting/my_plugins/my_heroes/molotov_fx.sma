#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "tranq_gun_inc/sh_molotov_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero chaff fx"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


new bool:gIsBurning[SH_MAXSLOTS+1]
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	arrayset(gIsBurning,false,SH_MAXSLOTS+1)
	g_msgFade = get_user_msgid("ScreenFade");
	
}
public plugin_precache(){
	precache_explosion_fx()
	precache_sound(gSoundBurning)
	precache_sound(gSoundScream)

}
public plugin_natives(){
	
	register_native("sh_molly_user","_sh_molly_user",0);
	register_native("sh_unmolly_user","_sh_unmolly_user",0);
}
public burn_task(array[],id)
{
	id-=BURN_TASKID
	
	if ( !shModActive() || !is_user_connected(id)||!(id>=1 && id <=SH_MAXSLOTS) ||!is_user_connected(array[0]) ||!(array[0]>=1 && array[0]<=SH_MAXSLOTS)) return PLUGIN_CONTINUE
	sh_screen_fade(id, 0.1, 0.9, molly_color[0], molly_color[1], molly_color[2], 50)
	sh_set_rendering(id,  molly_color[0], molly_color[1], molly_color[2],molly_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(array[0], 0.1, 0.9, molly_color[0], molly_color[1], molly_color[2], 50)
	
	make_fire(id,30.0)
	new origin[3],dist,i,burned_origin[3]
	get_user_origin(id,burned_origin)
	for ( i = 1; i <= SH_MAXSLOTS; i++) {
		
		if( !client_hittable(i) || i==id || gIsBurning[i] ) continue
		get_user_origin(i,origin)
		dist = get_distance(origin,burned_origin)
		if (dist <= MOLLY_PROPAGATE_RADIUS) {
			
			sh_molly_user(i,id,tranq_get_hero_id())
			
		}
	}

	if ( !is_user_alive(id) || pev(id, pev_waterlevel) == 3 ) {
		gIsBurning[id] = false
		return PLUGIN_CONTINUE
	}

	if ( !gIsBurning[id] )
		return PLUGIN_CONTINUE
	

	sh_extra_damage(id,array[0],BURN_DAMAGE,"Burning",0,SH_DMG_NORM)
	return PLUGIN_CONTINUE
}

//----------------------------------------------------------------------------------------------
public fire_scream(id)
{
	emit_sound(id, CHAN_AUTO, gSoundScream, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}
//----------------------------------------------------------------------------------------------
public stop_fire_sound(id)
{
	gIsBurning[id] = false
	emit_sound(id, CHAN_ITEM, gSoundBurning, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
}
public _sh_molly_user(iPlugin,iParams){
	
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!gIsBurning[user]){
		if((user==attacker)){
			if(CAN_SELF_MOLLY&&user){
				sh_chat_message(user,gHeroID,"%s has burned you!!!",attacker_name)
				sh_chat_message(attacker,gHeroID,"You burned %s!!!",user_name)
				burn_user(user,attacker)
			}
		}
		else{
			sh_chat_message(user,gHeroID,"%s has burned you!!!",attacker_name)
			sh_chat_message(attacker,gHeroID,"You burned %s!!!",user_name)
			burn_user(user,attacker)
		}
	}
	
	
	
}
public _sh_unmolly_user(iPlugin,iParams){
	
	new user=get_param(1)
	unburn_user(user)
	
	
	
	
}
stock burn_user(id,attacker){
	new array[1]
	array[0] = attacker
	gIsBurning[id]=true
	set_task(BURN_PERIOD,"burn_task",id+BURN_TASKID,array, sizeof(array), "a",BURN_TIMES)
	set_task(BURN_PERIOD, "fire_sound", id+BURN_TASKID+1, "", 0,  "a", BURN_TIMES);
	set_task(0.7, "fire_scream", id+BURN_TASKID+2)
	set_task(5.5, "stop_fire_sound", id+BURN_TASKID+3)
	set_task(floatsub(floatmul(BURN_PERIOD,float(BURN_TIMES)),0.1),"unburn_task",id+UNMOLLY_TASKID,"", 0,  "a",1)
	return 0
	
	
	
}
// Make fire sounds
public fire_sound(id) {
	id-=BURN_TASKID+1
	emit_sound(id, CHAN_AUTO, MOLLY_FIRE_SFX , VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public unburn_task(id){
	id-=UNMOLLY_TASKID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+BURN_TASKID)
	remove_task(id+BURN_TASKID+1)
	remove_task(id+BURN_TASKID+2)
	remove_task(id+BURN_TASKID+3)
	unfade_screen_user(id)
	
	gIsBurning[id]=false
	return 0
	
	
	
}

unburn_user(id){
	remove_task(id+UNMOLLY_TASKID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+BURN_TASKID)
	remove_task(id+BURN_TASKID+1)
	remove_task(id+BURN_TASKID+2)
	remove_task(id+BURN_TASKID+3)
	unfade_screen_user(id)
	gIsBurning[id]=false
	return 0
	
	
	
}
