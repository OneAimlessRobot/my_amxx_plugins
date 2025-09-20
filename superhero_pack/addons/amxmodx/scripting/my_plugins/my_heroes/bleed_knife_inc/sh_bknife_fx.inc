#if defined sh_bknife_fx
  #endinput
#endif
#define sh_bknife_fx

#define STABS_STACK true
#define SLASHES_STACK true
#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)

#define BLEED_SFX "hornet/ag_hornethit1.wav"

#define BLEED_TASKID 18182
#define UNBLEED_TASKID 8191
#define BLEED_PERIOD 1.0
#define BLEED_TIME 5.0
#define BLEED_DAMAGE 40
#define BLEED_TIMES floatround(floatdiv(BLEED_TIME,BLEED_PERIOD))

#define ULTRABLEED_TASKID 14121
#define UNULTRABLEED_TASKID 2331
#define ULTRABLEED_PERIOD 0.25
#define ULTRABLEED_TIME 5.0
#define ULTRABLEED_DAMAGE 40
#define ULTRABLEED_TIMES floatround(floatdiv(ULTRABLEED_TIME,ULTRABLEED_PERIOD))

#define MINIBLEED_TASKID 11231
#define UNMINIBLEED_TASKID 7431
#define MINIBLEED_PERIOD 1.0
#define MINIBLEED_TIME 5.0
#define MINIBLEED_DAMAGE 10
#define MINIBLEED_TIMES floatround(floatdiv(MINIBLEED_TIME,MINIBLEED_PERIOD))



stock const bleed_color[4]={255, 1, 1,255}

native sh_bleed_user(id,attacker,gHeroID)
native sh_ultrableed_user(id,attacker,gHeroID)
native sh_minibleed_user(id,attacker,gHeroID)
native sh_unbleed_user(id)
native make_bleed_fx(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
