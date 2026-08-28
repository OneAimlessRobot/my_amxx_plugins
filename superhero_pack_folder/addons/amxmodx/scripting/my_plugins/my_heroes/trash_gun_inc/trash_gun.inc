#if defined sh_tr45h_gun5
  #endinput
#endif
#define sh_tr45h_gun5

native bool:player_wpn_is_trash_wpn(pid, wpnid)


/*

  it returns what is left

  leaving the depleted damage

  makes the function merely return what is left

  without changing the value on the entity

*/

native Float:deplete_trash_wpn_dmg_reserve(wpn_ent, Float:damage_to_deplete = 0.0)