#if defined sh_special_fx
  #endinput
#endif
#define sh_special_fx


#define POISON_DMG_MULT 2.0
#define POISON_DAMAGE_PCT 0.05





#define STUN_SPEED 70.0



#define MORPHINE_HP_ADD 50


#define WEED_GRAVITY 0.1

#define METYLPHENIDATE_RECOIL_COEFF 0.2


#define COCAINE_SPEED 1000.0
#define COCAINE_FIRE_RATE_MULT 3.0
#define COCAINE_RELOAD_RATE_MULT 3.0




#define FOCUS_XPMULT 4.0



enum fx_id{
	FX_ID_NONE=0,
	KILL,
	GLOW,
	POISON,
	STUN,
	RADIOACTIVE,
	MORPHINE,
	WEED,
	COCAINE,
	BLIND,
	METYLPHENIDATE,
	BATH
}


#define FX_COLOR_OFFSET(%1) (sh_custom_color-sh_custom_color:fx_id+sh_custom_color:_:%1)

native sh_effect_user(id,attacker,gHeroID)
native fx_id:sh_gen_effect()
native sh_effect_user_direct(id,attacker,gHeroID,fx_id:fx_num)
native sh_uneffect_user(id)
native sh_get_fx_color_name(fx_id:fx_num,fx_arr[3],name[128])
native fx_id:sh_get_user_effect(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
