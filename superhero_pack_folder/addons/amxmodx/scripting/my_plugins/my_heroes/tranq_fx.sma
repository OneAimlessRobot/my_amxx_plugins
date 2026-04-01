#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"


#define PLUGIN "Superhero tranq fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


stock SLEEP_TASKID,
		UNSLEEP_TASKID,
		FULLY_WAKE_UP_TASKID

new bool:gIsAsleep[SH_MAXSLOTS+1]
new Float:gKeepAngles[SH_MAXSLOTS+1][3]
public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
arrayset(gIsAsleep,false,SH_MAXSLOTS+1)
register_forward(FM_CmdStart, "CmdStart");
register_event("DeathMsg","on_death_sleeping","a")
register_event("CurWeapon", "weaponChange", "be", "1=1")
SLEEP_TASKID=allocate_typed_task_id(player_task)
UNSLEEP_TASKID=allocate_typed_task_id(player_task)
FULLY_WAKE_UP_TASKID=allocate_typed_task_id(player_task)
register_event("ResetHUD","sleep_newRound","b")
init_explosion_defaults()

}

//----------------------------------------------------------------------------------------------
public sleep_newRound(id)
{	
	if(shModActive()&&client_hittable(id)){
		if(gIsAsleep[id]){
			sh_unsleep_user(id)
		}
	}
	
}
public CmdStart(id, uc_handle)
{
	if (!sh_is_active()||!client_hittable(id)) return FMRES_IGNORED;
	
	static button; button= get_uc(uc_handle, UC_Buttons);
	
	
	if ( gIsAsleep[id]) {
		button &= ~button;
		set_uc(uc_handle, UC_Buttons, button);
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED;
}
public plugin_natives(){


	register_native("sh_sleep_user","_sh_sleep_user",0);
	register_native("sh_get_user_is_asleep","_sh_get_user_is_asleep",0);
	register_native("sh_unsleep_user","_sh_unsleep_user",0);
}
stock sleep_user_switch_weapon(id){

	if ( !client_hittable(id)||!shModActive()) return
	
	new wpnid = read_data(2)
	new has_knife=user_has_weapon(id,CSW_KNIFE)
	if(!has_knife){
		sh_give_weapon(id,CSW_KNIFE,true)
	}
	else if(wpnid!=CSW_KNIFE){
		sh_switch_weapon(id,CSW_KNIFE)
		set_user_maxspeed(id,default_stun_speed)
	}
	
}
public bool:_sh_get_user_is_asleep(iPlugin,iParams){

	new id=get_param(1)
	return gIsAsleep[id]


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
			if(user&&CAN_SELF_SLEEP){

				
				if(!is_user_bot(user)){
					sh_chat_message(user,gHeroID,"%s has put you to sleep!!!",attacker_name)
				}
				if(!is_user_bot(attacker)){
					sh_chat_message(attacker,gHeroID,"You just put %s to sleep!!!",user_name)
				}
				sleep_user(user,attacker)
			}
		}
		else{
			if(!is_user_bot(user)){
				sh_chat_message(user,gHeroID,"%s has put you to sleep!!!",attacker_name)
			}
			
			if(!is_user_bot(attacker)){
				sh_chat_message(attacker,gHeroID,"You just put %s to sleep!!!",user_name)
			}
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
public sleep_task(array[],id){
	id-=SLEEP_TASKID
	if ( !shModActive() ||!client_hittable(id)) return
	entity_set_vector(id, EV_VEC_angles, gKeepAngles[id])
	entity_set_int( id, EV_INT_fixangle, 1);
	set_render_with_color_const(id,BLACK,0,_,255,1,1)
	set_render_with_color_const(id,WHITE,1,255,-1,0,0)
	


}
sleep_user(id,attacker){
	if ( !shModActive() ||!client_hittable(id)||!client_hittable(attacker)) return
	new array[1]
	array[0] = attacker
	gIsAsleep[id]=true
	sleep_user_switch_weapon(id)
	set_damage_icon(id,2,DMG_ICON_GAS,LineColors[WHITE])
	sh_set_stun(id,SLEEP_TIME*2.0,default_stun_speed)
	fade_screen_user(id)
	entity_get_vector(id, EV_VEC_angles, gKeepAngles[id])
	emit_sound(id, CHAN_VOICE, SLEEP_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_task(SLEEP_PERIOD,"sleep_task",id+SLEEP_TASKID,array, sizeof(array),  "a",SLEEP_TIMES+9)
	set_task(SLEEP_TIME,"unsleep_task",id+UNSLEEP_TASKID,"", 0,  "a",1)



}
public unsleep_task(id){
	id-=UNSLEEP_TASKID

	if ( !shModActive() ||!is_user_connected(id)) return
	unfade_screen_user(id)
	set_task(3.0,"fully_wake_up_task",id+FULLY_WAKE_UP_TASKID,"",0,"a",1)



}
public fully_wake_up_task(id){
	id-=FULLY_WAKE_UP_TASKID
	if ( !shModActive() ||!is_user_connected(id)) return
	
	set_user_rendering(id)
	set_damage_icon(id,0,DMG_ICON_GAS)
	gIsAsleep[id]=false
	entity_set_vector(id, EV_VEC_angles, gKeepAngles[id])
	entity_set_int( id, EV_INT_fixangle, 0);
	


}
unsleep_user(id){
	remove_task(id+UNSLEEP_TASKID)
	remove_task(id+SLEEP_TASKID)
	remove_task(id+FULLY_WAKE_UP_TASKID)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_user_rendering(id)
	set_damage_icon(id,0,DMG_ICON_GAS)
	gIsAsleep[id]=false
	entity_set_vector(id, EV_VEC_angles, gKeepAngles[id])
	entity_set_int( id, EV_INT_fixangle, 0);



}

public weaponChange(id)
{
	if ( !client_hittable(id)||!shModActive()) return

	if(gIsAsleep[id]){
		sleep_user_switch_weapon(id)
	}
}
public on_death_sleeping()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		sh_unsleep_user(id)

	}
	
}