#if defined sh_aux_natives_pt7
  #endinput
#endif
#define sh_aux_natives_pt7

native prepare_shero_aux_lib_pt7()

native sh_play_custom_sound(id,sound_id,channel,
            Float:volume=VOL_NORM,
            Float:attenuation=ATTN_NONE,
            flags=0,
            pitch=PITCH_NORM)

native sh_stop_custom_sound(id,channel)

native sh_register_custom_sound(file_name_buff[STRING_SIZE])