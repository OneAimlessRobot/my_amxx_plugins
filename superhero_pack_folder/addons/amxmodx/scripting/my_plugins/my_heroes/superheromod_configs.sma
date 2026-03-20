#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "superheromod_configs_aux/superheromod_configs_header.inc"



#define PLUGIN "Superhero config_funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


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



}
public plugin_natives(){

    register_native("fetch_player_config", "_fetch_player_config",0)

}

public newRound(id){

	if(!client_hittable(id)||!sh_is_active()){
		
		return PLUGIN_CONTINUE
	}
	if(!is_user_bot(id)){
        new player_key_from_id[MAX_PLAYER_SAVE_KEY_LENGTH]
        sh_get_player_save_key_on_db(id,player_key_from_id)
        sh_chat_message(id,0,"Here is your savekey_id for the db!:^n%s^n",player_key_from_id)
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