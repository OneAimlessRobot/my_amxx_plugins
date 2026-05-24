#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_WEAPONS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "weapon secret code aux stuff"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

initialize_default_stuff(){


	starting_secret_code = default_starting_secret_code

}

public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);

	starting_secret_code_pcvar = register_cvar("generator_starting_secret_code","10000")
	register_ham_for_weapon_bitsum(Ham_Spawn,GUNS_BIT_SUM|CSW_KNIFE,"ham_weapon_spawn",_, true, false)

	initialize_default_stuff()

	setupConfig()
	loadConfig()
	loadCVARS()
	start_allocator()

}
public ham_weapon_spawn(entity){

	ent_check(entity,HAM_IGNORED)

	entity_set_int(entity,EV_INT_iuser1, -1)

	return HAM_IGNORED

}
public plugin_natives(){

    register_native("allocate_weapon_secret_code", "_allocate_weapon_secret_code",0)

}

loadCVARS(){




	starting_secret_code = get_pcvar_num(starting_secret_code_pcvar);


}
//----------------------------------------------------------------------------------------------
setupConfig()
{
	// Set Up Config Files
	get_configsdir(generator_cfg_folder, charsmax(generator_cfg_folder))
	add(generator_cfg_folder, charsmax(generator_cfg_folder),
				WEAPON_SECRET_CODE_GENERATOR_CFG_DIRECTORY, 20)

	// Attempt to create directory if it does not exist
	if ( !dir_exists(generator_cfg_folder) ) {
		mkdir(generator_cfg_folder)
	}

	formatex(generator_cfg_file, charsmax(generator_cfg_file), "%s/%s", generator_cfg_folder,
				WEAPON_SECRET_CODE_GENERATOR_CFG_FILENAME)
}


//----------------------------------------------------------------------------------------------
loadConfig()
{
	//Load SH Config File
	if ( file_exists(generator_cfg_file) ) {
		
		log_amx("Loading %s",WEAPON_SECRET_CODE_GENERATOR_CFG_FILENAME)

		server_cmd("exec %s", generator_cfg_file)

		server_exec()
	}
	else {
		log_amx("Could not find %s file", generator_cfg_file)
	}
}
start_allocator(){

	curr_num_of_custom_weapons=0;
	weapon_id_to_give=starting_secret_code;

}
stock print_generator_state(){

	server_print("Printing current generator state!!^n^nAllocator stuff:^nStarting slot: %d (default: %d)^n^n^n",
					starting_secret_code, default_starting_secret_code)
	
	server_print("Curr num of secret codes: %d^nPrev task id given: %d^n^nCurr weapon id to give: %d^n^nEnd of weapon id generator state printing!!!^n",
					curr_num_of_custom_weapons,
					prev_task_weapon_id_given,
					weapon_id_to_give)

}

public _allocate_weapon_secret_code(iPlugin,iParams){

	prev_task_weapon_id_given = weapon_id_to_give


	weapon_id_to_give ++
	curr_num_of_custom_weapons++;

	//print_generator_state()
	
	return prev_task_weapon_id_given;


}