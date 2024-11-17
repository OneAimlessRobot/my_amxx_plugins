#if defined sh_special_funcs
  #endinput
#endif
#define sh_special_funcs

#define EFFECT_SHOT_SFX "shmod/Teliko/counter.wav"
#define GATLING_V_MODEL "models/shmod/yakui/v_m249.mdl"
#define GATLING_P_MODEL "models/shmod/yakui/p_m249.mdl"

#define NUM_OF_EFFECTS 5

#define PILL_CLASSNAME "pill_gatling_pill"

#define POISON_TASKID 13876
#define POISON_TIMES 10
#define POISON_PERIOD 1.0
#define POISON_DAMAGE 40

#define STUN_PERIOD 4.0
#define STUN_SPEED 70.0

#define RADIOACTIVE_TASKID 11986
#define RADIOACTIVE_PERIOD 1.0
#define RADIOACTIVE_TIMES 5
#define RADIOACTIVE_DAMAGE 40


#define MORPHINE_HP_ADD 50


#define WEED_TASKID 11420
#define WEED_GRAVITY 0.1
#define WEED_PERIOD 0.1
#define WEED_TIME 4.0
#define WEED_TIMES floatround(floatdiv(WEED_TIME,WEED_PERIOD))




#define COCAINE_TASKID 11666
#define COCAINE_SPEED 1000.0
#define COCAINE_PERIOD 0.1
#define COCAINE_TIME 4.0
#define COCAINE_TIMES floatround(floatdiv(COCAINE_TIME,COCAINE_PERIOD))

#define BLIND_TASKID 12226
#define BLIND_PERIOD 0.1
#define BLIND_TIME 4.0
#define BLIND_TIMES floatround(floatdiv(BLIND_TIME,BLIND_PERIOD))


#define PILL_RADIUS 30.0

#define PILL_SPEED 2000.0

#define PILL_SHOOT_PERIOD 0.001

#define PILL_SHOOT_RANDOMNESS 0.0

#define PILL_RELOAD_TASKID 7218

#define YAKUI_HUD_TASKID 12286

new m_trail
new gHeroID
new const gHeroName[] = "Yakui"
new gHasYakui[SH_MAXSLOTS+1]
new gPillGatlingEngaged[SH_MAXSLOTS+1]
new bool:pill_loaded[SH_MAXSLOTS+1]
new gNumPills[SH_MAXSLOTS+1]
new gCurrFX[SH_MAXSLOTS+1]

new hud_sync

new const gunsound[] = "shmod/yakui/m249-1.wav";

new gHeroLevel

new max_pills

//native player_prethink_gatling(id)
native gatling_set_num_pills(id,value_to_set)
native gatling_get_num_pills(id)

native gatling_set_fx_num(id,value_to_set)
native gatling_get_fx_num(id)

native gatling_get_hero_id()
native gatling_set_hero_id(value_to_set)

native gatling_dec_num_pills(id)
native uneffect_user_handler(id)
native make_effect(vic,attacker)
native gatling_set_has_yakui(id,value_to_set)
native gatling_get_has_yakui(id)


native gatling_set_pillgatling(id,value_to_set)
native gatling_get_pillgatling(id)


native client_isnt_hitter(id)
native launch_pill(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
