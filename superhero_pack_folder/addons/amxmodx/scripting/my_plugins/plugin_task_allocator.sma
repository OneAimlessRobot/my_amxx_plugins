#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "task_allocator_inc/task_allocator_aux_stuff.inc"


#define PLUGIN "task allocator aux stuff"
#define VERSION "1.0.0"
#include "my_include/my_author_header.inc"


#define ALLOCATOR_CFG_FILENAME "allocator.cfg"
#define ALLOCATOR_CFG_DIRECTORY "/task_allocator"




enum task_type_string_fields{
        convar_string=0,
        default_value_string,
        type_name,
        task_type_string_max_field
};
stock allocator_cfg_folder[128],allocator_cfg_file[128]



const default_starting_id =1000
stock starting_id = default_starting_id;

const default_slots_per_player_task = 40
const default_slots_per_entity_task = 2000
const default_slots_per_generic_task = 10

stock const default_slots_per_player_task_arr[_:max_task_type]={
        
        default_slots_per_player_task,
        default_slots_per_entity_task,
        default_slots_per_generic_task
        
};

stock const default_slots_task_type_strings[_:max_task_type][_:task_type_string_max_field][]={
        
        {"ta_slots_per_player_task","40","player_task"},
        {"ta_slots_per_entity_task","2000","entity_task"},
        {"ta_slots_per_generic_task","10","generic_task"}
        
};

stock slots_per_task_type[_:max_task_type];




stock curr_num_of_tasks,
        prev_task_id_given,
        task_id_to_give;



stock starting_id_pcvar, slots_per_task_type_pcvars[_:max_task_type];


public plugin_end(){

	/*remove every 0 id task (it shouldnt be necessary, though.
	just to test, for now
	Any "bloat complainers" 
	will have to answer back if my server crashes
	I actually want to hear from them*/

	remove_task(0, 1)
}
initialize_default_stuff(){


	starting_id = default_starting_id
	for(new i=0;i<_:max_task_type;i++){

		slots_per_task_type[i]=default_slots_per_player_task_arr[i]
	}

}

public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);

	starting_id_pcvar = create_cvar("ta_starting_slot_id","1000")
	for(new i=0;i<_:max_task_type;i++){
		slots_per_task_type_pcvars[i] = create_cvar(default_slots_task_type_strings[i][_:convar_string],default_slots_task_type_strings[i][_:default_value_string])
	}
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

	for(new i=0;i<_:max_task_type;i++){
		slots_per_task_type[i] = get_pcvar_num(slots_per_task_type_pcvars[i]);
	}


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
		
		log_amx("Loading %s",ALLOCATOR_CFG_FILENAME)

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
stock print_allocator_state(){

	server_print("Printing current allocator state!!^n^nAllocator stuff:^nStarting slot: %d (default: %d)^n^n^n",
					starting_id, default_starting_id)
	server_print("Defined num slots for task types:^n")
	for(new i=0;i<_:max_task_type;i++){
		server_print("%d- %s: %d slots (default is %d)^n",
					i,
					default_slots_task_type_strings[i][_:type_name],
					slots_per_task_type[i],
					default_slots_per_player_task_arr[i])
	}
	server_print("Curr num of tasks: %d^nPrev task id given: %d^n^nCurr task id to give: %d^n^nEnd of task_allocator state printing!!!^n",
					curr_num_of_tasks,prev_task_id_given,task_id_to_give)

}

public _allocate_typed_task_id(iPlugin,iParams){

	new the_type = get_param(1)
	new stack_ammount= get_param(2)
	prev_task_id_given = task_id_to_give


	task_id_to_give += ((slots_per_task_type[the_type]+1)+(3*stack_ammount))
	curr_num_of_tasks++;

	//print_allocator_state()
	
	return prev_task_id_given;


}