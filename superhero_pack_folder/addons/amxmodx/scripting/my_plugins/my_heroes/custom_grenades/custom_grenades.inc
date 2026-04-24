#if defined sh_custom_grenades_inc
  #endinput
#endif
#define sh_custom_grenades_inc

#define SH_CUSTOM_GRENADE_CHARGE_PERIOD 0.1
/**

#if defined sh_molly_funcs
  #endinput
#endif
#define sh_molly_funcs



native molly_uncharge_molly(id)


#if defined sh_sleep_grenade_funcs
  #endinput
#endif
#define sh_sleep_grenade_funcs

native sleep_nade_uncharge_sleep_nade(id)






#if defined sh_chaff_funcs
  #endinput
#endif
#define sh_chaff_funcs

native teliko_set_num_chaffs(id,value_to_set)
native teliko_get_num_chaffs(id)

native teliko_dec_num_chaffs(id)



native chaff_uncharge_chaff(id)

 */
enum sh_grenade_type{

    GREN_NONE=0,
    GREN_MOLLY,
    GREN_CHAFF,
    GREN_SLEEP,
    GREN_MAX_TYPES

}
native get_custom_grenade_ammo(id, sh_grenade_type:gren_type)
native set_custom_grenade_ammo(id, sh_grenade_type:gren_type, value_of_ammo)
native give_custom_grenades(id, sh_grenade_type:gren_type, value_of_ammo)
native uncharge_custom_nade(id, sh_grenade_type:gren_type)