#if defined sh_get_set
  #endinput
#endif
#define sh_get_set

#define EFFECT_SHOT_SFX "shmod/Teliko/counter.wav"
#define GATLING_V_MODEL "models/shmod/yakui/v_minigun.mdl"
#define GATLING_P_MODEL "models/shmod/yakui/p_minigun.mdl"

#define YAKUI_MORPH_TASKID 127186


native gatling_set_num_pills(id,value_to_set)
native gatling_get_num_pills(id)

native gatling_set_num_rockets(id,value_to_set)
native gatling_get_num_rockets(id)

native gatling_set_fx_num(id,value_to_set)
native gatling_get_fx_num(id)

native gatling_dec_num_pills(id)
native gatling_dec_num_rockets(id)

native gatling_set_has_yakui(id,value_to_set)
native gatling_get_has_yakui(id)

native gatling_set_hero_id(id)
native gatling_get_hero_id()


native sh_get_pill_color(fx_num,attacker,color[4])


native make_effect(vic,attacker,gHeroId)

native make_effect_direct(vic,attacker,gHeroID,fx_num)

native uneffect_user_handler(id,gHeroID)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
