#if defined sh_disrupt_fx
  #endinput
#endif
#define sh_disrupt_fx


#define CAN_SELF_DISRUPT 1


#define DISRUPT_PERIOD 1.0
#define DISRUPT_TIME 5.0
#define DISRUPT_TIMES floatround(floatdiv(DISRUPT_TIME,DISRUPT_PERIOD))


#define DISRUPT_AIM_RANDOMNESS 45.0
#define DISRUPT_MOVE_RANDOMNESS 1.0
#define DISORIENT_PERIOD 0.25
#define DISORIENT_TIME DISRUPT_TIME
#define DISORIENT_TIMES floatround(floatdiv(DISORIENT_TIME,DISORIENT_PERIOD))



stock const disrupt_color[4]={255, 255, 255,200}

native sh_get_user_is_disrupted(id)
native sh_disrupt_user(id,attacker,gHeroID)
native sh_undisrupt_user(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
