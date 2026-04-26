#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt7: bot tools for debugging"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt7.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt7.inc"


stock const bot_power_click_cmd[]="bot_powerclick"
stock const bot_power_unclick_cmd[]="bot_powerunclick"
stock const bot_power_hold_cmd[]="bot_powerhold"


new POWER_RELEASE_TASKID
public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_concmd(bot_power_click_cmd,"bot_powerclick",ADMIN_IMMUNITY,"param 1: botname. param2: power number")
	register_concmd(bot_power_unclick_cmd,"bot_powerunclick",ADMIN_IMMUNITY,"param 1: botname. param2: power number")
	register_concmd(bot_power_hold_cmd,"bot_powerhold",ADMIN_IMMUNITY,"param 1: botname. param2: power number. param3: time")

	POWER_RELEASE_TASKID=allocate_typed_task_id(player_task)

}
public plugin_cfg(){


prepare_shero_aux_lib_pt7()


}
public plugin_natives(){


	register_native("prepare_shero_aux_lib_pt7","_prepare_shero_aux_lib_pt7",0);
}

public _prepare_shero_aux_lib_pt7(iPlugins, iParams){
	

	server_print("%s innited!^n",LIBRARY_NAME)
}
public bot_powerhold(id,level,cid){

	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new arg[32], arg2[8],arg3[8]
	read_argv(1,arg,31)
	read_argv(2,arg2,8)
	read_argv(3,arg3,8)

	new player = cmd_target(id,arg,4)

	if (!player) return PLUGIN_HANDLED


	if(!is_user_bot(player)){

		sh_chat_message(id,-1,"That player isnt a bot! Aborting...")
		return PLUGIN_HANDLED
	}
	new power_number = str_to_num(arg2)
	if((power_number<=0)|| (power_number > SH_MAXBINDPOWERS)){

		sh_chat_message(id,-1,"Invalid power number! Input a power number from 1 to %d",SH_MAXBINDPOWERS)
		return PLUGIN_HANDLED

	}

	static power_cmd_string[128]

	formatex(power_cmd_string,charsmax(power_cmd_string),"+power%d",power_number)

	amxclient_cmd(player,power_cmd_string)

	new param[1]
	param[0]=power_number

	new Float: time_held = str_to_float(arg3)

	set_task(time_held,"power_key_up_task",player+POWER_RELEASE_TASKID,param,sizeof param)

	server_print("Bot with player id %d used their power%d!^n(held for %0.2f seconds!!)^n",player,power_number, time_held)

	log_amx("Bot with player id %d used their power%d!^n(held for %0.2f seconds!!)^n",player,power_number, time_held)
	return PLUGIN_HANDLED
}
public bot_powerclick(id,level,cid){

	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new arg[32], arg2[8]
	read_argv(1,arg,31)
	read_argv(2,arg2,8)

	new player = cmd_target(id,arg,4)

	if (!player) return PLUGIN_HANDLED


	if(!is_user_bot(player)){

		sh_chat_message(id,-1,"That player isnt a bot! Aborting...")
		return PLUGIN_HANDLED
	}
	new power_number = str_to_num(arg2)
	if((power_number<=0)|| (power_number > SH_MAXBINDPOWERS)){

		sh_chat_message(id,-1,"Invalid power number! Input a power number from 1 to %d",SH_MAXBINDPOWERS)
		return PLUGIN_HANDLED

	}
	static power_cmd_string[128]

	formatex(power_cmd_string,charsmax(power_cmd_string),"+power%d",power_number)

	amxclient_cmd(player,power_cmd_string)

	server_print("Bot with player id %d holds their power%d down!^n",player,power_number)

	log_amx("Bot with player id %d holds their power%d down!^n",player,power_number)
	return PLUGIN_HANDLED
}
public bot_powerunclick(id,level,cid){

	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new arg[32], arg2[8]
	read_argv(1,arg,31)
	read_argv(2,arg2,8)

	new player = cmd_target(id,arg,4)

	if (!player) return PLUGIN_HANDLED


	if(!is_user_bot(player)){

		sh_chat_message(id,-1,"That player isnt a bot! Aborting...")
		return PLUGIN_HANDLED
	}
	new power_number = str_to_num(arg2)
	if((power_number<=0)|| (power_number > SH_MAXBINDPOWERS)){

		sh_chat_message(id,-1,"Invalid power number! Input a power number from 1 to %d",SH_MAXBINDPOWERS)
		return PLUGIN_HANDLED

	}
	static power_cmd_string[128]

	formatex(power_cmd_string,charsmax(power_cmd_string),"-power%d",power_number)

	amxclient_cmd(player,power_cmd_string)

	server_print("Bot with player id %d releases their power%d!^n",player,power_number)

	log_amx("Bot with player id %d releases their power%d!^n",player,power_number)
	return PLUGIN_HANDLED
}


public power_key_up_task(param[1],id){
	id-=POWER_RELEASE_TASKID

	new power_cmd_string[128]

	formatex(power_cmd_string,charsmax(power_cmd_string),"-power%d",param[0])


	amxclient_cmd(id,power_cmd_string)
}