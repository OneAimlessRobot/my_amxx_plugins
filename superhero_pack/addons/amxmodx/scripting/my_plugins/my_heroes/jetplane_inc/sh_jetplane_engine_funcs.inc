#if defined sh_yandere_jet_engine_funcs
  #endinput
#endif
#define sh_yandere_jet_engine_funcs

#define FlameRate 5
#define SoundRate 1
#define JETPLANE_GRAVITY_MULT 1.0
#define JETPLANE_PHYS_UPDATE_TIME 0.05

#define JETPLANE_THRUST 100.0
#define JETPLANE_MASS 1.0
#define JETPLANE_CAR 0.045
#define JETPLANE_DIAMETER 33.0
#define JETPLANE_AREA ((JETPLANE_DIAMETER*JETPLANE_DIAMETER)*MATH_PI)
#define JETPLANE_AIR_RESISTANCE 0.005
#define JETPLANE_DRAG_CONST (JETPLANE_AREA*JETPLANE_CAR*JETPLANE_AIR_RESISTANCE)


#define JETPLANE_FLY_SOUND "shmod/yandere/jetsounds/engine/fly2.wav"
#define JETPLANE_IDLE_SOUND "shmod/yandere/jetsounds/engine/idle.wav"
#define JETPLANE_BLOW_SOUND "shmod/yandere/jetsounds/engine/blow.wav"

#define JETPLANE_ACCEL_PER_SEC (JETPLANE_THRUST/JETPLANE_MASS)

native Float:get_jet_fuel(jet_id)
native set_jet_fuel(jet_id,Float:fuel_ammount)
native get_jet_throttle(id)
native set_jet_throttle(id,on_or_of)
native get_jet_airbrakes(id)
native set_jet_airbrakes(id,on_or_of)
native get_jet_rightflapon(id)
native set_jet_rightflapon(id,on_or_of)
native get_jet_leftflapon(id)
native set_jet_leftflapon(id,on_or_of)
native get_jet_right_rollflapon(id)
native set_jet_right_rollflapon(id,on_or_of)
native get_jet_left_rollflapon(id)
native set_jet_left_rollflapon(id,on_or_of)
native get_jet_downflapon(id)
native set_jet_downflapon(id,on_or_of)
native get_jet_upflapon(id)
native set_jet_upflapon(id,on_or_of)
native reset_jet_fuel(jet_id)
native Float:get_user_fuel_ammount(id)
native set_user_fuel_ammount(id,Float:ammount)
native reset_user_fuel_ammount(id)
native Float:get_jet_fuel_spend()
native Float:get_jet_speed()
native Float:get_jet_accelerate_const()
native Float:jet_get_turn_inc_const()
native Float:jet_get_max_turn_const()
native Float:jet_get_stabilizer_mushyness()

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
