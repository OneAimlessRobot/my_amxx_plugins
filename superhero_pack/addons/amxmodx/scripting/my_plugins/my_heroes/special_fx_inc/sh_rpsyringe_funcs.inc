#if defined sh_rocket_funcs
  #endinput
#endif
#define sh_rocket_funcs

#define ROCKET_CLASSNAME "pill_gatling_rocket"

#define ROCKET_EXPLODE_SFX "shmod/yakui/rocket.wav"
#define NUM_OF_EFFECT_COLORS 10

#define ROCKET_SHOOT_PERIOD 1.0

#define ROCKET_RELOAD_TASKID 7668

#define ROCKET_RADIUS 500.0

#define ROCKET_SPEED 2000.0




native gatling_set_rockets(id,value_to_set)
native gatling_get_rockets(id)

native gatling_set_rocket_fx_num(pillid,value_to_set)
native gatling_get_rocket_fx_num(pillid)
native clear_missiles()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
