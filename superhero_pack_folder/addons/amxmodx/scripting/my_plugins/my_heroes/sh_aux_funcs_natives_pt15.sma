#define I_WANT_CONSTANTS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt15: superhero pickability checks: pt3"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "../my_include/auxiliar_stuff.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt15.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt15.inc"

stock const player_projectile_weapons_print[]="sh_print_player_projectile_weapons"

static sh_player_hero_projectile_weapon_tracker[SH_MAXSLOTS+1] = {0, ...};


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	
	register_concmd(player_projectile_weapons_print,"sh_print_player_projectile_weapons",ADMIN_IMMUNITY,"param 1: playername")

}


public plugin_cfg(){


	server_print("%s innited!^n",LIBRARY_NAME)
	
}

public plugin_natives(){

	register_native("sh_get_player_has_hero_projectile_weapon","_sh_get_player_has_hero_projectile_weapon")
}
public bool:_sh_get_player_has_hero_projectile_weapon(iPLugin,iParams){

	new id = get_param(1),
		my_weapon_ids:weapon_id = my_weapon_ids:get_param(2);
	
	return bool:Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:weapon_id)
}
stock print_player_hero_projectile_weapon_flags(id){
	server_print("The state of hero projectile weapon flags for this player is:^n^n")
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){
		
		if(Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
			server_print("The weapon number %d (which is named %s)^nPlayer: %d^nHas been:^n - picked!",
																	i,
																	wlt_get_def_name(i),
																	id)
		}

	}

}

public sh_print_player_projectile_weapons(id,level,cid){

	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1,arg,31)

	new player = cmd_target(id,arg,2)

	if (!player) return PLUGIN_HANDLED

	print_player_hero_projectile_weapon_flags(player)

	return PLUGIN_HANDLED
}
public init_fwd_ret_id:sh_hero_init_pre(id,heroID, sh_init_mode:mode){
	new init_fwd_ret_id:true_return_result = INIT_FWD_PASS
	
	if(!client_is_within_range(id)){

		return INIT_FWD_PASS
	}

	if(( heroID < 0 )||(heroID >= SH_MAXHEROS)){
		return INIT_FWD_PASS
	}
	if(mode!=SH_HERO_ADD){
		
		return INIT_FWD_PASS
	}
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){

		if(sh_get_hero_projectile_weapon_bit(heroID,i)){
			if(Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
			

				sh_chat_message(id,-1,"You have picked heroes with ^"%s^" projectile weapon already!...",
							wlt_get_def_name(i))
			
				true_return_result =  INIT_FWD_BLOCK
				break;
			}
		}
	}

	return true_return_result
}
public sh_hero_init(id,heroID, sh_init_mode:mode){
	
	if(!client_is_within_range(id)){

		return
	}

	if(( heroID < 0 )||(heroID >= SH_MAXHEROS)){
		return
	}
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){

		if(sh_get_hero_projectile_weapon_bit(heroID,i)){
			switch(mode){

				case SH_HERO_ADD:{

					if(!Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
						
						Assign_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i, true_for_macro)
					

					}
				}
				case SH_HERO_DROP:{
					
					if(Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
						
						Assign_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i, false_for_macro)
					

					}

				}

			}
			

		}

	}
}