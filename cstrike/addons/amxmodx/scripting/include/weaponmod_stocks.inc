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

#if defined _weaponmod_stocks_included
  #endinput
#endif
#define _weaponmod_stocks_included

#if !defined _amxmodx_included
  #include <amxmodx>
#endif

#if !defined _weaponmod_included
	#include <weaponmod>
#endif

#if !defined _fakemeta_included
	#include <fakemeta>
#endif


/* Gets weaponmod's config directory (automically creates if not existent)
* 
*   returns	0 when dir doesn't exist and creation failed
*/
stock get_weaponmoddir(name[], len)
{
	new configsdir[64];
	get_localinfo("amxx_configsdir", configsdir, 63);
	formatex(name, len, "%s/weaponmod", configsdir);
	
	if(!dir_exists(name))
	{
		if(mkdir(name) != 0)
		{
			return 0;
		}
	}
	
	// We successed
	return 1;
}

/* Gets weaponmod's log directory (automically creates if not existent)
* 
*   returns	0 when dir doesn't exist and creation failed
*/
stock get_weaponmod_logdir(name[], len)
{
	new weaponmoddir[64];
	get_weaponmoddir(weaponmoddir, 63);
	formatex(name, len, "%s/logs", weaponmoddir);
	
	if(!dir_exists(name))
	{
		if(mkdir(name) != 0)
		{
			return 0;
		}
	}
	
	return 1;
}

/* Gets the weapon id of the current hold weapon
* 
*   returns	Real weapon id (-1 if no WeaponMod weapon used)
*/
stock wpn_get_user_weapon_real(id)
{
	new usrwpn = wpn_get_user_weapon(id);
	if(usrwpn != -1)
	{
		return wpn_get_userinfo(id, usr_wpn_index, usrwpn);
	}
	
	return -1;
}

/* Checks if the player really owns the give weapon
* 
*   id		Player id
*   wpnid		Real weapon id
*   returns	ture if the player owns the given weapon
*/
stock bool:wpn_user_owns_weapon(id, wpnid)
{
	return (wpn_has_weapon(id, wpnid) != -1);
}

/* Removes weapon from a user by its real weapon id
*
*   returns	0 if user doesn't own the given weapon
*/
stock wpn_remove_weapon_real(id, wpnid)
{
	new usrwpn = wpn_has_weapon(id, wpnid);
	if(usrwpn != -1)
	{
		wpn_remove_weapon(id, usrwpn);
		return 1;
	}
	
	return 0;
}

/* Drops weapon from a user by its real weapon id
*
*   returns	0 if user doesn't own the given weapon
*/
stock wpn_drop_weapon_real(id, wpnid)
{
	new usrwpn = wpn_has_weapon(id, wpnid);
	if(usrwpn != -1)
	{
		wpn_drop_weapon(id, usrwpn);
		return 1;
	}
	
	return 0;
}

/* Zooms player's view (useful for sniper guns)
*
*   amount	Zoom amount
*/
stock wpn_set_user_zoom(id, amount=90)
{
	static msgSetFOV;
	if (!msgSetFOV)
		msgSetFOV = get_user_msgid("SetFOV");
	
	message_begin(MSG_ONE, msgSetFOV, {0,0,0}, id);
	write_byte(amount);
	message_end();
}

/* Gives a player a full weapon or refills it if he already owns one
*
*   id			Player id
*   wpnid			Weapon id
*   refillSound	Sound that should be played when the weapon was refilled
*   returns		1 if the weapon was given, 2 if it was refilled
*/
stock wpn_give_weapon_or_refill(id, wpnid, refillSound[]="")
{
	static ammo1, ammo2, usrwpn;
	
	ammo1 = wpn_get_integer(wpnid, wpn_ammo1);
	ammo2 = wpn_get_integer(wpnid, wpn_ammo2);
	usrwpn = wpn_has_weapon(id, wpnid);
	
	if(usrwpn != -1)
	{
		// Player owns the weapon, refill it
		wpn_set_userinfo(id, usr_wpn_ammo1, usrwpn, ammo1);
		wpn_set_userinfo(id, usr_wpn_ammo2, usrwpn, ammo2);
		
		// Play pickup sound
		if(!refillSound[0])
		{
			// Get the sound from WeaponMod
			new soundfile[64];
			wpn_get_core_sound(wpn_core_sound_ammo_pickup, soundfile, 63);
			emit_sound(id, CHAN_AUTO, soundfile, 1.0, ATTN_NORM, 0, PITCH_NORM);
		} else {
			emit_sound(id, CHAN_AUTO, refillSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		
		return 2;
	}
	
	// Player doesn't own the weapon, give it to him
	wpn_give_weapon(wpnid, id, ammo1, ammo2);
	return 1;
}

/* Sets a single mod supported (useful for GameInfo plugins)
*
*   mod		Mod name (e.g. cstrike)
*   type		What is this (e.g. "GameInfo"), will be displayed in the error
*			message if the given plugin should fail if the mod is not supported
*   fail		true if the plugin should fail if it's not running on the given mod
*   returns	True if the given mod is supported
*/
stock bool:wpn_set_supported_mod(const mod[], const type[]="", bool:fail=true)
{
	new running_mod[32], info[64];
	get_modname(running_mod, 31);
	
	if(!equali(running_mod, mod))
	{
		// Invalid mod
		if(fail)
		{
			// We have to fail here
			if(type[0])
				formatex(info, 63, "Mod '%s' not supported by this %s", running_mod, type);
			else
				formatex(info, 63, "Mod '%s' not supported", running_mod);
			
			set_fail_state(info);
		}
		
		return false;
	}
	
	return true;
}

/* Sets multiple mods supported
*
*   mods		List of mod names (e.g. cstrike)
*   len		Size of the list
*   type		What is this (e.g. "GameInfo"), will be displayed in the error
*			message if the given plugin should fail if the mod is not supported
*   fail		true if the plugin should fail if it's not running on the given mod
*   returns	True if the given mod is supported
*/
stock bool:wpn_set_supported_mods(const mods[][], len, const type[]="", bool:fail=true)
{
	new bool:failNow = false;
	
	for(new i = 0; i < len; i++)
	{
		if(i == len-1 && fail) failNow = true;
		if(wpn_set_supported_mod(mods[i], type, failNow))
		{
			return true;
		}
	}
	
	return false;
}

/* Damages all entities around the center (excluding players and monsters)
*
*   inflictor			Entity/Player that causes the damage
*   damage			Damage that should be done to the entitiy
*   source			Source origin of the impact
*   radius			Damage radius
*   killBreakAbles		Set this to true if breakables should break
*/
stock wpn_entity_radius_damage(inflictor, Float:damage, const Float:source[3], Float:radius, bool:killBreakAbles=true)
{
	new ent=-1, classname[32];
	new Float:falloff, Float:distance, Float:takeDamage, Float:tmpDamage, Float:health;
	
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, source, radius)) != 0)
	{
		// We've found an entity, make sure it's valid and not a player/monster
		if(!pev_valid(ent)) continue;
		if((pev(ent, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER))) continue;
		
		// Break the breakable
		if(killBreakAbles)
		{
			pev(ent, pev_classname, classname, 31);
			if(equali(classname, "func_breakable"))
			{
				dllfunc(DLLFunc_Use, ent, inflictor);
				continue;
			}
		}
		
		// Make sure it can take damage
		pev(ent, pev_takedamage, takeDamage);
		if(!takeDamage) continue;
		
		// Calculate the damage with the distance
		tmpDamage = damage - (distance * falloff);
		if(tmpDamage <= 0.0) continue;
		
		// Now do the damage
		pev(ent, pev_health, health);
		health -= tmpDamage;
		if(health < 0.0)
		{
			health = 0.0;
		}
		set_pev(ent, pev_dmg_inflictor, inflictor);
		set_pev(ent, pev_health, health);
	}
	
	return 1;
}

/* Finds the weapon id of a weapon by given name/shortname
*
*   name			Name of the weapon to find
*   isShortName	True if the shortname is given
*   returns		-1 if weapon was not found or the real weapon id
*/
stock wpn_find_weapon_by_name(name[], bool:isShortName=true)
{
	new current[32];
	for(new i = 0; i < wpn_weapon_count(); i++)
	{
		wpn_get_string(i, isShortName ? wpn_short : wpn_name, current, 31);
		if(equal(current, name))
		{
			return i;
		}
	}
	
	return -1;
}

/* Checks if a player uses the given weapon
*
*   id		Player id
*   wpnid		Real weapon id
*/
stock wpn_uses_weapon(id, wpnid)
{
	static usrwpn; usrwpn = wpn_has_weapon(id, wpnid);
	if(wpn_gi_is_default_weapon(get_user_weapon(id)) && usrwpn != -1 && usrwpn == wpn_get_user_weapon(id))
	{
		return true;
	}
	return false;
}
