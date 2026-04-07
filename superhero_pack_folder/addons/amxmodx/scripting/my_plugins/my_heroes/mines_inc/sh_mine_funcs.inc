#if defined sh_mine_funcs
  #endinput
#endif
#define sh_mine_funcs

#define MINE_CLASSNAME "mine"


#define MINE_WORLD_MDL "models/shmod/sapper/mine/mine.mdl"

#define DETECT_RADIUS 500.0

#define EXPLODE_RADIUS 750.0

#define MINE_DAMAGE 200.0
#define MINE_PLANT_PERIOD 1.0

#define MINE_ARMING_TIME 4.0




#define MINE_WAIT_PERIOD 0.2

#define MINE_CHARGE_PERIOD 0.1
#define MINE_CHARGE_TIMES floatround(floatdiv(min_charge_time,MINE_CHARGE_PERIOD))


#define MINE_DISARM_PERIOD 0.1
#define MINE_DISARM_TIMES floatround(floatdiv(min_charge_time,MINE_DISARM_PERIOD))




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
