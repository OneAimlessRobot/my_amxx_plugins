#if defined sh_ksun_global_funcs
  #endinput
#endif
#define sh_ksun_global_funcs

#define KSUN_MORPH_TASKID 912333
#define KSUN_UNGLOW_TASKID 5912382


#define KSUN_PLAYER_MODEL "models/player/ksun/ksun.mdl"

#define COOLDOWN_UPDATE_TASKID 1233222
#define COOLDOWN_UPDATE_PERIOD 0.5

#define STATUS_UPDATE_TASKID 7812713
#define STATUS_UPDATE_PERIOD 0.5

native spores_has_ksun(id)
native spores_ksun_hero_id()
native Float:spores_cooldown()
native ksun_dec_num_sleep_nades(id)
native ksun_get_num_sleep_nades(id)
native ksun_set_num_sleep_nades(id,value)
	
	