#if defined sh_teliko_get_set
  #endinput
#endif
#define sh_teliko_get_set


#define CHAFF_W_MODEL "models/shmod/lara/spear/w_spear.mdl"
#define CHAFF_V_MODEL "models/shmod/lara/spear/v_spear.mdl"
#define CHAFF_P_MODEL "models/shmod/lara/spear/p_spear.mdl"
#define NOCHAFF_V_MODEL "models/shmod/lara/spear/v_nospear.mdl"
#define CHAFF_HIT_SFX  "shmod/lara/spear/spear_hit.wav"
#define CHAFF_THROW_SFX  "shmod/lara/spear/spear_throw.wav"
#define CHAFF_WOUND_SFX  "shmod/lara/spear/spear_wound.wav"
#define TELIKO_SIDEARM_CLASSID CSW_P228
#define TELIKO_RIFLE_CLASSID CSW_FAMAS

#define TELIKO_SIDEARM_WEAPON_NAME "weapon_p228"
#define TELIKO_RIFLE_WEAPON_NAME "weapon_famas"

stock gHeroID

stock const gHeroName[] = "Teliko"

native teliko_set_num_chaffs(id,value_to_set)
native teliko_get_num_chaffs(id)

native teliko_dec_num_chaffs(id)



native teliko_set_has_teliko(id,value_to_set)
native teliko_get_has_teliko(id)

native teliko_set_hero_id(id)
native teliko_get_hero_id()


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
