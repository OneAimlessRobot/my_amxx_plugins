#if defined sh_aux_natives_pt14
  #endinput
#endif
#define sh_aux_natives_pt14
/**

generic tracer logic sfx masks!

*/

enum weapon_tracer_fx_flags (<<= 1){
	tracer_sfx_show_nothing = 0,
	tracer_sfx_show_laser_line = 1,
	tracer_sfx_show_glow_aura,
	tracer_sfx_show_play_shoot_sound,


}


native bool:generic_weapon_tracer_logic(
								Attacker,
								bool:custom_boolean=true,
								weapon_id=-1,
								hero_id=-1,
								bool:exclude_custom_weapons= false,
								sh_custom_color:color_vector_indices[3]={CUSTOM,CUSTOM,CUSTOM},
								weapon_tracer_fx_flags:weapon_tracer_fx_flags = tracer_sfx_show_laser_line,
      					const default_sound_sample[128]=LASER_LINE_DEFAULT_SOUND);
