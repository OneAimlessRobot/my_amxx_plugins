#if defined sh_get_set
  #endinput
#endif
#define sh_get_set

#define EFFECT_SHOT_SFX "shmod/Teliko/counter.wav"
#define GATLING_V_MODEL "models/shmod/yakui/v_minigun.mdl"
#define GATLING_P_MODEL "models/shmod/yakui/p_minigun.mdl"


native gatling_set_num_pills(id,value_to_set)
native gatling_get_num_pills(id)

native gatling_set_num_rockets(id,value_to_set)
native gatling_get_num_rockets(id)

native gatling_set_fx_num(id,value_to_set)
native gatling_get_fx_num(id)

native gatling_dec_num_pills(id)
native gatling_dec_num_rockets(id)

native gatling_get_hero_id()
native gatling_set_hero_id(id)


native sh_get_pill_color(fx_num,attacker,color[3])


native make_effect(vic,attacker,gHeroId,fx_num=-1,bool:override=false)


native uneffect_user_handler(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
