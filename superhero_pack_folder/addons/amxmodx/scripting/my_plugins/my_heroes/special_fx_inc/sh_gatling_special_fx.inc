#if defined sh_special_fx
  #endinput
#endif
#define sh_special_fx



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
