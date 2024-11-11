/*	Formatright © 2009, ConnorMcLeod

	Half Life Media Player is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Half Life Media Player; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <nvault>

#define VERSION "3.1.1"

#define NVAULT_MAX_DAYS_SAVE	15
#define MAX_RECONNECT_TIME	300 // in seconds (take in account that players could download a new map)
#define DEFAULT_VOLUME 40

#define A_DAY_IN_SECONDS		86400 // 60 * 60 * 24

#define GROUP_MAX_LENGTH	64

#define RADIO_MAX_LENGTH	64
#define URL_MAX_LENGTH	192

#define MAX_PLAYERS	32
#define AUTHID_LENGTH	22

#define SetIdBits(%1,%2)		%1 |= 1<<(%2 & 31)
#define ClearIdBits(%1,%2)	%1 &= ~( 1<<(%2 & 31) )
#define GetIdBits(%1,%2)		%1 & 1<<(%2 & 31)

enum _:Radios
{
	RadioName[RADIO_MAX_LENGTH],
	RadioUrl[URL_MAX_LENGTH]
}

enum _:Group
{
	GroupName[GROUP_MAX_LENGTH],
	Array:GroupArrayOffset
}

enum _:MenuSettings
{
	mGroups,
	mRadios,
	mConfig
}

new Array:g_aGroups

new g_iGroupsCount

new g_bRepeat, g_bListening

new g_iMenuOption[MAX_PLAYERS+1]
new g_iMenuPosition[MAX_PLAYERS+1]
new g_iVolume[MAX_PLAYERS+1] = {DEFAULT_VOLUME, ...}
new g_szAuthid[MAX_PLAYERS+1][AUTHID_LENGTH]
new g_PlayerGroup[MAX_PLAYERS+1][Group]

new g_pCvarShowAll, g_pCvarNoMotd

new gmsgMOTD
new g_iMotdRegistered
new g_iNvault

public plugin_init()
{
	register_plugin("Half Life Media Player", VERSION, "ConnorMcLeod")
	register_dictionary("common.txt")
	register_dictionary("hlmp.txt")

	g_pCvarShowAll = register_cvar("hlmp_show_all", "1")
	g_pCvarNoMotd = register_cvar("hlmp_no_motd", "1")

	register_menucmd(register_menuid("HLMP"), 0x3FF, "HlmpMenuAction")

	register_clcmd("hlmp_menu", "ClientCommand_HlmpMenu")
	register_clcmd("say /hlmp", "ClientCommand_HlmpMenu")
	register_clcmd("say /music", "ClientCommand_HlmpMenu")
	register_clcmd("say /radio", "ClientCommand_HlmpMenu")
	register_clcmd("say_team /hlmp", "ClientCommand_HlmpMenu")
	register_clcmd("say_team /music", "ClientCommand_HlmpMenu")
	register_clcmd("say_team /radio", "ClientCommand_HlmpMenu")

	register_clcmd("say /stop", "ClientCommand_StopMusic")
	register_clcmd("say_team /stop", "ClientCommand_StopMusic")

	Read_ConfigFile()
	Read_OpeningMotdCommandsFile()

	g_iNvault = nvault_open("hlmp")
	nvault_prune(g_iNvault, 0, get_systime(-(A_DAY_IN_SECONDS * NVAULT_MAX_DAYS_SAVE)) )

	gmsgMOTD = get_user_msgid("MOTD")
}

Read_ConfigFile()
{
	new szConfigFile[64]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/mediafiles.ini", szConfigFile)

	new iFile = fopen(szConfigFile, "rt")

	if(!iFile)
	{
		return
	}

	g_aGroups = ArrayCreate(Group)

	new iGroup
	new szText[Radios+16], RadioDatas[Radios], GroupDatas[Group]
	new Array:aRadiosDatas

	while(!feof(iFile))
	{
		fgets(iFile, szText, charsmax(szText))
		trim( szText )

		if(!szText[0] || szText[0] == '#' || szText[0] == ';' || (szText[0] == '/' && szText[1] == '/'))
		{
			continue
		}

		if( szText[0] == '[' )
		{
			iGroup++
			aRadiosDatas = ArrayCreate( Radios )

			strtok(szText[1], GroupDatas[GroupName], charsmax(GroupDatas[GroupName]), RadioDatas, 1, ']', 0)
			GroupDatas[GroupArrayOffset] = _:aRadiosDatas

			ArrayPushArray(g_aGroups, GroupDatas)
		}
		else if( iGroup )
		{
			parse(	szText,
					RadioDatas[RadioName], charsmax(RadioDatas[RadioName]), 
					RadioDatas[RadioUrl], charsmax(RadioDatas[RadioUrl])	)

			ArrayPushString(aRadiosDatas, RadioDatas)
		}
	}
	fclose(iFile)

	g_iGroupsCount = ArraySize(g_aGroups)
}

Read_OpeningMotdCommandsFile()
{
	new szConfigFile[64]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/hlmp_motd.ini", szConfigFile)
	new iFile = fopen(szConfigFile, "rt")
	if( iFile )
	{
		new szText[64], szCommand[32]
		while(!feof(iFile))
		{
			fgets(iFile, szText, charsmax(szText))
			trim( szText )
			if(!szText[0] || szText[0] == '#' || szText[0] == ';' || (szText[0] == '/' && szText[1] == '/'))
			{
				continue
			}
			parse(szText, szCommand, charsmax(szCommand))
			register_clcmd(szCommand, "OpeningMotdCommands")
		}
	}	
}

public plugin_end()
{
	new TempGroup[Group], iSize = ArraySize(g_aGroups)

	for(new i; i<iSize; i++)
	{
		ArrayGetArray(g_aGroups, i, TempGroup)
		ArrayDestroy(TempGroup[GroupArrayOffset])
	}

	ArrayDestroy(g_aGroups)

	nvault_close(g_iNvault)
}

public client_connect(id)
{
	g_szAuthid[id] = "C"
}

public client_authorized( id )
{
	if( g_szAuthid[id][0] == 'P' )
	{
		get_user_authid(id, g_szAuthid[id], AUTHID_LENGTH-1)
		GetPlayerSettings(id)
	}
	else
	{
		get_user_authid(id, g_szAuthid[id], AUTHID_LENGTH-1)
	}
}

public client_putinserver(id)
{
	g_iMenuOption[id] = mGroups
	g_PlayerGroup[id][GroupName][0] = 0
	g_PlayerGroup[id][GroupArrayOffset] = 0

	if( g_szAuthid[id][0] == 'C' )
	{
		g_szAuthid[id] = "P"
		return
	}

	static szSettings[8], szVolume[4], szRepeat[2], szListening[2], iVolume, iDisconnectTime
	nvault_lookup(g_iNvault, g_szAuthid[id], szSettings, charsmax(szSettings), iDisconnectTime)
	parse(szSettings, szVolume, charsmax(szVolume), szRepeat, charsmax(szRepeat), szListening, charsmax(szListening))

	if( (iVolume = str_to_num(szVolume)) )
	{
		g_iVolume[id] = min(iVolume, 100)
	}
	else
	{
		g_iVolume[id] = DEFAULT_VOLUME
	}

	if( str_to_num(szRepeat) )
	{
		SetIdBits(g_bRepeat, id)
	}
	else
	{
		ClearIdBits(g_bRepeat, id)
	}

	if(	get_systime() - iDisconnectTime < MAX_RECONNECT_TIME
	&&	str_to_num(szListening) == 1
	&&	get_pcvar_num(g_pCvarNoMotd)	)
	{
		SetIdBits(g_bListening, id)
		g_iMotdRegistered = register_message(gmsgMOTD, "Message_MOTD")
	}
	else
	{
		ClearIdBits(g_bListening, id)
	}
}

GetPlayerSettings(id)
{
	new szSettings[8], szVolume[4], szRepeat[2], iVolume
	nvault_get(g_iNvault, g_szAuthid[id], szSettings, charsmax(szSettings))
	parse(szSettings, szVolume, charsmax(szVolume), szRepeat, charsmax(szRepeat))

	if( (iVolume = str_to_num(szVolume)) )
	{
		g_iVolume[id] = min(iVolume, 100)
	}
	else
	{
		g_iVolume[id] = DEFAULT_VOLUME
	}

	if( str_to_num(szRepeat) )
	{
		SetIdBits(g_bRepeat, id)
	}
	else
	{
		ClearIdBits(g_bRepeat, id)
	}	

	ClearIdBits(g_bListening, id)
}

public client_disconnect( id )
{
	static szSettings[8]
	formatex(szSettings, charsmax(szSettings), "%d %d %d", 
										g_iVolume[id], 
											_:!!(GetIdBits(g_bRepeat, id)), 
												_:!!(GetIdBits(g_bListening, id)))
	nvault_set(g_iNvault, g_szAuthid[id], szSettings)

	g_szAuthid[id] = "D"
}

public Message_MOTD(iMsgId, iDest, id)
{
	if( GetIdBits(g_bListening, id) )
	{
		if( get_msg_arg_int(1) )
		{
			unregister_message(gmsgMOTD, g_iMotdRegistered)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public ClientCommand_HlmpMenu(id)
{
	DisplayMenu(id, g_iMenuPosition[id] = 0)
}

DisplayMenu(id, iPos = 0)
{
	new szMenu[1024], n
	new iKeys = MENU_KEY_6|MENU_KEY_7|MENU_KEY_0

	n = formatex(szMenu[n], charsmax(szMenu)-n, "\rHL Media Player (HLMP %s)^n", VERSION)

	switch( g_iMenuOption[id] )
	{
		case mGroups:
		{
			new iStart = iPos * 5
			new iStop = min(iStart + 5 , g_iGroupsCount)
			new aGroup[Group]

			n += formatex(szMenu[n], charsmax(szMenu)-n, "\d%L^n", id, "HLMP_GROUPS")
			
			for(new i=iStart, j; i<iStop; i++)
			{
				iKeys |= (1<<j)
				ArrayGetArray(g_aGroups, i, aGroup)
				n += formatex(szMenu[n], charsmax(szMenu)-n, "\w%d. \r%s^n", ++j, aGroup[GroupName])
			}
			iPos = iStop - iStart
			if( iPos < 5 )
			{
				for(new i; i < 5-iPos; i++)
				{
					n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
				}
			}

			if( g_PlayerGroup[id][GroupName][0] )
			{
				n += formatex(szMenu[n], charsmax(szMenu)-n, "\w6. \y%s^n", g_PlayerGroup[id][GroupName])
			}
			else
			{
				n += formatex(szMenu[n], charsmax(szMenu)-n, "\w6. \y%L^n", id, "HLMP_CONFIG")
			}
			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w7. \y%L^n\w", id, "HLMP_STOPMUSIC")

			if( iStart )
			{
				iKeys |= MENU_KEY_8
				n += formatex(szMenu[n], charsmax(szMenu)-n, "8. %L^n", id, "BACK")
			}
			else
			{
				n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
			}

			if( iStop < g_iGroupsCount )
			{
				iKeys |= MENU_KEY_9
				n += formatex(szMenu[n], charsmax(szMenu)-n, "9. %L^n", id, "MORE")
			}
			else
			{
				n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
			}
		}
		case mRadios:
		{
			new Array:aRadios = g_PlayerGroup[id][GroupArrayOffset]
			new aCurRadio[Radios]
			new iRadiosNum = ArraySize(aRadios)

			new iStart = iPos * 5
			new iStop = min(iStart + 5 , iRadiosNum)

			n += formatex(szMenu[n], charsmax(szMenu)-n, "\d%s^n", g_PlayerGroup[id][GroupName])

			for(new i=iStart, j; i<iStop; i++)
			{
				iKeys |= (1<<j)
				ArrayGetArray(aRadios, i, aCurRadio)
				n += formatex(szMenu[n], charsmax(szMenu)-n, "\w%d. \r%s^n", ++j, aCurRadio[RadioName])
			}
			iPos = iStop - iStart
			if( iPos < 5 )
			{
				for(new i; i< 5 - iPos; i++)
				{
					n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
				}
			}

			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w6. \y%L^n", id, "HLMP_CONFIG")
			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w7. \y%L^n\w", id, "HLMP_STOPMUSIC")

			if( iStart )
			{
				iKeys |= MENU_KEY_8
				n += formatex(szMenu[n], charsmax(szMenu)-n, "8. %L^n", id, "BACK")
			}
			else
			{
				n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
			}

			if( iStop < iRadiosNum )
			{
				iKeys |= MENU_KEY_9
				n += formatex(szMenu[n], charsmax(szMenu)-n, "9. %L^n", id, "MORE")
			}
			else
			{
				n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
			}

		}
		case mConfig:
		{
			iKeys |= MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_6|MENU_KEY_7

			n += formatex(szMenu[n], charsmax(szMenu)-n, "\d%L^n", id, "HLMP_CONFIG")

			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w1. \y%L\R%L^n", id, "HLMP_REPEAT", id, GetIdBits(g_bRepeat, id) ? "ON" : "OFF")
			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w2. \y%L +\R%d^n", id, "HLMP_VOLUME", g_iVolume[id])
			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w3. \y%L -^n", id, "HLMP_VOLUME")
			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w4. \y%L^n^n", id, "HLMP_ABOUT")

			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w6. \yGroups^n")
			n += formatex(szMenu[n], charsmax(szMenu)-n, "\w7. \y%L^n^n^n", id, "HLMP_STOPMUSIC")
		}
	}

	n += formatex(szMenu[n], charsmax(szMenu)-n, "\w0. %L", id, "EXIT")

	show_menu(id, iKeys, szMenu, 30, "HLMP")

	return PLUGIN_HANDLED
}

public HlmpMenuAction(id, iKey)
{
	switch( g_iMenuOption[id] )
	{
		case mGroups:
		{
			switch( iKey )
			{
				case 0..4:
				{
					ArrayGetArray(g_aGroups, g_iMenuPosition[id]*5 + iKey, g_PlayerGroup[id])

					g_iMenuOption[id] = mRadios
					DisplayMenu(id, g_iMenuPosition[id] = 0)
				}
				case 5:
				{
					if( g_PlayerGroup[id][GroupArrayOffset] )
					{
						g_iMenuOption[id] = mRadios
						DisplayMenu(id, g_iMenuPosition[id])
					}
					else
					{
						g_iMenuOption[id] = mConfig
						DisplayMenu(id, g_iMenuPosition[id] = 0)
					}
				}
				case 6:
				{
					ClientCommand_StopMusic(id)
				}
				case 7:
				{
					if( --g_iMenuPosition[id] < 0 )
					{
						g_iMenuPosition[id] = 0
					}
					DisplayMenu(id, g_iMenuPosition[id])
				}
				case 8:
				{
					if( ++g_iMenuPosition[id] >= g_iGroupsCount / 5 )
					{
						g_iMenuPosition[id] = g_iGroupsCount / 5
					}
					DisplayMenu(id, g_iMenuPosition[id])
				}
				case 9:
				{
					return PLUGIN_HANDLED
				}
			}
		}
		case mRadios:
		{
			switch( iKey )
			{
				case 0..4:
				{
					PlayMusic(id, g_PlayerGroup[id][GroupArrayOffset], g_iMenuPosition[id]*5 + iKey)
				}
				case 5:
				{
					g_iMenuOption[id] = mConfig
					DisplayMenu(id, g_iMenuPosition[id] = 0)
				}
				case 6:
				{
					ClientCommand_StopMusic(id)
				}
				case 7:
				{
					if( --g_iMenuPosition[id] < 0 )
					{
						g_iMenuPosition[id] = 0
					}
					DisplayMenu(id, g_iMenuPosition[id])
				}
				case 8:
				{
					new iSize = ArraySize(g_PlayerGroup[id][GroupArrayOffset])
					if( ++g_iMenuPosition[id] >= iSize / 5 )
					{
						g_iMenuPosition[id] = iSize / 5
					}
					DisplayMenu(id, g_iMenuPosition[id])
				}
				case 9:
				{
					return PLUGIN_HANDLED
				}
			}
		}
		case mConfig:
		{
			switch( iKey )
			{
				case 0:
				{
					if( GetIdBits(g_bRepeat, id) )
					{
						ClearIdBits(g_bRepeat, id)
					}
					else
					{
						SetIdBits(g_bRepeat, id)
					}
					client_print(id, print_chat, "%L", id, "HLMP_CONFIGMENUTIP")
					DisplayMenu(id)
				}
				case 1:
				{
					if( (g_iVolume[id] += 5) > 100)
					{
						g_iVolume[id] = 100
					}
					client_print(id, print_chat, "%L", id, "HLMP_CONFIGMENUTIP")
					DisplayMenu(id)
				}
				case 2:
				{
					if( (g_iVolume[id] -= 5) < 0)
					{
						g_iVolume[id] = 0
					}
					client_print(id, print_chat, "%L", id, "HLMP_CONFIGMENUTIP")
					DisplayMenu(id)
				}
				case 3:
				{
					client_print(id, print_chat, "HL Media Player %s by ConnorMcLeod, download link in console.", VERSION)
					client_print(id, print_center, "HL Media Player %s by ConnorMcLeod", VERSION)
					client_print(id, print_console, "http://forums.alliedmods.net/showthread.php?p=833070#post833070")
				}
				case 5:
				{
					g_iMenuOption[id] = mGroups
					DisplayMenu(id, g_iMenuPosition[id] = 0)
				}
				case 6:
				{
					ClientCommand_StopMusic(id)
				}
				case 9:
				{
					return PLUGIN_HANDLED
				}
				default:
				{
					DisplayMenu(id)
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

PlayMusic(id, Array:aGroup, iRadio)
{
	new Radio[Radios]
	ArrayGetArray(aGroup, iRadio, Radio)

	if( get_pcvar_num(g_pCvarShowAll) )
	{
		new szName[32]
		get_user_name(id, szName, charsmax(szName))
		client_print(0, print_chat, "%L", LANG_PLAYER, "HLMP_LISTENING", szName, Radio[RadioName])
	}

	new szMotd[1024], n

	n = formatex(szMotd[n], charsmax(szMotd)-n, "<html><head><meta http-equiv=^"content-type^" content=^"text/html; charset=UTF-8^"></head><body bgcolor=^"#000000^" align=^"center^"><span style=^"color: #FFB000; font-size: 9pt^">Now playing: %s <br>", Radio[RadioName])
	n += formatex(szMotd[n], charsmax(szMotd)-n, "<object classid=CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6 codebase=http://www.microsoft.com/ntserver/netshow/download/en/nsmp2inf.cab#Version=5,1,51,415 type=application/x-oleobject name=msplayer width=256 height=65 align=^"middle^" id=msplayer>")
	n += formatex(szMotd[n], charsmax(szMotd)-n, "<param name=^"enableContextMenu^" value=^"0^"><param name=^"stretchToFit^" value=^"1^">")
	if(GetIdBits(g_bRepeat, id))
	{
		n += formatex(szMotd[n], charsmax(szMotd)-n, "<param name=^"AutoRewind^" value=^"1^">")
	}
	n += formatex(szMotd[n], charsmax(szMotd)-n, "<param name=^"Volume^" value=^"%d^">", g_iVolume[id])
	n += formatex(szMotd[n], charsmax(szMotd)-n, "<param name=^"AutoStart^" value=^"1^"><param name=^"URL^" value=^"%s^">", Radio[RadioUrl])
	n += formatex(szMotd[n], charsmax(szMotd)-n, "<param name=^"uiMode^" value=^"full^"><param name=^"width^" value=^"256^"><param name=^"height^" value=^"65^">")
	n += formatex(szMotd[n], charsmax(szMotd)-n, "<param name=^"TransparentAtStart^" value=^"1^"></object><br>^"%L^"</span>", id, "HLMP_CLOSEWINDOW")
	n += formatex(szMotd[n], charsmax(szMotd)-n, "</body></html>")

	show_motd(id, szMotd, "HL Media Player")

	SetIdBits(g_bListening, id)
}

public ClientCommand_StopMusic(id)
{
	new szMotd[256]
	formatex(szMotd, charsmax(szMotd), "<html><head><meta http-equiv=^"content-type^" content=^"text/html; charset=UTF-8^"></head><body bgcolor=^"#000000^" align=^"center^"><span style=^"color: #FFB000; font-size: 9pt^">^"%L^"</span></body></html>", id, "HLMP_CLOSEWINDOW")
	show_motd(id, szMotd, "HL Media Player")
	ClearIdBits(g_bListening, id)
	return PLUGIN_HANDLED
}

public OpeningMotdCommands(id)
{
	ClearIdBits(g_bListening, id)
}