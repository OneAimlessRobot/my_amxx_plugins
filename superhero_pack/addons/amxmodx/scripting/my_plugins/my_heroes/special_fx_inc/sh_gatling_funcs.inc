#if defined sh_gat_funcs
  #endinput
#endif
#define sh_gat_funcs

#define PILL_CLASSNAME "pill_gatling_pill"
#define EFFECT_SHOT_SFX "shmod/Teliko/counter.wav"

#define NUM_OF_EFFECT_COLORS 10


#define PILL_SPEED 2000.0

#define PILL_SHOOT_PERIOD 0.001

#define PILL_SHOOT_RANDOMNESS 0.0

#define PILL_RELOAD_TASKID 7218

#define PILL_REM_TASKID 20399
#define PILL_REM_TIME 0.01

#define PILL_MASS 100.0


#define GAT_WINDUP_TASKID 728229
#define UNGAT_WINDUP_TASKID 274490
#define GAT_WINDUP_PERIOD 0.1
#define GAT_WINDUP_TIMES floatround(floatdiv(windup_time,GAT_WINDUP_PERIOD))

native gatling_set_pillgatling(id,value_to_set)
native gatling_get_pillgatling(id)

native gatling_set_pill_fx_num(pillid,value_to_set)
native gatling_get_pill_fx_num(pillid)
native clear_pills()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
