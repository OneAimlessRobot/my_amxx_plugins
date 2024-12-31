



#define Struct enum


#define PLUGIN_NAME "Not crash counter"
#define VERSION "1.0"
#define AUTHOR "ThrashBrat"
#define CF_TASKID 5929129

#define MAX_LEVELS 150
#define PATHSIZE 128
#define BUFFSIZE 8192
#define CF_CFG_FILENAME "crash_funny.cfg"
#define CF_RESULT "crash_funny.ini"
new const g_CmdChat[]     = "/crash_funny"; 

#include <amxmodx>
#include <amxmisc>

new g_msgSayText
new p_count
new time_ads
new cf_cfg_folder[128],cf_cfg_file[128],cf_ini_file[128]
new non_crash_count

public plugin_init()
{
register_plugin( PLUGIN_NAME, VERSION, AUTHOR );
register_cvar( "cf_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY );

p_count= register_cvar( "cf_time_ads"       , "120" );

register_concmd("cf", "cf_cmd", ADMIN_ALL);
g_msgSayText = get_user_msgid( "SayText" );

register_clcmd( "say"       , "cmd_Say" );
register_clcmd( "say_team"  , "cmd_Say" );
setupConfig()
loadConfig()
loadCVARS()
}


loadCVARS(){

	time_ads=get_pcvar_num(p_count)

}
public level_gen()
{

loadConfig()
loadCVARS()
make_files()



}

ShowPrint( id, const sMsg[], { Float, Sql, Result, _ }:... )
{
static
//  - - - - - - - - -
    newMsg[191],
    message[191],
//      |
    tNewMsg;
//  - - - - - - - - -

tNewMsg = charsmax( newMsg );
vformat( newMsg, tNewMsg, sMsg, 3 );

replace_all( newMsg, tNewMsg, "!t", "^3" );
replace_all( newMsg, tNewMsg, "!g", "^4" );
replace_all( newMsg, tNewMsg, "!n", "^1" );

formatex( message, charsmax( message ), "^4[ERS]^1 %s", newMsg );

emessage_begin( MSG_ONE, g_msgSayText, _, id );
ewrite_byte( id );
ewrite_string( message );
emessage_end();
}
    
public cmd_Say( id )
{
static sMsg[64];
read_argv( 1, sMsg, charsmax( sMsg ) );

if( equali( sMsg, g_CmdChat ) )
{
    if( !get_pcvar_num( p_player_toggle ) )
    {
	ShowPrint( id, "%L", id, "ERS_CMD_DISABLED" );
	return PLUGIN_HANDLED;
    }
    ShowPrint( id, "%L", id, g_pHeardSound[id] ? "ERS_SOUND_ENABLED" : "ERS_SOUND_DISABLED" );

    return PLUGIN_HANDLED;
}

return PLUGIN_CONTINUE;
}

//----------------------------------------------------------------------------------------------
setupConfig()
{
	// Set Up Config Files
	get_configsdir(cf_cfg_folder, charsmax(cf_cfg_folder))
	add(cf_cfg_folder, charsmax(cf_cfg_folder), "/crash_funny", 20)

	// Attempt to create directory if it does not exist
	if ( !dir_exists(cf_cfg_folder) ) {
		mkdir(cf_cfg_folder)
	}

	formatex(cf_cfg_file, charsmax(cf_cfg_file), "%s/%s", cf_cfg_folder,CF_CFG_FILENAME)
}


//----------------------------------------------------------------------------------------------
loadConfig()
{
	//Load SH Config File
	if ( file_exists(cf_cfg_file) ) {
		
		log_amx("Loading crash_funny.cfg")

		server_cmd("exec %s", cf_cfg_file)

		//Force the server to flush the exec buffer
		server_exec()

		//Note: I do not believe this is an issue anymore disabling until known otherwise - vittu
		//Exec the config again due to issues with it not loading all the time
		//server_cmd("exec %s", gSHConfig)
	}
	else {
		log_amx("Could not find %s file", cf_cfg_file)
	}
}
public client_putinserver( id )
{
new Float:time = get_pcvar_float( p_count );

if( !time )
    return;

remove_task( id + CF_TASKID );
set_task( time, "show_ads", id + CF_TASKID, _, _, "b" );
}


public show_ads( taskid )
{
new id = taskid - CF_TASKID;
ShowPrint( id, "%L", id, "ERS_DISPLAY_ADS", g_CmdChat );
}


public client_disconnected( id )
{
g_pHeardSound[id] = true;
remove_task( id + CF_TASKID );
}
make_files(){

	formatex(cf_ini_file, charsmax(cf_ini_file), "%s/%s", cf_cfg_folder,CF_RESULT)

	new cfFile= fopen(cf_ini_file, "wt")
	if (!cfFile) {
		log_amx("Failed to create %s, please verify file/folder permissions",cf_ini_file)
		return
	}
	
	
	fclose(cfFile)
}
public plugin_precache(){


        register_dictionary( "crash_funny.txt" );

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
