#if defined sh_aux_natives_pt12
  #endinput
#endif
#define sh_aux_natives_pt12

native bool:generic_heal(hud_msg_sync=-1,
					id,
					Float:added_hp,
					max_hp_to_clamp=-1,
					color_const=GREEN,
					user_will_glow=0,
					Float:glow_remove_timer=1.0,
					hud_alpha=-1,
					hud_will_glow=1,
					make_sound=1,
					const sound_sample_buff[128]=SPORE_HEAL_SFX)


native Float:sh_get_player_healthcap(player_id)

/*
	false == It was not able to register
	true == success at registration

*/
native bool:sh_register_hero_healthcap(heroID, Float:healthcap_to_set)