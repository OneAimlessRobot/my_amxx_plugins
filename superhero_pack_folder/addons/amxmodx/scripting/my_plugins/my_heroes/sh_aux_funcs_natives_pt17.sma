#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt17.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt17.inc"

new the_current_map_name[STRING_SIZE_FOR_MAP_STRING]

// max is 4x the number of maximum heroes
//4 restrictions for hero
#define MAX_HERO_MAP_RESTRICTIONS_PER_HERO (4)

enum hero_map_restriction_struct{
	map_restriction_substring[STRING_SIZE_FOR_MAP_STRING],
	reason_string[REASON_STRING_LENGTH]



}
	
new hero_map_blacklist_structs_array[SH_MAXHEROS][MAX_HERO_MAP_RESTRICTIONS_PER_HERO][hero_map_restriction_struct],
	hero_map_whitelist_structs_array[SH_MAXHEROS][MAX_HERO_MAP_RESTRICTIONS_PER_HERO][hero_map_restriction_struct]

new hero_map_blacklist_structs_counts[SH_MAXHEROS],
	hero_map_whitelist_structs_counts[SH_MAXHEROS]



#define PLUGIN "SH_AuxFun17: mapwise restricting"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_concmd(check_map_whitelist,check_map_whitelist,ADMIN_ALL)
	register_concmd(check_map_blacklist,check_map_blacklist,ADMIN_ALL)
	register_concmd(check_map_blacklist_for_hero,check_map_blacklist_for_hero,ADMIN_ALL)
	register_concmd(check_map_whitelist_for_hero,check_map_whitelist_for_hero,ADMIN_ALL)



}
public plugin_cfg(){


	server_print("%s innited!^n",PLUGIN)
	server_print("The current map name is: %s!^n",the_current_map_name)
	
}
public plugin_precache(){

	get_mapname(the_current_map_name,charsmax(the_current_map_name))


}
public sh_check_map_blacklisted_heroes(id,level,cid){

	if (!cmd_access(id,level,cid,0))
		return PLUGIN_HANDLED

	
	sh_check_map_blacklisted_heroes_aux(id)

	return PLUGIN_HANDLED
}
stock sh_check_map_blacklisted_heroes_aux(id){

	static hero_name[MAX_HERO_NAME_LENGTH]

	console_print(id,"The map-blacklisted heroes in this server are:^n")

	static counted_heroes;
	counted_heroes = 0
	for(new i=0;i<SH_MAXHEROS;i++){

		if(hero_map_blacklist_structs_counts[i]<=0){

			continue
		}
		else{

			sh_get_hero_name_from_id(i,hero_name)
			console_print(id,"^"%s^" contains maps in its blacklist!^n",
								hero_name)
			counted_heroes++
			
		}

		
		
	}

	if(counted_heroes<=0){

		console_print(id,"No map-blacklisted heroes are registered in this server^n")

	}


}

public sh_check_map_whitelisted_heroes(id,level,cid){

	if (!cmd_access(id,level,cid,0))
		return PLUGIN_HANDLED

	
	sh_check_map_whitelisted_heroes_aux(id)

	return PLUGIN_HANDLED
}
stock sh_check_map_whitelisted_heroes_aux(id){

	static hero_name[MAX_HERO_NAME_LENGTH]

	console_print(id,"The map-whitelisted heroes in this server are:^n")

	static counted_heroes;
	counted_heroes = 0
	for(new i=0;i<SH_MAXHEROS;i++){

		if(hero_map_whitelist_structs_counts[i]<=0){

			continue
		}
		else{

			sh_get_hero_name_from_id(i,hero_name)
			console_print(id,"^"%s^" contains maps in its whitelist!^n",
								hero_name)
			counted_heroes++
			
		}

		
		
	}

	if(counted_heroes<=0){

		console_print(id,"No map-whitelisted heroes are registered in this server^n")

	}

}
public sh_check_map_hero_blacklisted_maps(id,level,cid){

	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

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
	
	sh_check_map_hero_blacklisted_maps_aux(id,heroID,hero_name_to_use)

	return PLUGIN_HANDLED
}
stock sh_check_map_hero_blacklisted_maps_aux(id,heroID,hero_name_to_use[MAX_HERO_NAME_LENGTH]){


	console_print(id,"The hero map blacklist for %s this server is:^n", hero_name_to_use)
	if(!hero_map_blacklist_structs_counts[heroID]){


		console_print(id,"This hero's map blacklist is empty!^n")
		return
	}
	for(new i=0;i<hero_map_blacklist_structs_counts[heroID];i++){

		console_print(id,"You cannot equip ^"%s^" in maps that contain ^"%s^" in the name!^n",
								hero_name_to_use,
								hero_map_blacklist_structs_array[heroID][i][map_restriction_substring])

		console_print(id,"Registered reason: ^"%s^"^n",
								hero_map_blacklist_structs_array[heroID][i][reason_string])
		
		
	}

}
public sh_check_map_hero_whitelisted_maps(id,level,cid){

	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

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
	
	sh_check_map_hero_whitelisted_maps_aux(id,heroID,hero_name_to_use)

	return PLUGIN_HANDLED
}
stock sh_check_map_hero_whitelisted_maps_aux(id,heroID,hero_name_to_use[MAX_HERO_NAME_LENGTH]){


	console_print(id,"The hero map whitelist for %s this server is:^n", hero_name_to_use)
	if(!hero_map_whitelist_structs_counts[heroID]){


		console_print(id,"This hero's map whitelist is empty!^n")
		return
	}

	console_print(id,"You can ONLY equip ^"%s^" in maps that contain...^n", hero_name_to_use)

	for(new i=0;i<hero_map_whitelist_structs_counts[heroID];i++){

		console_print(id,"^n- ^"%s^"%s^n",
								hero_map_whitelist_structs_array[heroID][i][map_restriction_substring],
								i==(hero_map_whitelist_structs_counts[heroID]-1)?"":", or...")
		

		console_print(id,"Registered reason: ^"%s^"^n",
								hero_map_whitelist_structs_array[heroID][i][reason_string])
		
		
	}
	
	console_print(id,"In the name!!!^n")

}
public plugin_natives(){

	register_native("sh_register_superhero_map_restriction","_sh_register_superhero_map_restriction")
	register_native("sh_test_map_name_here","_sh_test_map_name_here")

}
bool:get_restriction_gating_value_based_on_bool_and_string(bool:white_listed_or_black_listed_bool_here, map_substring[]){
	
	
	return bool:(white_listed_or_black_listed_bool_here 
	
				?
	
		(containi(the_current_map_name,map_substring)>=0)

				:
		
		(containi(the_current_map_name,map_substring)<0))


		


}
public bool:_sh_test_map_name_here(iPlugins,iParams){
	
	new bool:white_listed_or_black_listed_bool_here = bool:get_param(1)
	

	new map_restriction_string[STRING_SIZE_FOR_MAP_STRING];

	get_string(2,map_restriction_string,charsmax(map_restriction_string))

	if(strlen(map_restriction_string)<=0){

		return false
	}
	return get_restriction_gating_value_based_on_bool_and_string(
			white_listed_or_black_listed_bool_here,map_restriction_string)
	

}

public bool:_sh_register_superhero_map_restriction(iPlugins,iParams){
	new heroID=get_param(1);

	if((heroID <0) || (heroID >= SH_MAXHEROS)){

		return false
	}

	new map_restriction_string[STRING_SIZE_FOR_MAP_STRING],
			the_reason_string[REASON_STRING_LENGTH]

	get_string(3,map_restriction_string,charsmax(map_restriction_string))

	get_string(4,the_reason_string,charsmax(the_reason_string))

	new bool:white_listed_or_black_listed_bool_here = bool:get_param(2)


	return (
				
				white_listed_or_black_listed_bool_here 
	
						? 
						
			sh_register_superhero_map_whitelist_entry(heroID,map_restriction_string,the_reason_string)
	
						:
						
			sh_register_superhero_map_blacklist_entry(heroID,map_restriction_string,the_reason_string)


			)

	
	
}


bool:sh_register_superhero_map_blacklist_entry(heroID, const the_map_string[STRING_SIZE_FOR_MAP_STRING],
															const the_reason_string[REASON_STRING_LENGTH]){
	

	if(hero_map_blacklist_structs_counts[heroID] >= MAX_HERO_MAP_RESTRICTIONS_PER_HERO){

		return false
	}



	if(strlen(the_map_string)<=0){

		return false;
	}

	new curr_count = hero_map_blacklist_structs_counts[heroID]

	copy(hero_map_blacklist_structs_array[heroID][curr_count][map_restriction_substring],charsmax(the_map_string),the_map_string);

	copy(hero_map_blacklist_structs_array[heroID][curr_count][reason_string],charsmax(the_reason_string),the_reason_string);
	
	hero_map_blacklist_structs_counts[heroID] = (curr_count+1)

	return (containi(the_current_map_name,the_map_string)>=0)

}

bool:sh_register_superhero_map_whitelist_entry(heroID, const the_map_string[STRING_SIZE_FOR_MAP_STRING],
															const the_reason_string[REASON_STRING_LENGTH]){


	if(hero_map_whitelist_structs_counts[heroID] >= MAX_HERO_MAP_RESTRICTIONS_PER_HERO){

		return false
	}

	if(strlen(the_map_string)<=0){

		return false;
	}
	new curr_count = hero_map_whitelist_structs_counts[heroID]
	
	copy(hero_map_whitelist_structs_array[heroID][curr_count][map_restriction_substring],charsmax(the_map_string),the_map_string);
	
	copy(hero_map_whitelist_structs_array[heroID][curr_count][reason_string],charsmax(the_reason_string),the_reason_string);
	
	hero_map_whitelist_structs_counts[heroID] = (curr_count+1)

	return (containi(the_current_map_name,the_map_string)>=0)


}

init_fwd_ret_id:safeguard_aux_function_whitelisting(the_struct_to_check, heroID, sh_init_mode:mode){


	if(mode==SH_HERO_DROP){
		return INIT_FWD_PASS
	}

	static bool:keep_in=false

	keep_in = (containi(the_current_map_name,hero_map_whitelist_structs_array[heroID][the_struct_to_check][map_restriction_substring])>=0)

	return keep_in?INIT_FWD_PASS:INIT_FWD_BLOCK;

}
init_fwd_ret_id:safeguard_aux_function_blacklisting(the_struct_to_check, heroID, sh_init_mode:mode){


	if(mode==SH_HERO_DROP){
		return INIT_FWD_PASS
	}

	static bool:keep_away=false

	keep_away = (containi(the_current_map_name,hero_map_blacklist_structs_array[heroID][the_struct_to_check][map_restriction_substring])>=0)

	return keep_away?INIT_FWD_BLOCK:INIT_FWD_PASS;

}
public init_fwd_ret_id:sh_hero_init_pre(id,heroID, sh_init_mode:mode){

	new init_fwd_ret_id:true_return_result = INIT_FWD_PASS
	
	if((heroID<0)||(heroID>=SH_MAXHEROS)){
		return INIT_FWD_PASS
	}

	if(!client_is_within_range(id)){

		return INIT_FWD_PASS
	}
		

	static hero_name[MAX_HERO_NAME_LENGTH]
		

	if(hero_map_blacklist_structs_counts[heroID]>0){

		for(new i=0;i<hero_map_blacklist_structs_counts[heroID];i++){

			true_return_result = init_fwd_ret_id:max(
				safeguard_aux_function_blacklisting(i,
						heroID,
						mode),
						true_return_result)
			
			if(true_return_result == INIT_FWD_BLOCK){

				sh_get_hero_name_from_id(heroID,hero_name)


				sh_chat_message(id,-1,"[SH map-based hero restrictor] You can not equip ^"%s^" on maps that contain ^"%s^" in the name!",
							hero_name,
							hero_map_blacklist_structs_array[heroID][i][map_restriction_substring])

				return true_return_result
			}
		}
	}
	//this check needs to come after the blacklist check!

	if(hero_map_whitelist_structs_counts[heroID]>0){

		true_return_result = INIT_FWD_BLOCK

		for(new i=0;i<hero_map_whitelist_structs_counts[heroID];i++){

			true_return_result = init_fwd_ret_id:min(
				safeguard_aux_function_whitelisting(i,
						heroID,
						mode),
						true_return_result)
			
			if(true_return_result == INIT_FWD_PASS){
				return true_return_result
			}
		}


		if(true_return_result == INIT_FWD_BLOCK){


			sh_get_hero_name_from_id(heroID,hero_name)
						
			sh_chat_message(id,-1,"[SH map-based hero restrictor] Sorry. ^"%s^" is whitelisted and this map's name does not match any of its map whitelist entries",
						hero_name)

		}
	}

	return true_return_result

	
}