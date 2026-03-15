#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"


#define PLUGIN "task allocator aux stuff"
#define VERSION "1.0.0"
#define AUTHOR "ThrashBrat"

initialize_default_stuff(){


	starting_id = default_starting_id
	slots_per_task_type[player_task]=default_slots_per_player_task
	slots_per_task_type[entity_task]=default_slots_per_entity_task

}

public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);

	starting_id_pcvar = register_cvar("ta_starting_slot_id","1000")
	slots_per_task_type_pcvars[player_task] = register_cvar("ta_slots_per_player_task","40")
	slots_per_task_type_pcvars[entity_task] = register_cvar("ta_slots_per_entity_task","2000")

	initialize_default_stuff()

	setupConfig()
	loadConfig()
	loadCVARS()
	start_allocator()

}

public plugin_natives(){

    register_native("allocate_typed_task_id", "_allocate_typed_task_id",0)

}

loadCVARS(){




	starting_id = get_pcvar_num(starting_id_pcvar);

	slots_per_task_type[player_task] = get_pcvar_num(slots_per_task_type_pcvars[player_task]);
	slots_per_task_type[entity_task] = get_pcvar_num(slots_per_task_type_pcvars[entity_task]);



}
//----------------------------------------------------------------------------------------------
setupConfig()
{
	// Set Up Config Files
	get_configsdir(allocator_cfg_folder, charsmax(allocator_cfg_folder))
	add(allocator_cfg_folder, charsmax(allocator_cfg_folder), ALLOCATOR_CFG_DIRECTORY, 20)

	// Attempt to create directory if it does not exist
	if ( !dir_exists(allocator_cfg_folder) ) {
		mkdir(allocator_cfg_folder)
	}

	formatex(allocator_cfg_file, charsmax(allocator_cfg_file), "%s/%s", allocator_cfg_folder,ALLOCATOR_CFG_FILENAME)
}


//----------------------------------------------------------------------------------------------
loadConfig()
{
	//Load SH Config File
	if ( file_exists(allocator_cfg_file) ) {
		
		log_amx("Loading allocator.cfg")

		server_cmd("exec %s", allocator_cfg_file)

		server_exec()
	}
	else {
		log_amx("Could not find %s file", allocator_cfg_file)
	}
}
start_allocator(){

	curr_num_of_tasks=0;
	task_id_to_give=starting_id;

}
print_allocator_state(){
/*
stock starting_id = default_starting_id;

const default_slots_per_player_task = 40
const default_slots_per_entity_task = 2000

stock slots_per_task_type[_:max_task_type];

*/
	server_print("Printing current allocator state!!^n^nAllocator stuff:^nStarting slot: %d (default: %d)^n^n^nDefined num slots for task types:^n1- player_tasks: %d slots (default is %d)^n2- Entity tasks: %d slots (default is %d)^n",
					starting_id, default_starting_id,
					slots_per_task_type[player_task], default_slots_per_player_task,
					slots_per_task_type[entity_task], default_slots_per_entity_task)
	server_print("Curr num of tasks: %d^nPrev task id given: %d^n^nCurr task id to give: %d^n^nEnd of task_allocator state printing!!!^n",
					curr_num_of_tasks,prev_task_id_given,task_id_to_give)

}

public _allocate_typed_task_id(iPlugin,iParams){

	new the_type = get_param(1)

	prev_task_id_given = task_id_to_give


	task_id_to_give += (slots_per_task_type[the_type]+1)
	curr_num_of_tasks++;

	print_allocator_state()

	return prev_task_id_given;


}