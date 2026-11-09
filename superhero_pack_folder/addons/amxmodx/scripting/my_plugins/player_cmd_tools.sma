#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include "task_allocator_inc/task_allocator_aux_stuff.inc"

#define PLUGIN "player cmd tools for debugging"
#define VERSION "1.0.0"
#include "my_include/my_author_header.inc"


stock const player_click_cmd[]="player_cmdclick"
stock const player_hold_cmd[]="player_cmdhold"


new CMD_RELEASE_TASKID
public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_concmd(player_click_cmd,"player_cmdclick",ADMIN_IMMUNITY,"param 1: playername. param2: cmd name param3: use engcmd param4: send console_cmd")
	register_concmd(player_hold_cmd,"player_cmdhold",ADMIN_IMMUNITY,"param 1: playername. param2: cmd name. param3: time param4: use engcmd param5: send console_cmd")

	CMD_RELEASE_TASKID=allocate_typed_task_id(player_task)

}

public player_cmdhold(id,level,cid){

	if (!cmd_access(id,level,cid,6))
		return PLUGIN_HANDLED

	static arg[32], arg2[32],arg3[8],arg4[8], arg5[8]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,8)
	read_argv(4,arg4,8)
	read_argv(5,arg5,8)

	new player = cmd_target(id,arg,6)

	if (!player) return PLUGIN_HANDLED

	static player_cmd_string[128]

	formatex(player_cmd_string,charsmax(player_cmd_string),"+%s",arg2)

	new bool:use_engcmd=bool:str_to_num(arg4)
	new bool:use_concmd=bool:str_to_num(arg5)
	if(!use_engcmd){
		amxclient_cmd(player,player_cmd_string)
	}
	else if(!use_concmd){
		engclient_cmd(player,player_cmd_string)
	}
	else{

		console_cmd(player, player_cmd_string)
	}
	new param[34]

	copy(param,31,arg2)
	param[32]=_:use_engcmd
	param[33]=_:use_concmd
	new Float: time_held = str_to_float(arg3)
	if(!task_exists(player+CMD_RELEASE_TASKID)){
		set_task(time_held,"player_cmd_off_task",player+CMD_RELEASE_TASKID,param,sizeof param)
	}
	else{
		remove_task(player+CMD_RELEASE_TASKID)
		player_cmd_off_task(param,player+CMD_RELEASE_TASKID)
	}
	server_print("Bot with player id %d held command %s for %0.2f seconds!!^n",player,arg2, time_held)

	log_amx("Bot with player id %d held command %s for %0.2f seconds!!^n",player,arg2, time_held)
	
	return PLUGIN_HANDLED
}
public player_cmdclick(id,level,cid){

	if (!cmd_access(id,level,cid,5))
		return PLUGIN_HANDLED

	static arg[32], arg2[32], arg3[8], arg4[8]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,8)
	read_argv(4,arg4,8)

	new player = cmd_target(id,arg,6)

	if (!player) return PLUGIN_HANDLED

	static player_cmd_string[128]

	formatex(player_cmd_string,charsmax(player_cmd_string),"%s",arg2)

	new bool:use_engcmd=bool:str_to_num(arg3)
	new bool:use_concmd=bool:str_to_num(arg4)
	
	if(!use_engcmd){
		amxclient_cmd(player,player_cmd_string)
	}
	else if(!use_concmd){
		engclient_cmd(player,player_cmd_string)
	}
	else{

		console_cmd(player,player_cmd_string)

	}

	server_print("Bot with player id %d clicks command %s!^n",player,arg2)

	log_amx("Bot with player id %d clicks command %s!^n",player,arg2)
	
	return PLUGIN_HANDLED
}
public player_cmd_off_task(param[34],id){
	id-=CMD_RELEASE_TASKID

	new player_cmd_string[128]

	formatex(player_cmd_string,charsmax(player_cmd_string),"-%s",param)
	new bool:use_engcmd= bool:param[32],
		bool:use_consolecmd = bool:param[33]


	if(!use_engcmd){
		engclient_cmd(id,player_cmd_string)
	}
	else if(!use_consolecmd){
		amxclient_cmd(id,player_cmd_string)
	}
	else{

		console_cmd(id,player_cmd_string)

	}
}