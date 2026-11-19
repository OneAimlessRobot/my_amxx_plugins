#if defined sh_pokemon_dmg_framework
  #endinput
#endif
#define sh_pokemon_dmg_framework


enum stat_struct_ids{

    STAT_SPEED_ID = 0,
    STAT_ATTACK_MULT,
    STAT_DEFENSE_MULT,
    STAT_SPECIAL_ATTACK_MULT,
    STAT_SPECIAL_DEFENSE_MULT,
    STAT_EVASIVENESS_MULT


}
/*
  returns true if application succeeded
  returns false otherwise

  go_up_or_go_down:

  true if stat should go up
  false if stat should go down

*/
native bool:sh_apply_staged_stat_boost(id, attacker, stat_struct_ids:the_stat_to_go_up, num_stages_to_apply, bool:go_up_or_go_down )

/*

  it returns true on success. false on failure

*/

native bool:sh_reset_player_stat_boosts(id, attacker)

native sh_check_player_boost_stage(id, stat_struct_ids:the_stat_to_check)