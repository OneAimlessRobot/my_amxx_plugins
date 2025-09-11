#if defined sh_ksun_particle_funcs
  #endinput
#endif
#define sh_ksun_particle_funcs


#define KSUN_SPORE_MDL "models/shmod/predgun/preddisc.mdl"
#define SPORE_WOUND_SFX  "hornet/ag_hornethit1.wav"
#define SPORE_HEAL_SFX "shmod/ration.wav"
#define SPORE_TRAVEL_SFX "roach/rch_smash.wav"


#define KSUN_HEAL_GLOW_TIME SHOOT_LOOP_PERIOD


#define SPORE_CLASSNAME "ksun_spore"

#define SPORE_SIZE 5.0


#define FIRE_LOOP_TASKID 65231239
#define UNFIRE_LOOP_TASKID 12344323
#define FIRE_DELAY 0.2

#define FOLLOW_LOOP_TASKID 2329129
#define UNFOLLOW_LOOP_TASKID 1223332
#define FOLLOW_LOOP_PERIOD 0.2
#define FOLLOW_LOOP_TIMES floatround(floatdiv(get_follow_time(),FOLLOW_LOOP_PERIOD))


#define SPORE_DEAD_HP 1000.0

native get_from_player_spores(id,index)
native Float:get_spore_base_health()
native spore_launch(id)
native spores_clear()
native get_times_player_spiked_player(attacker,victim)
native inc_times_player_spiked_player(attacker,victim)
native dec_times_player_spiked_player(attacker,victim)

native get_times_player_spiked_by_player(victim,attacker)
native inc_times_player_spiked_by_player(victim,attacker)
native dec_times_player_spiked_by_player(victim,attacker)
native Float:get_spike_base_damage_debt()
native bool:heal(id, Float:damage)

native clean_ksun_spores_from_players(dying_or_new_round,everyone,player)
native ksun_glisten(id)
native check_who_player_is_sporing(id)
native check_by_whom_player_spored(id)