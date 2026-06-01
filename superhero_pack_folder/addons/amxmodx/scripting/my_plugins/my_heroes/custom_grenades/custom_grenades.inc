#if defined sh_custom_grenades_inc
  #endinput
#endif
#define sh_custom_grenades_inc

#define SH_CUSTOM_GRENADE_CHARGE_PERIOD 0.1

enum sh_grenade_type{

    GREN_NONE=0,
    GREN_MOLLY,
    GREN_CHAFF,
    GREN_SLEEP,
    GREN_CO2,
    GREN_SHOCK,
    GREN_FREEZE,
    GREN_DISRUPT,
    GREN_SHRAPNEL,
    GREN_MARKER,
    GREN_CONC,
    GREN_WET

}
native get_custom_grenade_ammo(id, sh_grenade_type:gren_type)
native set_custom_grenade_ammo(id, sh_grenade_type:gren_type, value_of_ammo)
native give_custom_grenades(id, sh_grenade_type:gren_type, value_of_ammo)