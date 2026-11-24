#if defined auxiliar_stuff_safeguard_stocks_inc
  #endinput
#endif
#define auxiliar_stuff_safeguard_stocks_inc

stock task_safeguard_macro_for_player_task(id,taskid,range){
	
	if((client_is_within_custom_range(id,range))){ 
		if(task_exists(id+taskid)){
			remove_task(id+taskid)
		}
	
	}
}