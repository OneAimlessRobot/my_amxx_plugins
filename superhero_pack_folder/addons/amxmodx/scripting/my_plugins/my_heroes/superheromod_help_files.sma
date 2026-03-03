#include "../my_include/superheromod.inc"
#include "./superheromod_help_files_includes/superheromod_help_files.inc"


#define PLUGIN "Superhero help file funcs"
#define VERSION "1.0.0"
#define AUTHOR "ThrasherBratter"
#define Struct				enum

stock help_files_directory[STRLEN_FOR_FILES+1]
stock const help_cmd[]="help_of"
stock const config_directory_name[128]="/shero_help_files/"
stock const default_directory_name[128]="shero_def_dir/"
stock const default_index_name[128]="shero_no_help_found.html"
stock const default_title[128]="No Help Found for the specified hero."
stock const default_hero_name[128]={0};
stock default_directory[STRLEN_FOR_FILES+1]
stock default_file[STRLEN_FOR_FILES+1]
enum{
	TITLE=0,
	INDEX_NAME=1,
	DIR_NAME=2,
	HERO_NAME=3
};
stock superhero_help_files[SH_MAXHEROS][4][STRLEN_FOR_FILES+1];

public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	setup_configs()
	register_clcmd("print_help_files", "print_current_help_files")
	register_clcmd("say", "cl_say")


}
//sh_get_hero_id(string);

setup_configs(){

	for(new i=0;i<sizeof superhero_help_files;i++){
		
		arrayset(superhero_help_files[i][TITLE],0,STRLEN_FOR_FILES+1)
		arrayset(superhero_help_files[i][INDEX_NAME],0,STRLEN_FOR_FILES+1)
		arrayset(superhero_help_files[i][DIR_NAME],0,STRLEN_FOR_FILES+1)
		arrayset(superhero_help_files[i][HERO_NAME],0,STRLEN_FOR_FILES+1)
	
	}
	get_configsdir(help_files_directory,  charsmax(help_files_directory))
	add(help_files_directory, charsmax(help_files_directory), config_directory_name, charsmax(config_directory_name))

	arrayset(default_file,0,sizeof default_file)
	arrayset(default_directory,0,sizeof default_directory)
	add(default_file, charsmax(default_file), help_files_directory, charsmax(help_files_directory))
	add(default_file, charsmax(default_file), default_directory_name, charsmax(default_directory_name))
	add(default_file, charsmax(default_file), default_index_name, charsmax(default_index_name))
	add(default_directory, charsmax(default_directory), help_files_directory, charsmax(help_files_directory))
	add(default_directory, charsmax(default_directory), default_directory_name, charsmax(default_directory_name))
	
	for(new i=0;i<SH_MAXHEROS;i++){
		
		set_hero_id_entry_to_default(i)
	}
	// Attempt to create directory if it does not exist
	if ( !dir_exists(help_files_directory) ) {
		mkdir(help_files_directory)
		if ( !dir_exists(help_files_directory) ) {
			log_error(AMX_ERR_NOTFOUND,"Directory of path %s could not be created^nEven when it doesnt exist!!!^n",
											help_files_directory) 
			return
		}
	}
	if ( !dir_exists(default_directory) ) {
		mkdir(default_directory)
		if ( !dir_exists(default_directory) ) {
			log_error(AMX_ERR_NOTFOUND,"Directory of path %s could not be created^nEven when it doesnt exist!!!^n",
											default_directory)
			return;
		}
	}
	fclose(fopen(default_file, "a+"));
	if(!file_exists(default_file)){
		log_error(AMX_ERR_NOTFOUND,"File of path %s (THE DEFAULT OAAANNEEEEEEE!!!!!11111!!!!!1!&!&!/&!) could not be created^nEven when it doesnt exist!!!^n",
										default_file)
		return
	}
}
set_hero_id_entry_to_default(hero_id){
	if((hero_id<0)||(hero_id>=SH_MAXHEROS)){
		return;
	}
	arrayset(superhero_help_files[hero_id][INDEX_NAME],0,STRLEN_FOR_FILES)
	arrayset(superhero_help_files[hero_id][DIR_NAME],0,STRLEN_FOR_FILES)
	arrayset(superhero_help_files[hero_id][TITLE],0,STRLEN_FOR_FILES)
	arrayset(superhero_help_files[hero_id][HERO_NAME],0,STRLEN_FOR_FILES)
	add(superhero_help_files[hero_id][INDEX_NAME],STRLEN_FOR_FILES,default_file, charsmax(default_file))
	add(superhero_help_files[hero_id][DIR_NAME],STRLEN_FOR_FILES,default_directory, charsmax(default_directory))
	add(superhero_help_files[hero_id][TITLE],STRLEN_FOR_FILES,default_title, charsmax(default_title))
	add(superhero_help_files[hero_id][HERO_NAME],STRLEN_FOR_NAMES,default_hero_name, charsmax(default_hero_name))
}
public plugin_cfg(){


	loadCVARS()
}//----------------------------------------------------------------------------------------------
public cl_say(id)
{
	static said[192]
	read_args(said, charsmax(said))
	remove_quotes(said)

	if ( !get_cvar_num("sv_superheros") ) {
		if ( containi(said, help_cmd) ) {
			sh_chat_message(id, _, "SuperHero Mod is currently disabled")
		}
		return PLUGIN_CONTINUE
	}

	// If first character is "/" start command check after that character
	new pos=0;
	if ( said[pos] == '/' ) pos++

	if ( equali(said[pos], help_cmd, 4) ) {
		show_hero_help(id, said)
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public show_hero_help(id, const said[])
{
	new heroName[32]
	new heroIndex=-1;
	new spaceIdx = contain(said, " ")
	if ( spaceIdx > 0 && strlen(said) > spaceIdx+2 ) {
		copy(heroName, charsmax(heroName), said[spaceIdx+1] )
	}
	else {
		sh_chat_message(id, _, "Please provide at least two letters from the hero name you wish to drop")
		return
	}

	
	for ( heroIndex= 0; heroIndex <SH_MAXHEROS; heroIndex++ ) {
		if ( containi( superhero_help_files[heroIndex][HERO_NAME], heroName ) != -1 ) {
			sh_chat_message(id, heroIndex, "Arrived at help for hero: %s", superhero_help_files[heroIndex][HERO_NAME])			
			break
		}
	}
	superheromod_help_show_hero_help(id, heroIndex)
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
/*ester_flyspeed=get_cvar_float("ester_flyspeed");
*/
}
public plugin_natives(){

	register_native("superheromod_help_link_hero","_superheromod_help_link_hero",0);
	
	register_native("superheromod_help_show_hero_help","_superheromod_help_show_hero_help",0);
	
}

public _superheromod_help_show_hero_help(iPlugins,iParams){
	new id=get_param(1);
	new hero_id=get_param(2);
	if(!is_user_connected(id)){
		return
	}
	if((hero_id<0)||(hero_id>=SH_MAXHEROS)){
		show_motd(id, default_file, default_title)
		return
	}
	show_motd(id, superhero_help_files[hero_id][INDEX_NAME],superhero_help_files[hero_id][TITLE])


}
public _superheromod_help_link_hero(iPlugins,iParams){
	new hero_id=get_param(1);
	new dir_name[STRLEN_FOR_FILES+1]
	new index_name[STRLEN_FOR_FILES+1]
	new title[STRLEN_FOR_FILES+1]
	new hero_name[STRLEN_FOR_NAMES+1]
	if((hero_id<0)||(hero_id>=SH_MAXHEROS)){
		return
	}
	arrayset(superhero_help_files[hero_id][INDEX_NAME],0,STRLEN_FOR_FILES)
	
	arrayset(superhero_help_files[hero_id][DIR_NAME],0,STRLEN_FOR_FILES)
			
	arrayset(superhero_help_files[hero_id][TITLE],0,STRLEN_FOR_FILES)
			
	arrayset(superhero_help_files[hero_id][HERO_NAME],0,STRLEN_FOR_FILES)
			
	get_array(2, title, STRLEN_FOR_FILES);
	get_array(3, dir_name, STRLEN_FOR_FILES);
	get_array(4, index_name, STRLEN_FOR_FILES);
	get_array(5, hero_name, STRLEN_FOR_NAMES);
	server_print("Trying to register help file of hero named %s!!!!^n",hero_name)
	add(superhero_help_files[hero_id][TITLE],STRLEN_FOR_FILES,title, charsmax(title))
	add(superhero_help_files[hero_id][HERO_NAME],STRLEN_FOR_NAMES,hero_name, charsmax(hero_name))
	add(superhero_help_files[hero_id][DIR_NAME],STRLEN_FOR_FILES,help_files_directory, charsmax(help_files_directory))
	add(superhero_help_files[hero_id][DIR_NAME],STRLEN_FOR_FILES,dir_name, charsmax(dir_name))
	add(superhero_help_files[hero_id][INDEX_NAME],STRLEN_FOR_FILES,help_files_directory, charsmax(help_files_directory))
	add(superhero_help_files[hero_id][INDEX_NAME],STRLEN_FOR_FILES,dir_name, charsmax(dir_name))
	add(superhero_help_files[hero_id][INDEX_NAME],STRLEN_FOR_FILES,index_name, charsmax(index_name))
	
	if ( !dir_exists(superhero_help_files[hero_id][DIR_NAME]) ) {
		mkdir(superhero_help_files[hero_id][DIR_NAME])
		if ( !dir_exists(superhero_help_files[hero_id][DIR_NAME]) ) {
			log_error(AMX_ERR_NOTFOUND,"Directory of path %s could not be created^nEven when it doesnt exist!!!^n",
											superhero_help_files[hero_id][DIR_NAME])
			set_hero_id_entry_to_default(hero_id)
			return;
		}
	}
	if(!file_exists(superhero_help_files[hero_id][INDEX_NAME])){
	
		fclose(fopen(superhero_help_files[hero_id][INDEX_NAME], "a+"));
		if(!file_exists(superhero_help_files[hero_id][INDEX_NAME])){
			log_error(AMX_ERR_NOTFOUND,"File of path %s could not be created^nEven when it doesnt exist!!!^n",
											superhero_help_files[hero_id][INDEX_NAME]) 
			set_hero_id_entry_to_default(hero_id)
			return
		}
	}
	server_print("Registered help file of hero named %s sucessfully!!!!!^n",hero_name)
	server_print_help_file(hero_id)
	
}
//----------------------------------------------------------------------------------------------
stock print_help_file(id,hero_index){

		if(is_user_connected(id)){
			console_print(id,"[SH] (Hero help files): Hero help title: %s",
						superhero_help_files[hero_index][TITLE])
			console_print(id,"[SH] (Hero help files): Hero help directory name: %s",
						superhero_help_files[hero_index][DIR_NAME])
			console_print(id,"[SH] (Hero help files): Hero help index name: %s",
						superhero_help_files[hero_index][INDEX_NAME])
			console_print(id,"[SH] (Hero help files): Hero name: %s",
						superhero_help_files[hero_index][HERO_NAME])
		}

}
//----------------------------------------------------------------------------------------------
stock server_print_help_file(hero_index){

		server_print("[SH] (Hero help files): Hero help title: %s",
					superhero_help_files[hero_index][TITLE])
		server_print("[SH] (Hero help files): Hero help directory name: %s",
						superhero_help_files[hero_index][DIR_NAME])
		server_print("[SH] (Hero help files): Hero help index name: %s",
						superhero_help_files[hero_index][INDEX_NAME])
		server_print("[SH] (Hero help files): Hero name: %s",
					superhero_help_files[hero_index][HERO_NAME])

}
//----------------------------------------------------------------------------------------------
public print_current_help_files(id){

	for(new i=0;i<SH_MAXHEROS;i++){
	
		if(is_user_connected(id)){
			print_help_file(id,i)
		}
	}

}



//fopen(const filename[], const mode[], bool:use_valve_fs = false, const valve_path_id[] = "GAME");
//file_exists(const file[], bool:use_valve_fs = false);
