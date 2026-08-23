#define AUX_STUFF_GIVE_WEAPONS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_WEAPONS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"


#define PLUGIN "Superhero Extra: (Junko pt.2) Trash Gun Handling"
#define VERSION "1.0"
#include "../my_include/my_author_header.inc"


#define first_weap_owner_ent_field EV_INT_iuser2

new g_Old_Weapon[SH_MAXSLOTS+1] = {-1, ...}


#define GLOBAL_TRASH_GUN_LOOP_TASK_PERIOD   1.0

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_ham_for_weapon_bitsum(Ham_Item_AddToPlayer,GUNS_BIT_SUM,"fw_Item_AddToPlayer_Post",1, true)

}


public fw_Item_AddToPlayer_Post(Ent, id)
{
	ent_check(Ent,)
	
	new first_owner = entity_get_int(Ent,first_weap_owner_ent_field)
	
	if(!is_user_connected(first_owner)){
		


		entity_set_int(Ent,first_weap_owner_ent_field,id)

	}

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
public Event_CurWeapon(id)
{
	
	static CSWID; CSWID = read_data(2)

	

	new bool:wpn_is_in_bitsum = bool:wpn_id_in_bs(CSWID,GUNS_BIT_SUM);

	if(g_Old_Weapon[id] == CSWID){
		
		return
	
	}

	static Ent; Ent = get_weapon_ent_of_player(id, CSWID)
	
	if(!is_valid_ent(Ent))
	{
		return
	}


	new first_owner = entity_get_int(Ent,first_weap_owner_ent_field)
	
	new bool:diff_owner=  (first_owner!=id),
		bool:first_owner_is_connected = bool:is_user_connected(first_owner);

	sh_assign_id_bit(id,SH_IS_TR45H_GUN_EQUIPPED, first_owner_is_connected && wpn_is_in_bitsum && diff_owner)

	g_Old_Weapon[id] = CSWID
}

public sh_client_death(id){

	sh_assign_id_bit(id,SH_IS_TR45H_GUN_EQUIPPED,false)


}