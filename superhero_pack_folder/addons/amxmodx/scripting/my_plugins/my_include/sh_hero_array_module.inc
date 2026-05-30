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
enum hero_property_flags_id {
	
	SH_BLEED_POWERS = 0,
	SH_EXPLOSION_POWERS,
	SH_SLEEP_POWERS,
	SH_CORE_HERO,
	SH_INVISIBILITY_HERO,
	SH_HEALING_HERO
};

enum player_state_flags_id {
	
	SH_IS_SLEEPING = 0,
	SH_IS_CHAFFED,
	SH_IS_BURNING,
	SH_IS_DISRUPT,
	SH_IS_SHOCKED,
	SH_IS_CO2,
	SH_IS_FROZEN
};

//hero properties

//Full bitsum get/set

//retrieve full bitsum of hero
native sh_get_hero_flags(heroID)

//Override full bitsum of hero
native sh_set_hero_flags(heroID, hero_property_flags_id:the_flag_cell)


//single bit ops

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