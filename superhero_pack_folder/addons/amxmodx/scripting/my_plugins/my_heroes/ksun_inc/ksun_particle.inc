#if defined sh_ksun_particle_funcs
  #endinput
#endif
#define sh_ksun_particle_funcs


#define KSUN_SPORE_MDL "models/shmod/predgun/preddisc.mdl"
#define SPORE_TRAVEL_SFX "roach/rch_smash.wav"


#define KSUN_HEAL_GLOW_TIME SHOOT_LOOP_PERIOD


#define SPORE_CLASSNAME "ksun_spore"

#define SPORE_SIZE 10.0
#define SPORE_RADIUS (5.0)

#define WALL_BUMP_LENGTH ((CENTER_CUBE_VEX_DISTANCE(SPORE_RADIUS)))



#define SPORE_DEAD_HP 1000.0

native get_from_player_spores(id,index)
native spore_launch(id)
native get_times_player_spiked_player(attacker,victim)
native inc_times_player_spiked_player(attacker,victim)
native dec_times_player_spiked_player(attacker,victim)

native get_times_player_spiked_by_player(victim,attacker)
native inc_times_player_spiked_by_player(victim,attacker)
native dec_times_player_spiked_by_player(victim,attacker)
native bool:ksun_heal(id, Float:damage, &actual_drain_result = 0)

native clean_ksun_spores_from_players(dying_or_new_round,everyone,player)
native ksun_glisten(id)
native check_who_player_is_sporing(id)
native check_by_whom_player_spored(id)