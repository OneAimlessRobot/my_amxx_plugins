#if defined sh_zenitsu_charge_inc
  #endinput
#endif
#define sh_zenitsu_charge_inc

#define ZENITSU_CHARGE_SPEED 3500.0
#define ZENITSU_DAMAGE 1600.0
#define ZENITSU_CHARGE_THINK_TIME 0.25
#define ZENITSU_CHARGE_COLLISION_DISTANCE_THRESHOLD 90.0

native zenitsu_get_has_touched_player(id)

native zenitsu_charge_execute(id)