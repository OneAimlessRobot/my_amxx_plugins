/*================================================================================
	
	------------------------
	-*- [ZP] Nightvision -*-
	------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <cs_ham_bots_api>
#include <zp50_core>
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

#define TASK_NIGHTVISION 100
#define ID_NIGHTVISION (taskid - TASK_NIGHTVISION)

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

new g_NightVisionActive

new g_MsgNVGToggle

new cvar_nvision_custom, cvar_nvision_radius
new cvar_nvision_zombie, cvar_nvision_zombie_color_R, cvar_nvision_zombie_color_G, cvar_nvision_zombie_color_B
new cvar_nvision_human, cvar_nvision_human_color_R, cvar_nvision_human_color_G, cvar_nvision_human_color_B
new cvar_nvision_spec, cvar_nvision_spec_color_R, cvar_nvision_spec_color_G, cvar_nvision_spec_color_B
new cvar_nvision_nemesis, cvar_nvision_nemesis_color_R, cvar_nvision_nemesis_color_G, cvar_nvision_nemesis_color_B
new cvar_nvision_dragon, cvar_nvision_dragon_color_R, cvar_nvision_dragon_color_G, cvar_nvision_dragon_color_B
new cvar_nvision_survivor, cvar_nvision_survivor_color_R, cvar_nvision_survivor_color_G, cvar_nvision_survivor_color_B
new cvar_nvision_assassin, cvar_nvision_assassin_color_R, cvar_nvision_assassin_color_G, cvar_nvision_assassin_color_B
new cvar_nvision_crawler, cvar_nvision_crawler_color_R, cvar_nvision_crawler_color_G, cvar_nvision_crawler_color_B
new cvar_nvision_sniper, cvar_nvision_sniper_color_R, cvar_nvision_sniper_color_G, cvar_nvision_sniper_color_B 
new cvar_nvision_knifer, cvar_nvision_knifer_color_R, cvar_nvision_knifer_color_G, cvar_nvision_knifer_color_B 
new cvar_nvision_plasma, cvar_nvision_plasma_color_R, cvar_nvision_plasma_color_G, cvar_nvision_plasma_color_B 

public plugin_init()
{
	register_plugin("[ZP] Nightvision", ZP_VERSION_STRING, "ZP Dev Team")
	
	g_MsgNVGToggle = get_user_msgid("NVGToggle")
	register_message(g_MsgNVGToggle, "message_nvgtoggle")
	
	register_clcmd("nightvision", "clcmd_nightvision_toggle")
	register_event("ResetHUD", "event_reset_hud", "b")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
	RegisterHamBots(Ham_Killed, "fw_PlayerKilled_Post", 1)
	
	cvar_nvision_custom = register_cvar("zp_nvision_custom", "0")
	cvar_nvision_radius = register_cvar("zp_nvision_radius", "80")
	
	cvar_nvision_zombie = register_cvar("zp_nvision_zombie", "2") // 1-give only // 2-give and enable
	cvar_nvision_zombie_color_R = register_cvar("zp_nvision_zombie_color_R", "0")
	cvar_nvision_zombie_color_G = register_cvar("zp_nvision_zombie_color_G", "150")
	cvar_nvision_zombie_color_B = register_cvar("zp_nvision_zombie_color_B", "0")
	cvar_nvision_human = register_cvar("zp_nvision_human", "0") // 1-give only // 2-give and enable
	cvar_nvision_human_color_R = register_cvar("zp_nvision_human_color_R", "0")
	cvar_nvision_human_color_G = register_cvar("zp_nvision_human_color_G", "150")
	cvar_nvision_human_color_B = register_cvar("zp_nvision_human_color_B", "0")
	cvar_nvision_spec = register_cvar("zp_nvision_spec", "2") // 1-give only // 2-give and enable
	cvar_nvision_spec_color_R = register_cvar("zp_nvision_spec_color_R", "0")
	cvar_nvision_spec_color_G = register_cvar("zp_nvision_spec_color_G", "150")
	cvar_nvision_spec_color_B = register_cvar("zp_nvision_spec_color_B", "0")
	
	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
	{
		cvar_nvision_nemesis = register_cvar("zp_nvision_nemesis", "2")
		cvar_nvision_nemesis_color_R = register_cvar("zp_nvision_nemesis_color_R", "150")
		cvar_nvision_nemesis_color_G = register_cvar("zp_nvision_nemesis_color_G", "0")
		cvar_nvision_nemesis_color_B = register_cvar("zp_nvision_nemesis_color_B", "0")
	}

	// Dragon Class loaded?
	if (LibraryExists(LIBRARY_DRAGON, LibType_Library))
	{
		cvar_nvision_dragon = register_cvar("zp_nvision_dragon", "2")
		cvar_nvision_dragon_color_R = register_cvar("zp_nvision_dragon_color_R", "150")
		cvar_nvision_dragon_color_G = register_cvar("zp_nvision_dragon_color_G", "0")
		cvar_nvision_dragon_color_B = register_cvar("zp_nvision_dragon_color_B", "0")
	}

	// Assassin Class loaded?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
	{
		cvar_nvision_assassin = register_cvar("zp_nvision_assassin", "2")
		cvar_nvision_assassin_color_R = register_cvar("zp_nvision_assassin_color_R", "150")
		cvar_nvision_assassin_color_G = register_cvar("zp_nvision_assassin_color_G", "0")
		cvar_nvision_assassin_color_B = register_cvar("zp_nvision_assassin_color_B", "0")
	}

	// Nightcrawler Class loaded?
	if (LibraryExists(LIBRARY_NIGHTCRAWLER, LibType_Library))
	{
		cvar_nvision_crawler = register_cvar("zp_nvision_nightcrawler", "2")
		cvar_nvision_crawler_color_R = register_cvar("zp_nvision_nightcrawler_color_R", "150")
		cvar_nvision_crawler_color_G = register_cvar("zp_nvision_nightcrawler_color_G", "0")
		cvar_nvision_crawler_color_B = register_cvar("zp_nvision_nightcrawler_color_B", "0")
	}
	
	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
	{
		cvar_nvision_survivor = register_cvar("zp_nvision_survivor", "0")
		cvar_nvision_survivor_color_R = register_cvar("zp_nvision_survivor_color_R", "0")
		cvar_nvision_survivor_color_G = register_cvar("zp_nvision_survivor_color_G", "0")
		cvar_nvision_survivor_color_B = register_cvar("zp_nvision_survivor_color_B", "150")
	}

	// Sniper Class loaded?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
	{
		cvar_nvision_sniper = register_cvar("zp_nvision_sniper", "0")
		cvar_nvision_sniper_color_R = register_cvar("zp_nvision_sniper_color_R", "0")
		cvar_nvision_sniper_color_G = register_cvar("zp_nvision_sniper_color_G", "0")
		cvar_nvision_sniper_color_B = register_cvar("zp_nvision_sniper_color_B", "150")
	}

                // Knifer Class loaded?
	if (LibraryExists(LIBRARY_KNIFER, LibType_Library))
	{
		cvar_nvision_knifer = register_cvar("zp_nvision_knifer", "0")
		cvar_nvision_knifer_color_R = register_cvar("zp_nvision_knifer_color_R", "0")
		cvar_nvision_knifer_color_G = register_cvar("zp_nvision_knifer_color_G", "0")
		cvar_nvision_knifer_color_B = register_cvar("zp_nvision_knifer_color_B", "150")
	}

                // Plasma Class loaded?
	if (LibraryExists(LIBRARY_PLASMA, LibType_Library))
	{
		cvar_nvision_plasma = register_cvar("zp_nvision_plasma", "0")
		cvar_nvision_plasma_color_R = register_cvar("zp_nvision_plasma_color_R", "0")
		cvar_nvision_plasma_color_G = register_cvar("zp_nvision_plasma_color_G", "0")
		cvar_nvision_plasma_color_B = register_cvar("zp_nvision_plasma_color_B", "150")
	}
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
	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(id))
	{
		if (get_pcvar_num(cvar_nvision_nemesis))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_nemesis) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}

	// Dragon Class loaded?
	else if (LibraryExists(LIBRARY_DRAGON, LibType_Library) && zp_class_dragon_get(id))
	{
		if (get_pcvar_num(cvar_nvision_dragon))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_dragon) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
	// Assassin Class loaded?
	else if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(id))
	{
		if (get_pcvar_num(cvar_nvision_assassin))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_assassin) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
	// Nightcrawler Class loaded?
	else if (LibraryExists(LIBRARY_NIGHTCRAWLER, LibType_Library) && zp_class_nightcrawler_get(id))
	{
		if (get_pcvar_num(cvar_nvision_crawler))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_crawler) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
	else
	{
		if (get_pcvar_num(cvar_nvision_zombie))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_zombie) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
	
	// Always give nightvision to PODBots
	if (is_user_bot(id) && !cs_get_user_nvg(id))
		cs_set_user_nvg(id, 1)
}

public zp_fw_core_cure_post(id, attacker)
{
	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id))
	{
		if (get_pcvar_num(cvar_nvision_survivor))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_survivor) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
	// Sniper Class loaded?
	else if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id))
	{
		if (get_pcvar_num(cvar_nvision_sniper))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_sniper) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
                // Knifer Class loaded?
	else if (LibraryExists(LIBRARY_KNIFER, LibType_Library) && zp_class_knifer_get(id))
	{
		if (get_pcvar_num(cvar_nvision_knifer))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_knifer) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
                // Plasma Class loaded?
	else if (LibraryExists(LIBRARY_PLASMA, LibType_Library) && zp_class_plasma_get(id))
	{
		if (get_pcvar_num(cvar_nvision_plasma))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_plasma) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
	else
	{
		if (get_pcvar_num(cvar_nvision_human))
		{
			if (!cs_get_user_nvg(id)) cs_set_user_nvg(id, 1)
			
			if (get_pcvar_num(cvar_nvision_human) == 2)
			{
				if (!flag_get(g_NightVisionActive, id))
					clcmd_nightvision_toggle(id)
			}
			else if (flag_get(g_NightVisionActive, id))
				clcmd_nightvision_toggle(id)
		}
		else
		{
			cs_set_user_nvg(id, 0)
			
			if (flag_get(g_NightVisionActive, id))
				DisableNightVision(id)
		}
	}
	
	// Always give nightvision to PODBots
	if (is_user_bot(id) && !cs_get_user_nvg(id))
		cs_set_user_nvg(id, 1)
}

public clcmd_nightvision_toggle(id)
{
	if (is_user_alive(id))
	{
		// Player owns nightvision?
		if (!cs_get_user_nvg(id))
			return PLUGIN_CONTINUE;
	}
	else
	{
		// Spectator nightvision disabled?
		if (!get_pcvar_num(cvar_nvision_spec))
			return PLUGIN_CONTINUE;
	}
	
	if (flag_get(g_NightVisionActive, id))
		DisableNightVision(id)
	else
		EnableNightVision(id)
	
	return PLUGIN_HANDLED;
}

// ResetHUD Removes CS Nightvision (bugfix)
public event_reset_hud(id)
{
	if (!get_pcvar_num(cvar_nvision_custom) && flag_get(g_NightVisionActive, id))
		cs_set_user_nvg_active(id, 1)
}

// Ham Player Killed Post Forward
public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
	// Enable spectators nightvision?
	spectator_nightvision(victim)
}

public client_putinserver(id)
{
	// Enable spectators nightvision?
	set_task(0.1, "spectator_nightvision", id)
}

public spectator_nightvision(id)
{
	// Player disconnected
	if (!is_user_connected(id))
		return;
	
	// Not a spectator
	if (is_user_alive(id))
		return;
	
	if (get_pcvar_num(cvar_nvision_spec) == 2)
	{
		if (!flag_get(g_NightVisionActive, id))
			clcmd_nightvision_toggle(id)
	}
	else if (flag_get(g_NightVisionActive, id))
		DisableNightVision(id)
}

public client_disconnect(id)
{
	// Reset nightvision flags
	flag_unset(g_NightVisionActive, id)
	remove_task(id+TASK_NIGHTVISION)
}

// Prevent spectators' nightvision from being turned off when switching targets, etc.
public message_nvgtoggle(msg_id, msg_dest, msg_entity)
{
	return PLUGIN_HANDLED;
}

// Custom Night Vision Task
public custom_nightvision_task(taskid)
{
	// Get player's origin
	static origin[3]
	get_user_origin(ID_NIGHTVISION, origin)
	
	// Nightvision message
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NIGHTVISION)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(get_pcvar_num(cvar_nvision_radius)) // radius
	
	// Spectator
	if (!is_user_alive(ID_NIGHTVISION))
	{
		write_byte(get_pcvar_num(cvar_nvision_spec_color_R)) // r
		write_byte(get_pcvar_num(cvar_nvision_spec_color_G)) // g
		write_byte(get_pcvar_num(cvar_nvision_spec_color_B)) // b
	}
	// Zombie
	else if (zp_core_is_zombie(ID_NIGHTVISION))
	{
		// Nemesis Class loaded?
		if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(cvar_nvision_nemesis_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_nemesis_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_nemesis_color_B)) // b
		}
		// Dragon Class loaded?
		else if (LibraryExists(LIBRARY_DRAGON, LibType_Library) && zp_class_dragon_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(cvar_nvision_dragon_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_dragon_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_dragon_color_B)) // b
		}
                                // Assassin Class loaded?
		else if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(cvar_nvision_assassin_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_assassin_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_assassin_color_B)) // b
		}
		 // Nightcrawler Class loaded?
		else if (LibraryExists(LIBRARY_NIGHTCRAWLER, LibType_Library) && zp_class_nightcrawler_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(cvar_nvision_crawler_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_crawler_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_crawler_color_B)) // b
		}
		else
		{
			write_byte(get_pcvar_num(cvar_nvision_zombie_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_zombie_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_zombie_color_B)) // b
		}
	}
	// Human
	else
	{
		// Survivor Class loaded?
		if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(cvar_nvision_survivor_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_survivor_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_survivor_color_B)) // b
		}
                                // Sniper Class loaded?
		else if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(cvar_nvision_sniper_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_sniper_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_sniper_color_B)) // b
		}
                                 // Knifer Class loaded?
		else if (LibraryExists(LIBRARY_KNIFER, LibType_Library) && zp_class_knifer_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(cvar_nvision_knifer_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_knifer_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_knifer_color_B)) // b
		}
                                 // Plasma Class loaded?
		else if (LibraryExists(LIBRARY_PLASMA, LibType_Library) && zp_class_plasma_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(cvar_nvision_plasma_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_plasma_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_plasma_color_B)) // b
		}
		else
		{
			write_byte(get_pcvar_num(cvar_nvision_human_color_R)) // r
			write_byte(get_pcvar_num(cvar_nvision_human_color_G)) // g
			write_byte(get_pcvar_num(cvar_nvision_human_color_B)) // b
		}
	}
	
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

EnableNightVision(id)
{
	flag_set(g_NightVisionActive, id)
	
	if (!get_pcvar_num(cvar_nvision_custom))
		cs_set_user_nvg_active(id, 1)
	else
		set_task(0.1, "custom_nightvision_task", id+TASK_NIGHTVISION, _, _, "b")
}

DisableNightVision(id)
{
	flag_unset(g_NightVisionActive, id)
	
	if (!get_pcvar_num(cvar_nvision_custom))
		cs_set_user_nvg_active(id, 0)
	else
		remove_task(id+TASK_NIGHTVISION)
}

stock cs_set_user_nvg_active(id, active)
{
	// Toggle NVG message
	message_begin(MSG_ONE, g_MsgNVGToggle, _, id)
	write_byte(active) // toggle
	message_end()
}
