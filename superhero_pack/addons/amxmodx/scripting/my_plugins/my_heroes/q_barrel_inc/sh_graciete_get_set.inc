#if defined sh_get_set_graciete
  #endinput
#endif
#define sh_get_set_graciete


#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)



#define JP_CLASSNAME "jp_class"

#define TOUCHING_GROUND (1<<9)
// GLOBAL VARIABLES
#define GRACIETE_HUD_TASKID 17282
#define GRACIETE_TRAIL_TASKID 19272
#define GRACIETE_COOLDOWN_TASKID 22762
#define GRACIETE_LOAD_TASKID 12822

#define GRACIETE_CHARGE_TASKID 28762
#define UNGRACIETE_CHARGE_TASKID 28912
#define GRACIETE_CHARGE_PERIOD 0.1
#define GRACIETE_CHARGE_TIMES floatround(floatdiv(power_land_charge_time,GRACIETE_CHARGE_PERIOD))

#define GRACIETE_MAX_DAMAGE 500.0

#define GRACIETE_CHARGE_RATE 100.0

#define jp_jump "shmod/graciete/jp/rocketfire1.wav"
#define jp_fly "shmod/graciete/jp/rocket1.wav"
#define crush_stunned "shmod/Teliko/chaff/chaff_blow.wav"
#define jp_mdl "models/shmod/graciete/jp/rpgrocket.mdl"
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
