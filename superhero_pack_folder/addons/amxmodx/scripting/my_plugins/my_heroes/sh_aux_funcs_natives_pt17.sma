#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt17.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt17.inc"

new the_current_map_name[STRING_SIZE_FOR_MAP_STRING]

#define MAX_HERO_MAP_RESTRICTIONS SH_MAXHEROS

new curr_num_map_restrictions = 0;
enum hero_map_restriction_struct{
	hero_id,
	map_restriction_substring[STRING_SIZE_FOR_MAP_STRING],
	optional_reason_string[REASON_STRING_LENGTH]



}
new hero_map_restriction_structs_array[MAX_HERO_MAP_RESTRICTIONS][hero_map_restriction_struct]


#define PLUGIN "SH_AuxFun17: mapwise restricting"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_concmd(check_map_restricted_heroes,check_map_restricted_heroes,ADMIN_ALL)



}
public plugin_cfg(){


	server_print("%s innited!^n",LIBRARY_NAME)
	server_print("The current map name is: %s!^n",the_current_map_name)
	
}
public plugin_precache(){

	get_mapname(the_current_map_name,charsmax(the_current_map_name))


}
stock sh_check_map_restricted_heroes_aux(id){

	static hero_name[MAX_HERO_NAME_LENGTH]

	console_print(id,"The hero map restrictions in this server are:^n")
	if(!curr_num_map_restrictions){


		console_print(id,"None are registered!^n")
		return
	}
	for(new i=0;i<curr_num_map_restrictions;i++){

		sh_get_hero_name_from_id(hero_map_restriction_structs_array[i][hero_id],hero_name)

		console_print(id,"cannot equip ^"%s^" in maps that contain ^"%s^" in the name!^n",
								hero_name,
								hero_map_restriction_structs_array[i][map_restriction_substring])

		console_print(id,"Reason: ^"%s^"^n",
								hero_map_restriction_structs_array[i][optional_reason_string])
		
		
	}

}
public sh_check_map_restricted_heroes(id,level,cid){

	if (!cmd_access(id,level,cid,0))
		return PLUGIN_HANDLED

	
	sh_check_map_restricted_heroes_aux(id)

	return PLUGIN_HANDLED
}
public plugin_natives(){

	register_native("sh_register_map_restricted_superhero","_sh_register_map_restricted_superhero")

}
public bool:_sh_register_map_restricted_superhero(iPlugins,iParams){
	new heroID=get_param(1);

	if(curr_num_map_restrictions >= MAX_HERO_MAP_RESTRICTIONS){

		return false
	}

	if((heroID <0) || (heroID >= SH_MAXHEROS)){

		return false
	}

	new map_restriction_string[STRING_SIZE_FOR_MAP_STRING];
	new optional_reason[REASON_STRING_LENGTH];

	get_string(2,map_restriction_string,charsmax(map_restriction_string))
	get_string(3,optional_reason,charsmax(optional_reason))
	
	if(strlen(map_restriction_string)<=0){

		return false;
	}

	hero_map_restriction_structs_array[curr_num_map_restrictions][hero_id] = heroID

	copy(hero_map_restriction_structs_array[curr_num_map_restrictions][map_restriction_substring],charsmax(map_restriction_string),map_restriction_string);

	copy(hero_map_restriction_structs_array[curr_num_map_restrictions][optional_reason_string],charsmax(optional_reason),optional_reason);

	curr_num_map_restrictions++

	return true;
	
}

init_fwd_ret_id:safeguard_aux_function(id, the_struct_to_check, heroID, sh_init_mode:mode){


	if(mode==SH_HERO_DROP){
		return INIT_FWD_PASS
	}
		

	static hero_name[MAX_HERO_NAME_LENGTH]

	if(the_current_map_name,hero_map_restriction_structs_array[the_struct_to_check][hero_id]!=heroID){

			return INIT_FWD_PASS;
		}
	if(containi(the_current_map_name,hero_map_restriction_structs_array[the_struct_to_check][map_restriction_substring])>=0){
		
		sh_get_hero_name_from_id(heroID,hero_name)


		sh_chat_message(id,-1,"[SH map-based hero restrictor] cannot pick ^"%s^" on maps that contain ^"%s^" in the name!",
					hero_name,
					hero_map_restriction_structs_array[the_struct_to_check][map_restriction_substring]),

		sh_chat_message(id,-1,"[SH map-based hero restrictor] Reason: ^"%s^"",
					
					hero_map_restriction_structs_array[the_struct_to_check][optional_reason_string])

		sh_chat_message(id,-1,"[SH map-based hero restrictor] type ^"%s^" to check all registered hero-map restrictions",
					check_map_restricted_heroes)
		
		return INIT_FWD_BLOCK;

	}
	
	return INIT_FWD_PASS;

}
public init_fwd_ret_id:sh_hero_init_pre(id,heroID, sh_init_mode:mode){

	new init_fwd_ret_id:true_return_result = INIT_FWD_PASS
	
	if((heroID<0)||(heroID>=SH_MAXHEROS)){
		return INIT_FWD_PASS
	}

	if(!client_is_within_range(id)){

		return INIT_FWD_PASS
	}

	for(new i=0;i<curr_num_map_restrictions;i++){

		true_return_result = init_fwd_ret_id:max(
			safeguard_aux_function(id,
					i,
					heroID,
					mode),
					true_return_result)
		
		if(true_return_result == INIT_FWD_BLOCK){
			break
		}
	}

	return true_return_result
}