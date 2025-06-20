#if defined sh_ksun_global_funcs
  #endinput
#endif
#define sh_ksun_global_funcs

#define KSUN_MORPH_TASKID 912333
#define KSUN_UNGLOW_TASKID 5912382

#define KSUN_PLAYER_MODEL "models/player/ksun/ksun.mdl"

#define KSUN_ULTIMATE_READY_SOUND "ambience/alien_zonerator.wav"
#define KSUN_ULTIMATE_DRONE_SOUND "ambience/pulsemachine.wav"




#define COOLDOWN_UPDATE_TASKID 1233222
#define COOLDOWN_UPDATE_PERIOD 0.5

#define STATUS_UPDATE_TASKID 7812713
#define STATUS_UPDATE_PERIOD 0.5

#define MAX_VIOLENCE 13

stock const OVERT_ABUSE_ENABLED=1
stock const COVERT_ABUSE_ENABLED=1
stock const CENSORSHIP_SENTENCES[MAX_VIOLENCE+1][2][128]=
	{
	  {"",""},
	  {"You just got spored by  ","You just spored  "},
	  {"You just got seeded by  ","You just seeded  "},
	  {"you got tagged by  ","you just seeded  "},
	  {"you got caught by  ","you caught  "},
	  {"you got rocked by  ","you rocked  "},
	  {"You got socked by  ","smacked and socked  "},
      {"Fr broo...you rlly just got owned by  ","Dommed and owned  "},
	  {"robbed  ","you just ran the pockets of  "},
	  {"you just got taken on a walk by  ","petted and adopted  "},
	  {"scrubbed  ","you just deleted  "},
	  {"sucked  ","just sucked and spat on  "},
	  {"chest bursted  ","Eviscerated  "},
	  {"graped  ","You did them a fifty shades of grey... poor "},
	 }
native spores_has_ksun(id)
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
	
	