#if defined sh_chaff_funcs
  #endinput
#endif
#define sh_chaff_funcs

#define CHAFF_CLASSNAME "chaff_grenade"

#define XO_WEAPON 4
#define m_pPlayer 41



#define CHAFF_EXPLODE_SFX "shmod/Teliko/chaff/chaff_blow.wav"
#define CHAFF_BOUNCE_SFX "shmod/Teliko/chaff/bounce.wav"

#define CHAFF_SPEED 3000.0

#define CHAFF_RADIUS 500.0

#define CHAFF_SHOOT_PERIOD 1.0

#define CHAFF_RELOAD_TASKID 5842

#define CHAFF_REM_TASKID 7982
#define CHAFF_REM_TIME 1.0
#define CHAFF_BLAST_TASKID 9982
#define CHAFF_DET_TIME 1.0


#define CHAFF_CHARGE_TASKID 30142
#define UNCHAFF_CHARGE_TASKID 28218
#define CHAFF_CHARGE_PERIOD 0.1
#define CHAFF_CHARGE_TIMES floatround(floatdiv(max_charge_time,CHAFF_CHARGE_PERIOD))

#define MAX_ENTITIES 2048



native clear_chaffs()
native chaff_get_chaff_loaded(id)
native chaff_uncharge_chaff(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
