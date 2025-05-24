#if defined sh_kzam_global_funcs
  #endinput
#endif
#define sh_kzam_global_funcs

#define KZAM_MORPH_TASKID 912333


#define KZAM_PLAYER_MODEL "models/player/kzam/kzam.mdl"

#define COOLDOWN_UPDATE_TASKID 1233222
#define COOLDOWN_UPDATE_PERIOD 0.5

#define STATUS_UPDATE_TASKID 7812713
#define STATUS_UPDATE_PERIOD 0.5

native spores_has_kzam(id)
native spores_kzam_hero_id()
native Float:spores_cooldown()