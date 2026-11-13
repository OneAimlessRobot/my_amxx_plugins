#if defined sh_aux_natives_pt5
  #endinput
#endif
#define sh_aux_natives_pt5


#define default_morph_state_sound "items/suitchargeno1.wav"


native prepare_shero_aux_lib_pt5()
native sh_register_superheromod_model(gHeroID,
                        const filename_ct[STRING_SIZE],
                        const filename_t[STRING_SIZE],
                        const morph_string[STRING_SIZE],
                        const hud_msg_morph[SH_HUD_MSG_BUFF_SIZE],
                        const hud_msg_unmorph[SH_HUD_MSG_BUFF_SIZE],
                        const morph_sound_sample[STRING_SIZE]=default_morph_state_sound)


native sh_register_superheromod_weapon_model(gHeroID,
                                              wpn_id,
                                              const filename_v_model[STRING_SIZE]="",
                                              const filename_p_model[STRING_SIZE]="",
                                              bool:ignore_v_model_if_empty=true,
                                              bool:ignore_p_model_if_empty=true)

/*
  the third parameter tells the module whether or not we should change the input buffer. its useful if you dont have one to give.
  which means the input model_name buffer wont change if the third parameter is false!

  it returns -1 if no model is set for this player!

*/
native sh_get_player_superhero_player_model(id, model_name[STRING_SIZE] = "", bool:copy_to_buffer = true)

/*

  the fourth parameter tells you whether you want to copy the v model or the p model to the buffer
  true for v model
  false for p model
  it assumes copy_to_buffer is true!
  otherwise it is undefined behaviour

  it returns -1 if no weapon model is set for this player for this weapon

*/
native sh_get_player_superhero_weapon_model(id, wpnId, model_name[STRING_SIZE] = "", bool:copy_to_buffer = true, bool:wants_v_model_or_p_model = true)

native sh_get_number_of_registered_player_models()
native sh_get_player_superhero_player_model_from_model_id(model_id, model_name[STRING_SIZE])

native sh_set_player_invert_teamglow_bit(id, bool:the_value_to_set)

native bool:sh_get_player_invert_teamglow_bit(id)
