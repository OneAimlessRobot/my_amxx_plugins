/* Copyright (C) 2009 Space Headed Productions
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
#include <weaponmod>
#include <weaponmod_stocks>

// Plugin informations
new const PLUGIN[] = "Weapon Spawner"
new const VERSION[] = "0.1"
new const AUTHOR[] = "DevconeS"
new const PREFIX[] = "[Weapon Spawner]"

// Important data
new const MENU_TITLE[] = "[Weapon Spawner] Spawnpoint Editor"
new const Float:MENU_TIMES[] = {1.0, 2.0, 3.0, 5.0, 10.0, 15.0, 20.0, 30.0}	// Times that can be selected within the menu (minutes)
new const WPN_ENTITY_NAME[] = "wpn_entity"

#define ROTATION_STEP		0.05		// Stepping beetween each rotation movement
#define ROTATION_AMOUNT		6.0		// Amount the weapon should rotate each step
#define MAX_MAP_ENTS		1036		// Default value of hl engine -> 1035, this should be the same as in WeaponMod
#define MAX_WPN_SPAWN_POINTS	64		// Max weapons that can be spawned on a MAP
#define SPAWN_TASK_ID		1561		// Task ID used to spawn weapons
#define SPAWN_TASK_DELAY		60.0		// Time to wait beetween each spawn (does not interrupt the times defined in file)
#define WEAPON_SEARCH_RADIUS	10.0		// Radius to search for weapons when a weapon should be spawned

// Map infos
new g_MapFile[128]
new Float:g_WeaponSpawnDelay[MAX_WPN_SPAWN_POINTS]
new Float:g_WeaponNextSpawn[MAX_WPN_SPAWN_POINTS]
new Float:g_WeaponSpawnOrigin[MAX_WPN_SPAWN_POINTS][3]
new g_WeaponSpawnType[MAX_WPN_SPAWN_POINTS]
new g_WeaponSpawnPointCount

// Required menu data
new g_coloredMenus
new g_MenuPage[33]
new g_MenuCurTime[33]

// Weapon infos
new g_WeaponCount
new Float:g_NextRotationTime

// Initialize the plugin
public plugin_init()
{
	// Register the plugin
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Register client commands
	register_clcmd("wpn_spawnpoint_menu", "cmdSpawnPointMenu", ADMIN_BAN, "- Opens WeaponMod weapon spawnpoint menu")
	
	// Register menu
	register_menucmd(register_menuid(MENU_TITLE), 1023, "actionSpawnPointMenu")
	g_coloredMenus = colored_menus()
	
	// Hook forwards
	register_forward(FM_StartFrame, "fwd_StartFrame")
	
	// Get general WeaponMod information
	g_WeaponCount = wpn_weapon_count()
	
	// Start the spawn task
	load_map_configuration()
	set_task(SPAWN_TASK_DELAY, "respawn_weapons", SPAWN_TASK_ID)
}

// Loads map configuration and spawns all weapons the first time
load_map_configuration()
{
	// Get current filename
	new wmoddir[64], map[32], dir[64]
	get_weaponmoddir(wmoddir, 63)
	get_mapname(map, 31)
	formatex(g_MapFile, 127, "%s/spawner/%s.cfg", wmoddir, map)
	
	// Make sure that the config dir exists
	formatex(dir, 63, "%s/spawner/", wmoddir)
	if(!dir_exists(dir))
	{
		mkdir(dir)
	}
	
	
	// Open file
	new fp = fopen(g_MapFile, "r")
	if(!fp)
	{
		server_print("%s Spawnpoint file for map %s could not be loaded (no weapons will be spawned)", PREFIX, map)
		return PLUGIN_CONTINUE
	}
	
	// Prepare data
	new data[256], weapon[64], xAxis[8], yAxis[8], zAxis[8], respawnTime[8], weaponID
	new Float:weaponOrigin[3]
	
	// Read file until fileend or the weapon limit has been reached
	while(!feof(fp) && g_WeaponSpawnPointCount <= MAX_WPN_SPAWN_POINTS)
	{
		// Read the current line
		fgets(fp, data, 255)
		replace_all(data, 255, "^n", "")	// We don't want to include newline ;)
		if(data[0] == '^0') continue
		
		// Parse the data
		parse(data, weapon, 63, xAxis, 7, yAxis, 7, zAxis, 7, respawnTime, 7)
		
		// Transform to an origin array
		weaponOrigin[0] = str_to_float(xAxis)
		weaponOrigin[1] = str_to_float(yAxis)
		weaponOrigin[2] = str_to_float(zAxis)
		
		// Get the weapon ID of the current weapon using its short name
		if(equali(weapon, "random"))
		{
			weaponID = -1	// Random Weapon
		} else {
			weaponID = wpn_find_weapon_by_name(weapon, true)
			if(weaponID == -1)
			{
				// Invalid weapon name
				server_print("%s A weapon with the short name '%s' does not exist - ignoring", PREFIX, weapon)
				continue
			}
		}
		
		// Store loaded spawnpoint
		g_WeaponSpawnDelay[g_WeaponSpawnPointCount] = str_to_float(respawnTime)
		g_WeaponSpawnOrigin[g_WeaponSpawnPointCount] = weaponOrigin
		g_WeaponSpawnType[g_WeaponSpawnPointCount] = weaponID
		
		// Spawn the weapon
		spawn_weapon(g_WeaponSpawnPointCount)
		
		// Increase spawnpoint count
		g_WeaponSpawnPointCount++
		
		// Some info :)
		server_print("%s Loaded %d spawnpoints for map %s", PREFIX, g_WeaponSpawnPointCount, map)
	}
	
	// Close the file handle
	fclose(fp)
	return PLUGIN_CONTINUE
}

// Menu command executed
public cmdSpawnPointMenu(id,level,cid)
{
	if(!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED
	displaySpawnPointMenu(id, 0)
	return PLUGIN_HANDLED
}

// Handles menu actions
displaySpawnPointMenu(id, page)
{
	// Calculate the total amount of pages
	g_MenuPage[id] = page
	new menu[512], keys, len, name[32]
	new pageCount = ((g_WeaponCount+1)/7) + ((((g_WeaponCount+1)%7) > 0) ? 1 : 0)
	
	// use colored menus if possible
	if(g_coloredMenus)
		len = formatex(menu, 511, "\r%s\R%d/%d^n\w^n", MENU_TITLE, g_MenuPage[id]+1, pageCount)
	else
		len = formatex(menu, 511, "%s %d/%d^n^n", MENU_TITLE, g_MenuPage[id]+1, pageCount)
	
	// Calculate start and end position of the players (7 players per page)
	new start = g_MenuPage[id]*7
	new end = (((start+7) <= g_WeaponCount+1) ? start+7 : g_WeaponCount+1)
	
	// Cycle through all weapons and add them to the menu
	for(new i = start; i < end; i++)
	{
		if(i < 1)
		{
			// Add Random
			if(g_coloredMenus)
				len += formatex(menu[len], 511-len, "\y%d. Random Weapon\w^n", i+1-start, name)
			else
				len += formatex(menu[len], 511-len, "%d. Random Weapon^n", name)
		} else {
			// Add element to the menu
			wpn_get_string(i-1, wpn_name, name, 31)
			len += formatex(menu[len], 511-len, "%d. %s^n", i+1-start, name)
		}
		
		// Register key
		keys |= (1<<i-start)
	}
	
	// Add currently selected time to menu on position 8
	keys |= (1<<7)
	len += formatex(menu[len], 511-len, "^n8. %.0f Minutes^n", MENU_TIMES[g_MenuCurTime[id]])
	
	// If there are more players available, add next button
	if(g_MenuPage[id]+1 < pageCount)
	{
		keys |= (1<<8)
		len += formatex(menu[len], 511-len, "^n9. Next")
	}
	
	// If we're on the first page, add exit button, otherwise back
	keys |= (1<<9)
	if(start <= 0)
		len += formatex(menu[len], 511-len, "^n0. Exit")
	else
		len += formatex(menu[len], 511-len, "^n0. Back")
		
	// Finally show the generated menu
	show_menu(id, keys, menu)
	return PLUGIN_CONTINUE
}

// Handles pressed key of the weapon spawnpoint menu
public actionSpawnPointMenu(id,key)
{
	switch(key)
	{
		case 7:
		{
			// Next time
			g_MenuCurTime[id]++
			if(g_MenuCurTime[id] >= sizeof(MENU_TIMES))
			{
				// Time limit reached, start from the beginning
				g_MenuCurTime[id] = 0
			}
			
			displaySpawnPointMenu(id, g_MenuPage[id])
		}
		case 8:
		{
			// Next weapon page
			g_MenuPage[id]++
			displaySpawnPointMenu(id, g_MenuPage[id])
		}
		case 9: {
			if(g_MenuPage[id] > 0)
			{
				// Previous weapon page
				g_MenuPage[id]--
				displaySpawnPointMenu(id, g_MenuPage[id])
			}
		}
		
		default:
		{
			// Create spawn point at this position
			new weaponID = g_MenuPage[id]*7+key-1
			
			// Get origin
			new Float:origin[3]
			pev(id, pev_origin, origin)
			
			// Get short weapon name
			new shortname[32]
			if(weaponID == -1)
				formatex(shortname, 31, "random")
			else
				wpn_get_string(weaponID, wpn_short, shortname, 31)
			
			// Get time in seconds
			new Float:respawnTime = MENU_TIMES[g_MenuCurTime[id]]*60.0
			
			// store data in file
			new fp = fopen(g_MapFile,"a")
			if(fp)
			{
				new data[256]
				formatex(data, 255, "%s %.0f %.0f %.0f %.0f^n", shortname, origin[0], origin[1], origin[2], respawnTime)
				fputs(fp,data)
				
				fclose(fp)
				
				// Successfully saved data
				g_WeaponSpawnDelay[g_WeaponSpawnPointCount] = respawnTime
				g_WeaponSpawnOrigin[g_WeaponSpawnPointCount] = origin
				g_WeaponSpawnType[g_WeaponSpawnPointCount] = weaponID
				g_WeaponSpawnPointCount++
				client_print(id, print_chat, "%s Successfully saved spawnpoint (%s). The weapon will be spawned within the next spawn queue.", PREFIX, shortname)
			} else {
				// File could not be opened
				client_print(id, print_chat, "%s Failed to open spawpoint file %s, can't save data", PREFIX, g_MapFile)
			}
			
			// We do not want to close the menu ;)
			displaySpawnPointMenu(id, g_MenuPage[id])
		}
	}
}

// Spawns all weapons when time's come and there's no other on its place
public respawn_weapons()
{
	// Cycle through all loaded spawnpoints
	new Float:currentTime = get_gametime()
	for(new i = 0; i < g_WeaponSpawnPointCount; i++)
	{
		// Is the time come to spawn the weapon?
		if(currentTime < g_WeaponNextSpawn[i]) continue
		
		// If theres a weapon at this place, do not spawn this weapon
		if(is_weapon_in_sphere(g_WeaponSpawnOrigin[i], WEAPON_SEARCH_RADIUS)) continue
		
		// Spawn this weapon
		spawn_weapon(i)
	}
	
	// Reset task
	set_task(SPAWN_TASK_DELAY, "respawn_weapons", SPAWN_TASK_ID)
}

is_weapon_in_sphere(Float:origin[3], Float:radius)
{
	// Find a weapon around this place
	static ent, classname[32]
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, origin, radius)) != 0)
	{
		pev(ent, pev_classname, classname, 31)
		if(equali(classname, WPN_ENTITY_NAME)) 
		{
			// Weapon on this position found
			return true
		}
	}
	return false
}

// Spawns the weapon assigned to the given spawnpoint
spawn_weapon(spawnID)
{
	// get a random weapon if required
	static weaponID, entID
	weaponID = g_WeaponSpawnType[spawnID]
	if(weaponID == -1) weaponID = get_random_weapon()
	
	// Spawn the weapon on the map
	entID = wpn_spawn_weapon(weaponID, g_WeaponSpawnOrigin[spawnID], wpn_get_integer(weaponID, wpn_ammo1), wpn_get_integer(weaponID, wpn_ammo2))
	if(entID > 0)
	{
		// Update spawntime
		g_WeaponNextSpawn[spawnID] = get_gametime() + g_WeaponSpawnDelay[spawnID]
	}
	return entID
}

// Returns a random weapon
get_random_weapon()
{
	return random_num(0, g_WeaponCount-1)
}

// Handle spawned weapons
public wpn_event_post(player, wpnid, wpn_event:event, params[])
{
	// Reserve some memory :)
	static entID = 0
	static Float:glowColor[3]
	static Float:angles[3]
	
	if(event == event_worldspawn_post)
	{
		// A new WeaponMod weapon has been spawned
		entID = player	// Just to avoid confusion ;)
		
		// Random glow color
		glowColor[0] = random_float(0.0, 255.0)
		glowColor[1] = random_float(0.0, 255.0)
		glowColor[2] = random_float(0.0, 255.0)
		
		// Set some GFX
		set_pev(entID, pev_renderfx, kRenderFxGlowShell)
		set_pev(entID, pev_rendercolor, glowColor)
		set_pev(entID, pev_rendermode, kRenderNormal)
		set_pev(entID, pev_renderamt, 10)
		
		// Cross it a little bit
		pev(entID, pev_angles, angles)
		angles[0] = -15.0
		set_pev(entID, pev_angles, angles)
	}
}

// Called each server frame
public fwd_StartFrame()
{
	// Search for WeaponMod weapon entities
	static Float:currentTime
	static ent = 0
	currentTime = get_gametime()
	
	// check if weapons should be rotated now
	if(currentTime >= g_NextRotationTime)
	{
		while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", WPN_ENTITY_NAME)) != 0)
		{
			rotate_weapon(ent)
		}
		g_NextRotationTime = currentTime+ROTATION_STEP
	}
}

// Used to do a nice rotation animation on the weapon :)
rotate_weapon(entID)
{
	// Only handle WeaponMod weapon entities in here ;)
	if(!wpn_is_wpnentity(entID)) return FMRES_IGNORED
	
	// Get the angles
	static Float:angles[3]
	
	// Rotate the entity
	pev(entID, pev_angles, angles)
	angles[1] += ROTATION_AMOUNT
	set_pev(entID, pev_angles, angles)
	
	// We're done
	return FMRES_IGNORED
}
