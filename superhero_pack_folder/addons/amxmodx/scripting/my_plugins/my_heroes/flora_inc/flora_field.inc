#if defined sh_flora_field_funcs
  #endinput
#endif
#define sh_flora_field_funcs



native reset_flora_user(id, bool:newRound= false)

native Float:field_get_user_field_cooldown(id)

native field_uncharge_user(id)

native form_field(id)

native field_loaded(id)

native flora_get_user_num_active_fields(id)