#if defined sh_damage_sources_aux_code
  #endinput
#endif
#define sh_damage_sources_aux_code


#define Struct  enum


#define MAX_SH_CUSTOM_DMG_LONG_NAME_LEN 31
#define MAX_SH_CUSTOM_DMG_SHORT_NAME_LEN 31
#define MAX_SH_CUSTOM_DMG_SOURCES 999

#define SAFE_BUFFER_SIZE (MAX_SH_CUSTOM_DMG_SHORT_NAME_LEN)


enum sh_extra_damage_struct{

  short_dmg_name[SAFE_BUFFER_SIZE+1],
  long_dmg_name[SAFE_BUFFER_SIZE+1],
  the_wpn_id


}

#define is_valid_custom_dmg_source(%1) (((%1) >0) && ((%1) < MAX_SH_CUSTOM_DMG_SOURCES))

#define is_generic_dmg_source(%1) ((%1)==-1)

stock fill_up_dmg_struct(short_wpn_name[SAFE_BUFFER_SIZE+1],
          long_wpn_name[SAFE_BUFFER_SIZE+1],
          dmg_struct[sh_extra_damage_struct],
          wpn_id){

            copy(dmg_struct[short_dmg_name],charsmax(dmg_struct[short_dmg_name]),short_wpn_name)
            
            copy(dmg_struct[long_dmg_name],charsmax(dmg_struct[long_dmg_name]),long_wpn_name)
            
            dmg_struct[the_wpn_id]=wpn_id
}

native sh_log_custom_damage_source(hero_id=-2,short_name[SAFE_BUFFER_SIZE+1]="",long_name[SAFE_BUFFER_SIZE+1]="",is_a_melee=1);
native sh_get_generic_dmg_source_wpn_id()