#if defined sh_aux_funcs_misc_pt3
  #endinput
#endif
#define sh_aux_funcs_misc_pt3

stock remove_entity_safe(ent_id){

	if(is_valid_ent(ent_id)){
		entity_set_int(ent_id, EV_INT_flags, entity_get_int(ent_id, EV_INT_flags) | FL_KILLME)
		entity_set_float(ent_id, EV_FL_nextthink, get_gametime())
	}
}