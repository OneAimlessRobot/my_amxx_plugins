#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt9: Admin only hero registratrion!"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt9.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt9.inc"

#define client_is_within_range(%1) ((%1>0 && %1<=(SH_MAXSLOTS)))

enum sh_hero_priviledges_enum_struct{

	bool:admin_only,
	required_user_flags,
	max_pickable_times,
	times_pickable_left,
	unable_to_pick_string[STRING_SIZE+1]


}
new sh_pickable_hero_struct_arr[SH_MAXHEROS][sh_hero_priviledges_enum_struct];


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);


}
public plugin_natives(){

	register_native("sh_register_admin_only_hero","_sh_register_admin_only_hero",0)
}

public sh_hero_init_pre(id,heroID,mode){

	if(!client_is_within_range(id)) return INIT_FWD_PASS

	if((heroID<0)||(heroID>=SH_MAXHEROS)){
		return INIT_FWD_PASS
	}
	if(!sh_pickable_hero_struct_arr[heroID][admin_only]){

		return INIT_FWD_PASS
	}
	if(mode==SH_HERO_ADD){

		if(!sh_pickable_hero_struct_arr[heroID][times_pickable_left]){
			if(is_user_connected(id)){
				sh_chat_message(id, heroID,"%s: the hero has already been picked too many times! The limit of people using this hero is %d!",
						sh_pickable_hero_struct_arr[heroID][unable_to_pick_string],
						sh_pickable_hero_struct_arr[heroID][max_pickable_times])
			}
			sh_strip_user_hero(id, heroID)
			return INIT_FWD_BLOCK
		}
		new flags_of_player = get_user_flags(id)

		if((flags_of_player & sh_pickable_hero_struct_arr[heroID][required_user_flags])){


			if(is_user_connected(id)){
				sh_chat_message(id, heroID,"Have fun with your admin only hero... You nepo parasite")
			}
			sh_pickable_hero_struct_arr[heroID][times_pickable_left]--

			return INIT_FWD_PASS
		}
		else{

		
			if(is_user_connected(id)){
				sh_chat_message(id, heroID,"%s: I am afraid to inform you that you do not have the required privileges to pick that hero, you scumbag",
							sh_pickable_hero_struct_arr[heroID][unable_to_pick_string])
			}
			sh_strip_user_hero(id, heroID)
			return INIT_FWD_BLOCK
		}

	}
	else if(sh_user_has_hero(id,heroID)){

		
		if(is_user_connected(id)){
			sh_chat_message(id, heroID,"Wow... it took you some time to learn decency... I am not that disappointed, anymore")
		}
		sh_pickable_hero_struct_arr[heroID][times_pickable_left]++

	}

	return INIT_FWD_PASS

}
public bool:_sh_register_admin_only_hero(iPlugins, iParams){

	new the_hero_id_to_register = get_param(1),
		the_flags_to_assign = get_param(2),
		the_number_of_times_to_allow = get_param(3)

	
	if((the_hero_id_to_register<0)||(the_hero_id_to_register>=SH_MAXHEROS)){
		server_print("Illegal hero id to register as admin only!^nHero id given was: %s^nBut it must be between 0 and %s!!!!!!!!!^n",
					the_hero_id_to_register,SH_MAXHEROS)
		return false
	}

	if(sh_pickable_hero_struct_arr[the_hero_id_to_register][admin_only]){

		server_print("This hero is already admin only!!!!!!^n");
		return false

	}

	sh_pickable_hero_struct_arr[the_hero_id_to_register][admin_only] = true
	sh_pickable_hero_struct_arr[the_hero_id_to_register][required_user_flags] = the_flags_to_assign
	sh_pickable_hero_struct_arr[the_hero_id_to_register][times_pickable_left] = the_number_of_times_to_allow
	sh_pickable_hero_struct_arr[the_hero_id_to_register][max_pickable_times] = the_number_of_times_to_allow

	get_string(4, sh_pickable_hero_struct_arr[the_hero_id_to_register][unable_to_pick_string], STRING_SIZE-1)
	/*
	server_print("Hero with id %d successfully registered as admin only!^nIt is pickable 3 times in total^nAnd its admin flag bitsum is: %d^n",
				the_hero_id_to_register,
				sh_pickable_hero_struct_arr[the_hero_id_to_register][max_pickable_times],
				sh_pickable_hero_struct_arr[the_hero_id_to_register][required_user_flags])
	*/
	return true
}