#if defined sh_freeze_fx
  #endinput
#endif
#define sh_freeze_fx


#define FROZEN_SFX "shmod/frostnova.wav" 

#define FREEZE_TIME 20.0

#define DEFAULT_FREEZE_SPEED 130.0

#define FREEZE_DAMAGE_MULTIPLIER 2.0

native sh_freeze_user(id,Float:the_time = FREEZE_TIME,Float:speed = DEFAULT_FREEZE_SPEED, Float:freeze_damaga_vuln_mult=FREEZE_DAMAGE_MULTIPLIER)
native sh_unfreeze_user(id)




/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
