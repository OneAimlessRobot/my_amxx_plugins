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

// Plugin informations
new const PLUGIN[] = "WPN Buysystem"
new const VERSION[] = "0.8"
new const AUTHOR[] = "DevconeS"
new const PREFIX[] = "[WeaponMod]"

// List of supported mods
#define MAX_SUPPORTED_MODS	3
new const SUPPORTED_MODS[MAX_SUPPORTED_MODS][] = {"cstrike", "czero", "ts"}

// CVAR Pointers
new g_BuyMode
new g_Advertise
new g_BuyWaitTime
new g_Enabled

// User Informations
new g_InBuyzone[33]
new g_MenuPage[33]

// Others
new g_MenuTitle[64]
new g_ColoredMenus
new Float:g_MustWaitUntil

// Restricted teams
#define MAX_RES_TEAMS	4
#define MAX_TEAM_LENGTH	16
new g_RestrictedTeamsList[MAX_RES_TEAMS][MAX_TEAM_LENGTH]
new g_RestrictedTeamsCount = 0

// Register the plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Before doing anything, we wanna make sure we're running on a supported mod
	wpn_set_supported_mods(SUPPORTED_MODS, MAX_SUPPORTED_MODS, "addon")
	
	wpn_register_addon()
	
	// CVARs
	g_BuyMode = register_cvar("wpn_buymode", "2")
	g_Advertise = register_cvar("wpn_advertise", "1")
	g_BuyWaitTime = register_cvar("wpn_buy_wait_time", "0")
	g_Enabled = get_cvar_pointer("wpn_enabled")
	
	// Commands
	register_clcmd("wpnbuy", "cmdBuy", 0, "<wpnid> - buys a weapon")
	register_clcmd("wpnmenu", "cmdMenu", 0, "- displays weapon menu")
	register_clcmd("say /wpnmenu", "cmdMenu", 0, "- displays weapon menu")
	register_srvcmd("wpn_bs_restrict_team", "cmdRestrictTeam", _, "<teamname> - Restricts the buying of weapons to the given team")
	
	// Events
	new mod[32]
	get_modname(mod, 31)
	if(equal(mod, "cstrike") || equal(mod, "czero"))
	{
		register_event("StatusIcon", "eventStatusIcon", "be")
	}
	register_event("RoundTime", "eventRoundTime", "bc")
	
	// Menu
	g_ColoredMenus = colored_menus()
	if(g_ColoredMenus)
		formatex(g_MenuTitle, 63, "\y%s Buymenu", PREFIX)
	else
		formatex(g_MenuTitle, 63, "%s Buymenu", PREFIX)
	register_menucmd(register_menuid(g_MenuTitle), 1023, "actionBuyMenu")
}

// Manages message display on round begin
public eventRoundTime()
{
	if(read_data(1) == get_cvar_num("mp_roundtime")*60)
	{
		// New round has started, if the advertisment option is enabled, print the text
		if(get_pcvar_num(g_Advertise))
		{
			client_print(0, print_chat, "%s Type wpnmenu in console to open the WeaponMod menu or bind <key> wpnmenu", PREFIX)
			g_MustWaitUntil = get_gametime()+get_pcvar_float(g_BuyWaitTime)
		}
	}
}

// Event StatusIcon (to check if the user is in the buyzone)
public eventStatusIcon(id)
{
	new icon[32]
	read_data(2,icon,31)
	if(equal(icon, "buyzone"))
	{
		if(read_data(1))
			g_InBuyzone[id] = true
		else
			g_InBuyzone[id] = false
	}
}

// Checks if the given player is able to buy a weapon
canBuyWeapon(id)
{
	new mode = get_pcvar_num(g_BuyMode)
	if(mode == 0)
	{
		// Buying disabled
		client_print(id, print_console, "%s Buying of weapons has been disabled", PREFIX)
		client_print(id, print_chat, "%s Buying of weapons has been disabled", PREFIX)
		return false
	}
	
	if(!g_InBuyzone[id] && mode == 2)
	{
		// Player not in buyzone but buyzone is required
		client_print(id, print_console, "%s You aren't in buyzone", PREFIX)
		client_print(id, print_chat, "%s You aren't in buyzone", PREFIX)
		return false
	}
	
	if(is_player_team_restricted(id))
	{
		// Player's team can't buy weapons
		client_print(id, print_console, "%s Your team has been restricted from buying weapons", PREFIX)
		client_print(id, print_chat, "%s Your team has been restricted from buying weapons", PREFIX)
		return false
	}
	
	new Float:waitSecs = g_MustWaitUntil-get_gametime()
	if(waitSecs > 0.0)
	{
		// Player must still wait until he can buy weapons
		client_print(id, print_console, "%s You must still wait %.2f sec more until you can buy weapons", PREFIX, waitSecs)
		client_print(id, print_chat, "%s You must still wait %.2f sec more until you can buy weapons", PREFIX, waitSecs)
		return false
	}
	
	return true
}

// Buy command
public cmdBuy(id)
{
	if(!get_pcvar_num(g_Enabled)) return PLUGIN_HANDLED
	if(!canBuyWeapon(id)) return PLUGIN_HANDLED
	
	new wpnCount = wpn_weapon_count()
	if(wpnCount > 0)
	{
		if(read_argc() < 2)
		{
			// No weapon given, list all available weapon and buy command
			client_print(id, print_console, "%s Available Weapons are:^nTo buy type: wpnbuy <weaponid>", PREFIX)
			new weapon[32]
			for(new i = 0; i < wpnCount; i++)
			{
				// Only display information, if the weapon is enabled
				if(!is_plugin_enabled(wpn_get_integer(i, wpn_pluginid))) continue
				
				wpn_get_string(i, wpn_name, weapon, 31)
				client_print(id, print_console, "%d - %s - $%d", i, weapon, wpn_get_integer(i,wpn_cost))
			}
		} else {
			new wpn[64], wpnid
			read_argv(1, wpn, 63)
			wpnid = str_to_num(wpn)
			
			if(wpnid > -1 && wpnid < wpnCount)
			{
				if(!is_plugin_enabled(wpn_get_integer(wpnid, wpn_pluginid)))
				{
					// Player tryed to buy a disabled weapon
					client_print(id, print_console, "%s This weapon is currently disabled", PREFIX)
					return PLUGIN_HANDLED
				}
				
				new money = wpn_gi_get_offset_int(id, offset_money)
				new cost = wpn_get_integer(wpnid, wpn_cost)
				
				new weapon[32]
				wpn_get_string(wpnid, wpn_name, weapon, 31)
				
				if(money < cost)
				{
					// User has less money than required
					client_print(id, print_console, "%s You haven't got enough money for a '%s' ($%d)", PREFIX, weapon, cost)
					client_print(id, print_chat, "%s You haven't got enough money for a '%s' ($%d)", PREFIX, weapon, cost)
					return PLUGIN_HANDLED
				}
				
				// Take the money :)
				wpn_gi_set_offset_int(id, offset_money, money-cost)
				
				// Give him the weapon or refill it
				if(wpn_give_weapon_or_refill(id, wpnid) == 1)
				{
					// New weapon was given
					client_print(id, print_console, "%s You've got now a '%s'", PREFIX, weapon)
					client_print(id, print_chat, "%s You've got now a '%s'", PREFIX, weapon)
				} else {
					// Refilled
					client_print(id, print_console, "%s Your '%s' has now full ammo", PREFIX, weapon)
					client_print(id, print_chat, "%s Your '%s' has now full ammo", PREFIX, weapon)
				}
			} else {
				// Player tryed to buy an unknown weapon
				client_print(id, print_console, "%s Invalid Weapon ID '%s'", PREFIX, wpnid)
			}
		}
	} else {
		// No weapons are registered to WeaponMod
		client_print(id, print_console, "%s No weapons available", PREFIX)
	}
	
	return PLUGIN_HANDLED
}

// Checks if the given plugin is enabled
is_plugin_enabled(id)
{
	new temp[2],status[16]
	get_plugin(id, temp, 1, temp, 1, temp, 1, temp, 1, status, 15)
	if(status[0] == 's' || status[0] == 'p')
	{
		return false
	}
	return true
}

// Checks if player's team is restricted
is_player_team_restricted(id)
{
	new team[MAX_TEAM_LENGTH]
	get_user_team(id, team, MAX_TEAM_LENGTH-1)
	return is_team_restricted(team)
}

// Checks if the given team is restricted to buy WeaponMod weapons
is_team_restricted(team[])
{
	for(new i = 0; i < g_RestrictedTeamsCount; i++)
	{
		if(equal(team, g_RestrictedTeamsList[i]))
		{
			return true
		}
	}
	return false
}

// Menu command
public cmdMenu(id)
{
	if(!get_pcvar_num(g_Enabled)) return PLUGIN_HANDLED
	if(!canBuyWeapon(id)) return PLUGIN_HANDLED
	
	if(wpn_weapon_count() > 0)
	{
		// Display menu at page 1
		g_MenuPage[id] = 0
		showBuyMenu(id)
	} else {
		// No weapons available
		client_print(id, print_chat, "%s No weapons available", PREFIX)
	}
	
	return PLUGIN_HANDLED
}

// Restrict command
public cmdRestrictTeam()
{
	if(read_argc() < 2)
	{
		server_print("Usage:  wpn_bs_restrict_team <teamname> - Restricts the buying of weapons to the given team")
		server_print("Restricted Teams are:")
		for(new i = 0; i < g_RestrictedTeamsCount; i++)
		{
			server_print("- %s", g_RestrictedTeamsList[i])
		}
		return PLUGIN_HANDLED
	}
	
	// Add team to the restriction list
	read_argv(1, g_RestrictedTeamsList[g_RestrictedTeamsCount], MAX_TEAM_LENGTH-1)
	g_RestrictedTeamsCount++
	
	return PLUGIN_HANDLED
}

// Displays WeaponMod buymenu
public showBuyMenu(id)
{
	// Init variables, get weapon count and calculate amount of pages
	new menu[512], keys
	new wpnCount = wpn_weapon_count()
	new pageCount = (wpnCount/8) + (((wpnCount%8) > 0) ? 1 : 0)
	
	// Add menu header
	new len
	if(g_ColoredMenus)
		len = formatex(menu, 511, "%s\R%d/%d^n\w^n", g_MenuTitle, g_MenuPage[id]+1, pageCount)
	else
		len = formatex(menu, 511, "%s - Page %d/%d^n^n", g_MenuTitle, g_MenuPage[id]+1, pageCount)
	
	// Calculate weapon start index and end index of all available weapons
	new start = g_MenuPage[id]*8
	new end = (((start+8) <= wpnCount) ? start+8 : wpnCount)
	new money = wpn_gi_get_offset_int(id, offset_money)
	new cost, weapon[32]
	
	// Now cycle through all weapons
	for(new i = start; i < end; i++)
	{
		cost = wpn_get_integer(i, wpn_cost)
		wpn_get_string(i, wpn_name, weapon, 31)
		if(cost <= money)
		{
			if(is_plugin_enabled(wpn_get_integer(i, wpn_pluginid)))
			{
				// Weapon is enabled, add it to the menu and allow pressing the specifiec number
				keys |= (1<<i-start)
				if(g_ColoredMenus)
					len += formatex(menu[len], 511-len, "%d. %s \R\y$%d\w^n", i+1-start, weapon, cost)
				else
					len += formatex(menu[len], 511-len, "%d. %s - $%d^n", i+1-start, weapon, cost)
			} else {
				// The current weapon is disabled
				if(g_ColoredMenus)
					len += formatex(menu[len], 511-len, "\d%d. %s \R\rDISABLED\w^n", i+1-start, weapon, cost)
				else
					len += formatex(menu[len], 511-len, "#. %s - DISABLED^n", weapon, cost)
			}
		} else {
			// Player does not have enough money
			if(g_ColoredMenus)
				len += formatex(menu[len], 511-len, "\d%d. %s \R\y$%d\w^n", i+1-start, weapon, cost)
			else
				len += formatex(menu[len], 511-len, "#. %s - $%d^n", weapon, cost)
		}
	}
	
	if(end < wpnCount)
	{
		// There are more weapons available and so more pages, add next button
		keys |= (1<<8)
		len += formatex(menu[len], 511-len, "^n9. Next")
	}
	
	// If we're on the first page, we add the exit button, otherwise the back
	keys |= (1<<9)
	if(start <= 0)
		len += formatex(menu[len], 511-len, "^n0. Exit")
	else
		len += formatex(menu[len], 511-len, "^n0. Back")
		
	// Finally show the generated menu
	show_menu(id, keys, menu)
	return PLUGIN_CONTINUE
}

// Handles WeaponMod buymenu
public actionBuyMenu(id,key)
{
	switch(key)
	{
		case 8:
		{
			// Next page
			g_MenuPage[id]++
			showBuyMenu(id)
		}
		case 9:
		{
			if(g_MenuPage[id] > 0)
			{
				// Previous page
				g_MenuPage[id]--
				showBuyMenu(id)
			}
		}
		default:
		{
			// Buy weapon
			client_cmd(id, "wpnbuy %d", g_MenuPage[id]*8+key)
		}
	}
}
