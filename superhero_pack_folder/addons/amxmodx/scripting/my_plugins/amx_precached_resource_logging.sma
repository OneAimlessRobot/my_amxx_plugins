#define AUX_STUFF_GIVE_MACROS
#include <amxmisc>
#include <orpheu>
#include <orpheu_stocks>
#include "../include/fakemeta.inc"
#include "../include/engine.inc"
#include "my_include/auxiliar_stuff.inc"


#define PLUGIN "AMX Precached resource logging"
#define VERSION "1.0.0"
#include "my_include/my_author_header.inc"


#define THE_TOTAL_DIR_LENGTH 80


new const DEBUG_MODE = 0

new bool:setup_done = false;
new bool:plugin_done = false;
new the_data_path_to_use[THE_TOTAL_DIR_LENGTH],
		the_data_subdir_name[THE_TOTAL_DIR_LENGTH] = "/precached_res_tmp_files/"


enum files_to_use{

	precached_sounds_file = 0,
	precached_models_file,
	precached_generics_file,
	precached_events_file


}

enum file_handling_struct{

	curr_num_resources,
	file_ptr,
	bool:tried_opening,
	temp_buff[THE_TOTAL_DIR_LENGTH],
	the_file_name[THE_TOTAL_DIR_LENGTH],
	the_file_path[THE_TOTAL_DIR_LENGTH],
	file_struct_name[64],
	the_forward_id,
	FM_Constant,
	function_name[32],
	is_post,
	is_orpheu,
	orpheu_engine_function_name[32],
	function_name_if_orpheu[32],
	callback_func_name_if_orpheu[32]



}

new file_paths_for_files[files_to_use][file_handling_struct] = {
	{0, 0, false, "", "precached_sounds_list.txt", "", "sound", 0, FM_PrecacheSound, "fw_precache_sound", 1, 1, "pfnPrecacheSound", "PrecacheSound", "fw_precache_sound"},
	{0, 0, false, "", "precached_models_list.txt", "", "model", 0, FM_PrecacheModel, "fw_precache_model", 1, 1, "pfnPrecacheModel", "PrecacheModel",  "fw_precache_model"},
	{0, 0, false, "", "precached_generics_list.txt", "", "generic", 0, FM_PrecacheGeneric, "fw_precache_generic", 1, 1, "pfnPrecacheGeneric", "PrecacheGeneric", "fw_precache_generic"},
	{0, 0, false, "", "precached_events_list.txt", "", "event", 0, FM_PrecacheEvent, "fw_precache_event", 1, 0, "", ""}
}

new Trie:tries_for_files[files_to_use]

setup_precache_files_env(){
	// Set Up Config Files
	get_datadir(the_data_path_to_use,  charsmax(the_data_path_to_use))
	add(the_data_path_to_use, charsmax(the_data_path_to_use), the_data_subdir_name, charsmax(the_data_subdir_name))

	// Attempt to create directory if it does not exist
	if ( !dir_exists(the_data_path_to_use) ) {
		mkdir(the_data_path_to_use)
	}

	for( new files_to_use:i = enum_zero; i< files_to_use; i++){


		formatex(file_paths_for_files[i][the_file_path], THE_TOTAL_DIR_LENGTH-1, "%s%s",the_data_path_to_use,file_paths_for_files[i][the_file_name])


		if(DEBUG_MODE){
			server_print("The %s file path is: ^"%s^"^n",file_paths_for_files[i][file_struct_name],file_paths_for_files[i][the_file_path])
		}
		
		if(tries_for_files[i] == enum_zero){

			
			tries_for_files[i]= TrieCreate()

		}
	
	}
}
public plugin_precache(){


	if(!setup_done){

		setup_precache_files_env()
		setup_done=true
	}



	for( new files_to_use:i = enum_zero; i< files_to_use; i++){

		if(!file_paths_for_files[i][is_orpheu] ){
			file_paths_for_files[i][the_forward_id] =
					register_forward( file_paths_for_files[i][FM_Constant],
							file_paths_for_files[i][function_name],
							file_paths_for_files[i][is_post])
		}
		else{

			OrpheuRegisterHook( OrpheuGetEngineFunction(
											file_paths_for_files[i][orpheu_engine_function_name],
											file_paths_for_files[i][function_name_if_orpheu]),
						file_paths_for_files[i][callback_func_name_if_orpheu],
						file_paths_for_files[i][is_post]?OrpheuHookPost:OrpheuHookPre)

		}
	}

}
public plugin_init(){



	register_plugin(PLUGIN, VERSION, AUTHOR);
	for( new files_to_use:i = enum_zero; i< files_to_use; i++){


		if(DEBUG_MODE){
			server_print( "We have stored %d resources in our %ss array!^n",file_paths_for_files[i][curr_num_resources], 
								file_paths_for_files[i][file_struct_name] )
		}
	}
	
}

//close all files
public plugin_cfg(){

	for( new files_to_use:i = enum_zero; i< files_to_use; i++){

		plugin_done = true

		if(file_paths_for_files[i][file_ptr]){

			fclose(file_paths_for_files[i][file_ptr])
		}
		if(!file_paths_for_files[i][is_orpheu] ){
			unregister_forward(file_paths_for_files[i][FM_Constant],
							file_paths_for_files[i][the_forward_id],
							file_paths_for_files[i][is_post])
			
			file_paths_for_files[i][the_forward_id] = 0
		}
		if(tries_for_files[i]){

			TrieDestroy(tries_for_files[i])
			tries_for_files[i] = enum_zero
		}

	}

}

public fw_precache_model( const Resource[ ] )
{

	precache_handler_wrapper(Resource, precached_models_file)


}
public fw_precache_sound( const Resource[ ] )
{

	precache_handler_wrapper(Resource, precached_sounds_file)


}
public fw_precache_generic( const Resource[ ] )
{

	precache_handler_wrapper(Resource, precached_generics_file)

}
public fw_precache_event( type, const Resource[ ] )
{

	precache_handler_wrapper(Resource, precached_events_file)

}

bool:precache_resource_handling_arrays( const Resource[ ], files_to_use:the_file_to_use_here )
{

	
	new bool:Precached = false
	new TrieIter:the_iter = TrieIterCreate(tries_for_files[the_file_to_use_here])
	while(!TrieIterEnded(the_iter)){
		TrieIterGetString(the_iter,file_paths_for_files[the_file_to_use_here][temp_buff],THE_TOTAL_DIR_LENGTH)


		if( equal( file_paths_for_files[the_file_to_use_here][temp_buff] , Resource ) ){
		
			Precached = true; break;
		
		}

		TrieIterNext(the_iter)
	} 
	
	
	TrieIterDestroy(the_iter)


	if( !Precached ){
		
		new the_key[10]
		formatex(the_key,charsmax(the_key),"%s",file_paths_for_files[the_file_to_use_here][curr_num_resources])

		TrieSetString( tries_for_files[the_file_to_use_here], the_key, Resource)

		file_paths_for_files[the_file_to_use_here][curr_num_resources]++
	}

	return Precached
}
precache_handler_wrapper( const Resource[ ], files_to_use:the_file_to_use_here ){
	if(!plugin_done){

		if(!precache_resource_handling_arrays(Resource, the_file_to_use_here)){
			precache_resource_handling_post(Resource, the_file_to_use_here)

		}
	}

}
precache_resource_handling_post( const Resource[ ], files_to_use:the_file_to_use_here )
{


	file_paths_for_files[the_file_to_use_here][file_ptr] = (file_paths_for_files[the_file_to_use_here][tried_opening]
								?
							file_paths_for_files[the_file_to_use_here][file_ptr]
								:
					(!(file_paths_for_files[the_file_to_use_here][file_ptr])
											?
							fopen(file_paths_for_files[the_file_to_use_here][the_file_path],"wt")
											:
								file_paths_for_files[the_file_to_use_here][file_ptr]))
	
	file_paths_for_files[the_file_to_use_here][tried_opening] = true
	
	/*

	if(!file_paths_for_files[the_file_to_use_here][tried_opening]){
		if(!(file_paths_for_files[the_file_to_use_here][file_ptr])){

			file_paths_for_files[the_file_to_use_here][file_ptr] = fopen(file_paths_for_files[the_file_to_use_here][the_file_path],"wt")

		}
		file_paths_for_files[the_file_to_use_here][tried_opening] = true

	}
	
	*/


	if(DEBUG_MODE){
		server_print("Did we open the file with path ^"%s^"? %s^nDid we already try opening? %s",
												file_paths_for_files[the_file_to_use_here][the_file_path],
												file_paths_for_files[the_file_to_use_here][file_ptr]
															?
														"Yes!"
															:
														"No...",
												file_paths_for_files[the_file_to_use_here][tried_opening]
															?
														"Yes!"
															:
														"No...")

		server_print("This is the resource to be added: %s^n",
													Resource)
	}

	if(file_paths_for_files[the_file_to_use_here][file_ptr]){


		fprintf(file_paths_for_files[the_file_to_use_here][file_ptr],"%s^n",Resource)



	}
}
