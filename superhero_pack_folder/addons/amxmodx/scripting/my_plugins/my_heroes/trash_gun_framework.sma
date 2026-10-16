

#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "trash_gun_inc/trash_gun.inc"


#define PLUGIN "Superhero Extra: (Junko pt.2) Trash Gun Handling"
#define VERSION "1.0"
#include "../my_include/my_author_header.inc"


#define first_weap_owner_ent_field EV_INT_iuser2
#define trash_weapon_damage_field EV_FL_fuser1



//nums

//floats
new pcvar_tr45h_gun_init_dmg_amt

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	pcvar_tr45h_gun_init_dmg_amt = create_cvar("trash_gun_init_dmg_amt", "1500.0")

	set_pcvar_bounds(pcvar_tr45h_gun_init_dmg_amt,CvarBound_Upper,true, 2000.0)
	set_pcvar_bounds(pcvar_tr45h_gun_init_dmg_amt,CvarBound_Lower,true, 750.0)

	
	register_ham_for_weapon_bitsum(Ham_Item_PostFrame,GUNS_BIT_SUM, "fw_Item_PostFrame", 1, true, true)
	
	register_ham_for_weapon_bitsum(Ham_Item_AddToPlayer,GUNS_BIT_SUM, "fw_Item_AddToPlayer_Post", 0, true, true)

}
public plugin_natives(){


	register_native("player_wpn_is_trash_wpn","_player_wpn_is_trash_wpn")
	register_native("deplete_trash_wpn_dmg_reserve","_deplete_trash_wpn_dmg_reserve")
}

public bool:_player_wpn_is_trash_wpn(iPlugins, iParams){

	new pid = get_param(1),
		wpnid = get_param(2),
		bool:result; 
		
		
	result = player_wpn_is_trash_wpn_helper(pid, wpnid)


	return result
}

public Float:_deplete_trash_wpn_dmg_reserve(iPlugins, iParams){


	new wpn_ent = get_param(1),
		Float:dmg_to_subtract = get_param_f(2)
	
	return deplete_trash_wpn_dmg_reserve_helper(wpn_ent,dmg_to_subtract)


}
public fw_Item_AddToPlayer_Post(Ent, id)
{
	ent_check(Ent,)
	
	new first_owner = entity_get_int(Ent,first_weap_owner_ent_field)
	
	if(!is_user_connected(first_owner)){
		


		entity_set_int(Ent,first_weap_owner_ent_field,id)
		entity_set_float(Ent,trash_weapon_damage_field,cvar_val(float,pcvar_tr45h_gun_init_dmg_amt))

	}

}
Float:deplete_trash_wpn_dmg_reserve_helper(wpn_ent, Float:damage_to_deplete = 0.0){


	new Float:curr_dmg_reserve = 0.0,
		Float:prev_dmg_reserve = 0.0;

	if(!is_valid_ent(wpn_ent)){

		return 0.0
	}
	prev_dmg_reserve = entity_get_float(wpn_ent,trash_weapon_damage_field)
	
	if(damage_to_deplete > 0.0){
		curr_dmg_reserve = floatmax(0.0, prev_dmg_reserve-damage_to_deplete)

		entity_set_float(wpn_ent,trash_weapon_damage_field,curr_dmg_reserve)
	}
	else{
		curr_dmg_reserve = prev_dmg_reserve


	}
	
	return curr_dmg_reserve

}
bool:player_wpn_is_trash_wpn_helper(pid, wpnid){

	new first_owner = -1;

	if(!is_user_alive(pid)){


		return false;
	}

	if(!wpn_id_in_bs(wpnid,GUNS_BIT_SUM)){

		return false;
	}
	if(!user_has_weapon(pid,wpnid)){


		return false;
	}
	new wpn_ent = get_weapon_ent_of_player(pid, wpnid)

	if(!is_valid_ent(wpn_ent)){

		return false;
	}
	first_owner = entity_get_int(wpn_ent,first_weap_owner_ent_field)

	return (first_owner != pid);


}

public client_disconnected(disconnected_id){


	if(!sh_is_active()){


		return 
	}

	static the_players[SH_MAXSLOTS],
			pnum,
			pid,
			the_weapons[32],
			wpn_num,
			curr_pid_wpn,
			wpn_item_id,
			wpn_ent,
			first_owner

	get_players(the_players, pnum, "a")
	for (new i = 0; i < pnum; i++) {


		pid = the_players[i]
		
		if(!is_user_alive(pid)){

			continue;
		}

		curr_pid_wpn = get_user_weapon(pid)

		get_user_weapons(pid,the_weapons,wpn_num);


		for (new j = 0; j < wpn_num; j++) {
			
			wpn_item_id = the_weapons[j]

			

			if(!wpn_id_in_bs(wpn_item_id,GUNS_BIT_SUM)){

				continue;
			}

			wpn_ent = get_weapon_ent_of_player(pid, wpn_item_id)

			if(!is_valid_ent(wpn_ent)){

				continue;
			}
			first_owner = entity_get_int(wpn_ent,first_weap_owner_ent_field)

			if(first_owner == disconnected_id){
				
				entity_set_int(wpn_ent,first_weap_owner_ent_field,pid)

				if(curr_pid_wpn == wpn_item_id){

					sh_assign_id_bit(pid,SH_IS_TR45H_GUN_EQUIPPED,false)
				}
			}
		}
	}


}


public fw_Item_PostFrame(ent)
{

	if(!is_valid_ent(ent)){
		return HAM_IGNORED
	}
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	
	if(!is_user_alive(id)){
		
		return HAM_IGNORED
	}


	new first_owner = entity_get_int(ent,first_weap_owner_ent_field)
	
	new bool:diff_owner=  (first_owner!=id),
		bool:first_owner_is_connected = bool:is_user_connected(first_owner),
		bool:wpn_has_dmg_left = (deplete_trash_wpn_dmg_reserve_helper(ent)>0.0);

	sh_assign_id_bit(id,SH_IS_TR45H_GUN_EQUIPPED, first_owner_is_connected && diff_owner && wpn_has_dmg_left)

	return HAM_IGNORED

}

public sh_client_death(id){

	sh_assign_id_bit(id,SH_IS_TR45H_GUN_EQUIPPED,false)


}
