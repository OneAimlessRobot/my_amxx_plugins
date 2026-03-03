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

#include <amxmodx>
#include <weaponmod>
#include <fakemeta>

// Plugin informations
new const PLUGIN[] = "Weapon Drop Blocker"
new const VERSION[] = "0.53"
new const AUTHOR[] = "DevconeS"

// Plugin data
new const WPN_ENT_REM_TASKID = 2151
new g_MaxPlayers

// CVAR Pointers
new g_BlockDropCommand
new g_BlockWeaponDrop
new g_SkipEmptyWeapons
new g_EntityLifeTime

// Player data
new g_PlayerWeapon[33] = {-1, ...}

// Register the plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	wpn_register_addon()
	
	g_BlockDropCommand = register_cvar("wpn_block_dropcommand", "1")
	g_BlockWeaponDrop = register_cvar("wpn_block_weapondrop", "1")
	g_SkipEmptyWeapons = register_cvar("wpn_skip_empty_weapons", "1")
	g_EntityLifeTime = register_cvar("wpn_entity_life_time", "30.0")
	
	g_MaxPlayers = get_maxplayers()
}

// Executed each time before an event happened
public wpn_event_pre(id, wpnid, wpn_event:event, params[])
{
	// Get the user weapon id if this is a player event
	static usrwpn
	if(id > 0 && id <= g_MaxPlayers)
	{
		usrwpn = wpn_has_weapon(id, wpnid)
		if(is_user_alive(id))
		{
			if(usrwpn != -1)
			{
				// Store player's current weapon as soon as it's drawed
				if(event == event_draw)
				{
					g_PlayerWeapon[id] = wpnid
				}
			} else {
				g_PlayerWeapon[id] = -1
			}
		}
	}
	
	if(event == event_weapondrop_pre && get_pcvar_num(g_BlockWeaponDrop) && usrwpn != -1)
	{
		if(is_user_alive(id))
		{
			// Drop command or something similar is used since the player's still alive
			if(get_pcvar_num(g_BlockDropCommand) == 1)
			{
				return PLUGIN_HANDLED
			}
		} else {
			// This weapon is dropped on death, check if it can be dropped
			if(get_pcvar_num(g_BlockWeaponDrop) == 2)
			{
				// Block dropping of each weapon
				wpn_remove_weapon(id, usrwpn)
				return PLUGIN_HANDLED
			} else if(get_pcvar_num(g_BlockWeaponDrop) == 1)
			{
				if(g_PlayerWeapon[id] != wpnid)
				{
					// Only dropping of the last used weapon is enabled, but this is a different one
					wpn_remove_weapon(id, usrwpn)
					return PLUGIN_HANDLED
				}
			}
		}
	} else if(event == event_draw && get_pcvar_num(g_SkipEmptyWeapons) == 1)
	{
		// Player's drawing a weapon, check if it's empty
		if(usrwpn != -1)
		{
			if(wpn_get_userinfo(id, usr_wpn_ammo1, usrwpn) == 0 &&
				wpn_get_userinfo(id, usr_wpn_ammo2, usrwpn) == 0)
			{
				// Player's weapon does not have any ammo, make sure the weapon
				// requires some ammo
				if(wpn_get_integer(g_PlayerWeapon[id], wpn_ammo1) > 0 &&
					wpn_get_integer(g_PlayerWeapon[id], wpn_ammo2) > 0)
				{
					// Ammo is required, switch to the next weapon
					usrwpn++
					if(usrwpn >= wpn_user_weapon_count(id))
					{
						usrwpn = -1
					}
					
					// Change the weapon
					wpn_change_user_weapon(id, usrwpn, false)
					
					// Block draw event of the skipped weapon
					return PLUGIN_HANDLED
				}
			}
		}
	} else if(event == event_worldspawn_post)
	{
		// Add remove task if the weapon should be deleted
		static Float:delay; delay = get_pcvar_float(g_EntityLifeTime)
		if(delay > 0.0)
		{
			set_task(delay, "remove_weapon_entity", WPN_ENT_REM_TASKID+id)
		}
	}
	
	return PLUGIN_CONTINUE
}

// Executed as soon as a weapon entity should be removed
public remove_weapon_entity(taskid)
{
	static entity; entity = taskid-WPN_ENT_REM_TASKID
	if(pev_valid(entity))
	{
		if(wpn_is_wpnentity(entity))
		{
			// Weapon entity has to be removed
			set_pev(entity, pev_flags, FL_KILLME)
		}
	}
}
