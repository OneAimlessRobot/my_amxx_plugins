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
#include <amxmisc>
#include <fakemeta>
#include <weaponmod_const.inc>

// Enable this if you're using The Specialists
// #define TS_FIX

// Plugin informations
new const PLUGIN[] = "WeaponMod"
new const AUTHOR[] = "DevconeS"

// Version information
new const VERSION_NUMBER[] = "1.2"
new const VERSION_CODE_SHORT[] = "a"
new const VERSION_CODE_LONG[] = "Alpha"

// General
#define MAX_GAME_INFOS			3
#define MAX_WEAPONS				16
#define MAX_SZ_LENGTH			64
#define MAX_ERROR_LENGTH			1024
#define DOUBLE_DEATHMSG_BLOCK		(DMG_BULLET | DMG_BURN | DMG_NEVERGIB | DMG_CLUB | DMG_SLASH | DMG_ENERGYBEAM)

// Core sounds
#define MAX_CORE_SOUNDS	4

// Weapon infos
#define MAX_SZ_INFOS	6
#define MAX_INT_INFOS	8
#define MAX_FL_INFOS	6
#define MAX_EVENTS		13

// Addon Infos
#define MAX_ADDONS		16		// Maximum amount of addons that can be registered to WeaponMod

// User infos
#define MAX_USER_WPNS	16
#define MAX_USER_INFOS	3

// Entity infos
#define MAX_MAP_ENTS	1036		// Default value of hl engine -> 1035
#define MAX_ENT_INFOS	4

// Hm... BLOOD!
#define MAX_BLOOD			7
#define MAX_BLOOD_DISTANCE	64

// Some Task Informations
#define TASK_RELOAD_START	1452	// + 33 - Each player has his own reload task
#define TASK_REMOVE_WEAPONS	1485	// Task to remove weapons after roundend

// Sound files
new g_CoreSound[MAX_CORE_SOUNDS][MAX_SZ_LENGTH]

// Message strings
new const GI_INVALID_GAMEINFO[] = "Invalid GameInfo index: %d"
new const GI_INVALID_CORESOUND[] = "Invalid CoreSound index: %d"

new const WPN_UNREGISTERED_WPNID[] = "Weapons: Unregistered weapon index %d"
new const WPN_INVALID_WPNID[] = "Weapons: Invalid weapon index %d"
new const WPN_LIMIT_REACHED[] = "Weapons: Couldn't register weapon %s - Limit reached (%d)"

new const EV_INVALID_ID[] = "Events: Invalid event #%d registered by weapon #%d (%s)"
new const EV_REGISTRATION_FAILED[] = "Events: Registering event #%d failed on weapon #%d on function '%s'"
new const EV_FORWARD_EXECUTION_FAILED[] = "Events: Executing event #%d using forward #%d of weapon #%d (%s) failed"
	
// Internal strings
new const WPN_ENTITY_NAME[] = "wpn_entity"
new const DAMAGE_ENTITY_NAME[] = "trigger_hurt"
new const EMPTY_STRING[] = ""	// Don't even think of changing this

// Game Infos
new g_GameInfos[MAX_GAME_INFOS]

// Weapon datas
new g_sz_wpn[MAX_WEAPONS][MAX_SZ_INFOS][MAX_SZ_LENGTH]
new g_int_wpn[MAX_WEAPONS][MAX_INT_INFOS]
new Float:g_fl_wpn[MAX_WEAPONS][MAX_FL_INFOS]
new bool:g_wpn_reg[MAX_WEAPONS]
new g_wpnEvents[MAX_WEAPONS][MAX_EVENTS]
new g_wpnCount

// Events
new g_events[MAX_WEAPONS][MAX_EVENTS][MAX_SZ_LENGTH]

// Addons
new g_addons[MAX_ADDONS]
new g_addonCount

// Client datas
new g_UserWpns[33][MAX_USER_WPNS][MAX_USER_INFOS]
new g_UserActWpn[33]
new g_UserWpnCount[33]
new Float:g_NextShot[33]
new bool:g_BlockUserDataId[33]
new g_UserOldButtons[33]

// Mapentity datas
new g_EntInfos[MAX_MAP_ENTS][MAX_ENT_INFOS]

// User messages
new g_msgDeathMsg

// Blood
new g_blood
new g_bloodspray

// General Information
new g_MaxPlayers

// Block the whole suicide (including logging :))
new bool:g_BlockSuicide
new g_BlockPlayer

// CVAR Pointers
new g_Enabled
new g_PickupAmmo
new g_HeadshotDamage
new g_FriendlyFire
new g_KickBackForce
new g_KickBackForceFF
new g_MonsterFrags
new g_MonsterHeadshots
new g_ImpactThroughObjects

// Weapon Forwards
new g_EventPre
new g_EventPost
new g_AtkDamage
new g_AtkDamagePost

// GameInfo Forwards
new g_UpdateAmmo
new g_ResetWeapon
new g_PlayerKilled

// These natives are required by WeaponMod to work, they have to be registered in each GameInfo file
native wpn_gi_is_default_weapon(weapon);
native wpn_gi_set_offset_int(player, index, value);
native wpn_gi_get_offset_int(player, index);
native bool:wpn_gi_in_freeze_time();
native wpn_gi_take_default_weapon(id);
native wpn_gi_get_gunshot_decal();
native wpn_gi_get_smallblood_decal();
#if defined TS_FIX
native wpn_gi_get_user_weapon(id, &ammo1, &ammo2);
#endif

// Ininitializise WeaponMod
public plugin_init()
{
	// Basic plugin informations :)
	new version[16]
	formatex(version, 15, "%s%s", VERSION_NUMBER, VERSION_CODE_SHORT)
	register_plugin(PLUGIN, version, AUTHOR)
	
	// Build fully qualified version number
	formatex(version, 15, "%s %s", VERSION_NUMBER, VERSION_CODE_LONG)
	register_cvar("wpn_version", version, FCVAR_SERVER|FCVAR_SPONLY)
	
	// CVARs
	g_Enabled = register_cvar("wpn_enabled", "1")	// Enables/Disables WeaponMod
	g_PickupAmmo = register_cvar("wpn_pickup_ammo", "0")	// Enables/Disables ammo pickup
	g_HeadshotDamage = register_cvar("wpn_headshot_damage", "0")	// Damage done in a headshot (0=instant kill, others=damage multiplier)
	
	g_FriendlyFire = register_cvar("wpn_friendlyfire", "1")	// Enables/Disables friendlyfire
	g_KickBackForce = register_cvar("wpn_kickback_force", "1.0")	// Defines kickback force on enemys (1.0 = 100%)
	g_KickBackForceFF = register_cvar("wpn_kickback_force_ff", "1.0")	// Defines kickback force on teammates (1.0 = 100%)
	g_MonsterFrags = register_cvar("wpn_monster_frags", "0")	// Defines how many frags should be given for killing a monster
	g_MonsterHeadshots = register_cvar("wpn_monster_headshots", "1")	// Defines if it's possible to do headshots on monsters
	g_ImpactThroughObjects = register_cvar("wpn_impact_through_objects", "0")	// Defines if the impact should go through walls or not
	
	// Client Commands
	register_clcmd("drop", "cmdDrop")
	register_concmd("weaponmod", "cmdWeaponMod", 0, "- access WeaponMod information")
	
	// Events
	register_event("DeathMsg", "eventDeathMsg", "a")
	register_logevent("endround", 2, "0=World triggered", "1=Round_End")
	
	// Forwards
	register_forward(FM_CmdStart, "fwd_CmdStart")
	register_forward(FM_UpdateClientData, "fwd_UpdateClientDataPost", 1)
	register_forward(FM_Touch, "fwd_Touch")
	register_forward(FM_AlertMessage, "fwd_AlertMessage")
	
	// User messages
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	
	// Weapon Forwards
	g_EventPre = CreateMultiForward("wpn_event_pre", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_STRING)
	g_EventPost = CreateMultiForward("wpn_event_post", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_STRING)
	g_AtkDamage = CreateMultiForward("wpn_attack_damage", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_AtkDamagePost = CreateMultiForward("wpn_attack_damage_post", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	
	// GameInfo Forwards
	g_UpdateAmmo = CreateMultiForward("wpn_gi_update_ammo", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_ResetWeapon = CreateMultiForward("wpn_gi_reset_weapon", ET_STOP, FP_CELL)
	g_PlayerKilled = CreateMultiForward("wpn_gi_player_killed", ET_STOP, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_STRING, FP_CELL)

	// Others
	g_MaxPlayers = get_maxplayers()
}

// Everything should be initialized, load configurations
public plugin_cfg()
{
	// Build path
	new configsdir[32], wpnmoddir[64]
	get_configsdir(configsdir, 31)
	formatex(wpnmoddir, 63, "%s/weaponmod/", configsdir)
	
	// Execute configuration files
	server_cmd("exec %s/weaponmod.cfg", wpnmoddir)
	server_cmd("exec %s/addons.cfg", wpnmoddir)
}

// Cleans weaponmod registrations
public plugin_end()
{
	// Clean up registered forward
	// First the weapon forwards
	DestroyForward(g_EventPre)
	DestroyForward(g_EventPost)
	DestroyForward(g_AtkDamage)
	DestroyForward(g_AtkDamagePost)
	
	// Now the GameInfo
	DestroyForward(g_UpdateAmmo)
	DestroyForward(g_ResetWeapon)
	DestroyForward(g_PlayerKilled)
	
	// Finally all event forwards registered by the weapons
	for(new i = 0; i < g_wpnCount; i++)
	{
		for(new j = 0; j < MAX_EVENTS; j++)
		{
			new fwdId = g_wpnEvents[i][j]
			if(fwdId != -1)
			{
				DestroyForward(fwdId)
			}
		}
	}
}

// Precache are little amount of files
public plugin_precache()
{
	// Store sound files
	formatex(g_CoreSound[wpn_core_sound_weapon_empty], MAX_SZ_LENGTH-1, "weapons/357_cock1.wav")
	formatex(g_CoreSound[wpn_core_sound_weapon_drop], MAX_SZ_LENGTH-1, "items/weapondrop1.wav")
	formatex(g_CoreSound[wpn_core_sound_weapon_pickup], MAX_SZ_LENGTH-1, "items/gunpickup2.wav")
	formatex(g_CoreSound[wpn_core_sound_ammo_pickup], MAX_SZ_LENGTH-1, "weapons/generic_shot_reload.wav")
	
	g_blood = precache_model("sprites/blood.spr")
	g_bloodspray = precache_model("sprites/bloodspray.spr")
	
	// Precache sounds
	precache_sound(g_CoreSound[wpn_core_sound_weapon_empty])
	precache_sound(g_CoreSound[wpn_core_sound_weapon_drop])
	precache_sound(g_CoreSound[wpn_core_sound_weapon_pickup])
	precache_sound(g_CoreSound[wpn_core_sound_ammo_pickup])
}

// Register WeaponMod library and the natives
public plugin_natives()
{
	register_library("WeaponMod")
	
	// GameInfo
	register_native("wpn_set_gameinfo", "native_set_gameinfo")
	register_native("wpn_get_gameinfo", "native_get_gameinfo")
	
	// Core information
	register_native("wpn_set_core_sound", "native_set_core_sound")
	register_native("wpn_get_core_sound", "native_get_core_sound")
	
	// Weapon Information
	register_native("wpn_register_weapon", "native_register_weapon")
	register_native("wpn_register_event", "native_register_event")
	register_native("wpn_get_event", "native_get_event")
	register_native("wpn_set_string", "native_set_string")
	register_native("wpn_get_string", "native_get_string")
	register_native("wpn_set_integer", "native_set_integer")
	register_native("wpn_get_integer", "native_get_integer")
	register_native("wpn_set_float", "native_set_float")
	register_native("wpn_get_float", "native_get_float")
	register_native("wpn_weapon_count", "native_weapon_count")
	
	// Addon Information
	register_native("wpn_register_addon", "native_register_addon")
	register_native("wpn_get_addon", "native_get_addon")
	register_native("wpn_get_addon_count", "native_get_addon_count")
	
	// Some useful natives :p
	register_native("wpn_damage_user", "native_damage_user")
	register_native("wpn_fake_damage", "native_fake_damage")
	register_native("wpn_radius_damage", "native_radius_damage")
	register_native("wpn_kill_user", "native_kill_user")
	register_native("wpn_fake_kill", "native_fake_kill")
	register_native("wpn_create_blood", "native_create_blood")
	register_native("wpn_bullet_shot", "native_bullet_shot")
	register_native("wpn_playanim", "native_playanim")
	register_native("wpn_give_weapon", "native_give_weapon")
	register_native("wpn_spawn_weapon", "native_spawn_weapon")
	register_native("wpn_set_entity_view", "native_set_entity_view")
	register_native("wpn_user_silentkill", "native_user_silentkill")
	register_native("wpn_projectile_startpos", "native_projectile_startpos")
	register_native("wpn_remove_weapons", "native_remove_weapons")
	
	// User information
	register_native("wpn_get_user_weapon", "native_get_user_weapon")
	register_native("wpn_user_weapon_count", "native_user_weapon_count")
	register_native("wpn_change_user_weapon", "native_change_user_weapon")
	register_native("wpn_has_weapon", "native_has_weapon")
	register_native("wpn_set_userinfo", "native_set_userinfo")
	register_native("wpn_get_userinfo", "native_get_userinfo")
	register_native("wpn_reload_weapon", "native_reload_weapon")
	register_native("wpn_remove_weapon", "native_remove_weapon")
	register_native("wpn_drop_weapon", "native_drop_weapon")
	
	// Entity information
	register_native("wpn_is_wpnentity", "native_is_wpnentity")
	register_native("wpn_set_entinfo", "native_set_entinfo")
	register_native("wpn_get_entinfo", "native_get_entinfo")
}

// Checks given weaponid for that is correct, if not it will log the error
bool:check_wpn_id(wpnid)
{
	if(wpnid > -1 && wpnid < MAX_WEAPONS)
	{
		if(g_wpn_reg[wpnid])
		{
			return true
		} else{
			// Unregistered
			log_error(AMX_ERR_NATIVE, WPN_UNREGISTERED_WPNID, wpnid)
		}
	} else {
		// Invalid index
		log_error(AMX_ERR_NATIVE, WPN_INVALID_WPNID, wpnid)
	}
	
	// Invalid weapon
	return false
}

bool:is_team_attack(attacker, victim)
{
	if(!(pev(victim, pev_flags) & (FL_CLIENT | FL_FAKECLIENT)))
	{
		// Victim is a monster, so definetely no team attack ;)
		return false
	}
	
	if(get_pcvar_num(g_FriendlyFire) == 0 && g_GameInfos[gi_teamplay] == 1)
	{
		// FriendlyFire disabled on a TeamPlay game, check teams
		if(get_user_team(victim) == get_user_team(attacker))
		{
			// Team attack
			return true
		}
	}
	
	// No team attack or friendlyfire is disabled
	return false
}

public native_set_gameinfo(id)
{
	new gameinfo = get_param(1)
	
	if(gameinfo < 0 || gameinfo >= MAX_GAME_INFOS)
	{
		log_error(AMX_ERR_NATIVE, GI_INVALID_GAMEINFO, gameinfo)
		return 0
	}
	
	// Store the plugin id and the received information
	g_GameInfos[gi_pluginid] = id
	g_GameInfos[gameinfo] = get_param(2)
	return 1
}

public native_get_gameinfo()
{
	new gameinfo = get_param(1)
	
	if(gameinfo < 0 || gameinfo >= MAX_GAME_INFOS)
	{
		log_error(AMX_ERR_NATIVE, GI_INVALID_GAMEINFO, gameinfo)
		return 0
	}
	
	return g_GameInfos[gameinfo]
}

public native_set_core_sound()
{
	new coresound = get_param(1)
	if(coresound < 0 || coresound >= MAX_CORE_SOUNDS)
	{
		log_error(AMX_ERR_NATIVE, GI_INVALID_CORESOUND, coresound)
		return 0
	}
	
	// Store core sound
	return get_string(2, g_CoreSound[coresound], MAX_SZ_LENGTH-1)
}

public native_get_core_sound()
{
	new coresound = get_param(1)
	if(coresound < 0 || coresound >= MAX_CORE_SOUNDS)
	{
		log_error(AMX_ERR_NATIVE, GI_INVALID_CORESOUND, coresound)
		return 0
	}
	
	// Provide the core sound
	return set_string(2, g_CoreSound[coresound], get_param(3))
}

public native_register_weapon(id)
{
	if(g_wpnCount < MAX_WEAPONS)
	{
		get_string(1, g_sz_wpn[g_wpnCount][wpn_name], MAX_SZ_LENGTH-1)
		get_string(2, g_sz_wpn[g_wpnCount][wpn_short], MAX_SZ_LENGTH-1)
		g_wpn_reg[g_wpnCount] = true
		
		new file[32], name[32], version[8], author[32], status[32]
		get_plugin(id, file, 32, name, 32, version, 8, author, 32, status, 32)
		g_sz_wpn[g_wpnCount][wpn_file] = file
		
		g_int_wpn[g_wpnCount][wpn_pluginid] = id
		
		// Reset events
		for(new i = 0; i < MAX_EVENTS; i++)
		{
			g_wpnEvents[g_wpnCount][i] = -1;
		}
		
		// Now, set all the default values :)
		g_int_wpn[g_wpnCount][wpn_count_bullets1] = 1
		g_int_wpn[g_wpnCount][wpn_count_bullets2] = 1
		
		g_wpnCount++
	} else {
		new name[MAX_SZ_LENGTH]
		get_string(1, name, MAX_SZ_LENGTH-1)
		log_error(AMX_ERR_NATIVE, WPN_LIMIT_REACHED, name, MAX_WEAPONS)
		return -1
	}
	
	return g_wpnCount-1
}

public native_register_event(id)
{
	new wpnid = get_param(1)
	new wpn_event:evid = wpn_event:get_param(2)
	if(!check_wpn_id(wpnid))
	{
		return PLUGIN_CONTINUE
	} else if(evid < wpn_event:0 || evid >= wpn_event:MAX_EVENTS)
	{
		log_error(AMX_ERR_NATIVE, EV_INVALID_ID, evid, wpnid, g_sz_wpn[wpnid][wpn_name])
		return PLUGIN_CONTINUE
	}
	
	new func[MAX_SZ_LENGTH]
	get_string(3, func, MAX_SZ_LENGTH-1)
	
	// Some events receive more than one parameter
	new fwdId = -1;
	if(evid == event_attack1 || evid == event_attack2 || evid == event_weapondrop_post)
	{
		fwdId = CreateOneForward(g_int_wpn[wpnid][wpn_pluginid], func, FP_CELL, FP_CELL)
	} else {
		fwdId = CreateOneForward(g_int_wpn[wpnid][wpn_pluginid], func, FP_CELL)
	}
	
	// Check if the registration were successful
	if(fwdId > 0)
	{
		g_wpnEvents[wpnid][evid] = fwdId
	} else {
		log_error(AMX_ERR_NATIVE, EV_REGISTRATION_FAILED, evid, wpnid, func)
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

public native_get_event(id)
{
	new wpnid = get_param(1)
	new evid = get_param(2)
	if(!check_wpn_id(wpnid))
	{
		return PLUGIN_CONTINUE
	} else if(evid < 0 || evid >= MAX_EVENTS)
	{
		log_error(AMX_ERR_NATIVE, EV_INVALID_ID, evid, wpnid, g_sz_wpn[wpnid][wpn_name])
		return PLUGIN_CONTINUE
	}
	set_string(3, g_events[wpnid][evid], get_param(4))
	
	return PLUGIN_CONTINUE
}

public native_set_string(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return PLUGIN_CONTINUE
	}
	get_string(3, g_sz_wpn[wpnid][get_param(2)], MAX_SZ_LENGTH-1)
	
	return PLUGIN_CONTINUE
}

public native_get_string(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return PLUGIN_CONTINUE
	}
	set_string(3, g_sz_wpn[wpnid][get_param(2)], get_param(4))
	
	return PLUGIN_CONTINUE
}

public native_set_integer(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return PLUGIN_CONTINUE
	}
	g_int_wpn[wpnid][get_param(2)] = get_param(3)
	
	return PLUGIN_CONTINUE
}

public native_get_integer(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return -1
	}
	
	return g_int_wpn[wpnid][get_param(2)]
}

public native_set_float(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return PLUGIN_CONTINUE
	}
	g_fl_wpn[wpnid][get_param(2)] = get_param_f(3)
	
	return PLUGIN_CONTINUE
}

public Float:native_get_float(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return -1.0
	}
	
	return g_fl_wpn[wpnid][get_param(2)]
}

public native_weapon_count()
{
	return g_wpnCount
}

// Registers an addon to WeaponMod
public native_register_addon(id)
{
	if(g_addonCount >= MAX_ADDONS)
	{
		// Log error
		return 0
	}
	
	// Store the addon id
	g_addons[g_addonCount++] = id
	
	return 1
}

public native_get_addon()
{
	new aid = get_param(1)
	
	if(aid >= g_addonCount)
	{
		// Log error
		return -1
	}
	
	// Return the addon
	return g_addons[aid]
}

public native_get_addon_count()
{
	// Return addon count
	return g_addonCount
}

// Causes damage to a player/monster, if health goes 0 or less, the kill function will be called
damage_user(wpnid, victim, attacker, dmg_save, dmg_take, dmg_type, hitplace=0, bool:isFake=false)
{
	new bool:isVictimMonster = true
	new flags = pev(victim, pev_flags)
	new Float:takeDamage
	pev(victim, pev_takedamage, takeDamage)
	
	// This does nothing, I know, it's just to remove the compilation warning
	if(dmg_save) {}
	
	if((flags & FL_GODMODE || takeDamage == 0.0) && !isFake)
	{
		// Player/Monster got godmode, ignore it
		return 0
	}
	
	if(flags & (FL_CLIENT | FL_FAKECLIENT))
	{
		// The victim's definetely a player, do a check for team attack
		isVictimMonster = false
		if(is_team_attack(attacker, victim))
		{
			// User's attacking someone from the same team, friendlyfire's disabled
			// and it's a templay game. So don't do any damage :)
			return 0
		} else if(!is_user_alive(victim) && !isFake)
		{
			// Victim is not alive, ignore him
			return 0
		}
	}
	
	// Calculate remaining health after causing the damage
	new Float:health
	pev(victim, pev_health, health)
	if(health <= 0.0 && !isFake)
	{
		// No more health, player or monster's already dead, ignore it
		return 0
	}
	
	// Execute damage forward
	new res
	ExecuteForward(g_AtkDamage, res, victim, attacker, wpnid, dmg_take, hitplace, dmg_type, isVictimMonster)
	if(res == PLUGIN_HANDLED) return -2	// Something prevents weaponmod from doing damage :o
	
	// Let other things (e.g. plugins) know, who attacked this player
	set_pev(victim, pev_dmg_inflictor, attacker)
	
	new origDamage = dmg_take
	if(!isFake)
	{
		new Float:damage = float(dmg_take)
		new bool:killed = false
		if(hitplace == 1)
		{
			// Headshot
			if(!isVictimMonster || (isVictimMonster && get_pcvar_num(g_MonsterHeadshots) == 1))
			{
				// Get headshot damage multiplier and check the damage to be done
				new Float:hsDamageMultiplier = get_pcvar_float(g_HeadshotDamage)
				if(hsDamageMultiplier == 0.0)
				{
					// Instant headshot kill enabled
					kill_user(wpnid, victim, attacker, hitplace, dmg_type)
					killed = true
				} else {
					// Multiply the damage to be done
					damage *= hsDamageMultiplier
				}
			}
		}
		
		// Do damage if the victim was not killed
		if(!killed)
		{
			health -= damage
			if(health <= 0.0)
			{
				// Victim dies after the attack, so kill him
				kill_user(wpnid, victim, attacker, hitplace, dmg_type)
			} else {
				// Just cause the damage
				fake_damage(attacker, victim, wpnid, damage, dmg_type)
			}
		}
	}
	
	// Post execution
	ExecuteForward(g_AtkDamagePost, res, victim, attacker, wpnid, origDamage, hitplace, dmg_type, isVictimMonster)
	return dmg_take
}

public native_damage_user()
{
	if(!check_wpn_id(get_param(1)))
	{
		return 0
	}
	
	return damage_user(get_param(1), get_param(2), get_param(3), get_param(4),
		get_param(5), get_param(6), get_param(7)) 
}

public native_fake_damage()
{
	return damage_user(get_param(1), get_param(2), get_param(3), get_param(4),
		get_param(5), get_param(6), get_param(7), true) 
}

public native_radius_damage(id)
{
	// Get given parameters
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return 0
	}
	
	new attacker = get_param(2)
	new Float:vecSrc[3]
	new inflictor = get_param(3)
	pev(inflictor, pev_origin, vecSrc)
	new Float:range = get_param_f(4)
	new Float:damage = get_param_f(5)
	new dmgtype = get_param(6)
	
	new ent = -1
	new Float:tmpdmg = damage
	new hitCount = 0
	new Float:kickback = 0.0
	
	// Get CVAR data (we don't want to get them each iteration)
	new Float:kickBackForce = get_pcvar_float(g_KickBackForce)
	new Float:KickBackForceFF = get_pcvar_float(g_KickBackForceFF)
	new throughObjects = get_pcvar_num(g_ImpactThroughObjects)
	
	// Needed for doing some nice calculations :P
	new Float:Tabsmin[3], Float:Tabsmax[3]
	new Float:vecSpot[3]
	new Float:Aabsmin[3], Float:Aabsmax[3]
	new Float:vecSee[3]
	new trRes
	new Float:flFraction
	new Float:vecEndPos[3]
	new Float:distance
	new Float:origin[3], Float:vecPush[3]
	new Float:invlen
	new Float:velocity[3]
	
	// Calculate falloff
	new Float:falloff
	if (range > 0.0)
	{
		falloff = damage / range
	} else {
		falloff = 1.0
	}
	
	// Find monsters and players inside a specifiec radius
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, vecSrc, range)) != 0)
	{
		if(!pev_valid(ent)) continue
		if(!(pev(ent, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
		{
			// Entity is not a player or monster, ignore it
			continue
		}
		
		// Reset data
		kickback = kickBackForce
		tmpdmg = damage
		
		// The following calculations are provided by Orangutanz, THANKS!
		// We use absmin and absmax for the most accurate information
		pev(ent, pev_absmin, Tabsmin)
		pev(ent, pev_absmax, Tabsmax)
		vecSpot[0] = (Tabsmin[0] + Tabsmax[0]) * 0.5
		vecSpot[1] = (Tabsmin[1] + Tabsmax[1]) * 0.5
		vecSpot[2] = (Tabsmin[2] + Tabsmax[2]) * 0.5
		
		pev(inflictor, pev_absmin, Aabsmin)
		pev(inflictor, pev_absmax, Aabsmax)
		vecSee[0] = (Aabsmin[0] + Aabsmax[0]) * 0.5
		vecSee[1] = (Aabsmin[1] + Aabsmax[1]) * 0.5
		vecSee[2] = (Aabsmin[2] + Aabsmax[2]) * 0.5
		
		engfunc(EngFunc_TraceLine, vecSee, vecSpot, 0, inflictor, trRes)
		get_tr2(trRes, TR_flFraction, flFraction)
		// Explosion can 'see' this entity, so hurt them! (or impact through objects has been enabled xD)
		if (flFraction >= 0.9 || get_tr2(trRes, TR_pHit) == ent || throughObjects != 0)
		{
			// Work out the distance between impact and entity
			get_tr2(trRes, TR_vecEndPos, vecEndPos)
			
			distance = get_distance_f(vecSrc, vecEndPos) * falloff
			tmpdmg -= distance
			if(tmpdmg < 0.0)
				tmpdmg = 0.0
			
			// Kickback Effect
			if(is_team_attack(attacker, ent))
			{
				// Team attack, modify force of the kickback
				kickback = KickBackForceFF
			}
			if(kickback != 0.0 && (dmgtype & (DMG_BLAST | DMG_CLUB | DMG_SHOCK | DMG_SONIC | DMG_ENERGYBEAM | DMG_MORTAR)))
			{
				origin[0] = vecSpot[0] - vecSee[0]
				origin[1] = vecSpot[1] - vecSee[1]
				origin[2] = vecSpot[2] - vecSee[2]
				
				invlen = 1.0/get_distance_f(vecSpot, vecSee)
				vecPush[0] = origin[0] * invlen
				vecPush[1] = origin[1] * invlen
				vecPush[2] = origin[2] * invlen
				
				pev(ent, pev_velocity, velocity)
				velocity[0] = velocity[0] + vecPush[0] * tmpdmg * kickback
				velocity[1] = velocity[1] + vecPush[1] * tmpdmg * kickback
				velocity[2] = velocity[2] + vecPush[2] * tmpdmg * kickback
				
				if(tmpdmg < 60.0)
				{
					velocity[0] *= 12.0
					velocity[1] *= 12.0
					velocity[2] *= 12.0
				} else {
					velocity[0] *= 4.0
					velocity[1] *= 4.0
					velocity[2] *= 4.0
				}
				
				if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0)
				{
					// There's some movement todo :)
					set_pev(ent, pev_velocity, velocity)
				}
			}
			
			// Send info to Damage system
			if(damage_user(wpnid, ent, attacker, 0, floatround(tmpdmg), dmgtype))
			{
				hitCount++
			}
		}
	}
	
	return hitCount
}

// Kills given player or monster
kill_user(wpnid, victim, attacker, hitplace, dmg_type, bool:isFakeKill=false)
{
	// Get some information about the victim
	new flags = pev(victim, pev_flags)
	new bool:isVictimMonster = (flags & FL_MONSTER) ? true : false
	new Float:takeDamage
	pev(victim, pev_takedamage, takeDamage)
	
	// We do not cause any damage if the victim has godmode
	if((flags & FL_GODMODE || takeDamage == 0.0) && !isFakeKill)
	{
		return 0
	}
	
	// No need to check for friendly fire if the victim's a monster
	if(!isVictimMonster)
	{
		if(is_team_attack(attacker, victim))
		{
			// Team attack with disabled friendly fire on a teamplay game, what the hell we're doing here?
			return 0
		}
	}
	
	new Float:fragIncreasement = 1.0	// By default, a player just gets 1 frag for killing an enemy
	new weapon[MAX_SZ_LENGTH]
	weapon = g_sz_wpn[wpnid][wpn_short]
	
	if(!isFakeKill)
	{
		// No fakekill, kill the victim
		player_silentkill(victim, attacker, wpnid, dmg_type)
	}
	
	if(isVictimMonster)
	{
		// Monster
		fragIncreasement = get_pcvar_float(g_MonsterFrags)
		if(fragIncreasement == 0.0)
		{
			// Monster was killed, but players don't get frags for doing this,
			// no reason to continue
			return 1
		}
	}
	
	new Float:frags
	pev(attacker, pev_frags, frags)
	
	if(g_GameInfos[gi_teamplay] == 0)
	{
		// No teamplay, no need to check the teams
		frags += fragIncreasement
	} else {
		// Templay, increase/decrease frags
		if(isVictimMonster)
		{
			// Player's and monsters can't be in the same team I think ^^
			frags += fragIncreasement
		} else {
			if(get_user_team(attacker) != get_user_team(victim))
			{
				frags += fragIncreasement
			} else {
				frags -= fragIncreasement
			}
		}
	}
	set_pev(attacker, pev_frags, frags)
	
	// Let the GameInfo plugin do its job :)
	new res
	ExecuteForward(g_PlayerKilled, res, victim, attacker, hitplace, wpnid, weapon, isVictimMonster)
	
	// If the player killed a monster, we shouldn't continue on here
	if(isVictimMonster)
	{
		return 1
	}
	
	new aname[32], aauthid[32], ateam[10]
	get_user_name(attacker, aname, 31)
	get_user_team(attacker, ateam, 9)
	get_user_authid(attacker, aauthid, 31)
	
 	if(attacker != victim) 
	{
 		new vname[32], vauthid[32], vteam[10]
		get_user_name(victim, vname, 31)
		get_user_team(victim, vteam, 9)
		get_user_authid(victim, vauthid, 31)
		
		// Log the kill information
		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", 
			aname, get_user_userid(attacker), aauthid, ateam, 
		 	vname, get_user_userid(victim), vauthid, vteam, weapon)
	} else {
		// User killed himself xD
		log_message("^"%s<%d><%s><%s>^" committed suicide with ^"%s^"", 
			aname, get_user_userid(attacker), aauthid, ateam, weapon)
	}
	return 1
}

public native_kill_user()
{
	// Get given parameters
	if(!check_wpn_id(get_param(1)))
	{
		return 0
	}
	return kill_user(get_param(1), get_param(2), get_param(3), get_param(4), get_param(5))
}

public native_fake_kill()
{
	if(!check_wpn_id(get_param(1)))
	{
		return 0
	}
	return kill_user(get_param(1), get_param(2), get_param(3), get_param(4), get_param(5), true)
}

create_blood(Float:sourceOrigin[3], target, amount, distance, color=70)
{
	// Get the origin of the target
	new Float:targetOrigin[3]
	pev(target, pev_origin, targetOrigin)
	
	// Show some blood :)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(TE_BLOODSPRITE)
	write_coord(floatround(targetOrigin[0])) 
	write_coord(floatround(targetOrigin[1])) 
	write_coord(floatround(targetOrigin[2])) 
	write_short(g_bloodspray)
	write_short(g_blood)
	write_byte(color)
	write_byte(amount)
	message_end()
	
	// Calculate the direction of the blood
	new Float:traceEnd[3]
	traceEnd[0] = (sourceOrigin[0]-targetOrigin[0])*distance
	traceEnd[1] = (sourceOrigin[1]-targetOrigin[1])*distance
	traceEnd[2] = (sourceOrigin[2]-targetOrigin[2])*distance
	
	// Draw a trace line to get the place for blood on the wall
	new res, Float:wallOrigin[3]
	engfunc(EngFunc_TraceLine, sourceOrigin, traceEnd, 0, target, res)
	get_tr2(res, TR_vecEndPos, wallOrigin)
	
	// Put blood on the walls if they're near enough
	if(wallOrigin[0] != traceEnd[0] || wallOrigin[1] != traceEnd[1] ||
		wallOrigin[2] != traceEnd[2])
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(floatround(wallOrigin[0]))
		write_coord(floatround(wallOrigin[1]))
		write_coord(floatround(wallOrigin[2]))
		write_byte(wpn_gi_get_smallblood_decal())
		message_end()
	}
	
	return 1
}

public native_create_blood()
{
	new Float:sourceOrigin[3]
	get_array_f(1, sourceOrigin, 3)
	
	create_blood(sourceOrigin, get_param(2), get_param(3), get_param(4), get_param(5))
}

public native_bullet_shot(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return 0
	}
	
	new attacker = get_param(2)
	new dmg_save = get_param(3)
	new dmg_take = get_param(4)
	
	// Find target
	new aimOrigin[3], target, body
	get_user_origin(attacker, aimOrigin, 3)
	get_user_aiming(attacker, target, body)
	
	new hit = 0
	if(target > 0)
	{
		if(pev(target, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER))
		{
			// Target found, cause some damage
			new damage = damage_user(wpnid, target, attacker, dmg_save, dmg_take, DMG_BULLET, body)
			
			// Get the attackers location for the blood source
			new Float:attackerOrigin[3]
			pev(attacker, pev_origin, attackerOrigin)
			
			// Calculate the blood amount
			new amount = 0
			if(damage == -1) amount = 2
			else if(damage > 50) amount = 1
			
			// Now show the blood :)
			create_blood(attackerOrigin, target, amount, MAX_BLOOD_DISTANCE)
			hit = target
		}
	}
	
	if(hit == 0)
	{
		new decal = wpn_gi_get_gunshot_decal()
		
		// Check if the wall hit is an entity
		if(target)
		{
			// Put decal on an entity
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DECAL)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_byte(decal)
			write_short(target)
			message_end()
		} else {
			// Put decal on "world" (a wall)
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_WORLDDECAL)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_byte(decal)
			message_end()
		}
		
		// Show sparcles
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		write_coord(aimOrigin[0])
		write_coord(aimOrigin[1])
		write_coord(aimOrigin[2])
		write_short(attacker)
		write_byte(decal)
		message_end()
		
		hit = -1
	}
	return hit
}

public native_playanim()
{
	new player = get_param(1)
	new anim = get_param(2)
	set_pev(player, pev_weaponanim, anim)
	
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, player)
	write_byte(anim)
	write_byte(pev(player, pev_body))
	message_end()
}

public native_give_weapon(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return -2
	}
	
	return give_weapon(get_param(2), wpnid, get_param(3), get_param(4))
}

public native_spawn_weapon(id)
{
	new wpnid = get_param(1)
	if(!check_wpn_id(wpnid))
	{
		return PLUGIN_CONTINUE
	}
	
	new Float:origin[3]
	get_array_f(2, origin, 3)
	spawn_weapon(wpnid, origin, get_param(3), get_param(4))
	
	return PLUGIN_CONTINUE
}

public native_set_entity_view()
{
	new entity = get_param(1)
	new Float:Target[3], Float:Origin[3], Float:Angles[3]
	get_array_f(2, Target, 3)
	pev(entity, pev_origin, Origin)
	
	Target[0] -= Origin[0]
	Target[1] -= Origin[1]
	Target[2] -= Origin[2]
	
	vector_to_angle(Target, Angles)
	Angles[0] = 360-Angles[0]
	
	set_pev(entity, pev_v_angle, Angles)
	Angles[0] *= -1
	set_pev(entity, pev_angles, Angles)
	set_pev(entity, pev_fixangle, 1)
}

public native_user_silentkill()
{
	player_silentkill(get_param(1), 0, -1, DMG_GENERIC)
}

public native_projectile_startpos()
{
	new player = get_param(1)
	new forw = get_param(2)
	new right = get_param(3)
	new up = get_param(4)
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3], Float:vSrc[3]
	
	pev(player, pev_origin, vOrigin)
	pev(player, pev_v_angle, vAngle)
	
	engfunc(EngFunc_MakeVectors, vAngle)
	
	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)
	
	vSrc[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vSrc[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vSrc[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
	
	set_array_f(5, vSrc, 3)
}

public native_remove_weapons()
{
	remove_weapons()
	return 1
}

public native_get_user_weapon()
{
	new player = get_param(1)
	return g_UserActWpn[player]
}

public native_user_weapon_count()
{
	new player = get_param(1)
	return g_UserWpnCount[player]
}

public native_change_user_weapon()
{
	new player = get_param(1)
	new weapon = get_param(2)
	g_BlockUserDataId[player] = bool:get_param(3)
	change_weapon(player, weapon)
	
	return 1
}

public native_has_weapon()
{
	new player = get_param(1)
	new wpnid = get_param(2)
	
	for(new i = 0; i < g_UserWpnCount[player]; i++)
	{
		if(g_UserWpns[player][i][usr_wpn_index] == wpnid)
			return i
	}
	return -1
}

public native_set_userinfo()
{
	new player = get_param(1)
	new index = get_param(2)
	new userwpn = get_param(3)
	new value = get_param(4)
	
	g_UserWpns[player][userwpn][index] = value
	update_hud(player)
}

public native_get_userinfo()
{
	new player = get_param(1)
	new index = get_param(2)
	new userwpn = get_param(3)
	
	return g_UserWpns[player][userwpn][index]
}

public native_reload_weapon()
{
	new player = get_param(1)
	weapon_reload(player)
}

public native_remove_weapon()
{
	new id = get_param(1)
	new weapon = get_param(2)

	// Switch to the next weapon
	g_UserWpnCount[id]--
	if(g_UserWpnCount[id] > 0)
	{
		// Player still owns other WeaponMod weapons
		if(g_UserWpnCount[id] != weapon)
		{
			g_UserWpns[id][weapon] = g_UserWpns[id][g_UserWpnCount[id]]
		}
		if(is_user_alive(id)) g_UserActWpn[id] = 0
	} else {
		// Player doesn't own any other weapons
		g_UserActWpn[id] = -1
	}
	
	if(is_user_alive(id))
	{
		// Refresh used weapon :)
		change_weapon(id, g_UserActWpn[id])
	}
	
	if(g_UserWpnCount[id] < 0)
	{
		// Do not let it go less than 0 !!!
		g_UserWpnCount[id] = 0
	}
}

public native_drop_weapon()
{
	new id = get_param(1)
	new wpn = get_param(2)
	
	drop_weapon(id, wpn)
}

public native_is_wpnentity()
{
	new entity = get_param(1)
	new classname[32]
	
	if(pev_valid(entity))
	{
		pev(entity, pev_classname, classname, 31)
		if(equal(classname, WPN_ENTITY_NAME))
			return 1
	}
	return 0
}

public native_set_entinfo()
{
	new index = get_param(1)
	new info = get_param(2)
	new value = get_param(3)
	
	g_EntInfos[index][info] = value
}

public native_get_entinfo()
{
	new index = get_param(1)
	new info = get_param(2)
	
	return g_EntInfos[index][info]
}

// As you'll see, this is used to hook the attack and reload buttons :)
public fwd_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || g_UserActWpn[id] == -1) return FMRES_IGNORED
	
	// I prefer static here since this function is called quite often
	static Float:ctime
	static Float:recoilForce
	static Float:recoil[3]
	static weapon, temp
	static wpnid
	static buttons
	static wpn_event:attack, bool:atk1, bullets, param[1], attackResult
	
#if defined TS_FIX
	weapon = wpn_gi_get_user_weapon(id, temp, temp)
#else
	weapon = get_user_weapon(id, temp, temp)
#endif
	attack = wpn_event:-1
	
	// Check for the delay
	ctime = get_gametime()
	
	if(wpn_gi_is_default_weapon(weapon))
	{
		buttons = get_uc(uc_handle, UC_Buttons)
		wpnid = g_UserWpns[id][g_UserActWpn[id]][usr_wpn_index]
		
		// Released attack1?
		if((g_UserOldButtons[id] & IN_ATTACK) && !(buttons & IN_ATTACK))
		{
			// Check old buttons if they're still pressed
			if (pev(id, pev_oldbuttons) & IN_ATTACK) return FMRES_IGNORED;
			
			// User released attack1
			if(execute_event(id, wpnid, event_attack1_released, EMPTY_STRING) == PLUGIN_HANDLED)
			{
				// Releasing of the attack1 button has been blocked
				buttons &= IN_ATTACK
			}
		}
		if((g_UserOldButtons[id] & IN_ATTACK2) && !(buttons & IN_ATTACK2))
		{
			// Check old buttons if they're still pressed
			if (pev(id, pev_oldbuttons) & IN_ATTACK2) return FMRES_IGNORED;
			
			// User released attack2
			if(execute_event(id, wpnid, event_attack2_released, EMPTY_STRING) == PLUGIN_HANDLED)
			{
				// Releasing of the attack2 button has been blocked
				buttons &= IN_ATTACK2
			}
		}
		
		// Store old buttons
		g_UserOldButtons[id] = buttons
		
		if(buttons & IN_ATTACK)
		{
			attack = event_attack1
			atk1 = true
		} else if(buttons & IN_ATTACK2)
		{
			attack = event_attack2
			atk1 = false
		}
		
		// Remove attack 1 and attack 2 from the sent buttons
		buttons &= ~IN_ATTACK
		buttons &= ~IN_ATTACK2
		set_uc(uc_handle, UC_Buttons, buttons)
		
		// Make sure that the player is not reloading
		if(task_exists(TASK_RELOAD_START+id)) return FMRES_HANDLED
		
		if(attack != wpn_event:-1)
		{
			// If players are still in freezetime, we do not continue on here
			if(wpn_gi_in_freeze_time()) return FMRES_HANDLED
			
			// Make sure that the player can't shoot until his delay is over
			if(g_NextShot[id] > ctime) return FMRES_HANDLED
			
			// Get amount of ammo required by the player to do the given action (attack1 or attack2)
			bullets = g_int_wpn[wpnid][atk1 ? wpn_bullets_per_shot1 : wpn_bullets_per_shot2]
			if(g_UserWpns[id][g_UserActWpn[id]][usr_wpn_ammo1] >= bullets || g_int_wpn[wpnid][wpn_ammo1] < 1)
			{
				// Execute attack event
				param[0] = bullets
				attackResult = execute_event(id, wpnid, attack, param)
				
				if(attackResult != PLUGIN_HANDLED)
				{
					// Nothing wants to block the WeaponMod actions, so continue :)
					g_UserWpns[id][g_UserActWpn[id]][usr_wpn_ammo1] -= bullets
					
					// Recoil
					recoilForce = g_fl_wpn[wpnid][atk1 ? wpn_recoil1 : wpn_recoil2]
					if(recoilForce > 0.0)
					{
						recoil[0] = random_float(recoilForce*-1, 0.0)	// up - down
						recoil[1] = random_float(recoilForce*-1, 0.0)	// right - left
						recoil[2] = 0.0	// Screen rotation
						
						set_pev(id, pev_punchangle, recoil)
					}
					
					// Everything's done, now sync the hud
					update_hud(id)
					
					// Set the time when the user is able to shoot the next time
					g_NextShot[id] = ctime+g_fl_wpn[wpnid][atk1 ? wpn_refire_rate1 : wpn_refire_rate2]
					
					if(g_UserWpns[id][g_UserActWpn[id]][usr_wpn_ammo2] > 0 && g_UserWpns[id][g_UserActWpn[id]][usr_wpn_ammo1] <= 0
						&& g_int_wpn[wpnid][wpn_ammo1] > 0)
					{
						// Ammo1 is 0 or less and player has still some ammo2, so reload :)
						weapon_reload(id)
					}
				}
			} else if(g_UserWpns[id][g_UserActWpn[id]][usr_wpn_ammo2] > 0)
			{
				// Not enough primary ammo, reload weapon
				weapon_reload(id)
			} else {
				// No primary and secondary ammo
				if(execute_event(id, wpnid, event_empty, EMPTY_STRING) != PLUGIN_HANDLED)
				{
					// WeaponMod actions not blocked, so do it :p
					emit_sound(id, CHAN_WEAPON, g_CoreSound[wpn_core_sound_weapon_empty], 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_NextShot[id] = ctime+1.0
				}
			}
		} else if(buttons & IN_RELOAD)
		{
			// Player wants to reload, so do the favour
			weapon_reload(id)
		}
		
		return FMRES_HANDLED
	}
	
	return FMRES_IGNORED
}

// We fully block the animation in here
public fwd_UpdateClientDataPost(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id) || g_UserActWpn[id] == -1) return FMRES_IGNORED
	
	// I prefer static here since this function is called quite often
	static weapon, temp
#if defined TS_FIX
	weapon = wpn_gi_get_user_weapon(id, temp, temp)
#else
	weapon = get_user_weapon(id, temp, temp)
#endif
	if(wpn_gi_is_default_weapon(weapon))
	{
		if(g_BlockUserDataId[id])
		{
			// Block animation
			set_cd(cd_handle, CD_ID, 0)
			return FMRES_HANDLED
		} else {
			// Block animation next time
			g_BlockUserDataId[id] = true
		}
	}
	
	// User isn't using a WeaponMod weapon, ignore it
	return FMRES_IGNORED
}

// Block logging of the DeathMsg
player_silentkill(id, attacker, wpnid, dmg_type)
{
	static bool:blocking
	blocking = false
	if(dmg_type & DOUBLE_DEATHMSG_BLOCK)
	{
		// The suicide DeathMsg is emitted only for some damage types
		set_msg_block(g_msgDeathMsg, BLOCK_ONCE)
		blocking = true
	}
	
	// New way for killing players
	static Float:health
	pev(id, pev_health, health)
	
	set_pev(id, pev_dmg_inflictor, attacker)
	fake_damage(attacker, id, wpnid, health, dmg_type)
	
	// Fix for things that don't get killed by fake damage (some bots don't like it)
	pev(id, pev_health, health)
	if(health > 0.0)
	{
		if(!blocking)
		{
			set_msg_block(g_msgDeathMsg, BLOCK_ONCE)
		}
		g_BlockSuicide = true
		g_BlockPlayer = id
		user_kill(id, 1)
	}
}

// This is used to block messages sent to console for a real silent kill :)
public fwd_AlertMessage(msgType, message[])
{
	if(g_BlockSuicide)
	{
		if(pev_valid(g_BlockPlayer))
		{
			if(pev(g_BlockPlayer, pev_flags) & (FL_CLIENT | FL_FAKECLIENT))
			{
				new authid[32], name[32], logmsg[1024], team[32]
				get_user_authid(g_BlockPlayer, authid, 31)
				get_user_name(g_BlockPlayer, name, 31)
				get_user_team(g_BlockPlayer, team, 31)
				new userid = get_user_userid(g_BlockPlayer)
				
				formatex(logmsg, 1023, "^"%s<%d><%s><%s>^" committed suicide with ^"world^"^n", name, userid, authid, team)
				
				// Check if the handled message is a suicide message that has to be blocked
				if(equal(message, logmsg))
				{
					g_BlockSuicide = false
					return FMRES_SUPERCEDE
				}
				
				// Not the message we wanted, ignore it
				return FMRES_IGNORED
			}
		}
		
		// If we're here, the player isn't available anymore
		g_BlockSuicide = false
	}
	return FMRES_IGNORED
}

// Begin of a reload
public weapon_reload(id)
{
	// Check first that the player actually is able to reload
	new curwpn = g_UserActWpn[id]
	new wpnid = g_UserWpns[id][curwpn][usr_wpn_index]
	if(g_UserWpns[id][curwpn][usr_wpn_ammo1] >= g_int_wpn[wpnid][wpn_ammo1] || g_UserWpns[id][curwpn][usr_wpn_ammo2] < 1)
		return PLUGIN_CONTINUE
	
	if(execute_event(id, wpnid, event_reload, EMPTY_STRING) == PLUGIN_HANDLED)
	{
		// Reloading blocked
		return PLUGIN_CONTINUE
	}
	
	// Create task for a delayed reload
	new Float:rtime = g_fl_wpn[wpnid][wpn_reload_time]
	set_task(rtime, "end_reload", TASK_RELOAD_START+id)
	
	// Player shouldn't be able to fire while reloading ;)
	g_NextShot[id] = rtime+get_gametime()
	
	return PLUGIN_CONTINUE
}

// End of a reload
public end_reload(taskid)
{
	new id = taskid-TASK_RELOAD_START
	
	new curwpn = g_UserActWpn[id]
	if(curwpn == -1) return PLUGIN_CONTINUE
	
	// Shortcuts to some information ;)
	new wpnid = g_UserWpns[id][curwpn][usr_wpn_index]
	new ammo1 = g_UserWpns[id][curwpn][usr_wpn_ammo1]
	new ammo2 = g_UserWpns[id][curwpn][usr_wpn_ammo2]
	
	// Calculate amount of bullets that should be reloaded
	new toreload = g_int_wpn[wpnid][wpn_ammo1]-ammo1
	new reload = 0
	
	// Make sure player really has this amount of bullets, otherwise reload with the remaining bullets
	if(toreload <= ammo2)
		reload = toreload
	else
		reload = ammo2
	
	g_UserWpns[id][curwpn][usr_wpn_ammo1] += reload
	g_UserWpns[id][curwpn][usr_wpn_ammo2] -= reload
	update_hud(id)
	return PLUGIN_CONTINUE
}

// Stops reloading
stop_weapon_reload(id)
{
	if(task_exists(TASK_RELOAD_START+id))
	{
		remove_task(TASK_RELOAD_START+id)
	}
}

// Drop command
public cmdDrop(id)
{
	if(!get_pcvar_num(g_Enabled)) return PLUGIN_CONTINUE
	
	// Only drop weapon, if the player really has one ;)
	if(g_UserWpnCount[id] > 0 && g_UserActWpn[id] > -1)
	{
		// Make sure player's really using a special weapon
		new temp
#if defined TS_FIX
		new weapon = wpn_gi_get_user_weapon(id, temp, temp)
#else
		new weapon = get_user_weapon(id, temp, temp)
#endif
		if(wpn_gi_is_default_weapon(weapon))
		{
			drop_weapon(id, g_UserActWpn[id])
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

// Someone wants to know something about WeaponMod ;)
public cmdWeaponMod(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED
	
	new cmd[16], plugin[32], null[1], version[8], author[32]
	read_argv(1, cmd, 15)
	
	if(equali(cmd, "version"))
	{
		// Display version information
		console_print(id, "   WeaponMod  v%s  %s  (http://www.space-headed.net)", VERSION_NUMBER, VERSION_CODE_LONG)
	} else if(equali(cmd, "team"))
	{
		// Display list of developers
		console_print(id, "   Christoph  ^"DevconeS^"  Amrein  -  Lead coder, project founder")
	} else if(equali(cmd, "credits"))
	{
		// Display credits
		console_print(id, "   Space Headed Productions  -  For supporting and hosting WeaponMod")
		console_print(id, "   SHP Beta Tester Team  -  For hardly testing WeaponMod")
		console_print(id, "   Phil  ^"Orangutanz^"  Poland  -  For providing some of the used calculations")
		console_print(id, "   Arkshine  -  For helping to improve the WeaponMod functionallity")
		console_print(id, "   AMX Mod X  -  For its powerful features which make WeaponMod possible")
	} else if(equali(cmd, "weapons"))
	{
		// Display registered weapons
		console_print(id, "registered weapons:  %i/%i", g_wpnCount, MAX_WEAPONS)
		for(new i = 0; i < g_wpnCount; i++)
		{
			get_plugin(g_int_wpn[i][wpn_pluginid], null, 0, null, 0, version, 7, author, 31, null, 0)
			console_print(id, " [%s%i]  %s  %s  -  %s", i + 1 > 9 ? "" : " ", i + 1, g_sz_wpn[i][wpn_name], version, author)
		}
	} else if(equali(cmd, "addons"))
	{
		// Display registered weapons
		console_print(id, "registered addons:  %i/%i", g_addonCount, MAX_ADDONS)
		for(new i = 0; i < g_addonCount; i++)
		{
			get_plugin(g_addons[i], null, 0, plugin, 31, version, 7, author, 31, null, 0)
			console_print(id, " [%s%i]  %s  %s  -  %s", i + 1 > 9 ? "" : " ", i + 1, plugin, version, author)
		}
	} else {
		// Unknown parameter given, list all available parameters
		console_print(id, "usage: weaponmod <command>^ncommands:" )
		console_print(id, "   version  -  displays weaponmod version info")
		console_print(id, "   team  -  displays weaponmod team info")
		console_print(id, "   credits  -  displays weaponmod credits info")
		console_print(id, "   weapons  -  displays weaponmod weapons info")
		console_print(id, "   addons  -  displays weaponmod addons info")
	}
	
	return PLUGIN_HANDLED
}

// Weapon drop function
public drop_weapon(id, weapon)
{
	if(!get_pcvar_num(g_Enabled)) return PLUGIN_CONTINUE
	
	// Execute pre weapondrop event
	new wpnid = g_UserWpns[id][weapon][usr_wpn_index]
	if(execute_event(id, wpnid, event_weapondrop_pre, EMPTY_STRING) == PLUGIN_HANDLED)
	{
		// Dropping blocked
		return PLUGIN_CONTINUE
	}
	
	// Dropping was not blocked, so do it :)
	new Float:Aim[3], Float:origin[3]
	
	// Get the origin in front of player's view
	velocity_by_aim(id, 64, Aim)
	pev(id, pev_origin, origin)
	origin[0] += Aim[0]
	origin[1] += Aim[1]
	
	// Spawn weapon entity
	new ent = spawn_weapon(wpnid, origin, g_UserWpns[id][weapon][usr_wpn_ammo1], g_UserWpns[id][weapon][usr_wpn_ammo2])
	
	// Switch to the next weapon
	g_UserWpnCount[id]--
	if(g_UserWpnCount[id] > 0)
	{
		if(g_UserWpnCount[id] != weapon)
			g_UserWpns[id][weapon] = g_UserWpns[id][g_UserWpnCount[id]]
		
		if(is_user_alive(id)) g_UserActWpn[id] = 0
	} else
		g_UserActWpn[id] = -1
	
	if(is_user_alive(id))
	{
		// Play drop sound (taken from HLSDK)
		new pitch = 95+random_num(0, 29)
		emit_sound(id, CHAN_VOICE, g_CoreSound[wpn_core_sound_weapon_drop], 1.0, ATTN_NORM, 0, pitch)
		change_weapon(id, g_UserActWpn[id])
	}
	
	// Stop reloading
	stop_weapon_reload(id)
	
	// Execute post weapondrop event
	new params[8]
	params[0] = ent
	execute_event(id, wpnid, event_weapondrop_post, params)
	
	return PLUGIN_CONTINUE
}

// Spawns a weapon entity (of WeaponMod) on given origin
public spawn_weapon(wpnid, Float:origin[3], ammo1, ammo2)
{
	if(!get_pcvar_num(g_Enabled)) return 0
	
	new wpn = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!wpn) return 0
	
	// Execute pre worldspawn event
	if(execute_event(wpn, wpnid, event_worldspawn_pre, EMPTY_STRING) == PLUGIN_HANDLED)
	{
		// Worldspawn was blocked, remove entity and return
		set_pev(wpn, pev_flags, FL_KILLME)
		return PLUGIN_CONTINUE
	}
	
	set_pev(wpn, pev_classname, WPN_ENTITY_NAME)
	engfunc(EngFunc_SetModel, wpn, g_sz_wpn[wpnid][wpn_worldmodel])	
		
	set_pev(wpn, pev_mins, Float:{-16.0, -16.0, -16.0})
	set_pev(wpn, pev_maxs, Float:{16.0, 16.0, 16.0})
	
	set_pev(wpn, pev_solid, SOLID_TRIGGER)
	set_pev(wpn, pev_movetype, MOVETYPE_TOSS)
	
	set_pev(wpn, pev_origin, origin)
	
	// Register weapon to including specifiec WeaponMod infos
	g_EntInfos[wpn][ent_wpn_index] = wpnid
	g_EntInfos[wpn][ent_wpn_ammo1] = ammo1
	g_EntInfos[wpn][ent_wpn_ammo2] = ammo2
	g_EntInfos[wpn][ent_weapon_removed] = 0
	
	// Execute post worldspawn event
	execute_event(wpn, wpnid, event_worldspawn_post, EMPTY_STRING)
	
	return wpn
}

// Changes user's active weapon
public change_weapon(id, usrwpn)
{
	if(!get_pcvar_num(g_Enabled)) return PLUGIN_CONTINUE
	
	// If the player was using a special weapon, send the hide event
	if(g_UserActWpn[id] > -1)
	{
		if(execute_event(id, g_UserWpns[id][g_UserActWpn[id]][usr_wpn_index], event_hide, EMPTY_STRING) == PLUGIN_HANDLED)
		{
			// Hiding the weapon was blocked, so stop
			return PLUGIN_CONTINUE
		}
	}
	
	// Stop reloading
	stop_weapon_reload(id)
	
	// Is player's weapon the knife?
	new temp
#if defined TS_FIX
	new wpnid = wpn_gi_get_user_weapon(id, temp, temp)
#else
	new wpnid = get_user_weapon(id, temp, temp)
#endif
	if(usrwpn == -1)
	{
		
		// Is he still using the replaced weapon?
		if(wpn_gi_is_default_weapon(wpnid))
		{
			new res
			ExecuteForward(g_ResetWeapon, res, id)
			g_UserActWpn[id] = -1
			
			update_hud(id)
		}
		return PLUGIN_CONTINUE
	}
	
	// Now get the new Weaponindex
	new weapon = g_UserWpns[id][usrwpn][usr_wpn_index]
	
	// Execute draw event
	if(execute_event(id, weapon, event_draw, EMPTY_STRING) == PLUGIN_HANDLED)
	{
		// Drawing was blocked
		return PLUGIN_CONTINUE
	}
	
	set_pev(id, pev_viewmodel, engfunc(EngFunc_AllocString, g_sz_wpn[weapon][wpn_viewmodel]))
	set_pev(id, pev_weaponmodel, engfunc(EngFunc_AllocString, g_sz_wpn[weapon][wpn_weaponmodel]))
	if(!wpn_gi_in_freeze_time())
	{
		// No freezetime right now, so update the run speed
		set_pev(id, pev_maxspeed, g_fl_wpn[weapon][wpn_run_speed])
	}
		
	g_UserActWpn[id] = usrwpn
	update_hud(id)
	return PLUGIN_CONTINUE
}

// Will update players's Hud infos
public update_hud(id)
{
	if(!get_pcvar_num(g_Enabled)) return PLUGIN_CONTINUE
	
	new usrwpn = g_UserActWpn[id]
	new res
	if(usrwpn > -1)
		ExecuteForward(g_UpdateAmmo, res, id, usrwpn, g_UserWpns[id][usrwpn][usr_wpn_ammo1], g_UserWpns[id][usrwpn][usr_wpn_ammo2])
	else
		ExecuteForward(g_UpdateAmmo, res, id, -1, 0, 0)
	
	return PLUGIN_CONTINUE
}

// Called everytime an entity gets touched
public fwd_Touch(ptr, ptd)
{
	if(!get_pcvar_num(g_Enabled)) return FMRES_IGNORED
	
	if(pev_valid(ptr))
	{
		new classname[32]
		pev(ptr, pev_classname, classname, 31)
		
		if(equal(classname, WPN_ENTITY_NAME))
		{
			if(pev_valid(ptd))
			{
				new id = ptd
				if(id > 0 && id <= g_MaxPlayers && !g_EntInfos[ptr][ent_weapon_removed])
				{
					if(!is_user_alive(id)) return PLUGIN_CONTINUE
					
					// Check if player already has this weapon
					new wpnid = g_EntInfos[ptr][ent_wpn_index]
					new found = -1
					for(new i = 0; i < g_UserWpnCount[id]; i++)
					{
						if(g_UserWpns[id][i][usr_wpn_index] == wpnid)
						{
							found = i
							break
						}
					}
					
					if(found == -1)
					{
						// Player hasn't got this weapon, give it to him
						give_weapon(id, wpnid, g_EntInfos[ptr][ent_wpn_ammo1], g_EntInfos[ptr][ent_wpn_ammo2])
						set_pev(ptr, pev_flags, FL_KILLME)
					
						// This is to avoid that this weapon can be picked up twice
						g_EntInfos[ptr][ent_weapon_removed] = 1
					} else if(get_pcvar_num(g_PickupAmmo) != 0) {
						// Player can pickup the ammo
						new ammo2 = g_UserWpns[id][found][usr_wpn_ammo2] + g_EntInfos[ptr][ent_wpn_ammo1] + g_EntInfos[ptr][ent_wpn_ammo2]
						
						if(ammo2 > g_int_wpn[wpnid][wpn_ammo2])
						{
							// We don't add more ammo than the maximum
							ammo2 = g_int_wpn[wpnid][wpn_ammo2]
						}
						
						if(ammo2 > g_UserWpns[id][found][usr_wpn_ammo2])
						{
							// Player will receive some ammo, update the ammo and hud
							g_UserWpns[id][found][usr_wpn_ammo2] = ammo2
							update_hud(id)
	
							// Emit ammo pickup sound
							emit_sound(id, CHAN_AUTO, g_CoreSound[wpn_core_sound_ammo_pickup], 1.0, ATTN_NORM, 0, PITCH_NORM)
							
							// Remove the entity
							set_pev(ptr, pev_flags, FL_KILLME)
					
							// This is to avoid that this weapon can be picked up twice
							g_EntInfos[ptr][ent_weapon_removed] = 1
						}
					}
				}
			}
		}
	}
	return FMRES_IGNORED
}

// Gives a weapon to a user with given ammo1 and ammo2
public give_weapon(id, wpnid, ammo1, ammo2)
{
	if(!get_pcvar_num(g_Enabled)) return -3
	
	// Don't go over the max weapons limit!
	if(g_UserWpnCount[id] >= MAX_USER_WPNS) return -1
	
	if(execute_event(id, wpnid, event_pickup, EMPTY_STRING) == PLUGIN_HANDLED)
	{
		// Player isn't allowed to get this weapon
		return PLUGIN_CONTINUE
	}
	
	// Player weapon informations :)
	g_UserWpns[id][g_UserWpnCount[id]][usr_wpn_index] = wpnid
	g_UserWpns[id][g_UserWpnCount[id]][usr_wpn_ammo1] = ammo1
	g_UserWpns[id][g_UserWpnCount[id]][usr_wpn_ammo2] = ammo2
	g_UserWpnCount[id]++
	
	// Emit pickup sound
	emit_sound(id, CHAN_AUTO, g_CoreSound[wpn_core_sound_weapon_pickup], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	new temp
#if defined TS_FIX
	new weapon = wpn_gi_get_user_weapon(id, temp, temp)
#else
	new weapon = get_user_weapon(id, temp, temp)
#endif
	if(!wpn_gi_is_default_weapon(weapon))
	{
		// Let the player take out the default weapon
		g_UserActWpn[id] = g_UserWpnCount[id]-1
		wpn_gi_take_default_weapon(id)
	} else {
		// Default weapon's used, modify it :)
		change_weapon(id, g_UserWpnCount[id]-1)
	}
	
	return g_UserWpnCount[id]-1
}

// Called every roundend
public endround()
	set_task(4.0, "remove_weapons", TASK_REMOVE_WEAPONS)

// Removes special weapons on map
public remove_weapons()
{
	// I don't check if WeaponMod is enabled since there still could be some weapons
	new ent = 0
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", WPN_ENTITY_NAME)) != 0)
	{
		set_pev(ent, pev_flags, FL_KILLME)
	}
}

// Drop victims's weapons
public eventDeathMsg()
{
	if(!get_pcvar_num(g_Enabled)) return PLUGIN_CONTINUE
	
	new victim = read_data(2)
	if(victim > 0 && victim <= g_MaxPlayers)
	{
		new count = g_UserWpnCount[victim]
		for(new i = count-1; i >= 0; i--)
		{
			drop_weapon(victim, i)
		}
		g_UserWpnCount[victim] = 0
	}
	
	return PLUGIN_CONTINUE
}

// Reset all informations when a new client connects
public client_connect(id)
{
	g_UserActWpn[id] = -1
	g_UserWpnCount[id] = 0
	g_NextShot[id] = 0.0
}

// Executes WeaponMod events
public execute_event(id, wpnid, wpn_event:event, const params[])
{
	// Just to be sure :)
	if(!get_pcvar_num(g_Enabled)) return PLUGIN_CONTINUE
	
	// Execute pre event forward
	new res
	ExecuteForward(g_EventPre, res, id, wpnid, event, params)
	if(res == PLUGIN_HANDLED) return PLUGIN_HANDLED
	
	// Call forward (if registered)
	new fwdId = g_wpnEvents[wpnid][event]
	if(fwdId != -1)
	{
		new success = 0;
		if(event == event_attack1 || event == event_attack2 || event == event_weapondrop_post)
		{
			// Call forward with additional parameter
			success = ExecuteForward(fwdId, res, id, params[0])
		} else {
			// Call forward with standard parameters
			success = ExecuteForward(fwdId, res, id)
		}
		
		if(!success)
		{
			// Executing the forward failed, log the error
			server_print(EV_FORWARD_EXECUTION_FAILED, event, fwdId, wpnid, g_sz_wpn[wpnid][wpn_file])
		}
	}

	// Execute post event forward
	new res2
	ExecuteForward(g_EventPost, res2, id, wpnid, event, params)
	
	return res
}

// Fakedamage, taken from engine stocks, optimized and ported to fakemeta
fake_damage(attacker, victim, wpnid, Float:takedamage, damagetype)
{
	// Used quite often :D
	static entity, temp[16], wpnname[MAX_SZ_LENGTH]
	
	entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, DAMAGE_ENTITY_NAME))
	if (entity)
	{
		// Set the damage inflictor
		set_pev(victim, pev_dmg_inflictor, attacker)
		
		wpnname = (wpnid = -1) ? EMPTY_STRING : g_sz_wpn[wpnid][wpn_short]
		
		// Takedamages only do half damage per attack (damage is damage per second, and it's triggered in 0.5 second intervals).
		// Compensate for that.
		formatex(temp, 15, "%f", takedamage*2)
		set_keyvalue(entity, "dmg", temp, DAMAGE_ENTITY_NAME)
		
		formatex(temp, 15, "%i", damagetype)
		set_keyvalue(entity, "damagetype", temp, DAMAGE_ENTITY_NAME)
		
		set_keyvalue(entity, "origin", "8192 8192 8192", DAMAGE_ENTITY_NAME)
		dllfunc(DLLFunc_Spawn, entity)
		
		set_pev(entity, pev_classname, wpnname)
		set_pev(entity, pev_owner, attacker)
		dllfunc(DLLFunc_Touch, entity, victim)
		set_pev(entity, pev_flags, FL_KILLME)
		
		// Make sure the damage inflictor is not overwritten by the entity
		set_pev(victim, pev_dmg_inflictor, attacker)
		
		return 1
	}
	
	return 0
}

// Fakemeta has no "DispatchKeyValue"
set_keyvalue(entity, key[], data[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, data)
	set_kvd(0, KV_fHandled, 0)
	dllfunc(DLLFunc_KeyValue, entity, 0)
}
