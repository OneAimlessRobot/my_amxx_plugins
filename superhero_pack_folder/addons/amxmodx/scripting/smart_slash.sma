
 #include <amxmisc>
 #pragma semicolon 1

 #define MAX_PLAYERS 32

 #define COMMAND_NEW -1
 #define COMMAND_FIRST 0

 enum
 {
	COMM_CID,		//where in the command string is the command id
	COMM_CMD		//where in the command string the total command starts (must be last)
 }

 enum
 {
	REPL_NONE,		//didnt find anything to replace @'s
	REPL_USERID,	//replace @'s with userids
	REPL_AUTHID,	//replace @'s with authids
	REPL_NICK,		//replace @'s with nicknames
 }

 enum _:SAY_TYPES
 {
	SAY_NONE,		//Said nothing special
	SAY_SLASH,		//Said started with /
	SAY_QUESTION,	//Said started with ?
	SAY_AT,			//Said started with @
	SAY_BACKSLASH,	//Said started with backslash
 }

 new const SayChars[SAY_TYPES] =
 {
	'^0',
	'/',
	'?',
	'@',
	'\'
 };

 new Array:PreviousSlashes[MAX_PLAYERS+1];
 new Array:Repeaters[MAX_PLAYERS+1];

 new ss_showcmd;

 public plugin_init()
 {
	new const PLUGNAME[] =			"SmartSlash";
	new const AUTHOR[] =			"Emp`";
	new const VERSION[] =			"0.51";
	register_plugin(PLUGNAME, VERSION, AUTHOR);

	set_pcvar_string( register_cvar(PLUGNAME,VERSION,FCVAR_SERVER|FCVAR_SPONLY), VERSION );

	register_clcmd("say","CmdSay");

	for( new i; i<MAX_PLAYERS+1; i++ )
	{
		PreviousSlashes[i] = ArrayCreate(64, 1);
		Repeaters[i] = ArrayCreate(64, 1);
	}

	ss_showcmd = register_cvar("ss_showcmd", "1");

	//Repeaters only for cstrike
	if( cstrike_running() )
		register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
 }

 public client_disconnected(id)
 {
	//When someone leaves, make sure no one else see's their previous things
	ArrayClear( PreviousSlashes[id] );
	ArrayClear( Repeaters[id] );
 }

 public CmdSay(id)
 {
	new said[192];
	read_args(said,191);
	remove_quotes(said);
	return SayHandle( id, said );
 }

 SayHandle( id, said[192] )
 {
	new say_type = SAY_NONE;

	//Check for what type of say it was
	for( new i; i < SAY_TYPES; i++ )
	{
		if( said[0] == SayChars[i] )
		{
			say_type = i;
			break;
		}
	}

	//If nothing special was said
	if( say_type == SAY_NONE )
	{
		return PLUGIN_CONTINUE;
	}

	//Check if it was only a slash (to do previous slashes)
	if( said[1] == '^0' && say_type == SAY_SLASH )
	{
		//Get how many are in the array so we can iterate through them all
		new size = ArraySize(PreviousSlashes[id]);

		//If they don't have any previous commands, don't do anything
		if( !size )
		{
			return PLUGIN_CONTINUE;
		}

		//String for which number in the array it is
		new item_data[128];

		//Create a menu for previous slashes
		new menu = menu_create("/", "menu_handler");

		//Iterate through all previous slashes
		for( new i; i < size; i++ )
		{
			//get a previous slash
			ArrayGetString(PreviousSlashes[id], i, said, 63);

			//store the information we want to pass
			formatex( item_data, 127, "%d %d %s", said[COMM_CID], i, said[COMM_CMD] );

			//add it to the menu
			menu_additem(menu, said[COMM_CMD], item_data);
		}

		//Display the menu
		menu_display(id, menu);

		//Don't show the chat message, but let other plugins detect it
		return PLUGIN_HANDLED_MAIN;
	}

	//Backslashes (to turn off repeaters)
	if( say_type == SAY_BACKSLASH )
	{
		//Repeater menu
		if( said[1] == '^0' )
		{
			//Get how many are in the array so we can iterate through them all
			new size = ArraySize(Repeaters[id]);

			//If they don't have any repeater commands, don't do anything
			if( !size )
			{
				return PLUGIN_CONTINUE;
			}

			//Change it to a slash command
			said[0] = SayChars[SAY_SLASH];

			//String for which number in the array it is
			new item_data[128];

			//Create a menu for repeater
			new menu = menu_create("Repeaters", "menu_handler");

			//Iterate through all repeater
			for( new i; i < size; i++ )
			{
				//get a repeater
				ArrayGetString(Repeaters[id], i, said, 63);

				//store the information we want to pass
				formatex( item_data, 127, "REPEAT %s", said );

				//add it to the menu
				menu_additem(menu, said, item_data);
			}

			//Display the menu
			menu_display(id, menu);
		}
		else
		{
			//Change it to a slash command
			said[0] = SayChars[SAY_SLASH];

			//Get how many are in the array so we can iterate through them all
			new size = ArraySize( Repeaters[id] );

			//Save the entire command for later use
			if( size )
			{
				ArrayInsertStringBefore(Repeaters[id], 0, said);
			}
			else
			{
				ArrayPushString(Repeaters[id], said);
			}
		}

		//Don't show the chat message, but let other plugins detect it
		return PLUGIN_HANDLED_MAIN;
	}

	//For getting information about available commands
	new info[64], cmd[32], eflags, flags = get_user_flags(id);

	// HACK: ADMIN_ADMIN is never set as a user's actual flags, so those types of commands never show
	if (flags > 0 && !(flags & ADMIN_USER))
	{
		flags |= ADMIN_ADMIN;
	}

	new clcmdsnum = get_concmdsnum(flags, id);

	//If it was an @ say, keep track of the message
	if( say_type == SAY_AT )
	{
		new command[64];
		formatex( command, 63, "say %s", said );

		//Get the command id
		new cid;
		//iterate through all detected client commands
		for( new i; i <= clcmdsnum; i++ )
		{
			get_concmd( i, cmd, 31, eflags, info, 0, flags, id );
			if( equal( cmd, "say" ) )
			{
				cid = i;
				break;
			}
		}

		//Save it for later
		SaveCommand(id, cid, command);

		return PLUGIN_CONTINUE;
	}

	//get the first command, put the rest in said
	//note we skip the slash by using said[1]
	new said_cmd[32];
	argbreak( said[1], said_cmd, 31, said, 191 );

	new char_num, char_loc, cmdstr_len;

	//store information about the commands
	new Array:command_array = ArrayCreate(1, 1);

	//store the names of commands so we can check for duplicates
	new Trie:command_trie = TrieCreate();

	//iterate through all detected client commands
	for( new i; i <= clcmdsnum; i++ )
	{
		get_concmd( i, cmd, 31, eflags, info, 0, flags, id );

		//Check for "_", char_loc will be the location of "_", therefore char_loc+1 will check the partial string
		//Example command: "amx_kick"
		//Input: "/kick"

		//Check for "/", char_loc will be the location of "/", therefore char_loc+1 will check the partial string
		//Example command: "say /help"
		//Input: "/help"

		//Check for exact command, char_loc will be -1, therefore char_loc+1 will be 0, so it will check entire string
		//Example command: "amxmodmenu"
		//Input: "/amxmodmenu"

		//Assume it doesn't have a special character
		char_loc = -1;

		//Only check for special characters if it is not a question
		if( say_type == SAY_SLASH )
		{
			//Get the string length so we can iterate through all its characters without going over
			cmdstr_len = strlen( cmd );

			//Iterate through all the characters looking for any special character
			for( char_num = 0; char_num < cmdstr_len; char_num++ )
			{
				//Check for special characters
				switch( cmd[char_num] )
				{
					//These are the special characters
					case '_', '/', '.', ' ':
					{
						char_loc = char_num;
					}
					case '^0':
					{
						break;
					}
				}
			}
		}

		//Check against the current command
		//If it is a question, show any that contain the phrase said
		if( equal( said_cmd, cmd[ char_loc+1 ] ) || ( say_type == SAY_QUESTION && contain( cmd, said_cmd ) != -1 ) )
		{
			//Check to see the command has not been added before
			//This can happen if two seperate plugins register the same command (eg. amx_ban)
			if( !TrieKeyExists(command_trie, cmd) )
			{
				ArrayPushCell(command_array, i);
				TrieSetCell(command_trie, cmd, i);
				continue;
			}
		}
	}

	//Destroy the trie since we don't need it anymore
	TrieDestroy(command_trie);

	//How many matches were there
	new matches_num = ArraySize(command_array);

	//Add question since we want to make the menu if it was a question
	switch( matches_num + say_type - SAY_SLASH )
	{
		case 0:
		{
			//no matches found

			//destroy the array
			ArrayDestroy(command_array);

			//let them say what they said
			return PLUGIN_CONTINUE;
		}
		case 1:
		{
			//no matches found for the question
			if( say_type == SAY_QUESTION )
			{
				//destroy the array
				ArrayDestroy(command_array);

				//let them say what they said
				return PLUGIN_CONTINUE;
			}

			//which command is it?
			new cid = ArrayGetCell(command_array, 0);

			//only one match found, do that first match
			get_concmd( cid, cmd, 31, eflags, info, 63, flags, id );

			//Get the entire command
			new total_cmd[64];
			formatex(total_cmd, 63, "%s %s", cmd, said);

			//Execute the command
			ExecCommand( id, cid, total_cmd );

			//Save the entire command for later use
			SaveCommand(id, cid, total_cmd);
		}
		default:
		{
			//make the menu title
			formatex(cmd, 31, "%c%s %s", SayChars[say_type], said_cmd, said);
			new menu = menu_create(cmd, "menu_handler");

			new cid, item_name[64], item_data[128];

			//iterate through all matches and add them to the menu
			for( new i; i < matches_num; i++ )
			{
				cid = ArrayGetCell(command_array, i);

				//get the command name, if it is a question get the info too
				get_concmd( cid, cmd, 31, eflags, info, (say_type == SAY_QUESTION) ? 63 : 0, flags, id );

				//store the information we want to pass
				formatex( item_data, 127, "%d %d %s %s", cid, COMMAND_NEW, cmd, said );

				if( say_type == SAY_QUESTION )
				{
					formatex(item_name, 63, "%s %s", cmd, info);
					menu_additem(menu, item_name, item_data);
				}
				else
				{
					menu_additem(menu, cmd, item_data);
				}
			}

			//display the menu of choices
			menu_display(id, menu);
		}
	}

	//Destroy the array
	ArrayDestroy(command_array);

	//Don't show the chat message, but let other plugins detect it
	return PLUGIN_HANDLED_MAIN;
 }

 public menu_handler(id, menu, item)
 {
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new access, data[128], iName[1], callback;
	menu_item_getinfo(menu, item, access, data,127, iName,0, callback);

	//lets destroy it now since we dont need it anymore
	menu_destroy(menu);

	//If they are destroying a repeater
	if( equal( data, "REPEAT", 6 ) )
	{
		//Get how many are in the array so we can iterate through them all
		new size = ArraySize( Repeaters[id] );

		//Save the entire command for later use
		if( size )
		{
			//Check to make sure it is not something they have done before
			new temp_string[64];
			for( new i; i<size; i++ )
			{
				ArrayGetString(Repeaters[id], i, temp_string, 63);
				if( equal( temp_string, data[7] ) )	//check after the space
				{
					ArrayDeleteItem(Repeaters[id], i);
					client_print(id, print_chat, "Deleted Repeater: %s", data[7]);
					break;
				}
			}
		}
		return PLUGIN_HANDLED;
	}

	new szCid[10], szPrev[10];
	argbreak(data, szCid,9, data, 127);
	argbreak(data, szPrev,9, data, 127);

	new cid = str_to_num( szCid );
	new prev_num = str_to_num( szPrev );

	//Execute the command
	ExecCommand( id, cid, data );

	//If it's not at the front
	if( prev_num )
	{
		//If it is not new, delete the old position
		if( prev_num != COMMAND_NEW )
		{
			//Delete the old one
			ArrayDeleteItem(PreviousSlashes[id], prev_num);
		}

		SaveCommand(id, cid, data);
	}

	return PLUGIN_HANDLED;
 }

 SaveCommand(id, cid, command[])
 {
	new save_array[64];
	save_array[COMM_CID] = cid;
	copy(save_array[COMM_CMD], 63-COMM_CMD, command );

	//Get how many are in the array so we can iterate through them all
	new size = ArraySize( PreviousSlashes[id] );

	//Save the entire command for later use
	if( size )
	{
		//Check to make sure it is not something they have done before
		new temp_string[64], bool:deleted;
		for( new i; i<size; i++ )
		{
			ArrayGetString(PreviousSlashes[id], i, temp_string, 63);
			if( equal( temp_string, save_array ) )
			{
				ArrayDeleteItem(PreviousSlashes[id], i);
				deleted = true;
				break;
			}
		}

		if( size == 1 && deleted )
		{
			ArrayPushString(PreviousSlashes[id], save_array);
		}
		else
		{
			ArrayInsertStringBefore(PreviousSlashes[id], 0, save_array);
		}
	}
	else
	{
		ArrayPushString(PreviousSlashes[id], save_array);
	}
 }

 ExecCommand(id, cid, command[])
 {
	new info[64], cmd[32], eflags, flags = get_user_flags(id);

	// HACK: ADMIN_ADMIN is never set as a user's actual flags, so those types of commands never show
	if (flags > 0 && !(flags & ADMIN_USER))
	{
		flags |= ADMIN_ADMIN;
	}

	get_concmd( cid, cmd, 31, eflags, info, 63, flags, id );

	//Find which type to replace with
	new replace_type = REPL_NONE;
	if( contain( info, "userid" ) != -1 )		//best way
		replace_type = REPL_USERID;
	else if( contain( info, "authid" ) != -1 )	//second best way
		replace_type = REPL_AUTHID;
	else if( contain( info, "nick" ) != -1 )	//back up way
		replace_type = REPL_NICK;
	else if( contain( info, "name" ) != -1 )	//super back up way
		replace_type = REPL_NICK;
	else if( contain( info, "player" ) != -1 )	//super duper back up way
		replace_type = REPL_USERID;
	else if( contain( info, "target" ) != -1 )	//super duper duper back up way
		replace_type = REPL_USERID;
	else if( contain( info, "user" ) != -1 )	//super duper duper duper back up way
		replace_type = REPL_USERID;


	//If they put an @ in their command
	new command_at = contain( command, "@" );
	if( replace_type != REPL_NONE && command_at != -1 )
	{
		// @ was said, give them a menu of options
		if( command[command_at+1] == ' ' || command[command_at+1] == '^0' )
		{
			new temp_command[128], temp_replace[32], stuff_len;

			stuff_len = formatex( temp_command, 127, "%d %d ", cid, COMMAND_FIRST );

			copy( temp_command[stuff_len], 127-stuff_len, command );
			replace(temp_command[stuff_len+command_at], 127-stuff_len, "@", "\r@\y");
			new menu = menu_create( temp_command[stuff_len], "menu_handler" );

			//Add @ALL
			copy( temp_command[stuff_len], 127-stuff_len, command );
			replace(temp_command[stuff_len+command_at], 127, "@", "@ALL");
			menu_additem(menu, "@ALL", temp_command);

			//store the names of teams so we can check for duplicates
			new Trie:team_trie = TrieCreate();

			//Iterate through all players and add their teams
			for( new i=1; i<=MAX_PLAYERS; i++ )
			{
				//Make sure the player is connected
				if( is_user_connected(i) )
				{
					//Avoid the UNASSIGNED team
					if( get_user_team(i, temp_replace[1], 30) )
					{
						//Make sure it hasn't been added yet
						if( !TrieKeyExists(team_trie, temp_replace[1]) )
						{
							copy( temp_command[stuff_len], 127-stuff_len, command );
							temp_replace[0] = '@';
							replace( temp_command[stuff_len+command_at], 127, "@", temp_replace);

							menu_additem(menu, temp_replace, temp_command);

							TrieSetCell(team_trie, temp_replace[1], 1);
						}
					}
				}
			}

			//No longer need the trie, get rid of it
			TrieDestroy(team_trie);

			for( new i=1; i<=MAX_PLAYERS; i++ )
			{
				if( is_user_connected(i) )
				{
					switch( replace_type )
					{
						case REPL_USERID:	formatex( temp_replace, 31, "#%d", get_user_userid(i) );
						case REPL_AUTHID:	get_user_authid(i, temp_replace, 31);
						case REPL_NICK:		get_user_name(i, temp_replace, 31);
					}
					copy( temp_command[stuff_len], 127-stuff_len, command );
					replace( temp_command[stuff_len+command_at], 127-stuff_len, "@", temp_replace);

					//We want to see player names in the menu
					if( replace_type != REPL_NICK )
						get_user_name(i, temp_replace, 31);

					menu_additem(menu, temp_replace, temp_command);
				}
			}

			//display the menu of choices
			menu_display(id, menu);

			return;
		}

		//If the command does not support @'s
		if( contain( info, "@" ) == -1 )
		{
			//If trying for all players
			if( equali( command[command_at+1], "ALL", 3 ) )
			{
				for( new i=1; i<=MAX_PLAYERS; i++ )
				{
					if( is_user_connected(i) )
					{
						DoCmd(id, command[command_at], replace_type, i, command);
					}
				}
				new name[32], message[128];
				get_user_name(id, name, 31);
				formatex(message, 127, "%s used ^"%s^" through Smart Slash.", name, command);
				set_task(0.5, "delay_print", 0, message, 128);
				return;
			}
			//Detect for teams (eg. @A @C @CT @T @M @R etc.)
			else
			{
				new detected, teamname[5];
				for( new i=1; i<=MAX_PLAYERS; i++ )
				{
					if( is_user_connected(i) )
					{
						get_user_team(i, teamname, 4);
						if( equali( command[command_at+1], teamname, 1 ) )
						{
							DoCmd(id, command[command_at], replace_type, i, command);
							detected++;
						}
					}
				}
				if( detected )
				{
					new name[32], message[128];
					get_user_name(id, name, 31);
					formatex(message, 127, "%s used ^"%s^" through Smart Slash.", name, command);
					set_task(0.5, "delay_print", 0, message, 128);
					return;
				}
			}
		}
	}

	//Check for correct names
	if( contain( info, "nick" ) != -1 || contain( info, "name" ) != -1 || contain( info, "player" ) != -1 )
	{
		//Go through each argument
		new left[32], arg_num, command_left[32], command_right[64], i, player;
		while( contain( info, ">" ) != -1 )
		{
			strtok(info, left, 31, info, 63, '>');
			arg_num++;
			if( contain( left, "nick" ) != -1 || contain( left, "name" ) != -1 || contain( left, "player" ) != -1 )
			{
				//Get a temp copy of the command
				copy( command_right, 63, command );

				//Get the argument they put for the nick
				for( i=0; i <= arg_num; i++ )
				{
					argbreak(command_right, command_left, 31, command_right, 63);
				}

				//Get the first player with the name
				player = find_player("bl",command_left);

				//If it can find no players or two different players
				if( !player || player != find_player("blj",command_left) )
				{
					new menu = -1;
					new temp_replace[32], temp_command[128], stuff_len;

					stuff_len = formatex( temp_command, 127, "%d %d ", cid, COMMAND_FIRST );
					copy( temp_command[stuff_len], 127-stuff_len, command );

					//Get the first space in the command
					//We need this so we dont replace names into the command name
					//For example if they do /slap a
					//We want the second a (after the space) to be replaced
					new space_loc = contain( temp_command[stuff_len], " " );

					new clean_len, clean_left[32], clean_name[32];
					clean_len = CleanString( command_left, clean_left, 31 );

					for( i=1; i<=MAX_PLAYERS; i++ )
					{
						if( is_user_connected(i) )
						{
							//Get the name of the player and clean it
							get_user_name(i, temp_replace, 31);
							CleanString( temp_replace, clean_name, 31 );

							//Now check if its close to what they had
							if( !clean_len || containi(clean_name, clean_left) != -1 )
							{
								switch( replace_type )
								{
									case REPL_USERID:	formatex( temp_replace, 31, "#%d", get_user_userid(i) );
									case REPL_AUTHID:	get_user_authid(i, temp_replace, 31);
									case REPL_NICK:		{} //do nothing because temp_replace is already the nick
								}
								copy( temp_command[stuff_len], 127-stuff_len, command );
								replace(temp_command[stuff_len+space_loc], 127-stuff_len, command_left, temp_replace);

								//We want to see player names in the menu
								if( replace_type != REPL_NICK )
									get_user_name(i, temp_replace, 31);

								if( menu == -1 )
									menu = menu_create( command, "menu_handler" );

								menu_additem(menu, temp_replace, temp_command);
							}
						}
					}

					//If the menu was ever created
					if( menu != -1 )
					{
						//display the menu of choices
						menu_display(id, menu);

						return;
					}
				}
			}
		}
	}

	//The command does not have @ or the command supports @
	DoCmd(id, "", REPL_NONE, 0, command);
 }
 
 public delay_print( message[] )
	client_print(0, print_chat, message);
 
 DoCmd(id, replace_string[], replace_type, player, command[])
 {
	new temp_command[128];
	copy(temp_command, 127, command);

	if( replace_type != REPL_NONE && player )
	{
		new temp_replace[32];

		switch( replace_type )
		{
			case REPL_USERID:	formatex( temp_replace, 31, "#%d", get_user_userid(player) );
			case REPL_AUTHID:	get_user_authid(player, temp_replace, 31);
			case REPL_NICK:		get_user_name(player, temp_replace, 31);
		}

		//If what we are replacing has a space after it, only replace up to the space
		new replace_full[128], space_loc;
		copy(replace_full, 127, replace_string);
		space_loc = contain( replace_full, " " );
		if( space_loc != -1 )
		{
			replace_full[space_loc] = '^0';
		}

		replace(temp_command, 127, replace_full, temp_replace);
	}

	//let them know the command they smart slashed (if it wasn't replacing anything)
	if( replace_type == REPL_NONE && get_pcvar_num( ss_showcmd ) )
		client_print( id, print_center, temp_command );

	//engclient_cmd would be better here, however, it only works for commands from the game (doesnt work for commands from AMXX)
	client_cmd( id, temp_command );
 }

 CleanString( const string[], output[], len )
 {
	new PosIn, PosOut;
	while( PosOut < len )
	{
		switch( string[PosIn] )
		{
			//End of string
			case '^0':
			{
				output[PosOut] = '^0';
				break;
			}

			//Skip spaces and underscores
			case ' ', '_':
			{
				PosIn++;
				continue;
			}

			//Advanced characters (take more than one character to represent another character)
			case '|':
			{
				if( string[PosIn+1] == '<' )
					output[PosOut] = 'k';
				else if( string[PosIn+1] == '>' )
					output[PosOut] = 'p';
				else if( string[PosIn+1] == ')' )
					output[PosOut] = 'd';
				else if( string[PosIn+1] == '2' )
					output[PosOut] = 'r';
				else if( string[PosIn+1] == '3' )
					output[PosOut] = 'b';
				else
					output[PosOut] = 'l';
			}
			case '(':
			{
				if( string[PosIn+1] == ')' )
					output[PosOut] = 'o';
				else
					output[PosOut] = 'c';
			}
			case '[':
			{
				if( string[PosIn+1] == ']' )
					output[PosOut] = 'o';
				else
					output[PosOut] = 'c';
			}
			case '{':
			{
				if( string[PosIn+1] == '}' )
					output[PosOut] = 'o';
				else
					output[PosOut] = 'c';
			}
			case '\':
			{
				if( string[PosIn+1] == '/' )
					output[PosOut] = 'v';
				else
					output[PosOut] = 'l';
			}

			//Similar characters
			case 'A', '@':
				output[PosOut] = 'a';
			case 'B', '8':
				output[PosOut] = 'b';
			case 'C', '<':
				output[PosOut] = 'c';
			case 'D':
				output[PosOut] = 'd';
			case 'E', '3':
				output[PosOut] = 'e';
			case 'F':
				output[PosOut] = 'f';
			case 'G':
				output[PosOut] = 'g';
			case 'H':
				output[PosOut] = 'h';
			case 'I', '!':
				output[PosOut] = 'i';
			case 'J':
				output[PosOut] = 'j';
			case 'K':
				output[PosOut] = 'k';
			case 'L', '1':
				output[PosOut] = 'l';
			case 'M':
				output[PosOut] = 'm';
			case 'N':
				output[PosOut] = 'n';
			case 'O', '0':
				output[PosOut] = 'o';
			case 'P':
				output[PosOut] = 'p';
			case 'Q':
				output[PosOut] = 'q';
			case 'R':
				output[PosOut] = 'r';
			case 'S', '$', '5':
				output[PosOut] = 's';
			case 'T', '7', '+':
				output[PosOut] = 't';
			case 'U':
				output[PosOut] = 'u';
			case 'V':
				output[PosOut] = 'v';
			case 'W':
				output[PosOut] = 'w';
			case 'X':
				output[PosOut] = 'x';
			case 'Y':
				output[PosOut] = 'y';
			case 'Z':
				output[PosOut] = 'z';

			//Other Characters should just be copied
			default:
				output[PosOut] = string[PosIn];
		}
		PosIn++;
		PosOut++;
	}
	return PosOut;
 }

 public event_new_round()
 {
	new i, size, command[192];
	for( new id; id<=MAX_PLAYERS; id++ )
	{
		if( is_user_connected(id) )
		{
			size = ArraySize( Repeaters[id] );
			for( i=0; i < size; i++ )
			{
				ArrayGetString(Repeaters[id], i, command, 191);
				SayHandle( id, command );
			}
		}
	}
 }