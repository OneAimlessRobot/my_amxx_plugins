#if defined sh_flora_global_funcs
  #endinput
#endif
#define sh_flora_global_funcs


#define FLORA_PLAYER_MODEL "models/player/Flora/Flora.mdl"
#define FLORA_PLAYER_MODEL_T "models/player/Flora/FloraT.mdl"



native flora_get_hero_id()
native flora_get_user_num_fields(id)
native flora_set_user_num_fields(id,value)
native flora_dec_user_num_fields(id,value)
native flora_inc_user_num_fields(id,value)
native flora_get_hero_lvl()