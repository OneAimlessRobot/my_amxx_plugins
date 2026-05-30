#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt11: superhero pickability checks: pt2"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt11.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "../my_include/auxiliar_stuff.inc"

enum property_counter{

	property_name[128],
	max_pickable_count,
	curr_picked_count,
	tmp_bias


}

new sh_property_gating_array[hero_property_flags_id][property_counter] =  {
			{"Bloodthirsty",25,0,0},
			{"Explosive",3,0,0},
			{"Dream eater",25,0,0},
			{"Core hero",25,0,0},
			{"Invisibility",25,0,0}
			

}


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);
	
}
print_table_state(){
	server_print("The state of the hero property gating table is:^n^n")
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){
		
		server_print("The property number %d (which is named %s)^nHas been:^n - picked: %d times out of a maximum of %d^n",
																	i,
																	sh_property_gating_array[i][property_name],
																	sh_property_gating_array[i][curr_picked_count],
																	sh_property_gating_array[i][max_pickable_count])


	}

}
public sh_hero_init_pre(id,heroID, sh_init_mode:mode){
	new true_return_result = INIT_FWD_PASS
	
	if(!client_is_within_range(id)){

		return INIT_FWD_PASS
	}

	if((heroID<0)||(heroID> SH_MAXHEROS)){
		return INIT_FWD_PASS
	}


	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){

		sh_property_gating_array[i][tmp_bias] = 0
	}
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){

		if(sh_get_hero_bit(heroID,i)){
			switch(mode){

				case SH_HERO_ADD:{

					if(sh_property_gating_array[i][curr_picked_count]
							>=
						sh_property_gating_array[i][max_pickable_count]){
					

						sh_chat_message(id,-1,"Heroes with ^"%s^" property have been picked too many times! %d out of %d times...",
									sh_property_gating_array[i][property_name],
									sh_property_gating_array[i][curr_picked_count],
									sh_property_gating_array[i][max_pickable_count])
					
						true_return_result =  INIT_FWD_BLOCK
						break;
					}
					else{
						sh_property_gating_array[i][tmp_bias]++

						server_print("A hero with ^"%s^" property has been picked! %d out of %d times...",
									sh_property_gating_array[i][property_name],
									sh_property_gating_array[i][curr_picked_count]+sh_property_gating_array[i][tmp_bias],
									sh_property_gating_array[i][max_pickable_count])
					

					}
				}
				case SH_HERO_DROP:{
					
					if(sh_property_gating_array[i][curr_picked_count]>0){

						sh_property_gating_array[i][tmp_bias]--
					
					}

				}

			}
			

		}

	}
	for(new hero_property_flags_id:i=enum_zero;i<hero_property_flags_id;i++){

		sh_property_gating_array[i][curr_picked_count]+=sh_property_gating_array[i][tmp_bias]
	}

	return true_return_result
}