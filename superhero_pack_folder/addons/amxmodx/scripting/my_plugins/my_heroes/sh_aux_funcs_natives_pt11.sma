#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt11: superhero pickability checks: pt2"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt11.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "../my_include/auxiliar_stuff.inc"

enum property_bounds{

	property_name[128],
	max_pickable_count


}
enum property_counter{

	curr_picked_count,
	tmp_bias
}

static const sh_property_gating_array[hero_property_flags_id][property_bounds] =  {
			{"Blood thirsty",25},
			{"Explosive",4},
			{"Sleep bender",25},
			{"Core hero",25},
			{"Invisibility",25},
			{"Healing",25},
			{"Small",25},
			{"Dream eater",25},
			{"Annoying hero",25}
			

}

static sh_player_hero_property_tracker[SH_MAXSLOTS+1][hero_property_flags_id][property_counter];


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	
}


public plugin_cfg(){


	server_print("%s innited!^n",LIBRARY_NAME)
	
}

stock print_table_state(id){
	server_print("The state of the hero property gating table is:^n^n")
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){
		
		server_print("The property number %d (which is named %s)^nPlayer: %d^nHas been:^n - picked: %d times out of a maximum of %d^n",
																	i,
																	sh_property_gating_array[i][property_name],
																	id,
																	sh_player_hero_property_tracker[id][i][curr_picked_count],
																	sh_property_gating_array[i][max_pickable_count])


	}

}
public init_fwd_ret_id:sh_hero_init_pre(id,heroID, sh_init_mode:mode){
	new init_fwd_ret_id:true_return_result = INIT_FWD_PASS
	
	if(!client_is_within_range(id)){

		return INIT_FWD_PASS
	}

	if((heroID<0)||(heroID> SH_MAXHEROS)){
		return INIT_FWD_PASS
	}
	if(mode!=SH_HERO_ADD){
		
		return INIT_FWD_PASS
	}
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){

		if(sh_get_hero_bit(heroID,i)){
			if(sh_player_hero_property_tracker[id][i][curr_picked_count]
					>=
				sh_property_gating_array[i][max_pickable_count]){
			

				sh_chat_message(id,-1,"You have picked heroes with ^"%s^" property have been picked too many times! %d out of %d times...",
							sh_property_gating_array[i][property_name],
							sh_player_hero_property_tracker[id][i][curr_picked_count],
							sh_property_gating_array[i][max_pickable_count])
			
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

	if((heroID<0)||(heroID> SH_MAXHEROS)){
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
						sh_property_gating_array[i][max_pickable_count]){

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