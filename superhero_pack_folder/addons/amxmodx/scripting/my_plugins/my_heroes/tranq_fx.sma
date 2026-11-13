#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_RESOURCE_ALIASES
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"


#define PLUGIN "Superhero tranq fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

stock SLEEP_TASKID,
		FULLY_WAKE_UP_TASKID

new Float:gKeepAngles[SH_MAXSLOTS+1][3]

new on_sleep_start_fwd,
	on_sleep_end_fwd

public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
register_forward(FM_CmdStart, "CmdStart");
RegisterHam(Ham_Player_PreThink,"player","Ham_PlayerPreThink",_,true)
register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
register_event("CurWeapon", "weaponChange", "be", "1=1")	

on_sleep_start_fwd = CreateMultiForward("sh_on_sleep_start_fwd",ET_CONTINUE ,FP_CELL,FP_CELL, FP_FLOAT, FP_CELL)
on_sleep_end_fwd = CreateMultiForward("sh_on_sleep_end_fwd",ET_CONTINUE ,FP_CELL,FP_CELL, FP_FLOAT, FP_CELL)

SLEEP_TASKID=allocate_typed_task_id(player_task)
FULLY_WAKE_UP_TASKID=allocate_typed_task_id(player_task)
}
//https://forums.alliedmods.net/showthread.php?t=258006
public Ham_PlayerPreThink(id)
{
	if(!sh_is_active()) return FMRES_IGNORED

	if(!is_user_alive(id)){
		return FMRES_IGNORED
	}

	if(!sh_get_id_bit(id,SH_IS_SLEEPING)){
		return FMRES_IGNORED
	}
	entity_set_vector( id, EV_VEC_angles, gKeepAngles[id] )
	entity_set_vector( id, EV_VEC_v_angle, gKeepAngles[id] )
	entity_set_int( id, EV_INT_fixangle, 1 )
	return FMRES_IGNORED
}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(!sh_is_active()) return FMRES_IGNORED
	
	if(!is_user_alive(player)){
		
		return FMRES_IGNORED
	}
	if(!sh_get_id_bit(player,SH_IS_SLEEPING)){
		return FMRES_IGNORED
	}
	new pEntity = get_pdata_cbase(player, m_pActiveItem, XO_PLAYER)
	if(pev_valid(pEntity)==PDATA_SAFE){
		set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	
	unsleep_user(id)
	
}
public CmdStart(id, uc_handle)
{
	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if (!is_user_alive(id)) return FMRES_IGNORED;

	if ( sh_get_id_bit(id,SH_IS_SLEEPING)) {
		set_uc(uc_handle, UC_Buttons, 0);
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED;
}
public plugin_natives(){


	register_native("sh_sleep_user","_sh_sleep_user");
	register_native("sh_unsleep_user","_sh_unsleep_user");
}
stock sleep_user_switch_weapon(id){

	if ( !is_user_alive(id)||!sh_is_active()) return
	
	new wpnid = read_data(2)
	if(wpnid!=CSW_KNIFE){
		sh_switch_weapon(id,CSW_KNIFE)
		set_user_maxspeed_controlled(id,0.1,true,false)
	}
	
}
public _sh_sleep_user(iPlugin,iParams){

	new user=get_param(1)
	if(!sh_get_id_bit(user,SH_IS_SLEEPING)){
		new attacker=get_param(2)
		new Float:the_time = get_param_f(3)
		new heroID=get_param(4)
		static attacker_name[128]
		get_user_name(attacker,attacker_name,127)
		static user_name[128]
		get_user_name(user,user_name,127)
		if((user==attacker)){
			if(user&&CAN_SELF_SLEEP){

				
				if(!is_user_bot(user)){
					sh_chat_message(user,heroID,"%s has put you to sleep!!!",attacker_name)
				}
				if(!is_user_bot(attacker)){
					sh_chat_message(attacker,heroID,"You just put %s to sleep!!!",user_name)
				}
				sleep_user(user,attacker, the_time,heroID)
			}
		}
		else{
			if(!is_user_bot(user)){
				sh_chat_message(user,heroID,"%s has put you to sleep!!!",attacker_name)
			}
			
			if(!is_user_bot(attacker)){
				sh_chat_message(attacker,heroID,"You just put %s to sleep!!!",user_name)
			}
			sleep_user(user,attacker, the_time,heroID)
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
public sleep_task(any:array[4],id){
	id-=SLEEP_TASKID
	if(!sh_get_id_bit(id, SH_IS_SLEEPING)){

		return
		
	}
	if ( !sh_is_active() ||!is_user_alive(id)){

		unsleep_user(id)
		return
	}
	set_render_with_color_const(id,BLACK,1,255,255,1,1,SLEEP_PERIOD,_,_,kRenderNormal,PRIO_RENDER_DELETE_ASLEEP)

	if(sh_get_id_bit(id,SH_IS_SLEEPING)&&(array[0]>0)){
		array[0]--
		set_task(SLEEP_PERIOD,"sleep_task",id+SLEEP_TASKID,array, sizeof(array))
	}
	else if(sh_get_id_bit(id,SH_IS_SLEEPING)){
		set_task(Float:array[2],"fully_wake_up_task",id+FULLY_WAKE_UP_TASKID,array,sizeof(array))
	}


}
sleep_user(id,attacker, Float:the_time,heroID){
	if ( !sh_is_active() ||!is_user_alive(id)||!is_user_alive(attacker)) return
	new any:array[4]
	array[0] = SLEEP_TIMES
	array[1] = attacker
	array[2] = the_time
	array[3] = heroID

	entity_get_vector( id, EV_VEC_angles, gKeepAngles[id] )
	sh_assign_id_bit(id,SH_IS_SLEEPING,true)
	sleep_user_switch_weapon(id)
	sh_set_stun(id,the_time*2.0)
	emit_sound(id, CHAN_VOICE, SLEEP_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	if (!ExecuteForward(on_sleep_start_fwd, _,
								id,
								attacker,
								the_time,
								heroID)){

		server_print("Sh on sleep start forward execute error.");
	}
	sleep_task(array,id+SLEEP_TASKID)



}
public fully_wake_up_task(any:array[4],id){
	id-=FULLY_WAKE_UP_TASKID
	if (!ExecuteForward(on_sleep_end_fwd, _,
								id,
								array[1],
								Float:array[2],
								array[3])){

		server_print("Sh on sleep end forward execute error.");
	}

	unsleep_user(id)
	


}
unsleep_user(id){
	if ( !sh_is_active() ||!is_user_connected(id)) return
	
	if(task_exists(id+FULLY_WAKE_UP_TASKID)){
		remove_task(id+FULLY_WAKE_UP_TASKID)
	}

	if(sh_get_id_bit(id,SH_IS_SLEEPING)){
		remove_glow_user(id,PRIO_RENDER_DELETE_ASLEEP,255,kRenderNormal)
		sh_assign_id_bit(id,SH_IS_SLEEPING,false)
	}
}

public weaponChange(id)
{
	if ( !sh_is_active()) return

	if(sh_get_id_bit(id,SH_IS_SLEEPING)){
		sleep_user_switch_weapon(id)
	}
}
public sh_client_death(id){
	
	
	unsleep_user(id)	
}