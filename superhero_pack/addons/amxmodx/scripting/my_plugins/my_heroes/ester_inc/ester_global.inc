#if defined sh_ester_global_funcs
  #endinput
#endif
#define sh_ester_global_funcs


#define COUNTER_UP_SFX "shmod/Teliko/counter_plus_plus.wav"
#define NEUROBLAST_CHARGE "shmod/ester/ester_buildup.wav"
#define NEUROBLAST_RELEASE  "shmod/ester/ester_release.wav"

#define PAN_P_MODEL "models/shmod/ester/pan/p_knife.mdl"
#define PAN_V_MODEL  "models/shmod/ester/pan/v_knife.mdl"

#define PAN_HIT_WALL_SOUND "weapons/esterpan/knife_hitwall1.wav"
#define PAN_HIT_AIR1_SOUND  "weapons/esterpan/knife_slash1.wav"
#define PAN_HIT_AIR2_SOUND  "weapons/esterpan/knife_slash2.wav"
#define PAN_STAB_MEAT_SOUND  "weapons/esterpan/knife_stab.wav"
#define PAN_HIT_MEAT1_SOUND  "weapons/esterpan/knife_hit1.wav"
#define PAN_HIT_MEAT2_SOUND  "weapons/esterpan/knife_hit2.wav"
#define PAN_HIT_MEAT3_SOUND  "weapons/esterpan/knife_hit3.wav"
#define PAN_HIT_MEAT4_SOUND  "weapons/esterpan/knife_hit4.wav"

#define MAX_ESTER_XP 1000
#define ESTER_GIVE_PER_HIT 50
#define ESTER_GIVE_PER_HIT_BIG 400
#define ESTER_SAVED_THE_DAY_STRING "you have just given %s an extra %d xp from your annoying ass, smothering moralizing!"
#define ESTER_JUST_SHUT_UP_STRING "[SH] %s: Moralizing has earned you %d more xp!"
#define ESTER_FINE_WHATEVER_YOU_SAY "Moralizing last round has earned you %d more xp!"

native ester_get_has_ester(id)
native ester_get_hero_id()