#if defined sh_sapper_get_set
  #endinput
#endif
#define sh_sapper_get_set


stock gHeroID

stock const gHeroName[] = "Sapper"

native sapper_set_num_mines(id,value_to_set)
native sapper_get_num_mines(id)

native sapper_dec_num_mines(id)



native sapper_set_has_sapper(id,value_to_set)
native sapper_get_has_sapper(id)

native sapper_get_disarmable()

native sapper_set_hero_id(id)
native sapper_get_hero_id()


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
