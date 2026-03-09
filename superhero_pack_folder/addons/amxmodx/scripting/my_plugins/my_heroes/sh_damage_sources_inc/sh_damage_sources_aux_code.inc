#if defined sh_damage_sources_aux_code
  #endinput
#endif
#define sh_damage_sources_aux_code


#define Struct  enum

#define MAX_SH_CUSTOM_DMG_LONG_NAME_LEN 31
#define MAX_SH_CUSTOM_DMG_SHORT_NAME_LEN 31
#define MAX_SH_CUSTOM_DMG_SOURCES 1024

#define SAFE_BUFFER_SIZE (MAX_SH_CUSTOM_DMG_SHORT_NAME_LEN)


stock generic_dmg_source_wpn_id;
const generic_dmg_source_is_melee=1;
stock generic_dmg_hero_name[MAX_HERO_NAME_LENGTH]="some_hero"
stock generic_dmg_source_name[SAFE_BUFFER_SIZE-1]="sh_generic_dmg";
stock generic_dmg_source_long_name[SAFE_BUFFER_SIZE-1]="sh_generic_dmg";

//These are indexed by "SH_CUSTOM_DMG_WPN_ID"
//and the max number of weapons is "MAX_SH_CUSTOM_DMG_SOURCES"

stock sh_damage_source_hero_ids[MAX_SH_CUSTOM_DMG_SOURCES]
stock sh_damage_source_is_a_melee[MAX_SH_CUSTOM_DMG_SOURCES]
stock sh_damage_source_short_names[MAX_SH_CUSTOM_DMG_SOURCES][SAFE_BUFFER_SIZE+1]
stock sh_damage_source_long_names[MAX_SH_CUSTOM_DMG_SOURCES][SAFE_BUFFER_SIZE+1]

//returns wpn_id to be used in calls to sh_extra_damage if desired

native sh_log_custom_damage_source(hero_id=-1,short_name[SAFE_BUFFER_SIZE+1]="",long_name[SAFE_BUFFER_SIZE+1]="",is_a_melee=1);