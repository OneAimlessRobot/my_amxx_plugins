#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "jetplane_inc/sh_yandere_get_set.inc"
#include "yandere_inc/sh_yandere_psychosis.inc"

stock curr_player_pain_sound[SH_MAXSLOTS+1]

new gHeroID = -1

#define PLUGIN "Superhero psychosis fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new pcvar_psychosis_cooldown
new pcvar_zoom
new pcvar_psychosis_time
new pcvar_psychosis_add_ap
new pcvar_psychosis_dmg_cushion

new YANDERE_PSYCHOSIS_TASKID

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	pcvar_psychosis_time = create_cvar("yandere_psychosis_time", "5")
	pcvar_zoom = create_cvar("yandere_psychosis_zoom", "5")
	pcvar_psychosis_add_ap = create_cvar("yandere_psychosis_add_ap", "5")
	pcvar_psychosis_dmg_cushion = create_cvar("yandere_psychosis_dmg_cushion", "5")
	pcvar_psychosis_cooldown = create_cvar("yandere_psychosis_cooldown", "30")

	RegisterHam(Ham_Player_PreThink,"player","Ham_Think_Pre",_,true)
	RegisterHam(Ham_TakeDamage,"player","psychosis_ham_damage",_,true)
	MsgSetFOV = get_user_msgid("SetFOV")
	register_forward(FM_CmdStart, "psychosis_leap")
	YANDERE_PSYCHOSIS_TASKID=allocate_typed_task_id(player_task)
	init_hud_syncs()
	
}
public plugin_cfg(){

	gHeroID = yandere_get_hero_id()

}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		if(Get_BitVar(gIsPsychosisMask,id)){
			unpsychosis_user(id)
		}
	}
	
}
public psychosis_ham_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
if ( !sh_is_active() || !is_user_alive(id)||!is_user_alive(attacker) ||(id==attacker)) return HAM_IGNORED
new bool:clients_here_are_same_team=sh_clients_are_same_team(id,attacker)
if(sh_get_user_has_hero(id,gHeroID)&&!(clients_here_are_same_team)&&yandere_get_is_super(id)&&Get_BitVar(gIsPsychosisMask,id)){
	
	damage=1.0+damage- (damage*
		cvar_val(float, pcvar_psychosis_dmg_cushion))
	SetHamParamFloat(4, damage);
}
return HAM_IGNORED
	
}
public plugin_natives(){


	
	register_native("yandere_get_user_is_psychosis","_yandere_get_user_is_psychosis");
	register_native("yandere_psychosis_user","_yandere_psychosis_user");
	register_native("yandere_unpsychosis_user","_yandere_unpsychosis_user");


}

public _yandere_get_user_is_psychosis(iPlugin,iParams){
	new id= get_param(1)
	
	return Get_BitVar(gIsPsychosisMask,id)


}
public _yandere_psychosis_user(iPlugin,iParams){
	new id= get_param(1)
	
	psychosis_user(id)


}

public _yandere_unpsychosis_user(iPlugin,iParams){
	new id= get_param(1)
	
	unpsychosis_user(id)


}

public Ham_Think_Pre(id) {
	if(!sh_is_active()) return HAM_IGNORED

	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)) { 
		return HAM_IGNORED
	}
	if(Get_BitVar(g_yandere_leaped_mask,id)){
		new flags = pev(id, pev_flags)
		if((flags  & FL_INGROUND2)){
			UnSet_BitVar(g_yandere_leaped_mask,id)
		}
	}
	return HAM_IGNORED
}
public Player_TakeDamage(id)
{
	if ( !sh_is_active() || !yandere_get_is_super(id)||!(Get_BitVar(gIsPsychosisMask,id))||!is_user_alive(id)) return HAM_IGNORED
	
	set_pdata_float(id, fPainShock, 1.0, 5)

	return HAM_IGNORED
}

//----------------------------------------------------------------------------------------------
public psychosis_leap(id, uc_handle)
{
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}

	if (!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)||!yandere_get_user_is_psychosis(id)) return FMRES_IGNORED;
	
	if(sh_get_stun(id)) return FMRES_IGNORED
	
	new button = get_uc(uc_handle, UC_Buttons);
	
	if(!Get_BitVar(g_yandere_leaped_mask,id)){
		if(button & IN_JUMP)
		{
			button &= ~IN_JUMP;
			new Float:velocity[3]
			pev(id,pev_velocity,velocity)
			velocity[2]+=600.0
			set_pev(id,pev_velocity,velocity)
			Set_BitVar(g_yandere_leaped_mask,id)
			
			
		}
	}
	return FMRES_IGNORED;
}

public psychosis_task(id){
	id-=YANDERE_PSYCHOSIS_TASKID

	gPsychosisTime[id]-=1.0
	set_render_with_color_const(id, PINK,1,255,_,0,_,1.0)
	aura(id,LineColors[PINK])
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)){
		if(is_user_connected(id)){
			unpsychosis_user(id)
		}
		return
	}
	if(!Get_BitVar(gIsPsychosisMask,id)){
		unpsychosis_user(id)
		return
	}
	if(!yandere_get_is_super(id)){
		unpsychosis_user(id)
		return
	}
	if(!is_user_bot(id)){
		static hud_msg[SH_HUD_MSG_BUFF_SIZE];
		static hero_name_arr[MAX_HERO_NAME_LENGTH]
		sh_get_hero_name_from_id(gHeroID,hero_name_arr)
		formatex(hud_msg,99,"[SH] %s:^nPsychosis mode for %0.1f more seconds!",
		hero_name_arr,
		gPsychosisTime[id]
		);
		superhero_protected_hud_message(superhero_hud_msg_sync,id,"%s", hud_msg,LineColors[PINK][0],LineColors[PINK][1],LineColors[PINK][2], -0.7, -1.0, 1, 0.0, 1.0,0.0,0.0)
		sh_screen_fade(id,0.1,1.0,LineColors[PINK][0],LineColors[PINK][1],LineColors[PINK][2],50)
	}
	if(gPsychosisTime[id]>=0.0){
		set_task(PSYCHOSIS_PERIOD,"psychosis_task",id+YANDERE_PSYCHOSIS_TASKID)
	}
	else{
		unpsychosis_user(id)
	}
	
}
psychosis_user(id){
	
	psychosis_on(id)
	sh_screen_fade(id,0.1,1.0,LineColors[PINK][0],LineColors[PINK][1],LineColors[PINK][2],50)
	set_task(PSYCHOSIS_PERIOD,"psychosis_task",id+YANDERE_PSYCHOSIS_TASKID)
	
	
	
}

public unpsychosis_user(id){
	sh_set_rendering(id)
	psychosis_off(id)
	
	
	
}
//----------------------------------------------------------------------------------------------
psychosis_off(id)
{


// Reset Zoom

UnSet_BitVar(gIsPsychosisMask,id);
Set_BitVar(g_yandere_leaped_mask,id);

emit_sound(id, CHAN_AUTO,yandere_pain_sounds[curr_player_pain_sound[id]] , VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);

cs_set_user_armor(id,0,CS_ARMOR_NONE)
message_begin(MSG_ONE, MsgSetFOV, {0,0,0}, id)
write_byte(90)	//Normal, not Zooming
message_end()

}
psychosis_on(id){

gPsychosisTime[id]=cvar_val(float, pcvar_psychosis_time)
ultimateTimer(id, cvar_val(float, pcvar_psychosis_cooldown) * 1.0)
curr_player_pain_sound[id]=generate_int(0,NUM_YANDERE_PAIN_SOUNDS-1)
emit_sound(id, CHAN_AUTO,yandere_pain_sounds[curr_player_pain_sound[id]] , VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
UnSet_BitVar(g_yandere_leaped_mask,id);
Set_BitVar(gIsPsychosisMask,id);
cs_set_user_armor(id,cs_get_user_armor(id)+cvar_val(num, pcvar_psychosis_add_ap),CS_ARMOR_VESTHELM)
message_begin(MSG_ONE, MsgSetFOV, {0,0,0}, id)
write_byte(cvar_val(num, pcvar_zoom))
message_end()

}


public sh_client_death(id){
	
	if(is_user_connected(id)&&sh_is_active()){
		unpsychosis_user(id)
	}
	
}