/*================================================================================
	
	--------------------------------
	-*- [ZP] Rewards: Ammo Packs -*-
	--------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <hamsandwich>
#include <cs_ham_bots_api>
#include <zp50_gamemodes>
#define LIBRARY_NEMESIS "zp50_class_nemesis"
#include <zp50_class_nemesis>
#define LIBRARY_DRAGON "zp50_class_dragon"
#include <zp50_class_dragon>
#define LIBRARY_ASSASSIN "zp50_class_assassin"
#include <zp50_class_assassin>
#define LIBRARY_NIGHTCRAWLER "zp50_class_nightcrawler"
#include <zp50_class_nightcrawler>
#define LIBRARY_SURVIVOR "zp50_class_survivor"
#include <zp50_class_survivor>
#define LIBRARY_SNIPER "zp50_class_sniper"
#include <zp50_class_sniper>
#define LIBRARY_KNIFER "zp50_class_knifer"
#include <zp50_class_knifer>
#define LIBRARY_PLASMA "zp50_class_plasma"
#include <zp50_class_plasma>
#include <zp50_ammopacks>

#define MAXPLAYERS 32

new g_MaxPlayers

new Float:g_DamageDealtToZombies[MAXPLAYERS+1]
new Float:g_DamageDealtToHumans[MAXPLAYERS+1]

new cvar_ammop_winner, cvar_ammop_loser
new cvar_ammop_damage, cvar_ammop_zombie_damaged_hp, cvar_ammop_human_damaged_hp
new cvar_ammop_zombie_killed, cvar_ammop_human_killed
new cvar_ammop_human_infected
new cvar_ammop_nemesis_ignore, cvar_ammop_dragon_ignore, cvar_ammop_survivor_ignore
new cvar_ammop_assassin_ignore, cvar_ammop_sniper_ignore, cvar_ammop_nightcrawler_ignore
new cvar_ammop_plasma_ignore, cvar_ammop_knifer_ignore

public plugin_init()
{
	register_plugin("[ZP] Rewards: Ammo Packs", ZP_VERSION_STRING, "ZP Dev Team")
	
	cvar_ammop_winner = register_cvar("zp_ammop_winner", "3")
	cvar_ammop_loser = register_cvar("zp_ammop_loser", "1")
	
	cvar_ammop_damage = register_cvar("zp_ammop_damage", "1")
	cvar_ammop_zombie_damaged_hp = register_cvar("zp_ammop_zombie_damaged_hp", "500")
	cvar_ammop_human_damaged_hp = register_cvar("zp_ammop_human_damaged_hp", "250")
	cvar_ammop_zombie_killed = register_cvar("zp_ammop_zombie_killed", "1")
	cvar_ammop_human_killed = register_cvar("zp_ammop_human_killed", "1")
	cvar_ammop_human_infected = register_cvar("zp_ammop_human_infected", "1")
	
	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
		cvar_ammop_nemesis_ignore = register_cvar("zp_ammop_nemesis_ignore", "0")

	// Dragon Class loaded?
	if (LibraryExists(LIBRARY_DRAGON, LibType_Library))
		cvar_ammop_dragon_ignore = register_cvar("zp_ammop_dragon_ignore", "0")

	// Assassin Class loaded?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
		cvar_ammop_assassin_ignore = register_cvar("zp_ammop_assassin_ignore", "0")
	
	// Nightcrawler Class loaded?
	if (LibraryExists(LIBRARY_NIGHTCRAWLER, LibType_Library))
		cvar_ammop_nightcrawler_ignore = register_cvar("zp_ammop_nightcrawler_ignore", "0")
	
	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
		cvar_ammop_survivor_ignore = register_cvar("zp_ammop_survivor_ignore", "0")

	// Sniper Class loaded?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
		cvar_ammop_sniper_ignore = register_cvar("zp_ammop_sniper_ignore", "0")

                 // Knifer Class loaded?
	if (LibraryExists(LIBRARY_KNIFER, LibType_Library))
		cvar_ammop_knifer_ignore = register_cvar("zp_ammop_knifer_ignore", "0")

                // Plasma Class loaded?
	if (LibraryExists(LIBRARY_PLASMA, LibType_Library))
		cvar_ammop_plasma_ignore = register_cvar("zp_ammop_plasma_ignore", "0")

	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
	RegisterHamBots(Ham_Killed, "fw_PlayerKilled_Post", 1)
	
	g_MaxPlayers = get_maxplayers()
}

public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}
public module_filter(const module[])
{
	if (equal(module, LIBRARY_NEMESIS) || equal(module, LIBRARY_DRAGON) || equal(module, LIBRARY_ASSASSIN) || equal(module, LIBRARY_NIGHTCRAWLER) || equal(module, LIBRARY_SURVIVOR) || equal(module, LIBRARY_SNIPER) || equal(module, LIBRARY_KNIFER) || equal(module, LIBRARY_PLASMA))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
		
	return PLUGIN_CONTINUE;
}

public zp_fw_core_infect_post(id, attacker)
{
	// Reward ammo packs to zombies infecting humans?
	if (is_user_connected(attacker) && attacker != id && get_pcvar_num(cvar_ammop_human_infected) > 0)
		zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + get_pcvar_num(cvar_ammop_human_infected))
}

// Ham Take Damage Post Forward
public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_alive(attacker))
		return;
	
	// Ignore ammo pack rewards for Nemesis?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(attacker) && get_pcvar_num(cvar_ammop_nemesis_ignore))
		return;

	// Ignore ammo pack rewards for Dragon?
	if (LibraryExists(LIBRARY_DRAGON, LibType_Library) && zp_class_dragon_get(attacker) && get_pcvar_num(cvar_ammop_dragon_ignore))
		return;

	// Ignore ammo pack rewards for Assassin?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(attacker) && get_pcvar_num(cvar_ammop_assassin_ignore))
		return;

	// Ignore ammo pack rewards for Nightcrawler?
	if (LibraryExists(LIBRARY_NIGHTCRAWLER, LibType_Library) && zp_class_nightcrawler_get(attacker) && get_pcvar_num(cvar_ammop_nightcrawler_ignore))
		return;
	
	// Ignore ammo pack rewards for Survivor?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(attacker) && get_pcvar_num(cvar_ammop_survivor_ignore))
		return;

	// Ignore ammo pack rewards for Sniper?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(attacker) && get_pcvar_num(cvar_ammop_sniper_ignore))
		return;
 
                // Ignore ammo pack rewards for Knifer?
	if (LibraryExists(LIBRARY_KNIFER, LibType_Library) && zp_class_knifer_get(attacker) && get_pcvar_num(cvar_ammop_knifer_ignore))
		return;

                // Ignore ammo pack rewards for Plasma?
	if (LibraryExists(LIBRARY_PLASMA, LibType_Library) && zp_class_plasma_get(attacker) && get_pcvar_num(cvar_ammop_plasma_ignore))
		return;
	
	// Zombie attacking human...
	if (zp_core_is_zombie(attacker) && !zp_core_is_zombie(victim))
	{
		// Reward ammo packs to zombies for damaging humans?
		if (get_pcvar_num(cvar_ammop_damage) > 0)
		{
			// Store damage dealt
			g_DamageDealtToHumans[attacker] += damage
			
			// Give rewards according to damage dealt
			new how_many_rewards = floatround(g_DamageDealtToHumans[attacker] / get_pcvar_float(cvar_ammop_human_damaged_hp), floatround_floor)
			if (how_many_rewards > 0)
			{
				zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + (get_pcvar_num(cvar_ammop_damage) * how_many_rewards))
				g_DamageDealtToHumans[attacker] -= get_pcvar_float(cvar_ammop_human_damaged_hp) * how_many_rewards
			}
		}
	}
	// Human attacking zombie...
	else if (!zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
	{
		// Reward ammo packs to humans for damaging zombies?
		if (get_pcvar_num(cvar_ammop_damage) > 0)
		{
			// Store damage dealt
			g_DamageDealtToZombies[attacker] += damage
			
			// Give rewards according to damage dealt
			new how_many_rewards = floatround(g_DamageDealtToZombies[attacker] / get_pcvar_float(cvar_ammop_zombie_damaged_hp), floatround_floor)
			if (how_many_rewards > 0)
			{
				zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + (get_pcvar_num(cvar_ammop_damage) * how_many_rewards))
				g_DamageDealtToZombies[attacker] -= get_pcvar_float(cvar_ammop_zombie_damaged_hp) * how_many_rewards
			}
		}
	}
}

// Ham Player Killed Post Forward
public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
	// Non-player kill or self kill
	if (victim == attacker || !is_user_connected(attacker))
		return;
	
	// Ignore ammo pack rewards for Nemesis?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(attacker) && get_pcvar_num(cvar_ammop_nemesis_ignore))
		return;

	// Ignore ammo pack rewards for Dragon?
	if (LibraryExists(LIBRARY_DRAGON, LibType_Library) && zp_class_dragon_get(attacker) && get_pcvar_num(cvar_ammop_dragon_ignore))
		return;

	// Ignore ammo pack rewards for Assassin?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(attacker) && get_pcvar_num(cvar_ammop_assassin_ignore))
		return;

	// Ignore ammo pack rewards for Nightcrawler?
	if (LibraryExists(LIBRARY_NIGHTCRAWLER, LibType_Library) && zp_class_nightcrawler_get(attacker) && get_pcvar_num(cvar_ammop_nightcrawler_ignore))
		return;
	
	// Ignore ammo pack rewards for Survivor?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(attacker) && get_pcvar_num(cvar_ammop_survivor_ignore))
		return;

	// Ignore ammo pack rewards for Sniper?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(attacker) && get_pcvar_num(cvar_ammop_sniper_ignore))
		return;

                // Ignore ammo pack rewards for knifer?
	if (LibraryExists(LIBRARY_KNIFER, LibType_Library) && zp_class_knifer_get(attacker) && get_pcvar_num(cvar_ammop_knifer_ignore))
		return;

                // Ignore ammo pack rewards for plasma?
	if (LibraryExists(LIBRARY_PLASMA, LibType_Library) && zp_class_plasma_get(attacker) && get_pcvar_num(cvar_ammop_plasma_ignore))
		return;
	
	// Reward ammo packs to attacker for the kill
	if (zp_core_is_zombie(victim))
		zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + get_pcvar_num(cvar_ammop_zombie_killed))
	else
		zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + get_pcvar_num(cvar_ammop_human_killed))
}

public zp_fw_gamemodes_end()
{
	// Determine round winner and money rewards
	if (!zp_core_get_zombie_count())
	{
		// Human team wins
		new id
		for (id = 1; id <= g_MaxPlayers; id++)
		{
			if (!is_user_connected(id))
				continue;
			
			if (zp_core_is_zombie(id))
				zp_ammopacks_set(id, zp_ammopacks_get(id) + get_pcvar_num(cvar_ammop_loser))
			else
				zp_ammopacks_set(id, zp_ammopacks_get(id) + get_pcvar_num(cvar_ammop_winner))
		}
	}
	else if (!zp_core_get_human_count())
	{
		// Zombie team wins
		new id
		for (id = 1; id <= g_MaxPlayers; id++)
		{
			if (!is_user_connected(id))
				continue;
			
			if (zp_core_is_zombie(id))
				zp_ammopacks_set(id, zp_ammopacks_get(id) + get_pcvar_num(cvar_ammop_winner))
			else
				zp_ammopacks_set(id, zp_ammopacks_get(id) + get_pcvar_num(cvar_ammop_loser))
		}
	}
	else
	{
		// No one wins
		new id
		for (id = 1; id <= g_MaxPlayers; id++)
		{
			if (!is_user_connected(id))
				continue;
			
			zp_ammopacks_set(id, zp_ammopacks_get(id) + get_pcvar_num(cvar_ammop_loser))
		}
	}
}

public client_disconnect(id)
{
	// Clear damage after disconnecting
	g_DamageDealtToZombies[id] = 0.0
	g_DamageDealtToHumans[id] = 0.0
}
