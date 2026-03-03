
 ///////////////////////////////////////////////////////////////////
 //   ______          __  __   _____                _             //
 //  |  ____|   /\   |  \/  | |  __ \              | |            //
 //  | |__     /  \  | \  / | | |__) |___  __ _  __| | ___ _ __   //
 //  |  __|   / /\ \ | |\/| | |  _  // _ \/ _` |/ _` |/ _ \ '__|  //
 //  | |____ / ____ \| |  | | | | \ \  __/ (_| | (_| |  __/ |     //
 //  |______/_/    \_\_|  |_| |_|  \_\___|\__,_|\__,_|\___|_|     //
 //																  //
 ///////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <eam>

#define PLUGIN	"EAM Reader"
#define VERSION "0.1"
#define AUTHOR "Emp`"

new config_file[128];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}
public eam_setup()
{
	get_configsdir(config_file,127);
	add(config_file, 127, "/eam.cfg");
	
	new file = fopen(config_file, "rt");
	
	if(!file){
		log_amx("**WARNING** EAM Config File not found, making default file");
		ResetConfig();
		return PLUGIN_CONTINUE;
	}
	
	new Data[124];
	new Left[62], Right[124];
	new Float:temp;			//used for temporarily finding the lower bound on ranges
	
	new category = 0;
	new command = 0;
	new argument = 0;
	new TYPE_PLAYER:user_type;
	
	while(!feof(file))
	{
		fgets(file, Data, 123);
		
		while( equali(Data, " ", 1 ) )
		copy( Data, 123, Data[1]);
		
		if(equali(Data,"//",2) || equali(Data,";",1))
		continue;
		
		switch(Data[0])
		{
			case '{':{
				//get rid of the first character
				copy( Data, 123, Data[1]);
				
				//fill Left with the first thing and Right with the rest
				strtok( Data, Left, 61, Right, 123, '}');
				
				category = eam_category_register(Left);
				command = 0;
			}
			case '[':{
				//get rid of the first character
				copy( Data, 123, Data[1]);
				
				//fill Left with the first thing and Right with the rest
				strtok( Data, Left, 61, Right, 123, ']');
				
				command = eam_command_register(Left);
				eam_command_category(command, category);
				argument = 0;
			}
			case '-':{
				//get rid of the first character
				copy( Data, 123, Data[1]);
				
				//fill Left with the first thing and Right with the rest
				argbreak( Data, Left, 61, Right, 123);
				
				if(equali(Left, "ACCESS")){
					argbreak( Right, Left, 61, Right, 123);
					if(equali(Left, "FLAG")){
						strbrkqt( Right, Left, 61, Right, 123);
						remove_quotes(Left);
						if(command)
						eam_command_access(command, FLAG, Left);
						else
						eam_category_access(command, FLAG, Left);
					}
					else if(equali(Left, "CVAR")){
						strbrkqt( Right, Left, 61, Right, 123);
						remove_quotes(Left);
						if(command)
						eam_command_access(command, FLAG, Left);
						else
						eam_category_access(command, FLAG, Left);
					}
				}
				else if(equali(Left, "COMMENT")){
					strbrkqt( Right, Left, 61, Right, 123);
					remove_quotes(Left);
					eam_command_comment(command, Left);
				}
				else if(equali(Left, "EXEC")){
					argbreak( Right, Left, 61, Right, 123);
					if(equali(Left, "SERVER")){
						eam_command_exec(command, EXEC_SERVER);
					}
					else if(equali(Left, "ALL")){
						eam_command_exec(command, EXEC_ALL);
					}
					else if(equali(Left, "PLAYER")){
						eam_command_exec(command, EXEC_PLAYER);
					}
				}
				else if(equali(Left, "ARG")){
					argument++;
					
					argbreak( Right, Left, 61, Right, 123);
					if(equali(Left, "PLAYER")){
						argbreak( Right, Left, 61, Right, 123);
						if(equali(Left, "USERID"))
						user_type = USERID;
						else if(equali(Left, "AUTHID"))
						user_type = AUTHID;
						else if(equali(Left, "USERNAME"))
						user_type = USERNAME;
						eam_command_arg(command, argument, PLAYER, user_type);
					}
					else if(equali(Left, "PLAYER_OR_TEAM")){
						argbreak( Right, Left, 61, Right, 123);
						if(equali(Left, "USERID"))
						user_type = USERID;
						else if(equali(Left, "AUTHID"))
						user_type = AUTHID;
						else if(equali(Left, "USERNAME"))
						user_type = USERNAME;
						eam_command_arg(command, argument, PLAYER_OR_TEAM, user_type);
					}
					else if(equali(Left, "TEAM")){
						eam_command_arg(command, argument, TEAM);
					}
					else if(equali(Left, "RANGE")){
						argbreak( Right, Left, 61, Right, 123);
						temp = str_to_float(Left)
						argbreak( Right, Left, 61, Right, 123);
						eam_command_arg(command, argument, RANGE, floatround(temp), str_to_num(Left));
					}
					else if(equali(Left, "F_RANGE")){
						argbreak( Right, Left, 61, Right, 123);
						temp = str_to_float(Left)
						argbreak( Right, Left, 61, Right, 123);
						eam_command_arg(command, argument, F_RANGE, temp, str_to_float(Left));
					}
					else if(equali(Left, "OPTIONS")){
						eam_command_arg(command, argument, OPTIONS, Right);
					}
					else if(equali(Left, "OPT_OR_PLYR")){
						argbreak( Right, Left, 61, Right, 123);
						if(equali(Left, "USERID"))
						user_type = USERID;
						else if(equali(Left, "AUTHID"))
						user_type = AUTHID;
						else if(equali(Left, "USERNAME"))
						user_type = USERNAME;
						eam_command_arg(command, argument, OPT_OR_PLYR, user_type, Right);
					}
					else if(equali(Left, "INPUT")){
						eam_command_arg(command, argument, INPUT, Right);
					}
				}
			}
		}
	}
	
	fclose(file);
	
	return PLUGIN_CONTINUE;
}
public ResetConfig()
{
	new file = fopen(config_file, "wt");
	
	fputs(file,	"^n");
	fputs(file,	"//To add a Category, {Name} followed by commands^n");
	fputs(file,	"//To add a Command, [Name] followed by properties^n");
	fputs(file,	"//To add a Property, -Name^n");
	fputs(file,	"^n");
	fputs(file,	"//Properties: COMMENT, ARG, ACCESS, EXEC^n");
	fputs(file,	"//COMMENT - must be followed by a comment^n");
	fputs(file,	"//ARG - must be followed by an Arg Type^n");
	fputs(file,	"//  Arg Types: PLAYER, PLAYER_OR_TEAM, TEAM, RANGE, F_RANGE, OPTIONS, OPT_OR_PLYR, INPUT^n");
	fputs(file,	"//    PLAYER and PLAYER_OR_TEAM - must be followed by a Player Type^n");
	fputs(file,	"//      Player Types: USERID, AUTHID, USERNAME^n");
	fputs(file,	"//    RANGE - must be followed by two numbers^n");
	fputs(file,	"//    TEAM - nothing else to add^n");
	fputs(file,	"//    F_RANGE - must be followed by two floats^n");
	fputs(file,	"//    OPTIONS - must be followed by options^n");
	fputs(file,	"//    OPT_OR_PLYR - must be followed by a Player Type and then options^n");
	fputs(file,	"//    INPUT - followed by a comment^n");
	fputs(file,	"//ACCESS - must be followed by an Access Type^n");
	fputs(file,	"//  Access Types: FLAG, CVAR^n");
	fputs(file,	"//EXEC - must be followed by an Exec Type^n");
	fputs(file,	"//  Exec Types: PLAYER, SERVER, ALL^n");
	fputs(file,	"^n");
	fputs(file,	"//Examples (remove // to enable)^n");
	fputs(file,	"^n");
	fputs(file,	"//{PODBOT}^n");
	fputs(file,	"//[pb add]^n");
	fputs(file,	"//-COMMENT ^"adds a bot^"^n");
	fputs(file,	"//-EXEC SERVER^n");
	fputs(file,	"//[pb remove]^n");
	fputs(file,	"//-COMMENT ^"removes a bot^"^n");
	fputs(file,	"//-EXEC SERVER^n");
	fputs(file,	"//[pb killbots]^n");
	fputs(file,	"//-COMMENT ^"kills all bots^"^n");
	fputs(file,	"//-EXEC SERVER^n");
	fputs(file,	"//[pb fillserver]^n");
	fputs(file,	"//-COMMENT ^"adds max bots^"^n");
	fputs(file,	"//-EXEC SERVER^n");
	fputs(file,	"//[pb removebots]^n");
	fputs(file,	"//-COMMENT ^"removes all bots^"^n");
	fputs(file,	"//-EXEC SERVER^n");
	fputs(file,	"^n");
	fputs(file,	"//{MONSTER}^n");
	fputs(file,	"//[monster snark]^n");
	fputs(file,	"//-COMMENT ^"spawns a snark^"^n");
	fputs(file,	"//-EXEC SERVER^n");
	fputs(file,	"//-ARG PLAYER USERNAME^n");
	fputs(file,	"//[monster]^n");
	fputs(file,	"//-COMMENT ^"spawns other^"^n");
	fputs(file,	"//-EXEC SERVER^n");
	fputs(file,	"//-ARG OPTIONS ^"zombie^" ^"headcrab^" ^"barney^"^n");
	fputs(file,	"//-ARG PLAYER USERNAME^n");
	fputs(file,	"//-ACCESS FLAG ^"c^"^n");
	
	fclose(file);	
}

 // Thank you SH mod
stock strbrkqt(const text[], Left[], leftLen, Right[], rightLen)
{
	//Breaks text[] into two parts, Left[], and Right[]
	// Left[] will contain the first parameter (either quoted or non-quoted)
	// Right[] contain the rest of the string after Left[], not including the space
	new bool:in_quotes = false
	new bool:done_flag = false
	new i, left_pos = 0
	
	for ( i = 0; i < strlen(text); i++) {
		
		if (equali(text[i], "^"", 1) && !done_flag) {
			if (in_quotes) {
				done_flag = true
				in_quotes = false
			}
			else in_quotes = true
		}
		else if ( isspace(text[i]) && !in_quotes ) {
			if (left_pos > 0) {
				done_flag = true
			}
		}
		else if (!done_flag && left_pos <= leftLen) {
			setc(Left[left_pos], 1, text[i])
			left_pos++
		}
		else if (done_flag) break
	}
	
	Left[left_pos] = 0
	copy(Right,rightLen,text[i])
	
	return true
}