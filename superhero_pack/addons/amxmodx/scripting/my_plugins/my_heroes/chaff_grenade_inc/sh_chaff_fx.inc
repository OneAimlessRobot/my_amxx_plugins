#if defined sh_chaff_fx
  #endinput
#endif
#define sh_chaff_fx

#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)


#define XO_WEAPON 4
#define m_pPlayer 41

#define CAN_SELF_CHAFF 1


#define CHAFF_TASKID 19213
#define UNCHAFF_TASKID 2331
#define CHAFF_PERIOD 1.0
#define CHAFF_TIME 5.0
#define CHAFF_TIMES floatround(floatdiv(CHAFF_TIME,CHAFF_PERIOD))


#define DISORIENT_TASKID 14232
#define CHAFF_AIM_RANDOMNESS 45.0
#define CHAFF_MOVE_RANDOMNESS 1.0
#define DISORIENT_PERIOD 0.25
#define DISORIENT_TIME CHAFF_TIME
#define DISORIENT_TIMES floatround(floatdiv(DISORIENT_TIME,DISORIENT_PERIOD))



new const chaff_color[4]={255, 255, 255,200}

native sh_chaff_user(id,attacker,gHeroID)
native sh_unchaff_user(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/