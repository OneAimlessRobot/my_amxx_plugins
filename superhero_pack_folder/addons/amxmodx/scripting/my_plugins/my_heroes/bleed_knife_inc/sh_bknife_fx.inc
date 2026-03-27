#if defined sh_bknife_fx
  #endinput
#endif
#define sh_bknife_fx

#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)

#define BLEED_SFX "hornet/ag_hornethit1.wav"



enum fx_bleed_type{
	NONE=0,
  MINI_BLEED,
  BLEED,
  ULTRABLEED,
  NUM_BLEED_TYPES
}
enum bleed_task_parameter_id{
	Float:bleed_task_period,
	Float:bleed_task_time,
	bleed_task_repeats,
	bleed_task_apply_id,
	bleed_task_remove_id,
	bleed_task_apply_func_name[128],
	bleed_task_remove_func_name[128]
}
enum bleed_alpha_type{
  hud_alpha,
  render_alpha
}
stock const bleed_type_names[_:NUM_BLEED_TYPES][]={
			"no bleeding",
      "mini bleeding",
      "bleeding",
      "ultrableeding"
}
stock const bleed_type_damages[_:NUM_BLEED_TYPES]={
			0,
      10,
      40,
      40
}
stock const bleed_type_alphas[_:NUM_BLEED_TYPES][bleed_alpha_type]={
			{0,0},
      {50,255},
      {75,255},
      {120,255}
}
stock bleed_task_parameters[_:NUM_BLEED_TYPES][bleed_task_parameter_id]={	
					{-1.0,5.0,0,-1,-1,"",""},
					{1.0,5.0,0,-1,-1,"bleed_task","unbleed_task"},
					{1.0,5.0,0,-1,-1,"bleed_task","unbleed_task"},
					{0.25,5.0,0,-1,-1,"bleed_task","unbleed_task"}

}

native sh_bleed_user(id,attacker,fx_bleed_type:bleed_type,gHeroID)

native do_bleed_knife_attack(id,
          attacker,
          hero_id,
          slash_damage,
          stab_damage,
          optional_bool=1,
          const attack_name_string[128]="def_melee_bleed",
          const bleed_sound_sample[128]=BLEED_SFX);

native sh_unbleed_user(id)
native make_bleed_fx(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
