#if defined sh_lara_get_set
  #endinput
#endif
#define sh_lara_get_set


#define SPEAR_W_MODEL "models/shmod/lara/spear/w_spear.mdl"
#define SPEAR_V_MODEL "models/shmod/lara/spear/v_spear.mdl"
#define SPEAR_P_MODEL "models/shmod/lara/spear/p_spear.mdl"
#define NOSPEAR_V_MODEL "models/shmod/lara/spear/v_nospear.mdl"
#define SPEAR_HIT_SFX  "shmod/lara/spear/spear_hit.wav"
#define SPEAR_THROW_SFX  "shmod/lara/spear/spear_throw.wav"
#define SPEAR_WOUND_SFX  "shmod/lara/spear/spear_wound.wav"

new gHeroID

new const redline_color[4]={255,1,1,255}
new const gHeroName[] = "Lara"

native spear_set_num_spears(id,value_to_set)
native spear_get_num_spears(id)

native spear_dec_num_spears(id)



native spear_set_has_lara(id,value_to_set)
native spear_get_has_lara(id)

native spear_set_hero_id(id)
native spear_get_hero_id()


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
