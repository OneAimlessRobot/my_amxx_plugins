#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include <fakemeta_util>
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt5: hero player model morph registering"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


#define SH_MAX_PLAYER_MODELS 10

enum player_model_array_struct{

	hero_id,
	player_model_ct_file_path[STRING_SIZE],
	player_model_t_file_path[STRING_SIZE],
	player_model_morph_string[STRING_SIZE],
	player_model_morph_message[SH_HUD_MSG_BUFF_SIZE],
	player_model_unmorph_message[SH_HUD_MSG_BUFF_SIZE]

}
new curr_num_models_logged=0
new g_morphed[SH_MAXSLOTS+1]
new gPlayersCurrModelHeroID[SH_MAXSLOTS+1]
new sh_array_of_player_model_structs[SH_MAX_PLAYER_MODELS+1][player_model_array_struct]
new SH_MORPH_TASKID
new SH_UNMORPH_TASKID
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("sh_choose_model", "sh_choose_model",ADMIN_ALL)
	register_clcmd("sh_print_models", "sh_print_models",ADMIN_ALL)
	
	prepare_shero_aux_lib_pt5()
	SH_MORPH_TASKID=allocate_typed_task_id(player_task)
	SH_UNMORPH_TASKID=allocate_typed_task_id(player_task)
	init_hud_syncs()
    
	
}			
public plugin_natives(){


	register_native("prepare_shero_aux_lib_pt5","_prepare_shero_aux_lib_pt5",0);
	register_native("sh_reset_player_hero_player_model","_sh_reset_player_hero_player_model",0);
	register_native("sh_register_superheromod_model","_sh_register_superheromod_model",0)
}
// TODO: Finish this module
/*native sh_register_superheromod_model(gHeroID,
                        const filename_ct[STRING_SIZE],
                        const filename_t[STRING_SIZE],
                        const morph_string[STRING_SIZE],
                        const hud_msg_morph[SH_HUD_MSG_BUFF_SIZE],
                        const hud_msg_unmorph[SH_HUD_MSG_BUFF_SIZE])
						*/
public _sh_register_superheromod_model(iPlugins, iParams){

	if(curr_num_models_logged>=SH_MAX_PLAYER_MODELS){

		return -1
	}
	new hero_id= get_param(1)

	new filename_ct[STRING_SIZE],
	new filename_t[STRING_SIZE],
	new morph_string[STRING_SIZE],
	new hud_msg_morph[SH_HUD_MSG_BUFF_SIZE],
	new hud_msg_unmorph[SH_HUD_MSG_BUFF_SIZE]
	
	
	return curr_models_logged
}
public _sh_reset_player_hero_player_model(iPlugins, iParams){
	new id= get_param(1)
	if(!is_user_connected(id)){

		return 0
	}
	
	return 1
}

public _prepare_shero_aux_lib_pt5(iPlugins, iParams){
	
	server_print("Shero lib pt5 innited!^n")
}

public sh_choose_model(id, level, cid)
{
	if(!is_user_connected(id)){

		return PLUGIN_HANDLED
	}

	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	new arg[128]
	new model_hero_id
	if (read_argc() == 1)
	{
		read_argv(1,arg,charsmax(arg))
		model_hero_id = str_to_num(arg)
		gPlayersCurrModelHeroID[id]=model_hero_id
	}
	return PLUGIN_HANDLED
}

public sh_print_models(id, level, cid)
{
	if(!is_user_connected(id)){

		return PLUGIN_HANDLED
	}

	if (!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED
	

	return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------
public sh_player_morph_task(id)
{
	id-=SH_MORPH_TASKID
	if ( g_morphed[id] || !is_user_alive(id)||!sh_user_has_hero(id,gPlayersCurrModelHeroID[id])) return

	cs_set_user_model(id, sh_array_of_player_model_structs[gPlayersCurrModelHeroID[id]][player_model_morph_string])

	// Message
	superhero_protected_hud_message(superhero_hud_msg_sync,id, "%s",sh_array_of_player_model_structs[gPlayersCurrModelHeroID[id]][player_model_morph_message])

	g_morphed[id] = true
	
}
//----------------------------------------------------------------------------------------------
public sh_player_unmorph_task(id)
{
	id-=SH_UNMORPH_TASKID
	if ( !is_user_connected(id) ) return
	if ( g_morphed[id] ) {
		// Message
		superhero_protected_hud_message(superhero_hud_msg_sync,id, "%s",sh_array_of_player_model_structs[gPlayersCurrModelHeroID[id]][player_model_unmorph_message])

		cs_reset_user_model(id)

		g_morphed[id] = false

	}
}