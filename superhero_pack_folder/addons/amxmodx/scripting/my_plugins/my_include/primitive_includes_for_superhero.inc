#if defined prmitive_includes_superhero_inc
  #endinput
#endif
#define prmitive_includes_superhero_inc


#tryinclude "../my_include/randomx.inc"

#if defined SHCORE

  #tryinclude "../../include/amxmisc.inc"
  #tryinclude "../../include/csx.inc"
  #tryinclude "../../include/cstrike.inc"

  #define AUX_STUFF_GIVE_MACROS
  #define AUX_STUFF_GIVE_HITPOINTS

#else

  #tryinclude "../../include/amxmodx.inc"
  #tryinclude "../../include/fun.inc"

  #define AUX_STUFF_GIVE_ENT_STOCKS
  #define AUX_STUFF_GIVE_MACROS
  #define AUX_STUFF_GIVE_WEAPONS
  #define AUX_STUFF_GIVE_HITPOINTS

#endif

#tryinclude "../../include/hamsandwich.inc"
#tryinclude "../../include/fakemeta.inc"
#tryinclude "../../include/fun.inc"
#tryinclude "../my_include/auxiliar_stuff.inc"
#tryinclude "../my_include/sh_hero_array_module.inc"
#tryinclude "../../include/cstrike.inc"
#tryinclude "../my_include/superheroconst.inc"
