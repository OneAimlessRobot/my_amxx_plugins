#if defined sh_aux_natives_pt13
  #endinput
#endif
#define sh_aux_natives_pt13


//returns true if registration was successful. false otherwise
//heroID to make into a ethereal hero
//the healthcap to give
//if < 1.0 (the default) no healthcap will be given to this hero
//ethereal heroes cannot:
//- be healed
//- be hit with most conventional damage
//they have:
//- less gravity (cvar ptr is passed (-1 for default ethereal gravity pcvar)
//the name of it is "sh_ethereal_heroes_gravity"


native bool:sh_register_elemental_probe_hero(heroID, Float:health_cap = -1.0, cvar_ptr = -1)

//returns true if registration was successful. false otherwise
//heroID to make into a demonic hero
//give pcvars to hp, ap and speed if you dont want the default ones
//these heroes will get no knockback
//and a configurable passive resistance to all conventional damage
//and kinetic superheromod damage


native bool:sh_register_hero_with_demonic_prepackage(heroID, ap_cvar_ptr = -1, hp_cvar_ptr = -1, speed_cvar_ptr = -1)