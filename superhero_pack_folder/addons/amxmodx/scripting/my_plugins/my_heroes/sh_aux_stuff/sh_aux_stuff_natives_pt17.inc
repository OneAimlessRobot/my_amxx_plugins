#if defined sh_aux_natives_pt17
  #endinput
#endif
#define sh_aux_natives_pt17

#define REASON_STRING_LENGTH 128

#define STRING_SIZE_FOR_MAP_STRING 128

//it returns true of the restriction that we just applied is applicable for the current played map
native bool:sh_register_map_restricted_superhero(heroID, const the_map_string[STRING_SIZE_FOR_MAP_STRING],
                                                          const optional_reason_string[REASON_STRING_LENGTH] = "No reason specified")
