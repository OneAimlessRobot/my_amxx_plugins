#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt6: superhero help for ThrashBrat Libs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt6.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt6.inc"


stock const extra_help_cmd[]="extra_help"
stock const general_help_cmd[]="general_help"
stock help_files_directory[STRLEN_FOR_FILES+1]
stock const help_file_dir_name[128]="/shero_extra_help/"
stock const extra_help_file_name[128]="sh_extra_help_motd.txt"
new extra_help_motd[1024]

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say", "cl_say")
	prepare_shero_aux_lib_pt6()
    
	
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
createHelpMotdFile(const helpMotdFile[]){
	// Write as binary so if created on windows server the motd won't display double spaced
	new extraHelpFile = fopen(helpMotdFile, "wb")
	if ( !extraHelpFile ) {
		log_amx("Failed to create sh_extra_help_motd.txt, please verify file/folder permissions")
		return
	}
	fputs(extraHelpFile, "<html><head><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><body><pre>^n")


	fputs(extraHelpFile, "say /help_of [part of hero name] - Shows you a help page for a particular hero (if available)^n")
	fputs(extraHelpFile, "(Console) sh_print_models		- Shows you a list of player model ids available depending on heroes equipped^n")
	fputs(extraHelpFile, "(Console) sh_choose_model	[model_id] - pick a player model! The only parameter required is the id of it^n")
	
	fputs(extraHelpFile, "</pre></body></html>")

	fclose(extraHelpFile)
}
//----------------------------------------------------------------------------------------------
showExtraHelp(id)
{
	show_motd(id, extra_help_motd, "SuperHero extra Help")
}
//----------------------------------------------------------------------------------------------
setupHelpMotd()
{
	formatex(extra_help_motd, charsmax(extra_help_motd), "%s/%s",help_files_directory,extra_help_file_name)

	if ( !file_exists(extra_help_motd) ) {
		//Create the file if it doesn't exist
		createHelpMotdFile(extra_help_motd)
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


	register_native("prepare_shero_aux_lib_pt6","_prepare_shero_aux_lib_pt6",0);
}

public _prepare_shero_aux_lib_pt6(iPlugins, iParams){
	
	setup_help_files_env()
	setupHelpMotd()
	server_print("%s innited!^n",LIBRARY_NAME)
}
