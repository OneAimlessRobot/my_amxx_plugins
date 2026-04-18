#if defined sh_molly_fx
  #endinput
#endif
#define sh_molly_fx


#define CAN_SELF_MOLLY 1

#define gSoundBurning "ambience/burning1.wav"
#define gSoundScream "scientist/c1a0_sci_catscream.wav"


#define BURN_PERIOD 1.0
#define BURN_DAMAGE 10
#define BURN_DAMAGE_VULNERABILITY_COEFF 0.30
#define BURN_TIME 15.0
#define BURN_TIMES floatround(floatdiv(BURN_TIME,BURN_PERIOD))

native sh_molly_user(id,attacker,gHeroID)
native sh_unmolly_user(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
