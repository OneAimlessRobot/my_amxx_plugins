#define I_WANT_CONSTANTS
#define I_WANT_BASIC_MACROS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "SH_AuxFun9: Admn Only REG"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt9.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt9.inc"


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
	register_concmd(admin_compatibility_print,admin_compatibility_print,ADMIN_ALL)


}
public plugin_cfg(){


	server_print("%s innited!^n",PLUGIN)
	
}
bool:sh_register_admin_only_hero_primitive(the_hero_id_to_register,
          admin_flags_required = ADMIN_IMMUNITY,
          num_pickable_times = -1,
          const unable_to_pick_msg[STRING_SIZE] = "Unable to pick"){

	
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
	sh_pickable_hero_struct_arr[the_hero_id_to_register][required_user_flags] = admin_flags_required
	sh_pickable_hero_struct_arr[the_hero_id_to_register][times_pickable_left] = num_pickable_times
	sh_pickable_hero_struct_arr[the_hero_id_to_register][max_pickable_times] = num_pickable_times

	copy(sh_pickable_hero_struct_arr[the_hero_id_to_register][unable_to_pick_string], STRING_SIZE-1,unable_to_pick_msg)

	return true
}

stock sh_admin_compatibility_print_aux(id){

	static hero_name[MAX_HERO_NAME_LENGTH]

	console_print(id,"The admin only heroes registered on this server are:^n")
	
	for(new i=0;i<SH_MAXHEROS;i++){
		
		if(!sh_pickable_hero_struct_arr[i][admin_only]){
			continue

		}

		sh_get_hero_name_from_id(i,hero_name)

		console_print(id,"^"%s^" is registered!^nIt is pickable %d times in total^nAnd its admin flag bitsum is: %d^n",
				hero_name,
				sh_pickable_hero_struct_arr[i][max_pickable_times],
				sh_pickable_hero_struct_arr[i][required_user_flags])
		
		
		
	}

}
public sh_admin_compatibility_print(id,level,cid){

	if (!cmd_access(id,level,cid,0))
		return PLUGIN_HANDLED

	
	sh_admin_compatibility_print_aux(id)

	return PLUGIN_HANDLED
}
public plugin_natives(){

	register_native("sh_register_admin_only_hero","_sh_register_admin_only_hero")
}

public init_fwd_ret_id:sh_hero_init_pre(id,heroID, sh_init_mode:mode){

	if(!client_is_within_range(id)) return INIT_FWD_PASS

	if((heroID<0)||(heroID>=SH_MAXHEROS)){
		return INIT_FWD_PASS
	}
	if(!sh_pickable_hero_struct_arr[heroID][admin_only]){

		return INIT_FWD_PASS
	}
	if(mode==SH_HERO_ADD){

		new flags_of_player = get_user_flags(id)

		if(!(flags_of_player & sh_pickable_hero_struct_arr[heroID][required_user_flags])||
					!sh_pickable_hero_struct_arr[heroID][times_pickable_left]){

		
			sh_chat_message(id, heroID,"%s",sh_pickable_hero_struct_arr[heroID][unable_to_pick_string])
			sh_chat_message(id, heroID,"[SH admin only and server-limited hero picking manager] Type %s in the console to get a list of all admin heroes",admin_compatibility_print)
			

			return INIT_FWD_BLOCK
		}

	}

	return INIT_FWD_PASS

}

public sh_hero_init(id,heroID, sh_init_mode:mode){

	if(!client_is_within_range(id)) return

	if((heroID<0)||(heroID>=SH_MAXHEROS)){
		return
	}
	if(!sh_pickable_hero_struct_arr[heroID][admin_only]){

		return
	}
	if(mode==SH_HERO_ADD){
		new flags_of_player = get_user_flags(id)

		if((flags_of_player & sh_pickable_hero_struct_arr[heroID][required_user_flags])){


			sh_chat_message(id, heroID,"Have fun with your admin only hero... You nepo parasite")
			sh_pickable_hero_struct_arr[heroID][times_pickable_left]--
		}

	}
	else{

		
		sh_chat_message(id, heroID,"Wow... it took you some time to learn decency... I am not that disappointed, anymore")
		sh_pickable_hero_struct_arr[heroID][times_pickable_left]++

	}

}

public bool:_sh_register_admin_only_hero(iPlugins, iParams){

	new the_hero_id_to_register = get_param(1),
		the_flags_to_assign = get_param(2),
		the_number_of_times_to_allow = get_param(3)

	static pickable_string[STRING_SIZE]
	

	get_string(4, pickable_string, charsmax(pickable_string))

	return sh_register_admin_only_hero_primitive(the_hero_id_to_register,
									the_flags_to_assign,
									the_number_of_times_to_allow,
									pickable_string)

}