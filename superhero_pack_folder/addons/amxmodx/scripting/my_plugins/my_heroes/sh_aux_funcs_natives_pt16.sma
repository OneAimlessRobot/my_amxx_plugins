#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt16.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"


#define PLUGIN LIBRARY_NAME
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new const DEBUG_MODE = 0

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

new REMOVE_GLOW_TASKID

new DEBUG_HUD_TASKID = -1


new DEBUG_HUD_HUD_SYNC_OBJ = -1

#define DEBUG_HUD_TASK_PERIOD 0.2

new rendering_priority_consts:player_rendering_priorities_array[server_slot_idx] = 
																		
											{rendering_priority_consts:0,
																		
																		...}
																		/*
new rendering_priority_consts:last_attempted_player_rendering_priorities_array[server_slot_idx] = 
																		
											{rendering_priority_consts:0,
																		
																		...}
																		*/
new player_rendering_pctgs_array[server_slot_idx] = {0, ...}
new player_rendering_modes_array[server_slot_idx] = {kRenderNormal, ...}
new player_rendering_heroes_array[server_slot_idx] = {-1, ...}

new Array:rendering_attempts_stack_obj[server_slot_idx]

new player_hud_buffer_array[server_slot_idx][1024];

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);


	if(DEBUG_MODE){

		DEBUG_HUD_HUD_SYNC_OBJ = CreateHudSyncObj()

		DEBUG_HUD_TASKID=allocate_typed_task_id(player_task)
		
		set_task(DEBUG_HUD_TASK_PERIOD,"debug_glow_hud_taskid",DEBUG_HUD_TASKID,_,_,"b")

		for( new server_slot_idx:i = server_slot_idx:0; i< server_slot_idx;i++){
			rendering_attempts_stack_obj[i] = ArrayCreate()
		}

	}

	REMOVE_GLOW_TASKID=allocate_typed_task_id(entity_task)


}
public plugin_cfg(){


	server_print("%s innited!^n",LIBRARY_NAME)
	
}
public plugin_end() {

	if(DEBUG_MODE){

		for( new server_slot_idx:i = server_slot_idx:0; i< server_slot_idx;i++){
			ArrayDestroy(rendering_attempts_stack_obj[i])
		}
	
	}

}
public plugin_natives(){

	register_native("set_render_with_color_const","_set_render_with_color_const")
	register_native("aura","_aura");
	register_native("remove_glow_user","_remove_glow_user")

}
clear_client_state(server_slot_idx:id){


	player_rendering_pctgs_array[id]=0
	player_rendering_priorities_array[id]=rendering_priority_consts:0
}
public sh_client_spawn(id){

	clear_client_state(server_slot_idx:id)

}
public client_disconnected(id){

	clear_client_state(server_slot_idx:id)


}
aura_aux(id,const color[3]={255,255,255},life=3,decay=1){
	
	if ( !is_user_connected(id) ) return

	new origin[3]


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
	new color[3]
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

	new bool:is_valid_client = bool:is_user_alive(id);
	if(glow_user_hud&&is_valid_client){
		
		if((sh_get_id_bit(id,SH_IS_SLEEPING)&&is_sleep)||!sh_get_id_bit(id,SH_IS_SLEEPING)){

			sh_screen_fade(id, 0.1, 0.9,
				LineColors[the_color_const][0],
				LineColors[the_color_const][1],
				LineColors[the_color_const][2],
				(the_hud_alpha<0)?50:the_hud_alpha)

		}
	}
	
	if(glow_on_user){


		

		if(DEBUG_MODE){
		
			if(ArraySize(rendering_attempts_stack_obj[server_slot_idx:id])<1){
					ArrayPushCell(rendering_attempts_stack_obj[server_slot_idx:id],
									the_priority)


			}
			else{
					ArrayInsertCellBefore(rendering_attempts_stack_obj[server_slot_idx:id],
									0
									,
									the_priority)
			}
		
		}
		
		if(DEBUG_MODE){
			sh_chat_message(id,heroID,"We are about to try to change glow! The target glow type is: %s",render_priority_names[the_priority])
		}
		if(player_rendering_priorities_array[server_slot_idx:id]>the_priority){
			
			if(DEBUG_MODE){
				sh_chat_message(id,heroID,"We tried changing glow and nothing happened because of priority!")
				sh_chat_message(id,heroID,"The priority attempted to be changed out was:  %s",render_priority_names[player_rendering_priorities_array[server_slot_idx:id]])
			}
			return;


		}

		if(task_exists(id+REMOVE_GLOW_TASKID)&&client_is_within_range(id)){
			remove_task(id+REMOVE_GLOW_TASKID)
		}
		if(is_valid_client){

			if(DEBUG_MODE){
					
				sh_chat_message(id,heroID,"We are about to try to change glow! The priority test passed!");
				sh_chat_message(id,heroID, "The attempted glow type is: %s",render_priority_names[the_priority])
				sh_chat_message(id,heroID, "Our glow type is: %s",render_priority_names[player_rendering_priorities_array[server_slot_idx:id]])
			}


			new invis_from_player_pct = sh_get_player_cloak_pct(id)
			if((the_priority==PRIO_RENDER_INVISIBILITY)&&(player_rendering_priorities_array[server_slot_idx:id]==PRIO_RENDER_INVISIBILITY)){

			
				new invis_pct_to_set_pct = ALPHA_PCT_CALC_FROM_RENDER_MODE_AND_AMT(rendering_mode, float(alpha))
					

				if((invis_from_player_pct>invis_pct_to_set_pct)&&(player_rendering_heroes_array[server_slot_idx:id]!=heroID)){
					
					if(DEBUG_MODE){
					
						sh_chat_message(id,heroID,"We tried changing glow and nothing happened because of transparency!")
					
					}
					
					return
				}
			}

			player_rendering_pctgs_array[server_slot_idx:id] = invis_from_player_pct
			player_rendering_priorities_array[server_slot_idx:id] = the_priority
			player_rendering_modes_array[server_slot_idx:id] = rendering_mode
			player_rendering_heroes_array[server_slot_idx:id] = heroID

		}
		sh_set_rendering(id,
						LineColors[the_color_const][0],
						LineColors[the_color_const][1],
						LineColors[the_color_const][2],
						(alpha<0)?255:alpha,
						rendering_fx,
						rendering_mode)
		if((the_priority!=PRIO_RENDER_INVISIBILITY)&&set_aura_glow){
			aura_aux(id,LineColors[the_color_const])
		}
		if((the_glow_timer>0.1)){
			
			remove_glow_user_aux(id,the_priority,alpha,rendering_mode,the_glow_timer,heroID)
		}

	}
}
remove_glow_user_aux(id,
                  rendering_priority_consts:the_priority = PRIO_RENDER_NONE,
                  gating_alpha = 255,
                  the_rendering_mode_obtained = kRenderTransColor,
                  Float:delay = 0.0,
                  heroID = -1){

	if(player_rendering_priorities_array[server_slot_idx:id]>the_priority){
		
		

		return
	}

	if(!client_is_within_range(id)){

		return
	}
	if((the_priority==PRIO_RENDER_INVISIBILITY)&&(player_rendering_priorities_array[server_slot_idx:id]==PRIO_RENDER_INVISIBILITY)){

		new gating_invis_pct = ALPHA_PCT_CALC_FROM_RENDER_MODE_AND_AMT(the_rendering_mode_obtained, float(gating_alpha)),
			invis_from_player_pct = sh_get_player_cloak_pct(id)

		if((invis_from_player_pct>gating_invis_pct)&&(player_rendering_heroes_array[server_slot_idx:id]!=heroID)){
			
			if(DEBUG_MODE){
			
				sh_chat_message(id,heroID,"We tried removing glow and nothing happened because of transparency!")
			
			}
			
			return
		}

	}




	if(delay<0.1){

		remove_glow_task(id+REMOVE_GLOW_TASKID)
		return;
	}
	set_task(delay,"remove_glow_task",id+REMOVE_GLOW_TASKID)



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
public remove_glow_task(id){

	id-=REMOVE_GLOW_TASKID
	if(!sh_is_active()||!is_user_connected(id)||!is_user_alive(id)){
		return
	}
	clear_client_state(server_slot_idx:id)
	sh_set_rendering(id)

}
public debug_glow_hud_taskid(task_id){

	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]

		if(!is_user_alive(id)){

			continue;
		}
		arrayset(player_hud_buffer_array[server_slot_idx:id],0,sizeof player_hud_buffer_array[]);

		new rendering_priority_consts:latest_recorded_attempt_at_change = rendering_priority_consts:0;


		if(ArraySize(rendering_attempts_stack_obj[server_slot_idx:id])>0)
		{
			
			latest_recorded_attempt_at_change = (ArrayGetCell(rendering_attempts_stack_obj[server_slot_idx:id],
															ArraySize(rendering_attempts_stack_obj[server_slot_idx:id])-1))
															
		
			ArrayDeleteItem(rendering_attempts_stack_obj[server_slot_idx:id],ArraySize(rendering_attempts_stack_obj[server_slot_idx:id])-1)
		}	
		new hero_name[MAX_HERO_NAME_LENGTH]
		
		(player_rendering_heroes_array[server_slot_idx:id]<0)?formatex(hero_name,sizeof hero_name,"%s","Some Generic Hero"):sh_get_hero_name_from_id(player_rendering_heroes_array[server_slot_idx:id],hero_name);
	
		formatex(player_hud_buffer_array[server_slot_idx:id],sizeof player_hud_buffer_array[],
									"Last applicant hero: %s^nPrevious glow priority: %s^nCurrent glow priority: %s^nPrevious invisibility percentage: %d^nCurrent invisibility percentage: %d^nCurrent render mode: %s^n",
									hero_name,
									render_priority_names[latest_recorded_attempt_at_change],
									render_priority_names[player_rendering_priorities_array[server_slot_idx:id]],
									player_rendering_pctgs_array[server_slot_idx:id],
									sh_get_player_cloak_pct(id),
									render_mode_names[clamp(entity_get_int(id, EV_INT_rendermode),0,_:kRenderTransAdd)])
		

		set_hudmessage(255, 255, 255, -1.0, 0.48, 2, 0.1, 2.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(id, DEBUG_HUD_HUD_SYNC_OBJ, "%s", player_hud_buffer_array[server_slot_idx:id])



	}


}