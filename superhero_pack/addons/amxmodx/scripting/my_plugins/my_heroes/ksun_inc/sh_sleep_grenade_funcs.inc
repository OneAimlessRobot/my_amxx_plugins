#if defined sh_sleep_grenade_funcs
  #endinput
#endif
#define sh_sleep_grenade_funcs

#define SLEEP_NADE_CLASSNAME "sleep_grenade"
#define SLEEP_NADE_WEAPON_NAME "weapon_smokegrenade"
#define SLEEP_NADE_CLASSID CSW_SMOKEGRENADE


#define SLEEP_NADE_BURST_SFX "shmod/erica/molotov/molotov_crack.wav"

#define SLEEP_NADE_THROW_SFX  "shmod/lara/spear/spear_throw.wav"
#define SLEEP_NADE_P_MODEL  "models/p_flashbang.mdl"
#define SLEEP_NADE_V_MODEL  "models/v_flashbang.mdl"
#define SLEEP_NADE_W_MODEL  "models/w_flashbang.mdl"

#define SLEEP_NADE_SPEED 3000.0

#define SLEEP_NADE_RADIUS 500.0

#define SLEEP_NADE_PROPAGATE_RADIUS 100.0

#define SLEEP_NADE_SHOOT_PERIOD 1.0

#define SLEEP_NADE_RELOAD_TASKID 5842

#define SLEEP_NADE_REM_TASKID 62342343
#define SLEEP_NADE_REM_TIME 1.0
#define SLEEP_NADE_BLAST_TASKID 938292
#define SLEEP_NADE_DET_TIME 1.0


#define SLEEP_NADE_CHARGE_TASKID 8192843
#define UNSLEEP_NADE_CHARGE_TASKID 759821
#define SLEEP_NADE_CHARGE_PERIOD 0.1
#define SLEEP_NADE_CHARGE_TIMES floatround(floatdiv(max_charge_time,SLEEP_NADE_CHARGE_PERIOD))




native clear_sleep_nades()
native sleep_nade_get_sleep_nade_loaded(id)
native sleep_nade_uncharge_sleep_nade(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
