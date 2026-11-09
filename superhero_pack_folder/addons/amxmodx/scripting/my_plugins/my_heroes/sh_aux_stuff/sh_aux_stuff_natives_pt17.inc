#if defined sh_aux_natives_pt17
  #endinput
#endif
#define sh_aux_natives_pt17

#define REASON_STRING_LENGTH 128

#define STRING_SIZE_FOR_MAP_STRING 128

/*
  it returns true of the restriction that we just applied is applicable for the current played map
  true for white listed (Can ONLY be used on certain maps) false for black listed (cannot be used on these maps)

  max is 4x the number of maximum heroes

  more than 4 restrictions for hero are not expected.

  it returns true if map name matches with current one when plugin is being initialized

  false otherwise

  the optional string is not necessary.t

  and is actually not even used if registering a whitelist

  it is used when players want to know why a hero is blacklisted on a certain map.
*/

native bool:sh_register_superhero_map_restriction(heroID, bool:white_listed_or_black_listed, const the_map_string[STRING_SIZE_FOR_MAP_STRING],
                                                          const optional_reason_string[REASON_STRING_LENGTH] = "No reason specified")


/*
  Without actually registering anything,

  Performs a map name test based on whether we white list or black list

  if white listed:

  true if the map string has a partial match
  true otherwise

  if black listed:

  false if the map string has a partial match
  false otherwise

  its like an "allow" check for the map without anything internal changing

  the module loads the map name at plugin_precache

  that is what we compare the given string against

  always returning false if the string has no characters in it

*/

native bool:sh_test_map_name_here(bool:white_listed_or_black_listed, const the_map_string[STRING_SIZE_FOR_MAP_STRING])