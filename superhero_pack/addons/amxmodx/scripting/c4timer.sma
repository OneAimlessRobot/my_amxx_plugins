/* AMX Mod X
*   Stats Logging Plugin
*
* by the AMX Mod X Development Team
*  originally developed by JustinHoMi
*
* This file is part of AMX Mod X.
*
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation, 
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve, 
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#include <amxmodx>
#include <cstrike>

#define PLUGIN 	"C4 Timer and Sound"
#define VERSION "1.6"
#define AUTHOR 	"kwpd"

new g_c4timer
new cvar_showteam
new cvar_flash
new cvar_sprite
new cvar_msg
new g_Cvar
new g_C4
new g_msg_showtimer
new g_msg_roundtime
new g_msg_scenario

#define MAX_SPRITES	2
#define task_sound 69696969

new const g_timersprite[MAX_SPRITES][] = { "bombticking", "bombticking1" }
new const g_message[] = "Detonation time intiallized....."

public plugin_precache() 
{
	precache_sound("C4Female/ten.wav")
	precache_sound("C4Female/nine.wav")
	precache_sound("C4Female/eight.wav")
	precache_sound("C4Female/seven.wav")
	precache_sound("C4Female/six.wav")
	precache_sound("C4Female/five.wav")
	precache_sound("C4Female/four.wav")
	precache_sound("C4Female/three.wav")
	precache_sound("C4Female/two.wav")
	precache_sound("C4Female/one.wav")
	
	return PLUGIN_HANDLED
} 

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cvar_showteam	= register_cvar("amx_showc4timer", "3")
	cvar_flash	= register_cvar("amx_showc4flash", "0")
	cvar_sprite	= register_cvar("amx_showc4sprite", "1")
	cvar_msg	= register_cvar("amx_showc4msg", "0")
	
	g_msg_showtimer	= get_user_msgid("ShowTimer")
	g_msg_roundtime	= get_user_msgid("RoundTime")
	g_msg_scenario	= get_user_msgid("Scenario")
	
	register_event("HLTV", "event_hltv", "a", "1=0", "2=0")
	register_logevent("RoundEnd",2,"1=Round_End")
	register_logevent("RoundStart", 2, "1=Round_Start")
	register_logevent("logevent_plantedthebomb", 3, "2=Planted_The_Bomb")
	
	g_C4	= get_cvar_pointer("mp_c4timer")
	g_Cvar	= register_cvar("amx_soundc4", "1")
}

public event_hltv()
{
	g_c4timer = get_pcvar_num(g_C4)
}

public logevent_plantedthebomb()
{
	new showtteam = get_pcvar_num(cvar_showteam)
	
	static players[32], num, i
	switch(showtteam)
	{
		case 1: 
		{
			get_players(players, num, "ace", "TERRORIST")
		}
		case 2: 
		{
			get_players(players, num, "ace", "CT")
		}
		case 3: 
		{
			get_players(players, num, "ac")
		}
		default: return
	}
	for(i = 0; i < num; ++i) set_task(1.0, "update_timer", players[i])
}

public update_timer(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msg_showtimer, _, id)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_roundtime, _, id)
	write_short(g_c4timer)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_scenario, _, id)
	write_byte(1)
	write_string(g_timersprite[clamp(get_pcvar_num(cvar_sprite), 0, (MAX_SPRITES - 1))])
	write_byte(150)
	write_short(get_pcvar_num(cvar_flash) ? 20 : 0)
	message_end()
	
	if(get_pcvar_num(cvar_msg))
	{
		set_hudmessage(255, 180, 0, 0.44, 0.87, 2, 6.0, 6.0)
		show_hudmessage(id, g_message)
	}
}

public bomb_planted(planter) 
{
	new Name[32]
	new id = task_sound
	
	if(get_pcvar_num(g_Cvar))
	{
		get_user_name(planter, Name, 31)  
		
		new time = get_pcvar_num(g_C4)
		
		float(time)
		set_task( (time - 10.0) , "Zero", task_sound+id)
		set_task( (time - 9.0) , "one", task_sound+id)
		set_task( (time - 8.0) , "two", task_sound+id)
		set_task( (time - 7.0) , "three", task_sound+id)
		set_task( (time - 6.0) , "foor", task_sound+id)
		set_task( (time - 5.0) , "five", task_sound+id)
		set_task( (time - 4.0) , "six", task_sound+id)
		set_task( (time - 3.0) , "seven", task_sound+id)
		set_task( (time - 2.0) , "eigth", task_sound+id)
		set_task( (time - 1.0) , "nine", task_sound+id)
	}
	return PLUGIN_CONTINUE  
}

public Zero()  
{
	client_cmd(0, "spk C4Female/ten.wav" )  
	return PLUGIN_CONTINUE  
}

public one()  
{
	client_cmd(0, "spk C4Female/nine.wav" )  
	return PLUGIN_CONTINUE  
}

public two()  
{
	client_cmd(0, "spk C4Female/eight.wav")  
	return PLUGIN_CONTINUE  
}

public three()  
{
	client_cmd(0, "spk C4Female/seven.wav")  
	return PLUGIN_CONTINUE  
}

public foor()  
{ 
	client_cmd(0, "spk C4Female/six.wav"  )  
	return PLUGIN_CONTINUE  
}

public five()  
{
	client_cmd(0, "spk C4Female/five.wav" )  
	return PLUGIN_CONTINUE  
}

public six()  
{
	client_cmd(0, "spk C4Female/four.wav" )  
	return PLUGIN_CONTINUE  
}

public seven()  
{
	client_cmd(0, "spk C4Female/three.wav")  
	return PLUGIN_CONTINUE  
}

public eigth()  
{
	client_cmd(0, "spk C4Female/two.wav"  )  
	return PLUGIN_CONTINUE  
}

public nine()  
{
	client_cmd(0, "spk C4Female/one.wav")  
	return PLUGIN_CONTINUE  
}

public RoundEnd()
{
	new id = task_sound
	remove_task(task_sound+id)
}

public RoundStart()  
{
	new id = task_sound
	remove_task(task_sound+id)
}
