/*
	
    the objective is to not make the game depend on this one.
    that is one constraint.
    the other is that the main formula for damage will be inspired by the one used by game freak


    special boosts mess with damage of special superhero damage and grenades

    physical boosts mess with damage of physical hero damage (and generic. I will classify generic dmg as physical)
    and normal hitscan gun + knife damage.


    I wont do speed boosts yet as coordinating boosts is hard.

    I will implement evasiveness boosts by using my cloak management function.

    your invisibility will go down or up depending on whether you have less or more evasiveness


    there will be no critical hits as that is stupid

    each boost will lower or increase a stat by increasing the user's current stat multiplier by 0.5.

    at 1.0 multiplier in physical damage, the player does twice the damage

    at 0.0 multiplier, no damage is changed



    stats that are planned for this release:

    - evasiveness (invisibility)

    - attack / defense (physical)

    - attack / defense (special)

    - speed (maybe later)

    ok lets start


*/

#define I_WANT_CONSTANTS
#define I_WANT_MATH_FUNCS_PT2
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#define I_WANT_PDATA_ALIASES
#define I_WANT_INIT_UTILITIES
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "SH_PKMN_Framework"

#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_pokemon_dmg_framework.inc"
#include "sh_aux_stuff/sh_pokemon_dmg_framework_consts.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "../my_include/auxiliar_stuff.inc"

#define ACTIVATE_POKEMON_DMG_CVAR "sh_use_pokemon_damage"

#define DAMAGE_DAMPENING_DIVIDER 10.5
#define POKEMON_DAMAGE_RELATION_BALLAST_VAL 0.20
#define POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_NUMERATOR 0.0001
#define POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_DENOMINATOR 10.0

#define MAX_PLAYER_STAT_STAGES 6

#define STAT_UP_SFX "shmod/pokemon_stat_up_sfx.wav"

#define STAT_DOWN_SFX "shmod/pokemon_stat_down_sfx.wav"

#define IS_VALID_STAT_ID(%1) (((%1) >= enum_zero) && ((%1) < stat_struct_ids) )

enum player_stat_struct{

    Float:the_stat_boost_value,
    the_number_of_stages,
	prev_number_of_stages

}

#define EVASIVENESS_TASK_PERIOD 0.1

static const DEBUG = 1

static const stat_change_notifications[2][5][] = {
	
		
		{

			

			"cannot go any lower!",
			"was lowered...",
			"was cripplied!",
			"plummeted!",
			"collapsed!!"


		},
		{
			"cannot get any higher!",
			"rose!",
			"rose sharply!",
			"rose drastically!",
			"rose skyrocketed!!"


		}
		
}

enum stat_constants_struct{

	name[50],
	Float:step,
	description[512]


}
static const stat_consts[stat_struct_ids][stat_constants_struct] = {

	{"Speed", 1.0, "Speed"},
	{"Attack", POKEMON_DAMAGE_RELATION_BALLAST_VAL, "Physical attack"},
	{"Defense", POKEMON_DAMAGE_RELATION_BALLAST_VAL, "Physical defense"},
	{"Sp. Attack", POKEMON_DAMAGE_RELATION_BALLAST_VAL, "Special attack"},
	{"Sp. Defense", POKEMON_DAMAGE_RELATION_BALLAST_VAL, "Special defense"},
	{"Evasiveness", 40.0, "Transaparency"}


}

static g_player_stats[SH_MAXSLOTS+1][stat_struct_ids][player_stat_struct]


static enable_pokemon_dmg_cvar = -1


#define POKEMON_EVASIVENESS_MONITOR_ENTITY_CLASSNAME "Pokemon_evasiveness_Monitor_Entity"

new pokemon_evasiveness_monitor_entity = -1

new pokemon_evasiveness_monitor_forward_id = -1


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	enable_pokemon_dmg_cvar = create_cvar(ACTIVATE_POKEMON_DMG_CVAR, "0", _,"Enable experimental pokemon based damage framework",true, 0.0,true, 1.0)



	register_concmd(print_pokemon_framework_info, print_pokemon_framework_info , ADMIN_IMMUNITY, "Print pokemon library init constants and other things")

	register_concmd(apply_player_pokemon_stat_change, apply_player_pokemon_stat_change , ADMIN_IMMUNITY, "Parm1: playername. Parm2: boost id, Parm3: boost stages, Parm4 go up or go down")

	register_concmd(print_pokemon_stat_descriptions, print_pokemon_stat_descriptions, ADMIN_IMMUNITY, "Print the descriptions of stats availiable")

	register_concmd(reset_player_pokemon_stats, reset_player_pokemon_stats, ADMIN_IMMUNITY, "Parm1: playername")

	register_concmd(print_player_pokemon_stats, print_player_pokemon_stats, ADMIN_IMMUNITY, "Print pokemon stats of a player^n^n^n")


	RegisterHam(Ham_TakeDamage,"player","ham_sh_stat_management_physical_damage",_, true)

	init_monitor_entity_based_global(POKEMON_EVASIVENESS_MONITOR_ENTITY_CLASSNAME, "apply_evasiveness", EVASIVENESS_TASK_PERIOD,
											pokemon_evasiveness_monitor_entity,
											pokemon_evasiveness_monitor_forward_id)

	register_event("CurWeapon", "curweapon", "be", "1=1")


}
public curweapon(id){
	

	if ( !sh_is_active() || !sh_is_inround()||sh_is_freezetime()) return
	
	if(sh_get_stun(id)||sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(id,SH_USER_IS_FLYING)){

		return


	}
	static my_weapon_ids:wpn_id;
	wpn_id= my_weapon_ids:read_data(2)

	if((!is_weaponid_valid(_:wpn_id))||(wpn_id==MY_CSW_C4)){

		return
	}

	pokemon_speed_update(id,wpn_id)

}
//----------------------------------------------------------------------------------------------
pokemon_speed_update(id,my_weapon_ids:wpn_id)
{
	

	if ( !sh_is_active() || !sh_is_inround()||sh_is_freezetime()) return
	
	if(sh_get_stun(id)||sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(id,SH_USER_IS_FLYING)){

		return


	}

	if((!is_weaponid_valid(_:wpn_id))||(wpn_id==MY_CSW_C4)){

		return
	}
	
	static bool:speed_is_neg,
			Float:speed_added_thing,
			Float:curr_speed,
			Float:speed_stat_boost_coeff,
			stat_diff

	stat_diff = (g_player_stats[id][STAT_SPEED_ID][the_number_of_stages]-g_player_stats[id][STAT_SPEED_ID][prev_number_of_stages])

	speed_stat_boost_coeff = float_abs_macro(g_player_stats[id][STAT_SPEED_ID][the_stat_boost_value])
	
	curr_speed = max_macro(wlt_get_def_movespeed(wpn_id),sh_get_user_sh_maxspeed(id, _:wpn_id))



	speed_is_neg = g_player_stats[id][STAT_SPEED_ID][the_number_of_stages] < 0
	
	speed_added_thing = speed_is_neg? 
					
				-(curr_speed* (1.0 -(1.0/(speed_stat_boost_coeff+stat_consts[STAT_SPEED_ID][step]))))
		
							:
		
					((150.0) * speed_stat_boost_coeff)
					
	
	
	set_user_maxspeed_controlled(id, curr_speed +
	
								speed_added_thing
								
								, false, (stat_diff>=0))

	if(DEBUG){


		sh_chat_message(id,_,"How much speed are we supposed to apply? %0.2f", curr_speed+speed_added_thing)
	}

}
public amx_print_pokemon_framework_info(id,level,cid){

	if (!cmd_access(id,level,cid,0)){
		return PLUGIN_HANDLED
	}
	
	
	console_print(id, "Info of the version of pokemon framework that is installed on this server:^n^n^n")
	
	console_print(id, "VERSION: %s^n", VERSION)

	console_print(id, "DAMAGE_DAMPENING_DIVIDER: %0.2f^n", DAMAGE_DAMPENING_DIVIDER)

	console_print(id, "POKEMON_DAMAGE_RELATION_BALLAST_VAL: %0.2f^n", POKEMON_DAMAGE_RELATION_BALLAST_VAL)

	console_print(id, "POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_NUMERATOR: %0.2f^n", POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_NUMERATOR)
	
	console_print(id, "POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_DENOMINATOR: %0.2f^n", POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_DENOMINATOR)

	console_print(id, "MAX_PLAYER_STAT_STAGES: %d", MAX_PLAYER_STAT_STAGES)

	
	
	
	return PLUGIN_HANDLED

}
public amx_print_player_pokemon_stats(id,level,cid){

	if (!cmd_access(id,level,cid,1)){
		return PLUGIN_HANDLED
	}
	new arg1[128]

	read_argv(1, arg1, charsmax(arg1))

	new player = cmd_target(id,arg1,2)

	if (!player) return PLUGIN_HANDLED

	static player_name[128]

	get_user_name(id, player_name, charsmax(player_name))

	console_print(id,"The pokemon stats of this player (named %s) are: ^n^n",player_name)

	for(new stat_struct_ids:i = enum_zero; i < stat_struct_ids;i++){

		console_print(id,"Stat %d:^n",i)
		console_print(id,"Name - %s^n",stat_consts[i][name])
		console_print(id,"Num of stages: %d^n",g_player_stats[id][i][the_number_of_stages])
		console_print(id,"Total boost value: %0.6f^n",g_player_stats[id][i][the_stat_boost_value])
	
	

	}

	return PLUGIN_HANDLED
}
public amx_print_pokemon_stat_descriptions(id,level,cid){

	if (!cmd_access(id,level,cid,0)){
		return PLUGIN_HANDLED
	}

	if(!pokemon_dmg_enabled()){
		
		console_print(id,"Pokemon framework disabled")
		return PLUGIN_HANDLED

	}
	console_print(id,"The pokemon stat boosts available on the server are: ^n^n")
	
	for(new stat_struct_ids:i = enum_zero; i< stat_struct_ids;i++){

		console_print(id,"Stat %d:^n",i)
		console_print(id,"Name - %s^n",stat_consts[i][name])
		console_print(id,"Description - %s^n",stat_consts[i][description])
	
	

	}

	return PLUGIN_HANDLED
}
public amx_apply_player_pokemon_stat_change(id,level,cid){

	if (!cmd_access(id,level,cid,4)){
		return PLUGIN_HANDLED
	}

	if(!pokemon_dmg_enabled()){
		
		console_print(id,"Pokemon framework disabled")
		return PLUGIN_HANDLED

	}
	new arg1[128],arg2[8],arg3[8],arg4[8]

	read_argv(1, arg1, charsmax(arg1))

	new player = cmd_target(id,arg1,2)

	if (!player) return PLUGIN_HANDLED

	read_argv(2, arg2, charsmax(arg2))


	new stat_struct_ids:stat_to_use = stat_struct_ids:str_to_num(arg2)

	if((stat_to_use<enum_zero)||(stat_to_use>=stat_struct_ids)){

		return PLUGIN_HANDLED

	}

	read_argv(3, arg3, charsmax(arg3))
	
	new num_of_stages = str_to_num(arg3)

	read_argv(4, arg4, charsmax(arg4))
	
	new bool:go_up_or_go_down = bool:str_to_num(arg4)

	static bool:enum_zero_here;
	enum_zero_here = enum_zero

	go_up_or_go_down = clamp_macro(go_up_or_go_down, enum_zero_here, enum_one)


	sh_apply_staged_stat_boost_aux(player, id, stat_to_use, num_of_stages,go_up_or_go_down)

	return PLUGIN_HANDLED
}
public amx_reset_player_pokemon_stats(id,level,cid){

	if (!cmd_access(id,level,cid,1)){
		return PLUGIN_HANDLED
	}

	if(!pokemon_dmg_enabled()){
		
		console_print(id,"Pokemon framework disabled")
		return PLUGIN_HANDLED

	}
	new arg1[128]

	read_argv(1, arg1, charsmax(arg1))

	new player = cmd_target(id,arg1,2)

	if (!player) return PLUGIN_HANDLED

	sh_reset_player_stat_boosts_aux(player,id)

	return PLUGIN_HANDLED
}
public notify_stat_change(id, attacker, stat_struct_ids:the_stat, bool:go_up_or_go_down, num_stages){

	if(!pokemon_dmg_enabled()) return

	static client_name[128]
	if(is_user_connected(attacker)&&is_user_connected(id)){
		if(id!=attacker){

			get_user_name(id, client_name, charsmax(client_name))


		}
		
		num_stages = max_macro(0,min_macro(num_stages,4))

		if(num_stages||(!num_stages&&DEBUG)){
			
			sh_chat_message(attacker,_,"%s%s %s %s",(id == attacker)?"Your":client_name,(id == attacker)?"":"'s",stat_consts[the_stat][name], stat_change_notifications[_:go_up_or_go_down][num_stages] )
			if(attacker!=id){
				sh_chat_message(id,_,"Your %s %s",stat_consts[the_stat][name], stat_change_notifications[_:go_up_or_go_down][num_stages] )
			}
		}
		if(num_stages){
			emit_sound(id, CHAN_AUTO, go_up_or_go_down? STAT_UP_SFX:STAT_DOWN_SFX,VOL_NORM, ATTN_NORM,0,PITCH_NORM)
			set_render_with_color_const(id,go_up_or_go_down?ORANGE:PURPLE,1,35,_,0,_,1.5,1,_,kRenderNormal,PRIO_RENDER_DELETE_INVISIBILITY)
		}
	}

}
public apply_evasiveness(entity_id){


	if(!is_valid_ent(entity_id)){
		
		return PLUGIN_CONTINUE
	
	}
	if(!sh_is_active()){

		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + EVASIVENESS_TASK_PERIOD)
		return PLUGIN_CONTINUE
	}
	if(sh_is_freezetime()){
		
		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + EVASIVENESS_TASK_PERIOD)
		return PLUGIN_CONTINUE
	}
	if( !sh_is_inround()){
		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + EVASIVENESS_TASK_PERIOD)
		return PLUGIN_CONTINUE
	}
	if( !pokemon_dmg_enabled()){
		entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + EVASIVENESS_TASK_PERIOD)
		return PLUGIN_CONTINUE
	}

	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]

		if(!is_user_alive(id)){

			continue
		}
		if(g_player_stats[id][STAT_EVASIVENESS_MULT][the_number_of_stages]<=0){
			
			continue

		}
		static const Float:get_rid_of_annoying_warning = 0.87

		static Float:stat_clamp_evasiveness_frac;
		
		stat_clamp_evasiveness_frac = clamp_macro((float(g_player_stats[id][STAT_EVASIVENESS_MULT][the_number_of_stages])/float(MAX_PLAYER_STAT_STAGES) ), 0.1,get_rid_of_annoying_warning);



		set_render_with_color_const(id,FX_NONE,1, floatround(255.0* (1.0 - stat_clamp_evasiveness_frac)),_,
		
									0,0,EVASIVENESS_TASK_PERIOD,0,_,kRenderTransAlpha,PRIO_RENDER_INVISIBILITY)

		
	}
	entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + EVASIVENESS_TASK_PERIOD)
	return PLUGIN_CONTINUE
}
public plugin_cfg(){

	server_print("%s innited!^n",PLUGIN)
	
}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound, STAT_UP_SFX)

	engfunc(EngFunc_PrecacheSound, STAT_DOWN_SFX)

}
bool:pokemon_dmg_enabled(){

	return cvar_val(bool, enable_pokemon_dmg_cvar)
}

public sh_round_new(){

	if(!pokemon_dmg_enabled()) return

	static the_players[SH_MAXSLOTS], pnum, id 
	get_players(the_players, pnum, "h")
	for (new m = 0; m < pnum; m++) {

		id = the_players[m];
		for (new stat_struct_ids:s = enum_zero; s < stat_struct_ids; s++) {

			g_player_stats[id][s][the_stat_boost_value] = 0.0
			g_player_stats[id][s][prev_number_of_stages] = 0
			g_player_stats[id][s][the_number_of_stages] = 0
		}

	} 

}
public sh_client_spawn(id, bool:newRound){

	if(!pokemon_dmg_enabled()) return
	
	
	if(newRound){

		return
	}
	for (new stat_struct_ids:s = enum_zero; s < stat_struct_ids; s++) {
		
		g_player_stats[id][s][the_stat_boost_value] = 0.0
		g_player_stats[id][s][prev_number_of_stages] = 0
		g_player_stats[id][s][the_number_of_stages] = 0
	}

}
public plugin_natives(){

    register_native("sh_apply_staged_stat_boost", "_sh_apply_staged_stat_boost")
    register_native("sh_check_player_boost_stage", "_sh_check_player_boost_stage")
    register_native("sh_reset_player_stat_boosts", "_sh_reset_player_stat_boosts")
    register_native("sh_set_player_single_stat_boost", "_sh_set_player_single_stat_boost")

}
public _sh_check_player_boost_stage(iPlugins, iParams){

	if(!pokemon_dmg_enabled()) return 0

	new id = get_param(1),
		stat_struct_ids:the_stat_to_use = stat_struct_ids:get_param(2)
		
	
	return g_player_stats[id][the_stat_to_use][the_number_of_stages]

}

public bool:_sh_reset_player_stat_boosts(iPlugins, iParams){


	if(!pokemon_dmg_enabled()) return false
	
	
	new id = get_param(1),
		attacker = get_param(2)


	return sh_reset_player_stat_boosts_aux(id,attacker)
	
}

public bool:_sh_set_player_single_stat_boost(iPlugins, iParams){


	if(!pokemon_dmg_enabled()) return false




	new id = get_param(1),
		stat_struct_ids:the_stat_id = stat_struct_ids:get_param(2),
		the_stat_stage_value = get_param(3)


	return sh_set_player_single_stat_boost_aux(id, the_stat_id, the_stat_stage_value)
	
}

bool:sh_set_player_single_stat_boost_aux(id,stat_struct_ids:the_stat_id, the_stat_stage_value){




	if(!is_user_alive(id)) return false
	
	if(!IS_VALID_STAT_ID(the_stat_id)) return false

	new annoying_warning_value = 1

	the_stat_stage_value = clamp_macro(the_stat_stage_value, -MAX_PLAYER_STAT_STAGES,annoying_warning_value* MAX_PLAYER_STAT_STAGES)


	g_player_stats[id][the_stat_id][the_number_of_stages] = the_stat_stage_value


	g_player_stats[id][the_stat_id][the_stat_boost_value] = (float(g_player_stats[id][the_stat_id][the_number_of_stages])
																						
																									*
																									
																						stat_consts[the_stat_id][step])

	g_player_stats[id][the_stat_id][prev_number_of_stages] = the_stat_stage_value

	return true
}
bool:sh_reset_player_stat_boosts_aux(id,attacker){



	if(!is_user_alive(id)) return false
	
	if(!is_user_connected(attacker)) return false

	static bool:something_happened;

	something_happened=false

	for (new stat_struct_ids:s = enum_zero; s < stat_struct_ids; s++) {

		g_player_stats[id][s][prev_number_of_stages] = 0
		if(g_player_stats[id][s][the_number_of_stages] == 0){
		
			continue
		
		}
		
		something_happened = true

		g_player_stats[id][s][the_stat_boost_value] = 0.0
		g_player_stats[id][s][the_number_of_stages] = 0
	
	}

	if(something_happened){

		static client_name[128]
		
		get_user_name(id, client_name, charsmax(client_name))
		
		set_render_with_color_const(id,BLACK,1,35,_,0,_,1.5,1,_,kRenderNormal,PRIO_RENDER_DELETE_INVISIBILITY)
		
		sh_chat_message(attacker,_,"All of %s's stats have been reset!",client_name)
		sh_chat_message(id,_, "All of your stats have been reset!")
	
	}
	else{
	
		sh_chat_message(attacker,_,"... Nothing happened!" )
		
		if(DEBUG){
		
			sh_chat_message(id,_, "... Nothing happened!" )
		
		}
	}

	return something_happened
}

bool:sh_apply_staged_stat_boost_aux(id, attacker, stat_struct_ids:the_stat_to_use, num_stages_to_apply, bool:go_up_or_go_down ){


	if ( !sh_is_active() || !sh_is_inround()||sh_is_freezetime()) return false


	num_stages_to_apply = abs_macro(num_stages_to_apply)
	if(!is_user_alive(id)){

		return false
	}
	if(!is_user_connected(attacker)){

		return false
	}
	if(!IS_VALID_STAT_ID(the_stat_to_use)){

		return false //unknown stat
	}
	if(!num_stages_to_apply){

		return false //wtf u doin man
	}
	if(DEBUG){

		sh_chat_message(attacker,_, "Prev num of your stages: %d",g_player_stats[id][the_stat_to_use][the_number_of_stages])
	}
	static prev_num_of_stages = 0;
	prev_num_of_stages = g_player_stats[id][the_stat_to_use][the_number_of_stages]

	if(go_up_or_go_down){
		if((g_player_stats[id][the_stat_to_use][the_number_of_stages] + num_stages_to_apply) > MAX_PLAYER_STAT_STAGES){

			num_stages_to_apply = max_macro(0, MAX_PLAYER_STAT_STAGES - g_player_stats[id][the_stat_to_use][the_number_of_stages])
			if(num_stages_to_apply<=0){
				notify_stat_change(id, attacker, the_stat_to_use, go_up_or_go_down, num_stages_to_apply)
				return false
			}
		}
	}
	else if(g_player_stats[id][the_stat_to_use][the_number_of_stages] - num_stages_to_apply < -MAX_PLAYER_STAT_STAGES){

		if(DEBUG){

			sh_chat_message(attacker,-1,"Ok lets see. The stages applied are: %d excessive are: %d",num_stages_to_apply,g_player_stats[id][the_stat_to_use][the_number_of_stages] - num_stages_to_apply  + MAX_PLAYER_STAT_STAGES)
			
		}
		num_stages_to_apply = max_macro(0,MAX_PLAYER_STAT_STAGES - abs_macro(g_player_stats[id][the_stat_to_use][the_number_of_stages]) )
		if(DEBUG){

			sh_chat_message(attacker,-1,"Ok lets see. The stages applied are: %d",num_stages_to_apply)
			
		}
		if(!num_stages_to_apply){
			notify_stat_change(id, attacker, the_stat_to_use, go_up_or_go_down, num_stages_to_apply)
			return false
		}
	}
	g_player_stats[id][the_stat_to_use][the_number_of_stages] += (num_stages_to_apply*floatround(sign_chng_mult(!go_up_or_go_down)))


	g_player_stats[id][the_stat_to_use][the_stat_boost_value] = (float(g_player_stats[id][the_stat_to_use][the_number_of_stages])
																						
																									*
																									
																						stat_consts[the_stat_to_use][step])


	g_player_stats[id][the_stat_to_use][prev_number_of_stages] = prev_num_of_stages

	
	if(the_stat_to_use == STAT_SPEED_ID){
		static my_weapon_ids:wpn_id;
		wpn_id = my_weapon_ids:get_user_weapon(id)
		pokemon_speed_update(id,wpn_id)
	}
	notify_stat_change(id,attacker,the_stat_to_use,go_up_or_go_down,num_stages_to_apply)

	return true 




}

public bool:_sh_apply_staged_stat_boost(iPlugins, iParams){

	if(!pokemon_dmg_enabled()) return false

	if ( !sh_is_active() || !sh_is_inround()||sh_is_freezetime()) return false

	new id = get_param(1),
		attacker = get_param(2),
		stat_struct_ids:the_stat_to_use = stat_struct_ids:get_param(3),
		num_stages_to_apply = get_param(4),
		bool:go_up_or_go_down = bool:get_param(5) //true for up. false for down

 	return sh_apply_staged_stat_boost_aux(id, attacker, the_stat_to_use, num_stages_to_apply, go_up_or_go_down )




}

/*
	please use a valid entity for the inflictor
	even if it has to be a player. otherwise the function doesnt work ok??
*/

Float:get_dmg_between_players(id, inflictor, attacker, Float:damage, sh_thrash_brat_dmg_type:the_sh_dmg_type = enum_minus_one){




	static inflictor_classname[64];

	if(!is_valid_ent(inflictor)){

		return damage

	}

	static stat_struct_ids:the_attack_stat_to_use,
			stat_struct_ids:the_defense_stat_to_use
	
		
	if(the_sh_dmg_type<enum_zero){
		entity_get_string(inflictor,EV_SZ_classname,inflictor_classname,63)
		static bool:it_was_a_grenade; it_was_a_grenade = bool:equal(inflictor_classname,"grenade")

			


		the_attack_stat_to_use = it_was_a_grenade?STAT_SPECIAL_ATTACK_MULT:STAT_ATTACK_MULT
		the_defense_stat_to_use = it_was_a_grenade?STAT_SPECIAL_DEFENSE_MULT:STAT_DEFENSE_MULT
		
	}
	else{


		the_attack_stat_to_use = CUSTOM_DMG_TYPE_IS_SPECIAL(the_sh_dmg_type)?STAT_SPECIAL_ATTACK_MULT:STAT_ATTACK_MULT
		the_defense_stat_to_use = CUSTOM_DMG_TYPE_IS_SPECIAL(the_sh_dmg_type)?STAT_SPECIAL_DEFENSE_MULT:STAT_DEFENSE_MULT
		

	}


	if (!sh_clients_are_same_team(attacker,id)) {

		static Float:attkr_level = 0.0,
				Float:id_defense_mult = 0.0,
				Float:attacker_attk_mult = 0.0,
				Float:combined_attk_vs_def_mult = 0.0,
				Float:the_power_val = 0.0,
				Float:the_lvl_factor = 0.0,
				Float:the_first_power_factor = 0.0,
				Float:the_second_power_factor = 0.0,
				Float:the_final_damage = 0.0,
				bool:attck_is_neg = false,
				bool:defense_is_neg = false



		attck_is_neg = g_player_stats[attacker][the_attack_stat_to_use][the_number_of_stages] < 0

		defense_is_neg = g_player_stats[id][the_defense_stat_to_use][the_number_of_stages] < 0
		

		attacker_attk_mult = 1.0
		
		id_defense_mult = 1.0

		combined_attk_vs_def_mult = 1.0

		/*
			//nonegative stage defense 
			(1.0)/(g_player_stats[id][the_defense_stat_to_use][the_stat_boost_value]+1.0)
			
			//negative stage defense
			(floatabs((2.0* g_player_stats[id][the_defense_stat_to_use][the_stat_boost_value])-1.0))
			
			//negative stage damage
			(1.0)/(floatabs((2.0* g_player_stats[attacker][the_attack_stat_to_use][the_stat_boost_value])-1.0))
			
			//nonegative stage damage 
			(g_player_stats[attacker][the_attack_stat_to_use][the_stat_boost_value]+1.0)

		*/



		if(g_player_stats[attacker][the_attack_stat_to_use][the_number_of_stages]){
			
			//neg multiplies attack by <1 number
			//positive multiplies attack by >1 number
			
			
			attacker_attk_mult = (attck_is_neg) ? (1.0)/(float_abs_macro((g_player_stats[attacker][the_attack_stat_to_use][the_stat_boost_value])-1.0))
			
															:
															
													(g_player_stats[attacker][the_attack_stat_to_use][the_stat_boost_value]+1.0)


			combined_attk_vs_def_mult *= attacker_attk_mult


		}	
		if(g_player_stats[id][the_defense_stat_to_use][the_number_of_stages]){
			
			//neg multiplies attack by >1 number
			//positive multiplies attack by <1 number

			id_defense_mult = (defense_is_neg) ? (float_abs_macro((g_player_stats[id][the_defense_stat_to_use][the_stat_boost_value])-1.0))
															:
													(1.0)/(g_player_stats[id][the_defense_stat_to_use][the_stat_boost_value]+1.0)

			combined_attk_vs_def_mult *= id_defense_mult



		}

		the_power_val = damage

		if(DEBUG){
			sh_chat_message(attacker,_,"Their defense coeeff: %0.2f",1.0/id_defense_mult)
			sh_chat_message(attacker,_,"The stat we are targeting: %s", stat_consts[the_defense_stat_to_use][name])

			sh_chat_message(attacker,_,"Our attack coeeff: %0.2f",attacker_attk_mult)
			sh_chat_message(attacker,_,"The attack stat we are using: %s", stat_consts[the_attack_stat_to_use][name])

			sh_chat_message(id,_,"Our defense coeeff: %0.2f",1.0/id_defense_mult)
			sh_chat_message(id,_,"The stat they are targeting: %s", stat_consts[the_defense_stat_to_use][name])

			sh_chat_message(id,_,"Their attack coeeff: %0.2f",attacker_attk_mult)
			sh_chat_message(id,_,"The attack stat they are using: %s", stat_consts[the_attack_stat_to_use][name])

			/*
			sh_chat_message(attacker,_,"The attack/defense ratio here is: %0.2f", (attacker_attk_mult/id_defense_mult))
			*/

			sh_chat_message(attacker,_,"The final combined damage factor is: %0.2f", combined_attk_vs_def_mult)

			sh_chat_message(attacker,_,"Input damage is: %0.2f", the_power_val)

			sh_chat_message(id,_,"The final combined damage factor is: %0.2f", combined_attk_vs_def_mult)

			sh_chat_message(id,_,"Input damage is: %0.2f", the_power_val)
		}


		attkr_level = float(sh_get_user_lvl(attacker))


		the_lvl_factor =  ((POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_NUMERATOR)*(attkr_level)
		
													/

						( POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_DENOMINATOR))
						
													+
													
							POKEMON_DAMAGE_LEVEL_RELEVANCE_DAMPENING_FACTOR_DENOMINATOR



		the_first_power_factor = float(floatround(the_lvl_factor * the_power_val * combined_attk_vs_def_mult, floatround_floor))

		the_second_power_factor = float(floatround(the_first_power_factor / DAMAGE_DAMPENING_DIVIDER, floatround_floor)) + 2.0

		the_final_damage = the_second_power_factor
		
		if(DEBUG){
			
			sh_chat_message(attacker,_,"Final damage is: %0.2f", the_final_damage)
			sh_chat_message(id,_,"Final damage is: %0.2f", the_final_damage)
		}

		return the_final_damage



		
	}

	return damage


}


public ham_sh_stat_management_physical_damage(id, inflictor, attacker, Float:damage, damagebits)
{
	if(damage<=0.0){
		return HAM_IGNORED
	}

	if(!pokemon_dmg_enabled()) return HAM_IGNORED

	if ( !sh_is_active() || !is_user_alive(id) ) return HAM_IGNORED


	if (!is_user_connected(attacker) || (id == attacker)) return HAM_IGNORED

	SetHamParamFloat(4,get_dmg_between_players(id,inflictor,attacker,damage))
	
	
	return HAM_HANDLED

} 
public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,const sh_thrash_brat_dmg_type:new_dmg_type,const custom_weapon_id){
	
	if(damage<=0){
		return DMG_FWD_PASS
	}

	if(!pokemon_dmg_enabled()) return DMG_FWD_PASS

	if ( !sh_is_active() || !is_user_alive(victim) ) return DMG_FWD_PASS


	if (!is_user_connected(attacker) || (victim == attacker)) return DMG_FWD_PASS


	damage = floatround(get_dmg_between_players(victim,victim,attacker,float(damage),new_dmg_type))
	

	return DMG_FWD_HANDLED
}
