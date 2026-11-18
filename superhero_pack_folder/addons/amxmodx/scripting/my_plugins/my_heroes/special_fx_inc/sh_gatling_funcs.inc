#if defined sh_pill_gat_funcs
  #endinput
#endif
#define sh_pill_gat_funcs

#define YAKUI_WEAPON_CLASSID CSW_M249


native gatling_set_user_pillgatling(id, bool:value, start_ammo = 100)

native gatling_set_num_pills(id,value_to_set)
native gatling_dec_num_pills(id)

native gatling_set_pillgatling(id,value_to_set)
native gatling_get_pillgatling(id)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
