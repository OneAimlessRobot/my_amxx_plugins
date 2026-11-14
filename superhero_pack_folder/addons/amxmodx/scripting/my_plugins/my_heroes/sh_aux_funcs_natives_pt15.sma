#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_MISC_FUNCS
#define I_WANT_PDATA_ALIASES
#define I_WANT_ENTITY_VECTORS
#define I_WANT_RESOURCE_ALIASES
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "SH_AuxFun15: proj. wpn gating"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "../my_include/auxiliar_stuff.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt15.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt15.inc"


static sh_player_hero_projectile_weapon_tracker[SH_MAXSLOTS+1] = {0, ...};


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	
	register_concmd(player_projectile_weapons_print,player_projectile_weapons_print,ADMIN_IMMUNITY,"param 1: playername")

	register_concmd(hero_projectile_weapons_print,hero_projectile_weapons_print,ADMIN_IMMUNITY,"param 1: hero name")

	register_ham_hook_multiple(Ham_TraceAttack,full_entity_array_for_trace_attack,sizeof(full_entity_array_for_trace_attack),
						"Ham_TraceAttackProjectileWeapon",_,true)

	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPostProjectileWeapons", 1)

}

public fm_UpdateClientDataPostProjectileWeapons(player, sendWeapons, cd)
{
	if(!is_user_alive(player)){
		
		return FMRES_IGNORED
	}
	if(!Get_BitVar(sh_player_hero_projectile_weapon_tracker[player], _:get_user_weapon(player))){
		return FMRES_IGNORED
	}
	new pEntity = get_pdata_cbase(player, m_pActiveItem,XO_PLAYER)
	if(pev_valid(pEntity)==PDATA_SAFE){
		set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public Ham_TraceAttackProjectileWeapon(id, idattacker, Float:damage, Float:direction[3], ptr, damagebits)
{
	if(damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_connected(idattacker)){
		return HAM_IGNORED	
	}
	if(!Get_BitVar(sh_player_hero_projectile_weapon_tracker[idattacker], _:get_user_weapon(idattacker))){
		return HAM_IGNORED
	}

	damage= 0.0
	SetHamParamFloat(3,damage)
	
	return HAM_SUPERCEDE
	
}

public plugin_cfg(){


	server_print("%s innited!^n",PLUGIN)
	
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
	static weapon_name_buff[50]
	server_print("The state of hero projectile weapon flags for this player is:^n^n")
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){
		
		if(!is_weaponid_valid(_:i)){
			continue
		}
		if(Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
			wlt_get_def_name(i,weapon_name_buff,charsmax(weapon_name_buff))
																	
			server_print("%s^nHas been:^n - picked!",weapon_name_buff)
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
stock print_hero_projectile_weapon_flags(heroID){
	static weapon_name_buff[50]
	server_print("The projectile weapons flags for this hero are:^n^n")
	for(new my_weapon_ids:i=enum_zero;i<my_weapon_ids;i++){
		
		if(!is_weaponid_valid(_:i)){
			continue
		}
		if(sh_get_hero_projectile_weapon_bit(heroID,i)){
			wlt_get_def_name(i,weapon_name_buff,charsmax(weapon_name_buff))
																	
			server_print("- %s^n",weapon_name_buff)
		}

	}

}

public sh_print_hero_projectile_weapons(id,level,cid){

	static arg[MAX_HERO_NAME_LENGTH],
			hero_name_to_use[MAX_HERO_NAME_LENGTH]

	read_argv(1,arg,charsmax(arg))

	static arg_strlen;

	arg_strlen = strlen(arg)


	if(!arg_strlen){
		
		console_print(id, "Part of hero name is required!")

		return PLUGIN_HANDLED
	}

	static heroID;

	if((heroID = sh_match_string_with_hero_name(id,arg)) < 0){


		return PLUGIN_HANDLED


	}
	
	sh_get_hero_name_from_id(heroID,hero_name_to_use)
	
	console_print(id, "Hero name obtained: %s", hero_name_to_use)
	
	print_hero_projectile_weapon_flags(heroID)
	
	return PLUGIN_HANDLED

}
public init_fwd_ret_id:sh_hero_init_pre(id,heroID, sh_init_mode:mode){
	new init_fwd_ret_id:true_return_result = INIT_FWD_PASS
	static weapon_name_buff[50]
	
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

		if(!is_weaponid_valid(_:i)){
			continue
		}
		if(sh_get_hero_projectile_weapon_bit(heroID,i)){
			if(Get_BitVar(sh_player_hero_projectile_weapon_tracker[id], _:i)){
			
				wlt_get_def_name(i,weapon_name_buff,charsmax(weapon_name_buff))

				sh_chat_message(id,-1,"You have picked heroes with ^"%s^" projectile weapon already!...",
							weapon_name_buff)
			
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

		if(!is_weaponid_valid(_:i)){
			continue
		}
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