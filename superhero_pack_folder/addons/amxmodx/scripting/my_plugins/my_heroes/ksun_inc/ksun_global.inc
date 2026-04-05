#if defined sh_ksun_global_funcs
  #endinput
#endif
#define sh_ksun_global_funcs


#define KSUN_PLAYER_MODEL "models/player/ksun/ksun.mdl"

#define KSUN_ULTIMATE_READY_SOUND "ambience/alien_zonerator.wav"
#define KSUN_ULTIMATE_DRONE_SOUND "ambience/pulsemachine.wav"




#define COOLDOWN_UPDATE_PERIOD 0.5

#define STATUS_UPDATE_PERIOD 0.5


stock const OVERT_ABUSE_ENABLED=1
stock const COVERT_ABUSE_ENABLED=1

enum ksun_reset_occasions{
	never_reset=0,
	reset_on_death=1,
	reset_on_new_round=2,
	always_reset=3
	
	
}

native spores_ksun_hero_id()
native Float:spores_cooldown()
native ksun_dec_num_sleep_nades(id)
native ksun_get_num_sleep_nades(id)
native ksun_set_num_sleep_nades(id,value)

native ksun_dec_num_available_spores(id)
native ksun_inc_num_available_spores(id)

native ksun_multi_dec_num_available_spores(id,value)
native ksun_multi_inc_num_available_spores(id,value)

native ksun_get_num_available_spores(id)
native ksun_set_num_available_spores(id,value)

native ksun_reset_occasions:ksun_get_when_reset_spores()

