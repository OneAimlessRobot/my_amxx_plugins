#if defined sh_tranq_fx
  #endinput
#endif
#define sh_tranq_fx

#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)


#define XO_WEAPON 4
#define m_ppPlayer 41

#define CAN_SELF_SLEEP 1

#define SLEEP_SFX "shmod/erica/sleep/snore.wav"

#define SLEEP_PERIOD 0.25
#define SLEEP_TIME 5.0
#define SLEEP_TIMES floatround(floatdiv(SLEEP_TIME,SLEEP_PERIOD))


native sh_sleep_user(id,attacker,gHeroID)
native sh_unsleep_user(id)
native bool:sh_get_user_is_asleep(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
