#if defined sh_flora_global_funcs
  #endinput
#endif
#define sh_flora_global_funcs


#define FLORA_MORPH_TASKID 9762237
#define FLORA_UNGLOW_TASKID 5612718
#define FLORA_STATUS_HUD_TASKID 45624389
#define FLORA_PLAYER_MODEL "models/player/flora/flora.mdl"
#define STATUS_UPDATE_PERIOD 0.1
#define STATUS_UPDATE_TASKID 81271237

native flora_get_has_flora(id)
native flora_get_hero_id()
native flora_get_user_num_fields(id)
native flora_set_user_num_fields(id,value)
native flora_dec_user_num_fields(id,value)
native flora_inc_user_num_fields(id,value)
native delete_hud_tasks(id)
native init_hud_tasks(id)
native flora_get_hero_lvl()
native flora_get_prev_weapon(id)
native flora_set_prev_weapon(id,value)