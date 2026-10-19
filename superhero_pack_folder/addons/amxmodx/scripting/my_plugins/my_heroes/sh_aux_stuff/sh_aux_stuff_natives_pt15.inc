#if defined sh_aux_natives_pt15
  #endinput
#endif
#define sh_aux_natives_pt15


native bool:sh_get_player_has_hero_projectile_weapon(player_id, my_weapon_ids:the_weapon_id)
/*

  weapon gating macro: the first parameter is who is attacking, the second parameter is the weapon id
  It is assumed that we know that the person has the weapon!
  the third parameter and fourth parameters is what to do in case we have the projectile weapon because of one of our heroes
  if %3 is continue or break, %4 should not be used
*/
#define weapon_gating_macro_code_snippet(%1,%2,%3,%4) if(sh_get_player_has_hero_projectile_weapon(%1,my_weapon_ids:%2)) %3 %4