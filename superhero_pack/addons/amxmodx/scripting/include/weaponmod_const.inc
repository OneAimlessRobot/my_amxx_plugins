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

#if defined _weaponmod_const_included
  #endinput
#endif
#define _weaponmod_const_included

/* GameInfos */
enum wpn_gi_integer
{
	gi_pluginid,	/* Plugin id (automatically detected) */
	gi_available,	/* Identifies if there's a GameInfo plugin available */
	gi_teamplay	/* Identifies if the current played mod is a teamplay game or not */
}

/* Core Sounds */
enum wpn_core_sound
{
	/* Weapon sounds */
	wpn_core_sound_weapon_empty,	/* Played when a weapon is empty */
	wpn_core_sound_weapon_drop,	/* Played when a weapon has been picked dropped */
	wpn_core_sound_weapon_pickup,	/* Played when a weapon has been picked up */
	
	/* Ammo sounds */
	wpn_core_sound_ammo_pickup,	/* Played when a ammo has been picked up */
}

/* Weapon data strings */
enum wpn_string
{
	/* Weapon information */
	wpn_name,
	wpn_short,
	wpn_file,	/* Automatically detected */
	
	/* Models used */
	wpn_viewmodel,
	wpn_weaponmodel,
	wpn_worldmodel
}

/* Weapon data integers */
enum wpn_integer
{
	/* Cost of the weapon */
	wpn_cost,	
	
	/* Primary and secondary ammo */
	wpn_ammo1,
	wpn_ammo2,
	
	/* Bullets used by clicking attack 1/2 */
	wpn_bullets_per_shot1,
	wpn_bullets_per_shot2,
	
	/* Should bullets be counted by 3rd party mods (e.g. Stats) (default = 1)  */
	wpn_count_bullets1,
	wpn_count_bullets2,
	
	/* Identicates the plugin which registered the weapon (automatically detected) */
	wpn_pluginid
}

/* Weapon data floats */
enum wpn_float
{
	/* Refire rate of attack 1/2 */
	Float:wpn_refire_rate1,
	Float:wpn_refire_rate2,
	
	/* Time of reloading */
	Float:wpn_reload_time,
	
	/* Maximum run speed if this weapon is hold */
	Float:wpn_run_speed,
	
	/* Recoil of attack 1/2 */
	Float:wpn_recoil1,
	Float:wpn_recoil2
}

/* Weapon events */
enum wpn_event
{
	/* Attack events */
	event_attack1,		/* player, bullets used */
	event_attack2,		/* player, bullets used */
	event_reload,		/* player */
	event_empty,		/* player */
	
	/* Weapon player events */
	event_pickup,		/* player */
	event_draw,		/* player */
	event_hide,		/* player */
	
	/* Weapon entity events */
	event_worldspawn_pre,	/* entity */
	event_worldspawn_post,	/* entity */
	event_weapondrop_pre,	/* dropper */
	event_weapondrop_post,	/* dropper, entity */
	
	/* Release events (blocking this will cause player continues shooting the current frame) */
	event_attack1_released,	/* player */
	event_attack2_released	/* player */
}

/* Player weapon information */
enum wpn_usr_info
{
	/* Real Weapon ID */
	usr_wpn_index,
	
	/* Primary and Secondary ammo */
	usr_wpn_ammo1,
	usr_wpn_ammo2
}

/* Entity Weapon Information */
enum wpn_ent_info
{
	/* Real Weapon ID */
	ent_wpn_index,
	
	/* Primary and Secondary ammo */
	ent_wpn_ammo1,
	ent_wpn_ammo2,
	
	/* Identifies if the entity has been removed */
	ent_weapon_removed
}

/* Offsets */
enum wpn_offset
{
	offset_money,
	offset_deaths
}
