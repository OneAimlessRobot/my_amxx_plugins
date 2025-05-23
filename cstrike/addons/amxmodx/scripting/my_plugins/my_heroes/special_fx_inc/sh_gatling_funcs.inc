#if defined sh_special_funcs
  #endinput
#endif
#define sh_special_funcs

#define EFFECT_SHOT_SFX "shmod/Teliko/counter.wav"
#define GATLING_V_MODEL "models/shmod/yakui/v_m249.mdl"
#define GATLING_P_MODEL "models/shmod/yakui/p_m249.mdl"

#define NUM_OF_EFFECT_COLORS 10


enum
{
	KILL=1,
	GLOW,
	POISON,
	STUN,
	RADIOACTIVE,
	MORPHINE,
	WEED,
	COCAINE,
	BLIND,
	METYLPHENIDATE,
}

new const kill_color[4]={0, 255, 255, 255}

#define PILL_CLASSNAME "pill_gatling_pill"

#define POISON_TASKID 13876
#define UNPOISON_TASKID 13879
#define POISON_PERIOD 1.0
#define POISON_TIME 5.0
#define POISON_DAMAGE 40
#define POISON_TIMES floatround(floatdiv(POISON_TIME,POISON_PERIOD))

new const poison_color[4]={80, 240, 30, 255}

#define GLOW_TASKID 14509
#define UNGLOW_TASKID 14519
#define GLOW_PERIOD 1.0
#define GLOW_TIME 5.0
#define GLOW_TIMES floatround(floatdiv(GLOW_TIME,GLOW_PERIOD))


new const glow_color[4]={100, 8, 100, 255}


#define STUN_PERIOD 4.0
#define STUN_SPEED 70.0

new const stun_color[4]={100, 100, 100, 255}

#define RADIOACTIVE_TASKID 11986
#define UNRADIOACTIVE_TASKID 11996
#define RADIOACTIVE_PERIOD 1.0
#define RADIOACTIVE_TIME 5.0
#define RADIOACTIVE_DAMAGE 40
#define RADIOACTIVE_TIMES floatround(floatdiv(RADIOACTIVE_TIME,RADIOACTIVE_PERIOD))


new const radioactive_color[4]={240, 80, 30,  255}
#define MORPHINE_TASKID 14112
#define UNMORPHINE_TASKID 14911
#define MORPHINE_PERIOD 1.0
#define MORPHINE_HP_ADD 50
#define MORPHINE_TIME 5.0
#define MORPHINE_TIMES floatround(floatdiv(MORPHINE_TIME,MORPHINE_PERIOD))


new const morphine_color[4]={80, 240, 0, 255}
#define WEED_TASKID 11420
#define UNWEED_TASKID 11422
#define WEED_GRAVITY 0.1
#define WEED_PERIOD 0.1
#define WEED_TIME 4.0
#define WEED_TIMES floatround(floatdiv(WEED_TIME,WEED_PERIOD))


new const weed_color[4]={80, 240, 90, 255}


#define COCAINE_TASKID 11666
#define UNCOCAINE_TASKID 11669
#define COCAINE_SPEED 1000.0
#define COCAINE_PERIOD 0.1
#define COCAINE_TIME 4.0
#define COCAINE_TIMES floatround(floatdiv(COCAINE_TIME,COCAINE_PERIOD))

new const cocaine_color[4]={250, 10, 30, 255}
#define BLIND_TASKID 12226
#define BLIND_PERIOD 0.1
#define BLIND_TIME 4.0
#define BLIND_TIMES floatround(floatdiv(BLIND_TIME,BLIND_PERIOD))


new const blind_color[4]={255, 255, 255, 255}

#define FOCUS_TASKID 10001
#define UNFOCUS_TASKID 10010
#define FOCUS_PERIOD 1.0
#define FOCUS_TIME 4.0
#define FOCUS_TIMES floatround(floatdiv(FOCUS_TIME,FOCUS_PERIOD))


new const focus_color[4]={10, 10, 10, 255}

#define NO_RECOIL_WEAPONS_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define XO_WEAPON 4
#define m_pPlayer 41


#define PILL_RADIUS 30.0

#define PILL_SPEED 2000.0

#define PILL_SHOOT_PERIOD 0.001

#define PILL_SHOOT_RANDOMNESS 0.0

#define PILL_RELOAD_TASKID 7218

#define YAKUI_HUD_TASKID 12286


#define MAX_ENTITIES 2048
new m_trail
new gHeroID
new const gHeroName[] = "Yakui"
new gHasYakui[SH_MAXSLOTS+1]
new gPillGatlingEngaged[SH_MAXSLOTS+1]
new bool:pill_loaded[SH_MAXSLOTS+1]
new gNumPills[SH_MAXSLOTS+1]
new gCurrFX[SH_MAXSLOTS+1]

new pill_fx[MAX_ENTITIES]

new hud_sync

new const gunsound[] = "shmod/yakui/m249-1.wav";

new gHeroLevel

new max_pills

//native player_prethink_gatling(id)
native gatling_set_num_pills(id,value_to_set)
native gatling_get_num_pills(id)

native gatling_set_fx_num(id,value_to_set)
native gatling_get_fx_num(id)


native gatling_set_pill_fx_num(pillid,value_to_set)
native gatling_get_pill_fx_num(pillid)

native gatling_get_hero_id()
native gatling_set_hero_id(value_to_set)

native gatling_dec_num_pills(id)
native uneffect_user_handler(id)
native make_effect(vic,attacker)
native make_effect_direct(vic,attacker,fx_num)
native gatling_set_has_yakui(id,value_to_set)
native gatling_get_has_yakui(id)


native gatling_set_pillgatling(id,value_to_set)
native gatling_get_pillgatling(id)


native client_isnt_hitter(id)
native launch_pill(id)
native clear_pills()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
