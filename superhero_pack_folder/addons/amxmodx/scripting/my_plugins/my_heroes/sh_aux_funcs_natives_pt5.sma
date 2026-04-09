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

	player_model_hero_id,
	player_model_ct_file_path[STRING_SIZE],
	player_model_t_file_path[STRING_SIZE],
	player_model_morph_string[STRING_SIZE],
	player_model_morph_message[SH_HUD_MSG_BUFF_SIZE],
	player_model_unmorph_message[SH_HUD_MSG_BUFF_SIZE]

}
new curr_num_models_logged=0
new gPlayersCurrHeroModelID[SH_MAXSLOTS+1]
new sh_array_of_player_model_structs[SH_MAX_PLAYER_MODELS+1][player_model_array_struct]
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("sh_choose_model", "sh_choose_model",ADMIN_ALL,"Choose a model. The only parameter is the model_id as shown in ^"sh_print_models^"")
	register_clcmd("sh_print_models", "sh_print_models",ADMIN_ALL,"Print all superhero models available to you")
	
	prepare_shero_aux_lib_pt5()
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


//----------------------------------------------------------------------------------------------
public sh_player_morph_task(id,hero_model_id)
{
	if ( (gPlayersCurrHeroModelID[id]>=0 )|| !is_user_alive(id)) return

	gPlayersCurrHeroModelID[id]=hero_model_id
	
	cs_set_user_model(id, sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_morph_string])

	// Message
	if(strlen(sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_morph_message])){
			superhero_protected_hud_message(superhero_hud_msg_sync,id, "%s",
						sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_morph_message])
	}
	
}
//----------------------------------------------------------------------------------------------
public sh_player_unmorph_task(id)
{
	if ( !is_user_connected(id) ) return
	if ( (gPlayersCurrHeroModelID[id]>=0 )) {
		// Message
		if(strlen(sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_unmorph_message])){
			superhero_protected_hud_message(superhero_hud_msg_sync,id, "%s",
						sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_unmorph_message])
		}
		cs_reset_user_model(id)
		gPlayersCurrHeroModelID[id]=-1

	}
}
public _sh_register_superheromod_model(iPlugins, iParams){

	if(curr_num_models_logged>=SH_MAX_PLAYER_MODELS){

		return -1
	}
	new hero_id= get_param(1)

	if (hero_id<0 || hero_id > SH_MAXHEROS){

		return -1
	}
	new result=curr_num_models_logged
	sh_array_of_player_model_structs[result][player_model_hero_id]=hero_id
	get_string(2,sh_array_of_player_model_structs[result][player_model_ct_file_path],STRING_SIZE-1)
	get_string(3,sh_array_of_player_model_structs[result][player_model_t_file_path],STRING_SIZE-1)
	get_string(4,sh_array_of_player_model_structs[result][player_model_morph_string],STRING_SIZE-1)
	get_string(5,sh_array_of_player_model_structs[result][player_model_morph_message],SH_HUD_MSG_BUFF_SIZE-1)
	get_string(6,sh_array_of_player_model_structs[result][player_model_unmorph_message],SH_HUD_MSG_BUFF_SIZE-1)


	engfunc(EngFunc_PrecacheModel,sh_array_of_player_model_structs[result][player_model_ct_file_path])
	server_print("Model load attempted: %s",sh_array_of_player_model_structs[result][player_model_ct_file_path])
	engfunc(EngFunc_PrecacheModel,sh_array_of_player_model_structs[result][player_model_t_file_path])
	server_print("Model load attempted: %s",sh_array_of_player_model_structs[result][player_model_t_file_path])
	curr_num_models_logged++
	
	return result
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

	server_print("Someone tried to choose a model!")
	new the_argc=read_argc()
	if (the_argc == 2)
	{
		new arg[128]
		new hero_model_id
		read_argv(1,arg,charsmax(arg))
		hero_model_id = str_to_num(arg)
		sh_player_unmorph_task(id)
		if((hero_model_id>=0)&&(hero_model_id<SH_MAX_PLAYER_MODELS)){

			static the_hero_id;
			the_hero_id=sh_array_of_player_model_structs[hero_model_id][player_model_hero_id]
			if(sh_user_has_hero(id,the_hero_id)){
				sh_player_morph_task(id,hero_model_id)
			}
			return PLUGIN_HANDLED
		}
		
	}
	else{
		console_print(id,"Wrong number of arguments? argument count: %d^nNeeded argument count: %d^n",the_argc,2)

	}
	return PLUGIN_HANDLED
}

public sh_print_models(id, level, cid)
{


	server_print("Someone tried to print all models!")
	if (!cmd_access(id, level, cid, 0)){
		return PLUGIN_HANDLED
	}
	console_print(id,"Available models for you:^n")
	for(new i=0;i<curr_num_models_logged;i++){
		
		
		
		
		new inner_hero_id=sh_array_of_player_model_structs[i][player_model_hero_id]
		
		if(sh_user_has_hero(id,inner_hero_id)){
			
			console_print(id,"Model of id %d:^n",i)
			
			static hero_name[MAX_HERO_NAME_LENGTH]
			
			sh_get_hero_name_from_id(inner_hero_id,hero_name)

			console_print(id," - - hero name: %s^n",hero_name)
			console_print(id," - - Model name: %s^n^n^n^n",sh_array_of_player_model_structs[i][player_model_morph_string])
		}
		

	}
	

	return PLUGIN_HANDLED
}