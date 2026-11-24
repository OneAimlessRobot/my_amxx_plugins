#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS_2
#define I_WANT_QUICK_CHECKS
#define I_WANT_BASIC_MACROS
#define I_WANT_MATH_FUNCS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_PRECACHE_UTILITIES
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "jetplane_inc/sh_grief_drive_get_set.inc"
#include "grief_drive_inc/sh_grief_drive_psychosis.inc"


new num_psychosis_sounds = 0

new grief_drive_pain_sounds[][]={
	"shmod/grief_drive/Yakui_the_maid-bodies_everywhere.wav",
	"shmod/grief_drive/Yakui_the_maid-46.wav",
	"shmod/grief_drive/Yakui_the_maid-Chloramine.wav",
	""
	
	
}
#define PSYCHOSIS_PERIOD 1.0
#define PSYCHOSIS_TIMES floatround(floatdiv(psychosis_time,PSYCHOSIS_PERIOD))

stock g_grief_drive_leaped_mask

stock Float:gPsychosisTime[SH_MAXSLOTS+1]

stock MsgSetFOV


stock curr_player_pain_sound[SH_MAXSLOTS+1]


#define PLUGIN "Superhero psychosis fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new pcvar_psychosis_cooldown
new pcvar_zoom
new pcvar_psychosis_time
new pcvar_psychosis_add_ap
new pcvar_psychosis_dmg_cushion

new YANDERE_PSYCHOSIS_TASKID

new const DEBUG = 0
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	pcvar_psychosis_time = create_cvar("grief_drive_psychosis_time", "5")
	pcvar_zoom = create_cvar("grief_drive_psychosis_zoom", "5")
	pcvar_psychosis_add_ap = create_cvar("grief_drive_psychosis_add_ap", "5")
	pcvar_psychosis_dmg_cushion = create_cvar("grief_drive_psychosis_dmg_cushion", "5")
	pcvar_psychosis_cooldown = create_cvar("grief_drive_psychosis_cooldown", "30")

	RegisterHam(Ham_Player_PostThink,"player","Ham_Think_Post",_,true)
	RegisterHam(Ham_TakeDamage,"player","psychosis_ham_damage",_,true)
	MsgSetFOV = get_user_msgid("SetFOV")
	register_forward(FM_CmdStart, "psychosis_leap")
	
	YANDERE_PSYCHOSIS_TASKID=allocate_typed_task_id(generic_task)
	
	set_task(1.0,"psychosis_loop",YANDERE_PSYCHOSIS_TASKID,_,_,"b")
	
	init_hud_syncs()
	
}
public plugin_cfg(){

	gHeroID = grief_drive_get_hero_id()

}
public plugin_precache(){


	num_psychosis_sounds = count_null_terminated_string_array(grief_drive_pain_sounds,
															"grief_drive psychosis morph sounds",
															"Sentence",
															DEBUG)

	precache_null_terminated_resource_list(grief_drive_pain_sounds,PRECACHE_SOUNDS, DEBUG)

}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		if(gPsychosisTime[id]>0.0){
			psychosis_off(id)
		}
	}
	
}
public psychosis_ham_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
if(damage <= 0.0){

	return HAM_IGNORED
}
if ( !sh_is_active() || !is_user_alive(id)||!is_user_alive(attacker) ||(id==attacker)) return HAM_IGNORED
new bool:clients_here_are_same_team=sh_clients_are_same_team(id,attacker)
if(sh_get_user_has_hero(id,gHeroID)&&!(clients_here_are_same_team)&&grief_drive_get_is_super(id)&&
			gPsychosisTime[id]>0.0){
	
	damage=1.0+damage- (damage*
		cvar_val(float, pcvar_psychosis_dmg_cushion))
	SetHamParamFloat(4, damage);
}
return HAM_IGNORED
	
}
public plugin_natives(){

	register_native("grief_drive_psychosis_user","_grief_drive_psychosis_user");
	register_native("grief_drive_unpsychosis_user","_grief_drive_unpsychosis_user");


}
public _grief_drive_psychosis_user(iPlugin,iParams){
	new id= get_param(1)
	
	psychosis_on(id)


}

public _grief_drive_unpsychosis_user(iPlugin,iParams){
	new id= get_param(1)
	
	psychosis_off(id)


}

public Ham_Think_Post(id) {
	if(!sh_is_active()) return HAM_IGNORED

	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)||(gPsychosisTime[id]<=0.0)) { 
		return HAM_IGNORED
	}
	if(Get_BitVar(g_grief_drive_leaped_mask,id)){
		new flags = pev(id, pev_flags)
		if((flags  & FL_INGROUND2)){
			UnSet_BitVar(g_grief_drive_leaped_mask,id)
		}
	}
	return HAM_IGNORED
}
public Player_TakeDamage(id)
{
	if ( !sh_is_active() || !grief_drive_get_is_super(id)||
				(gPsychosisTime[id]<=0.0)||
				!is_user_alive(id)) return HAM_IGNORED
	
	set_pdata_float(id, fPainShock, 1.0, 5)

	return HAM_IGNORED
}

//----------------------------------------------------------------------------------------------
public psychosis_leap(id, uc_handle)
{
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}

	if (!is_user_alive(id)){
		
		
		return FMRES_IGNORED
	
	}

	if(!sh_get_user_has_hero(id,gHeroID)||(gPsychosisTime[id]<=0.0)||
			sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||
			sh_get_id_bit(id, SH_USER_IS_FLYING)){
				
		return FMRES_IGNORED;
	}
	if(sh_get_stun(id)) return FMRES_IGNORED
	
	static button; button = get_uc(uc_handle, UC_Buttons);
	
	static flags; flags = pev(id, pev_flags)
	if((flags  & FL_INGROUND2)){
		if((button&IN_JUMP))
		{
			if(!Get_BitVar(g_grief_drive_leaped_mask,id)){
				static Float:velocity[3],
						Float:aimdir[3],
						Float:aimdir_2d[2],
						Float:curr_movespeed = 0.0
				
				pev(id,pev_velocity,velocity)

				curr_movespeed = vector_length(velocity)


				my_velocity_by_aim(id,curr_movespeed,aimdir,dummy_vector)

				aimdir_2d[0] = aimdir[0]
				aimdir_2d[1] = aimdir[1]

				multiply_2d_vector_by_scalar(aimdir_2d,0.15,aimdir_2d)

				aimdir[0] = aimdir_2d[0]
				aimdir[1] = aimdir_2d[1]

				aimdir[2]=180.0

				add_3d_vectors(velocity,aimdir,velocity)

				set_pev(id,pev_velocity,velocity)
				Set_BitVar(g_grief_drive_leaped_mask,id)
				
				
			}
		}
	}
	return FMRES_IGNORED;
}

public psychosis_loop(taskid){


	if(!sh_is_active()) return

	if(sh_is_freezetime()) return
	

	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		id = the_players[i]
		
		if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)){
			continue
		}
		if((gPsychosisTime[id]<=0.0)){
			continue
		}
		if(!grief_drive_get_is_super(id)){
			continue
		}
		if(gPsychosisTime[id]<=0.0){
			continue
		}

		gPsychosisTime[id]-=1.0
		set_render_with_color_const(id, PINK,1,255,_,0,_,1.0,_,_,_,PRIO_RENDER_POWERUP)
		aura(id,LineColors[PINK])

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
		if(gPsychosisTime[id]<=0.0){


			psychosis_off(id)
		}
	}
	
}
//----------------------------------------------------------------------------------------------
psychosis_off(id)
{


	gPsychosisTime[id]=-1.0
	sh_assign_id_bit(id,SH_IS_PSYCHOSIS,false)

	emit_sound(id, CHAN_AUTO,grief_drive_pain_sounds[curr_player_pain_sound[id]] , VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);

	cs_set_user_armor(id,0,CS_ARMOR_NONE)

	// Reset Zoom
	message_begin(MSG_ONE_UNRELIABLE, MsgSetFOV, {0,0,0}, id)
	write_byte(90)	//Normal, not Zooming
	message_end()

}
psychosis_on(id){

	if(gPsychosisTime[id]>0.0){
		return
	}
	sh_screen_fade(id,0.1,1.0,LineColors[PINK][0],LineColors[PINK][1],LineColors[PINK][2],50)

	curr_player_pain_sound[id]=generate_int(0,num_psychosis_sounds-1,40)
	emit_sound(id, CHAN_AUTO,grief_drive_pain_sounds[curr_player_pain_sound[id]] , VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	cs_set_user_armor(id,cs_get_user_armor(id)+cvar_val(num, pcvar_psychosis_add_ap),CS_ARMOR_VESTHELM)
	message_begin(MSG_ONE_UNRELIABLE, MsgSetFOV, {0,0,0}, id)
	write_byte(cvar_val(num, pcvar_zoom))
	message_end()
	gPsychosisTime[id]=cvar_val(float, pcvar_psychosis_time)
	sh_set_cooldown(id, cvar_val(float, pcvar_psychosis_cooldown) * 1.0)
	sh_assign_id_bit(id,SH_IS_PSYCHOSIS,true)

}


public sh_client_death(id){
	
	if(is_user_connected(id)&&sh_is_active()){
		psychosis_off(id)
	}
	
}