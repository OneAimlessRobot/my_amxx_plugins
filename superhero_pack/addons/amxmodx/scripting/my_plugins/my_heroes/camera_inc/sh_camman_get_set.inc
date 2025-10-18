#if defined sh_camman_get_set
  #endinput
#endif
#define sh_camman_get_set


stock gHeroID

stock const gHeroName[] = "Camman"

native camman_set_num_cameras(id,value_to_set)
native camman_get_num_cameras(id)
native camman_get_max_cameras()

native camman_dec_num_cameras(id)
native camman_inc_num_cameras(id)



native camman_set_has_camman(id,value_to_set)
native camman_get_has_camman(id)

native camman_get_disarmable()

native camman_set_hero_id(id)
native camman_get_hero_id()

native client_isnt_hitter(id)


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
