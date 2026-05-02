#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt7: bot tools for debugging"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt7.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt7.inc"


stock const bot_click_cmd[]="bot_cmdclick"
stock const bot_unclick_cmd[]="bot_cmdunclick"
stock const bot_hold_cmd[]="bot_cmdhold"


new CMD_RELEASE_TASKID
public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_concmd(bot_click_cmd,"bot_cmdclick",ADMIN_IMMUNITY,"param 1: botname. param2: cmd name")
	register_concmd(bot_unclick_cmd,"bot_cmdunclick",ADMIN_IMMUNITY,"param 1: botname. param2: cmd name")
	register_concmd(bot_hold_cmd,"bot_cmdhold",ADMIN_IMMUNITY,"param 1: botname. param2: cmd name. param3: time")

	CMD_RELEASE_TASKID=allocate_typed_task_id(player_task)

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
public bot_cmdhold(id,level,cid){

	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new arg[32], arg2[32],arg3[8]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,8)

	new player = cmd_target(id,arg,4)

	if (!player) return PLUGIN_HANDLED


	if(!is_user_bot(player)){

		sh_chat_message(id,-1,"That player isnt a bot! Aborting...")
		return PLUGIN_HANDLED
	}

	static bot_cmd_string[128]

	formatex(bot_cmd_string,charsmax(bot_cmd_string),"+%s",arg2)

	amxclient_cmd(player,bot_cmd_string)

	new param[32]

	copy(param,31,arg2)
	new Float: time_held = str_to_float(arg3)

	set_task(time_held,"bot_cmd_off_task",player+CMD_RELEASE_TASKID,param,sizeof param)

	server_print("Bot with player id %d held command %s for %0.2f seconds!!^n",player,arg2, time_held)

	log_amx("Bot with player id %d held command %s for %0.2f seconds!!^n",player,arg2, time_held)
	
	return PLUGIN_HANDLED
}
public bot_cmdclick(id,level,cid){

	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new arg[32], arg2[8]
	read_argv(1,arg,31)
	read_argv(2,arg2,32)

	new player = cmd_target(id,arg,4)

	if (!player) return PLUGIN_HANDLED


	if(!is_user_bot(player)){

		sh_chat_message(id,-1,"That player isnt a bot! Aborting...")
		return PLUGIN_HANDLED
	}
	static bot_cmd_string[128]

	formatex(bot_cmd_string,charsmax(bot_cmd_string),"+%s",arg2)

	amxclient_cmd(player,bot_cmd_string)

	server_print("Bot with player id %d holds command %s down!^n",player,arg2)

	log_amx("Bot with player id %d holds command %s down!^n",player,arg2)
	
	return PLUGIN_HANDLED
}
public bot_cmdunclick(id,level,cid){

	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new arg[32], arg2[32]
	read_argv(1,arg,31)
	read_argv(2,arg2,32)

	new player = cmd_target(id,arg,4)

	if (!player) return PLUGIN_HANDLED


	if(!is_user_bot(player)){

		sh_chat_message(id,-1,"That player isnt a bot! Aborting...")
		return PLUGIN_HANDLED
	}
	static bot_cmd_string[128]

	formatex(bot_cmd_string,charsmax(bot_cmd_string),"-%s",arg2)

	amxclient_cmd(player,bot_cmd_string)

	server_print("Bot with player id %d releases command %s!^n",player,arg2)

	log_amx("Bot with player id %d releases command %s!^n",player,arg2)
	return PLUGIN_HANDLED
}


public power_key_up_task(param[32],id){
	id-=CMD_RELEASE_TASKID

	new bot_cmd_string[128]

	formatex(bot_cmd_string,charsmax(bot_cmd_string),"-%s",param)


	amxclient_cmd(id,bot_cmd_string)
}