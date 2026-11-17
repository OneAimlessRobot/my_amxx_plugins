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
//TODO: Basically everything


#define I_WANT_CONSTANTS
#define I_WANT_MATH_FUNCS_PT2
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#define I_WANT_PDATA_ALIASES
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"


#define PLUGIN "SH_PKMN_Framework"

#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_pokemon_dmg_framework.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "../my_include/auxiliar_stuff.inc"

#define ACTIVATE_POKEMON_DMG_CVAR "sh_use_pokemon_damage"

#define DAMAGE_DAMPENING_DIVIDER 20.0
#define POKEMON_DAMAGE_RELATION_BALLAST_VAL 0.5 //idc if this makes no diff. It makes me feel safe not to divide things too close to zero
#define POKEMON_DMG_LVL_RELEVANCE_DAMPENING_FACTOR 10.0

#define MAX_PLAYER_STAT_STAGES 6

#define STAT_UP_SFX "shmod/pokemon_stat_up_sfx.wav"

#define STAT_DOWN_SFX "shmod/pokemon_stat_down_sfx.wav"

#define IS_VALID_STAT_ID(%1) (((%1) >= enum_zero) && ((%1) < stat_struct_ids) )

enum player_stat_struct{

    Float:the_stat_boost_value,
    the_number_of_stages,
	prev_number_of_stages

}

#define EVASIVENESS_TASK_PERIOD 1.0
#define SPEED_TASK_PERIOD 0.33

static const DEBUG = 0

static const stat_change_notifications[2][4][] = {
	
		
		{

			

			"cannot go any lower!",
			"was lowered...",
			"was cripplied!",
			"plummeted!"


		},
		{
			"cannot get any higher!",
			"rose!",
			"rose sharply!",
			"rose drastically!"


		}
		
}

enum stat_constants_struct{

	name[50],
	Float:step


}
static const stat_consts[stat_struct_ids][stat_constants_struct] = {

	{"Speed", 1.0},
	{"Attack", POKEMON_DAMAGE_RELATION_BALLAST_VAL},
	{"Defense", POKEMON_DAMAGE_RELATION_BALLAST_VAL},
	{"Sp. Attack", POKEMON_DAMAGE_RELATION_BALLAST_VAL},
	{"Sp. Defense", POKEMON_DAMAGE_RELATION_BALLAST_VAL},
	{"Evasiveness", 40.0}


}

static g_player_speed_stat_mults[SH_MAXSLOTS+1][stat_struct_ids][player_stat_struct]


static Float:curr_player_pure_maxspeeds[SH_MAXSLOTS+1][my_weapon_ids] 


static my_weapon_ids:last_player_deployed_weapon[SH_MAXSLOTS+1] 


stock EVASIVENESS_TASKID = -1,
		SPEED_TASKID = -1

static enable_pokemon_dmg_cvar = -1


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	enable_pokemon_dmg_cvar = create_cvar(ACTIVATE_POKEMON_DMG_CVAR, "0", _,"Enable experimental pokemon based damage framework",true, 0.0,true, 1.0)


	RegisterHam(Ham_TakeDamage,"player","ham_sh_stat_management_physical_damage",_, true)

	EVASIVENESS_TASKID = allocate_typed_task_id(generic_task)
	SPEED_TASKID = allocate_typed_task_id(generic_task)

	register_event("CurWeapon", "on_Weapon_Change", "be", "1=1")



}

public on_Weapon_Change(id)
{

	if(!pokemon_dmg_enabled()) return

	if (!sh_is_active()) return
	

	new my_weapon_ids:user_wpn = my_weapon_ids:read_data(2)
	if(((last_player_deployed_weapon[id]!=user_wpn)||(!is_weaponid_valid(_:last_player_deployed_weapon[id])))&&is_weaponid_valid(_:user_wpn)){

		static Float:last_weapon_speed_for_this_one = 0.0,
			Float:curr_user_maxspeed = 0.0

		curr_user_maxspeed = get_user_maxspeed(id)

		
		if(DEBUG){
			last_weapon_speed_for_this_one = (!is_weaponid_valid(_:last_player_deployed_weapon[id]))?
		
													curr_user_maxspeed
																:
													curr_player_pure_maxspeeds[id][last_player_deployed_weapon[id]]
			static switched_wpn_name[50]

			wlt_get_def_name(user_wpn,switched_wpn_name,charsmax(switched_wpn_name))
			sh_chat_message(id,-1,"Last weapon's speed: %0.2f. The curr_weapon name is: %s",last_weapon_speed_for_this_one, switched_wpn_name)
			if(is_weaponid_valid(_:last_player_deployed_weapon[id])){


				wlt_get_def_name(last_player_deployed_weapon[id],switched_wpn_name,charsmax(switched_wpn_name))
				sh_chat_message(id,-1,"The last weapon name is: %s",switched_wpn_name)
			}
		}
		curr_player_pure_maxspeeds[id][user_wpn] = curr_user_maxspeed

		last_player_deployed_weapon[id]=user_wpn


	}

}
public notify_stat_change(id, attacker, stat_struct_ids:the_stat, bool:go_up_or_go_down, num_stages){

	if(!pokemon_dmg_enabled()) return

	static client_name[128]
	if(is_user_connected(attacker)&&is_user_connected(id)){
		if(id!=attacker){

			get_user_name(id, client_name, charsmax(client_name))


		}
		
		num_stages = max_macro(0,min_macro(num_stages,3))

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
public apply_evasiveness(task_id){


	if (! sh_is_active() || sh_is_freezetime() || !pokemon_dmg_enabled()) return

	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]

		if(!is_user_alive(id)){

			continue
		}
		if(g_player_speed_stat_mults[id][STAT_EVASIVENESS_MULT][the_number_of_stages]<=0){
			
			continue

		}
		static const Float:get_rid_of_annoying_warning = 0.87

		static Float:stat_clamp_evasiveness_frac;
		
		stat_clamp_evasiveness_frac = clamp_macro((float(g_player_speed_stat_mults[id][STAT_EVASIVENESS_MULT][the_number_of_stages])/float(MAX_PLAYER_STAT_STAGES) ), 0.1,get_rid_of_annoying_warning);



		set_render_with_color_const(id,FX_NONE,1, floatround(255.0* (1.0 - stat_clamp_evasiveness_frac)),_,
		
									0,0,EVASIVENESS_TASK_PERIOD,0,_,kRenderTransAlpha,PRIO_RENDER_INVISIBILITY)

		
	}
}
public apply_speed(task_id){


	if (! sh_is_active() || sh_is_freezetime() || !pokemon_dmg_enabled() || !sh_is_inround()) return

	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new k = 0; k < pnum; k++) {
		
		id = the_players[k]

		if(!is_user_alive(id)){

			continue
		}
		if(sh_get_stun(id)){
			
			continue

		}

		
		static bool:speed_is_neg,
				Float:speed_added_thing,
				Float:curr_speed,
				Float:speed_stat_boost_coeff

		speed_stat_boost_coeff = floatabs(g_player_speed_stat_mults[id][STAT_SPEED_ID][the_stat_boost_value])
		
		curr_speed = curr_player_pure_maxspeeds[id][my_weapon_ids:get_user_weapon(id)]



		speed_is_neg = g_player_speed_stat_mults[id][STAT_SPEED_ID][the_number_of_stages] < 0
		
		speed_added_thing = speed_is_neg? 
						
					-(curr_speed* (1.0 -(1.0/speed_stat_boost_coeff)))
			
								:
			
						((150.0) * speed_stat_boost_coeff)


		set_user_maxspeed_controlled(id, curr_speed +
		
									speed_added_thing
									
									, false, speed_is_neg?false:true)
		
	}
}
public plugin_cfg(){

	if(!pokemon_dmg_enabled()) return 

	set_task(EVASIVENESS_TASK_PERIOD,"apply_evasiveness",EVASIVENESS_TASKID,_,_,"b")
	set_task(SPEED_TASK_PERIOD,"apply_speed",SPEED_TASKID,_,_,"b")

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

			g_player_speed_stat_mults[id][s][the_stat_boost_value] = 0.0
			g_player_speed_stat_mults[id][s][the_number_of_stages] = 0
		}
		
		last_player_deployed_weapon[id] = enum_minus_one

	} 

}
public sh_client_spawn(id, bool:newRound){

	if(!pokemon_dmg_enabled()) return
	
	last_player_deployed_weapon[id] = enum_minus_one
	
	if(newRound){

		return
	}
	for (new stat_struct_ids:s = enum_zero; s < stat_struct_ids; s++) {
		
		g_player_speed_stat_mults[id][s][the_stat_boost_value] = 0.0
		g_player_speed_stat_mults[id][s][the_number_of_stages] = 0
	}
	arrayset(curr_player_pure_maxspeeds[id],0.0,sizeof(curr_player_pure_maxspeeds[]))

}
public sh_client_death(id){

	if(!pokemon_dmg_enabled()) return

	last_player_deployed_weapon[id] = enum_minus_one

}
public plugin_natives(){

    register_native("sh_apply_staged_stat_boost", "_sh_apply_staged_stat_boost")

}

public bool:_sh_apply_staged_stat_boost(iPlugins, iParams){

	if(!pokemon_dmg_enabled()) return false

	new id = get_param(1),
		attacker = get_param(2),
		stat_struct_ids:the_stat_to_use = stat_struct_ids:get_param(3),
		num_stages_to_apply = get_param(4),
		bool:go_up_or_go_down = bool:get_param(5) //true for up. false for down

	num_stages_to_apply = abs(num_stages_to_apply)


	if(!is_user_connected(id)){

		return false
	}
	if(!IS_VALID_STAT_ID(the_stat_to_use)){

		return false //unknown stat
	}
	if(!num_stages_to_apply){

		return false //wtf u doin man
	}
	if(DEBUG){

		sh_chat_message(attacker,_, "Prev num of your stages: %d",g_player_speed_stat_mults[id][the_stat_to_use][the_number_of_stages])
	}
	static prev_num_of_stages = 0;
	prev_num_of_stages = g_player_speed_stat_mults[id][the_stat_to_use][the_number_of_stages]

	if(go_up_or_go_down){
		if((g_player_speed_stat_mults[id][the_stat_to_use][the_number_of_stages] + num_stages_to_apply) > MAX_PLAYER_STAT_STAGES){

			num_stages_to_apply = max_macro(0, MAX_PLAYER_STAT_STAGES - g_player_speed_stat_mults[id][the_stat_to_use][the_number_of_stages])
			if(num_stages_to_apply<=0){
				notify_stat_change(id, attacker, the_stat_to_use, go_up_or_go_down, num_stages_to_apply)
				return false //no stages applied at all
			}

		}
	}
	else if((g_player_speed_stat_mults[id][the_stat_to_use][the_number_of_stages] - num_stages_to_apply) < (-MAX_PLAYER_STAT_STAGES)){

		num_stages_to_apply = max_macro(0, -(g_player_speed_stat_mults[id][the_stat_to_use][the_number_of_stages] + MAX_PLAYER_STAT_STAGES) )
		if(num_stages_to_apply<=0){
			notify_stat_change(id, attacker, the_stat_to_use, go_up_or_go_down, num_stages_to_apply)
			return false //no stages applied at all
		}
	}
	g_player_speed_stat_mults[id][the_stat_to_use][the_number_of_stages] += (num_stages_to_apply*floatround(sign_chng_mult(!go_up_or_go_down)))


	g_player_speed_stat_mults[id][the_stat_to_use][the_stat_boost_value] = (float(g_player_speed_stat_mults[id][the_stat_to_use][the_number_of_stages])
																						
																									*
																									
																						stat_consts[the_stat_to_use][step])


	g_player_speed_stat_mults[id][the_stat_to_use][prev_number_of_stages] = prev_num_of_stages


	notify_stat_change(id,attacker,the_stat_to_use,go_up_or_go_down,num_stages_to_apply)

	return true 




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
				Float:the_power_val = 0.0,
				Float:the_lvl_factor = 0.0,
				Float:the_first_power_factor = 0.0,
				Float:the_second_power_factor = 0.0,
				Float:the_final_damage = 0.0,
				bool:attck_is_neg = false,
				bool:defense_is_neg = false




		attck_is_neg = g_player_speed_stat_mults[attacker][the_attack_stat_to_use][the_number_of_stages] < 0
		
		attacker_attk_mult = attck_is_neg? 
						
			( (POKEMON_DAMAGE_RELATION_BALLAST_VAL/floatabs(g_player_speed_stat_mults[attacker][the_attack_stat_to_use][the_stat_boost_value])))
			
								:
			
						(POKEMON_DAMAGE_RELATION_BALLAST_VAL + g_player_speed_stat_mults[attacker][the_attack_stat_to_use][the_stat_boost_value])


		defense_is_neg = g_player_speed_stat_mults[id][the_defense_stat_to_use][the_number_of_stages] < 0
		
		id_defense_mult = defense_is_neg?
						
			((POKEMON_DAMAGE_RELATION_BALLAST_VAL/floatabs(g_player_speed_stat_mults[id][the_defense_stat_to_use][the_stat_boost_value])))
							
								:
			
						(POKEMON_DAMAGE_RELATION_BALLAST_VAL + g_player_speed_stat_mults[id][the_defense_stat_to_use][the_stat_boost_value])

		if(DEBUG){
			sh_chat_message(attacker,_,"Their defense coeeff: %0.2f",id_defense_mult)
			sh_chat_message(attacker,_,"The stat we are targeting: %s", stat_consts[the_defense_stat_to_use][name])

			sh_chat_message(attacker,_,"Our attack coeeff: %0.2f",attacker_attk_mult)
			sh_chat_message(attacker,_,"The attack stat we are using: %s", stat_consts[the_attack_stat_to_use][name])

			sh_chat_message(attacker,_,"The attack/defense ratio here is: %0.2f", (attacker_attk_mult/id_defense_mult))
		}


		the_power_val = damage
		attkr_level = float(sh_get_user_lvl(attacker))


		the_lvl_factor =  ((POKEMON_DMG_LVL_RELEVANCE_DAMPENING_FACTOR *2.0)*(attkr_level)/(POKEMON_DMG_LVL_RELEVANCE_DAMPENING_FACTOR *5.0)) + 2.0

		the_first_power_factor = float(floatround(the_lvl_factor * the_power_val * (attacker_attk_mult/id_defense_mult), floatround_floor))

		the_second_power_factor = float(floatround(the_first_power_factor / DAMAGE_DAMPENING_DIVIDER, floatround_floor)) + 2.0

		//the_final_damage = the_second_power_factor * (float(generate_int(85,100,10))/float(100))
		the_final_damage = the_second_power_factor
		
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