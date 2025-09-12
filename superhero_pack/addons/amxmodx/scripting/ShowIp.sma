/* Copyright (c) 2008 Kyle Swecker

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details. */

#include <amxmodx>
#include <amxmisc>
#include <geoip>

new iPlayers[32], iPlayerNum
new szName[32], szIP[20], szID[20], szCountry[20]
new szConfigsDir[96], szShowIPPath[128], szIPResult[20], szShowSIDPath[128], szSIDResult[20], iResultLen
new szAllowedIP[20], szAllowedSID[20], szAllowedPath[128], szAllowedResult[20], iAllowedResultLen
new g_Enabled, g_Mode, g_Method, g_AdminOnly, g_Allowed, g_Log

public plugin_init()
{
	register_plugin("ShowIP", "1.08", "Spunky")

	register_concmd("amx_showall", "cmd_showall", ADMIN_BAN, "- <name>")
	register_concmd("amx_showall_all", "cmd_showall_all", ADMIN_BAN, "- Gets all of every player's information.")
	register_concmd("amx_showip", "cmd_showip", ADMIN_BAN, "- <name>")
	register_concmd("amx_showip_all", "cmd_showip_all", ADMIN_BAN, "- Gets every player's IP address.")
	register_concmd("amx_showsid", "cmd_showsid", ADMIN_ALL, "- <name>")
	register_concmd("amx_showsid_all", "cmd_showsid_all", ADMIN_KICK, "- Gets every player's Steam ID.")
	register_concmd("amx_showcountry", "cmd_showcountry", ADMIN_ALL, "- <name>")
	register_concmd("amx_showcountry_all", "cmd_showcountry_all", ADMIN_KICK, "- Gets every player's country.")

	g_Enabled = register_cvar("amx_showips", "1")
	g_Mode = register_cvar("amx_showip_mode", "1")
	g_Method = register_cvar("amx_showip_method", "1")
	g_AdminOnly = register_cvar("amx_showip_admin", "0")
	g_Allowed = register_cvar("amx_showip_allowed", "0")
	g_Log = register_cvar("amx_showip_log", "1")
}

public client_connect(id)
{
	if (get_pcvar_num(g_Enabled) == 0)
		return PLUGIN_HANDLED

	if (get_pcvar_num(g_Enabled) > 1)
	{
		set_pcvar_num(g_Enabled, 1)

		console_print(0, "[ShowIP] amx_showips was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_Mode) > 3)
	{
		set_pcvar_num(g_Mode, 1)

		console_print(0, "[ShowIP] amx_showip_mode was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_Method) > 2)
	{
		set_pcvar_num(g_Method, 1)

		console_print(0, "[ShowIP] amx_showip_method was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_AdminOnly) > 1)
	{
		set_pcvar_num(g_AdminOnly, 0)

		console_print(0, "[ShowIP] amx_showip_admin was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_Allowed) > 1)
	{
		set_pcvar_num(g_Allowed, 1)

		console_print(0, "[ShowIP] amx_showip_allowed was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_Log) > 1)
	{
		set_pcvar_num(g_Log, 1)

		console_print(0, "[ShowIP] amx_showip_log was set higher than max value and has been reset.")
	}

	new ShowIP_Mode = get_pcvar_num(g_Mode)
	new ShowIP_Method = get_pcvar_num(g_Method)
	new ShowIP_AdminOnly = get_pcvar_num(g_AdminOnly)
	new ShowIP_Allowed = get_pcvar_num(g_Allowed)
	new ShowIP_Log = get_pcvar_num(g_Log)

	get_user_name(id, szName, 31)
	get_user_authid(id, szID, 19)
	get_user_ip(id, szIP, 19, 1)
	geoip_country_ex(szIP, szCountry, 19)

	get_configsdir(szConfigsDir, 95)
	format(szShowIPPath, 127, "%s/showip/ips.cfg", szConfigsDir)
	format(szShowSIDPath, 127, "%s/showip/sids.cfg", szConfigsDir)
	format(szAllowedPath, 127, "%s/showip/allowed.cfg", szConfigsDir)

	get_players(iPlayers, iPlayerNum, "ch")

	if (ShowIP_Allowed == 1)
	{
		if (ShowIP_Log == 1)
		{
			if (ShowIP_Mode == 1)
				log_amx("^nShowIP: %s (connecting)^n---^nIP: %s^nSteam ID: %s^nCountry: %s^n", szName, szIP, szID, szCountry)

			if (ShowIP_Mode == 2)
				log_amx("^nShowIP: %s (connecting)^n---^nIP: %s^nCountry: %s^n", szName, szIP, szCountry)

			if (ShowIP_Mode == 3)
				log_amx("^nShowIP: %s (connecting)^n---^nSteam ID: %s^n", szName, szID)
		}

		for (new i = 0; i < file_size(szAllowedPath, 1); i++)
		{
			read_file(szAllowedPath, i, szAllowedResult, 19, iAllowedResultLen)

			for (new j = 0; j < iPlayerNum; j++)
			{
				get_user_authid(iPlayers[j], szAllowedSID, 19)
				get_user_ip(iPlayers[j], szAllowedIP, 19, 1)

				if (equali(szAllowedIP, szAllowedResult) || equali(szAllowedSID, szAllowedResult))
				{
					if (ShowIP_Method == 1)
					{
						for (new k = 0; k < file_size(szShowIPPath, 1); k++)
						{
							read_file(szShowIPPath, k, szIPResult, 19, iResultLen)

							if (ShowIP_AdminOnly == 1)
							{
								if (access(iPlayers[j], ADMIN_BAN))
								{
									if (equali(szIP, szIPResult))
										client_print(iPlayers[j], print_chat, "%s connected.", szName)
								}
							}
							else
							{
								if (equali(szIP, szIPResult))
									client_print(iPlayers[j], print_chat, "%s connected.", szName)
							}
						}
					}

					if (ShowIP_Method == 2)
					{
						for (new k = 0; k < file_size(szShowSIDPath, 1); k++)
						{
							read_file(szShowSIDPath, k, szSIDResult, 19, iResultLen)

							if (ShowIP_AdminOnly == 1)
							{
								if (access(iPlayers[j], ADMIN_BAN))
								{
									if (equali(szID, szSIDResult))
										client_print(iPlayers[j], print_chat, "%s connected.", szName)
								}
							}
							else
							{
								if (equali(szID, szSIDResult))
									client_print(iPlayers[j], print_chat, "%s connected.", szName)
							}
						}
					}

					if (ShowIP_Mode == 1 || ShowIP_Mode == 2)
						client_print(iPlayers[j], print_chat, "%s connected from %s. (%s)", szName, szCountry, szIP)

					if (ShowIP_Mode == 3)
						client_print(iPlayers[j], print_chat, "%s connected from %s. (%s)", szName, szCountry, szID)
				}
			}
		}

		return PLUGIN_HANDLED
	}

	if (ShowIP_Method == 1)
	{
		for (new i = 0; i < file_size(szShowIPPath, 1); i++)
		{
			read_file(szShowIPPath, i, szIPResult, 19, iResultLen)

			if (equali(szIP, szIPResult))
			{
				if (ShowIP_Mode == 1)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (connecting)^n---^nIP: %s^nSteam ID: %s^nCountry: %s^n", szName, szIP, szID, szCountry)

					client_print(0, print_chat, "%s connected.", szName)

					return PLUGIN_HANDLED
				}

				if (ShowIP_Mode == 2)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (connecting)^n---^nIP: %s^nCountry: %s^n", szName, szIP, szCountry)

					client_print(0, print_chat, "%s connected.", szName)

					return PLUGIN_HANDLED
				}

				if (ShowIP_Mode == 3)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (connecting)^n---^nSteam ID: %s^n", szName, szID)

					client_print(0, print_chat, "%s connected.", szName)

					return PLUGIN_HANDLED
				}
			}
		}
	}

	if (ShowIP_Method == 2)
	{
		for (new i = 0; i < file_size(szShowSIDPath, 1); i++)
		{
			read_file(szShowSIDPath, i, szSIDResult, 19, iResultLen)

			if (equali(szID, szSIDResult))
			{
				if (ShowIP_Mode == 1)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (connecting)^n---^nIP: %s^nSteam ID: %s^nCountry: %s^n", szName, szIP, szID, szCountry)

					client_print(0, print_chat, "%s connected.", szName)

					return PLUGIN_HANDLED
				}

				if (ShowIP_Mode == 2)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (connecting)^n---^nIP: %s^nCountry: %s^n", szName, szIP, szCountry)

					client_print(0, print_chat, "%s connected.", szName)

					return PLUGIN_HANDLED
				}

				if (ShowIP_Mode == 3)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (connecting)^n---^nSteam ID: %s^n", szName, szID)

					client_print(0, print_chat, "%s connected.", szName)

					return PLUGIN_HANDLED
				}
			}
		}
	}

	if (ShowIP_Mode == 1)
	{
		if (ShowIP_Log == 1)
			log_amx("^nShowIP: %s (connecting)^n---^nIP: %s^nSteam ID: %s^nCountry: %s^n", szName, szIP, szID, szCountry)

		get_players(iPlayers, iPlayerNum, "ch")

		if (ShowIP_AdminOnly == 1)
		{
			for (new i = 0; i < iPlayerNum; i++)
			{
				if (access(iPlayers[i], ADMIN_BAN))
					client_print(iPlayers[i], print_chat, "%s connected from %s. (%s)", szName, szCountry, szIP)
			}
		}
		else
			client_print(0, print_chat, "%s connected from %s. (%s)", szName, szCountry, szIP)

		return PLUGIN_HANDLED
	}

	if (ShowIP_Mode == 2)
	{
		if (ShowIP_Log == 1)
			log_amx("^nShowIP: %s (connecting)^n---^nIP: %s^nCountry: %s^n", szName, szIP, szCountry)

		get_players(iPlayers, iPlayerNum, "ch")

		if (ShowIP_AdminOnly == 1)
		{
			for (new i = 0; i < iPlayerNum; i++)
			{
				if (access(iPlayers[i], ADMIN_BAN))
					client_print(iPlayers[i], print_chat, "%s connected from %s. (%s)", szName, szCountry, szIP)
			}
		}
		else
			client_print(0, print_chat, "%s connected from %s. (%s)", szName, szCountry, szIP)

		return PLUGIN_HANDLED
	}

	if (ShowIP_Mode == 3)
	{
		if (ShowIP_Log == 1)
			log_amx("^nShowIP: %s (connecting)^n---^nSteam ID: %s^n", szName, szID)

		client_print(0, print_chat, "%s connected from %s. (%s)", szName, szCountry, szID)

		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public client_disconnected(id)
{
	if (get_pcvar_num(g_Enabled) == 0)
		return PLUGIN_HANDLED

	if (get_pcvar_num(g_Enabled) > 1)
	{
		set_pcvar_num(g_Enabled, 1)

		console_print(0, "[ShowIP] amx_showips was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_Mode) > 3)
	{
		set_pcvar_num(g_Mode, 1)

		console_print(0, "[ShowIP] amx_showip_mode was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_Method) > 2)
	{
		set_pcvar_num(g_Method, 1)

		console_print(0, "[ShowIP] amx_showip_method was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_AdminOnly) > 1)
	{
		set_pcvar_num(g_AdminOnly, 0)

		console_print(0, "[ShowIP] amx_showip_admin was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_Allowed) > 1)
	{
		set_pcvar_num(g_Allowed, 1)

		console_print(0, "[ShowIP] amx_showip_allowed was set higher than max value and has been reset.")
	}

	if (get_pcvar_num(g_Log) > 1)
	{
		set_pcvar_num(g_Log, 1)

		console_print(0, "[ShowIP] amx_showip_log was set higher than max value and has been reset.")
	}

	new ShowIP_Mode = get_pcvar_num(g_Mode)
	new ShowIP_Method = get_pcvar_num(g_Method)
	new ShowIP_AdminOnly = get_pcvar_num(g_AdminOnly)
	new ShowIP_Allowed = get_pcvar_num(g_Allowed)
	new ShowIP_Log = get_pcvar_num(g_Log)

	get_user_name(id, szName, 31)
	get_user_authid(id, szID, 19)
	get_user_ip(id, szIP, 19, 1)

	get_configsdir(szConfigsDir, 95)
	format(szShowIPPath, 127, "%s/showip/ips.cfg", szConfigsDir)
	format(szShowSIDPath, 127, "%s/showip/sids.cfg", szConfigsDir)
	format(szAllowedPath, 127, "%s/showip/allowed.cfg", szConfigsDir)

	get_players(iPlayers, iPlayerNum, "ch")

	if (ShowIP_Allowed == 1)
	{
		if (ShowIP_Log == 1)
		{
			if (ShowIP_Mode == 1)
				log_amx("^nShowIP: %s (disconnecting)^n---^nIP: %s^nSteam ID: %s^n", szName, szIP, szID)

			if (ShowIP_Mode == 2)
				log_amx("^nShowIP: %s (disconnecting)^n---^nIP: %s^n", szName, szIP)

			if (ShowIP_Mode == 3)
				log_amx("^nShowIP: %s (disconnecting)^n---^nSteam ID: %s^n", szName, szID)
		}

		for (new i = 0; i < file_size(szAllowedPath, 1); i++)
		{
			read_file(szAllowedPath, i, szAllowedResult, 19, iAllowedResultLen)

			for (new j = 0; j < iPlayerNum; j++)
			{
				get_user_authid(iPlayers[j], szAllowedSID, 19)
				get_user_ip(iPlayers[j], szAllowedIP, 19, 1)

				if (equali(szAllowedIP, szAllowedResult) || equali(szAllowedSID, szAllowedResult))
				{
					if (ShowIP_Method == 1)
					{
						for (new k = 0; k < file_size(szShowIPPath, 1); k++)
						{
							read_file(szShowIPPath, k, szIPResult, 19, iResultLen)

							if (ShowIP_AdminOnly == 1)
							{
								if (access(iPlayers[j], ADMIN_BAN))
								{
									if (equali(szIP, szIPResult))
										client_print(iPlayers[j], print_chat, "%s disconnected.", szName)
								}
							}
							else
							{
								if (equali(szIP, szIPResult))
									client_print(iPlayers[j], print_chat, "%s disconnected.", szName)
							}
						}
					}

					if (ShowIP_Method == 2)
					{
						for (new k = 0; k < file_size(szShowSIDPath, 1); k++)
						{
							read_file(szShowSIDPath, k, szSIDResult, 19, iResultLen)

							if (ShowIP_AdminOnly == 1)
							{
								if (access(iPlayers[j], ADMIN_BAN))
								{
									if (equali(szID, szSIDResult))
										client_print(iPlayers[j], print_chat, "%s disconnected.", szName)
								}
							}
							else
							{
								if (equali(szID, szSIDResult))
									client_print(iPlayers[j], print_chat, "%s disconnected.", szName)
							}
						}
					}

					if (ShowIP_Mode == 1 || ShowIP_Mode == 2)
						client_print(iPlayers[j], print_chat, "%s disconnected. (%s)", szName, szIP)

					if (ShowIP_Mode == 3)
						client_print(iPlayers[j], print_chat, "%s disconnected. (%s)", szName, szID)
				}
			}
		}

		return PLUGIN_HANDLED
	}

	if (ShowIP_Method == 1)
	{
		for (new i = 0; i < file_size(szShowIPPath, 1); i++)
		{
			read_file(szShowIPPath, i, szIPResult, 19, iResultLen)

			if (equali(szIP, szIPResult))
			{
				if (ShowIP_Mode == 1)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (disconnecting)^n---^nIP: %s^nSteam ID: %s^n", szName, szIP, szID)

					client_print(0, print_chat, "%s disconnected.", szName)

					return PLUGIN_HANDLED
				}

				if (ShowIP_Mode == 2)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (disconnecting)^n---^nIP: %s^n", szName, szIP)

					client_print(0, print_chat, "%s disconnected.", szName)

					return PLUGIN_HANDLED
				}

				if (ShowIP_Mode == 3)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (disconnecting)^n---^nSteam ID: %s^n", szName, szID)

					client_print(0, print_chat, "%s disconnected.", szName)

					return PLUGIN_HANDLED
				}
			}
		}
	}

	if (ShowIP_Method == 2)
	{
		for (new i = 0; i < file_size(szShowSIDPath, 1); i++)
		{
			read_file(szShowSIDPath, i, szSIDResult, 19, iResultLen)

			if (equali(szID, szSIDResult))
			{
				if (ShowIP_Mode == 1)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (disconnecting)^n---^nIP: %s^nSteam ID: %s^n", szName, szIP, szID)

					client_print(0, print_chat, "%s disconnected.", szName)

					return PLUGIN_HANDLED
				}

				if (ShowIP_Mode == 2)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (disconnecting)^n---^nIP: %s^n", szName, szIP)

					client_print(0, print_chat, "%s disconnected.", szName)

					return PLUGIN_HANDLED
				}

				if (ShowIP_Mode == 3)
				{
					if (ShowIP_Log == 1)
						log_amx("^nShowIP: %s (disconnecting)^n---^nSteam ID: %s^n", szName, szID)

					client_print(0, print_chat, "%s disconnected.", szName)

					return PLUGIN_HANDLED
				}
			}
		}
	}

	if (ShowIP_Mode == 1)
	{
		if (ShowIP_Log == 1)
			log_amx("^nShowIP: %s (disconnecting)^n---^nIP: %s^nSteam ID: %s^n", szName, szIP, szID)

		get_players(iPlayers, iPlayerNum, "ch")

		if (ShowIP_AdminOnly == 1)
		{
			for (new i = 0; i < iPlayerNum; i++)
			{
				if (access(iPlayers[i], ADMIN_BAN))
					client_print(iPlayers[i], print_chat, "%s disconnected. (%s)", szName, szIP)
			}
		}
		else
			client_print(0, print_chat, "%s disconnected. (%s)", szName, szIP)

		return PLUGIN_HANDLED
	}

	if (ShowIP_Mode == 2)
	{
		if (ShowIP_Log == 1)
			log_amx("^nShowIP: %s (disconnecting)^n---^nIP: %s^n", szName, szIP)

		get_players(iPlayers, iPlayerNum, "ch")

		if (ShowIP_AdminOnly == 1)
		{
			for (new i = 0; i < iPlayerNum; i++)
			{
				if (access(iPlayers[i], ADMIN_BAN))
					client_print(iPlayers[i], print_chat, "%s disconnected. (%s)", szName, szIP)
			}
		}
		else
			client_print(0, print_chat, "%s disconnected. (%s)", szName, szIP)

		return PLUGIN_HANDLED
	}

	if (ShowIP_Mode == 3)
	{
		if (ShowIP_Log == 1)
			log_amx("^nShowIP: %s (disconnecting)^n---^nSteam ID: %s^n", szName, szID)
	
		client_print(0, print_chat, "%s disconnected. (%s)", szName, szID)

		return PLUGIN_HANDLED
	}

	return PLUGIN_HANDLED
}

public cmd_showall(id, level, cid)
{
	if (get_pcvar_num(g_Enabled) == 0)
	{
		console_print(id, "ShowIP is currently disabled!")

		return PLUGIN_HANDLED
	}

	if (!cmd_access(id, level, cid, 2))
	{
		console_print(id, "You have no access to this command!")

		return PLUGIN_HANDLED
	}

	new arg[32]
	read_argv(1, arg, 31)

	new tid = cmd_target(id, arg, 1)

	if (!tid)
	{
		console_print(id, "User ^"%s^" not found!", arg)

		return PLUGIN_HANDLED
	}

	get_user_name(tid, szName, 31)
	get_user_ip(tid, szIP, 19, 1)
	get_user_authid(tid, szID, 19)
	geoip_country_ex(szIP, szCountry, 19)

	if (is_user_bot(tid))
		console_print(id, "User %s is a bot!", szName)
	else
		console_print(id, "^nShowIP: %s^n---^nIP: %s^nSteam ID: %s^nCountry: %s^n", szName, szIP, szID, szCountry)

	return PLUGIN_HANDLED
}

public cmd_showall_all(id, level, cid)
{
	if (get_pcvar_num(g_Enabled) == 0)
	{
		console_print(id, "ShowIP is currently disabled!")

		return PLUGIN_HANDLED
	}

	if (!cmd_access(id, level, cid, 1))
	{
		console_print(id, "You have no access to this command!")

		return PLUGIN_HANDLED
	}

	get_players(iPlayers, iPlayerNum, "ch")

	for (new i = 0; i < iPlayerNum; i++)
	{
		get_user_name(iPlayers[i], szName, 31)
		get_user_ip(iPlayers[i], szIP, 19, 1)
		get_user_authid(iPlayers[i], szID, 19)
		geoip_country_ex(szIP, szCountry, 19)

		if ((szIP[0] != '1' && szIP[1] != '9' && szIP[2] != '2') || (szIP[0] != '1' && szIP[1] != '2' && szIP[2] != '7'))
			console_print(id, "^nShowIP: %s^n---^nIP: %s^nSteam ID: %s^nCountry: %s^n", szName, szIP, szID, szCountry)
	}

	return PLUGIN_HANDLED
}

public cmd_showip(id, level, cid)
{
	if (get_pcvar_num(g_Enabled) == 0)
	{
		console_print(id, "ShowIP is currently disabled!")

		return PLUGIN_HANDLED
	}

	if (!cmd_access(id, level, cid, 2))
	{
		console_print(id, "You have no access to this command!")

		return PLUGIN_HANDLED
	}

	new arg[32]
	read_argv(1, arg, 31)

	new tid = cmd_target(id, arg, 1)

	if (!tid)
	{
		console_print(id, "User ^"%s^" not found!", arg)

		return PLUGIN_HANDLED
	}

	get_user_name(tid, szName, 31)
	get_user_ip(tid, szIP, 19, 1)

	if (is_user_bot(tid))
		console_print(id, "User %s is a bot!", szName)
	else
		console_print(id, "^nShowIP: %s^n---^nIP: %s^n", szName, szIP)

	return PLUGIN_HANDLED
}

public cmd_showip_all(id, level, cid)
{
	if (get_pcvar_num(g_Enabled) == 0)
	{
		console_print(id, "ShowIP is currently disabled!")

		return PLUGIN_HANDLED
	}

	if (!cmd_access(id, level, cid, 1))
	{
		console_print(id, "You have no access to this command!")

		return PLUGIN_HANDLED
	}

	get_players(iPlayers, iPlayerNum, "ch")

	for (new i = 0; i < iPlayerNum; i++)
	{
		get_user_name(iPlayers[i], szName, 31)
		get_user_ip(iPlayers[i], szIP, 19, 1)

		if ((szIP[0] != '1' && szIP[1] != '9' && szIP[2] != '2') || (szIP[0] != '1' && szIP[1] != '2' && szIP[2] != '7'))
			console_print(id, "^nShowIP: %s^n---^nIP: %s^n", szName, szIP)
	}

	return PLUGIN_HANDLED
}

public cmd_showsid(id, level, cid)
{
	new arg[32]
	read_argv(1, arg, 31)

	new tid = cmd_target(id, arg, 1)

	if (!tid)
	{
		console_print(id, "User ^"%s^" not found!", arg)

		return PLUGIN_HANDLED
	}

	get_user_name(tid, szName, 31)
	get_user_authid(tid, szID, 19)

	if (is_user_bot(tid))
		console_print(id, "User %s is a bot!", szName)
	else
		console_print(id, "^nShowIP: %s^n---^nSteam ID: %s^n", szName, szID)

	return PLUGIN_HANDLED
}

public cmd_showsid_all(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
	{
		console_print(id, "You have no access to this command!")

		return PLUGIN_HANDLED
	}

	get_players(iPlayers, iPlayerNum, "ch")

	for (new i = 0; i < iPlayerNum; i++)
	{
		get_user_name(iPlayers[i], szName, 31)
		get_user_authid(iPlayers[i], szID, 19)

		if ((szIP[0] != '1' && szIP[1] != '9' && szIP[2] != '2') || (szIP[0] != '1' && szIP[1] != '2' && szIP[2] != '7'))
			console_print(id, "^nShowIP: %s^n---^nSteam ID: %s^n", szName, szID)
	}

	return PLUGIN_HANDLED
}

public cmd_showcountry(id, level, cid)
{
	new arg[32]
	read_argv(1, arg, 31)

	new tid = cmd_target(id, arg, 1)

	if (!tid)
	{
		console_print(id, "User ^"%s^" not found!", arg)

		return PLUGIN_HANDLED
	}

	get_user_name(tid, szName, 31)
	get_user_ip(tid, szIP, 19, 1)
	geoip_country_ex(szIP, szCountry, 19)

	if (is_user_bot(tid))
		console_print(id, "User %s is a bot!", szName)
	else
		console_print(id, "^nShowIP: %s^n---^nCountry: %s^n", szName, szCountry)

	return PLUGIN_HANDLED
}

public cmd_showcountry_all(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
	{
		console_print(id, "You have no access to this command!")

		return PLUGIN_HANDLED
	}

	get_players(iPlayers, iPlayerNum, "ch")

	for (new i = 0; i < iPlayerNum; i++)
	{
		get_user_name(iPlayers[i], szName, 31)
		get_user_ip(iPlayers[i], szIP, 19)
		geoip_country_ex(szIP, szCountry, 19)

		if ((szIP[0] != '1' && szIP[1] != '9' && szIP[2] != '2') || (szIP[0] != '1' && szIP[1] != '2' && szIP[2] != '7'))
			console_print(id, "^nShowIP: %s^n---^nCountry: %s^n", szName, szCountry)
	}

	return PLUGIN_HANDLED
}