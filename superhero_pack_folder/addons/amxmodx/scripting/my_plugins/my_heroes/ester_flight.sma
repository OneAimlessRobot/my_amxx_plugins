#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_QUICK_CHECKS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_ENTITY_VECTORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_PRECACHE_UTILITIES
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "ester_inc/ester_global.inc"
#include "ester_inc/ester_flight.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"



#define PLUGIN "Superhero ester flight funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"



#define FLIGHT_POWER "shmod/ester/flight/flight_power.wav"
#define FLIGHT_IGNITION "shmod/ester/flight/flight_ignition.wav"
#define FLIGHT_HUM "shmod/ester/flight/flight_hum.wav"
#define FLIGHT_WEAK "shmod/ester/flight/flight_weak.wav"

#define FLIGHT_DRAIN_INFLICT_PERIOD 0.33

#define FLIGHT_MOVEMENT_PERIOD 0.1

#define COLOR_STRONG WHITE
#define COLOR_WEAK GREEN


new num_sounds = 0


new ester_blowup_sounds[][]={

	"shmod/ester/flight/preventative_conniferous.wav",
	"shmod/ester/flight/kaitai_the_maid_404_Dante_the_maid_cover.wav",
	"shmod/ester/flight/Kichi_-_REBORN_-_02_Shallow_Emptiness.wav",
	"shmod/ester/flight/mahokichi_deathless.wav",
	"shmod/ester/flight/amurican_malez.wav",
	"shmod/ester/flight/end_of_days.wav",
	"shmod/ester/flight/IT_AINT_THE_END_OF_ME.wav",
	"shmod/ester/flight/This_Fire.wav",
	"shmod/ester/flight/born_to_win.wav",
	"shmod/ester/flight/captain_tsubasa_counter_attack.wav",
	"shmod/ester/flight/No_More_Words.wav",
	"shmod/ester/flight/shitai_maid_overdrinking.wav",
	"shmod/ester/flight/ozoi_x_yakui_maids_-_frontier.wav",
	""

}

stock curr_player_sound[SH_MAXSLOTS+1]

#define ESTER_RESPAWN_FAIL_SOUND "shmod/ester/flight/flight_blowup_fail.wav"

#define ESTER_FIRST_RESPAWN_SOUND "shmod/ester/flight/chikoi_the_maid_autumn_melancholy.wav"

#define ESTER_LAST_RESPAWN_SOUND "shmod/ester/flight/The_Last_Breath_Of_A_Hollow_Bosom__mp3.wav"

#define ESTER_RESPAWN_FAIL_MSG "You're done. You get no more chances."

#define ESTER_SUICIDE_FAIL_MSG "You failed to transcend self-worth, for you have bailed the ultimate honour. You're done. Now, rest easy."

#define ESTER_SUICIDE_SCOURN_MSG "Wow, they really do not make gods like they used to. Forgiven for taking your own life? Alright, enjoy the rest of the round."

#define FLIGHT_GODMODE_THINK_TIME 1.0

#define ESTER_WALL_STUCK_MSG "You were eliminated completely. Dont get stuck on walls, moron."
#define ESTER_REBORN_TEAM_CHANGE_MSG "You changed teams and were reborn as ester, now you shall die"


#define ESTER_REBORN_COLLISION_DISTANCE_THRESHOLD 30.0

#define ESTER_REBORN_COLLISION_THINK_TIME 0.25

#define PRE_RESPAWN_MESSAGE_RELAY 0.0
#define ESTER_REBORN_EXPLOSION_DELAY_TIME 10.0
#define ESTER_REBORN_EXPLOSION_PERIOD 0.5
#define ESTER_REBORN_EXPLOSION_NUMBER 3


new num_sentences = 0
new ester_sentences[][]={

	"You were made to do more than survive the day. Go avenge yourself",
	"This one must count, now. I wont disappoint myself or them any longer",
	"Its show time.",
	""
}





new g_ester_is_denied_mask = 0
new g_flying_mask = 0
new g_draining_mask = 0
new g_smashed_someone_mask = 0
new g_smashed_breakable_mask = 0
new g_is_desperate_mask = 0


new pcvar_ester_flyspeed,
pcvar_ester_fly_health_spend_pct,
pcvar_ester_calculation_time_period,
pcvar_ester_calculation_chance_numerator,
pcvar_ester_fly_knock_enemies_force,
pcvar_ester_damage_reflect_coeff,
pcvar_ester_reborn_weak_mode_hp,
pcvar_ester_calculation_chance_denominator,
pcvar_ester_fly_desperate_health_frac,
pcvar_ester_fly_despondent_health_frac

new pcvar_ester_fly_knock_enemies;
new pcvar_ester_calculation_times
new pcvar_ester_explosion_damage,
pcvar_ester_explosion_radius
new pcvar_ester_explosion_ignore_user
new pcvar_ester_total_respawn_attempts
new pcvar_ester_anti_pussy_engaged

new Float:g_ester_blow_up_time_left[SH_MAXSLOTS+1]
new g_ester_respawned_attempts[SH_MAXSLOTS+1]
new CsTeams:g_which_team_is_user[SH_MAXSLOTS+1]
new Float:g_saved_coords[SH_MAXSLOTS+1][3]


new dmg_source_name_short_ester_flight_drain[SAFE_BUFFER_SIZE+1]="ester_flight_drain"
new dmg_source_name_log_ester_flight_drain[SAFE_BUFFER_SIZE+1]="ester_flight_drain"
new ester_flight_drain_wpn_id

new dmg_source_name_short_ester_rebirth[SAFE_BUFFER_SIZE+1]="ester_rebirth"
new dmg_source_name_log_ester_rebirth[SAFE_BUFFER_SIZE+1]="ester_rebirth"
new ester_rebirth_wpn_id

new generic_dmg_source_shock = -1
new ESTER_REBORN_CALCULATION_LOOP_TASKID,
		ESTER_REBORN_GLOW_TASKID,
		ESTER_REBORN_EXPLOSION_DELAY_TASKID,
		ESTER_FLIGHT_DRAIN_GLOBAL_TASKID,
		ESTER_FLIGHT_MOVEMENT_TASKID


new const DEBUG = 0
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	pcvar_ester_flyspeed = create_cvar("ester_flyspeed", "1000.0")
	pcvar_ester_fly_health_spend_pct = create_cvar("ester_fly_health_spend_pct", "25.0")
	pcvar_ester_fly_desperate_health_frac = create_cvar("ester_fly_desperate_health_frac", "0.3")
	pcvar_ester_fly_despondent_health_frac = create_cvar("ester_fly_despondent_health_frac", "0.9")
	pcvar_ester_explosion_damage = create_cvar("ester_explosion_damage", "300.0")
	pcvar_ester_explosion_radius = create_cvar("ester_explosion_radius", "400.0")
	pcvar_ester_explosion_ignore_user = create_cvar("ester_explosion_ignore_user", "1")
	pcvar_ester_fly_knock_enemies = create_cvar("ester_fly_knock_enemies", "1")
	pcvar_ester_fly_knock_enemies_force = create_cvar("ester_fly_knock_enemies_force", "100.0")
	pcvar_ester_calculation_time_period = create_cvar("ester_calculation_time_period", "25.0")
	pcvar_ester_calculation_times = create_cvar("ester_calculation_times", "10")
	pcvar_ester_calculation_chance_numerator = create_cvar("ester_calculation_chance_numerator", "4.0")
	pcvar_ester_calculation_chance_denominator = create_cvar("ester_calculation_chance_denominator", "6.0")
	pcvar_ester_damage_reflect_coeff = create_cvar("ester_damage_reflect_coeff", "0.8")
	pcvar_ester_total_respawn_attempts = create_cvar("ester_total_respawn_attempts", "4")
	pcvar_ester_reborn_weak_mode_hp = create_cvar("ester_reborn_weak_mode_hp", "160.0")
	pcvar_ester_anti_pussy_engaged = create_cvar("ester_anti_pussy_engaged", "0")
	
	
	register_custom_touchable("player","ester_break_shit",breakable_vector,1)
	register_custom_touchable("player","ester_charge_impact",player_vector,1)

	register_forward(FM_CmdStart, "OnCmdStart")
	
	
	RegisterHam(Ham_TakeDamage, "player", "Ester_Knockback", 1,true)
	RegisterHam(Ham_TakeDamage, "player", "Ester_DamageReflect",_,true)

	ESTER_REBORN_CALCULATION_LOOP_TASKID=allocate_typed_task_id(player_task)
	ESTER_REBORN_GLOW_TASKID=allocate_typed_task_id(player_task)
	ESTER_REBORN_EXPLOSION_DELAY_TASKID=allocate_typed_task_id(player_task)
	ESTER_FLIGHT_DRAIN_GLOBAL_TASKID=allocate_typed_task_id(generic_task)
	ESTER_FLIGHT_MOVEMENT_TASKID=allocate_typed_task_id(generic_task)

	set_task(FLIGHT_MOVEMENT_PERIOD,"ester_flight_loop",ESTER_FLIGHT_MOVEMENT_TASKID,_,_,"b")

	set_task(FLIGHT_DRAIN_INFLICT_PERIOD,"ester_drain_loop",ESTER_FLIGHT_DRAIN_GLOBAL_TASKID,_,_,"b")
}
public plugin_cfg(){

	gHeroID= ester_get_hero_id()
	

	ester_flight_drain_wpn_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_ester_flight_drain,
								dmg_source_name_log_ester_flight_drain,
								0)

	ester_rebirth_wpn_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_ester_rebirth,
								dmg_source_name_log_ester_rebirth,
								0)

	generic_dmg_source_shock = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_SHOCK)
}
public ester_drain_loop(task_id){

	if(!sh_is_active()) return

	if(sh_is_freezetime()) return
	static hp,
			max_hp_to_use,
			Float:curr_hp_ratio
	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		id = the_players[i]
        

		if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)||
				!sh_get_id_bit(id,SH_IS_REBORN)){
				continue;
		}
		if(get_user_godmode(id)){
			
			continue
		
		}

		if(!Get_BitVar(g_flying_mask,id)){
			continue
		}


		if(!Get_BitVar(g_draining_mask,id)){
			continue
		}
		max_hp_to_use = sh_get_max_hp(id)
		


		curr_hp_ratio = float(get_user_health(id))/float(max_hp_to_use)
		
		if(!Get_BitVar(g_is_desperate_mask,id)){
			
			if(curr_hp_ratio<=cvar_val(float, pcvar_ester_fly_desperate_health_frac)){
			
				Assign_BitVar(g_is_desperate_mask,id, true_for_macro)
			}
		}
		else if(curr_hp_ratio>=cvar_val(float, pcvar_ester_fly_despondent_health_frac)){

				
			Assign_BitVar(g_is_desperate_mask,id, false_for_macro)
		}
		hp=get_user_health(id)
		new lost_hp = floatround(
					
					FLIGHT_DRAIN_INFLICT_PERIOD*

					float(hp)*
					
					(cvar_val(float,pcvar_ester_fly_health_spend_pct)*0.01))
					
					+1
		
		sh_extra_damage(id, id, lost_hp,
					_,_,_,_,_,
					SH_NEW_DMG_DRAIN,
					ester_flight_drain_wpn_id)



	}
}
public ester_flight_loop(task_id){

	if(!sh_is_active()) return

	if(sh_is_freezetime()) return
	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		id = the_players[i]
        

		if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)||
				!sh_get_id_bit(id,SH_IS_REBORN)){
				continue;
		}

		if(Get_BitVar(g_flying_mask,id)){
			static Float:Velocity[3]

			static Float:curr_hp_ratio,
						Float:flight_speed,
						Float:flight_speed_if_not_desperate,
						Float:flight_speed_if_desperate,
						max_hp_to_use
			
			
			max_hp_to_use = sh_get_max_hp(id)
			
			curr_hp_ratio = float(get_user_health(id))/float(max_hp_to_use)
			
			flight_speed_if_desperate = cvar_val(float,pcvar_ester_flyspeed)

			flight_speed_if_not_desperate = min_macro(flight_speed_if_desperate, max_macro(250.0, flight_speed_if_desperate*curr_hp_ratio))
			
			
			flight_speed = (Get_BitVar(g_is_desperate_mask,id)? flight_speed_if_desperate:flight_speed_if_not_desperate)

			
			velocity_by_aim(id, floatround(flight_speed), Velocity)
		
			entity_set_vector(id, EV_VEC_velocity, Velocity)
		}


	}
}
deny_next_reborn(id,bool:is_sillycide=true){
	
	if(Get_BitVar(g_ester_is_denied_mask,id)){
		return
	}
	sh_chat_message(id,gHeroID,is_sillycide?ESTER_SUICIDE_FAIL_MSG:ESTER_RESPAWN_FAIL_MSG)

	emit_sound(id, CHAN_AUTO,NULL_SOUND , VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);

	emit_sound(id, CHAN_AUTO,ESTER_RESPAWN_FAIL_SOUND , VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	g_ester_respawned_attempts[id]=is_sillycide?
				cvar_val(num, pcvar_ester_total_respawn_attempts):
				g_ester_respawned_attempts[id]
	
	Assign_BitVar(g_ester_is_denied_mask,id,true_for_macro)
}
public plugin_natives(){

	register_native("ester_set_reborn_mode","_ester_set_reborn_mode");

}
public Ester_DamageReflect(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(damage <= 0.0){

		return HAM_IGNORED
	}
	if ( !sh_is_active() || !is_user_alive(id)||!is_user_alive(attacker)||(id==attacker)) return HAM_IGNORED

	if(cs_get_user_team(id)==cs_get_user_team(attacker)){
	
		return HAM_IGNORED;
	
	}
	if(Get_BitVar(g_flying_mask,id)&&
		sh_get_user_has_hero(id,gHeroID)&&
		sh_get_id_bit(id,SH_IS_REBORN)&&
		!Get_BitVar(g_smashed_someone_mask,id)){
		
			sh_extra_damage(attacker, id, 1 + (floatround(clamp_macro(cvar_val(float, pcvar_ester_damage_reflect_coeff),0.1,1.0)*damage)),
				_,_,_,_,_,
				SH_NEW_DMG_SHOCK,
				generic_dmg_source_shock)


			directed_spark(id, attacker)
			damage=1.0 + (damage- (damage*clamp_macro(cvar_val(float, pcvar_ester_damage_reflect_coeff),0.1,1.0)))
			SetHamParamFloat(4, damage);
	
	}
	return HAM_IGNORED
}
inc_user_ester_respawn_attempts(id){
	
	if(is_user_connected(id)&&sh_is_active()&&sh_get_user_has_hero(id,gHeroID)){
		
		g_ester_respawned_attempts[id]=g_ester_respawned_attempts[id]<
				cvar_val(num, pcvar_ester_total_respawn_attempts)?
				g_ester_respawned_attempts[id]+1:
				cvar_val(num, pcvar_ester_total_respawn_attempts)
	
	}
	
}
public Ester_Knockback(id)
{
	if ( !sh_is_active() ||!is_user_alive(id)|| 
		!sh_get_id_bit(id,SH_IS_REBORN)) return HAM_IGNORED
	
	set_pdata_float(id, fPainShock, 1.0, 5)

	return HAM_IGNORED
}

remove_user_flight_fx(id, bool:remove_flight=true, bool:remove_songs=true){
	
	if(!is_user_connected(id)||!sh_get_user_has_hero(id,gHeroID)||!sh_is_active()) return
	
	if(remove_songs){
		if(g_ester_respawned_attempts[id]<=1){


			emit_sound(id, CHAN_AUTO, ESTER_FIRST_RESPAWN_SOUND , VOL_NORM, ATTN_NONE, SND_STOP, PITCH_NORM);

		
		
		}
		else if(g_ester_respawned_attempts[id]==((cvar_val(num,pcvar_ester_total_respawn_attempts)))){


			emit_sound(id, CHAN_AUTO, ESTER_LAST_RESPAWN_SOUND , VOL_NORM, ATTN_NONE, SND_STOP, PITCH_NORM);

		}
		else{
			

			emit_sound(id, CHAN_AUTO,ester_blowup_sounds[curr_player_sound[id]] , VOL_NORM, ATTN_NONE, SND_STOP, PITCH_NORM);

			
		}
	}
	if(remove_flight){
		kill_trails_on_user(id)
		emit_sound(id, CHAN_BODY,NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		UnSet_BitVar(g_flying_mask, id);
		sh_assign_id_bit(id,SH_USER_IS_FLYING, false)
	}
	
}

ester_set_reborn_mode_primitive(id,value){

	sh_assign_id_bit(id,SH_IS_REBORN, bool:value)

	Assign_BitVar(g_smashed_someone_mask,id,!value);
	Assign_BitVar(g_smashed_breakable_mask,id,!value);
	Assign_BitVar(g_is_desperate_mask, id, false_for_macro);
	Assign_BitVar(g_draining_mask, id, false_for_macro);
}

public _ester_set_reborn_mode(iPlugins,iParams){
	new id=get_param(1)
	new value=get_param(2)

	ester_set_reborn_mode_primitive(id,value)
}
public OnCmdStart(id, uc_handle)
{	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)||
			!sh_get_id_bit(id,SH_IS_REBORN)){
			return FMRES_IGNORED;
	}

	if(sh_get_stun(id)||sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||((sh_get_id_bit(id,SH_USER_IS_FLYING))&&!Get_BitVar(g_flying_mask,id))){
		if(Get_BitVar(g_flying_mask,id)){
			remove_user_flight_fx(id,_,false)
			
		}
		return FMRES_IGNORED;
	}
	static buttons,oldbuttons; 
	buttons = get_uc(uc_handle, UC_Buttons)
	
	oldbuttons = pev(id, pev_oldbuttons)
	if((buttons & IN_DUCK)&&(buttons &IN_JUMP))
	{ 
		if(!(oldbuttons & IN_DUCK)||!(oldbuttons &IN_JUMP)){
			static bool:not_weak=false;
			
			not_weak= (float(get_user_health(id)) > cvar_val(float,pcvar_ester_reborn_weak_mode_hp))
			
			if(not_weak){
				
				emit_sound(id, CHAN_AUTO, FLIGHT_IGNITION, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				trail(id,COLOR_STRONG,6,20)
				emit_sound(id, CHAN_BODY, FLIGHT_POWER, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
			}
			else{
				trail(id,COLOR_WEAK,1,10)
				emit_sound(id, CHAN_BODY, FLIGHT_HUM, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				
				
			}
			UnSet_BitVar(g_smashed_someone_mask,id);
			UnSet_BitVar(g_smashed_breakable_mask,id);
			if(!Get_BitVar(g_flying_mask,id)){
				Set_BitVar(g_flying_mask,id);
				sh_assign_id_bit(id,SH_USER_IS_FLYING, true)
				
			}
			Set_BitVar(g_draining_mask,id)
		}
		
	}
	else{
		if(Get_BitVar(g_flying_mask,id)){
			remove_user_flight_fx(id,_,false)
			
		}
		UnSet_BitVar(g_draining_mask,id)
		
		
	}
	return FMRES_IGNORED;
}

//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	
	engfunc(EngFunc_PrecacheSound,FLIGHT_HUM );
	engfunc(EngFunc_PrecacheSound,FLIGHT_POWER );
	engfunc(EngFunc_PrecacheSound,FLIGHT_IGNITION );
	engfunc(EngFunc_PrecacheSound,FLIGHT_WEAK );
	engfunc(EngFunc_PrecacheSound,ESTER_RESPAWN_FAIL_SOUND );
	engfunc(EngFunc_PrecacheSound,ESTER_FIRST_RESPAWN_SOUND );
	engfunc(EngFunc_PrecacheSound,ESTER_LAST_RESPAWN_SOUND );
	

	num_sounds = count_null_terminated_string_array(ester_blowup_sounds,
															"ester reborn sounds",
															"Filename",
															DEBUG)

	num_sentences = count_null_terminated_string_array(ester_sentences,
															"ester reborn sentences",
															"Sentence",
															DEBUG)

	precache_null_terminated_resource_list(ester_blowup_sounds,PRECACHE_SOUNDS, DEBUG)
	
}

public sh_client_spawn(id){


	emit_sound(id, CHAN_AUTO,ester_blowup_sounds[curr_player_sound[id]] , VOL_NORM, ATTN_NONE, SND_STOP, PITCH_NORM);

}
//---------------------------------------------------------------------------------------------- 

public sh_client_death(id, killer){
	if ( !sh_is_inround()){
		return PLUGIN_CONTINUE
	}
	new has_hero=sh_get_user_has_hero(id,gHeroID)
	if ( !is_user_connected(id) || !has_hero||!is_user_connected(killer)){
		return PLUGIN_CONTINUE
	}
	if(Get_BitVar(g_ester_is_denied_mask, id)){

		return PLUGIN_CONTINUE
	}
	ester_remove_statuses(id)
	if(killer==id){
		if(has_hero&&
				cvar_val(bool,pcvar_ester_anti_pussy_engaged)){
			
			deny_next_reborn(id)
			return PLUGIN_CONTINUE
			
		}
		else if(has_hero){
			
			sh_chat_message(id,gHeroID,ESTER_SUICIDE_SCOURN_MSG)
			
			
		}
	}
	g_ester_blow_up_time_left[id]=0.0

	g_which_team_is_user[id] = cs_get_user_team(id)

	// Save users origin on death
	pev(id,pev_origin, g_saved_coords[id])
	g_saved_coords[id][2] += 10.0

	// Look for self to raise from dead
	if ( !is_user_alive(id) && (g_ester_respawned_attempts[id]<
				cvar_val(num,pcvar_ester_total_respawn_attempts)) ) {
		new parm[2]
		parm[0] = id
		parm[1] = 0
		set_task(max_macro(PRE_RESPAWN_MESSAGE_RELAY,cvar_val(float,pcvar_ester_calculation_time_period)-PRE_RESPAWN_MESSAGE_RELAY), "ester_reborn_loop_task", id+ESTER_REBORN_CALCULATION_LOOP_TASKID, parm, sizeof(parm))
	}
	else if (!is_user_alive(id)){
		
		deny_next_reborn(id,false)

	}
	return PLUGIN_CONTINUE
}

public ester_reborn_loop_task(parm[2]){
	
	new id= parm[0]

	if ( !is_user_connected(id) || is_user_alive(id) ) return
	if ( !sh_get_user_has_hero(id,gHeroID)) return
	if ( (g_ester_respawned_attempts[id]>=
				cvar_val(num,pcvar_ester_total_respawn_attempts))||
				!sh_is_inround()) return
	if ( g_which_team_is_user[id]!= cs_get_user_team(id) ) return

	new Float:chance=generate_float(0.0,1.0)
	if(chance<(cvar_val(float,pcvar_ester_calculation_chance_numerator)/
						cvar_val(float,pcvar_ester_calculation_chance_denominator))){
	
		ester_respawn(parm)
		
	}
	else if(parm[1]<cvar_val(num,pcvar_ester_calculation_times)){

		parm[1]++
		set_task(max_macro(PRE_RESPAWN_MESSAGE_RELAY,cvar_val(float,pcvar_ester_calculation_time_period)-PRE_RESPAWN_MESSAGE_RELAY), "ester_reborn_loop_task", id+ESTER_REBORN_CALCULATION_LOOP_TASKID, parm, sizeof(parm))
	

	}
	
	
	
}


public client_disconnected(id){

	task_safeguard_macro_for_player_task(id,ESTER_REBORN_CALCULATION_LOOP_TASKID,SH_MAXSLOTS)
	
}
public client_connect(id){


	task_safeguard_macro_for_player_task(id,ESTER_REBORN_CALCULATION_LOOP_TASKID,SH_MAXSLOTS)
	
}
//----------------------------------------------------------------------------------------------
public ester_respawn(parm[2])
{
	new id = parm[0]
	if ( !is_user_connected(id) || is_user_alive(id) ) return
	if ( !sh_get_user_has_hero(id,gHeroID)) return
	if ( (g_ester_respawned_attempts[id]>=
				cvar_val(num,pcvar_ester_total_respawn_attempts))||
				!sh_is_inround()) return
	if ( g_which_team_is_user[id]!= cs_get_user_team(id) ) return

	sh_chat_message(id,gHeroID, "%s",ester_sentences[generate_int(0,num_sentences-1)])
	static user_name[128]
	get_user_name(id,user_name,127)
	sh_chat_message(0,gHeroID, "%s! They've been reborn!",user_name)
	sh_chat_message(id,gHeroID, "%d attempts to change left",
			cvar_val(num,pcvar_ester_total_respawn_attempts)-g_ester_respawned_attempts[id])

	// Double spawn prevents the no HUD glitch
	
	revival(id)
	revival(id)
	ester_set_reborn_mode_primitive(id,1)
	if(g_ester_respawned_attempts[id]<=0){


		emit_sound(id, CHAN_AUTO, ESTER_FIRST_RESPAWN_SOUND , VOL_NORM, ATTN_NONE, 0, PITCH_NORM);

	
	
	}
	else if(g_ester_respawned_attempts[id]==((cvar_val(num,pcvar_ester_total_respawn_attempts))-1)){


		emit_sound(id, CHAN_AUTO, ESTER_LAST_RESPAWN_SOUND , VOL_NORM, ATTN_NONE, 0, PITCH_NORM);

	}
	else{
		
		curr_player_sound[id]=generate_int(0,num_sounds-1,40)

		emit_sound(id, CHAN_AUTO,ester_blowup_sounds[curr_player_sound[id]] , VOL_NORM, ATTN_NONE, 0, PITCH_NORM);

		
	}
	inc_user_ester_respawn_attempts(id)
	g_ester_blow_up_time_left[id]=ESTER_REBORN_EXPLOSION_DELAY_TIME

	// Teleport the player
	set_pev(id, pev_origin,g_saved_coords[id])

	positionChangeTimer(id)
}
public godmode_timer_update(id){
	
	id-=ESTER_REBORN_GLOW_TASKID
	
	if(is_user_alive(id)&&sh_get_user_has_hero(id,gHeroID)&&sh_get_id_bit(id,SH_IS_REBORN)){
		
		if(!is_user_bot(id)){
			client_print(id,print_center,"Blowing up in %0.2f...",g_ester_blow_up_time_left[id])
		}
		g_ester_blow_up_time_left[id]-=FLIGHT_GODMODE_THINK_TIME
		
		if(g_ester_blow_up_time_left[id]>0.0){
			set_task(FLIGHT_GODMODE_THINK_TIME,"godmode_timer_update",id+ESTER_REBORN_GLOW_TASKID)
		}
		else{


			new param[1]
			param[0]=0
			BlowUp(param,id+ESTER_REBORN_EXPLOSION_DELAY_TASKID)
		}
	}
	
	
}
//----------------------------------------------------------------------------------------------
public sh_round_new(){

	g_ester_is_denied_mask = 0

}
public sh_round_end(){

	arrayset(g_ester_respawned_attempts,0,SH_MAXSLOTS+1)
	arrayset(g_ester_blow_up_time_left,0.0,SH_MAXSLOTS+1)
	g_flying_mask = 0
	// Reset the cooldown on round end, to start fresh for a new round
	for (new id = 1; id < sh_maxplayers()+1; id++) {
		if(is_user_connected(id)&&sh_get_user_has_hero(id,gHeroID)){
			ester_set_reborn_mode_primitive(id,0)
			ester_remove_statuses(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public positionChangeTimer(id)
{
	if(!sh_hull_vacant(id,g_saved_coords[id],HULL_HUMAN)){
		user_kill(id,1)
		sh_chat_message(id, gHeroID, ESTER_WALL_STUCK_MSG)
		deny_next_reborn(id)
		ester_remove_statuses(id)
		ester_set_reborn_mode_primitive(id,0)
	}
	else{


		sh_set_godmode(id,ESTER_REBORN_EXPLOSION_DELAY_TIME*0.5)

		godmode_timer_update(id+ESTER_REBORN_GLOW_TASKID)
	}
}
ester_remove_statuses(id, bool:remove_flight=true,bool:remove_songs=true){

	if(is_user_connected(id)&&sh_get_user_has_hero(id,gHeroID)){
		
		remove_task(id+ESTER_REBORN_EXPLOSION_DELAY_TASKID)
		remove_user_flight_fx(id,remove_flight,remove_songs)
	}
	
}
//----------------------------------------------------------------------------------------------
public BlowUp(param[1],id)
{
	id-=ESTER_REBORN_EXPLOSION_DELAY_TASKID

	if(!sh_is_freezetime()&&sh_is_inround()&&is_user_alive(id)&&
					sh_get_user_has_hero(id,gHeroID)&&
					(param[0]<ESTER_REBORN_EXPLOSION_NUMBER)&&
					sh_get_id_bit(id,SH_IS_REBORN)){
		
		param[0]++
		explosion(gHeroID,id,
			cvar_val(float,pcvar_ester_explosion_radius),
			cvar_val(float,pcvar_ester_explosion_damage)
			,_,
			cvar_val(bool,pcvar_ester_explosion_ignore_user),
			_,_,_,_,_,ester_rebirth_wpn_id,SH_NEW_DMG_ENERGY_BLAST)
		set_task(ESTER_REBORN_EXPLOSION_PERIOD,"BlowUp",id+ESTER_REBORN_EXPLOSION_DELAY_TASKID,param,1)
	}
	else{
		ester_remove_statuses(id,false,false)
	}
		
	
}
public revival(id)
{
	ExecuteHamB(Ham_Spawn, id) 
	if(is_user_alive(id)){
		setScreenFlash(id, 0, 0, 0, 0, 255 )  //Black flash indicating revival
	}
}
//----------------------------------------------------------------------------------------------
public ester_break_shit(pToucher,pTouched){

	if (pev_valid(pToucher)!=2){
		
		return
	}
	if (!is_user_alive(pToucher)){

		return
	}

	if (pev_valid(pTouched)<1){
		
		return
	}

	if (!sh_get_user_has_hero(pToucher,gHeroID)||
							Get_BitVar(g_smashed_breakable_mask,pToucher)||
							!sh_get_id_bit(pToucher,SH_IS_REBORN)||
							!Get_BitVar(g_flying_mask,pToucher)){

		return
	}
	Set_BitVar(g_smashed_breakable_mask, pToucher)
	sh_set_stun(pToucher,1.0,200.0)

	static Float:killer_velocity[3],Float:killer_origin[3],Float:killer_speed
	
	pev(pToucher, pev_origin,killer_origin)
	pev(pToucher, pev_velocity,killer_velocity)

	killer_speed=max_macro(1.0,vector_length(killer_velocity))

	explosion_custom_entity(pToucher,
							150.0,(0.2*killer_speed),
							"func_breakable",
							cvar_val(float, pcvar_ester_fly_knock_enemies_force))

	pev(pToucher, pev_velocity,killer_velocity)
	multiply_3d_vector_by_scalar(killer_velocity,0.5,killer_velocity)
	set_velocity_from_origin(pToucher,killer_origin,killer_speed)


}
public ester_charge_impact(pToucher, pTouched) {


if (pev_valid(pToucher)!=2){
	
	return
}
if (!is_user_alive(pToucher)){

	return
}

if (pev_valid(pTouched)<1){
	
	return
}

if (!sh_get_user_has_hero(pToucher,gHeroID)||
						Get_BitVar(g_smashed_someone_mask,pToucher)||
						!sh_get_id_bit(pToucher,SH_IS_REBORN)||
						!Get_BitVar(g_flying_mask,pToucher)||
						!cvar_val(bool, pcvar_ester_fly_knock_enemies)){

	return
}
if(!is_user_alive(pTouched)){
	
	return
}
if(pTouched==pToucher){

	return
}
if(sh_clients_are_same_team(pToucher,pTouched)){

	return
}

sh_set_stun(pToucher,1.0,200.0)

Set_BitVar(g_smashed_someone_mask, pToucher)
static Float:killer_velocity[3],Float:killer_origin[3],Float:killer_speed

pev(pToucher, pev_origin,killer_origin)
pev(pToucher, pev_velocity,killer_velocity)

killer_speed=max_macro(1.0,vector_length(killer_velocity))

explosion(gHeroID,pToucher,150.0,(0.2*killer_speed),
		cvar_val(float, pcvar_ester_fly_knock_enemies_force),1,
			_,_,_,_,_,_,SH_NEW_DMG_ENERGY_BLAST)

pev(pToucher, pev_velocity,killer_velocity)
multiply_3d_vector_by_scalar(killer_velocity,0.5,killer_velocity)
set_velocity_from_origin(pToucher,killer_origin,killer_speed)


}
