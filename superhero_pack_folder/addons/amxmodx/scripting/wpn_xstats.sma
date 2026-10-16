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

// Uncomment the mod you wanna use (COMMENT ALL OTHERS!)
#define CS_SUPPORT		// Counter-Strike
//#define DOD_SUPPORT		// Day of Defeat
//#define TS_SUPPORT		// The Specialists

#include <amxmodx>
#include <weaponmod>

// Include mod specifiec functions
#if defined CS_SUPPORT
#include <csx>
#endif
#if defined DOD_SUPPORT
#include <dodx>
#endif
#if defined TS_SUPPORT
#include <tsx>
#endif

// Plugin informations
#if defined CS_SUPPORT
new const PLUGIN[] = "WPN CSX Stats"
#endif
#if defined DOD_SUPPORT
new const PLUGIN[] = "WPN DODX Stats"
#endif
#if defined TS_SUPPORT
new const PLUGIN[] = "WPN TSX Stats"
#endif

new const VERSION[] = "0.51"
new const AUTHOR[] = "DevconeS"

#define MAX_WEAPONS		16
#define MAX_SZ_LENGTH	64

new g_xmodId[MAX_WEAPONS]

// Initializes the plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	wpn_register_addon()
}

// Registers weapons to the stats module
public plugin_cfg()
{
	new long[MAX_SZ_LENGTH], short[MAX_SZ_LENGTH]
	new count = wpn_weapon_count()
	if(count > MAX_WEAPONS) count = MAX_WEAPONS
	
	for(new i = 0; i < count; i++)
	{
		wpn_get_string(i, wpn_name, long, MAX_SZ_LENGTH-1)
		wpn_get_string(i, wpn_short, short, MAX_SZ_LENGTH-1)
		g_xmodId[i] = custom_weapon_add(long, 0, short)
	}
}

// Called each time when damage is done by a WeaponMod weapon
public wpn_attack_damage_post(victim, attacker, wpnid, damage, hitplace, damageType, bool:monster)
{
	if(monster)
	{
		// Victim is a monster (stats module doesn't support them) or it's called in pre (post required for registration)
		return PLUGIN_CONTINUE
	}
	
	if(wpnid > -1 && wpnid < MAX_WEAPONS && damage > 0)
	{
		if(g_xmodId[wpnid] != 0)
		{
			// WeaponMod weapon which is registered, let the stats module know it
			custom_weapon_dmg(g_xmodId[wpnid], attacker, victim, damage, hitplace)
		}
	}
	
	return PLUGIN_CONTINUE
}

// Called each time after an event has been executed
public wpn_event_post(player, wpnid, wpn_event:event, params[])
{
	// Called quite often, keep the reserved memory :)
	static wpn_integer:count

	if(wpnid > -1 && wpnid < MAX_WEAPONS)
	{
		// This is a registered WeaponMod weapon, check if the attack button was pressed
		if((event == event_attack1 || event == event_attack2) && g_xmodId[wpnid])
		{
			count = (event == event_attack1) ? wpn_count_bullets1 : wpn_count_bullets2
			if(wpn_get_integer(wpnid, count))
			{
				// Bullet was fired and is allowed to be counted, let the stats module know it
				custom_weapon_shot(g_xmodId[wpnid], player)
			}
		}
	}
}
