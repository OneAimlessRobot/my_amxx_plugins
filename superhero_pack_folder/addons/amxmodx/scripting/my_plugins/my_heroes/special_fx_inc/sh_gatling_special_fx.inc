#if defined sh_special_fx
  #endinput
#endif
#define sh_special_fx




#define XO_WEAPON 4
#define m_ppPlayer 41




#define POISON_DMG_MULT 2.0
#define POISON_DAMAGE 40





#define STUN_SPEED 70.0

#define RADIOACTIVE_DAMAGE 40
#define RADIOACTIVE_DAMAGE_VULNERABILITY_COEFF 0.40


#define MORPHINE_HP_ADD 50


#define WEED_GRAVITY 0.1




#define COCAINE_SPEED 1000.0
#define COCAINE_FIRE_RATE_MULT 3.0
#define COCAINE_RELOAD_RATE_MULT 3.0




#define FOCUS_XPMULT 4.0



enum fx_id{
	NONE=0,
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
	BATH,
	NUM_FX
}
enum fx_task_parameter_id{
	Float:fx_task_period,
	Float:fx_task_time,
	fx_task_repeats,
	fx_task_apply_id,
	fx_task_remove_id,
	fx_task_apply_func_name[128],
	fx_task_remove_func_name[128]
}

stock const fx_colors[_:NUM_FX][4]={
			{0,0,0,0},
			{1, 255, 255, 255},
			{255, 255, 255, 255},
			{80, 240, 30, 255},
			{100, 100, 100, 255},
			{240, 80, 30,  255},
			{80, 240, 1, 255},
			{80, 240, 90, 255},
			{250, 10, 30, 255},
			{255, 255, 255, 255},
			{10, 10, 10, 255},
			{179, 66, 5, 255}
}
stock const fx_names[_:NUM_FX][]={
			"no drug",
			"cyanide",
			"glowstick juice",
			"poison",
			"stunner",
			"uranium",
			"morphine",
			"weed",
			"cocaine",
			"blindness",
			"metylphenidate",
			"bath salts",
}
stock const fx_remove_strings[_:NUM_FX][]={
			"We have removed nothing!",
			"We have removed nothing! You should be dead...",
			"Removed ur glow bro!",
			"Removed ur stun bro!",
			"Removed ur poisan!",
			"Removed ur chernobyl!",
			"Removed ur heals!",
			"Removed ur weed!",
			"Removed ur 80s!",
			"Removed ur blindess!",
			"Removed ur college pills!",
			"Removed ur spicy college pills!"
	
}
stock const Float:fx_rarity_slice_edges[_:NUM_FX]={
				0.0,
				0.01,
				0.38,
				0.46,
				0.50,
				0.58,
				0.64,
				0.71,
				0.79,
				0.85,
				0.90,
				0.95
}
stock fx_task_parameters[_:NUM_FX][fx_task_parameter_id]={	
					{-1.0,5.0,-1,-1,-1,"",""},
					{-1.0,5.0,-1,-1,-1,"",""},
					{1.0,5.0,-1,-1,-1,"glow_task","unglow_task"},
					{1.0,5.0,-1,-1,-1,"poison_task","unpoison_task"},
					{0.1,5.0,1,-1,-1,"stun_task","unstun_task"},
					{0.1,5.0,1,-1,-1,"radioactive_task","unradioactive_task"},
					{1.0,5.0,-1,-1,-1,"morphine_task","unmorphine_task"},
					{1.0,5.0,-1,-1,-1,"weed_task","unweed_task"},
					{1.0,5.0,-1,-1,-1,"cocaine_task","uncocaine_task"},
					{1.0,5.0,-1,-1,-1,"blind_task","unblind_task"},
					{1.0,5.0,-1,-1,-1,"focus_task","unfocus_task"},
					{1.0,5.0,-1,-1,-1,"bath_task","unbath_task"}

}
native sh_effect_user(id,attacker,gHeroID)
native sh_gen_effect()
native sh_effect_user_direct(id,attacker,gHeroID,fx_num)
native sh_uneffect_user(id,gHeroID,fx_num)
native sh_get_fx_color_name(fx_num,fx_arr[4],name[128])
native sh_get_user_effect(id)
native set_render_with_fx_num(id,the_color_num,reveal_user=1)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
