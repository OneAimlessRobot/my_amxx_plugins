#if defined sh_yandere_jet_engine_funcs
  #endinput
#endif
#define sh_yandere_jet_engine_funcs

#define FlameAndSoundRate 3

#define JETPLANE_FLY_SOUND "shmod/yandere/jetsounds/engine/fly2.wav"
#define JETPLANE_BLOW_SOUND "shmod/yandere/jetsounds/engine/blow.wav"

native Float:get_jet_fuel(jet_id)
native set_jet_fuel(jet_id,Float:fuel_ammount)
native reset_jet_fuel(jet_id)
native Float:get_user_fuel_ammount(id)
native set_user_fuel_ammount(id,Float:ammount)
native reset_user_fuel_ammount(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
