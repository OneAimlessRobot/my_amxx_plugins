
 ///////////////////////////////////////////////////////////////////
 //   ______      _                 _       _     _      		  //
 //  |  ____|    | |               | |     | |   | |     		  //
 //  | |__  __  _| |_ ___ _ __   __| | __ _| |__ | | ___ 		  //
 //  |  __| \ \/ / __/ _ \ '_ \ / _` |/ _` | '_ \| |/ _ \		  //
 //  | |____ >  <| ||  __/ | | | (_| | (_| | |_) | |  __/		  //
 //  |______/_/\_\\__\___|_| |_|\__,_|\__,_|_.__/|_|\___|		  //
 //               _           _         __  __                    //
 //      /\      | |         (_)       |  \/  |                   //
 //     /  \   __| |_ __ ___  _ _ __   | \  / | ___ _ __  _   _   //
 //    / /\ \ / _` | '_ ` _ \| | '_ \  | |\/| |/ _ \ '_ \| | | |  //
 //   / ____ \ (_| | | | | | | | | | | | |  | |  __/ | | | |_| |  //
 //  /_/    \_\__,_|_| |_| |_|_|_| |_| |_|  |_|\___|_| |_|\__,_|  //
 //																  //
 ///////////////////////////////////////////////////////////////////

 #include <amxmodx>
 #include <amxmisc>
 #include <cstrike>
 #include <engine>

 new const PLUGNAME[] =			"Extendable Admin Menu";
 #define AUTHOR					"Emp`"
 new const VERSION[] =			"0.1";

 /////////////////////////////////
 enum		//					//
 {			//					//
	NONE,	//					//
	CS,		//	  Do NOT Edit	//
	DOD,	//	     These		//
	NS,		//					//
	TFC		//					//
 }			//					//
 //////////////////////////////////////////////////////////
 new MOD;	// No need to define, we can check ourselves //
 
 /////////////////////////////////
 enum		//					//
 {			//					//
	NVAULT,	//	  Do Not Edit	//
	VAULT	//	     These		//
 }			//					//
 //////////////////////////////////////////////////////////////////////////////////////
 #define OPTION_SAVE	NVAULT	// Edit this to how you wish to save command options //
 
 /////////////////////////////////////
 enum			//					//
 {				//					//
	AC_AMXX,	//	  Do Not Edit	//
	AC_EAM,		//	     These		//
	AC_BOTH		//					//
 }				//					//
 //////////////////////////////////////////////////////////////////////////////////////////////
 #define AC_TYPE	AC_BOTH	// Edit this to what type of access grants players access to EAM //

 #define MAX_LOGIN_ATTEMPTS	5	//Max amount of times they can try to login


 // Use this to create the table in MySQL
 /*

 CREATE TABLE IF NOT EXISTS `eam_args` ( 
	`ARG_INFO` varchar(500) binary NOT NULL default '',
	PRIMARY KEY  (`ARG_INFO`)
 ) TYPE=MyISAM COMMENT='EAM Arg Info Table'; 

 */
 // Everything below here is just used for the plugin. Nothing else customizeable.

 #if OPTION_SAVE == NVAULT
	#include <nvault>
	new nvault_db;
 #endif

 #define _eam_base
 #include <eam>

 #pragma semicolon 1

 new	 MAX_TEAMS;

 new CATEGORY_NAME[MAX_CATEGORIES+1][CATEGORY_NAME_LENGTH];
 new CATEGORY_ACCESS[MAX_CATEGORIES+1];
 new COMMAND_NAME[MAX_COMMANDS+1][COMMAND_NAME_LENGTH];
 new COMMAND_CATEGORY[MAX_COMMANDS+1];
 new COMMAND_COMMENT[MAX_COMMANDS+1][COMMENT_LENGTH];
 new COMMAND_SELECTION[MAX_COMMANDS+1][MAX_ARGUMENTS+1][MAX_OPTIONS];
 new COMMAND_ACCESS[MAX_COMMANDS+1];
 new COMMAND_EXEC[MAX_COMMANDS+1];

 enum{
	PLAYER = 1,
	TEAM,
	PLAYER_OR_TEAM,
	RANGE,
	F_RANGE,
	OPTIONS,
	OPT_OR_PLYR,
	INPUT
 }
 enum{
	USERID = 1,
	AUTHID,
	USERNAME
 }
 
 enum{
	CVAR = 1,
	ADMIN_CONST,
	FLAG
 }
 
 enum{
	EXEC_PLAYER = 0,
	EXEC_SERVER,
	EXEC_ALL
 }

 new g_coloredMenus;
 new last_category_registered;
 new last_command_registered;
 new SetupForward = -1;
 
 new PlayerPos[MAX_PLAYERS+1];						//position player is in in the menu
 new PlayerArg[MAX_PLAYERS+1];						//argument player is in in the command
 new Float:PlayerArgs[MAX_PLAYERS+1][MAX_ARGUMENTS+1];	//currently saved arguments
 new PlayerPlayers[MAX_PLAYERS+1][MAX_PLAYERS+MAX_OPTIONS];
 new PlayerNum[MAX_PLAYERS+1];
 new PlayerCat[MAX_PLAYERS+1];
 new PlayerInput[MAX_PLAYERS+1][MAX_ARGUMENTS][INPUT_LENGTH];

 new Float:PlayerRange[MAX_PLAYERS+1];					//multiplier for changing a range
 new PlayerEAM[MAX_PLAYERS+1];			//how much access they have within EAM
 new PlayerDeny[MAX_PLAYERS+1];			//how many times they have input a wrong password
 
 public plugin_init()
 {
	register_dictionary("eam.txt");
	register_dictionary("common.txt");

	new lang_temp[51], lang_temp2[51];
	formatex(lang_temp, 50, "%L", 0, "EAM_NAME");
	register_plugin(lang_temp, VERSION, AUTHOR);

	register_cvar(PLUGNAME,VERSION,FCVAR_SERVER|FCVAR_SPONLY);
	set_cvar_string(PLUGNAME,VERSION);

	formatex(lang_temp, 50, "%L", 0, "EAM_PREFIX");
	strtolower(lang_temp);
	formatex(lang_temp2, 50, "%L", 0, "EAM_HELP1");
	register_clcmd(lang_temp, "cmdEAM", 0, lang_temp2);

	formatex(lang_temp, 50, "%L", 0, "EAM_COM_REFRESH");
	formatex(lang_temp2, 50, "%L", 0, "EAM_HELP2");
	register_concmd(lang_temp, "start_setup", ADMIN_MENU, lang_temp2);

	formatex(lang_temp, 50, "%L", 0, "EAM_COM_LOGIN");
	formatex(lang_temp2, 50, "%L", 0, "EAM_HELP3");
	register_concmd(lang_temp, "eam_login", 0, lang_temp2);

	formatex(lang_temp, 50, "%L", 0, "EAM_USERS");
	formatex(lang_temp2, 50, "%L", 0, "EAM_HELP4");
	register_concmd(lang_temp, "show_users", ADMIN_ADMIN, lang_temp2);

	//let's add to the menu
	SetupForward = CreateMultiForward("eam_setup", ET_STOP);	//stop on return value
	set_task(5.0, "start_setup");

	register_menucmd(register_menuid("EAM - Category"), 1023, "actionCategory");
	register_menucmd(register_menuid("EAM - Commands"), 1023, "actionCommand");
	register_menucmd(register_menuid("EAM - Argument"), 1023, "actionArgument");

	if( is_running("czero") || is_running("cstrike") )
		MOD = CS;
	else if( is_running("tfc") )
		MOD = TFC;
	else if( is_running("dod") )
		MOD = DOD;
	else if( is_running("ns") )
		MOD = NS;
	else
		MOD = NONE;

	g_coloredMenus = colored_menus();

	if( MOD == TFC)
		MAX_TEAMS = 4;
	else
		MAX_TEAMS = 2;

	#if OPTION_SAVE == NVAULT
		nvault_db = nvault_open("eam_options");
	#endif

	register_clcmd("say","HandleSay");
 }
 
 public start_setup()
 {
	//get rid of any saved information
	plugin_end();

	last_category_registered = 1;
	last_command_registered = 1;
	if(SetupForward > -1){
		new functionReturn;
		ExecuteForward(SetupForward, functionReturn);
	}
	console_print(0, "[%L] %L", 0, "EAM_PREFIX", 0, "EAM_LOADED", last_category_registered-1, last_command_registered-1);
	eam_login(0);
 }

 public plugin_natives()
 {
	//we need to block things, if they aren't going to be used, that will pause the plugin
	set_native_filter( "native_trapper" );
	set_module_filter( "module_filter" );

	register_library("eam");

	register_native(	"eam_category_register",	"_category_register");
	register_native(	"eam_category_access",		"_category_access");
	register_native(	"eam_command_register",		"_command_register");
	register_native(	"eam_command_comment",		"_command_comment");
	register_native(	"eam_command_category",		"_command_category");
	register_native(	"eam_command_arg",			"_command_arg");
	register_native(	"eam_command_access",		"_command_access");
	register_native(	"eam_command_exec",			"_command_exec");
 }
 
 public plugin_end()
 {
	#if OPTION_SAVE == NVAULT
		nvault_prune(nvault_db, 0, get_systime());
	#endif
 }
 
 public module_filter(const module[])
 {
	if (equali(module, "cstrike"))
		return PLUGIN_HANDLED;
	else if(equali(module, "engine"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
 }

 public native_trapper(const name[], index, trap)
 {
	if (!trap)
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
 }
 
 public client_connect(id)
 {
	PlayerEAM[id] = 0;
	PlayerRange[id] = 1.0;
	PlayerDeny[id] = 0;
 }

 //Check for auto access
 public client_putinserver(id)
	eam_login(id);

 eam_error(const error[], {Float,Sql,Result,_}:...)
 {
	new output[256];
	vformat(output, 255, error, 2);
	log_amx(output);
 }

 public _category_register(iPlugin,iParams)
 {
	if(iParams != 1)
		return 0;

	if(last_category_registered > MAX_CATEGORIES){
		eam_error("%L", 0, "EAM_MAX_CATS");
		return 0;
	}

	new category = last_category_registered++;

	get_string(1, CATEGORY_NAME[category], CATEGORY_NAME_LENGTH-1);

	return category;
 }
 public _category_access(iPlugin,iParams)
 {
	if(iParams != 3)
		return 0;

	new category = get_param(1);
	if(!category || category > MAX_CATEGORIES)
		return 0;

	new access = get_param(2);
	if(!access)
		return 0;

	switch(access)
	{
		case CVAR:{
			new cvar_string[16];
			new cvar_value[16];
			get_string(3, cvar_string, 15);
			get_cvar_string(cvar_string, cvar_value, 15);
			CATEGORY_ACCESS[category] = read_flags(cvar_value);
		}
		case ADMIN_CONST:{
			CATEGORY_ACCESS[category] = get_param(3);
		}
		case FLAG:{
			new param_string[16];
			get_string(3, param_string, 15);
			CATEGORY_ACCESS[category] = read_flags(param_string);
		}
	}

	return category;
 }

 public _command_register(iPlugin,iParams)
 {
	if(iParams != 1)
		return 0;

	if(last_command_registered > MAX_COMMANDS){
		eam_error("%L", 0, "EAM_MAX_COMS");
		return 0;
	}

	new command = last_command_registered++;

	get_string(1, COMMAND_NAME[command], COMMAND_NAME_LENGTH-1);

	return command;
 }
 public _command_comment(iPlugin,iParams)
 {
	if(iParams != 2)
		return 0;

	new command = get_param(1);
	if(!command || command > MAX_COMMANDS)
		return 0;

	get_string(2, COMMAND_COMMENT[command], COMMENT_LENGTH-1);

	return command;
 }
 public _command_category(iPlugin,iParams)
 {
	if(iParams != 2)
		return 0;

	new command = get_param(1);
	if(!command || command > MAX_COMMANDS)
		return 0;

	new category = get_param(2);
	if(!category || category > MAX_CATEGORIES)
		return 0;

	COMMAND_CATEGORY[command] = category;

	return command;
 }

 public _command_arg(iPlugin,iParams)
 {
	if(iParams < 3 || iParams > 3 + MAX_OPTIONS)
		return 0;

	new command = get_param(1);
	if(!command || command > MAX_COMMANDS)
		return 0;

	new argument = get_param(2);
	if(!argument || argument > MAX_ARGUMENTS)
		return 0;

	new type = get_param(3);
	if(!type)
		return 0;
	COMMAND_SELECTION[command][0][argument] = type;

	switch(type)
	{
		case PLAYER, PLAYER_OR_TEAM:{
			new player_type = get_param_byref(4);

			if(!player_type)
				return 0;

			formatex(COMMAND_SELECTION[command][argument], MAX_OPTIONS-1, "%d", player_type);
		}
		case RANGE:{
			new start_range = get_param_byref(4);
			new end_range = get_param_byref(5);

			if(end_range < start_range){
				eam_error("[%L] %L", 0,"EAM_PREFIX", 0,"EAM_ERROR_RANGE", COMMAND_NAME[command],argument);
				end_range = start_range;
			}

			COMMAND_SELECTION[command][argument][0] = start_range;
			COMMAND_SELECTION[command][argument][1] = end_range;
		}
		case F_RANGE:{
			new Float:start_range = get_float_byref(4);
			new Float:end_range = get_float_byref(5);

			if(end_range < start_range){
				eam_error("[%L] %L", 0,"EAM_PREFIX", 0,"EAM_ERROR_RANGE", COMMAND_NAME[command],argument);
				end_range = start_range;
			}

			formatex(COMMAND_SELECTION[command][argument], MAX_OPTIONS-1, "%.1f %.1f", start_range, end_range);
		}
		case OPTIONS:{
			new total_options[MAX_OPTIONS * OPTION_NAME_LENGTH];
			get_string(4, total_options, (MAX_OPTIONS * OPTION_NAME_LENGTH) - 1);
			save_arg_info(command, argument, total_options);
		}
		case OPT_OR_PLYR:{
			new player_type = get_param_byref(4);
			if(!player_type)
				return 0;
			formatex(COMMAND_SELECTION[command][argument], MAX_OPTIONS-1, "%d", player_type);

			new total_options[MAX_OPTIONS * OPTION_NAME_LENGTH];
			get_string(5, total_options, (MAX_OPTIONS * OPTION_NAME_LENGTH) - 1);
			save_arg_info(command, argument, total_options);
		}
		case INPUT:{
			new input_comment[COMMENT_LENGTH];
			get_string(4, input_comment, COMMENT_LENGTH-1);
			remove_quotes(input_comment);
			save_arg_info(command, argument, input_comment);
		}
		default:{
			formatex(COMMAND_SELECTION[command][argument], MAX_OPTIONS-1, "%d", type);
		}
	}

	return command;
 }
 save_arg_info(const command, const argument, const info[])
 {
	new save_key[COMMAND_NAME_LENGTH];
	formatex(save_key, COMMAND_NAME_LENGTH-1, "%d_%d", command, argument);

	#if OPTION_SAVE == NVAULT
		nvault_set(nvault_db, save_key, info);
	#endif

	#if OPTION_SAVE == VAULT
		set_vaultdata(save_key, info );
	#endif
 }

 public _command_access(iPlugin,iParams)
 {
	if(iParams != 3)
		return 0;

	new command = get_param(1);
	if(!command)
		return 0;

	new access = get_param(2);
	if(!access)
		return 0;

	switch(access)
	{
		case CVAR:{
			new cvar_string[16];
			new cvar_value[16];
			get_string(3, cvar_string, 15);
			get_cvar_string(cvar_string, cvar_value, 15);
			COMMAND_ACCESS[command] = read_flags(cvar_value);
		}
		case ADMIN_CONST:{
			COMMAND_ACCESS[command] = get_param(3);
		}
		case FLAG:{
			new param_string[16];
			get_string(3, param_string, 15);
			COMMAND_ACCESS[command] = read_flags(param_string);
		}
	}

	return command;
 }
 public _command_exec(iPlugin,iParams)
 {
	if(iParams != 2)
		return 0;

	new command = get_param(1);
	if(!command)
		return 0;

	COMMAND_EXEC[command] = get_param(2);

	return command;
 }
 
 get_category(const command)
 {
	if(!command || command > MAX_COMMANDS)
		return 0;
	return COMMAND_CATEGORY[command];
 }
 
 eam_get_commands(commands[MAX_COMMANDS], &cnum, const cat_num)
 {
	new i, total = 0;
	for(i=1; i<last_command_registered; i++)
	{
		if(!cat_num || get_category(i) == cat_num)
		{
			commands[total] = i;
			total++;
		}
	}
	cnum = total;

	return true;
 }
 
 get_argument_type(const command, const argument)
 {
	if(!command || command > MAX_COMMANDS || !argument || argument > MAX_ARGUMENTS)
		return 0;
	return COMMAND_SELECTION[command][0][argument];
 }
 get_player_type(const command, const argument)
 {
	if(!command || command > MAX_COMMANDS || !argument || argument > MAX_ARGUMENTS)
		return 0;
	return str_to_num(COMMAND_SELECTION[command][argument]);
 }
 Float:lower_command_range(const command, const argument)
 {
	if(!command || command > MAX_COMMANDS || !argument || argument > MAX_ARGUMENTS)
		return 0.0;

	if(get_argument_type(command, argument)==RANGE)
		return float(COMMAND_SELECTION[command][argument][0]);

	new Left[11], Right[11];
	argbreak(COMMAND_SELECTION[command][argument], Left, 10, Right, 10);
	return str_to_float(Left);
 }
 Float:upper_command_range(const command, const argument)
 {
	if(!command || command > MAX_COMMANDS || !argument || argument > MAX_ARGUMENTS)
		return 0.0;

	if(get_argument_type(command, argument)==RANGE)
		return float(COMMAND_SELECTION[command][argument][1]);

	new Left[11], Right[11];
	argbreak(COMMAND_SELECTION[command][argument], Left, 10, Right, 10);
	return str_to_float(Right);
 }
 command_option(const command, const argument, const option_num, option[], len)
 {
	new save_key[COMMAND_NAME_LENGTH], total_options[OPTION_NAME_LENGTH * MAX_OPTIONS];
	formatex(save_key, COMMAND_NAME_LENGTH-1, "%d_%d", command, argument);

	#if OPTION_SAVE == NVAULT
		nvault_get(nvault_db, save_key, total_options, (OPTION_NAME_LENGTH * MAX_OPTIONS)-1 );
	#endif
	#if OPTION_SAVE == VAULT
		get_vaultdata(save_key, total_options, (OPTION_NAME_LENGTH * MAX_OPTIONS)-1 );
	#endif

	for(new i = 0; i<option_num; i++)
		strbrkqt(total_options, option, len, total_options, (OPTION_NAME_LENGTH * MAX_OPTIONS)-1 );

	remove_quotes(option);

	if(option[0])
		return true;
	return false;
 }
 input_comment(const command, const argument, comment[], len)
 {
	new save_key[COMMAND_NAME_LENGTH];
	formatex(save_key, COMMAND_NAME_LENGTH-1, "%d_%d", command, argument);

	#if OPTION_SAVE == NVAULT
		nvault_get(nvault_db, save_key, comment, len );
	#endif
	#if OPTION_SAVE == VAULT
		get_vaultdata(save_key, comment, len );
	#endif

	if(comment[0])
		return true;
	return false;
 }

 public cmdEAM(id)
 {
	if( PlayerDeny[id] > MAX_LOGIN_ATTEMPTS ){
		console_print(id, "%L", id,"EAM_DENY");
		return PLUGIN_HANDLED;
	}

	display_EAM_cats(id, PlayerPos[id] = 1);
	return PLUGIN_HANDLED;
 }
 public show_users(id, level, cid)
 {
	if (!eam_cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;

	new players[32], inum, cl_on_server[64], authid[32], name[32], sflags[32], player;
	new lAccess[16];

	formatex(lAccess, 15, "%L", id, "ACCESS");

	eam_get_players(players, inum);
	formatex(cl_on_server, 63, "%L", id, "CLIENTS_ON_SERVER");
	console_print(id, "^n%s:^n #  %-16.15s %-20s %-8s %s", cl_on_server, "nick", "authid", "userid", lAccess);
	
	for (new a = 0; a < inum; ++a)
	{
		player = players[a];
		get_user_authid(player, authid, 31);
		get_user_name(player, name, 31);

		#if AC_TYPE == AC_AMXX
		lAccess[0] = get_user_flags(player);
		#endif
		#if AC_TYPE == AC_EAM
		lAccess[0] = PlayerEAM[player];
		#endif
		#if AC_TYPE == AC_BOTH
		lAccess[0] = get_user_flags(player) | PlayerEAM[player];
		#endif

		get_flags(	lAccess[0]	, sflags, 31);
		console_print(id, "%2d  %-16.15s %-20s %-8d %s", player, name, authid, 
		get_user_userid(player), sflags);
	}
	
	return PLUGIN_HANDLED;
 }
 public eam_login(id)
 {
	if( PlayerDeny[id] > MAX_LOGIN_ATTEMPTS ){
		console_print(id, "%L", id,"EAM_DENY");
		return PLUGIN_HANDLED;
	}

	new arg[32];
	read_argv(1,arg,31);

	new config_file[128], Right[124];
	get_configsdir(config_file,127);
	format(config_file, 127, "%s/%L.ini",config_file, 0, "EAM_USERS");

	if(!file_exists(config_file)) {
		log_amx("%L", 0,"EAM_ERROR_USERS", 0,"EAM_USERS");
		formatex(Right, 123, "//%L", 0,"EAM_INI_SETUP");
		write_file(config_file, Right, -1);
		formatex(Right, 123, "//%L", 0,"EAM_INI_SETUP2");
		write_file(config_file, Right, -1);

		if( id ){
			console_print(id, "%L", id,"EAM_LOGIN_FAL", arg);
			PlayerDeny[id]++;
		}

		return PLUGIN_HANDLED;
	}

	//if the file does exist, then we don't want to try to login
	if( !id || AC_TYPE == AC_AMXX)
		return PLUGIN_HANDLED;

	new steamid[35];
	new Left[32], len;
	new line = 0;
	new succes = 0;

	while((line = read_file(config_file , line , Right , 123 , len) ) != 0 )
	{
		while( equali(Right, " ", 1 ) )
			copy( Right, 123, Right[1]);

		if(equali(Right, "//", 2) || equali(Right, ";", 1))
			continue;

		strbrkqt(Right, Left, 31, Right, 123);
		remove_quotes(Left);

		if( Left[0]=='+' ){
			copy( Left, 31, Left[1]);
			get_user_authid(id, steamid, 34);

			if( equal( Left, steamid ) ){
				strbrkqt(Right, Left, 31, Right, 123);
				PlayerEAM[id] |= read_flags(Left);
			}
		}
		else if( equal(Left, arg) ){
			strbrkqt(Right, Left, 31, Right, 123);
			remove_quotes(Left);
			PlayerEAM[id] |= read_flags(Left);
			new tot_flags[26];
			get_flags(PlayerEAM[id], tot_flags, 25);
			console_print(id, "%L", id,"EAM_LOGIN_SUC", tot_flags);
			succes = 1;
			break;
		}
	}

	if(!succes && id){
		console_print(id, "%L", id,"EAM_LOGIN_FAL", arg);
		PlayerDeny[id]++;
	}

	return PLUGIN_HANDLED;
 }

 display_EAM_cats(id, pos)
 {
	if (pos < 1)
		return;

	if ( last_category_registered == 1 ){
		display_EAM_commands(id, PlayerPos[id] = 1);
		return;
	}

	new menuBody[512];
	new keys = MENU_KEY_0;

	new b = 0;
	new start = (pos-1) * 7 + 1;

	PlayerArg[id] = 0;

	if (start >= last_category_registered || !start)
		start = pos = PlayerPos[id] = 1;

	new len = formatex(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "EAM_NAME", pos, (last_category_registered / 7 + ((last_category_registered % 7) ? 1 : 0)));

	//add an all command
	b++;
	keys |= MENU_KEY_1;
	len += formatex(menuBody[len], 511-len, "%d. %L^n", b, id, "EAM_ALL");

	new end = start + 7;

	if (end > last_category_registered)
		end = last_category_registered;

	for (new a = start; a < end; ++a)
	{
		if(CATEGORY_ACCESS[a] && !eam_access(id, CATEGORY_ACCESS[a]))
		{
			++b;
			if (g_coloredMenus)
				len += formatex(menuBody[len], 511-len, "\d%d. %s^n\w", b, CATEGORY_NAME[a]);
			else
				len += formatex(menuBody[len], 511-len, "#. %s^n", CATEGORY_NAME[a]);
		} else {
			keys |= (1<<b);
			len += formatex(menuBody[len], 511-len, "%d. %s^n", ++b, CATEGORY_NAME[a] );
		}
	}

	if (end != last_category_registered)
	{
		formatex(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos > 1 ? "BACK" : "EXIT");
		keys |= MENU_KEY_9;
	}
	else
		formatex(menuBody[len], 511-len, "^n0. %L", id, pos > 1 ? "BACK" : "EXIT");

	show_menu(id, keys, menuBody, -1, "EAM - Category");
 }
 public actionCategory(id, key)
 {
	key++;
	if(key==10)
		key = 0;

	switch (key)
	{
		case 9: display_EAM_cats(id, ++PlayerPos[id]);
		case 0: display_EAM_cats(id, --PlayerPos[id]);
		default:
		{
			PlayerCat[id] = (PlayerPos[id]-1) * 7 + key - 1;	//subtract one because of the all category

			display_EAM_commands(id, PlayerPos[id] = 1);
		}
	}
	
	return PLUGIN_HANDLED;
 }
 
 display_EAM_commands(id, pos)
 {
	if (pos < 1){
		if(last_command_registered > 1)
			display_EAM_cats(id, PlayerPos[id] = 1);
		return;
	}

	new menuBody[512];
	new keys = MENU_KEY_0;

	if ( last_command_registered == 1 ){
		formatex(menuBody, 511, g_coloredMenus ? "\y%L^n^n\w%L^n^n0. %L" : "%L^n^n%L^n^n0. %L", id, "EAM_NAME", id, "EAM_NO_COMMANDS", id, "EXIT");
		show_menu(id, keys, menuBody, -1, "EAM - Commands");
		return;
	}

	new b = 0;
	new start = (pos-1) * 7 + 1;

	PlayerArg[id] = 0;

	new commands[MAX_COMMANDS], cnum;
	eam_get_commands(commands, cnum, PlayerCat[id]);

	if (start >= cnum || !start)
		start = pos = PlayerPos[id] = 1;

	new len = formatex(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "EAM_NAME", pos, (cnum / 7 + ((cnum % 7) ? 1 : 0)));
	new end = start + 7;
	new tempcommand;

	if (end > cnum)
		end = cnum;

	for (new a = start-1; a < end; ++a)
	{
		tempcommand = commands[a];
		if(COMMAND_ACCESS[tempcommand] && !eam_access(id, COMMAND_ACCESS[tempcommand]))
		{
			++b;
			if (g_coloredMenus)
				len += formatex(menuBody[len], 511-len, "\d%d. %s^n\w", b, COMMAND_NAME[tempcommand]);
			else
				len += formatex(menuBody[len], 511-len, "#. %s^n", COMMAND_NAME[tempcommand]);
		} else {
			keys |= (1<<b);
			if(COMMAND_COMMENT[tempcommand][0])
				len += formatex(menuBody[len], 511-len, "%d. %s - %s^n" , ++b, COMMAND_NAME[tempcommand], COMMAND_COMMENT[tempcommand] );
			else
				len += formatex(menuBody[len], 511-len, "%d. %s^n", ++b, COMMAND_NAME[tempcommand]);
		}
	}

	if (end != cnum)
	{
		formatex(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos > 1 ? "BACK" : ( cnum != 1 ? "EAM_BACK_CATS" : "EXIT" ) );
		keys |= MENU_KEY_9;
	}
	else
		formatex(menuBody[len], 511-len, "^n0. %L", id, pos > 1 ? "BACK" : ( cnum != 1 ? "EAM_BACK_CATS" : "EXIT" ) );

	show_menu(id, keys, menuBody, -1, "EAM - Commands");
 }

 public actionCommand(id, key)
 {
	key++;
	if(key==10)
		key = 0;

	switch (key)
	{
		case 9: display_EAM_commands(id, ++PlayerPos[id]);
		case 0: display_EAM_commands(id, --PlayerPos[id]);
		default:
		{
			//with categories
			new commands[MAX_COMMANDS], cnum;
			eam_get_commands(commands, cnum, PlayerCat[id]);
			new command = commands[ (PlayerPos[id]-1) * 7 + key - 1];

			PlayerArgs[id][0] = float(command);
			PlayerArg[id]++;

			if(get_argument_type( command, PlayerArg[id]))
				display_EAM_args(id, PlayerPos[id] = 1);
			else
				display_EAM_args(id, PlayerPos[id] = 1, true);
		}
	}
	
	return PLUGIN_HANDLED;
 }
 display_EAM_args(id, pos, bool:remove_after_display=false)
 {
	if (pos < 1){
		PlayerArg[id]--;
		if(PlayerArg[id] > 0)
			display_EAM_args(id, PlayerPos[id] = 1);
		else
			display_EAM_commands(id, PlayerPos[id] = 1);
		return;
	}

	new menuBody[512];
	new b = 0;
	new start = (pos-1) * 7 + 1;
	new end;
	new keys = MENU_KEY_0|MENU_KEY_8;
	new name[32];
	new command = floatround(PlayerArgs[id][0]);
	new arg_type = get_argument_type( command, PlayerArg[id]);

	if( !remove_after_display && (arg_type==RANGE || arg_type==F_RANGE ) ){
		remove_after_display = true;
		PlayerArgs[id][PlayerArg[id]] = lower_command_range(command, PlayerArg[id]);
	}

	if(remove_after_display)
		PlayerArg[id]++;

	new len = formatex(menuBody, 511, g_coloredMenus ? "\y%L^n\w^n" : "%L^n^n", id, "EAM_NAME");

	new total_command[128];
	build_command(id, total_command, 127);
	len += copy(menuBody[len], 511-len, total_command);

	for(new q = PlayerArg[id]; q <= MAX_ARGUMENTS; q++){
		if(get_argument_type( command, q ) )
			len += copy(menuBody[len], 511-len, "__ ");
		else
			break;
	}

	if(remove_after_display)
		PlayerArg[id]--;

	len += copy(menuBody[len], 511-len, "^n^n");

	switch(arg_type)
	{
		case OPTIONS:{
			if (start >= last_command_registered || !start)
				start = pos = PlayerPos[id] = 1;

			end = start + 6;

			if (end > MAX_OPTIONS)
				end = MAX_OPTIONS;

			new option[OPTION_NAME_LENGTH], option_num;
			for(option_num = start; option_num < end; option_num++){
				if(command_option(command, PlayerArg[id], option_num, option, OPTION_NAME_LENGTH-1)){
					keys |= (1<<b);
					len += formatex(menuBody[len], 511-len, "%d. %s^n",++b, option);
				}
				else{
					end = PlayerNum[id];
					break;
				}
			}
		}
		case TEAM:{
			new teams_added;
			new player[MAX_PLAYERS], in_team;

			b++;
			end = PlayerNum[id];	//so we don't see the more option

			PlayerPlayers[id][0] = -999;
			keys |= MENU_KEY_1;
			len += formatex(menuBody[len], 511-len, "1. %L^n", id, "EAM_ALL");

			for(teams_added = 1; teams_added <= MAX_TEAMS; teams_added++){
				eam_get_players(player, in_team, "e", teams_added);

				if(in_team){

					get_user_team(player[0], name, 31);
					len += formatex(menuBody[len], 511-len, "%d. %s^n",++b, name);

					keys |= (1 << teams_added);

					PlayerPlayers[id][teams_added] = teams_added * -100;
				}
			}
		}
		case PLAYER,PLAYER_OR_TEAM,OPT_OR_PLYR:{
			new i;
			if(arg_type==PLAYER){
				eam_get_players(PlayerPlayers[id], PlayerNum[id]);
			}

			if (start >= PlayerNum[id] || !start)
				start = pos = PlayerPos[id] = 1;
			end = start + 6;

			if(arg_type==PLAYER_OR_TEAM){

				new teams_added = 1;
				new player[MAX_PLAYERS], in_team;

				if(pos==1){
					b++;
					PlayerPlayers[id][0] = -999;
					keys |= MENU_KEY_1;
					len += formatex(menuBody[len], 511-len, "1. %L^n", id, "EAM_ALL");
				}

				while( teams_added <= MAX_TEAMS ){
					eam_get_players(player, in_team, "e", teams_added);

					if(in_team){

						if(pos==1){
							get_user_team(player[0], name, 31);
							len += formatex(menuBody[len], 511-len, "%d. %s^n",++b, name);

							keys |= (1 << teams_added);
						}

						PlayerPlayers[id][teams_added] = teams_added * -100;

						teams_added++;
					}
				}

				eam_get_players(PlayerPlayers[id], PlayerNum[id], _, _, teams_added);
				if(pos==1){
					start += teams_added;
				}
			}
			else if(arg_type==OPT_OR_PLYR){

				new option[OPTION_NAME_LENGTH], option_num;
				for(option_num = start; option_num < end; option_num++){

					if(pos==1 && command_option(command, PlayerArg[id], option_num, option, OPTION_NAME_LENGTH-1)){

						keys |= (1 << b);
						len += formatex(menuBody[len], 511-len, "%d. %s^n",++b, option);

						PlayerPlayers[id][option_num] = option_num * -1;
					}
					else
						break;
				}

				eam_get_players(PlayerPlayers[id], PlayerNum[id], _, _, option_num);
				if(pos==1){
					start += option_num;
				}
			}

			if (end > PlayerNum[id])
				end = PlayerNum[id];

			for (new a = start-1; a < end; ++a)
			{
				i = PlayerPlayers[id][a];
				get_user_name(i, name, 31);

				keys |= (1<<b);

				len += formatex(menuBody[len], 511-len, "%d. %s^n", ++b, name);
			}
		}
		case INPUT:{
			new comment[COMMENT_LENGTH];
			input_comment(command, PlayerArg[id], comment, COMMENT_LENGTH-1);
			remove_quotes(comment);
			len += formatex(menuBody[len], 511-len, "%s^n", comment);
			end = PlayerNum[id];
		}
		case RANGE:{
			new Float:lower_range = lower_command_range(command, PlayerArg[id]);
			new Float:upper_range = upper_command_range(command, PlayerArg[id]);

			if( PlayerArgs[id][ PlayerArg[id] ] < lower_range)
				PlayerArgs[id][ PlayerArg[id] ] = lower_range;

			if( PlayerArgs[id][PlayerArg[id]] + (1.0*PlayerRange[id]) <= upper_range ){
				keys |= MENU_KEY_1;
				len += formatex(menuBody[len], 511-len, "1. +%d^n",floatround(PlayerRange[id]));
			}
			else{
				if (g_coloredMenus)
					len += formatex(menuBody[len], 511-len, "\d1. +%d^n\w",floatround(PlayerRange[id]));
				else
					len += formatex(menuBody[len], 511-len, "#. +%d^n",floatround(PlayerRange[id]));
			}
			if( PlayerArgs[id][PlayerArg[id]] - (1.0*PlayerRange[id]) >= lower_range ){
				keys |= MENU_KEY_2;
				len += formatex(menuBody[len], 511-len, "2. -%d^n",floatround(PlayerRange[id]));
			}
			else{
				if (g_coloredMenus)
					len += formatex(menuBody[len], 511-len, "\d2. -%d^n\w",floatround(PlayerRange[id]));
				else
					len += formatex(menuBody[len], 511-len, "#. -%d^n",floatround(PlayerRange[id]));
			}
			if( PlayerArgs[id][PlayerArg[id]] + (5.0*PlayerRange[id]) <= upper_range ){
				keys |= MENU_KEY_3;
				len += formatex(menuBody[len], 511-len, "3. +%d^n",floatround(5*PlayerRange[id]));
			}
			else{
				if (g_coloredMenus)
					len += formatex(menuBody[len], 511-len, "\d3. +%d^n\w",floatround(5*PlayerRange[id]));
				else
					len += formatex(menuBody[len], 511-len, "#. +%d^n",floatround(5*PlayerRange[id]));
			}
			if( PlayerArgs[id][PlayerArg[id]] - (5.0*PlayerRange[id]) >= lower_range ){
				keys |= MENU_KEY_4;
				len += formatex(menuBody[len], 511-len, "4. -%d^n",floatround(5*PlayerRange[id]));
			}
			else{
				if (g_coloredMenus)
					len += formatex(menuBody[len], 511-len, "\d4. -%d^n\w",floatround(5*PlayerRange[id]));
				else
					len += formatex(menuBody[len], 511-len, "#. -%d^n",floatround(5*PlayerRange[id]));
			}

			keys |= MENU_KEY_5;
			len += copy(menuBody[len], 511-len, "5. x10^n");
			keys |= MENU_KEY_6;
			len += copy(menuBody[len], 511-len, "6. /10^n");

			end = PlayerNum[id];
		}
		case F_RANGE:{
			new Float:lower_range = lower_command_range(command, PlayerArg[id]);
			new Float:upper_range = upper_command_range(command, PlayerArg[id]);

			if( PlayerArgs[id][ PlayerArg[id] ] < lower_range)
				PlayerArgs[id][ PlayerArg[id] ] = lower_range;

			if( PlayerArgs[id][PlayerArg[id]] + (1.0*PlayerRange[id]) <= upper_range ){
				keys |= MENU_KEY_1;
				len += formatex(menuBody[len], 511-len, "1. +%0.01f^n",PlayerRange[id]);
			}
			else{
				if (g_coloredMenus)
					len += formatex(menuBody[len], 511-len, "\d1. +%0.01f^n\w",PlayerRange[id]);
				else
					len += formatex(menuBody[len], 511-len, "#. +%0.01f^n",PlayerRange[id]);
			}
			if( PlayerArgs[id][PlayerArg[id]] - (1.0*PlayerRange[id]) >= lower_range ){
				keys |= MENU_KEY_2;
				len += formatex(menuBody[len], 511-len, "2. -%0.01f^n",PlayerRange[id]);
			}
			else{
				if (g_coloredMenus)
					len += formatex(menuBody[len], 511-len, "\d2. -%0.01f^n\w",PlayerRange[id]);
				else
					len += formatex(menuBody[len], 511-len, "#. -%0.01f^n",PlayerRange[id]);
			}
			if( PlayerArgs[id][PlayerArg[id]] + (5.0*PlayerRange[id]) <= upper_range ){
				keys |= MENU_KEY_3;
				len += formatex(menuBody[len], 511-len, "3. +%0.01f^n",5.0*PlayerRange[id]);
			}
			else{
				if (g_coloredMenus)
					len += formatex(menuBody[len], 511-len, "\d3. +%0.01f^n\w",5.0*PlayerRange[id]);
				else
					len += formatex(menuBody[len], 511-len, "#. +%0.01f^n",5.0*PlayerRange[id]);
			}
			if( PlayerArgs[id][PlayerArg[id]] - (5.0*PlayerRange[id]) >= lower_range ){
				keys |= MENU_KEY_4;
				len += formatex(menuBody[len], 511-len, "4. -%0.01f^n",5.0*PlayerRange[id]);
			}
			else{
				if (g_coloredMenus)
					len += formatex(menuBody[len], 511-len, "\d4. -%0.01f^n\w",5.0*PlayerRange[id]);
				else
					len += formatex(menuBody[len], 511-len, "#. -%0.01f^n",5.0*PlayerRange[id]);
			}

			keys |= MENU_KEY_5;
			len += copy(menuBody[len], 511-len, "5. x10^n");
			keys |= MENU_KEY_6;
			len += copy(menuBody[len], 511-len, "6. /10^n");

			end = PlayerNum[id];
		}
	}

	if( remove_after_display ){
		keys |= MENU_KEY_8;
		len += formatex(menuBody[len], 511-len, "^n8. %L^n", id, get_argument_type( command, PlayerArg[id]+1) ? "EAM_NEXT_ARG" : "EAM_EXEC_COMM" );
	}

	if (end != PlayerNum[id])
	{
		if(pos > 1)
			formatex(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, "BACK");
		else
			formatex(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, PlayerArg[id]==1 ? "EAM_BACK_COMM" : "EAM_PREV_ARG");
		keys |= MENU_KEY_9;
	}
	else if(pos > 1)
		formatex(menuBody[len], 511-len, "^n0. %L", id, "BACK");
	else
		formatex(menuBody[len], 511-len, "^n0. %L", id, PlayerArg[id]==1 ? "EAM_BACK_COMM" : "EAM_PREV_ARG");

	show_menu(id, keys, menuBody, -1, "EAM - Argument");
 }
 public actionArgument(id, key)
 {
	new command = floatround(PlayerArgs[id][0]);
	key++;
	if(key==10)
		key = 0;

	switch (key)
	{
		case 8:
		{
			PlayerArg[id]++;

			//does it still need more arguments?
			if( get_argument_type( command, PlayerArg[id]) ){
				display_EAM_args(id, PlayerPos[id] = 1);
				return PLUGIN_HANDLED;
			}

			new total_command[128];
			build_command(id, total_command, 127);

			switch( COMMAND_EXEC[command] )
			{
				case EXEC_PLAYER:	client_cmd(id, "%s", total_command );
				case EXEC_SERVER:	server_cmd( "%s", total_command );
				case EXEC_ALL: {
					eam_get_players(PlayerPlayers[0], PlayerNum[0]);
					for ( new i=0 ; i < PlayerNum[0] ; i++ )
						client_cmd(PlayerPlayers[0][i], "%s", total_command );
				}
			}
			display_EAM_args(id, --PlayerArg[id], true);
		}
		case 9: display_EAM_args(id, ++PlayerPos[id]);
		case 0: display_EAM_args(id, --PlayerPos[id]);
		default:
		{
			new arg_type = get_argument_type( command, PlayerArg[id]);
			switch(arg_type)
			{
				case OPTIONS:
					PlayerArgs[id][PlayerArg[id]] = float((PlayerPos[id]-1) * 7 + key) * -1;
				case PLAYER, PLAYER_OR_TEAM, TEAM:
					PlayerArgs[id][PlayerArg[id]] = float(PlayerPlayers[id][ (PlayerPos[id]-1) * 7 + key - 1]);
				case RANGE,F_RANGE:{
					switch(key)
					{
						case 1:		PlayerArgs[id][PlayerArg[id]] += PlayerRange[id];
						case 2:		PlayerArgs[id][PlayerArg[id]] -= PlayerRange[id];
						case 3:		PlayerArgs[id][PlayerArg[id]] += 5*PlayerRange[id];
						case 4:		PlayerArgs[id][PlayerArg[id]] -= 5*PlayerRange[id];
						case 5:		PlayerRange[id] *= 10;
						case 6:		PlayerRange[id] /= 10;
					}
					if( PlayerArgs[id][PlayerArg[id]] > upper_command_range(command, PlayerArg[id]) )
						PlayerArgs[id][PlayerArg[id]] = lower_command_range(command, PlayerArg[id]);
					else if( PlayerArgs[id][PlayerArg[id]] < lower_command_range(command, PlayerArg[id]) )
							 PlayerArgs[id][PlayerArg[id]] = upper_command_range(command, PlayerArg[id]);

					display_EAM_args(id, PlayerPos[id], true);
					return PLUGIN_HANDLED;
				}
			}

			//still needs more arguments
			if( get_argument_type( command, PlayerArg[id]+1) ){
				display_EAM_args(id, PlayerPos[id] = 1, true);
			}
			//selected last argument, but still need to select Execute
			else{
				display_EAM_args(id, PlayerPos[id] = 1, true);
			}
		}
	}
	
	return PLUGIN_HANDLED;
 }
 
 public HandleSay(id)
 {
	static command;
	command = floatround(PlayerArgs[id][0]);
	if( !command )
		return PLUGIN_CONTINUE;

	static arg_type;
	arg_type = get_argument_type( command, PlayerArg[id]);
	if( arg_type != INPUT && 
		arg_type != RANGE && 
		arg_type != F_RANGE )
		return PLUGIN_CONTINUE;

	static said[192];
	read_args(said,191);
	remove_quotes(said);

	switch( arg_type )
	{
		case RANGE, F_RANGE :{
			new Float:num_said = str_to_float(said);
			if( ( num_said || equal(said,"0") || equal(said,"0.0") )
			&&	( num_said < upper_command_range(command, PlayerArg[id])
			&&	  num_said > lower_command_range(command, PlayerArg[id])
			)){
				PlayerArgs[id][PlayerArg[id]] = num_said;
			}
			else return PLUGIN_CONTINUE;
		}
		case INPUT :{
			copy(PlayerInput[id][PlayerArg[id]-1], INPUT_LENGTH-1, said);
		}
		case PLAYER,PLAYER_OR_TEAM,OPT_OR_PLYR:{
			new player = cmd_target(id, said, 0);

			if (!player) return PLUGIN_CONTINUE;
			PlayerArgs[id][PlayerArg[id]] = float(player);
		}
	}

	display_EAM_args(id, PlayerPos[id] = 1, true);

	return PLUGIN_HANDLED;
 }

 build_command(id, total_command[], length)
 {
	new len, name[32], option[OPTION_NAME_LENGTH];
	new command = floatround(PlayerArgs[id][0]);
	len += formatex(total_command[len], length-len, "%s ",COMMAND_NAME[ command ] );
	for(new j = 0; j < PlayerArg[id]; j++){
		switch(get_argument_type( command, j ) )
		{
			case PLAYER,PLAYER_OR_TEAM,TEAM,OPT_OR_PLYR:{
				if(PlayerArgs[id][j] < 0 && get_argument_type( command, j ) == OPT_OR_PLYR){
					if(command_option(command, j, floatround(PlayerArgs[id][j] * -1), option, OPTION_NAME_LENGTH-1))
						len += formatex(total_command[len], length-len, "%s ", option);
					continue;
				}
				new player_type = get_player_type( command, j);
				if(PlayerArgs[id][j] < 0 || player_type == USERNAME ){
					eam_get_name(floatround(PlayerArgs[id][j]), name, 31);
					len += formatex(total_command[len], length-len, "^"%s^" ",name);
				}
				else if( player_type == USERID ){
					len += formatex(total_command[len], length-len, "#%d ", get_user_userid( floatround(PlayerArgs[id][j]) ) );
				}
				else if( player_type == AUTHID ){
					get_user_authid( floatround(PlayerArgs[id][j]), name, 31);
					len += formatex(total_command[len], length-len, "%s ",name);
				}
			}
			case RANGE: len += formatex(total_command[len], length-len, "%d ", floatround(PlayerArgs[id][j]) );
			case F_RANGE: len += formatex(total_command[len], length-len, "%.1f ", PlayerArgs[id][j]);
			case OPTIONS: {
				if(command_option(command, j, floatround(PlayerArgs[id][j] * -1), option, OPTION_NAME_LENGTH-1))
					len += formatex(total_command[len], length-len, "%s ", option);
			}
			case INPUT: {
				len += formatex(total_command[len], length-len, "%s ", PlayerInput[id][j-1]);
			}
		}
	}
 }

 /* Sets indexes of players.
 * Flags:
 * "a" - don't collect dead players.
 * "b" - don't collect alive players.
 * "c" - skip bots.
 * "d" - skip real players.
 * "e" - match with team number.
 * "f" - match with part of name.   //not used - leaving blank to match AMXX's get_players
 * "g" - ignore case sensitivity.   //not used - leaving blank to match AMXX's get_players
 * "h" - skip HLTV.
 * "i" - not equal to team number.
 * Example: Get all alive on team 2: poke_get_players(players,num,"ae",2) */
 stock eam_get_players(players[], &pnum, const flags[]="", team=-1, start_arg=0)
 {
	new i, total = start_arg, bitwise = read_flags(flags);
	for(i=1; i<=MAX_PLAYERS; i++)
	{
		if(is_user_connected(i))
		{
			if( is_user_alive(i) ? (bitwise & 2) : (bitwise & 1))
				continue;
			if( is_user_bot(i) ? (bitwise & 4) : (bitwise & 8))
				continue;
			if( (bitwise & 16) && team!=-1 && Team(i)!=team)
				continue;
			// & 32
			// & 64
			if( (bitwise & 128) && is_user_hltv(i))
				continue;
			if( (bitwise & 256) && team!=-1 && Team(i)==team)
				continue;
			players[total] = i;
			total++;
		}
	}
	pnum = total;

	return true;
 }

 stock Team(id)
 {
	if(!is_user_connected(id))
		return 0;

	new team;
	if( MOD == NS ){
		team = entity_get_int(id, EV_INT_team);
		if(team==2)
			return 2;
		else if(team==1)
			return 1;
		else
			return 3;
	}
	else if( MOD == CS ){
		team = _:cs_get_user_team(id);
		return team;
	}

	team = get_user_team(id);
	return team;
 }
 
 eam_get_name(const team_or_player, return_name[], const len)
 {
	if(team_or_player > 0){
		get_user_name( team_or_player, return_name, len );
		return true;
	}
	else{
		if(team_or_player == -999){
			copy(return_name, len, "@ALL");
			return true;
		}
		new team = team_or_player / -100;

		switch( MOD )
		{
			case CS:{
				if(team==1){
					copy(return_name, len,"@T");
					return true;
				}
				else if(team==2){
					copy(return_name, len,"@CT");
					return true;
				}
			}
			case DOD:{
				if(team==1){
					copy(return_name, len,"@ALLIED");
					return true;
				}
				else if(team==2){
					copy(return_name, len,"@AXIS");
					return true;
				}
			}
			case NS:{
				if(team==1){
					copy(return_name, len,"@MARINES");
					return true;
				}
				else if(team==2){
					copy(return_name, len,"@ALIENS");
					return true;
				}
			}
			case TFC:{
				if(team==1){
					copy(return_name, len,"@BLUE");
					return true;
				}
				else if(team==2){
					copy(return_name, len,"@RED");
					return true;
				}
				else if(team==3){
					copy(return_name, len,"@YELLOW");
					return true;
				}
				else if(team==4){
					copy(return_name, len,"@GREEN");
					return true;
				}
			}
			default:{
				formatex(return_name, len, "@%d",team);
				return true;
			}
		}
	}
	return false;
 }
 
 stock strbrkqt(const text[], Left[], leftLen, Right[], rightLen)
 {
	//Breaks text[] into two parts, Left[], and Right[]
	// Left[] will contain the first parameter (either quoted or non-quoted)
	// Right[] contain the rest of the string after Left[], not including the space
	new bool:in_quotes = false;
	new bool:done_flag = false;
	new i, left_pos = 0;

	for ( i = 0; i < strlen(text); i++) {

		if (equali(text[i], "^"", 1) && !done_flag) {
			if (in_quotes) {
				done_flag = true;
				in_quotes = false;
			}
			else in_quotes = true;
		}
		else if ( isspace(text[i]) && !in_quotes ) {
			if (left_pos > 0) {
				done_flag = true;
			}
		}
		else if (!done_flag && left_pos <= leftLen) {
			setc(Left[left_pos], 1, text[i]);
			left_pos++;
		}
		else if (done_flag) break;
	}

	Left[left_pos] = 0;
	copy(Right,rightLen,text[i]);

	return true;
 }
 
 stock eam_access(id, bitaccess)
 {
	#if AC_TYPE == AC_AMXX || AC_TYPE == AC_BOTH
	if(access(id, bitaccess))
		return true;
	#endif
	#if AC_TYPE == AC_EAM || AC_TYPE == AC_BOTH
	if(PlayerEAM[id]&bitaccess)
		return true;
	#endif
	return false;
 }
 
 stock eam_cmd_access(id,level,cid,num)
 {
	new has_access = 0;
	if ( id==(is_dedicated_server()?0:1) ) {
		has_access = 1;
	} else if ( eam_access(id, level) ) {
		has_access = 1;
	} else if (level == ADMIN_ALL) {
		has_access = 1;
	}

	if ( has_access==0 ) {
		#if defined AMXMOD_BCOMPAT
			console_print(id, SIMPLE_T("You have no access to that command."));
		#else
			console_print(id,"%L",id,"NO_ACC_COM");
		#endif
		return 0;
	}
	if (read_argc() < num) {
		new hcmd[32], hinfo[128], hflag;
		get_concmd(cid,hcmd,31,hflag,hinfo,127,level);
	#if defined AMXMOD_BCOMPAT
		console_print(id, SIMPLE_T("Usage:  %s %s"), hcmd, SIMPLE_T(hinfo));
	#else
		console_print(id,"%L:  %s %s",id,"USAGE",hcmd,hinfo);
	#endif
		return 0;
	}
	return 1;
 }
 

 
 