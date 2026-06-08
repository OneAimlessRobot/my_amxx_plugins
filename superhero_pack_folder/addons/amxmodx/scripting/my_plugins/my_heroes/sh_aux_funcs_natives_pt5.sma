#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include <amxmisc>
#include <reapi>
#include <newmenus>
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt5.inc"


#define PLUGIN "Superhero aux natives pt5: hero player/weapon  model morph registering"
#define VERSION "1.0.0"
#define GLOBAL_GLOW_TASK_LOOP_PERIOD 1.0
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


#define ITEM_STRING_SIZE 50

#define SH_MAX_PLAYER_MODELS 30

#define SH_MAX_WPN_MODELS_PER_WPN 30

#define SAY_CMD_MDOELS "say /skins"

#define MODEL_MENU_NAME "Skins menu"

#define PLAYER_MODEL_MENU_NAME "Player skins menu"

#define CON_PLAYER_MODELS_MENU_CMD "sh_player_model_menu"


#define WEAPON_MODEL_MENU_NAME "Weapon model menu"

#define WEAPON_MODEL_SUBMENU_NAME "Weapon skins sub menu"

#define CON_WEAPON_MODELS_MENU_CMD "sh_weapon_model_menu"


new GLOW_TASKID


enum player_model_array_struct{

	player_model_hero_id,
	player_model_ct_file_path[STRING_SIZE],
	player_model_t_file_path[STRING_SIZE],
	player_model_morph_string[STRING_SIZE],
	player_model_morph_message[SH_HUD_MSG_BUFF_SIZE],
	player_model_unmorph_message[SH_HUD_MSG_BUFF_SIZE],
	player_model_custom_morph_sound_sample[STRING_SIZE]

}
new curr_num_models_logged=0
new gPlayersCurrHeroModelID[SH_MAXSLOTS+1]={-1, ...}
new sh_array_of_player_model_structs[SH_MAX_PLAYER_MODELS+1][player_model_array_struct]


enum wpn_model_array_struct{

	wpn_model_hero_id,
	wpn_model_v_model_string[STRING_SIZE],
	wpn_model_p_model_string[STRING_SIZE],
	bool:ignore_v_model_if_empty,
	bool:ignore_p_model_if_empty

}
/**

first macro param: wpn_id
second macro param: in-weapon model id

*/
#define strlen_of_v_model(%1,%2) (strlen(sh_array_of_wpn_model_structs[%1][%2][wpn_model_v_model_string]))

#define strlen_of_p_model(%1,%2) (strlen(sh_array_of_wpn_model_structs[%1][%2][wpn_model_p_model_string]))

new curr_num_models_logged_on_wpn[CSW_LAST_WEAPON+1] = {0, ...}
new gPlayersCurrHeroWpnModelID[SH_MAXSLOTS+1][CSW_LAST_WEAPON+1]
//num weapons | models per weapon | struct
new sh_array_of_wpn_model_structs[CSW_LAST_WEAPON+1][SH_MAX_WPN_MODELS_PER_WPN+1][wpn_model_array_struct]


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);


	register_clcmd(CON_PLAYER_MODELS_MENU_CMD, "sh_player_model_menu", ADMIN_ALL, PLAYER_MODEL_MENU_NAME)

	register_clcmd(CON_WEAPON_MODELS_MENU_CMD, "sh_weapon_model_menu", ADMIN_ALL, WEAPON_MODEL_MENU_NAME)


	register_clcmd(SAY_CMD_MDOELS, "say_for_tha_squines_squiline_squiline",  ADMIN_ALL, "All skins menu")

	register_event("CurWeapon", "weaponChange", "be", "1=1")

	GLOW_TASKID=allocate_typed_task_id(generic_task)

	prepare_shero_aux_lib_pt5()
	init_hud_syncs()

	set_task(GLOBAL_GLOW_TASK_LOOP_PERIOD,"global_glow_task",GLOW_TASKID,_,_,"b")
    
	
}

public plugin_precache(){
	
	engfunc(EngFunc_PrecacheSound, default_morph_state_sound)
}
public say_for_tha_squines_squiline_squiline(id,level,cid){

    if (!cmd_access(id,level,cid,1))
        return PLUGIN_HANDLED

    if(!is_user_connected(id)){
        return PLUGIN_HANDLED
    }
	
    show_skin_menus_func(id)

    return PLUGIN_HANDLED
}

show_skin_menus_func(id){

	new gMenuID = menu_create(MODEL_MENU_NAME, "show_skin_menus_handler")
	
	static curr_menu_line_string[128],
			item_string[1]
		
	item_string[0] = 0
	

	formatex(curr_menu_line_string,charsmax(curr_menu_line_string),
						"%s",
						PLAYER_MODEL_MENU_NAME)

	menu_additem(gMenuID,curr_menu_line_string,item_string)
	
	item_string[0] = 1
	

	formatex(curr_menu_line_string,charsmax(curr_menu_line_string),
						"%s",
						WEAPON_MODEL_MENU_NAME)

	menu_additem(gMenuID,curr_menu_line_string,item_string)
	
	menu_display(id,gMenuID)

}
public show_skin_menus_handler(id, menu, item){


	if(item>=0){
		
		static item_string[1],
		menu_to_put = 0
		menu_item_getinfo(menu, item, _,item_string,sizeof(item_string))
		menu_to_put = item_string[0]
		

		menu_to_put ? (show_weapon_model_menu_func(id)):(show_player_model_menu_func(id))
		
	}


}


public sh_weapon_model_menu(id,level,cid){

    if (!cmd_access(id,level,cid,1))
        return PLUGIN_HANDLED

    if(!is_user_connected(id)){
        return PLUGIN_HANDLED
    }
	
    show_weapon_model_menu_func(id)

    return PLUGIN_HANDLED
}

show_weapon_model_menu_func(id){

	new gMenuID = menu_create(WEAPON_MODEL_MENU_NAME, "show_weapon_model_weapon_menu_handler")
	
	static curr_menu_line_string[128],
			item_string[1]
		
	new bool:should_show_menu = false
	for(new wpn_id = 1 ;wpn_id<= CSW_LAST_WEAPON;wpn_id++){

		if(is_weaponid_valid(wpn_id)&&((GUNS_BIT_SUM|(1<<CSW_KNIFE)) & (1<<wpn_id))){
			
			if(user_has_weapon(id,wpn_id)){
				
				new i = 0;
				for(;i<curr_num_models_logged_on_wpn[wpn_id];i++){
							
							
					new inner_hero_id=sh_array_of_wpn_model_structs[wpn_id][i][wpn_model_hero_id]
					
					if(sh_get_user_has_hero(id,inner_hero_id)){
				
						break;
					}
				}
				
				if(i >= curr_num_models_logged_on_wpn[wpn_id]){
					
					continue;

				}
				else if(!should_show_menu){

					should_show_menu = true
				}

				item_string[0] = wpn_id
				

				formatex(curr_menu_line_string,charsmax(curr_menu_line_string),
									"%s",
									wlt_get_fruity_name(my_weapon_ids:wpn_id))

				menu_additem(gMenuID,curr_menu_line_string,item_string)
			}
		}
	}


	should_show_menu?menu_display(id,gMenuID):menu_destroy(gMenuID)

}
show_weapon_model_submenu_func(id,wpn_id){

	new gMenuID = menu_create(WEAPON_MODEL_SUBMENU_NAME, "show_weapon_model_menu_handler")
	static curr_menu_line_string[ITEM_STRING_SIZE],
			hero_name[MAX_HERO_NAME_LENGTH],
							item_string[2]

	item_string[0] = wpn_id
	item_string[1] = SH_MAX_WPN_MODELS_PER_WPN
	
	formatex(curr_menu_line_string, charsmax(curr_menu_line_string),
			"Remove weapon model for %s",wlt_get_fruity_name(my_weapon_ids:wpn_id))

	menu_additem(gMenuID, curr_menu_line_string, item_string)
	
	for(new i=0;i<curr_num_models_logged_on_wpn[wpn_id];i++){
				
				
		new inner_hero_id=sh_array_of_wpn_model_structs[wpn_id][i][wpn_model_hero_id]
		
		if(sh_get_user_has_hero(id,inner_hero_id)){
			
			
			sh_get_hero_name_from_id(inner_hero_id,hero_name)

			formatex(curr_menu_line_string,charsmax(curr_menu_line_string),
								"%s",
								hero_name)
			
			item_string[0] = wpn_id
			item_string[1] = i

			menu_additem(gMenuID,curr_menu_line_string,item_string)
		}
	}


	menu_display(id,gMenuID)

}

public sh_player_model_menu(id,level,cid){

    if (!cmd_access(id,level,cid,1))
        return PLUGIN_HANDLED

    if(!is_user_connected(id)){
        return PLUGIN_HANDLED
    }
	
    show_player_model_menu_func(id)

    return PLUGIN_HANDLED
}

show_player_model_menu_func(id){

	new gMenuID = menu_create(PLAYER_MODEL_MENU_NAME, "player_model_menu_handler")
	static hero_name[MAX_HERO_NAME_LENGTH],
				curr_menu_line_string[ITEM_STRING_SIZE],
				item_string[1]

	item_string[0] = SH_MAX_PLAYER_MODELS
	
	menu_additem(gMenuID,"Remove player model",item_string)

	for( new i = 0; ( i < curr_num_models_logged ) ; i++ ){
		
		
		new inner_hero_id=sh_array_of_player_model_structs[i][player_model_hero_id]
		
		if(sh_get_user_has_hero(id,inner_hero_id)){
			
			
			sh_get_hero_name_from_id(inner_hero_id,hero_name)
			
			formatex(curr_menu_line_string,charsmax(curr_menu_line_string),
								"%s",
								hero_name)
			item_string[0] = i
			
			menu_additem(gMenuID,curr_menu_line_string,item_string)


		}
	}


	menu_display(id,gMenuID)

}


pick_player_model_from_menu_func(id,hero_model_id){

		new inner_hero_id=sh_array_of_player_model_structs[hero_model_id][player_model_hero_id]
		
		if(sh_get_user_has_hero(id,inner_hero_id)){
			
			player_morph_wrapper(id,hero_model_id)

		}

}

/**
 * Menu and menu item status codes
 */
/*
#define MENU_TIMEOUT    -4
#define MENU_EXIT       -3
#define MENU_BACK       -2
#define MENU_MORE       -1
#define ITEM_IGNORE     0
#define ITEM_ENABLED    1
#define ITEM_DISABLED   2*/

public player_model_menu_handler(id, menu, item)
{
	
	if(item>=0){
	
		static item_string[1],
		hero_model_id = 0
		menu_item_getinfo(menu, item, _,item_string,sizeof(item_string))
		hero_model_id = item_string[0]

		(hero_model_id>=SH_MAX_PLAYER_MODELS)?(sh_player_unmorph_task(id))
									:
				(pick_player_model_from_menu_func(id,hero_model_id))
	
	}

	menu_destroy(menu)

	return PLUGIN_HANDLED
}
public show_weapon_model_weapon_menu_handler(id, menu, item)
{

	if(item>=0){
		
		static item_string[1],
		weapon_id = 0
		menu_item_getinfo(menu, item, _,item_string,sizeof(item_string))
		weapon_id = item_string[0]
		

		show_weapon_model_submenu_func(id, weapon_id)
	}
	menu_destroy(menu)

	return PLUGIN_HANDLED
}
public show_weapon_model_menu_handler(id, menu, item)
{

	if(item>=0){
		
		static item_string[2],
		weapon_id = 0,
		wpn_model_id = 0
	
	
		menu_item_getinfo(menu, item, _,item_string,sizeof(item_string))
		weapon_id = item_string[0]
		wpn_model_id = item_string[1]

		(wpn_model_id>=SH_MAX_WPN_MODELS_PER_WPN)?(gPlayersCurrHeroWpnModelID[id][weapon_id]=-1)
									:
				weapon_model_pick_wrapper(id,weapon_id,wpn_model_id)
	}

	menu_destroy(menu)

	return PLUGIN_HANDLED
}

player_morph_wrapper(id,hero_model_id){
	sh_player_unmorph_task(id)
	if((hero_model_id>=0)&&(hero_model_id<SH_MAX_PLAYER_MODELS)){

		static the_hero_id;
		the_hero_id=sh_array_of_player_model_structs[hero_model_id][player_model_hero_id]
		if(sh_get_user_has_hero(id,the_hero_id)){
			sh_player_morph_task(id,hero_model_id)
		}
	}
	return PLUGIN_HANDLED
}

public weaponChange(id)
{
	if (!sh_is_active()) return PLUGIN_CONTINUE

	// If user has a shield do not change model, since we don't have one with a shield
	if ( cs_get_user_shield(id) ) return PLUGIN_CONTINUE

	new wpnid = read_data(2)

	if(gPlayersCurrHeroWpnModelID[id][wpnid]< 0) return PLUGIN_CONTINUE
	
	new wpn_id_of_player=gPlayersCurrHeroWpnModelID[id][wpnid]
	
	new the_hero_id=sh_array_of_wpn_model_structs[wpnid][wpn_id_of_player][wpn_model_hero_id]

	if(!sh_get_user_has_hero(id,the_hero_id)){

		gPlayersCurrHeroWpnModelID[id][wpnid]=-1
		return PLUGIN_CONTINUE

	}
	
	if(!(strlen_of_v_model(wpnid,wpn_id_of_player)<=0)||!sh_array_of_wpn_model_structs[wpnid][wpn_id_of_player][ignore_v_model_if_empty]){
		
		entity_set_string(id, EV_SZ_viewmodel,
		sh_array_of_wpn_model_structs[wpnid][wpn_id_of_player][wpn_model_v_model_string])
	}
		
	if(!(strlen_of_p_model(wpnid,wpn_id_of_player)<=0)||!sh_array_of_wpn_model_structs[wpnid][wpn_id_of_player][ignore_p_model_if_empty]){
		entity_set_string(id, EV_SZ_weaponmodel,
		sh_array_of_wpn_model_structs[wpnid][wpn_id_of_player][wpn_model_p_model_string])
	}
	return PLUGIN_CONTINUE

}

public sh_hero_init(id,heroID, sh_init_mode:mode){

	if(!is_user_connected(id)) return

	if(mode==SH_HERO_DROP){
		
		if((gPlayersCurrHeroModelID[id]>=0)){
			if(sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_hero_id]==heroID){
				
				sh_player_unmorph_task(id,1)

			}
		}
		for(new wpnid=1;wpnid<= CSW_LAST_WEAPON;wpnid++){

			if(gPlayersCurrHeroWpnModelID[id][wpnid]>= 0){
				new wpn_model_id=gPlayersCurrHeroWpnModelID[id][wpnid]

				if(sh_array_of_wpn_model_structs[wpnid][wpn_model_id][wpn_model_hero_id]==heroID){
					gPlayersCurrHeroWpnModelID[id][wpnid]=-1
				}
				
			}
		}
	}
}
public plugin_natives(){

	register_native("prepare_shero_aux_lib_pt5","_prepare_shero_aux_lib_pt5");
	register_native("sh_register_superheromod_model","_sh_register_superheromod_model")
	register_native("sh_register_superheromod_weapon_model","_sh_register_superheromod_weapon_model")
}

play_morph_sound(id){

	if(!is_user_connected(id)) return

	emit_sound(id,CHAN_VOICE,
				
				sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_custom_morph_sound_sample],
				
				VOL_NORM,ATTN_NORM,SND_STOP,PITCH_NORM)
				
	
	emit_sound(id,CHAN_VOICE,
				
				sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_custom_morph_sound_sample],
				
				VOL_NORM,ATTN_NORM,0,PITCH_NORM)
}
//----------------------------------------------------------------------------------------------
sh_player_morph_task(id,hero_model_id)
{
	if ( !is_user_alive(id)) return

	gPlayersCurrHeroModelID[id]=hero_model_id

	
	cs_set_user_model(id, sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_morph_string])
	play_morph_sound(id)
	// Message
	if(strlen(sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_morph_message])){
			superhero_protected_hud_message(superhero_hud_msg_sync,id, "%s",
						sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_morph_message])
	}
	
}
//----------------------------------------------------------------------------------------------
sh_player_unmorph_task(id,take_away_model=1)
{
	if ( !is_user_connected(id) ) return
	if ( (gPlayersCurrHeroModelID[id]>=0 )) {
		// Message
		if(strlen(sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_unmorph_message])){
			superhero_protected_hud_message(superhero_hud_msg_sync,id, "%s",
						sh_array_of_player_model_structs[gPlayersCurrHeroModelID[id]][player_model_unmorph_message])
		}
		cs_reset_user_model(id)
		if(sh_get_player_cloak_pct(id)<=0){

			sh_set_rendering(id)
		}
		play_morph_sound(id)
		gPlayersCurrHeroModelID[id]=(take_away_model?-1:gPlayersCurrHeroModelID[id])

	}
}
public _sh_register_superheromod_model(iPlugins, iParams){

	if(curr_num_models_logged>=SH_MAX_PLAYER_MODELS){

		return -1
	}
	new hero_id= get_param(1)

	if (hero_id<0 || hero_id >=SH_MAXHEROS){

		return -1
	}
	new result=curr_num_models_logged
	sh_array_of_player_model_structs[result][player_model_hero_id]=hero_id
	get_string(2,sh_array_of_player_model_structs[result][player_model_ct_file_path],STRING_SIZE-1)
	get_string(3,sh_array_of_player_model_structs[result][player_model_t_file_path],STRING_SIZE-1)
	get_string(4,sh_array_of_player_model_structs[result][player_model_morph_string],STRING_SIZE-1)
	get_string(5,sh_array_of_player_model_structs[result][player_model_morph_message],SH_HUD_MSG_BUFF_SIZE-1)
	get_string(6,sh_array_of_player_model_structs[result][player_model_unmorph_message],SH_HUD_MSG_BUFF_SIZE-1)
	get_string(7,sh_array_of_player_model_structs[result][player_model_custom_morph_sound_sample],STRING_SIZE-1)

	/*server_print("Index: %d^nCT Player model load attempted: %s",result,
								sh_array_of_player_model_structs[result][player_model_ct_file_path])
	*/
	engfunc(EngFunc_PrecacheGeneric,sh_array_of_player_model_structs[result][player_model_ct_file_path])
	/*
	server_print("Index: %d^nT Player model load attempted: %s",result,
								sh_array_of_player_model_structs[result][player_model_t_file_path])
	*/
	engfunc(EngFunc_PrecacheGeneric,sh_array_of_player_model_structs[result][player_model_t_file_path])
	
	/*
	server_print("Index: %d^nPlayer morph sound load attempted: %s",result,
								sh_array_of_player_model_structs[result][player_model_custom_morph_sound_sample])
	*/
	engfunc(EngFunc_PrecacheSound,sh_array_of_player_model_structs[result][player_model_custom_morph_sound_sample])
	
	curr_num_models_logged++
	
	return result
}

public _sh_register_superheromod_weapon_model(iPlugins, iParams){

	new hero_id= get_param(1)

	if (hero_id<0 || hero_id >=SH_MAXHEROS){

		return -1
	}

	new wpn_id=get_param(2)

	if (!is_weaponid_valid(wpn_id)){

		return -1
	}

	if(curr_num_models_logged_on_wpn[wpn_id]>=SH_MAX_WPN_MODELS_PER_WPN){

		return -1
	}

	new result=curr_num_models_logged_on_wpn[wpn_id]

	sh_array_of_wpn_model_structs[wpn_id][result][ignore_v_model_if_empty]=bool:get_param(5)
	sh_array_of_wpn_model_structs[wpn_id][result][ignore_p_model_if_empty]=bool:get_param(6)
	
	sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_hero_id]=hero_id
	get_string(3,sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_v_model_string],STRING_SIZE-1)
	
	if(strlen_of_v_model(wpn_id,result)<=0){

		/*
		server_print("Warning: weapon model number %d from weapon %s (weapon id = %d):^nLoad attempted with empty filename on v model!^nFirst person model must be present in server!^nFirst person model will not be present...^n",
					result,
					wpn_name,
					wpn_id,
					sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_v_model_string])
		*/
	}
	else{
		
		/*
		server_print("Note: Weapon first person model load attempted: %s^nWeapon model number %d from weapon %s (weapon id = %d):^nLoaded!",
					sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_v_model_string],
					result,
					wpn_name,
					wpn_id)
		*/
		engfunc(EngFunc_PrecacheModel,sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_v_model_string])
	
	}
	get_string(4,sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_p_model_string],STRING_SIZE-1)
	

	if(strlen_of_p_model(wpn_id,result)<=0){

		/*
		server_print("Warning: weapon model number %d from weapon %s (weapon id = %d):^nLoad attempted with empty filename on p model!!^nWorld model will not be present...^n",
					result,
					wpn_name,
					wpn_id,
					sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_p_model_string])
		*/
	}
	else{
		/*
		server_print("Note: Weapon world model load attempted: %s^nWeapon model number %d from weapon %s (weapon id = %d):^nLoaded!",
					sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_p_model_string],
					result,
					wpn_name,
					wpn_id)
		*/
		engfunc(EngFunc_PrecacheModel,sh_array_of_wpn_model_structs[wpn_id][result][wpn_model_p_model_string])
		
	}
	
	curr_num_models_logged_on_wpn[wpn_id]++
	
	return result
}

public _prepare_shero_aux_lib_pt5(iPlugins, iParams){
	
	server_print("%s innited!^n",LIBRARY_NAME)
}

weapon_model_pick_wrapper(id, wpn_id, wpn_model_id){

	gPlayersCurrHeroWpnModelID[id][wpn_id]=-1

	if(!is_weaponid_valid(wpn_id)){
		console_print(id,"Invalid weapon id %d!^nInput a wpn_id from 1 to %d!^n",
						wpn_id,
						CSW_LAST_WEAPON)
	}
	else if((wpn_model_id>=0)&&(wpn_model_id<curr_num_models_logged_on_wpn[wpn_id])){

		static the_hero_id;
		the_hero_id=sh_array_of_wpn_model_structs[wpn_id][wpn_model_id][wpn_model_hero_id]
		if(sh_get_user_has_hero(id,the_hero_id)){
			gPlayersCurrHeroWpnModelID[id][wpn_id]=wpn_model_id
		}
	}
}
public sh_client_death(id)
{
	if(!is_user_connected(id)) return

	sh_player_unmorph_task(id,0)

}
public client_connect(id){

	arrayset(gPlayersCurrHeroWpnModelID[id],-1,sizeof gPlayersCurrHeroWpnModelID[])

}
public sh_client_spawn(id){

	if(!is_user_connected(id)) return

	if(gPlayersCurrHeroModelID[id]>=0){

			sh_player_morph_task(id,gPlayersCurrHeroModelID[id])

	}

}
//assumes player is connected and all that
//to be executed in the task!
teamglow_player(id){

	if(sh_get_player_cloak_pct(id)>0) return 

	static CsTeams:curr_player_team

	curr_player_team=cs_get_user_team(id)

	switch(curr_player_team){
		
		case CS_TEAM_T:{

			sh_set_rendering(id, 255, 0, 0, 50,kRenderFxGlowShell);
		}
		case CS_TEAM_CT:{

			sh_set_rendering(id, 0, 0, 255, 50,kRenderFxGlowShell);

		}



	}
}
public global_glow_task(task_id){

	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]

		if(gPlayersCurrHeroModelID[id]<0) continue
		

		teamglow_player(id)



	}


}