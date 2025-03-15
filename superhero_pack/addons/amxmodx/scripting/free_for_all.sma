/*	Copyright © 2008, ConnorMcLeod

	Free For All is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Free For All; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

/*
v0.0.6
- Disable Forwards and registered message when plugin is disabled
v0.0.5
- Recursion should be fixed for all Ham forwards
- Removed Cvar, new command instead
- Hide Radar
v0.0.4
- Fixed HamKilled possible loop when a player kills himself
v0.0.3
- Removed useless vars
v0.0.2
- Block Radar
v0.0.1
- First shot
*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Free For All"
#define AUTHOR "ConnorMcLeod"
#define VERSION "0.0.6"

#define OFFSET_TEAM	114
#define fm_get_user_team(%1)	get_pdata_int(%1,OFFSET_TEAM)
#define fm_set_user_team(%1,%2)	set_pdata_int(%1,OFFSET_TEAM,%2)

new gmsgRadar
new g_iMaxPlayers
new mp_friendlyfire, g_iOldFFVal
new HamHook:g_hTraceAttack, HamHook:g_hTakeDamage, HamHook:g_hKilled, g_mRadarHook
new bool:g_bFFA

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR )

	register_concmd("amx_set_ffa", "AdminCommand_SetFFA", ADMIN_CFG)
	register_clcmd("drawradar", "ClientCommand_DrawRadar") // not sure this is hookable but anyway Radar Msg is bloqued as well

	g_iMaxPlayers = get_maxplayers()
	mp_friendlyfire = get_cvar_pointer("mp_friendlyfire")
	g_iOldFFVal = get_pcvar_num(mp_friendlyfire)
	gmsgRadar = get_user_msgid("Radar")
}

public AdminCommand_SetFFA(id, level)
{
	if( !(get_user_flags(id) & level) )
	{
		return PLUGIN_HANDLED
	}

	if( read_argc() < 2 )
	{
		if( id )
		{
			client_print(id, print_console, "Usage: amx_set_ffa <0|1>" )
		}
		else
		{
			server_print( "Usage: amx_set_ffa <0|1>" )
		}
	}
	else
	{
		new szArg[3]
		read_argv(1, szArg, charsmax(szArg))
		if( g_bFFA && (szArg[0] == '0' || szArg[1] == 'f' || szArg[1] == 'F') )
		{
			set_pcvar_num(mp_friendlyfire, g_iOldFFVal)
			client_cmd(0, "drawradar")
			Register_Forwards((g_bFFA=false))
		}
		else if( !g_bFFA && (szArg[0] == '1' || szArg[1] == 'n' || szArg[1] == 'N') )
		{
			g_iOldFFVal = get_pcvar_num(mp_friendlyfire)
			set_pcvar_num(mp_friendlyfire, 1)
			client_cmd(0, "hideradar")
			Register_Forwards((g_bFFA=true))
		}
	}
	
	if( id )
	{
		client_print(id, print_console, "FFA mode is %s", g_bFFA ? "On" : "Off" )
	}
	else
	{
		server_print( "FFA mode is %s", g_bFFA ? "On" : "Off" )
	}
	return PLUGIN_HANDLED
}

public client_connect(id)
{
	if( g_bFFA )
	{
		client_cmd(id, "hideradar")
	}
}

public TraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damagebits)
{
	if( victim != attacker && (1 <= attacker <= g_iMaxPlayers) )
	{
		new vteam = fm_get_user_team(victim)
		if( vteam == fm_get_user_team(attacker) )
		{
			fm_set_user_team(victim, vteam == 1 ? 2 : 1)
			ExecuteHamB(Ham_TraceAttack, victim, attacker, damage, direction, tracehandle, damagebits)
			fm_set_user_team(victim, vteam)
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public TakeDamage(victim, idinflictor, attacker, Float:damage, damagebits)
{
	if( victim != attacker && (1 <= attacker <= g_iMaxPlayers) )
	{
		new vteam = fm_get_user_team(victim)
		if( vteam == fm_get_user_team(attacker) )
		{
			fm_set_user_team(victim, vteam == 1 ? 2 : 1)
			ExecuteHamB(Ham_TakeDamage, victim, idinflictor, attacker, damage, damagebits)
			fm_set_user_team(victim, vteam)
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public Killed(victim, attacker, shouldgib)
{
	if( victim != attacker && (1 <= attacker <= g_iMaxPlayers) )
	{
		new vteam = fm_get_user_team(victim)
		if( vteam == fm_get_user_team(attacker) )
		{
			fm_set_user_team(victim, vteam == 1 ? 2 : 1)
			ExecuteHamB(Ham_Killed, victim, attacker, shouldgib)
			fm_set_user_team(victim, vteam)
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public Message_Radar(iMsgId, MSG_DEST, id)
{
	return PLUGIN_HANDLED
}

public ClientCommand_DrawRadar(id)
{
	return _:g_bFFA
}

Register_Forwards(bool:bState)
{
	if(bState)
	{
		if( g_hTraceAttack )
		{
			EnableHamForward( g_hTraceAttack )
		}
		else
		{
			g_hTraceAttack = RegisterHam(Ham_TraceAttack, "player", "TraceAttack")
		}

		if( g_hTakeDamage )
		{
			EnableHamForward( g_hTakeDamage )
		}
		else
		{
			g_hTakeDamage = RegisterHam(Ham_TakeDamage, "player", "TakeDamage")
		}

		if( g_hKilled )
		{
			EnableHamForward( g_hKilled )
		}
		else
		{
			g_hKilled = RegisterHam(Ham_Killed, "player", "Killed")
		}

		if( !g_mRadarHook )
		{
			g_mRadarHook = register_message( gmsgRadar, "Message_Radar")
		}
	}
	else
	{
		if( g_hTraceAttack )
		{
			DisableHamForward( g_hTraceAttack )
		}

		if( g_hTakeDamage )
		{
			DisableHamForward( g_hTakeDamage )
		}

		if( g_hKilled )
		{
			DisableHamForward( g_hKilled )
		}

		if( g_mRadarHook )
		{
			unregister_message(gmsgRadar, g_mRadarHook)
			g_mRadarHook = 0
		}
	}
}