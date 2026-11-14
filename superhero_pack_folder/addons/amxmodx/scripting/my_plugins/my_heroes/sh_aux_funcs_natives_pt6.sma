#define I_WANT_CONSTANTS
#define I_WANT_BASIC_MACROS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "SH aux funcs 6: xtra help files"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt4.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt6.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt9.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt10.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt11.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt12.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt17.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt15.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt18.inc"

#include "sh_aux_stuff/sh_aux_stuff_natives_pt6.inc"

stock const extra_help_cmd[]="extra_help"
stock const general_help_cmd[]="general_help"
stock help_files_directory[STRLEN_FOR_FILES+1]

#define HELP_FILE_URL_BASE "http://lenasattic.ddns.net:11020/webcrookedstuff/cstrike_folder/addons/amxmodx/configs/shero_extra_help/"
#define NUM_OF_EXTRA_HELP_FILES 3



stock const help_file_dir_name[128]="/shero_extra_help/"

enum help_file_disk_list_node{

	file_name[128],
	file_path[128],
	callback_name_for_filling[128],
	callback_id,
	bool:validated


}


new help_file_structs_array[NUM_OF_EXTRA_HELP_FILES][help_file_disk_list_node] = {

	{"sh_extra_help_motd.html", "", "createHelpMotdFile", -1, false},
	{"sh_extra_help_motd_2.html", "", "createHelpMotdFilePt2", -1, false},
	{"sh_extra_help_motd_3.html", "", "createHelpMotdFilePt3", -1, false}



}

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say", "cl_say")
    
	
}
setup_help_files_env(){
	// Set Up Config Files
	get_configsdir(help_files_directory,  charsmax(help_files_directory))
	add(help_files_directory, charsmax(help_files_directory), help_file_dir_name, charsmax(help_file_dir_name))

	// Attempt to create directory if it does not exist
	if ( !dir_exists(help_files_directory) ) {
		mkdir(help_files_directory)
	}
}
//----------------------------------------------------------------------------------------------
public createHelpMotdFile(const extraHelpFile){
	

	fputs(extraHelpFile, "say /help_of [part of hero name] -^n	Shows you a help page for a particular hero (if available)^n^n^n")
	fputs(extraHelpFile, "say /skins - show menu for skins depending on heroes equipped. Both weapons and body^n^n^n")

	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, hero_properties_descriptions_print)
	fputs(extraHelpFile, " - shows a list of descriptions for all hero properties registered^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, hero_properties_print)
	fputs(extraHelpFile, " - shows a list hero properties that a hero is currently registered with^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, player_flags_print)
	fputs(extraHelpFile, " - shows a list of hero properties a player currently has (due to equipped heroes)^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, admin_compatibility_print)
	fputs(extraHelpFile, " - shows a list of admin/limited server pick heroes^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, hero_incompatible_pairs_print)
	fputs(extraHelpFile, " - shows a list of the incompatible hero pairs registered in the server^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, hero_healthcaps_print)
	fputs(extraHelpFile, " - shows a list of health capped heroes registered in the server^n^n")
}
//----------------------------------------------------------------------------------------------
public createHelpMotdFilePt2(extraHelpFile){
	
	fputs(extraHelpFile, "Part 2 of extra help file!^n^n^n")

	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, check_map_blacklist_for_hero)
	fputs(extraHelpFile, " - shows a list of maps that a hero cannot be played on. Requires part of hero name^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, check_map_whitelist_for_hero)
	fputs(extraHelpFile, " - shows a list of the only maps that a hero can be played on. Requires part of hero name^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, check_map_blacklist)
	fputs(extraHelpFile, " - shows a list of heroes that are blacklisted for at least one map^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, check_map_whitelist)
	fputs(extraHelpFile, " - shows a list of heroes that are whitelisted for at least one map^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, check_what_damage_types_exist)
	fputs(extraHelpFile, " - shows a list of the damage types that exist!^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, player_damage_recoveries_print)
	fputs(extraHelpFile, " - shows a list of damage types that this player can currently recover hp from!^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, hero_damage_recoveries_print)
	fputs(extraHelpFile, " - shows a list of damage types that a hero allows a user to recover from!^n^n")
	
}
//----------------------------------------------------------------------------------------------
public createHelpMotdFilePt3(extraHelpFile){
	
	fputs(extraHelpFile, "Part 3 of extra help file!^n^n^n")

	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, player_unhealable_hero_skip_flags)
	fputs(extraHelpFile, " - Shows a list of damage types a player will heal from even if using unhealable heroes! Requires part of hero name^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, hero_unhealable_hero_skip_flags)
	fputs(extraHelpFile, " - Shows a list of heroes that skip unhealable flags!^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, player_projectile_weapons_print)
	fputs(extraHelpFile, " -  A list of projectile weapon flags that a player has due to equipped heroes^n^n^n")
	fputs(extraHelpFile, "(console) ")
	fputs(extraHelpFile, hero_projectile_weapons_print)
	fputs(extraHelpFile, " - Shows a list of projectile weapons for a hero!^n^n^n")

	
}
//----------------------------------------------------------------------------------------------
showExtraHelp(id)
{	
	if(help_file_structs_array[0][validated]){
		show_motd(id, help_file_structs_array[0][file_path], "SuperHero extra Help")
	}
}
//----------------------------------------------------------------------------------------------
setupHelpMotds()
{

	setup_help_files_env()
	
	static extraHelpFile;

	for(new i = 0; i< NUM_OF_EXTRA_HELP_FILES; i++){

		formatex(help_file_structs_array[i][file_path], 127, "%s/%s",help_files_directory, help_file_structs_array[i][file_name])
		extraHelpFile = 0

		if ( !file_exists(help_file_structs_array[i][file_path]) ) {
			// Write as binary so if created on windows server the motd won't display double spaced
			extraHelpFile = fopen(help_file_structs_array[i][file_path], "wb")
			if ( !extraHelpFile ) {
				log_amx("Failed to create %s, please verify file/folder permissions",help_file_structs_array[i][file_path])
				
			}
			else
			{
				help_file_structs_array[i][callback_id] = get_func_id(help_file_structs_array[i][callback_name_for_filling])
				if(help_file_structs_array[i][callback_id]<0){

					
					fclose(extraHelpFile)
					continue
				}
				
				fputs(extraHelpFile, "<!DOCTYPE html><html><head>")
				fputs(extraHelpFile, "<base href=^"")
				fputs(extraHelpFile, HELP_FILE_URL_BASE)
				fputs(extraHelpFile, "^"><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><body><pre>")


				callfunc_begin_i(help_file_structs_array[i][callback_id])
				callfunc_push_int(extraHelpFile)
				callfunc_end()



				new iprev = (i-1),
					inext = (i+1)

				if(iprev >= 0){

					fputs(extraHelpFile, "<a href=^"./")
					fputs(extraHelpFile, help_file_structs_array[iprev][file_name])
					fputs(extraHelpFile, "^">Previous extra help file entry</a>^n")
				}
				if(inext < NUM_OF_EXTRA_HELP_FILES){

					fputs(extraHelpFile, "<a href=^"./")
					fputs(extraHelpFile, help_file_structs_array[inext][file_name])
					fputs(extraHelpFile, "^">Next extra help file entry</a>^n")
				}

				fputs(extraHelpFile, "</pre></body></html>")

				fclose(extraHelpFile)

				help_file_structs_array[i][validated] = true
			}
			
		
		}
		else{

			help_file_structs_array[i][validated] = true
		}

	}
}
public plugin_cfg(){


prepare_shero_aux_lib_pt6()


}
public cl_say(id){

	static said[192]
	read_args(said, charsmax(said))
	remove_quotes(said)

	if ( !get_cvar_num("sv_superheros") ) {
		if ( containi(said, extra_help_cmd) ||  containi(said, general_help_cmd)  ) {
			sh_chat_message(id, _, "SuperHero Mod is currently disabled")
		}
		return PLUGIN_CONTINUE
	}

	
	if ( containi(said, "models") != -1 || containi(said, "superhero") != -1 ) {
		sh_chat_message(id, _, "For additional help with SuperHero Mod, say: /%s or /%s",
							extra_help_cmd,
							general_help_cmd)
		
		return PLUGIN_CONTINUE
	}

	// If first character is "/" start command check after that character
	new pos=0;
	if ( said[pos] == '/' ) pos++

	if ( equali(said[pos], extra_help_cmd, 4) ) {
		showExtraHelp(id)
		return PLUGIN_HANDLED
	}
	if ( equali(said[pos], general_help_cmd, 4) ) {
		show_motd(id,"motd.txt","REBORN SUPERHERO MOD general help file")
		return PLUGIN_HANDLED
	}


	return PLUGIN_CONTINUE
}
public plugin_natives(){


	register_native("prepare_shero_aux_lib_pt6","_prepare_shero_aux_lib_pt6");
}

public _prepare_shero_aux_lib_pt6(iPlugins, iParams){
	
	setupHelpMotds()
	server_print("%s innited!^n",PLUGIN)
}
