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
	SH_HEALING_HERO,
	SH_SMALL_HERO,
	SH_DREAM_EATER_HERO,
	SH_ANNOYING_HERO,
	SH_HEALTH_CAP_HERO,
	SH_BOT_RESTRICTED,
	SH_ANTI_FALL_DAMAGE_HERO,
	SH_ANTI_GRENADES_HERO,
	SH_HITBOX_MANIP_HERO,
	SH_RESPAWN_HERO,
	SH_M249_HERO,
	SH_TR45H_HERO,
	SH_UNHEALABLE_HERO,
	SH_PARASITE_HERO_I_HATE_THEM,
	SH_YANDERE_HERO,
	SH_FIRE_RETARDANT_HERO
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
	SH_IS_PSYCHOSIS,
	SH_IS_REBORN,
	SH_IS_FIRE_HEADSHOT_HELMET,
	SH_IS_TR45H_GUN_EQUIPPED,
	SH_IS_CHARGING_HEAVY_ATTACK
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
	SH_HEALING_HERO,
	SH_SMALL_HERO,
	SH_DREAM_EATER_HERO,
	SH_ANNOYING_HERO,
	SH_HEALTH_CAP_HERO,
	SH_BOT_RESTRICTED,
	SH_ANTI_FALL_DAMAGE_HERO,
	SH_ANTI_GRENADES_HERO,
	SH_HITBOX_MANIP_HERO,
	SH_RESPAWN_HERO,
	SH_M249_HERO,
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
	SH_HEALING_HERO,
	SH_SMALL_HERO,
	SH_DREAM_EATER_HERO,
	SH_ANNOYING_HERO,
	SH_HEALTH_CAP_HERO,
	SH_BOT_RESTRICTED,
	SH_ANTI_FALL_DAMAGE_HERO,
	SH_ANTI_GRENADES_HERO,
	SH_HITBOX_MANIP_HERO,
	SH_RESPAWN_HERO,
	SH_M249_HERO,
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

//Hero cooldown
/*

bool
 
 
*/
native bool:sh_get_id_hero_cooldown_bit(hero_id, the_player_id)
/*

no return value
 
*/
native sh_set_id_hero_cooldown_bit(hero_id, the_player_id, bool:the_value_to_set)


/*
	when called,
	for the hero id given,
	every player's cooldown flag
	(for that hero id)
	will be set to some value!
	Recommended
	ONLY
	on map start
	and at most on round change
	NEVER on client spawn

*/
native sh_set_one_hero_cooldown_bits(hero_id, bool:the_value_to_set)



/*
	it does what it is told
	but it is horrid and slow
	not recommended.
	It clears the cooldown of one client
	for all of its heroes.
	Useful
	But the memory layout of the native makes it slow
	Not recommended

*/
native sh_set_one_client_cooldown_bit_for_all_heroes(the_player_id, bool:the_value_to_set)
/*

//retrieve the bit of a hero bitsum
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
	SH_IS_PSYCHOSIS,
	SH_IS_REBORN,
	SH_IS_FIRE_HEADSHOT_HELMET
};

*/

native bool:sh_get_id_bit(player_id, player_state_flags_id:the_flag_id)


/*

//The third parameter decides the polarity to set

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
	SH_IS_PSYCHOSIS,
	SH_IS_REBORN,
	SH_IS_FIRE_HEADSHOT_HELMET
};

*/

native sh_assign_id_bit(player_id, player_state_flags_id:the_flag_id, bool:the_polarity)


native bool:sh_get_hero_projectile_weapon_bit(the_hero_id, my_weapon_ids:the_weapon_id)


native sh_assign_hero_projectile_weapon_bit(the_hero_id, my_weapon_ids:the_weapon_id, bool:the_polarity)





//Init the lib
//leaving a parameter at zero automatically initializes it at the maximum value within the library
native sh_init_hero_array_lib(max_heros=0, max_hero_props=0, max_client_states=0);

//returns the number of client states that are currently mappable by this instance of the library
native sh_max_client_states()


//returns the number of hero properties that are currently mappable by this instance of the library
native sh_max_hero_props()

//returns the number of heroes that are currently mappable by this instance of the library
native sh_maxhero_capacity()


//to be used by the superhero core
native sh_zero_out_cooldown_memory();