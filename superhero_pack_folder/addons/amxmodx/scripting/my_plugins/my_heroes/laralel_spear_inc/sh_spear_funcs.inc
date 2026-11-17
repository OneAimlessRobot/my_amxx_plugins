#if defined sh_lara_funcs
  #endinput
#endif
#define sh_lara_funcs

#define SPEAR_CLASSNAME "spear"

#define SPEAR_RETRIEVE true


#define SPEAR_SPEED 1750.0

#define SPEAR_SHOOT_PERIOD 1.0

#define SPEAR_LAUNCH_DAMAGE 100
#define SPEAR_LAUNCH_FORCE 1500.0
#define SPEAR_LAUNCH_EXPLODE_RADIUS 100.0

#define SPEAR_SMASH_DAMAGE 400
#define SPEAR_SMASH_FORCE 2750.0
#define SPEAR_SMASH_EXPLODE_RADIUS 70.0

#define SPEAR_STAB_DAMAGE 200
#define SPEAR_SLASH_DAMAGE 10

#define SPEAR_SHOOT_RANDOMNESS 0.0



native spear_set_user_spear(id, bool:value, start_ammo = 100)

native spear_set_num_spears(id,value_to_set)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
