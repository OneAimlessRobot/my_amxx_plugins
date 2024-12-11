#if defined sh_special_fx
  #endinput
#endif
#define sh_special_fx


#define NO_RECOIL_WEAPONS_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define XO_WEAPON 4
#define m_pPlayer 41




#define POISON_TASKID 13876
#define UNPOISON_TASKID 13879
#define POISON_PERIOD 1.0
#define POISON_TIME 5.0
#define POISON_DMG_MULT 2.0
#define POISON_DAMAGE 40
#define POISON_TIMES floatround(floatdiv(POISON_TIME,POISON_PERIOD))


#define GLOW_TASKID 14509
#define UNGLOW_TASKID 14519
#define GLOW_PERIOD 1.0
#define GLOW_TIME 5.0
#define GLOW_TIMES floatround(floatdiv(GLOW_TIME,GLOW_PERIOD))




#define STUN_PERIOD 4.0
#define STUN_SPEED 70.0


#define RADIOACTIVE_TASKID 11986
#define UNRADIOACTIVE_TASKID 11996
#define RADIOACTIVE_PERIOD 1.0
#define RADIOACTIVE_TIME 20.0
#define RADIOACTIVE_DAMAGE 40
#define RADIOACTIVE_TIMES floatround(floatdiv(RADIOACTIVE_TIME,RADIOACTIVE_PERIOD))


#define MORPHINE_TASKID 14112
#define UNMORPHINE_TASKID 14911
#define MORPHINE_PERIOD 1.0
#define MORPHINE_HP_ADD 50
#define MORPHINE_TIME 5.0
#define MORPHINE_TIMES floatround(floatdiv(MORPHINE_TIME,MORPHINE_PERIOD))


#define WEED_TASKID 11420
#define UNWEED_TASKID 11422
#define WEED_GRAVITY 0.1
#define WEED_PERIOD 0.1
#define WEED_TIME 4.0
#define WEED_TIMES floatround(floatdiv(WEED_TIME,WEED_PERIOD))




#define COCAINE_TASKID 11666
#define UNCOCAINE_TASKID 11669
#define COCAINE_SPEED 1000.0
#define COCAINE_PERIOD 0.1
#define COCAINE_TIME 4.0
#define COCAINE_TIMES floatround(floatdiv(COCAINE_TIME,COCAINE_PERIOD))

#define BLIND_TASKID 12226
#define BLIND_PERIOD 0.1
#define BLIND_TIME 4.0
#define BLIND_TIMES floatround(floatdiv(BLIND_TIME,BLIND_PERIOD))



#define FOCUS_TASKID 10001
#define UNFOCUS_TASKID 10010
#define FOCUS_PERIOD 1.0
#define FOCUS_TIME 4.0
#define FOCUS_TIMES floatround(floatdiv(FOCUS_TIME,FOCUS_PERIOD))

#define BATH_TASKID 11001
#define UNBATH_TASKID 10110
#define BATH_PERIOD 1.0
#define BATH_TIME 4.0
#define BATH_TIMES floatround(floatdiv(BATH_TIME,BATH_PERIOD))


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
	BATH,
}

new const kill_color[4]={1, 255, 255, 255}
new const poison_color[4]={80, 240, 30, 255}
new const glow_color[4]={255, 255, 255, 255}
new const stun_color[4]={100, 100, 100, 255}
new const radioactive_color[4]={240, 80, 30,  255}
new const morphine_color[4]={80, 240, 1, 255}
new const weed_color[4]={80, 240, 90, 255}
new const cocaine_color[4]={250, 10, 30, 255}
new const blind_color[4]={255, 255, 255, 255}
new const focus_color[4]={10, 10, 10, 255}
new const bath_color[4]={179, 66, 5, 255}

native sh_effect_user(id,attacker,gHeroID)
native sh_gen_effect()
native sh_effect_user_direct(id,attacker,gHeroID,fx_num)
native sh_uneffect_user(id,fx_num,gHeroID)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
