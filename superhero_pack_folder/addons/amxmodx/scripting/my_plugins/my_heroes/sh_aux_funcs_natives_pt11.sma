#define I_WANT_CONSTANTS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "SH_AuxFun11: property gating"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt11.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "../my_include/auxiliar_stuff.inc"

enum hero_property_struct{
	name[64],
	description[100]

}
static const sh_hero_property_structs_array[hero_property_flags_id][hero_property_struct] =  {
			{"Blood thirsty", "Heroes that manipulate blood!"},
			
			{"Explosive", "Heroes that create explosions"},

			{"Sleep bender", "Heroes that can put players to sleep"},
			
			{"Core hero", "Complex heroes with loads of features"},
			
			{"Invisibility", "Heroes that can become invisible"},
			
			{"Healing", "Heroes that heal players"},
			
			{"Small", "Heroes with tiny size"},
			
			{"Dream eater", "Heroes that feed on your dreams"},
			
			{"Annoying hero", "Heroes that are annoying"},
			
			{"Health cap hero", "Heroes that have a healthcap"},
			
			{"No bots hero", "Heroes unable to be picked by bots"},
			
			{"Anti fall damage hero", "Heroes that do not take damage from falling"},
			
			{"Anti grenades hero", "Heroes that do not take damage from vanilla HE grenades"},
			
			{"Hitbox manipulating hero", "Heroes that can manipulate their own hitbox"},
			
			{"Respawning hero", "Heroes that respawn after dying"},
			
			{"M249 wielding hero", "Heroes that wield the M249"},
			
			{"TR45H P0W3R5 hero", "Heroes that can recycle weapons"},
			
			{"Unhealable hero", "Heroes that may not recover health"},
			
			{"Parasite hero I hate them", "I hate these heroes"},
			
			{"Yandere hero", "Heroes with too much passion"},
			
			{"Fire retardant hero", "Heroes with fire resistance"},
			
			{"Radio detector hero", "Heroes that can detect radioactivity"}
			
			

}








static const sh_property_gating_array[hero_property_flags_id] =  {
			25,
			4,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			25,
			1,
			25,
			25,
			25,
			5,
			25,
			25
			

}

enum property_counter{

	curr_picked_count,
	tmp_bias
}

static sh_player_hero_property_tracker[SH_MAXSLOTS+1][hero_property_flags_id][property_counter];


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	
	register_concmd(player_flags_print,player_flags_print,ADMIN_ALL,"param 1: playername")

	
	register_concmd(hero_properties_print,hero_properties_print,ADMIN_ALL,"param 1: part of hero name")


	register_concmd(hero_properties_descriptions_print,hero_properties_descriptions_print,ADMIN_ALL)


}


public plugin_cfg(){


	server_print("%s innited!^n",PLUGIN)
	
}

public plugin_natives(){

	register_native("sh_get_player_has_hero_prop","_sh_get_player_has_hero_prop")
}
public bool:_sh_get_player_has_hero_prop(iPLugin,iParams){

	new id = get_param(1),
		hero_property_flags_id:hero_prop_id = hero_property_flags_id:get_param(2)
	
	return (sh_player_hero_property_tracker[id][hero_prop_id][curr_picked_count] > 0)
}

stock sh_hero_properties_descriptions_print_aux(id){
	console_print(id,"The state of hero prop flags for this player is:^n^n")
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){
		
		console_print(id,"The property number %d (which is named %s) is described as:^n",
																	i,
																	sh_hero_property_structs_array[i][name])
		
		console_print(id,"^"Marked on ^"^"%s^"^n",sh_hero_property_structs_array[i][description])


	}

}
public sh_hero_properties_descriptions_print(id,level,cid){

	if (!cmd_access(id,level,cid,0))
		return PLUGIN_HANDLED

	
	sh_hero_properties_descriptions_print_aux(id)

	return PLUGIN_HANDLED

}

stock sh_print_player_hero_flags_aux(id, player_target){
	console_print(id,"The state of hero prop flags for this player is:^n^n")
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){
		
		console_print(id,"The property number %d (which is named %s)^nPlayer: %d^nHas been:^n - picked: %d times out of a maximum of %d^n",
						i,
						sh_hero_property_structs_array[i][name],
						player_target,
						sh_player_hero_property_tracker[player_target][i][curr_picked_count],
						sh_property_gating_array[i])


		console_print(id,"is player this property? %s^n",
						(sh_player_hero_property_tracker[player_target][i][curr_picked_count] > 0)?"Yes!":"No..")


	}

}

public sh_print_player_hero_flags(id,level,cid){

	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1,arg,31)

	new player = cmd_target(id,arg,2)

	if (!player) return PLUGIN_HANDLED

	sh_print_player_hero_flags_aux(id, player)

	return PLUGIN_HANDLED
}
stock sh_print_hero_property_flags_aux(id, hero_name_partial[MAX_HERO_NAME_LENGTH]){

	
	new hero_id = sh_match_string_with_hero_name(id, hero_name_partial)
	
	if(hero_id<0){

		return
	}
	
	console_print(id,"The properties that %s has are:^n^n",hero_name_partial)
	
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){


		if(!sh_get_hero_bit(hero_id,i)){

				continue;

		}

		console_print(id,"The property number %d (which is named %s)^nPlayers can only have %d heroes with this property!^n",
																	i,
																	sh_hero_property_structs_array[i][name],
																	sh_property_gating_array[i])


	}

}
public sh_print_hero_property_flags(id,level,cid){

	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new arg[MAX_HERO_NAME_LENGTH]
	read_argv(1,arg, charsmax(arg))

	sh_print_hero_property_flags_aux(id, arg)

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
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){

		if(sh_get_hero_bit(heroID,i)){
			if(sh_player_hero_property_tracker[id][i][curr_picked_count]
					>=
				sh_property_gating_array[i]){
			

				sh_chat_message(id,-1,"[SH hero property manager] You have picked heroes with ^"%s^" too many times! %d out of %d times...",
							sh_hero_property_structs_array[i][name],
							sh_player_hero_property_tracker[id][i][curr_picked_count],
							sh_property_gating_array[i])

				sh_chat_message(id,-1,"[SH hero property manager] type ^"%s <part of hero name>^" to check hero properties for a specific hero",
							hero_properties_print)
			
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


	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){

		sh_player_hero_property_tracker[id][i][tmp_bias] = 0
	}
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){

		if(sh_get_hero_bit(heroID,i)){
			switch(mode){

				case SH_HERO_ADD:{

					if(sh_player_hero_property_tracker[id][i][curr_picked_count]
							<
						sh_property_gating_array[i]){
						
						sh_player_hero_property_tracker[id][i][tmp_bias]++
					

					}
				}
				case SH_HERO_DROP:{
					
					if(sh_player_hero_property_tracker[id][i][curr_picked_count]>0){
						
						sh_player_hero_property_tracker[id][i][tmp_bias]--

					}

				}

			}
			

		}

	}
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){

		sh_player_hero_property_tracker[id][i][curr_picked_count]+=sh_player_hero_property_tracker[id][i][tmp_bias]
	}
}