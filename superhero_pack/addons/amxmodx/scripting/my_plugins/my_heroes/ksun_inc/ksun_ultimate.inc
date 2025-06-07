#if defined sh_ksun_ultimate_funcs
  #endinput
#endif
#define sh_ksun_ultimate_funcs


#define KSUN_ULTIMATE_TASKID 23712316
#define UNKSUN_ULTIMATE_TASKID 9723512
#define KSUN_ULTIMATE_LOOP_PERIOD 0.4
#define KSUN_ULTIMATE_LOOP_DEC 30
#define KSUN_ULTIMATE_LOOP_TIMES floatround(floatdiv(float(ksun_supply_capacity),float(KSUN_ULTIMATE_LOOP_DEC)))



native ksun_player_is_in_ultimate(id)

native ksun_player_is_ultimate_ready(id)

native ksun_unultimate_user(id)

native ksun_player_engage_ultimate(id)


native ksun_get_player_supply_points(id)


native ksun_set_player_supply_points(id, value)

native ksun_inc_player_supply_points(id, value)

native ksun_dec_player_supply_points(id, value)
