#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../../include/sqlx.inc"
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "superheromod_configs_aux/superheromod_configs_header.inc"



#define PLUGIN "Superhero config_funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

/*
//these work

sh_get_player_save_key_on_db(id,player_key_from_id)
        
client_cmd(id,"clearpowers")
    


 */
//----------------------------------------------------------------------------------------------
public plugin_init()
{
    // Plugin Info
    register_plugin(PLUGIN, VERSION, AUTHOR)

    server_print("Superhero configs manager not yet implemented. But loading!")
    register_event("ResetHUD","newRound","b")
    initialize_settings()
    setupConfig()
    loadConfig()
    loadCVARS()
    initialize_config_engine()



}
public plugin_natives(){

    register_native("fetch_player_config", "_fetch_player_config",0)

}

public newRound(id){

	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}
	if(!is_user_bot(id)){
        
    }
	return PLUGIN_CONTINUE


}
public bool:_fetch_player_config(iPlugin,iParams){

    new player_id= get_param(1)
    new config_id= get_param(2)

    new player_key_from_id[MAX_PLAYER_SAVE_KEY_LENGTH]
    sh_get_player_save_key_on_db(player_id,player_key_from_id)
    server_print("This is a dummy function, for now.^nConfig utility not yet implemented!^nDummy parameters received:^nplayer_id= %d^nconfig_id: %d^nTheir save key is: %s^n",
                        player_id,
                        config_id,
                        player_key_from_id)

    
    return true


}
loadCVARS(){

    assign_setting_values()



}
//----------------------------------------------------------------------------------------------
setupConfig()
{
    // Set Up Config Files
    get_configsdir(shconfigs_cfg_folder, charsmax(shconfigs_cfg_folder))
    add(shconfigs_cfg_folder, charsmax(shconfigs_cfg_folder), SHCONFIGS_CFG_DIRECTORY, 20)

    // Attempt to create directory if it does not exist
    if ( !dir_exists(shconfigs_cfg_folder) ) {
        mkdir(shconfigs_cfg_folder)
    }

    formatex(shconfigs_cfg_file, charsmax(shconfigs_cfg_file), "%s/%s", shconfigs_cfg_folder,SHCONFIGS_CFG_FILENAME)
}


//----------------------------------------------------------------------------------------------
loadConfig()
{
	//Load SH Config File
	if ( file_exists(shconfigs_cfg_file) ) {
		
		log_amx("Loading shero_configs.cfg")

		server_cmd("exec %s", shconfigs_cfg_file)

		server_exec()
	}
	else {
		log_amx("Could not find %s file", shconfigs_cfg_file)
	}
}

mySQLConnectForConfigs()
{

    // Only create the tuple it was not done yet or a connection could not be made
    if ( !MySQL_Tuple ) {
        

        //mysql only for now
        SQL_SetAffinity("mysql")

        // Set up the tuple, cache the information
        MySQL_Tuple = SQL_MakeDbTuple(setting_struct_arr[SETTING_MYSQL_HOST][value_string],
                                setting_struct_arr[SETTING_MYSQL_USER][value_string],
                                setting_struct_arr[SETTING_MYSQL_PASS][value_string],
                                setting_struct_arr[SETTING_MYSQL_DB][value_string])
    }

    // Attempt to connect
    static error[128]
    new errcode
    if ( MySQL_Tuple ) MySQL_Handle = SQL_Connect(MySQL_Tuple, errcode, error, charsmax(error))

    if ( MySQL_Handle == Empty_Handle ) {
        /*console_print(0,"MySQL connect error: [%d] '%s' (%s,%s,%s)^n", errcode, error,
                                        setting_struct_arr[SETTING_MYSQL_HOST][value_string],
                                        setting_struct_arr[SETTING_MYSQL_USER][value_string],
                                        setting_struct_arr[SETTING_MYSQL_DB][value_string])*/

        // Free the tuple on a connection error
        SQL_FreeHandle(MySQL_Tuple)
        MySQL_Tuple = Empty_Handle
        return
    }
    /*console_print(0,"MySQL connect sucessfull!: [%d] '%s' (%s,%s,%s)^n", errcode, error,
                                        setting_struct_arr[SETTING_MYSQL_HOST][value_string],
                                        setting_struct_arr[SETTING_MYSQL_USER][value_string],
                                        setting_struct_arr[SETTING_MYSQL_DB][value_string])*/

}

//----------------------------------------------------------------------------------------------
close_mysql()
{
	if ( MySQL_Handle == Empty_Handle ) return

	SQL_FreeHandle(MySQL_Handle)
	MySQL_Handle = Empty_Handle
}
config_saving_end()
{
	if ( MySQL_Handle != Empty_Handle ) {
		SQL_FreeHandle(MySQL_Handle)
		MySQL_Handle = Empty_Handle
		
	}

	if ( MySQL_Tuple != Empty_Handle ) {
		SQL_FreeHandle(MySQL_Tuple)
		MySQL_Tuple = Empty_Handle
	}
}

initialize_config_engine(){


    mySQLConnectForConfigs()
    close_mysql()
    config_saving_end()

}