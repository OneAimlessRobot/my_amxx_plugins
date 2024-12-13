#if defined sh_lara_funcs
  #endinput
#endif
#define sh_lara_funcs

#define SPEAR_CLASSNAME "spear"

#define XO_WEAPON 4
#define m_pPlayer 41


#define SPEAR_RETRIEVE true


#define SPEAR_SPEED 3000.0

#define SPEAR_SHOOT_PERIOD 1.0

#define SPEAR_DAMAGE 100

#define SPEAR_STAB_DAMAGE 200

#define SPEAR_SHOOT_RANDOMNESS 0.0

#define SPEAR_RELOAD_TASKID 5842

#define SPEAR_REM_TASKID 7682
#define SPEAR_REM_TIME 1.0


#define SPEAR_CHARGE_TASKID 30142
#define UNSPEAR_CHARGE_TASKID 28218
#define SPEAR_CHARGE_PERIOD 0.1
#define SPEAR_CHARGE_TIMES floatround(floatdiv(max_charge_time,SPEAR_CHARGE_PERIOD))



native clear_spears()
native spear_get_spear_loaded(id)
native spear_uncharge_spear(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
