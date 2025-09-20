/*******************************************************************************************************
                        		Control-Players
          

  Authors: KRoTaL & Fox-NL
  Version: 0.2
  Ported to AMXX by GHW_Chronic

  0.1  Release
  0.2  Fixed a few bugs
	 You can control a player when you are dead
  

	This plugin will allow you to control a player, when he is alive.
	You can do almost everything you want (move, jump, reload, use, nighvision, flashlight, radio, ...)
	and the coolest of the plugin is that it won't mess your binds up like what the other plugin did...
	It almost doesn't even touch your config.

	Important: if you want to control a player while you are dead, you have to select him in spectator mode (chase cam or first
	person cam) before executing the amx_control command. 


  Commands:

	amx_control	<name/id/authid>   -   start controlling the victim
	amx_stopcontrol		       -   stop controlling the victim


  Cvars:

	controlplayers_beams 1		    - 	0: disables the beam
								1: enables a beam while controlling (only the controller will see it)

	controlplayers_vision 1		    - 	0: no cool vision
								1: enables the cool vision to the victim while controlling

	controlplayers_firstperson 0	    - 	0: third-person controlling 
						    - 	1: first-person controlling

  Setup (AMX 0.9.9):

	Install the amx file.
	Enable VexdUM (both in metamod's plugins.ini and amx's modules.ini)


  Credits:

	A small credit goes to Asskickr who made a kind of the same plugin 
	a long time ago... (not-working one)

	anarchist.: German translation
	Xavior: Danish translation

*******************************************************************************************************/


#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>


new controlled[33] = {0, ...}
new controller[33] = {0, ...}
new camera[33] = {0, ...}
new laserbeam, laserdot
new gmsgSetFOV
new gmsgFade


public plugin_init() 
{
	register_plugin("Control-Players", "0.2", "KRoTaL & Fox-NL")
	register_concmd("amx_control", "control", ADMIN_SLAY, "<name/id/authid> - start controlling the victim")
	register_concmd("amx_stopcontrol", "stop_control", ADMIN_SLAY, "stop controlling the victim")
	register_cvar("controlplayers_beams", "1")
	register_cvar("controlplayers_vision", "1")
	register_cvar("controlplayers_firstperson", "0")
	register_clcmd("c_slot1", "c_slot1")
	register_clcmd("c_slot2", "c_slot2")
	register_clcmd("c_slot3", "c_slot3")
	register_clcmd("c_slot4", "c_slot4")
	register_clcmd("c_slot5", "c_slot5")
	register_clcmd("c_slot6", "c_slot6")
	register_clcmd("c_slot7", "c_slot7")
	register_clcmd("c_slot8", "c_slot8")
	register_clcmd("c_slot9", "c_slot9")
	register_clcmd("c_slot10", "c_slot10")
	register_clcmd("buy", "c_buy") 
	register_clcmd("drop", "c_drop") 
	register_clcmd("nightvision", "c_nightvision")
	register_clcmd("lastinv", "c_lastinv")
	register_clcmd("radio1", "c_radio1")
	register_clcmd("radio2", "c_radio2")
	register_clcmd("radio3", "c_radio3")
	register_event("DeathMsg", "death_event", "a")
	register_event("ResetHUD", "resethud_event", "be")
	register_event("CurWeapon", "check_weapon", "be", "1=1")
	register_event("23", "spray", "a", "1=112")
	register_event("Flashlight", "flashlight", "be")
	register_event("ScreenFade", "screen_fade", "b")
	register_event("TextMsg", "game_restart", "a", "1=4", "2&#Game_C", "2&#Game_w")
	register_event("SendAudio", "round_end", "a", "2=%!MRAD_terwin", "2=%!MRAD_ctwin", "2=%!MRAD_rounddraw")
	gmsgSetFOV = get_user_msgid("SetFOV")
	gmsgFade = get_user_msgid("ScreenFade") 
}

public client_prethink(id)
{
	if(controlled[id] > 0)
	{
		if(get_user_button(id) & IN_ATTACK)
		{
			client_cmd(controlled[id], "+attack")
		}
		else if(get_user_oldbutton(id) & IN_ATTACK)
		{
			client_cmd(controlled[id], "-attack")
		}
		if(get_user_button(id) & IN_ATTACK2)
		{
			client_cmd(controlled[id], "+attack2")
		}
		else if(get_user_oldbutton(id) & IN_ATTACK2)
		{
			client_cmd(controlled[id], "-attack2")
		}
		if(get_user_button(id) & IN_JUMP)
		{
			client_cmd(controlled[id], "+jump")
		}
		else if(get_user_oldbutton(id) & IN_JUMP)
		{
			client_cmd(controlled[id], "-jump")
		}
		if(get_user_button(id) & IN_DUCK)
		{
			client_cmd(controlled[id], "+duck")
		}
		else if(get_user_oldbutton(id) & IN_DUCK)
		{
			client_cmd(controlled[id], "-duck")
		}
		if(get_user_button(id) & IN_RUN)
		{
			client_cmd(controlled[id], "+speed")
		}
		else if(get_user_oldbutton(id) & IN_RUN)
		{
			client_cmd(controlled[id], "-speed")
		}
		if(get_user_button(id) & IN_USE)
		{
			client_cmd(controlled[id], "+use")
		}
		else if(get_user_oldbutton(id) & IN_USE)
		{
			client_cmd(controlled[id], "-use")
		}
		if(get_user_button(id) & IN_RELOAD)
		{
			client_cmd(controlled[id], "+reload")
		}
		else if(get_user_oldbutton(id) & IN_RELOAD)
		{
			client_cmd(controlled[id], "-reload")
		}
		if(get_user_button(id) & IN_FORWARD)
		{
			client_cmd(controlled[id], "+forward")
		}
		else if(get_user_oldbutton(id) & IN_FORWARD)
		{
			client_cmd(controlled[id], "-forward")
		}
		if(get_user_button(id) & IN_BACK)
		{
			client_cmd(controlled[id], "+back")
		}
		else if(get_user_oldbutton(id) & IN_BACK)
		{
			client_cmd(controlled[id], "-back")
		}
		if(get_user_button(id) & IN_MOVELEFT)
		{
			client_cmd(controlled[id], "+moveleft")
		}
		else if(get_user_oldbutton(id) & IN_MOVELEFT)
		{
			client_cmd(controlled[id], "-moveleft")
		}
		if(get_user_button(id) & IN_MOVERIGHT)
		{
			client_cmd(controlled[id], "+moveright")
		}
		else if(get_user_oldbutton(id) & IN_MOVERIGHT)
		{
			client_cmd(controlled[id], "-moveright")
		}

		new Float:angles[3]
		entity_get_vector(id, EV_VEC_angles, angles)
		angles[0] = - angles[0]
		if(camera[id] > 0)
		{
			new Float:player_origin[3]
			entity_get_vector(controlled[id], EV_VEC_origin, player_origin)
			new Float:origin[3]
			if(get_cvar_num("controlplayers_firstperson") == 1)
			{
				if(get_user_button(id) & IN_FORWARD)
				{
					VelocityByAim(id, 65, origin)
				}
				else
				{
					VelocityByAim(id, 15, origin)
				}
				player_origin[0] = player_origin[0] + origin[0]
				player_origin[1] = player_origin[1] + origin[1]
				player_origin[2] = player_origin[2] + 20.0
			}
			else
			{
				VelocityByAim(id, 30, origin)
				player_origin[0] = player_origin[0] - origin[0]
				player_origin[1] = player_origin[1] - origin[1]
				player_origin[2] = player_origin[2] + 35.0

			}
			entity_set_vector(camera[id], EV_VEC_origin, player_origin)
			entity_set_vector(camera[id], EV_VEC_angles, angles)
			if(get_cvar_num("controlplayers_beams") == 1)
			{
				new origin2[3]
				get_user_origin(controlled[id], origin2, 3)
				message_begin(MSG_ONE, SVC_TEMPENTITY, {0,0,0}, id) 
				write_byte(1) 
				write_short(controlled[id]) 
				write_coord(origin2[0])
				write_coord(origin2[1])
				write_coord(origin2[2])
				write_short(laserbeam)
				write_byte(1) 
				write_byte(1) 
				write_byte(1) 
				write_byte(8) 
				write_byte(0)  
				write_byte(255) 
				write_byte(0) 
				write_byte(0) 
				write_byte(128)  
				write_byte(0) 
				message_end() 
			}
		}

		entity_set_vector(controlled[id], EV_VEC_angles, angles)
		entity_set_int(controlled[id], EV_INT_fixangle, 1) 

		if(!is_user_alive(id))
		{
			entity_set_int(id, EV_INT_iuser1, 0)
			entity_set_int(id, EV_INT_iuser2, controlled[id])
			if(get_cvar_num("controlplayers_beams") == 1)
			{
				new origin2[3]
				get_user_origin(controlled[id], origin2, 3)
				message_begin(MSG_ONE, SVC_TEMPENTITY, {0,0,0}, id) 
				write_byte(17) 
				write_coord(origin2[0])
				write_coord(origin2[1])
				write_coord(origin2[2])
				write_short(laserdot)
				write_byte(8) 
				write_byte(255) 
				message_end() 
			}
		}
	}

	return PLUGIN_CONTINUE
}

public c_slot1(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "slot1")
		client_cmd(controlled[id], "menuselect 1")
		return PLUGIN_HANDLED
	}

	return PLUGIN_HANDLED
}

public c_slot2(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "slot2")
		client_cmd(controlled[id], "menuselect 2")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_slot3(id) 
{
	if(controlled[id] > 0)
	{ 
		client_cmd(controlled[id], "slot3")
		client_cmd(controlled[id], "menuselect 3")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_slot4(id) 
{
	if(controlled[id] > 0)
	{ 
		client_cmd(controlled[id], "slot4")
		client_cmd(controlled[id], "menuselect 4")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_slot5(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "slot5")
		client_cmd(controlled[id], "menuselect 5")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_slot6(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "slot6")
		client_cmd(controlled[id], "menuselect 6")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_slot7(id) 
{
	if(controlled[id] > 0)
	{ 
		client_cmd(controlled[id], "slot7")
		client_cmd(controlled[id], "menuselect 7")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_slot8(id) 
{
	if(controlled[id] > 0)
	{ 
		client_cmd(controlled[id], "slot8")
		client_cmd(controlled[id], "menuselect 8")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_slot9(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "slot9")
		client_cmd(controlled[id], "menuselect 9")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_slot10(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "slot10")
		client_cmd(controlled[id], "menuselect 10")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public c_buy(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "buy")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public c_drop(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "drop")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public c_nightvision(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "nightvision")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public c_lastinv(id) 
{
	if(controlled[id] > 0)
	{ 
		client_cmd(controlled[id], "lastinv")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public c_radio1(id) 
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "radio1")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public c_radio2(id) 
{
	if(controlled[id] > 0)
	{ 
		client_cmd(controlled[id], "radio2")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public c_radio3(id) 
{
	if(controlled[id] > 0)
	{ 
		client_cmd(controlled[id], "radio3")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public spray()
{
	new id = read_data(2)

	if(controlled[id] > 0)
	{
		new origin[3]
		get_user_origin(controlled[id], origin, 3)
		message_begin(MSG_ALL, SVC_TEMPENTITY)
		write_byte(112)
		write_byte(controlled[id])
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_short(0)
		write_byte(1)
		message_end()
	}
}

public flashlight(id)
{
	if(controlled[id] > 0)
	{
		client_cmd(controlled[id], "impulse 100")
	}	
}

public control(id, level, cid) 
{
	if(!cmd_access(id, level, cid, 2)) 
	{
		return PLUGIN_HANDLED
	}

	if(controlled[id] > 0) 
	{
		client_print(id, print_chat, "[C-P] You may only control one at a time.")
		client_print(id, print_console, "[C-P] You may only control one at a time.")
		return PLUGIN_HANDLED
	}

	if(controller[id] > 0) 
	{
		client_print(id, print_chat, "[C-P] You cannot control a player if you are already controlled.")
		client_print(id, print_console, "[C-P] You cannot control a player if you are already controlled.")
		return PLUGIN_HANDLED
	}

	new arg[33]
	read_argv(1, arg, 32)

	new player_id = cmd_target(id, arg, 1)

	if(!player_id) 
	{
		return PLUGIN_HANDLED
	}


	if(player_id == id) 
	{
		client_print(id, print_chat, "[C-P] You already control yourself...")
		client_print(id, print_console, "[C-P] You already control yourself...")
		return PLUGIN_HANDLED
	}

	if(!is_user_alive(player_id)) 
	{
		client_print(id, print_chat, "[C-P] You cannot control a dead player...")
		client_print(id, print_console, "[C-P] You cannot control a dead player...")
		return PLUGIN_HANDLED
	}

	new player_name[32] 
	get_user_name(player_id, player_name, 31) 

	if(controlled[player_id] > 0) 
	{
		client_print(id, print_chat, "[C-P] %s is controlling a player...", player_name)
		client_print(id, print_console, "[C-P] %s is controlling a player...", player_name)
		return PLUGIN_HANDLED
	}

	if(controller[player_id] > 0) 
	{
		new controller_name[32] 
		get_user_name(controller[player_id], controller_name, 31) 
		client_print(id, print_chat, "[C-P] %s is already under %s's control...", player_name, controller_name)
		client_print(id, print_console, "[C-P] %s is already under %s's control...", player_name, controller_name)
		return PLUGIN_HANDLED
	}

	client_print(id, print_chat, "[C-P] %s is under your control.", player_name)
	client_print(id, print_console, "[C-P] %s is under your control.", player_name)

	if(is_user_alive(id))
	{
		camera[id] = create_entity("info_target")
		if(camera[id] > 0)
		{
			entity_set_string(camera[id], EV_SZ_classname, "camera")
			entity_set_int(camera[id], EV_INT_solid, SOLID_NOT) 
			entity_set_int(camera[id], EV_INT_movetype, MOVETYPE_NOCLIP) 
			entity_set_size(camera[id], Float:{0,0,0}, Float:{0,0,0})
			entity_set_model(camera[id], "models/rpgrocket.mdl")
			set_rendering(camera[id], kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)

			new Float:player_origin[3]
			entity_get_vector(player_id, EV_VEC_origin, player_origin)
			entity_set_vector(camera[id], EV_VEC_origin, player_origin)
			new Float:angles[3]
			entity_get_vector(id, EV_VEC_angles, angles)
			angles[0] = - angles[0]
			entity_set_vector(camera[id], EV_VEC_angles, angles)
			attach_view(id, camera[id])
		}
		set_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderTransAlpha, 255)
		set_user_godmode(id, 1)
		set_user_maxspeed(id, -1.0)
	}
	else
	{
		entity_set_int(id, EV_INT_iuser1, 0)
		entity_set_int(id, EV_INT_iuser2, player_id)
	}

	if(get_cvar_num("controlplayers_vision") == 1)
	{
		message_begin(MSG_ONE, gmsgSetFOV, {0,0,0}, player_id)
		write_byte(120)
		message_end()
		set_task(1.0, "delay_blind", player_id)
		message_begin(MSG_ONE, gmsgFade, {0,0,0}, player_id)  
		write_short(1<<12) // fade lasts this long duration  
		write_short(1<<8) // fade lasts this long hold time  
		write_short(1<<0) // fade type IN 
		write_byte(255) // fade red  
		write_byte(0) // fade green  
		write_byte(0) // fade blue    
		write_byte(100) // fade alpha    
		message_end()
	}

	client_cmd(id, "bind 1 c_slot1")
	client_cmd(id, "bind 2 c_slot2")
	client_cmd(id, "bind 3 c_slot3")
	client_cmd(id, "bind 4 c_slot4")
	client_cmd(id, "bind 5 c_slot5")
	client_cmd(id, "bind 6 c_slot6")
	client_cmd(id, "bind 7 c_slot7")
	client_cmd(id, "bind 8 c_slot8")
	client_cmd(id, "bind 9 c_slot9")
	client_cmd(id, "bind 0 c_slot10")

	client_cmd(player_id, "sensitivity 1")

	controlled[id] = player_id
	controller[player_id] = id

	client_cmd(id, "weapon_knife")

	new controller_name[32]
	get_user_name(id, controller_name, 31)
	set_hudmessage(255, 255, 255, -1.0, 0.6, 0, 1.0, 10.0, 0.1, 0.2, 3)
	show_hudmessage(player_id, "%s is using his mind to control you.^nYou can chat with y and u.^nVoicerecord is binded to MOUSE1.", controller_name)


	client_cmd(player_id, "unbindall")
	client_cmd(player_id, "bind TAB +showscores")
	client_cmd(player_id, "bind MOUSE1 +voicerecord")
	client_cmd(player_id, "bind y messagemode")
	client_cmd(player_id, "bind u messagemode2")
	client_cmd(player_id, "-forward")
	client_cmd(player_id, "-back")
	client_cmd(player_id, "-moveleft")
	client_cmd(player_id, "-moveright")
	client_cmd(player_id, "-attack")
	client_cmd(player_id, "-attack2")
	client_cmd(player_id, "-jump")
	client_cmd(player_id, "-duck")
	client_cmd(player_id, "-reload")
	client_cmd(player_id, "-use")

	new victim_id[1] 
	victim_id[0] = player_id

	set_task(1.0, "victim_task", 2000+player_id, victim_id, 1, "b")

	return PLUGIN_HANDLED
}

public victim_task(victim_id[])
{
	new id = victim_id[0]

	client_cmd(id, "unbindall")
	client_cmd(id, "bind TAB +showscores")
	client_cmd(id, "bind MOUSE1 +voicerecord")
	client_cmd(id, "bind y messagemode")
	client_cmd(id, "bind u messagemode2")

	return PLUGIN_CONTINUE
}

public stop_control(id, level, cid) 
{
	if(!cmd_access(id, level, cid, 1)) 
	{
		return PLUGIN_HANDLED
	}

	if(controlled[id] > 0)
	{
		if(camera[id] > 0)
		{	
			remove_entity(camera[id])
			camera[id] = 0
			attach_view(id, id)
		}
		reset(id)
		reset(controlled[id])
		controller[controlled[id]] = 0
		normal_fade(controlled[id])
		controlled[id] = 0
		engclient_cmd(id, "weapon_knife")
		client_cmd(id, "weapon_knife")
		client_print(id, print_chat, "[C-P] You have stopped controlling this player.")
		client_print(id, print_console, "[C-P] You have stopped controlling this player.")
	}

	return PLUGIN_HANDLED
}

public client_disconnect(id)
{
	if(controller[id])
	{
		if(camera[controller[id]] > 0)
		{	
			remove_entity(camera[controller[id]])
			camera[controller[id]] = 0
			attach_view(controller[id], controller[id])
		}
		reset(controller[id])
		controlled[controller[id]] = 0
		engclient_cmd(controller[id], "weapon_knife")
		client_cmd(controller[id], "weapon_knife")
		controller[id] = 0
	}

	return PLUGIN_CONTINUE
}

public death_event() 
{
	new id = read_data(2)

	if(controller[id] > 0)
	{
		if(camera[controller[id]] > 0)
		{	
			remove_entity(camera[controller[id]])
			camera[controller[id]] = 0
			attach_view(controller[id], controller[id])
		}
		reset(id)
		reset(controller[id])
		controlled[controller[id]] = 0
		engclient_cmd(controller[id], "weapon_knife")
		client_cmd(controller[id], "weapon_knife")
		controller[id] = 0
		normal_fade(id)
	}
	if(controlled[id] > 0)
	{
		if(camera[id] > 0)
		{	
			remove_entity(camera[id])
			camera[id] = 0
			attach_view(id, id)
		}
		reset(id)
		reset(controlled[id])
		controller[controlled[id]] = 0
		normal_fade(controlled[id])
		controlled[id] = 0
		engclient_cmd(id, "weapon_knife")
		client_cmd(id, "weapon_knife")
	}

	return PLUGIN_CONTINUE
}

public resethud_event(id)
{
	if(controller[id] > 0)
	{
		if(camera[controller[id]] > 0)
		{	
			remove_entity(camera[controller[id]])
			camera[controller[id]] = 0
			attach_view(controller[id], controller[id])
		}
		reset(id)
		reset(controller[id])
		controlled[controller[id]] = 0
		engclient_cmd(controller[id], "weapon_knife")
		client_cmd(controller[id], "weapon_knife")
		controller[id] = 0
		normal_fade(id)
	}
	if(controlled[id] > 0)
	{
		if(camera[id] > 0)
		{	
			remove_entity(camera[id])
			camera[id] = 0
			attach_view(id, id)
		}
		reset(id)
		reset(controlled[id])
		controller[controlled[id]] = 0
		normal_fade(controlled[id])
		controlled[id] = 0
		engclient_cmd(id, "weapon_knife")
		client_cmd(id, "weapon_knife")
	}

	return PLUGIN_CONTINUE
}

public round_end()
{
	set_task(4.0, "reset_control", 4513250)

	return PLUGIN_CONTINUE
}

public game_restart()
{
	set_task(0.1, "reset_control", 6845150)

	return PLUGIN_CONTINUE
}

public reset_control()
{
	new players[32], inum
	get_players(players, inum)
	for(new i = 0 ; i < inum ; i++)
	{
		if(controller[players[i]] > 0)
		{
			if(camera[controller[players[i]]] > 0)
			{	
				remove_entity(camera[controller[players[i]]])
				camera[controller[players[i]]] = 0
				attach_view(controller[players[i]], controller[players[i]])
			}
			reset(players[i])
			reset(controller[players[i]])
			controlled[controller[players[i]]] = 0
			engclient_cmd(controller[players[i]], "weapon_knife")
			client_cmd(controller[players[i]], "weapon_knife")
			controller[players[i]] = 0
			normal_fade(players[i])
		}
		if(controlled[players[i]] > 0)
		{
			if(camera[players[i]] > 0)
			{	
				remove_entity(camera[players[i]])
				camera[players[i]] = 0
				attach_view(players[i], players[i])
			}
			reset(players[i])
			reset(controlled[players[i]])
			controller[controlled[players[i]]] = 0
			normal_fade(controlled[players[i]])
			controlled[players[i]] = 0
			engclient_cmd(players[i], "weapon_knife")
			client_cmd(players[i], "weapon_knife")
		}
	}
}

public reset(id)
{
	client_cmd(id, "-forward")
	client_cmd(id, "-back")
	client_cmd(id, "-moveleft")
	client_cmd(id, "-moveright")
	client_cmd(id, "-attack")
	client_cmd(id, "-attack2")
	client_cmd(id, "-jump")
	client_cmd(id, "-duck")
	client_cmd(id, "-reload")
	client_cmd(id, "-use")
	if(controlled[id] > 0)
	{
		client_cmd(id, "bind 1 slot1")
		client_cmd(id, "bind 2 slot2")
		client_cmd(id, "bind 3 slot3")
		client_cmd(id, "bind 4 slot4")
		client_cmd(id, "bind 5 slot5")
		client_cmd(id, "bind 6 slot6")
		client_cmd(id, "bind 7 slot7")
		client_cmd(id, "bind 8 slot8")
		client_cmd(id, "bind 9 slot9")
		client_cmd(id, "bind 0 slot10")
		set_rendering(id)
		set_task(1.0, "remove_godmode", id)
	}
	if(task_exists(2000+id))
	{
		remove_task(2000+id)
	}
	if(get_cvar_num("controlplayers_vision") == 1)
	{
		message_begin(MSG_ONE, gmsgSetFOV, {0,0,0}, id)
		write_byte(90)
		message_end()
	}
	client_cmd(id, "exec config.cfg")
	if(is_user_alive(id))
	{
		set_user_maxspeed(id, 250.0)
	}
	else
	{
		entity_set_int(id, EV_INT_iuser1, 3)
		entity_set_int(id, EV_INT_iuser2, 0)
	}
}

public remove_godmode(id)
{
	set_user_godmode(id)
}

public delay_blind(id) 
{
	if(controller[id] > 0) 
	{
		fade_red(id)
	}
}

public screen_fade(id) 
{
	if(controller[id] > 0) 
	{
		fade_red(id)
	}
}

fade_red(id) 
{
	if(get_cvar_num("controlplayers_vision") == 1)
	{
		message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
		write_short(1<<0) // fade lasts this long duration 
		write_short(1<<0) // fade lasts this long hold time 
		write_short(1<<2) // fade type HOLD 
		write_byte( 255 ) // fade red 
		write_byte( 0 ) // fade green 
		write_byte( 0 ) // fade blue  
		write_byte( 100 ) // fade alpha  
		message_end()
	}
}

normal_fade(id)
{
	if(get_cvar_num("controlplayers_vision") == 1)
	{
		message_begin(MSG_ONE, gmsgFade, {0,0,0}, id) 
		write_short(1) 
		write_short(1) 
		write_short(12) 
		write_byte(0) 
		write_byte(0) 
		write_byte(0) 
		write_byte(0) 
		message_end() 
	}
}

public check_weapon(id)
{
	if(controlled[id] > 0)
	{
		client_cmd(id, "weapon_knife")
		set_user_maxspeed(id, -1.0)
	}

	return PLUGIN_CONTINUE
}

public client_kill(id)
{
	if(controller[id] > 0)
	{
		client_print(id, print_chat, "[C-P] You cannot kill yourself when you are controlled.")
		client_print(id, print_console, "[C-P] You cannot kill yourself when you are controlled.")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public plugin_precache() 
{ 
	laserbeam = precache_model("sprites/laserbeam.spr")
	laserdot = precache_model("sprites/laserdot.spr")
	precache_model("models/rpgrocket.mdl")

	return PLUGIN_CONTINUE 
} 
