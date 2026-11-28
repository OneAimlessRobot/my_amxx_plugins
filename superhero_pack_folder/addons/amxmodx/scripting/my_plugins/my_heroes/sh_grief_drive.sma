#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MISC_FUNCS_2
#define I_WANT_BASIC_MACROS
#define I_WANT_CUSTOM_WEAPONS
#define I_WANT_PDATA_ALIASES
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_CUSTOM_COLORS
#define I_WANT_ENTITY_VECTORS
#define I_WANT_PRECACHE_UTILITIES
#define I_WANT_INIT_UTILITIES
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "grief_drive_inc/sh_grief_drive_psychosis.inc"
#include "jetplane_inc/sh_jetplane_funcs.inc"
#include "jetplane_inc/sh_grief_drive_get_set.inc"
#include "sh_aux_stuff/sh_pokemon_dmg_framework.inc"
#include "./superheromod_help_files_includes/superheromod_help_files.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt14.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt17.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt9.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"


stock num_sentences = 0
new grief_drive_sentences[][]={
	"Where are you... where... are you...",
	"Come out to plaaaaayyyy... There is NO WAY IM LETTING ANY OF YOU GO NOW!!!!!",
	"I hear their voices... I hear them... Then want... they want... red and black",
	"I want... all your blood. All of it.... and water the graves of my family with it.",
	""
}



static const DEBUG = 0


#define GRIEF_DRIVE_CYCLE "shmod/grief_drive/grief_drive_cycle3.wav"
#define GRIEF_DRIVE_PAIN "shmod/grief_drive/grief_drive_pain.wav"

#define GRIEF_DRIVE_SHOTGUN_V_MODEL "models/shmod/grief_drive/shotgun/v_grief_drive_shotgun.mdl"

#define GRIEF_DRIVE_KNIFE_V_MODEL "models/shmod/grief_drive/knife/v_knife.mdl"
#define GRIEF_DRIVE_KNIFE_P_MODEL "models/shmod/grief_drive/knife/p_knife.mdl"

#define GRIEF_DRIVE_PSYCHO_KNIFE_V_MODEL "models/shmod/grief_drive/knife/v_psycho_knife.mdl"
#define GRIEF_DRIVE_PSYCHO_KNIFE_P_MODEL "models/shmod/grief_drive/knife/p_psycho_knife.mdl"



#define GRIEF_DRIVE_WEAPON_CLASSID CSW_XM1014

new num_warcries = 0
new GRIEF_DRIVE_WARCRIES[][]={

  "shmod/grief_drive/Yuyoyuppe_-_Kyakkya.wav",
  "shmod/grief_drive/Yuyoyuppe_-_MAKKA.wav",
  "shmod/grief_drive/ozoi_x_yakui_maid_lanterns.wav",
  ""
  
}
new num_melancholy_sounds = 0
new melancholy_sounds[][]={

  "shmod/grief_drive/ozoi_x_yakui_maid_Y_X_O.wav",
  "shmod/grief_drive/Shinda_boku_no_kanojo_Hades_end_song.wav",
  ""
  
}
stock curr_player_sound[SH_MAXSLOTS+1],
		curr_melancholy_sound[SH_MAXSLOTS+1]


stock dmg_source_name_short_senpai_avenger[SAFE_BUFFER_SIZE+1]="senpai_avgr",
    dmg_source_name_log_senpai_avenger[SAFE_BUFFER_SIZE+1]="senpai_avenger",
    custom_dmg_id_senpai_avenger,
    
    dmg_source_name_short_drain[SAFE_BUFFER_SIZE+1]="slowburn",
    dmg_source_name_log_drain[SAFE_BUFFER_SIZE+1]="slowburn",
    custom_dmg_id_drain,


    dmg_source_name_short_rage[SAFE_BUFFER_SIZE+1]="manic_rage",
    dmg_source_name_log_rage[SAFE_BUFFER_SIZE+1]="manic_rage",
    custom_dmg_id_rage


#define GRIEF_DRIVE_CYCLE_PERIOD 0.33
#define GRIEF_DRIVE_TEAM_COUNT_MONITOR_PERIOD 0.5

// GLOBAL VARIABLES
//Replacing with bitmasks...

#define gHeroName "Grief Drive"


stock gSuperAngryMask
stock gIdleAngryMask
stock gPlayedSoundMask
stock g_is_cursed_masks[SH_MAXSLOTS+1]
stock bool:is_weapon_glowing[SH_MAXSLOTS+1]
stock gTransTimerStartedMask


stock g_mates_dead[SH_MAXSLOTS+1]
stock g_mates_alive[SH_MAXSLOTS+1]

new g_num_players = 0; 

stock g_curr_sound[SH_MAXSLOTS+1] = {-1, ...}



stock Float:gTransTimer[SH_MAXSLOTS+1]



#define GRIEF_DRIVE_STATS_MAX_MAGNITUDE 2


stock hud_sync
new Float:degen_iter_period

new can_jet_here = false

new pcvar_psychosis_degen_health_threshold,
pcvar_psychosis_degen_pct

new pcvar_angry_dmg_mult,
pcvar_angry_gravity,
pcvar_angry_degen_pct,
pcvar_angry_hitheal_pct,
pcvar_explode_radius,
pcvar_explode_maxdamage,
pcvar_curse_pct;
new pcvar_min_players
new pcvar_degen_health_extra_threshold
new pcvar_overheal_hp_max
new pcvar_trans_time
new generic_dmg_dark_arts = -1

#define GRIEF_DRIVE_SUPER_ANGRY_MONITOR_ENTITY_CLASSNAME "super_angry_monitor"
#define GRIEF_DRIVE_TRANSFORM_MONITOR_ENTITY_CLASSNAME "transform_monitor"
#define GRIEF_DRIVE_PLAYER_TEAM_COUNT_MONITOR_CLASSNAME "team_count_monitor"

new grief_drive_super_monitor_entity_id = -1,
	grief_drive_transform_monitor_entity_id = -1,
	grief_drive_team_count_monitor_entity_id = -1

new super_angry_forward_id = -1,
	grief_drive_transform_forward_id = -1,
	grief_drive_team_count_forward_id = -1
	
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO grief_drive", "1.0", AUTHOR)
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	create_cvar("grief_drive_level", "8")
	create_cvar("grief_drive_degen_iter_period", "0.1")
	pcvar_explode_radius = create_cvar("grief_drive_explode_radius", "1")
	pcvar_explode_maxdamage = create_cvar("grief_drive_explode_maxdamage", "1")
	pcvar_psychosis_degen_pct = create_cvar("grief_drive_psychosis_degen_pct", "20.0")
	pcvar_psychosis_degen_health_threshold = create_cvar("grief_drive_psychosis_degen_health_threshold", "50.0")
	pcvar_trans_time = create_cvar("grief_drive_trans_time", "4.0")
	pcvar_curse_pct = create_cvar("grief_drive_angry_curse_pct", "0.5")
	pcvar_angry_gravity = create_cvar("grief_drive_angry_gravity", "0.25")
	pcvar_angry_dmg_mult = create_cvar("grief_drive_angry_dmg_mult", "5.0")
	pcvar_angry_degen_pct = create_cvar("grief_drive_angry_degen_pct", "10.0")
	pcvar_overheal_hp_max = create_cvar("grief_drive_overheal_hp_max", "1000.0")
	pcvar_degen_health_extra_threshold = create_cvar("grief_drive_degen_health_extra_threshold", "500.0")
	pcvar_angry_hitheal_pct = create_cvar("grief_drive_angry_hitheal_pct", "1.0")
	pcvar_min_players = create_cvar("grief_drive_min_players", "6")
	gHeroID=shCreateHero(gHeroName, "Grief driven!", "Protect live teamates and avenge dead ones!", true, "grief_drive_level" )
	
	can_jet_here = (sh_test_map_name_here(true,"cs_assault")||sh_test_map_name_here(true,"starwars"))

	sh_assign_hero_bit(gHeroID,SH_EXPLOSION_POWERS, true)


	sh_register_admin_only_hero(gHeroID,ADMIN_IMMUNITY,13,
				"No access was granted")


	superheromod_help_link_hero(gHeroID, "Grief Drive: Help file","grief_drive_folder/","grief_drive_help_file.html")
	
	sh_register_superheromod_model(gHeroID,
								"models/player/yanderu/yanderu.mdl",
								"models/player/yanderu/yanderuT.mdl",
								"yanderu",
								"",
								"")
	sh_register_superheromod_model(gHeroID,
								"models/player/superyanderu/superyanderu.mdl",
								"models/player/superyanderu/superyanderuT.mdl",
								"superyanderu",
								"",
								"")
	sh_register_superheromod_model(gHeroID,
								"models/player/yanderu_psycho/yanderu_psycho.mdl",
								"models/player/yanderu_psycho/yanderu_psycho.mdl",
								"yanderu_psycho",
								"",
								"")

	register_event("CurWeapon", "weaponChange", "be", "1=1")

	RegisterHam(Ham_TakeDamage, "player", "grief_drive_damage",1,true)

	RegisterHam(Ham_TakeDamage,"player","grief_drive_ham_knife_damage",1,true)

	register_ham_hook_multiple(Ham_TraceAttack,
						full_entity_array_for_trace_attack,
						length_of_trace_attack_entity_array,
						"grief_drive_fire_Weapon",
						1,
						true)
	

	register_forward(FM_CmdStart, "grief_drive_angry_idle_checks")

	custom_dmg_id_senpai_avenger=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_senpai_avenger,
								dmg_source_name_log_senpai_avenger,
								0)

	custom_dmg_id_drain=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_drain,
								dmg_source_name_log_drain,
								0)

	custom_dmg_id_rage=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_rage,
								dmg_source_name_log_rage,
								0)

	init_hud_syncs()

	init_monitor_entity_based_global(GRIEF_DRIVE_TRANSFORM_MONITOR_ENTITY_CLASSNAME, "grief_drive_loop", GRIEF_DRIVE_CYCLE_PERIOD,
											grief_drive_transform_monitor_entity_id,
											grief_drive_transform_forward_id)

	init_monitor_entity_based_global(GRIEF_DRIVE_PLAYER_TEAM_COUNT_MONITOR_CLASSNAME, "grief_drive_team_count_monitor_callback", GRIEF_DRIVE_TEAM_COUNT_MONITOR_PERIOD,
											grief_drive_team_count_monitor_entity_id,
											grief_drive_team_count_forward_id)

}


public plugin_natives(){

	register_native("grief_drive_get_is_super","_grief_drive_get_is_super");
	register_native("grief_drive_get_hero_id","_grief_drive_get_hero_id");



}
public _grief_drive_get_hero_id(iPlugin,iParams){
	
	return gHeroID

}
public _grief_drive_get_is_super(iPlugin,iParams){
	new id= get_param(1)
	
	//return gSuperAngry[id]
	return Get_BitVar(gSuperAngryMask,id)

}

public grief_drive_angry_idle_checks(id, uc_handle){

	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)) return FMRES_IGNORED

	if(!sh_get_user_has_hero(id,gHeroID) ||!Get_BitVar(gSuperAngryMask,id)) return FMRES_IGNORED
	static butnprs

	Set_BitVar(gIdleAngryMask,id)
	butnprs =  get_uc(uc_handle, UC_Buttons);

	if (butnprs&IN_ATTACK || butnprs&IN_ATTACK2 || butnprs&IN_RELOAD || butnprs&IN_USE) UnSet_BitVar(gIdleAngryMask,id)

	if (butnprs&IN_JUMP) UnSet_BitVar(gIdleAngryMask,id)
	if (butnprs&IN_FORWARD || butnprs&IN_BACK || butnprs&IN_LEFT || butnprs&IN_RIGHT) UnSet_BitVar(gIdleAngryMask,id)
	if (butnprs&IN_MOVELEFT || butnprs&IN_MOVERIGHT) UnSet_BitVar(gIdleAngryMask,id)

	return FMRES_IGNORED

}
public grief_drive_ham_knife_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(damage <= 0.0){

		return HAM_IGNORED
	}	

	if(attacker == id) return HAM_IGNORED 
	
	if ( !sh_is_active() || !is_user_alive(id)||!is_user_alive(attacker)){

		return HAM_IGNORED
	}

	new my_hitpoint_enum:the_hitpoint = my_hitpoint_enum:get_pdata_int(id, m_iLastHitGroup, XO_PLAYER)
	
	pev(id, pev_dmg_take, damage)

	return do_bleed_knife_attack(id,attacker,gHeroID,15,65,
				sh_get_user_has_hero(attacker,gHeroID) && Get_BitVar(gSuperAngryMask,attacker),_,_,_,the_hitpoint)

	
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
	if(heroID!=gHeroID) return

	if(sh_get_user_has_hero(id,gHeroID) ){
		
		UnSet_BitVar(gPlayedSoundMask,id)
		
	}
	else{
		killgrief_drive(id,true)
	}
	
	
}

public get_first_alive(){


static the_players[SH_MAXSLOTS], pnum	
get_players(the_players, pnum, "ah")
for (new k = 0; k < pnum; k++) {
	//will immediatly return valid value if pnum is >0
	return the_players[k]
}
return -1;


}

public grief_drive_team_count_monitor_callback(entity_id){

	if(!is_valid_ent(entity_id)){

		return PLUGIN_CONTINUE
	}
	if(!sh_is_active()){

		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + GRIEF_DRIVE_TEAM_COUNT_MONITOR_PERIOD)
		return PLUGIN_CONTINUE
	}
	if(sh_is_freezetime()){
		
		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + GRIEF_DRIVE_TEAM_COUNT_MONITOR_PERIOD)
		return PLUGIN_CONTINUE
	}
	
	static the_players[SH_MAXSLOTS], pnum, id	
	g_num_players = get_playersnum(0)
	get_players(the_players, pnum, "ah")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]

		if(!sh_get_user_has_hero(id,gHeroID) ){
			continue;
		}
		sh_get_player_counts(id,1,g_mates_alive[id],g_mates_dead[id],true)

		new bool:can_transform= (g_num_players>=cvar_val(num,pcvar_min_players))&&(g_mates_alive[id]<=0)
		if(can_transform && !Get_BitVar(gSuperAngryMask,id) && sh_is_inround() &&!sh_is_freezetime()){

			Set_BitVar(gTransTimerStartedMask,id)
			
		}
		else{

			UnSet_BitVar(gTransTimerStartedMask,id)
			if(DEBUG){
				sh_chat_message(id,gHeroID,"Timer interrupted?")
			}
		}
	}

	entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + GRIEF_DRIVE_TEAM_COUNT_MONITOR_PERIOD)
	return PLUGIN_CONTINUE

}


public grief_drive_sentence_loop(entity_id){
	
	if(!is_valid_ent(entity_id)){

		return PLUGIN_CONTINUE
	}
	if(!sh_is_active()){

		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + degen_iter_period)
		return PLUGIN_CONTINUE
	}
	if(sh_is_freezetime()){
		
		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + degen_iter_period)
		return PLUGIN_CONTINUE
	}
	if(!sh_is_inround()){
		
		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + degen_iter_period)
		return PLUGIN_CONTINUE
	}

	static the_players[SH_MAXSLOTS], pnum, id
	get_players(the_players, pnum, "ah")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]

		if(sh_get_user_has_hero(id,gHeroID) &&Get_BitVar(gSuperAngryMask,id)){

			if(Get_BitVar(gIdleAngryMask,id)||(get_user_health(id)>
						cvar_val(num,pcvar_degen_health_extra_threshold))){
				
				static client_name[128]
				new user_health=get_user_health(id)
				new degen_dmg_2_take= (float(user_health)>cvar_val(float, pcvar_psychosis_degen_pct))?
											floatround((float(user_health)-cvar_val(float, pcvar_psychosis_degen_health_threshold))*
														degen_iter_period*
														0.01*
														(sh_get_id_bit(id,SH_IS_PSYCHOSIS)?cvar_val(float, pcvar_psychosis_degen_pct):
															cvar_val(float,pcvar_angry_degen_pct)),floatround_ceil)*
														(Get_BitVar(gIdleAngryMask,id)?2:1):0
	
				if(degen_dmg_2_take>0){
					static client_origin[3]
					get_user_origin(id,client_origin)
					new Float:floatalpha=25.0+max_macro(0.0,min_macro(190.0,255.0*(float(user_health)/float(cvar_val(num,pcvar_overheal_hp_max)))))
					set_render_with_color_const(id,SEVERE_RED,0,_,floatround(floatalpha),1,0,2.5,0,_,kRenderNormal,PRIO_RENDER_INFORMATIVE,gHeroID)
					
					sh_extra_damage(id,id,degen_dmg_2_take,
									MY_HIT_HEAD,
									_,_,_,_,
									SH_NEW_DMG_HEALTH_SET,custom_dmg_id_drain)
					
					fx_bleed(client_origin)
					if(degen_iter_period>1.0){
							get_user_name(id,client_name,127)
							emit_sound(id, CHAN_AUTO, GRIEF_DRIVE_CYCLE, 1.0, 0.0, 0, PITCH_NORM)
							sh_chat_message(0,gHeroID,"%s: %s",client_name,grief_drive_sentences[generate_int(0,num_sentences-1)])
					}
				}
				
			}
		}
	}
	entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + degen_iter_period)
	return PLUGIN_CONTINUE
}
public grief_drive_loop(entity_id){

	if(!is_valid_ent(entity_id)){

		return
	}
	if(!sh_is_active()){

		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + GRIEF_DRIVE_CYCLE_PERIOD)
	}
	if(sh_is_freezetime()){
		
		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + GRIEF_DRIVE_CYCLE_PERIOD)
	}


	static the_players[SH_MAXSLOTS], pnum, id	
	get_players(the_players, pnum, "ah")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]

		if(!sh_get_user_has_hero(id,gHeroID)){
			continue
		}
		if(!is_user_bot(id)&&Get_BitVar(gTransTimerStartedMask,id)){
			client_print(id,print_center,"All teamates died! Grief will take over in... %0.2fs^n",gTransTimer[id])
		}
		grief_drive_timer_transform(id)
	}

	entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + GRIEF_DRIVE_CYCLE_PERIOD)
}

update_grief_drives_stats(CsTeams:the_team,bool:died_or_spawned,id_to_exclude=-1){

	static the_players[SH_MAXSLOTS], pnum, id	
	g_num_players = get_playersnum(0)
	get_players(the_players, pnum, "ah")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]

		if(!sh_get_user_has_hero(id,gHeroID) ){
			continue;
		}
		static CsTeams:curr_grief_drives_team = CS_TEAM_UNASSIGNED;

		curr_grief_drives_team = cs_get_user_team(id)

		if(curr_grief_drives_team!=the_team){

			continue
		}
		if(is_user_connected(id_to_exclude)&&(id_to_exclude==id)){
			
			continue

		}

		update_stats(id,died_or_spawned)
	}
}

update_stats(id, bool:go_up_or_go_down){

	if(!is_user_alive(id)) return
	if(!sh_get_user_has_hero(id,gHeroID) ) return
	if(go_up_or_go_down){
		if(sh_check_player_boost_stage(id, STAT_SPEED_MULT)<GRIEF_DRIVE_STATS_MAX_MAGNITUDE){

			sh_apply_staged_stat_boost(id,id,STAT_SPEED_MULT, 1, true)

		}
		if(sh_check_player_boost_stage(id, STAT_DEFENSE_MULT)>-GRIEF_DRIVE_STATS_MAX_MAGNITUDE){
			
			sh_apply_staged_stat_boost(id,id,STAT_DEFENSE_MULT, 1, false)
		
		}
		if(sh_check_player_boost_stage(id, STAT_ATTACK_MULT)<GRIEF_DRIVE_STATS_MAX_MAGNITUDE){
			
			sh_apply_staged_stat_boost(id,id,STAT_ATTACK_MULT, 1, true)
		
		}
	}
	else{

		if(sh_check_player_boost_stage(id, STAT_SPEED_MULT)>0){

			sh_apply_staged_stat_boost(id,id,STAT_SPEED_MULT, 1, false)

		}
		if(sh_check_player_boost_stage(id, STAT_DEFENSE_MULT)<GRIEF_DRIVE_STATS_MAX_MAGNITUDE){
			
			sh_apply_staged_stat_boost(id,id,STAT_DEFENSE_MULT, 1, true)
		
		}
		if(sh_check_player_boost_stage(id, STAT_ATTACK_MULT)>0){
			
			sh_apply_staged_stat_boost(id,id,STAT_ATTACK_MULT, 1, false)
		
		}

	}
}
public grief_drive_timer_transform(id){
	
	if(Get_BitVar(gSuperAngryMask,id)){

		new Float:gravity=get_user_gravity(id)
		set_user_gravity(id,min_macro(cvar_val(float,pcvar_angry_gravity),gravity))
		if(g_mates_alive[id]>0){

			UnSet_BitVar(gSuperAngryMask,id)
			sh_reset_min_gravity(id)
			sh_reset_player_stat_boosts(id,id)
			sh_apply_staged_stat_boost(id,id,STAT_DEFENSE_MULT,1,true)
			sh_chat_message(0,gHeroID,"Hah... What happened?");
			UnSet_BitVar(gPlayedSoundMask,id)
			if(user_has_weapon(id,GRIEF_DRIVE_WEAPON_CLASSID)){
				sh_drop_weapon(id, GRIEF_DRIVE_WEAPON_CLASSID,true)
			}

			emit_sound(id, CHAN_AUTO, GRIEF_DRIVE_WARCRIES[curr_player_sound[id]],
				VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		}
	}
	else{
		UnSet_BitVar(gIdleAngryMask,id)
		if(Get_BitVar(gTransTimerStartedMask,id)){

			gTransTimer[id]-= GRIEF_DRIVE_CYCLE_PERIOD
			if((gTransTimer[id]<=0.0)){
				
				Set_BitVar(gSuperAngryMask,id)
				sh_reset_min_gravity(id)
				sh_reset_player_stat_boosts(id,id)
				sh_apply_staged_stat_boost(id,id,STAT_SPEED_MULT,-GRIEF_DRIVE_STATS_MAX_MAGNITUDE,true)
				sh_apply_staged_stat_boost(id,id,STAT_DEFENSE_MULT,GRIEF_DRIVE_STATS_MAX_MAGNITUDE,false)
				sh_apply_staged_stat_boost(id,id,STAT_ATTACK_MULT,GRIEF_DRIVE_STATS_MAX_MAGNITUDE+1,true)
				if(!Get_BitVar(gPlayedSoundMask,id)){
					static client_name[128]
					get_user_name(id,client_name,127)
					sh_chat_message(0,gHeroID,"%s: Ok. NOW Im mad!",client_name);
					
					emit_sound(id, CHAN_AUTO, melancholy_sounds[curr_melancholy_sound[id]],VOL_NORM,ATTN_NORM,SND_STOP,PITCH_NORM)

					emit_sound(id, CHAN_AUTO, GRIEF_DRIVE_WARCRIES[curr_player_sound[id]],VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
					curr_player_sound[id]=generate_int(0,num_warcries-1)
					emit_sound(id, CHAN_AUTO, GRIEF_DRIVE_WARCRIES[curr_player_sound[id]], 1.0, 0.0, 0, PITCH_NORM)
					Set_BitVar(gPlayedSoundMask,id)
				}
				gTransTimer[id]=cvar_val(float,pcvar_trans_time)
			}
		}
		else if(gTransTimer[id]>=cvar_val(float,pcvar_trans_time)){

			gTransTimer[id]=cvar_val(float,pcvar_trans_time)
		}
		if(Get_BitVar(gSuperAngryMask,id)&&is_user_alive(id)){
			UnSet_BitVar(gTransTimerStartedMask,id)
			BlowUp(id)
			if(can_jet_here){
				jet_destroy(id)
			}
			if(!sh_is_freezetime()){
				if(!user_has_weapon(id,GRIEF_DRIVE_WEAPON_CLASSID)){
					sh_give_weapon(id, GRIEF_DRIVE_WEAPON_CLASSID,true)
					is_weapon_glowing[id]=false
				}
			}
		}
	}

}

public client_disconnected(id){


	killgrief_drive(id,true)

	
}

//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
loadCVARS();
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
degen_iter_period=get_cvar_float("grief_drive_degen_iter_period")
generic_dmg_dark_arts = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_DARK_ARTS)


init_monitor_entity_based_global(GRIEF_DRIVE_SUPER_ANGRY_MONITOR_ENTITY_CLASSNAME, "grief_drive_sentence_loop", degen_iter_period,
										grief_drive_super_monitor_entity_id,
										super_angry_forward_id)

}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id, bool:newRound)
{	
	if(is_user_alive(id) && sh_is_active()){
		g_is_cursed_masks[id]=0
		if ( sh_get_user_has_hero(id,gHeroID) ) {
			
			sh_drop_weapon(id, GRIEF_DRIVE_WEAPON_CLASSID,true)
			grief_drive_unpsychosis_user(id)
			sh_end_cooldown(id+SH_COOLDOWN_TASKID);
			UnSet_BitVar(gSuperAngryMask,id);
			UnSet_BitVar(gPlayedSoundMask,id);
			gTransTimer[id]=cvar_val(float,pcvar_trans_time);
			UnSet_BitVar(gTransTimerStartedMask,id)
			emit_sound(id, CHAN_AUTO, GRIEF_DRIVE_CYCLE, 1.0, 0.0, SND_STOP, PITCH_NORM)
			emit_sound(id, CHAN_VOICE, GRIEF_DRIVE_PAIN, 1.0, 0.0, SND_STOP, PITCH_NORM)

		}
		if(!newRound){
			notify_grief_drives_about_life(id,false)
		}
		else{

			emit_sound(id, CHAN_AUTO, melancholy_sounds[curr_melancholy_sound[id]],VOL_NORM,ATTN_NORM,SND_STOP,PITCH_NORM)

			emit_sound(id, CHAN_AUTO, GRIEF_DRIVE_WARCRIES[curr_player_sound[id]],VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		}
	}
	
}
public grief_drive_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(damage <= 0.0){

		return HAM_IGNORED
	}
	if ( !sh_is_active() || !is_user_alive(id) || !is_user_alive(attacker)) return HAM_IGNORED

	if(sh_clients_are_same_team(id,attacker)||(id==attacker)){
		return HAM_IGNORED
	}
	new bool:victim_has_hero = bool:sh_get_user_has_hero(id,gHeroID),
	bool:attacker_has_hero = bool:sh_get_user_has_hero(attacker,gHeroID)

	if(!victim_has_hero&&!attacker_has_hero) return HAM_IGNORED

	new return_result= HAM_IGNORED

	new my_hitpoint_enum:the_hitpoint = my_hitpoint_enum:get_pdata_int(id, m_iLastHitGroup, XO_PLAYER)

	new weapon = get_user_weapon(attacker)

	pev(id, pev_dmg_take, damage)


	static attacker_name[128],client_name[128]
	get_user_name(attacker,attacker_name,127)
	get_user_name(id,client_name,127)

	if ( attacker_has_hero ) {
		if(Get_BitVar(gSuperAngryMask,attacker)){
			new Float:extraDamage = damage * cvar_val(float, pcvar_angry_dmg_mult) - damage
			if (floatround(extraDamage) > 0){

				static sh_extra_damage_result:dmg_result; dmg_result =
							sh_extra_damage(id, attacker, floatround(extraDamage),
							the_hitpoint,
							_,_,_,_,
							SH_NEW_DMG_DARK_ARTS,
							Get_BitVar(gSuperAngryMask,attacker)&&(weapon==GRIEF_DRIVE_WEAPON_CLASSID)?
							custom_dmg_id_senpai_avenger
							:
							custom_dmg_id_rage)

				sh_set_stun(id,2.0)
			
				generic_heal(attacker,extraDamage*
					cvar_val(float,pcvar_angry_hitheal_pct),
					cvar_val(num,pcvar_overheal_hp_max),RED,1,_,70,1)
				if(dmg_result == SH_DMG_RESULT_DMG_KILLED_OPPONENT){
					static Float:origin[3];
					// player fades.. 
					set_user_rendering(id, kRenderFxFadeSlow, 255, 255, 255, kRenderTransColor, 4); 
					entity_get_vector(id,EV_VEC_origin,origin)
					anime_kill_fx(origin)
					
				}
				if((weapon==CSW_KNIFE)){
					

					if(!Get_BitVar(g_is_cursed_masks[attacker],id)){
						
						Set_BitVar(g_is_cursed_masks[attacker],id)
						
						if(!is_user_bot(attacker)){
							sh_chat_message(attacker,gHeroID,"%s has been cursed!",client_name)
						}
					
						if(!is_user_bot(id)){
							sh_chat_message(id,gHeroID,"%s has put a curse on you!",attacker_name)
						}
					}
					
					
				
				}
			}
		}	
		
	}
	if( victim_has_hero && is_user_alive(attacker)&& !sh_get_id_bit(attacker, SH_CONTROLLING_VEHICLE)){

		if(Get_BitVar(g_is_cursed_masks[id],attacker)){
			
			new Float:obtained_float = generate_float(0.0,1.0,40)
			new Float:upper=max_macro(0.01,(1.0 -cvar_val(float,pcvar_curse_pct)))

			if(obtained_float> upper){
				set_user_godmode(attacker,0)
				sh_extra_damage(attacker,id,1,_,
							SH_DMG_KILL,
							_,_,_,
							SH_NEW_DMG_HEALTH_SET,
							generic_dmg_dark_arts)
				UnSet_BitVar(g_is_cursed_masks[id],attacker)
			}
		}
	
	
	}
	return return_result
}
public plugin_precache()
{




	num_sentences = count_null_terminated_string_array(grief_drive_sentences,
															"grief_drive rambling sentences",
															"Sentence",
															DEBUG)

	num_warcries = count_null_terminated_string_array(GRIEF_DRIVE_WARCRIES,
															"grief_drive warcry sounds",
															"Filename",
															DEBUG)

	precache_null_terminated_resource_list(GRIEF_DRIVE_WARCRIES,PRECACHE_SOUNDS, DEBUG)
	

	num_melancholy_sounds = count_null_terminated_string_array(melancholy_sounds,
															"grief_drive melancholy sounds",
															"Filename",
															DEBUG)

	precache_null_terminated_resource_list(melancholy_sounds,PRECACHE_SOUNDS, DEBUG)

	engfunc(EngFunc_PrecacheSound,GRIEF_DRIVE_CYCLE)
	engfunc(EngFunc_PrecacheSound,GRIEF_DRIVE_PAIN)
	
	engfunc(EngFunc_PrecacheModel,GRIEF_DRIVE_SHOTGUN_V_MODEL)
	engfunc(EngFunc_PrecacheModel,GRIEF_DRIVE_KNIFE_V_MODEL)
	engfunc(EngFunc_PrecacheModel,GRIEF_DRIVE_KNIFE_P_MODEL)
	engfunc(EngFunc_PrecacheModel,GRIEF_DRIVE_PSYCHO_KNIFE_V_MODEL)
	engfunc(EngFunc_PrecacheModel,GRIEF_DRIVE_PSYCHO_KNIFE_P_MODEL)

	
	
}


//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		grief_drive_kd(id)
	}
	
	case SH_KEYUP: {
		
		grief_drive_ku(id)
	}
}
}
public grief_drive_kd(id)
{
	
	if ( !is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)||!sh_is_inround()||sh_is_freezetime()||!sh_is_active() ||Get_BitVar(gTransTimerStartedMask,id) ) {


			return

	}

	if(Get_BitVar(gSuperAngryMask,id)){
		if ( sh_get_cooldown_flag(id)||
				sh_get_id_bit(id,SH_IS_PSYCHOSIS) ) {
			
			if(!is_user_bot(id)){
				sh_sound_deny(id)
			}
			return
		}
		static client_name[128]
		get_user_name(id,client_name,charsmax(client_name))
		sh_chat_message(0,gHeroID,"%s LOST IT!!!!!",client_name)
		grief_drive_psychosis_user(id)
	}
	else{
		
		if(can_jet_here){
			new bool:jet_deployed_here=bool:jet_deployed(id)
			if(!jet_loaded(id)&&!jet_deployed_here){

				if(!is_user_bot(id)){
					sh_sound_deny(id)
				}
				return
				
			}

			if(jet_deployed_here){
				
				jet_destroy(id,true,id)
				
				if(!is_user_bot(id)){
					sh_chat_message(id, gHeroID, "You J-ed out!!")
				}

				sh_reset_min_gravity(id)
				return
				
			}
			grief_drive_jet_charge_user(id)
		
		
		}
		else{


			if(!is_user_bot(id)){
				
				sh_chat_message(id, gHeroID, "You cannot use a jet here. the map is too small!")
				sh_sound_deny(id)
			}
			return
		}
	}
}
//----------------------------------------------------------------------------------------------
public grief_drive_ku(id)
{
	
	if ( !is_user_alive(id) ||!sh_get_user_has_hero(id,gHeroID)  ||Get_BitVar(gTransTimerStartedMask,id) ) {
		return
	}
	if(!can_jet_here){
		return
	}
	
	if(!jet_deployed(id)){
		
		grief_drive_jet_uncharge_user(id)
	}
}
public sh_round_end(){
	
	if(can_jet_here){
		
		static the_players[SH_MAXSLOTS], pnum, id

		get_players(the_players, pnum, "ah")

		for (new k = 0; k < pnum; k++) {

			id = the_players[k]
			if(sh_get_user_has_hero(id,gHeroID) ){
		
				jet_destroy(id)
		
			}
		
		}
	}
	new total_alive,total_dead;
	sh_get_player_counts(0,0,total_alive,total_dead)
	
	if(total_alive>1){
		return;
		
	}
	new last_alive=get_first_alive()
	if(!is_user_alive(last_alive)) return
	if(sh_get_user_has_hero(last_alive,gHeroID) && Get_BitVar(gSuperAngryMask,last_alive) ){
		static client_name[128]
		get_user_name(last_alive,client_name,charsmax(client_name))
		sh_chat_message(0,gHeroID,"%s : What... have I done...",client_name)

		emit_sound(last_alive, CHAN_AUTO, GRIEF_DRIVE_WARCRIES[curr_player_sound[last_alive]],VOL_NORM,ATTN_NORM,SND_STOP,PITCH_NORM)
		

		emit_sound(last_alive, CHAN_AUTO, melancholy_sounds[curr_melancholy_sound[last_alive]],VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);

		curr_melancholy_sound[last_alive]=generate_int(0,num_melancholy_sounds-1)

		emit_sound(last_alive, CHAN_AUTO, melancholy_sounds[curr_melancholy_sound[last_alive]], 1.0, 0.0, 0, PITCH_NORM)
		
	}
}

public grief_drive_fire_Weapon(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	generic_weapon_tracer_logic(Attacker,bool:Get_BitVar(gSuperAngryMask,Attacker),_,gHeroID,sh_custom_color:{RED,RED,RED})

}

killgrief_drive(id,bool:dropping=false){
	
	if(!is_user_connected(id)||!sh_is_active()) return
	if(sh_get_user_has_hero(id,gHeroID) ||dropping){
		
		if(Get_BitVar(gSuperAngryMask,id)){
			if(sh_get_user_has_hero(id,gHeroID)){
				static Float:origin[3]
				entity_get_vector(id,EV_VEC_origin,origin)
				fx_invisible(id)
				anime_kill_fx(origin)
			}
			for(new i=1;i< sh_maxplayers()+1;i++){
				UnSet_BitVar(g_is_cursed_masks[i],id)
			}
			if(sh_get_id_bit(id,SH_IS_PSYCHOSIS)){
				grief_drive_unpsychosis_user(id)
			}
		}
		else if(jet_deployed(id)&&can_jet_here){
			
			jet_destroy(id);
		}
		UnSet_BitVar(gSuperAngryMask,id)
		sh_reset_min_gravity(id)
		sh_reset_max_speed(id)
		
		
	}
	g_is_cursed_masks[id]=0
}
public notify_grief_drives_about_life(id,bool:died_true_or_spawned_false){

	static CsTeams:the_team; the_team = cs_get_user_team(id)
	
	static id_to_exclude = -1;

	id_to_exclude = (sh_get_user_has_hero(id,gHeroID)?id:-1)


	update_grief_drives_stats(the_team,died_true_or_spawned_false,id_to_exclude)

}
public sh_client_death(id){
	

	notify_grief_drives_about_life(id, true)
	killgrief_drive(id)
}

//----------------------------------------------------------------------------------------------
public BlowUp(id)
{
	explosion(gHeroID,id,
		cvar_val(float,pcvar_explode_radius),
		cvar_val(float,pcvar_explode_maxdamage)
		,_,1,
		_,_,_,_,_,_,_,true)
	
}
//----------------------------------------------------------------------------------------------

public weaponChange(id)
{
	if (!sh_is_active()) return
	if(!sh_get_user_has_hero(id,gHeroID) ) return

	
	if (!Get_BitVar(gSuperAngryMask,id)) return
	
	static wpnid; wpnid = read_data(2)
	
	if (wpnid == GRIEF_DRIVE_WEAPON_CLASSID) {

		set_pev(id, pev_viewmodel2,GRIEF_DRIVE_SHOTGUN_V_MODEL)
		if(!is_weapon_glowing[id]){
			trail(id,PINK,3,5,160)
			set_render_with_color_const(id, PINK,1,24,
							30,
							_,_,
							1.0,_,_,kRenderNormal,PRIO_RENDER_INFORMATIVE)
							
			is_weapon_glowing[id] = true
		}
	}
	else{
		kill_all_entity_beams(id)
		is_weapon_glowing[id] = false
		
		if (wpnid == CSW_KNIFE) {
			if(sh_get_id_bit(id,SH_IS_PSYCHOSIS)){
				set_pev(id, pev_viewmodel2,GRIEF_DRIVE_PSYCHO_KNIFE_V_MODEL)
				set_pev(id, pev_weaponmodel2,GRIEF_DRIVE_PSYCHO_KNIFE_P_MODEL)
			}
			else{
			
				set_pev(id, pev_viewmodel2,GRIEF_DRIVE_KNIFE_V_MODEL)
				set_pev(id, pev_weaponmodel2,GRIEF_DRIVE_KNIFE_P_MODEL)
			
			}
		}
	}
}