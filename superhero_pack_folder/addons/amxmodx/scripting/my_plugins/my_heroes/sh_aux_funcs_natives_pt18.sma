#include <amxmisc>
#define I_WANT_CONSTANTS
#define I_WANT_BASIC_MACROS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_QUICK_CHECKS
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt18.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt18.inc"

#define PLUGIN "SH_AuxFun18: hp recovery lib"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

static const Float:max_heal_mult = 1.0;
static const Float:min_heal_mult = 0.2;

enum property_counter{

	curr_picked_count,
	Float:curr_mult,
	tmp_bias,
	Float:tmp_mult_bias,
}

static sh_player_hero_damage_flag_tracker[SH_MAXSLOTS+1][sh_thrash_brat_dmg_type][property_counter];



public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_concmd(player_damage_recoveries_print,player_damage_recoveries_print,ADMIN_ALL,"param 1: playername")

	
	register_concmd(hero_damage_recoveries_print,hero_damage_recoveries_print,ADMIN_ALL,"param 1: part of hero name")


}
public plugin_cfg(){


	server_print("%s innited!^n",PLUGIN)
	
}
bool:sh_get_player_has_damage_recovery_flag(id,sh_thrash_brat_dmg_type:hero_damage_id ){
	
	
	return (sh_player_hero_damage_flag_tracker[id][hero_damage_id][curr_picked_count] > 0)
}

stock sh_print_player_hero_damage_recoveries_aux(id, player_target){
	console_print(id,"The state of hero damage recovery flags for this player is:^n^n")
	static dmg_source_name_buff[32]


	for(new sh_thrash_brat_dmg_type:i=enum_zero;i<sh_thrash_brat_dmg_type;i++){
		
		get_name_of_generic_dmg_source(i,dmg_source_name_buff)

		console_print(id,"The player %s recover from damage source name %s^n",
						(sh_player_hero_damage_flag_tracker[player_target][i][curr_picked_count]>0)?"will":"will not",
						dmg_source_name_buff)

		if((sh_player_hero_damage_flag_tracker[player_target][i][curr_picked_count]>0)){

			console_print(id,"The heal percent of this player for this type of damage is: %0.2f^n",
						sh_player_hero_damage_flag_tracker[player_target][i][curr_mult])

			
		}
	}

}

public sh_print_player_hero_damage_recoveries(id,level,cid){

	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1,arg,31)

	new player = cmd_target(id,arg,2)

	if (!player) return PLUGIN_HANDLED

	sh_print_player_hero_damage_recoveries_aux(id, player)

	return PLUGIN_HANDLED
}
stock sh_print_hero_damage_recoveries_aux(id, hero_name_partial[MAX_HERO_NAME_LENGTH]){

	
	new hero_id = sh_match_string_with_hero_name(id, hero_name_partial)
	
	if(hero_id<0){

		return
	}
	
	console_print(id,"The source of damage that %s allows users to recover from are:^n^n",hero_name_partial)
	
	static dmg_source_name_buff[32]


	for(new sh_thrash_brat_dmg_type:i=enum_zero;i<sh_thrash_brat_dmg_type;i++){
		

		if(!sh_get_hero_damage_bit(hero_id,i)){

				continue;

		}

		get_name_of_generic_dmg_source(i,dmg_source_name_buff)

		console_print(id,"%s (+%0.2f %% more healing pct)^n",
										dmg_source_name_buff)


	}

}
public sh_print_hero_damage_recoveries(id,level,cid){

	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new arg[MAX_HERO_NAME_LENGTH]
	read_argv(1,arg, charsmax(arg))

	sh_print_hero_damage_recoveries_aux(id, arg)

	return PLUGIN_HANDLED
}

public sh_hero_init(id,heroID, sh_init_mode:mode){
	
	if(!client_is_within_range(id)){

		return
	}

	if(( heroID < 0 )||(heroID >= SH_MAXHEROS)){
		return
	}


	for(new sh_thrash_brat_dmg_type:i=enum_zero;i<sh_thrash_brat_dmg_type;i++){

		sh_player_hero_damage_flag_tracker[id][i][tmp_bias] = 0
	}
	for(new sh_thrash_brat_dmg_type:i=enum_zero;i<sh_thrash_brat_dmg_type;i++){

		if(sh_get_hero_damage_bit(heroID,i)){
			
			sh_player_hero_damage_flag_tracker[id][i][tmp_bias]+=(mode==SH_HERO_ADD?1:-1)

			sh_player_hero_damage_flag_tracker[id][i][tmp_mult_bias]+=((mode==SH_HERO_ADD?1.0:-1.0)*sh_get_hero_damage_heal_mult(heroID,i));


		}

	}
	for(new sh_thrash_brat_dmg_type:i=enum_zero;i<sh_thrash_brat_dmg_type;i++){

		
		if(sh_get_hero_damage_bit(heroID,i)){
			sh_player_hero_damage_flag_tracker[id][i][curr_picked_count]+=sh_player_hero_damage_flag_tracker[id][i][tmp_bias]
			sh_player_hero_damage_flag_tracker[id][i][curr_mult]+=sh_player_hero_damage_flag_tracker[id][i][tmp_mult_bias]

			sh_player_hero_damage_flag_tracker[id][i][curr_mult] = clamp_macro(sh_player_hero_damage_flag_tracker[id][i][curr_mult],min_heal_mult,max_heal_mult);
		
		} 
	}
}
public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart ,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,custom_weapon_id){
	
	if ( !sh_is_active() ||  !is_user_connected(victim)){
	
		return DMG_FWD_PASS
	}
	if((victim==attacker)||sh_clients_are_same_team(victim,attacker)){


		return DMG_FWD_PASS
	}
	if(!is_valid_custom_dmg_source(_:new_dmg_type)){

		return DMG_FWD_PASS

	}
	if(sh_get_player_has_damage_recovery_flag(attacker,new_dmg_type)){

		new Float:the_mult_on_this_player=sh_player_hero_damage_flag_tracker[attacker][new_dmg_type][curr_mult]

		generic_heal(attacker,the_mult_on_this_player*float(damage),_,GREEN,_,_,50)

	}
	
	return DMG_FWD_PASS
}
