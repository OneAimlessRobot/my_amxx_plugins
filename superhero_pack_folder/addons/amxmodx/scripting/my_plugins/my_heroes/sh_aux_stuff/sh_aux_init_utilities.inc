#if defined sh_aux_init_utilities
  #endinput
#endif
#define sh_aux_init_utilities

/*

	it returns nothing.

	but it accepts two in-out parameters
	one for the forward id
	and the other for the entity_id

	if either of them is equal to -1,
	the function failed
	and that shoulld be properly handled if it happens

	the default cycle period is 1.0


*/
enum init_timer_entity_struct{
	s_entity_classname_t[128],
	s_loop_callback_function_name_t[128],
	Float:s_monitor_enttiy_think_period_t,
	s_entity_id_t, s_forward_id_t

}
stock init_monitor_entity_based_global(const entity_classname[], const loop_callback_function_name[], Float:monitor_enttiy_think_period = 1.0,
											&entity_id = -1,
											&forward_id = -1){


	forward_id = register_think(entity_classname, loop_callback_function_name)

	entity_id = create_entity("info_target")


	if(!entity_id){

		set_fail_state("Monitor entity of classname %s could not be initialized!^n",entity_classname)
		server_print("Monitor entity of classname %s could not be initialized!^n",entity_classname)
		unregister_think(forward_id)
		forward_id = -1
		entity_id = -1
		return
	}

	entity_set_string(entity_id,EV_SZ_classname,entity_classname)

	entity_set_float(entity_id, EV_FL_nextthink, get_gametime() + monitor_enttiy_think_period)


}

stock init_monitor_entity_based_global_struct(the_struct_sized_buff[init_timer_entity_struct],
											&entity_id = -1,
											&forward_id = -1){

	init_monitor_entity_based_global(the_struct_sized_buff[s_entity_classname_t],
											the_struct_sized_buff[s_loop_callback_function_name_t],
											the_struct_sized_buff[s_monitor_enttiy_think_period_t],
											entity_id,forward_id)
										

}