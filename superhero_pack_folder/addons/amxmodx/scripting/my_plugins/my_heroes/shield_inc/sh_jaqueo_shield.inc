#if defined sh_jaqueo_shield_funcs
  #endinput
#endif
#define sh_jaqueo_shield_funcs


#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)



#define JAQUEO_SHIELD_CLASSNAME "jaqueo_shield"


// GLOBAL VARIABLES
#define JAQUEO_COOLDOWN_TASKID 7926
#define JAQUEO_LOAD_TASKID 8263

#define JAQUEO_CHARGE_TASKID 29227
#define JAQUEO_DEPLOY_TASKID 24227
#define JAQUEO_CHARGE_PERIOD 0.1
#define JAQUEO_THINK_PERIOD 0.1

#define JAQUEO_CHARGE_RATE 100.0


#define shield_deploy "shmod/jaqueo/shield/deployed.wav"
#define shield_hum "shmod/jaqueo/shield/charge.wav"
#define shield_destroyed "shmod/jaqueo/shield/teardown.wav"
#define shield_mdl "models/shmod/jaqueo/shield/shield.mdl"

native clear_shields()

native reset_jaqueo_user(id)
native shield_get_user_shield_cooldown(id)
native shield_loaded(id)
native shield_destroy(id)
native shield_deployed(id)
native shield_uncharge_user(id)
native shield_charge_user(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
