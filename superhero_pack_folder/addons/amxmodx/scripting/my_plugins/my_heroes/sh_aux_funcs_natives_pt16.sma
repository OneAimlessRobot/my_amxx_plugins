#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_COLORS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt16.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"


#define PLUGIN "SH_AuxFun16: invis mngr"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new const DEBUG = 0

/*


enum
{
	kRenderNormal = 0, 
	kRenderTransColor,     
	kRenderTransTexture,  
	kRenderGlow,       
	kRenderTransAlpha,     
	kRenderTransAdd,  
};

render mode names

*/

new const render_mode_names[kRenderTransAdd+1][128] = {
	"kRenderNormal",
	"kRenderTransColor",
	"kRenderTransTexture",
	"kRenderGlow",
	"kRenderTransAlpha",
	"kRenderTransAdd"

}
/*



enum rendering_priority_consts{

    PRIO_RENDER_NONE = 0,
  PRIO_RENDER_PASSIVE = 1,
  PRIO_RENDER_INFORMATIVE = 2,
  PRIO_RENDER_EFFECT_ACTIVE = 3,
  PRIO_RENDER_POWERUP = 4,
  PRIO_RENDER_GODMODE= 5,
  PRIO_RENDER_INVISIBILITY = 6,
  PRIO_RENDER_DELETE_INVISIBILITY = 7,
  PRIO_RENDER_DELETE_ASLEEP = 8,
  PRIO_RENDER_MAX_PRIORITY = 9


}
render mode names

*/

new const render_priority_names[PRIO_RENDER_MAX_PRIORITY][128] = {
	"PRIO_RENDER_NONE",
	"PRIO_RENDER_PASSIVE",
	"PRIO_RENDER_INFORMATIVE",
 	"PRIO_RENDER_EFFECT_ACTIVE",
  	"PRIO_RENDER_POWERUP",
  	"PRIO_RENDER_GODMODE",
  	"PRIO_RENDER_INVISIBILITY",
  	"PRIO_RENDER_DELETE_INVISIBILITY",
  	"PRIO_RENDER_DELETE_ASLEEP"
}

new DEBUG_HUD_TASKID = -1


new DEBUG_HUD_HUD_SYNC_OBJ = -1

#define DEBUG_HUD_TASK_PERIOD 0.2


enum rendering_priority_struct{
	rendering_priority_consts:curr_priority,
	curr_color[3],
	curr_alpha,
	curr_pct,
	curr_render_mode,
	curr_hero_id,
	Array:rendering_attempts_stack_obj,
	player_hud_buffer_array[1024],
	player_renderer_entity

}

#define PLAYER_RENDER_MANAGER_ENTITY_CLASSNAME "sh_thrashbrat_player_renderer_manager"

new player_rendering_priority_structs_array[server_slot_idx][rendering_priority_struct]


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);


	if(DEBUG){

		DEBUG_HUD_HUD_SYNC_OBJ = CreateHudSyncObj()

		DEBUG_HUD_TASKID=allocate_typed_task_id(generic_task)
		
		set_task(DEBUG_HUD_TASK_PERIOD,"debug_glow_hud_taskid",DEBUG_HUD_TASKID,_,_,"b")

		
		for( new server_slot_idx:i = enum_one; i< server_slot_idx;i++){
			player_rendering_priority_structs_array[i][rendering_attempts_stack_obj] = ArrayCreate()
		}

	}
	for( new server_slot_idx:i = enum_one; i< server_slot_idx;i++){
		static the_player_ent_here;
		the_player_ent_here = create_entity("info_target")
		if(!the_player_ent_here){

			the_player_ent_here = -1
		}
		else{
			if(DEBUG){

				server_print("Player render manager entity created for slot %d!^n",_:i)
			}
			entity_set_string(the_player_ent_here, EV_SZ_classname,PLAYER_RENDER_MANAGER_ENTITY_CLASSNAME)
			entity_set_int(the_player_ent_here,EV_INT_iuser4, _:i)
		
		}

		player_rendering_priority_structs_array[i][player_renderer_entity] = the_player_ent_here

	}

	register_think(PLAYER_RENDER_MANAGER_ENTITY_CLASSNAME, "render_removal_think")

}
public plugin_cfg(){


	server_print("%s innited!^n",PLUGIN)
	
}
public plugin_end() {

	if(DEBUG){

		for( new server_slot_idx:i = server_slot_idx:0; i< server_slot_idx;i++){
			ArrayDestroy(player_rendering_priority_structs_array[i][rendering_attempts_stack_obj])
		}
	
	}

}
public plugin_natives(){

	register_native("set_render_with_color_const","_set_render_with_color_const")
	register_native("aura","_aura");
	register_native("remove_glow_user","_remove_glow_user")

}
clear_client_state(server_slot_idx:id){


	player_rendering_priority_structs_array[id][curr_pct] = 0
	player_rendering_priority_structs_array[id][curr_priority] = enum_zero

}
public sh_client_spawn(id, bool:newRound){

	clear_client_state(server_slot_idx:id)
	if(!newRound){

		set_user_rendering(id)
	}
}
public client_disconnected(id){

	clear_client_state(server_slot_idx:id)


}
aura_aux(id,const color[3]={255,255,255},life=3,decay=1){
	
	if ( !is_user_connected(id) ) return

	static origin[3]


	get_user_origin(id, origin, 1)


	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(15)
	write_byte(color[0])			// r, g, b
	write_byte(color[1])		// r, g, b
	write_byte(color[2])			// r, g, b
	write_byte(life)			// life
	write_byte(decay)			// decay
	message_end()

}
public _aura(iPlugins, iParams){
	new id= get_param(1);
	static color[3]
	get_array(2,color,3)
	new life=get_param(3)
	new decay= get_param(4)
	
	aura_aux(id,color,life,decay)

}
public _set_render_with_color_const(iPlugins,iParams){
	new id=get_param(1)

	if(!is_valid_ent(id)){
		return 
	}

	new sh_custom_color:the_color_const=sh_custom_color:get_param(2),
		glow_on_user=get_param(3),
		alpha=get_param(4),
		the_hud_alpha=get_param(5),
		glow_user_hud=get_param(6),
		is_sleep=get_param(7),
		Float:the_glow_timer=get_param_f(8),
		set_aura_glow=get_param(9),
		rendering_fx=get_param(10),
		rendering_mode=get_param(11),
		rendering_priority_consts:the_priority = rendering_priority_consts:get_param(12),
		heroID = get_param(13)

	static bool:is_valid_client;
	
	is_valid_client = bool:is_user_alive(id);
	
	if(!is_valid_client){

		return
	}
	/*
	if(DEBUG){
		sh_chat_message(id,heroID,"We are about to try to change glow! The target glow type is: %s",render_priority_names[the_priority])
	}*/

	
	if(glow_user_hud){
		
		if(player_rendering_priority_structs_array[server_slot_idx:id][curr_priority]<=the_priority){
			if((sh_get_id_bit(id,SH_IS_SLEEPING)&&is_sleep)||!sh_get_id_bit(id,SH_IS_SLEEPING)){

				sh_screen_fade(id, 0.1, 0.9,
					LineColors[the_color_const][0],
					LineColors[the_color_const][1],
					LineColors[the_color_const][2],
					(the_hud_alpha<0)?50:the_hud_alpha)

			}
		}
	}
	
	if(glow_on_user){

		if(DEBUG){
		
			if(ArraySize(player_rendering_priority_structs_array[server_slot_idx:id][rendering_attempts_stack_obj])<1){
					ArrayPushCell(player_rendering_priority_structs_array[server_slot_idx:id][rendering_attempts_stack_obj],
									the_priority)


			}
			else{
					ArrayInsertCellBefore(player_rendering_priority_structs_array[server_slot_idx:id][rendering_attempts_stack_obj],
									0
									,
									the_priority)
			}
		
		}
		if(player_rendering_priority_structs_array[server_slot_idx:id][curr_priority]>the_priority){
			
			/*
			if(DEBUG){
				sh_chat_message(id,heroID,"We tried changing glow and nothing happened because of priority!")
				sh_chat_message(id,heroID,"The priority attempted to be changed out was:  %s",render_priority_names[player_rendering_priorities_array[server_slot_idx:id]])
			}
			*/
			return;


		}

		/*
		if(DEBUG){
				
			sh_chat_message(id,heroID,"We are about to try to change glow! The priority test passed!");
			sh_chat_message(id,heroID, "The attempted glow type is: %s",render_priority_names[the_priority])
			sh_chat_message(id,heroID, "Our glow type is: %s",render_priority_names[player_rendering_priorities_array[server_slot_idx:id]])
		}*/

		static invis_from_player_pct,
				invis_pct_to_set_pct;
		
		invis_from_player_pct = sh_get_player_cloak_pct(id)

		
		invis_pct_to_set_pct = ALPHA_PCT_CALC_FROM_RENDER_MODE_AND_AMT(rendering_mode, float(alpha))
		
		if((the_priority==PRIO_RENDER_INVISIBILITY)&&(player_rendering_priority_structs_array[server_slot_idx:id][curr_priority]==PRIO_RENDER_INVISIBILITY)){
			
			
			/*
			if(DEBUG){
					
				sh_chat_message(id,heroID,"We are about to try to change transparency!");
				sh_chat_message(id,heroID, "The attempted transparency is: %d",invis_pct_to_set_pct)
				sh_chat_message(id,heroID, "Our transparency is: %d",invis_from_player_pct)
				sh_chat_message(id,heroID, "Our current rendering hero is: %d",player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id])
				sh_chat_message(id,heroID, "The attempted rendering hero is: %d",heroID)
			}
			*/
			

			if((invis_from_player_pct>invis_pct_to_set_pct)&&(player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id]!=heroID)){
				
				//if(DEBUG){
				
					//sh_chat_message(id,heroID,"We tried changing glow and nothing happened because of transparency!")
				
				//}
				
				return
			}
		}
		
		player_rendering_priority_structs_array[server_slot_idx:id][curr_pct] = invis_from_player_pct
		player_rendering_priority_structs_array[server_slot_idx:id][curr_priority] = the_priority
		player_rendering_priority_structs_array[server_slot_idx:id][curr_render_mode] = rendering_mode
		player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id] = heroID
		player_rendering_priority_structs_array[server_slot_idx:id][curr_alpha] = alpha

		player_rendering_priority_structs_array[server_slot_idx:id][curr_color][0] = LineColors[the_color_const][0]
		player_rendering_priority_structs_array[server_slot_idx:id][curr_color][1] = LineColors[the_color_const][1]
		player_rendering_priority_structs_array[server_slot_idx:id][curr_color][2] = LineColors[the_color_const][2]

		/*if(DEBUG){
		
			sh_chat_message(id,player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id],
			
						"We SHOULD be seeing new rendering, here!")
		
		}*/
		/*
		static bool:result;
		result = bool:*/
		sh_set_rendering(id,
						player_rendering_priority_structs_array[server_slot_idx:id][curr_color][0],
						player_rendering_priority_structs_array[server_slot_idx:id][curr_color][1],
						player_rendering_priority_structs_array[server_slot_idx:id][curr_color][2],
						(alpha<0)?255:player_rendering_priority_structs_array[server_slot_idx:id][curr_alpha],
						rendering_fx,
						player_rendering_priority_structs_array[server_slot_idx:id][curr_render_mode], true)
		
		/*
		if(DEBUG){
		
			sh_chat_message(id,player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id],
			
						"sh_set_rendering returned: %s", result?"Success!":"Failure...")
		
		}*/
		

		if((the_priority!=PRIO_RENDER_INVISIBILITY)&&set_aura_glow){

			aura_aux(id,player_rendering_priority_structs_array[server_slot_idx:id][curr_color])
		}
		
		if(is_valid_ent(player_rendering_priority_structs_array[server_slot_idx:id][player_renderer_entity])){

			if((entity_get_float(player_rendering_priority_structs_array[server_slot_idx:id][player_renderer_entity],EV_FL_nextthink)>0.0)&&client_is_within_range(id)){

			//if(client_is_within_range(id)){

				if(DEBUG){
					sh_chat_message(id,player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id],
					
								"does this even get called?")
				}					
				entity_set_float(player_rendering_priority_structs_array[server_slot_idx:id][player_renderer_entity],
										EV_FL_nextthink,0.0)
			
			}
		}
		remove_glow_user_aux(id,the_priority,alpha,rendering_mode,the_glow_timer,heroID)

	}
}
remove_glow_user_aux(id,
                  rendering_priority_consts:the_priority = PRIO_RENDER_NONE,
                  gating_alpha = 255,
                  the_rendering_mode_obtained = kRenderTransColor,
                  Float:delay = 0.0,
                  heroID = -1){
	if(player_rendering_priority_structs_array[server_slot_idx:id][curr_priority]>the_priority){
		
		

		return
	}


	if(!client_is_within_range(id)){

		return
	}

	static gating_invis_pct,
		invis_from_player_pct;
	
	gating_invis_pct = ALPHA_PCT_CALC_FROM_RENDER_MODE_AND_AMT(the_rendering_mode_obtained, float(gating_alpha)),
	invis_from_player_pct = sh_get_player_cloak_pct(id)

	/*if(DEBUG){
			
		sh_chat_message(id,heroID,"We are about to try to remove glow! The priority test passed!");
		sh_chat_message(id,heroID, "The attempted glow  removal type is: %s",render_priority_names[the_priority])
		sh_chat_message(id,heroID, "Our glow type is: %s",render_priority_names[player_rendering_priorities_array[server_slot_idx:id]])
	}*/

	if((the_priority==PRIO_RENDER_INVISIBILITY)&&(player_rendering_priority_structs_array[server_slot_idx:id][curr_priority] ==PRIO_RENDER_INVISIBILITY)){

		/*
		if(DEBUG){
				
			sh_chat_message(id,heroID,"We are about to try to remove transparency!");
			sh_chat_message(id,heroID, "The attempted transparency to remove is: %d",gating_invis_pct)
			sh_chat_message(id,heroID, "Our transparency is: %d",invis_from_player_pct)
			sh_chat_message(id,heroID, "Our current rendering hero is: %d",player_rendering_heroes_array[server_slot_idx:id])
			sh_chat_message(id,heroID, "The attempted rendering hero is: %d",heroID)
		}*/

		if((invis_from_player_pct>gating_invis_pct)&&(player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id] !=heroID)){
			
			if(DEBUG){
			
				sh_chat_message(id,heroID,"We tried removing glow and nothing happened because of transparency!")
			
			}
			
			return
		}

	}
	if(delay > 0.0){
		entity_set_float(player_rendering_priority_structs_array[server_slot_idx:id][player_renderer_entity],
							EV_FL_nextthink, get_gametime()+delay)

	}


}
public _remove_glow_user(iPlugin,iParams){



	new id=get_param(1)
	new rendering_priority_consts:the_priority = rendering_priority_consts:get_param(2)
	

	new gating_alpha= get_param(3)
	new heroID = get_param(6)

	new the_rendering_mode_obtained = get_param(4)

	new Float:delay=get_param_f(5)

	remove_glow_user_aux(id,
				the_priority,
                gating_alpha,
                the_rendering_mode_obtained,
                delay,
                heroID);
				

}
public render_removal_think(ent_id){

	if(!is_valid_ent(ent_id)){

		return PLUGIN_CONTINUE
	}

	static id;
	id = entity_get_int(ent_id,EV_INT_iuser4)

	if(!sh_is_active()||!is_user_connected(id)||!is_user_alive(id)){
		return PLUGIN_CONTINUE
	}
	
	clear_client_state(server_slot_idx:id)
	sh_set_rendering(id)
	
	return PLUGIN_CONTINUE

}
public debug_glow_hud_taskid(task_id){

	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]

		if(!is_user_alive(id)){

			continue;
		}
		arrayset(player_rendering_priority_structs_array[server_slot_idx:id][player_hud_buffer_array],0,1023);

		new rendering_priority_consts:latest_recorded_attempt_at_change = rendering_priority_consts:0;


		if(ArraySize(player_rendering_priority_structs_array[server_slot_idx:id][rendering_attempts_stack_obj])>0)
		{
			
			latest_recorded_attempt_at_change = (ArrayGetCell(player_rendering_priority_structs_array[server_slot_idx:id][rendering_attempts_stack_obj],
															ArraySize(player_rendering_priority_structs_array[server_slot_idx:id][rendering_attempts_stack_obj])-1))
															
		
			ArrayDeleteItem(player_rendering_priority_structs_array[server_slot_idx:id][rendering_attempts_stack_obj],ArraySize(player_rendering_priority_structs_array[server_slot_idx:id][rendering_attempts_stack_obj])-1)
		}	
		static hero_name[MAX_HERO_NAME_LENGTH]
		
		(player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id]<0)?formatex(hero_name,sizeof hero_name,"%s","Some Generic Hero"):sh_get_hero_name_from_id(player_rendering_priority_structs_array[server_slot_idx:id][curr_hero_id],hero_name);
	
		formatex(player_rendering_priority_structs_array[server_slot_idx:id][player_hud_buffer_array],1023,
									"Last applicant hero: %s^nPrevious glow priority: %s^nCurrent glow priority: %s^nCurrent Alpha: %d^nPrevious invisibility percentage: %d^nCurrent invisibility percentage: %d^nCurrent render mode: %s^n",
									hero_name,
									render_priority_names[latest_recorded_attempt_at_change],
									render_priority_names[player_rendering_priority_structs_array[server_slot_idx:id][curr_priority]],
									player_rendering_priority_structs_array[server_slot_idx:id][curr_alpha],
									player_rendering_priority_structs_array[server_slot_idx:id][curr_pct],
									sh_get_player_cloak_pct(id),
									render_mode_names[clamp(entity_get_int(id, EV_INT_rendermode),0,_:kRenderTransAdd)])
		

		set_hudmessage(player_rendering_priority_structs_array[server_slot_idx:id][curr_color][0],
						player_rendering_priority_structs_array[server_slot_idx:id][curr_color][1],
						player_rendering_priority_structs_array[server_slot_idx:id][curr_color][2],
						 -1.0, 0.48, 0, 0.1, 2.0, 0.02, 0.02, -1)

		ShowSyncHudMsg(id, DEBUG_HUD_HUD_SYNC_OBJ, "%s",player_rendering_priority_structs_array[server_slot_idx:id][player_hud_buffer_array])



	}


}