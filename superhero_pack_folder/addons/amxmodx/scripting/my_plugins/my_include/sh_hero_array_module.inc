#if defined fast_sh_array_module_aux_inc
  #endinput
#endif
#define fast_sh_array_module_aux_inc


/* Hero array module
*
* (c) Copyright 2026 ThrashBrat
*
* This file is provided as is (no warranties).
*/

/*

no return value

*/
//up to 64 properties can be added in the current version of the library
enum hero_property_flags_id {
	
	SH_BLEED_POWERS = 0,
	SH_EXPLOSION_POWERS,
	SH_SLEEP_POWERS,
	SH_CORE_HERO,
	SH_INVISIBILITY_HERO,
	SH_HEALING_HERO,
	SH_SMALL_HERO,
	SH_DREAM_EATER_HERO,
	SH_ANNOYING_HERO
};

//up to 64 states can be added in the current version of the library
enum player_state_flags_id {
	
	SH_IS_COOLDOWN = 52,
	SH_IS_SLEEPING,
	SH_IS_CHAFFED,
	SH_IS_BURNING,
	SH_IS_DISRUPT,
	SH_IS_SHOCKED,
	SH_IS_CO2,
	SH_IS_FROZEN,
	SH_IS_WET,
	SH_IS_BLEEDING,
	SH_IS_PSYCHOSIS
};

//hero properties


/**

//The third parameter decides the polarity to set

enum hero_property_flags_id {
	
	SH_BLEED_POWERS = 0,
	SH_EXPLOSION_POWERS,
	SH_SLEEP_POWERS,
	SH_CORE_HERO,
	SH_INVISIBILITY_HERO,
	SH_HEALING_HERO
};

*/

native sh_assign_hero_bit(heroID, hero_property_flags_id:the_flag_id, bool:the_polarity)

/**

//retrieve the bit of a hero bitsum


enum hero_property_flags_id {
	
	SH_BLEED_POWERS = 0,
	SH_EXPLOSION_POWERS,
	SH_SLEEP_POWERS,
	SH_CORE_HERO,
	SH_INVISIBILITY_HERO,
	SH_HEALING_HERO
};

 */
native sh_get_hero_bit(heroID, hero_property_flags_id:the_flag_id)


//Hero ownership
/*

bool
 
 
*/
native bool:sh_get_user_has_hero(id, the_hero_id)
/*

no return value
 
*/
native sh_set_user_has_hero(id, the_hero_id, bool:the_value_to_set)


/*

//retrieve the bit of a hero bitsum

enum player_state_flags_id {
	
	SH_IS_SLEEPING = 0,
	SH_IS_CHAFFED,
	SH_IS_BURNING,
	SH_IS_DISRUPT,
	SH_IS_SHOCKED,
	SH_IS_CO2,
	SH_IS_FROZEN
};

*/

native bool:sh_get_id_bit(player_id, player_state_flags_id:the_flag_id)


/*

//The third parameter decides the polarity to set

enum player_state_flags_id {
	
	SH_IS_SLEEPING = 0,
	SH_IS_CHAFFED,
	SH_IS_BURNING,
	SH_IS_DISRUPT,
	SH_IS_SHOCKED,
	SH_IS_CO2,
	SH_IS_FROZEN
};

*/

native sh_assign_id_bit(player_id, player_state_flags_id:the_flag_id, bool:the_polarity)


//retrieve the bit of a hero bitsum
native sh_init_id_masks_array()





//Init the lib
native sh_init_hero_array();

//returns the number of client states that are currently mappable by this version of the library
native sh_max_client_states()


//returns the number of hero properties that are currently mappable by this version of the library
native sh_max_hero_props()