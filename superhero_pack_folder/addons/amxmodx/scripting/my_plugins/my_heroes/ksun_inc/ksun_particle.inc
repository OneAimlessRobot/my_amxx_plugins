#if defined sh_ksun_particle_funcs
  #endinput
#endif
#define sh_ksun_particle_funcs


#define KSUN_SPORE_MDL "models/shmod/predgun/preddisc.mdl"

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