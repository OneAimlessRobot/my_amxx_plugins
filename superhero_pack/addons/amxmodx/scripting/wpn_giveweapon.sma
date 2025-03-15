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
#include <weaponmod>
#include <weaponmod_stocks>

// Plugin information
new const PLUGIN[] = "WPN GiveWeapon"
new const VERSION[] = "1.41"
new const AUTHOR[] = "DevconeS"

// Menu and output information
new const MENU_TITLE[] = "[WeaponMod] Weapon Giver"
new const PREFIX[] = "[WeaponMod]"

// List of teams which shouldn't be displayed in the menu
new const IGNORE_TEAMS[][] = {"UNASSIGNED", "SPECTATOR", ""}

// Required menu data
new g_MenuPage[33]
new g_CurWeapon[33]
new g_MenuPlayers[33][32]
new g_MenuSpclCount[33]
new g_MenuSpclNames[33][8][32]
new g_coloredMenus

// General
new g_MaxPlayers

// Initializes the plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	wpn_register_addon()
	
	register_concmd("wpn_giveweapon", "cmdGiveWeapon", ADMIN_LEVEL_A, "<weaponid> <name/#userid/authid/@ALL/@TEAM> - gives a player a weapon")
	register_clcmd("wpn_givemenu", "cmdGiveMenu", ADMIN_LEVEL_A, "- opens weapon giver menu")
	
	register_menucmd(register_menuid(MENU_TITLE), 1023, "actionGiveMenu")
	
	g_coloredMenus = colored_menus()
	g_MaxPlayers = get_maxplayers()
}

// Handles give command
public cmdGiveWeapon(id, level, cid)
{
	if(!cmd_access(id,level,cid,1)) return PLUGIN_HANDLED
	
	new wpnname[32]
	new wpncount = wpn_weapon_count()
	
	if(read_argc() < 2)
	{
		// Display the usage of the command
		new hcmd[32], hinfo[128], hflag
		get_concmd(cid, hcmd, 31, hflag, hinfo, 127, level)
		console_print(id,"%L:  %s %s", id, "USAGE", hcmd, hinfo)
		
		// Display all available weapons
		console_print(id, "Available weapons are:")
		for(new i = 0; i < wpncount; i++)
		{
			wpn_get_string(i, wpn_name, wpnname, 31)
			console_print(id, "%d - %s", i, wpnname)
		}
		return PLUGIN_HANDLED
	}
	
	// Read parameter
	new arg1[8], arg2[32]
	read_argv(1, arg1, 7)
	read_argv(2, arg2, 31)
		
	new wpnid = str_to_num(arg1)
	if(wpnid < 0 && wpnid > wpncount)
	{
		// Invalid weapon id was given, print all available weapons
		console_print(id, "%s Invalid weapon id '%d'^nAvailable weapons are:", PREFIX, wpnid)
		for(new i = 0; i < wpncount; i++)
		{
			wpn_get_string(i, wpn_name, wpnname, 31)
			console_print(id, "%d - %s", i, wpnname)
		}
	}
	
	// Contains the list of players who receive a weapon
	new receiverList[33]
	new receiverCount = 0
	new target = 0
	new bool:isSpecial = false
	
	if(arg2[0] == '@')
	{
		// Special command
		isSpecial = true
		replace(arg2, 31, "@", "")	// Remove the first @
		if(equali(arg2, "ALL"))
		{
			// All players
			for(new pl = 1; pl < g_MaxPlayers; pl++)
			{
				if(!is_user_alive(pl)) continue;	// Only collect alive players :)
				
				// Add current player to the list
				receiverList[receiverCount] = pl
				receiverCount++
			}
		} else {
			// Add to team
			new team[32]
			for(new pl = 1; pl < g_MaxPlayers; pl++)
			{
				get_user_team(pl, team, 31)
				if(!equali(team, arg2)) continue;	// Not the team given
				if(!is_user_alive(pl)) continue;	// Only collect alive players :)
				
				// Add current player to the list
				receiverList[receiverCount] = pl
				receiverCount++
			}
		}
	} else {
		// Check target client
		target = cmd_target(id, arg2, 4)
		if(!target)
		{
			console_print(id, "%s invalid target '%s'", PREFIX, arg2)
			return PLUGIN_HANDLED
		}
		
		// Add specified target to the receiver list
		receiverList[0] = target
		receiverCount = 1
	}
	
	// Now cycle through all players inside receiverlist and give them the weapon
	new name[32]
	for(new pl = 0; pl < receiverCount; pl++)
	{
		// Retrieve playerinfo
		target = receiverList[pl]
		get_user_name(target, name, 31)
		
		// Retrieve some information from the weapon
		wpn_get_string(wpnid, wpn_name, wpnname, 31)
		
		if(!isSpecial)
		{
			// Weapon is provided to a single person, so we can display some details
			if(wpn_give_weapon_or_refill(target, wpnid) == 1)
			{
				console_print(id, "%s %s has now a %s", PREFIX, name, wpnname)
				if(id != 0)
					client_print(id, print_chat, "%s %s has now a %s", PREFIX, name, wpnname)
			} else {
				console_print(id, "%s %s got his %s refilled", PREFIX, name, wpnname)
				if(id != 0)
					client_print(id, print_chat, "%s %s got his %s refilled", PREFIX, name, wpnname)
			}
		} else {
			// Just give the weapon
			wpn_give_weapon_or_refill(target, wpnid)
		}
	}
	
	if(isSpecial)
	{
		new msg[32]
		if(equali(arg2, "ALL"))
		{
			// Everyone
			formatex(msg, 31, "EVERYONE")
		} else {
			// Specifiec team
			formatex(msg, 31, "team %s", arg2)
		}
		
		// Print the info
		console_print(id, "%s A %s has been given to %s", PREFIX, wpnname, msg)
		if(id != 0)
			client_print(id, print_chat, "%s A %s has been given to %s", PREFIX, wpnname, msg)
	}
	
	return PLUGIN_HANDLED
}

// Handles command for the weapon giver menu
public cmdGiveMenu(id,level,cid)
{
	if(!cmd_access(id,level,cid,1)) return PLUGIN_HANDLED
	
	// Select first page and display the menu
	g_MenuPage[id] = 0
	showGiveMenu(id)
	
	return PLUGIN_HANDLED
}

// Refreshs special commands and defines them to the proper variable (e.g. @ALL, @CT)
refresh_specials(id)
{
	// @ALL will be always available
	formatex(g_MenuSpclNames[id][0], 31, "ALL")
	g_MenuSpclCount[id] = 1
	
	// Cycle through all players to get the amount of teams
	new curTeam, team[32]
	new bool:teamFound
	for(new i = 1; i < g_MaxPlayers; i++)
	{
		if(!is_user_connected(i)) continue
		
		teamFound = false
		get_user_team(i, team, 31)
		
		// Make sure the team of the current player is unknown
		for(curTeam = 0; curTeam < g_MenuSpclCount[id]; curTeam++)
		{
			if(equal(team, g_MenuSpclNames[id][curTeam]))
			{
				// Team exists, ignore it
				teamFound = true
				break
			}
		}
		
		// Make sure the team is not in the list of ignored teams
		if(!teamFound)
		{
			for(curTeam = 0; curTeam < sizeof(IGNORE_TEAMS); curTeam++)
			{
				if(equal(team, IGNORE_TEAMS[curTeam]))
				{
					// Team has to be ignored
					teamFound = true
					break
				}
			}
		}
		
		if(teamFound) continue
		
		// Add team to the list
		formatex(g_MenuSpclNames[id][g_MenuSpclCount[id]], 31, team)
		g_MenuSpclCount[id]++
	}
}

// Shows the weapon giver menu
showGiveMenu(id)
{
	// Refresh specials :)
	refresh_specials(id)
	
	// Get all players and calculate the total amount of pages
	new menu[512], keys, len, pnum, temp, name[32]
	get_players(g_MenuPlayers[id], pnum)
	new pageCount = ((pnum+g_MenuSpclCount[id])/7) + ((((pnum+g_MenuSpclCount[id])%7) > 0) ? 1 : 0)
	
	// use colored menus if possible
	if(g_coloredMenus)
		len = formatex(menu, 511, "\r%s\R%d/%d^n\w^n", MENU_TITLE, g_MenuPage[id]+1, pageCount)
	else
		len = formatex(menu, 511, "%s %d/%d^n^n", MENU_TITLE, g_MenuPage[id]+1, pageCount)
	
	// Calculate start and end position of the players (7 players per page)
	new start = g_MenuPage[id]*7
	new end = (((start+7) <= pnum+g_MenuSpclCount[id]) ? start+7 : pnum+g_MenuSpclCount[id])
	
	// Cycle through all players and add them to the menu
	temp = 0
	for(new i = start; i < end; i++)
	{
		if(i < g_MenuSpclCount[id])
		{
			// Special element
			if(i+1 == g_MenuSpclCount[id])
			{
				// Last special element to add, we want some space to the players
				formatex(name, 31, "@%s^n", g_MenuSpclNames[id][i])
			} else {
				formatex(name, 31, "@%s", g_MenuSpclNames[id][i])
			}
		} else {
			temp = g_MenuPlayers[id][i-g_MenuSpclCount[id]]
			get_user_name(temp, name, 31)
		}
		
		if(temp < g_MenuSpclCount[id] || is_user_alive(temp))
		{
			// User is alive (or special function), so he can get a weapon
			keys |= (1<<i-start)
			len += formatex(menu[len], 511-len, "%d. %s^n", i+1-start, name)
		} else {
			// User is not alive, so no weapon for him
			if(g_coloredMenus)
				len += formatex(menu[len], 511-len, "\d%d. %s\w^n", i+1-start, name)
			else
				len += formatex(menu[len], 511-len, "#. %s^n", name)
		}
	}
	
	// Add currently selected weapon to menu on position 8
	new weapon[32]
	wpn_get_string(g_CurWeapon[id], wpn_name, weapon, 31)
	keys |= (1<<7)
	len += formatex(menu[len], 511-len, "^n8. %s^n", weapon)
	
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

// Handles pressed key of the weapon giver menu
public actionGiveMenu(id,key)
{
	switch(key)
	{
		case 7:
		{
			// Next weapon
			g_CurWeapon[id]++
			if(g_CurWeapon[id] >= wpn_weapon_count())
			{
				// Weapon limit reached, start from the beginning
				g_CurWeapon[id] = 0
			}
			
			showGiveMenu(id)
		}
		case 8:
		{
			// Next player page
			g_MenuPage[id]++
			showGiveMenu(id)
		}
		case 9: {
			if(g_MenuPage[id] > 0)
			{
				// Previous player page
				g_MenuPage[id]--
				showGiveMenu(id)
			}
		}
		
		default:
		{
			// Get weapon name and the selected index
			new weapon[32]
			new index = g_MenuPage[id]*7+key
			wpn_get_string(g_CurWeapon[id], wpn_name, weapon, 31)
			
			if(index < g_MenuSpclCount[id])
			{
				// Special element selected
				client_cmd(id, "wpn_giveweapon %d @%s", g_CurWeapon[id], g_MenuSpclNames[id][index])
			} else {
				// Player selected
				new target = g_MenuPlayers[id][g_MenuPage[id]*7+key-g_MenuSpclCount[id]]
				new player[32]
				get_user_name(target, player, 31)
				
				if(is_user_alive(target))
				{
					// Player's still alive, give him the weapon
					client_cmd(id,"wpn_giveweapon %d #%d", g_CurWeapon[id], get_user_userid(target))
				} else {
					// Player's dead so he can't get a weapon
					client_print(id, print_chat, "%s %s is dead and can't get a weapon", PREFIX, player)
				}
			}
			
			// We do not want to close the menu ;)
			showGiveMenu(id)
		}
	}
}
