#if defined sh_aux_natives_pt5
  #endinput
#endif
#define sh_aux_natives_pt5


#define default_morph_state_sound "items/suitchargeno1.wav"


native prepare_shero_aux_lib_pt5()
native sh_reset_player_hero_player_model(id)
native sh_register_superheromod_model(gHeroID,
                        const filename_ct[STRING_SIZE],
                        const filename_t[STRING_SIZE],
                        const morph_string[STRING_SIZE],
                        const hud_msg_morph[SH_HUD_MSG_BUFF_SIZE],
                        const hud_msg_unmorph[SH_HUD_MSG_BUFF_SIZE],
                        const morph_sound_sample[STRING_SIZE]=default_morph_state_sound)
