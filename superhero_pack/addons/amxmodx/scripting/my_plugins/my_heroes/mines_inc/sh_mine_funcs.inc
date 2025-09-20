#if defined sh_mine_funcs
  #endinput
#endif
#define sh_mine_funcs

#define MINE_CLASSNAME "mine"

#define XO_WEAPON 4
#define m_pPlayer 41



#define MINE_WORLD_MDL "models/shmod/sapper/mine/mine.mdl"

#define DETECT_RADIUS 500.0

#define EXPLODE_RADIUS 750.0

#define MINE_DAMAGE_FALLOFF_DIST 750.0

#define MINE_PLANT_PERIOD 1.0

#define MINE_ARMING_TASKID 2162
#define MINE_ARMING_TIME 4.0
#define UNMINE_ARMING_TASKID 3538

#define MINE_DAMAGE 200

#define MINE_RELOAD_TASKID 5122

#define MINE_WAIT_TASKID 8562
#define MINE_WAIT_PERIOD 0.2
#define UNMINE_WAIT_TASKID 9372

#define MINE_REM_TASKID 9127
#define MINE_REM_TIME 1.0

#define MINE_CHARGE_TASKID 12783
#define UNMINE_CHARGE_TASKID 18229
#define MINE_CHARGE_PERIOD 0.1
#define MINE_CHARGE_TIMES floatround(floatdiv(min_charge_time,MINE_CHARGE_PERIOD))


#define MINE_DISARM_TASKID 7281
#define UNMINE_DISARM_TASKID 4281
#define MINE_DISARM_PERIOD 0.1
#define MINE_DISARM_TIMES floatround(floatdiv(min_charge_time,MINE_DISARM_PERIOD))


stock const mine_color[4]={255, 255, 255,200}


native clear_mines()
native mine_get_mine_disarmer_on(id)
native mine_set_mine_disarmer_on(id,value_to_set)
native mine_get_mine_armed(id)
native mine_set_mine_armed(id,value_to_set)
native mine_get_mine_loaded(id)
native mine_get_mine_charging(id)
native mine_uncharge_mine(id)
native mine_charge_mine(id)
native mine_disarm_mine(id,mine_id)
native mine_undisarm_mine(id)
native mine_get_mine_disarming(id)

native plant_mine(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
