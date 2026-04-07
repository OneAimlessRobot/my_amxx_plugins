#if defined sh_damage_sources_aux_code
  #endinput
#endif
#define sh_damage_sources_aux_code


#define Struct  enum

#define MAX_SH_CUSTOM_DMG_LONG_NAME_LEN 31
#define MAX_SH_CUSTOM_DMG_SHORT_NAME_LEN 31
#define MAX_SH_CUSTOM_DMG_SOURCES 127

#define SAFE_BUFFER_SIZE (MAX_SH_CUSTOM_DMG_SHORT_NAME_LEN)

native sh_log_custom_damage_source(hero_id=-2,short_name[SAFE_BUFFER_SIZE+1]="",long_name[SAFE_BUFFER_SIZE+1]="",is_a_melee=1);
native sh_get_generic_dmg_source_wpn_id()