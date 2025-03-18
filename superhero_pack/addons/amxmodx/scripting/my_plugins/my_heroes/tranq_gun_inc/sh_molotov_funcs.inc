#if defined sh_molly_funcs
  #endinput
#endif
#define sh_molly_funcs

#define MOLLY_CLASSNAME "molotov_grenade"

#define XO_WEAPON 4
#define m_pPlayer 41

#define ANTI_LAGG		7

#define MOLLY_BURST_SFX "shmod/erica/molotov/molotov_crack.wav"
#define MOLLY_FIRE_SFX "shmod/erica/molotov/molotov_fire.wav"

#define MOLLY_THROW_SFX  "shmod/lara/spear/spear_throw.wav"
#define MOLLY_P_MODEL  "models/shmod/erica/molotov/p_hegrenade.mdl"
#define MOLLY_V_MODEL  "models/shmod/erica/molotov/v_hegrenade.mdl"
#define MOLLY_W_MODEL  "models/shmod/erica/molotov/w_hegrenade.mdl"

#define MOLLY_SPEED 3000.0

#define MOLLY_RADIUS 500.0

#define MOLLY_SHOOT_PERIOD 1.0

#define MOLLY_RELOAD_TASKID 5842

#define MOLLY_REM_TASKID 7982
#define MOLLY_REM_TIME 1.0
#define MOLLY_BLAST_TASKID 9982
#define MOLLY_DET_TIME 1.0


#define MOLLY_CHARGE_TASKID 30142
#define UNMOLLY_CHARGE_TASKID 28218
#define MOLLY_CHARGE_PERIOD 0.1
#define MOLLY_CHARGE_TIMES floatround(floatdiv(max_charge_time,MOLLY_CHARGE_PERIOD))




native clear_mollies()
native molly_get_molly_loaded(id)
native molly_uncharge_molly(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
