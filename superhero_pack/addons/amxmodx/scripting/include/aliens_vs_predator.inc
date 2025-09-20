/*================================================================================
	
	----------------------------------------
	-*- Aliens vs Predator Includes File -*-
	----------------------------------------
	
	~~~~~~~~~~
	- How To -
	~~~~~~~~~~
	
	To make use of the Aliens vs Predator API features in your plugin, just
	add the following line at the beginning of your script:
	
	#include <aliens_vs_predator>
	
	~~~~~~~~~~~
	- Natives -
	~~~~~~~~~~~
	
	These work just like any other functions: you may have to pass
	parameters and they usually return values.
	
	Example:
	
	if ( is_user_alive( id ) && avp_get_user_alien( id ) )
	{
		server_print( "Player %d is alive and a alien", id )
	}
	
	~~~~~~~~~~~~
	- Forwards -
	~~~~~~~~~~~~
	
	Forwards get called whenever an event happens during the game.
	You need to make a public callback somewhere on your script,
	and it will automatically be triggered when the event occurs.
	
	Example:
	
	public avp_user_alienized_post( id )
	{
		server_print( "Player %d just now is a Alien!", id )
	}
	
	Also, take note of cases when there's a suffix:
	
	* _pre  : means the forward will be called BEFORE the event happens
	* _post : means it will be called AFTER the event takes place
	
=================================================================================*/

#if defined _aliens_vs_predator_included
  #endinput
#endif
#define _aliens_vs_predator_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib aliens_vs_predator
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib aliens_vs_predator
	#endif
#else
	#pragma library aliens_vs_predator
#endif

/* Teams for avp_register_extra_item() */
#define AVP_TEAM_MARINE (1<<0) //- 1
#define AVP_TEAM_ALIEN (1<<1) //- 2
#define AVP_TEAM_PREDATOR (1<<2) //- 3

/* Types for avp_register_weapon() */
#define AVP_PRIMARY_WEAPON (1<<0) //- 1
#define AVP_SECONDARY_WEAPON (1<<1) //- 2

/* Game modes for avp_round_started() */
enum
{
	MODE_DECIMATION = 1,
	MODE_EXTINCTION,
};

/* Winner teams for avp_round_ended() */
enum
{
	WIN_NO_ONE = 0,
	WIN_ALIENS,
	WIN_PREDATORS,
	WIN_MARINES,
};

/* Custom forward return values */
#define AVP_PLUGIN_HANDLED 97

/**
 * Returns whether a player is a marine.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native avp_get_user_marine(id)

/**
 * Returns whether a player is a alien.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native avp_get_user_alien(id)

/**
 * Returns whether a player is a predator.
 *
 * @param id		Player index.
 * @return		True if it is, false otherwise.
 */
native avp_get_user_predator(id)

/**
 * Returns a player's marine points count.
 *
 * @param id		Player index.
 * @return		Number of marine points owned.
 */
native avp_get_user_marinepoints(id)

/**
 * Returns a player's xeno points count.
 *
 * @param id		Player index.
 * @return		Number of xeno points owned.
 */
native avp_get_user_xenopoints(id)

/**
 * Returns a player's honor points count.
 *
 * @param id		Player index.
 * @return		Number of honor points owned.
 */
native avp_get_user_honorpoints(id)

/**
 * Sets a player's marine points count.
 *
 * @param id		Player index.
 * @param amount	New quantity of marine points owned.
 */
native avp_set_user_marinepoints(id, amount)

/**
 * Sets a player's xeno points count.
 *
 * @param id		Player index.
 * @param amount	New quantity of xeno points owned.
 */
native avp_set_user_xenopoints(id, amount)

/**
 * Sets a player's honor points count.
 *
 * @param id		Player index.
 * @param amount	New quantity of honor points owned.
 */
native avp_set_user_honorpoints(id, amount)

/**
 * Forces a player to become a marine.
 *
 * Note: Unavailable for last alien.
 *
 * @param id		Player index to turn into marine.
 * @return		True on success, false otherwise.
 */
native avp_make_user_marine(id)

/**
 * Forces a player to become a alien.
 *
 * Note: Unavailable for last predator/human.
 *
 * @param id		Player index to turn into alien.
 * @return		True on success, false otherwise.
 */
native avp_make_user_alien(id)

/**
 * Forces a player to become a predator.
 *
 * Note: Unavailable for last alien.
 *
 * @param id		Player index to turn into predator.
 * @return		True on success, false otherwise.
 */
native avp_make_user_predator(id)

/**
 * Returns number of alive marines.
 *
 * @return		Marine count.
 */
native avp_get_marine_count()

/**
 * Returns number of alive aliens.
 *
 * @return		Alien count.
 */
native avp_get_alien_count()

/**
 * Returns number of alive predators.
 *
 * @return		Predator count.
 */
native avp_get_predator_count()

/**
 * Returns a player's current marine class ID.
 *
 * @param id		Player index.
 * @return		Internal marine class ID, or default (0) if not yet chosen.
 */
native avp_get_user_marine_class()

/**
 * Returns a player's current alien class ID.
 *
 * @param id		Player index.
 * @return		Internal alien class ID, or default (0) if not yet chosen.
 */
native avp_get_user_alien_class()

/**
 * Returns a player's current predator class ID.
 *
 * @param id		Player index.
 * @return		Internal predator class ID, or default (0) if not yet chosen.
 */
native avp_get_user_predator_class()

/**
 * Sets a player's next marine class ID.
 *
 * @param id		Player index.
 * @param classid	A valid marine class ID.
 * @return		True on success, false otherwise.
 */
native avp_set_user_marine_class(id, classid)

/**
 * Sets a player's next alien class ID.
 *
 * @param id		Player index.
 * @param classid	A valid alien class ID.
 * @return		True on success, false otherwise.
 */
native avp_set_user_alien_class(id, classid)

/**
 * Sets a player's next predator class ID.
 *
 * @param id		Player index.
 * @param classid	A valid predator class ID.
 * @return		True on success, false otherwise.
 */
native avp_set_user_predator_class(id, classid)

/**
 * Returns a player's next marine class ID.
 *
 * @param id		Player index.
 * @return		Internal marine class ID, or default (0) if not yet chosen.
 */
native avp_get_user_next_marine_class()

/**
 * Returns a player's next alien class ID.
 *
 * @param id		Player index.
 * @return		Internal alien class ID, or default (0) if not yet chosen.
 */
native avp_get_user_next_alien_class()

/**
 * Returns a player's next predator class ID.
 *
 * @param id		Player index.
 * @return		Internal predator class ID, or default (0) if not yet chosen.
 */
native avp_get_user_next_pred_class()

/**
 * Returns whether the current round is a decimation round.
 *
 * @return		True if it is, false otherwise.
 */
native avp_is_decimation_round()

/**
 * Returns whether the current round is a extinction round.
 *
 * @return		True if it is, false otherwise.
 */
native avp_is_extinction_round()

/**
 * Called when the AvP round starts, when game mode begins.
 *
 * @param gamemode	Mode which has started.
 * @deprecated id		Do not use! Base support for the next AvP updates.
 */
forward avp_round_started(gamemode, id)

/**
 * Called when the round ends.
 *
 * @param winteam	Team which has won the round.
 */
forward avp_round_ended(winteam)

/**
 * Called on a player is marined attempt. You can use this to block
 * an marinezation by returning AVP_PLUGIN_HANDLED in your plugin.
 *
 * Note: This is only available after the AVP round starts, since some
 * situations are not yet handled.
 */
forward avp_user_marineze_attempt(id)

/**
 * Called on a player is alienized attempt. You can use this to block
 * an alienization by returning AVP_PLUGIN_HANDLED in your plugin.
 *
 * Note: This is only available after the AVP round starts, since some
 * situations are not yet handled.
 */
forward avp_user_alienize_attempt(id)

/**
 * Called on a player is predatorized attempt. You can use this to block
 * an predatorization by returning AVP_PLUGIN_HANDLED in your plugin.
 *
 * Note: This is only available after the AVP round starts, since some
 * situations are not yet handled.
 */
forward avp_user_predatorize_attempt(id)

/**
 * Called when a player turns in a Marine.
 *
 * @param id		Player index who was "marinized".
 */
forward avp_user_marined_pre(id)
forward avp_user_marined_post(id)

/**
 * Called when a player turns in a Alien.
 *
 * @param id		Player index who was "alienized".
 */
forward avp_user_alienized_pre(id)
forward avp_user_alienized_post(id)

/**
 * Called when a player turns in a Predator.
 *
 * @param id		Player index who was "predatorized".
 */
forward avp_user_predatorized_pre(id)
forward avp_user_predatorized_post(id)

/**
 * Returns a marine class' ID.
 *
 * @param name		Class name to look for.
 * @return		Internal marine class ID, or -1 if not found.
 */
native avp_get_marine_class_id(const name[])

/**
 * Returns a alien class' ID.
 *
 * @param name		Class name to look for.
 * @return		Internal alien class ID, or -1 if not found.
 */
native avp_get_alien_class_id(const name[])

/**
 * Returns a predator class' ID.
 *
 * @param name		Class name to look for.
 * @return		Internal predator class ID, or -1 if not found.
 */
native avp_get_predator_class_id(const name[])

/**
 * Returns a extra item' ID.
 *
 * @param name		Item name to look for.
 * @return		Internal item ID, or -1 if not found.
 */
native avp_get_extra_item_id(const name[])

/**
 * Returns a weapon' ID.
 *
 * @param name		Weapon name to look for.
 * @return		Internal weapon ID, or -1 if not found.
 */
native avp_get_weapon_id(const name[])

/**
 * Forces a player to buy an extra item.
 *
 * @param id		Player index.
 * @param itemid	A valid extra item ID.
 * @param ignorecost	If set, item's cost won't be deduced from player.
 * @return		True on success, false otherwise.
 */
native avp_force_buy_extra_item(id, itemid, ignorecost = 0)

/**
 * Forces a player to buy an weapon.
 *
 * @param id		Player index.
 * @param weaponid	A valid weapon ID.
 * @return		True on success, false otherwise.
 */
native avp_force_buy_weapon(id, weaponid)

/**
 * Registers a custom class which will be added to the marine classes menu of AvP.
 *
 * Note: The returned alien class ID can be later used to identify
 * the class when calling the avp_get_user_marine_class() native.
 *
 * @param name		Caption to display on the menu.
 * @param info		Brief description of the class.
 * @param health	Health points to set.
 * @param gravity	Gravity multiplier.
 * @param speed		Maximum speed.
 * @param model		Player model to be used.
 * @return		An internal marine class ID.
 */
native avp_register_marine_class(const name[], const info[], health, Float:gravity, Float:speed, const model[])

/**
 * Registers a custom class which will be added to the alien classes menu of AvP.
 *
 * Note: The returned alien class ID can be later used to identify
 * the class when calling the avp_get_user_alien_class() native.
 *
 * @param name		Caption to display on the menu.
 * @param info		Brief description of the class.
 * @param health	Health points to set.
 * @param gravity	Gravity multiplier.
 * @param damage	Damage inflicted on enemies.
 * @param speed		Maximum speed.
 * @param model		Player model to be used.
 * @param claw		Claws model to be used.
 * @return		An internal alien class ID.
 */
native avp_register_alien_class(const name[], const info[], health, Float:gravity, damage, Float:speed, const model[], const claw[])

/**
 * Registers a custom class which will be added to the predator classes menu of AvP.
 *
 * Note: The returned alien class ID can be later used to identify
 * the class when calling the avp_get_user_predator_class() native.
 *
 * @param name		Caption to display on the menu.
 * @param info		Brief description of the class.
 * @param health	Health points to set.
 * @param gravity	Gravity multiplier.
 * @param speed		Maximum speed.
 * @param model		Player model to be used.
 * @return		An internal predator class ID.
 */
native avp_register_predator_class(const name[], const info[], health, Float:gravity, Float:speed, const model[])

/**
 * Registers a custom item which will be added to the extra items menu of AvP.
 *
 * Note: Different from ZP, you didn't use the zp_extra_item_selected() forward,
 * the item handler automatically is executed when player buy he.
 *
 * @param name		Caption to display on the menu.
 * @param cost		Points to be deducted on purchase.
 * @param handler	Function to be executed when player select this item.
 * @param team		Bitsum of team it should be available for.
 * @return		An internal extra item ID.
 */
native avp_register_extra_item(const name[], cost, const handler[], team)

/**
 * Registers a custom item which will be added to the weapons menu of AvP.
 *
 * @param name		Caption to display on the menu.
 * @param handler	Function to be executed when player select this item.
 * @param type		Bitsum of type (primary or secondary) to display on the respectively menu.
 * @return		An internal weapon ID.
 */
native avp_register_weapon(const name[], const handler[], type)