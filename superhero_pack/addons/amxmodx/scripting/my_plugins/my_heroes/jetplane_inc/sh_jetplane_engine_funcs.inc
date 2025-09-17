#if defined sh_yandere_jet_engine_funcs
  #endinput
#endif
#define sh_yandere_jet_engine_funcs

#define FlameRate 5
#define SoundRate 1

#define JETPLANE_FLY_SOUND "shmod/yandere/jetsounds/engine/fly2.wav"
#define JETPLANE_IDLE_SOUND "shmod/yandere/jetsounds/engine/idle.wav"
#define JETPLANE_BLOW_SOUND "shmod/yandere/jetsounds/engine/blow.wav"

#define JETPLANE_ACCEL_PER_SEC 100.0
native Float:get_jet_fuel(jet_id)
native set_jet_fuel(jet_id,Float:fuel_ammount)
native get_jet_throttle(id)
native set_jet_throttle(id,on_or_of)
native get_jet_airbrakes(id)
native set_jet_airbrakes(id,on_or_of)
native reset_jet_fuel(jet_id)
native Float:get_user_fuel_ammount(id)
native set_user_fuel_ammount(id,Float:ammount)
native reset_user_fuel_ammount(id)
native Float:get_jet_fuel_spend()
native Float:get_jet_speed()
native Float:get_jet_accelerate_const()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
