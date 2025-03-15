/*  
	amx_freeze 
    by Drekes
    
    Description:
        Makes it able for admins to freeze a player, this will make him unable to move or jump.
        
    Cvars:
        amx_freeze_knife_only 0/1    Makes a frozen player hold only his knife
		
	Command:
		amx_freeze <@all/@T/@CT/player> <0/1> <seconds>
		
		seconds is optional.
        
    Changelog: 
        v1.0: - Release
        
        v1.1: - Merged several functions.    				darkgod's suggestion
              - Remade the activity code.    				darkgod's suggestion
              - Changed the numtime code.    				darkgod's suggestion
              - Added a timer.                				Elite Taco's suggestion
              - Added cvar for game-monitor
              
        v1.2: - Changed way of freezing       				Many peoples suggestion
              - knife only (cvar)
        
        v1.3: - Added @ct/@t/@all support    				ConnorMcleod's suggestion.
              - Filtered curweapon             				ConnorMcleod's suggestion.
              - changed timer code.
			 
		v1.4: - Converted to fakemeta.
			  - Made cstrike version.
		
		v1.5: - Blocked players view when frozen.			ConnorMcleod's suggestion.
			  - Used bits to check and set frozen players.	ConnorMcleod's suggestion.
			 
		v1.6: - Remove reduntant code.						ConnorMcleod's suggestion.
			  - Removed cstrike version since 
			    get_user_team isn't used anymore.
			  - unregistered PlayerPreThink when it's not
				needed.										ConnorMcLeod's suggestion.
			
		v1.7: - optimized code								ConnorMcLeod's suggestion.
		
		v1.8: - Changed syntax of command 					Seta00's suggestion.
			  
    Credits:
        - RedRobster: Helping me find an annoying mistake that kept crashing my server.
		- Bugsy: For the bitfield tutorial and the macro's.
		- ConnorMcleod / ArkShine / Seta00: Suggestions to improve the plugin.
		- All the other people that suggested and helped improving the plugin
*/

#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define VERSION 	"1.8"

#define Freeze(%1)     	 (frozen |= (1<<(%1&31)))
#define UnFreeze(%1)   	 (frozen &= ~(1<<(%1&31)))
#define IsFrozen(%1)     (frozen & (1<<(%1&31))) 

enum teams
{
	ALL,
	T,
	CT
};

new const g_TeamNames[teams][] = 
{
	"all players",
	"terrorists",
	"counter-terrorists"
};

new cvar_knife;
new frozen;
new g_PreThinkId;

new Float: g_Angles[33][3];

public plugin_init()
{
	register_plugin("amx freeze", VERSION, "Drekes");
	
	register_concmd("amx_freeze", "Cmd_Freeze", ADMIN_KICK, "<player> <0/1> <seconds> ^"Freeze/unfreeze a player^"");
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1", "2!29");
	
	
	register_cvar("freeze_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY);
	cvar_knife = register_cvar("amx_freeze_knife_only", "1");
	
}

public client_disconnect(id)
{
	if(IsFrozen(id))
		UnFreeze(id);
	
	if(!frozen && g_PreThinkId)
	{
		unregister_forward(FM_PlayerPreThink, g_PreThinkId);
		
		g_PreThinkId = 0;
	}
}

public Cmd_Freeze(id, level, cid)
{	
	if(!cmd_access(id, level, cid, 3))  
		return PLUGIN_HANDLED;
		
	new admin_name[34];
	get_user_name(id, admin_name, charsmax(admin_name));
	
	new target[34], szOn[3], szTime[6];
	
	read_argv(1, target, charsmax(target));
	read_argv(2, szOn, charsmax(szOn));
	read_argv(3, szTime, charsmax(szTime));
	
	new iOn = str_to_num(szOn);
	new Float: fTime = str_to_float(szTime);
	
	if(target[0] == '@')
	{	
		new players[32], pnum;
		new teams: team;
		
		switch(target[1])
		{
			case 'A', 'a':
			{
				get_players(players, pnum);
				
				team = ALL;
			}
				
			case 'T', 't':
			{
				get_players(players, pnum, "ae", "TERRORIST");
				
				team = T;
			}
			
			case 'C', 'c':
			{
				get_players(players, pnum, "ae", "CT");
				
				team = CT;
			}
		}
		
		for(new i = 0; i < pnum; i++)
			freeze(players[i], iOn, fTime);
			
		show_activity(id, admin_name, "%sfroze %s", iOn == 0 ? "un" : "", g_TeamNames[team]);
		log_amx("%s %sfroze %s", admin_name, iOn == 0 ? "un" : "", g_TeamNames[team]);
		
		return PLUGIN_HANDLED;
	}
	
	new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);

	if(!player)	
		return PLUGIN_HANDLED;
		
	freeze(player, iOn, fTime);
	
	new plName[34];
	get_user_name(player, plName, charsmax(plName));	
	
	show_activity(id, admin_name, "%sfroze %s", iOn == 0 ? "un" : "", plName);
	log_amx("%s %sfroze %s", admin_name, iOn == 0 ? "un" : "", plName);
	
	return PLUGIN_HANDLED;
}

freeze(id, on, Float:Time)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
		
	if(!on)
	{
		UnFreeze(id);
		
		set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN);
		set_pev(id, pev_fixangle, 0);
	
		if(!frozen && g_PreThinkId)
		{
			unregister_forward(FM_PlayerPreThink, g_PreThinkId);
			
			g_PreThinkId = 0;
		}
	}
	
	else
	{
		if(get_pcvar_num(cvar_knife))
			engclient_cmd(id, "weapon_knife");
			
		if(!frozen && !g_PreThinkId)
			g_PreThinkId = register_forward(FM_PlayerPreThink, "Fwd_PlayerPreThink");
			
		Freeze(id);
		
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN);
		pev(id, pev_v_angle, g_Angles[id]);
		
		if(Time)
			set_task(Time, "Task_Unfreeze", id);
	}
	
	return PLUGIN_HANDLED;
}

public Task_Unfreeze(id)
{
	if(is_user_connected(id))
	{
		UnFreeze(id);
		
		set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN);
		set_pev(id, pev_fixangle, 0);
	
		client_print(id, print_chat, "[AMXX] You have been unfrozen.");
		
		if(!frozen && g_PreThinkId)
		{
			unregister_forward(FM_PlayerPreThink, g_PreThinkId);
			
			g_PreThinkId = 0;
		}
	}
}

public Event_CurWeapon(id)
{
	if(IsFrozen(id))
	{
		if(is_user_alive(id) && get_pcvar_num(cvar_knife))
			engclient_cmd(id, "weapon_knife");
	}
}

public Fwd_PlayerPreThink(id)
{
	if(IsFrozen(id))
	{
		if(is_user_alive(id))
		{
			set_pev(id, pev_v_angle, g_Angles[id]);
			set_pev(id, pev_fixangle, 1);
		}
	}
}

