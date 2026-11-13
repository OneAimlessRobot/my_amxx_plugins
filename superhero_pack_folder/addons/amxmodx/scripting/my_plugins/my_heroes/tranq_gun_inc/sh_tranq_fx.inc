#if defined sh_tranq_fx
  #endinput
#endif
#define sh_tranq_fx


#define CAN_SELF_SLEEP 1


#define SLEEP_SFX "shmod/erica/sleep/snore.wav"

#define SLEEP_PERIOD 0.25
#define SLEEP_TIME 15.0
#define SLEEP_TIMES floatround(floatdiv(the_time,SLEEP_PERIOD))


forward sh_on_sleep_start_fwd(id, attacker, Float:the_time, heroID)
forward sh_on_sleep_end_fwd(id, attacker, Float:the_time, heroID)

native sh_sleep_user(id,attacker, Float:the_time = SLEEP_TIME,gHeroID)
native sh_unsleep_user(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
