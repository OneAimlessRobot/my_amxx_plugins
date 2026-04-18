#if defined sh_bknife_fx
  #endinput
#endif
#define sh_bknife_fx



enum fx_bleed_type{
	NONE=0,
  BLEED_MINI,
  BLEED_NORMAL,
  BLEED_ULTRA,
  NUM_BLEED_TYPES
}

native sh_bleed_user(id,attacker,fx_bleed_type:bleed_type,gHeroID,heal_user=1)

native do_bleed_knife_attack(id,
          attacker,
          hero_id,
          slash_damage,
          stab_damage,
          optional_bool=1,
          const attack_name_string[128]="def_melee_bleed",
          const bleed_sound_sample[128]=PIERCE_WOUND_SFX,
          heal_attacker=1);

native sh_unbleed_user(id)
native make_bleed_fx(id)
native sh_get_user_is_bleeding(id)



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
