#if defined sh_molly_fx
  #endinput
#endif
#define sh_molly_fx

#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)


#define XO_WEAPON 4

#define CAN_SELF_MOLLY 1

#define gSoundBurning "ambience/burning1.wav"
#define gSoundScream "scientist/c1a0_sci_catscream.wav"

#define MOLLY_TASKID 19213
#define UNMOLLY_TASKID 2331
#define MOLLY_PERIOD 1.0
#define MOLLY_TIME 30.0
#define MOLLY_TIMES floatround(floatdiv(MOLLY_TIME,MOLLY_PERIOD))


#define BURN_TASKID 14232
#define BURN_PERIOD 0.25
#define BURN_DAMAGE 30
#define BURN_DAMAGE_VULNERABILITY_COEFF 0.30
#define BURN_TIME MOLLY_TIME
#define BURN_TIMES floatround(floatdiv(BURN_TIME,BURN_PERIOD))



stock const molly_color[4]={255, 50, 255,200}

native sh_molly_user(id,attacker,gHeroID)
native sh_unmolly_user(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
