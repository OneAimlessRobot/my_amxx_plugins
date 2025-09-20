/* Copyright (C) 2006-2008 Space Headed Productions
* 
* WeaponMod is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation.
*
* WeaponMod is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with WeaponMod; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#if defined _weaponmod_included
  #endinput
#endif
#define _weaponmod_included

#include <hlsdk_const>
#include <weaponmod_const>

#pragma library WeaponMod



/****************************************************************
 *      GameInfo Functions                                      *
 ****************************************************************/

/* Sets GameInfo */
native wpn_set_gameinfo(wpn_gi_integer:index, value);

/* Gets GameInfo */
native wpn_get_gameinfo(wpn_gi_integer:index);

/* Checks if the given weapon is the default weapon */
native wpn_gi_is_default_weapon(weapon);

/* Sets an offset int */
native wpn_gi_set_offset_int(player, wpn_offset:index, value);

/* Gets an offset int */
native wpn_gi_get_offset_int(player, wpn_offset:index);

/* Identifies if the game is currently in the freeze time */
native bool:wpn_gi_in_freeze_time();

/* Tells the game info plugin to take out the default weapon */
native wpn_gi_take_default_weapon(id);

/* Returns a random gunshot decal */
native wpn_gi_get_gunshot_decal();

/* Returns a random large explosion decal */
native wpn_gi_get_explosion_decal();

/* Returns a random small explosion decal */
native wpn_gi_get_smallexplosion_decal();

/* Returns a random large blood decal */
native wpn_gi_get_blood_decal();

/* Returns a random small blood decal */
native wpn_gi_get_smallblood_decal();

/* Called when the ammo hud has to be updated
* 
*   id		Playerid
*   wpnid		User WeaponId
*   pAmmo		Primary Ammo
*   sAmmo		Secondary Ammo
*/
forward wpn_gi_update_ammo(id, wpnid, pAmmo, sAmmo);

/* Called when the replaced weapon is beeing used (e.g CS -> knife) */
forward wpn_gi_reset_weapon(id);

/* Called when user gets killed
*  Use this forward to build a death message and to update Scoreboard
* 
*   id		Victim id
*   killer	Killer id
*   hitplace	Hitplace
*   wpnid		WeaponMod weaponid
*   weapon	short weaponname
*   monster	True if the killed victim was a monster
 */
forward wpn_gi_player_killed(id, killer, hitplace, wpnid, weapon[], bool:monster);



/****************************************************************
 *      Core Informations                                       *
 ****************************************************************/

/* Sets a core sound */
native wpn_set_core_sound(wpn_core_sound:coresound, soundfile[]);

/* Gets a core sound */
native wpn_get_core_sound(wpn_core_sound:coresound, soundfile[], len);



/****************************************************************
 *      General weapon functions                                *
 ****************************************************************/
 
/* Register a new weapon
*  
*   weaponname	Name of the weapon (can contain spaces and capital letters)
*   short_name Used for log and death messages (don't use spaces or capital letters)
*   returns	Weapon ID
*/
native wpn_register_weapon(weaponname[], short_name[]);

/* Registers an event done by a weapon
*  Returning PLUGIN_HANDLED inside an executed event will block WeaponMod actions
* 
*   weaponid	Weapon ID
*   index		Event type to register (see weaponmod_const.inc)
*   function	Function which gets called when event occurs
*/
native wpn_register_event(weaponid, wpn_event:index, function[]);

/* Gets an event */
native wpn_get_event(weaponid, wpn_event:index, function[], len);

/* Sets a string by given weapon (weaponid) */
native wpn_set_string(weaponid, wpn_string:index, string[]);

/* Gets a string by given weapon (weaponid) */
native wpn_get_string(weaponid, wpn_string:index, string[], len);

/* Sets a integer by given weapon (weaponid) */
native wpn_set_integer(weaponid, wpn_integer:index, integer);

/* Returns integer by given weapon (weaponid) */
native wpn_get_integer(weaponid, wpn_integer:index);

/* Sets a float by given weapon (weaponid) */
native wpn_set_float(weaponid, wpn_float:index, Float:fl);

/* Returns float by given weapon (weaponid) */
native Float:wpn_get_float(weaponid, wpn_float:index);



/****************************************************************
 *      Addon functions                                         *
 ****************************************************************/
 
/* Registers an addon to WeaponMod
*  This is not required to use the addon API, it's just to allow
*  WeaponMod and other plugins retrieving some information about 
*  the addon
*  
*   returns	1 if the registration were successful (not required to make the addon working)
*/
native wpn_register_addon();

/* Registers an addon to WeaponMod
*
*   id		Addon id
*   returns	Plugin id or -1 if it's an invalid addon
*/
native wpn_get_addon(id);

/* Returns the amount of registered addons */
native wpn_get_addon_count();


/****************************************************************
 *      Some misc functions :)                                  *
 ****************************************************************/

/* Damages a user, now supports monsters as well
*
*   returns	Damage made (-1 when killed/-2 when aborted external)
*/
native wpn_damage_user(weaponid, victim, attacker, dmg_save, dmg_take, dmg_type, hitplace=0);

/* Does all actions just like wpn_damage_user but doesn't cause damage to the player
*
*   returns	Damage made (-1 when killed/-2 when aborted external)
*/
native wpn_fake_damage(weaponid, victim, attacker, dmg_save, dmg_take, dmg_type, hitplace=0);

/* Makes radius damage, now supports monsters as well
* 
*   inflictor	Entity which causes the damage impact
*   returns	Amount of players/monsters hit
*/
native wpn_radius_damage(weaponid, attacker, inflictor, Float:range, Float:damage, damageType);

/* Kills a player, now supports monsters as well
* 
*   returns	1 on success or 0 on fail (e.g. team attack with friendlyfire disabled)
*/
native wpn_kill_user(weaponid, victim, attacker, headshot=0, dmg_type=DMG_GENERIC);

/* Does all actions just like wpn_kill_user but doesn't kill the player
* 
*   returns	1 on success or 0 on fail (e.g. team attack with friendlyfire disabled)
*/
native wpn_fake_kill(weaponid, victim, attacker, headshot=0, dmg_type=DMG_GENERIC);

/* Creates some blood around the target and puts some on the wall if it's near enough
* 
*   sourceOrigin	Origin from where the damage came
*   target		Victim who was attacked (can be an entity)
*   amount		Amount of blood (e.g.: 0=small damage, 1=big damage, 2=kill)
*   distance		Maximum distance to the wall
*   color			Color of the blood
*/
native wpn_create_blood(Float:sourceOrigin[3], target, amount, distance=64, color=70);

/* Shoots a normal bullet
* 
*   returns	Player hit
*/
native wpn_bullet_shot(weaponid, attacker, dmg_save, dmg_take);

/* Plays an animation */
native wpn_playanim(player, animation);

/* Returns amount of registered weapons */
native wpn_weapon_count();

/* Gives user a weapon
*
*   returns	User weapon index (0 or more)
*			-1 if player cannot hold more weapons
*			-2 if weapon id is invalid (will be logged)
*			-3 if weaponmod is disabled
*/
native wpn_give_weapon(weaponid, player, ammo1, ammo2);

/* Spawns a weapon entity */
native wpn_spawn_weapon(weaponid, Float:Origin[3], ammo1, ammo2);

/* Sets the view of an entity to the given origin */
native wpn_set_entity_view(entity, Float:Origin[3]);

/* Kills a user TOTALLY silent (no DeathMsg on no log entry) */
native wpn_user_silentkill(player);

/* Use this to get the correct projectile start position */
native wpn_projectile_startpos(player, vForward, vRight, vUp, Float:StartPos[3]);

/* This function deletes all WeaponMod weapons spawned on map */
native wpn_remove_weapons();

/* Called before an event happens
*  Returning PLUGIN_HANDLED will block event execution (no post event, no weapon actions, no WeaponMod actions)
* 
*   player	Player id on which the event was executed
*   wpnid		WeaponMod weapon id of the used weapon
*   event		Executed event
*   params	Additional parameters sent
*/
forward wpn_event_pre(player, wpnid, wpn_event:event, params[]);

/* Called after an event happenened
* 
*   player	Player id on which the event was executed
*   wpnid		WeaponMod weapon id of the used weapon
*   event		Executed event
*   params	Additional parameters sent
*/
forward wpn_event_post(player, wpnid, wpn_event:event, params[]);

/* Called before damage gets caused by weaponmod natives
*  Returning PLUGIN_HANDLED will block damage call (only in pre)
* 
*   victim	Player/Monster which was attacked
*   attacker	Player which attacked the victim
*   wpnid		WeaponMod weapon id of the used weapon
*   damage	Damage caused by this attack
*   hitplace	Hitplace on victim's body
*   damageType Type of the damage done by the weapon
*   monster	True if the attacked victim was a monster
*/
forward wpn_attack_damage(victim, attacker, wpnid, damage, hitplace, damageType, bool:monster);

/* Same as the forward "wpn_attack_damage", except that this one is executed in post
*/
forward wpn_attack_damage_post(victim, attacker, wpnid, damage, hitplace, damageType, bool:monster);



/****************************************************************
 *      User infos                                              *
 ****************************************************************/

/* Has user this weapon
* 
*   returns	user weapon index (-1 if user doesn't own given weapon)
*/
native wpn_has_weapon(player, weaponid);

/* Sets user information
*  Note: "user_weapon" is the index of the user's hold weapon and not the real weapon id.
*/
native wpn_set_userinfo(player, wpn_usr_info:index, user_weapon, value);

/* Returns user information
*  Note: "user_weapon" is the index of the user's hold weapon and not the real weapon id.
*/
native wpn_get_userinfo(player, wpn_usr_info:index, user_weapon);

/* Reloads current hold weapon */
native wpn_reload_weapon(player);

/* Returns user weapon index of the currently used weapon
*  Note: The number returned is the index of the user's hold weapon and not the real weapon id.
*        Use "wpn_get_userinfo(player, usr_wpn_index, user_weapon)" to get the real weapon id.
*/
native wpn_get_user_weapon(player);

/* Returns current amount of weapons */
native wpn_user_weapon_count(player);

/* Switches currently used weapon to given
*  Note: "user_weapon" is the index of the user's hold weapon and not the real weapon id.
*/
native wpn_change_user_weapon(player, user_weapon, bool:blockWpnId = true);

/* Completely removes weapon hold by user
*  Note: "user_weapon" is the index of the user's hold weapon and not the real weapon id.
*/
native wpn_remove_weapon(player, user_weapon);

/* Drops given weapon from user
* 
*  automically creates weapon on floor that can be picked up again
*  Note: "user_weapon" is the index of the user's hold weapona and not the real weapon id.
*/
native wpn_drop_weapon(player, user_weapon);



/****************************************************************
 *      Entity infos                                            *
 ****************************************************************/

/* Is this a registered weapon entity
* 
*   returns	Entity index or -1
*/
native wpn_is_wpnentity(entity);

/* sets entity information */
native wpn_set_entinfo(entindex, wpn_ent_info:index, value);

/* Returns entity information */
native wpn_get_entinfo(entindex, wpn_ent_info:index);
