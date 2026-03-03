/***********************************************************************************
*										    
*	  		Plugin : Advanced - Respawn Menu	
*										    
*	  	            Author : Atomen					    
*										    
*	  		  Version : 2.1 - 15/4/2008
*
*	Plugin Thread : "http://forums.alliedmods.net/showthread.php?t=67801"
*		
*===================================================================================*
*
*    	  		      Description
*    
* My first plugin , Advanced respawn with menu. Has multiple different features.
* Instant respawn on join (defined by cvar). Health on spawn feature
* 17 cvars and more to come to customize. Only works on Counter-Strike and CZ.
* Requires 4 modules , "fakemeta_util", "hamsandwich", "cstrike", "fakemeta".
*
* Advanced menu for each cvar. Also blocks
* abusing of "/respawn" say command. You cannot use it while alive. I made this
* plugin mostly because the were only 2 different respawn plugins out there.
* (This does not count as a deathmatch plugin)				    
*										    
* Halo - Respawn : Made by Emp`	(Though it differs much from this plugin)
*										    
* Respawn Forever : Made by Geesu						    
*
* Last update on "Halo - Respawn" was on 4/2/2007.	
* Last update on "Respawn Forever" was on 2/4/2005.
*				    
* This plugin is using pcvar and new respawn system "Hamsandwich"
*										    
*==================================================================================*
*
*			       Credits	    	    
*
*	     -Exolent : Recived a much needed help from him !
*
*	     -Arkshine : Pointing out that i should use if statement
*
*	     -G-Dog : Helped me with multiple "cs_get_user_team" command
*
*	     -v3x : Got help from his plugin "Awp Glow"
*
*	     -Geesu : Used his code for the "/respawn" command
*
*	     -MeRcyLeZZ : Helped me alot with the menus !
*
*	     -[FTW]-S.W.A.T / vittu : Code for the spawn effect
*
*	     -Vittu : Ham respawn function and recommending other team function
*
*==================================================================================*
*										    
* Changelog :
* V 2.1 - Addition Update
* - Fixed menu comes up when plugin is disabled
* - Fixed message displayed even if dead
* - Fixed problem with server cvar
* - Added amx_respawn_punish cvar/menu
* - Added amx_respawn_click cvar/menu
* - Added additional checks on spawn
* - Changed Admin flag to "u" for menu access
* - Changed position of the hudmessages
* - Changed chat detecting
*
* V 2.0 - Performance Update
* - Improved performance/stability
* - Added a lot more use of hamsandwich module
* - Added block for the say command
* - Added more checks to avoid problems
* - Renamed some functions to more appropriate names
* - Removed a lot of "not needed" functions
* - Removed not needed variables
* - Removed all bugs/problems
* - Fixed a crash whom occured on respawn
* - Fixed a pcvar problem with toggle_say
* - Fixed so less resources is used
* - Fixed amx_respawn_armor menu
* - Fixed code smaller
* - Changed the spawn effect framerate
* - Changed some commands/functions
* - Changed a lot of checks
*
* V 1.5c - Update || 10/3/2008
* - Fixed Crash problem
* - Added Plugin Tracker
* - Added *_kill_money cvar/menu
*
* V 1.5b - Small addition
* - Added more options for *_abuse
*
* V 1.5a - Bug/Problem Update
* - Fixed issue with money system
* - Fixed 3 bugs/problems
* - Fixed "/respawn"
* - Added cstrike module for better detecting
*
* V 1.5 - Never released
* - An important update on the menus !
* - Reduced numbers of "set_task()"
* - Fixed problems with menus
* - Added money system, off by default
* - Added amx_respawn_money cvar/menu
* - Added amx_respawn_amount cvar/menu
* - Added fakemeta module for respawn support
*
* V 1.4 - Important Update
* - Changed respawn method to hamsandwich
* - Fixed Weapon related Menu
* - Added amx_respawn_health cvar/menu
* - Renamed amx_respawn_say to *_abuse
*
* V 1.3a - Small Update
* - Added amx_respawn_say cvar/menu
*
* V 1.3
* - Removed fun module
* - Renamed main menu
* - Added sound effect on spawn
* - Added amx_respawn_effect cvar/menu
* - Added amx_respawn_armor cvar/menu
*	
* V 1.2
* - Optimized code
*
* V 1.1
* - Removed cstrike module thanks to X-Olent
*
* V 1.0
* - Initial release
*
*==================================================================================*
*										    
*			    Menu Command :					    
*										    
*			   amx_respawn_menu					    
*										    
*			Write in console, Requires				    
*		       ADMIN_MENU access (flag "u")   
*										    
*										    
************************************************************************************
*										    
*	CVARS Spawn Related :							    
*										    
*	amx_respawn	   "1"	   //Toggles the plugin on/off		    
*	amx_respawn_delay  "1"	   //Delay until respawn upon death
*	amx_respawn_effect "0"	   //Respawn effect	
*	amx_respawn_abuse  "1"	   //0=Disabled 1=only dead 2=Say "/respawn" alive
*	amx_respawn_health "0"	   //Health on spawn , 0 = 100 hp
*	amx_respawn_click  "0"	   //Respawn by click(+attack)
*										    
*										    
************************************************************************************
*										    
*	CVARS Protection Related :						    
*										    
*    amx_respawn_protection 	    "1"	//Toggles spawn protection on/off	    
*    amx_respawn_protection_time    "3"	//Toggles how long you are protected	    
*    amx_respawn_protection_glow    "1"	//Toggles Protection Glow		    
*    amx_respawn_protection_message "1"	//Toggles spawn protection message on/off
*										    
*				
************************************************************************************
*										    
*	CVARS Weapon Related :							    
*									    	    
*	amx_respawn_pistol "1"		//Respawn with a pistol or not		    
*	amx_respawn_ammo   "1"		//Respawn with full ammo on the pistol	 
*	amx_respawn_kevlar "1"		//Respawn with kevlar= 1 ||Kevlar+Helmet = 2
*	amx_respawn_punish "0"		//Remove the users weapon on tk
*										    
*										    
************************************************************************************
*										    
*	CVARS Money Related :							    
*									    	    
*	amx_respawn_money      "1"	//Recieve money on each respawn,0 by default
*	amx_respawn_amount     "600"	//How much money , 600 by default
*	amx_respawn_kill_money "200"	//Add money on frag, Default 300 + "200"
*										    
*										    
***********************************************************************************/
#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>

new const PLUGIN_NAME[] = "Advanced - Respawn Menu"
new const PLUGIN_AUTHOR[] = "Atomen"
new VERSION[] = {"2.1 Menu"}

#define MAX_PLAYERS 32
#define FM_MONEY_OFFSET 115
#define Keysmenu (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
#define fm_get_user_money(%1) get_pdata_int(%1, FM_MONEY_OFFSET)

new iColorT[4]  = { 255, 100, 100, 255 }
new iColorCT[4] = { 100, 100, 255, 255 }

new toggle_plugin, toggle_click, toggle_effect,toggle_delay,toggle_say,toggle_health
new toggle_sp,toggle_sp_time,toggle_sp_glow,toggle_sp_text
new toggle_money,toggle_amount,toggle_kill_money, toggle_punish
new toggle_mode,toggle_ammo,toggle_kevlar

new bool:g_originset[33], bool:g_HasClicked[33]

new Float:g_origin[33][3];
new g_iOldMoney[MAX_PLAYERS + 1], g_aOldMoney[MAX_PLAYERS + 1]

new g_spriteFlare, SayText, mp_tkpunish

//=================================[ Register Plugin ]==========================

public plugin_init()
{
	//Register Plugin
	register_plugin(PLUGIN_NAME, VERSION, PLUGIN_AUTHOR)

	//Events
	RegisterHam(Ham_Killed, "player", "fwd_Ham_Killed_post", 1)
	register_event( "TeamInfo", "join_team", "a")

	register_forward(FM_CmdStart,"fw_CmdStart")
	RegisterHam(Ham_Spawn, "player", "fwd_Ham_Spawn_post", 1)

	//Main Menu
	register_menu("Respawn Menu", Keysmenu, "respawn_menu")

	//Respawn Menus
	register_menu("Spawn Related Menu", Keysmenu, "respawn_related_menu")
	register_menu("amx_respawn Menu", Keysmenu, "amx_respawn_menu")
	register_menu("amx_respawn_click Menu", Keysmenu, "amx_respawn_click_menu")
	register_menu("amx_respawn_say Menu", Keysmenu, "amx_respawn_say_menu")
	register_menu("amx_respawn_effect Menu", Keysmenu, "amx_respawn_effect_menu")
	register_menu("amx_respawn_delay Menu", Keysmenu, "amx_respawn_delay_menu")
	register_menu("amx_respawn_health Menu", Keysmenu, "amx_respawn_health_menu")

	//Protection Menus
	register_menu("Protection Related Menu", Keysmenu, "protection_related_menu")
	register_menu("amx_respawn_protection menu", Keysmenu, "protection_menu")
	register_menu("amx_respawn_protection_time menu", Keysmenu, "protection_time_menu")
	register_menu("amx_respawn_protection_glow menu", Keysmenu, "protection_glow_menu")
	register_menu("amx_respawn_protection_message menu", Keysmenu, "protection_message_menu")

	//Weapon Menus
	register_menu("Weapon Related Menu", Keysmenu, "weapon_related_menu")
	register_menu("amx_respawn_pistol Menu", Keysmenu, "amx_pistol_menu")
	register_menu("amx_respawn_ammo Menu", Keysmenu, "amx_ammo_menu")
	register_menu("amx_respawn_armor menu", Keysmenu, "armor_menu")
	register_menu("amx_respawn_punish Menu", Keysmenu, "amx_punish_menu")

	//Money Menus
	register_menu("Money Related Menu", Keysmenu, "money_related_menu")
	register_menu("amx_respawn_money Menu", Keysmenu, "amx_respawn_money_menu")
	register_menu("amx_respawn_amount Menu", Keysmenu, "amx_respawn_amount_menu")
	register_menu("amx_respawn_kill_money Menu", Keysmenu, "amx_respawn_kill_money_menu")

	//Command
	register_concmd("amx_respawn_menu", "RespawnMenu", ADMIN_MENU, "Respawn Menu")

	//Other
	register_cvar("arm_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	mp_tkpunish = get_cvar_pointer("mp_tkpunish")
	
	//Pcvars
	toggle_plugin = register_cvar("amx_respawn", "1")
	toggle_click = register_cvar("amx_respawn_click", "0")
	toggle_delay = register_cvar("amx_respawn_delay", "1")
	toggle_effect = register_cvar("amx_respawn_effect", "0")
	toggle_say = register_cvar("amx_respawn_abuse", "1")
	toggle_health = register_cvar("amx_respawn_health", "0")

	toggle_sp = register_cvar("amx_respawn_protection", "1")
	toggle_sp_time = register_cvar("amx_respawn_protection_time", "3")
	toggle_sp_glow = register_cvar("amx_respawn_protection_glow", "1")
	toggle_sp_text = register_cvar("amx_respawn_protection_message", "1")

	toggle_mode = register_cvar("amx_respawn_pistol", "1")
	toggle_ammo = register_cvar("amx_respawn_ammo", "1")
	toggle_kevlar = register_cvar("amx_respawn_armor", "1")
	toggle_punish = register_cvar("amx_respawn_punish", "0")

	toggle_money = register_cvar("amx_respawn_money", "0")
	toggle_amount = register_cvar("amx_respawn_amount", "600")
	toggle_kill_money = register_cvar("amx_respawn_kill_money", "200")

	register_clcmd("say /respawn","on_Chat")
	register_clcmd("say_team /respawn","on_Chat")

	SayText = get_user_msgid("SayText");
}

public plugin_cfg()
{
	set_cvar_string("mp_tkpunish", "0")
}

//=================================[ Precache Files ]==========================

public plugin_precache()
{
	g_spriteFlare = precache_model("sprites/b-tele1.spr")
	precache_sound("debris/beamstart2.wav")
}

//=================================[ Respawn Command ]==========================

public on_Chat(iVictimID)
{
	do_Chat(iVictimID)
	return 1;
}

public do_Chat(iVictimID)
{
	if(!get_pcvar_num(toggle_plugin))
	{
		green_print(iVictimID, "Respawn Plugin is currently Disabled")
	}

	else
	{
		new alive = is_user_alive(iVictimID)
		new CsTeams:team = cs_get_user_team(iVictimID)
		new checking = get_pcvar_num(toggle_say)
			
		if(!alive)
		{
			if( team == CS_TEAM_T || team == CS_TEAM_CT && checking == 1 || checking == 2)
				set_task(get_pcvar_float(toggle_delay),"spawnning",iVictimID)

			else if( team == CS_TEAM_SPECTATOR )
				green_print(iVictimID, "You cannot respawn as an spectator")
		}
			
		else if(alive)
		{
			if(checking == 1)
				green_print(iVictimID, "Only dead players are allowed to respawn !")

			else if(checking == 2)
			{
				if( team == CS_TEAM_T || team == CS_TEAM_CT)
				{
					if(g_originset[iVictimID] == true)
					{
						g_origin[iVictimID][2] = g_origin[iVictimID][2] + 10;
						set_pev(iVictimID, pev_origin, g_origin[iVictimID])

						green_print(iVictimID, "You have been moved to your last spawn")
					}
				}

				else if( team == CS_TEAM_SPECTATOR)
					green_print(iVictimID, "You cannot respawn as an spectator")
			}
		}
	}
}

//=================================[ Block Useless ]==========================

public fwdStartFrame()
{
	if(get_pcvar_num(toggle_punish))
		set_pcvar_num(mp_tkpunish, 0)
}

//=================================[ Register Spawn ]==========================

public fwd_Ham_Spawn_post(iVictimID) 
{
	if(get_pcvar_num(toggle_plugin) >= 1)
	{
		if(is_user_alive(iVictimID))
		{
			if(get_pcvar_num(toggle_say) == 2)
			{
				pev(iVictimID, pev_origin, g_origin[iVictimID])
				g_originset[iVictimID] = true
			}

			if(get_pcvar_num(toggle_health) >= 1)
				set_pev(iVictimID, pev_health, get_pcvar_float(toggle_health))

			if(get_pcvar_num(toggle_sp) >= 1)
			{
				set_pev(iVictimID, pev_takedamage, 0.0)
	
				if(get_pcvar_num(toggle_sp_glow) >= 1)
				{
					new CsTeams:team = cs_get_user_team(iVictimID)

					if( team == CS_TEAM_CT)  
						fm_set_rendering(iVictimID, kRenderFxGlowShell, iColorCT[0], iColorCT[1], iColorCT[2],  kRenderNormal, iColorCT[3])
		
					else if( team == CS_TEAM_T)
						fm_set_rendering(iVictimID, kRenderFxGlowShell, iColorT[0], iColorT[1], iColorT[2],  kRenderNormal, iColorT[3])
				}
				set_task( 0.3, "spawn_protection_message", iVictimID)
				set_task(get_pcvar_float(toggle_sp_time), "remove_spawn_protection", iVictimID)
			}
		}
	}
}

public fw_CmdStart(iVictimID, uc_handle)
{
	if (get_pcvar_num(toggle_plugin) && get_pcvar_num(toggle_click))
	{
		if(is_user_alive(iVictimID)) return FMRES_IGNORED
		new iButtons = get_uc(uc_handle,UC_Buttons)

		if((iButtons & IN_ATTACK))
		{
			if(g_HasClicked[iVictimID] == false)
			{
				new CsTeams:team = cs_get_user_team(iVictimID)
				if( team == CS_TEAM_T || team == CS_TEAM_CT)
				{
					g_HasClicked[iVictimID] = true
					set_task(get_pcvar_float(toggle_delay),"spawnning",iVictimID)
				}
			}
		}
	}
	return FMRES_IGNORED
}

//=================================[ Trigger Respawn ]==========================

public fwd_Ham_Killed_post(iVictimID, attacker) 
{
	if(get_pcvar_num(toggle_plugin) >= 1)
	{
		if( !is_user_connected( iVictimID ) )
			return 0

		else
		{
			g_iOldMoney[iVictimID] = fm_get_user_money(iVictimID)
			g_aOldMoney[attacker] = fm_get_user_money(attacker)

			if(get_pcvar_num(mp_tkpunish))
				set_pcvar_num(mp_tkpunish, 0)

			if(attacker != iVictimID && get_user_team(attacker) == get_user_team(iVictimID) && get_pcvar_num(toggle_punish))
			{
				fm_strip_user_weapons(attacker)
				set_hudmessage( 255, 0, 0, 0.30, 0.50, 0, 5.0, 3.0 , 0.1, 0.2, 3 )
				show_hudmessage( iVictimID, "[AMXX] TK is not allowed !")
			}

			else
				money_on_kill(attacker)

			if(get_pcvar_num(toggle_click))
			{
				set_hudmessage( 255, 0, 0, 0.30, 0.50, 0, 90.0, 3.0 , 0.1, 0.2, 3 )
				show_hudmessage( iVictimID, "[AMXX] Press attack to Respawn")
			}

			else if(get_pcvar_num(toggle_delay) < 1)
			{
				set_pcvar_num(toggle_delay, 1)
				set_task(get_pcvar_float(toggle_delay),"spawnning",iVictimID)
			}

			else
				set_task(get_pcvar_float(toggle_delay),"spawnning",iVictimID)
		}
	}
	return HAM_IGNORED;
}

//=================================[ Money on Kill ]==========================

public money_on_kill(attacker)
{
	if(is_user_connected(attacker))
		if(get_pcvar_num(toggle_kill_money) > 0)
			fm_set_user_money(attacker, g_aOldMoney[attacker] += get_pcvar_num(toggle_kill_money), 1)
}

//=================================[ Respawn on Join ]==========================

public join_team()
{
	if(get_pcvar_num(toggle_plugin) >= 1)
	{
		new iVictimID = read_data(1)
		static user_team[32]
    
		read_data(2, user_team, 31)  
		new alive = is_user_alive(iVictimID)  
    
		if(!is_user_connected(iVictimID))
			return 0;
    
		switch(user_team[0])
		{
			case 'C':  
			{
				if(!alive)
					set_task(get_pcvar_float(toggle_delay),"spawnning",iVictimID);
			}
            
			case 'T':
			{ 
				if(!alive)
					set_task(get_pcvar_float(toggle_delay),"spawnning",iVictimID); 
        		}
        
			case 'S':  
			{
				green_print(iVictimID, "You have to join CT or Terrorist to respawn")
			}
        	}
	}
	return 0;
}

//=================================[ Respawn upon Death ]==========================

public spawnning(iVictimID) 
{
	ExecuteHamB(Ham_CS_RoundRespawn, iVictimID)
	green_print(iVictimID, "You have been respawned")

	cvar_loads(iVictimID)

	if(get_pcvar_num(toggle_click))
		g_HasClicked[iVictimID] = false

	if(get_pcvar_num(toggle_sp) >= 1)
		set_task( 0.1 , "spawn_protection", iVictimID)
}

//=================================[ Check cvar Features ]==========================

public cvar_loads(iVictimID)
{
	if(get_pcvar_num(toggle_mode) < 1)
	{
		fm_strip_user_weapons(iVictimID)
		fm_give_item(iVictimID, "weapon_knife")
	}

	else
	{
		if(get_pcvar_num(toggle_ammo) >= 1)
		{

			if(cs_get_user_team(iVictimID) == CS_TEAM_T)
				ExecuteHam(Ham_GiveAmmo, iVictimID, 80, "9mm", 120)
			else
				ExecuteHam(Ham_GiveAmmo, iVictimID, 76, "45acp", 100)
		}
	}
	armoury_check(iVictimID)
}

//=================================[ Armor Check ]==========================

public armoury_check(iVictimID)
{
	respawn_check(iVictimID)
	new check = get_pcvar_num(toggle_kevlar)

	if(check == 1)
		fm_give_item(iVictimID, "item_kevlar")

	else if(check == 2)
		fm_give_item(iVictimID, "item_assaultsuit")
}

//=================================[ Respawn Check ]==========================

public respawn_check(iVictimID)
{
	new CsTeams:team = cs_get_user_team(iVictimID)

	if(get_pcvar_num(toggle_say) == 2)
	{
		pev(iVictimID, pev_origin, g_origin[iVictimID])
		g_originset[iVictimID] = true
	}

	if(get_pcvar_num(toggle_money))
		if( team == CS_TEAM_T || team == CS_TEAM_CT)
			fm_set_user_money(iVictimID, g_iOldMoney[iVictimID] += get_pcvar_num(toggle_amount), 1)

	if(get_pcvar_num(toggle_health) >= 1)
		set_pev(iVictimID, pev_health, get_pcvar_float(toggle_health))

	if(get_pcvar_num(toggle_effect) == 1)
	{
		new origin[3]
		get_user_origin(iVictimID, origin)
		emit_sound(iVictimID, CHAN_STATIC, "debris/beamstart2.wav", 0.6, ATTN_NORM, 0, PITCH_NORM)

		explosion_effect(origin)
	}
}

//=================================[ Spawn Effect ]==========================

public explosion_effect(vec1[3])
{
	// Value
	new radius = 300

	// Explosion 2
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(12)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_byte(188)
	write_byte(10)
	message_end()

	// Explosion
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
	write_byte(3)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short(g_spriteFlare)
	write_byte(radius/9)
	write_byte(15)
	write_byte(0)
	message_end()
}

//=================================[ Spawn Protection - Feature ]==========================

public spawn_protection(iVictimID)
{
	set_pev(iVictimID, pev_takedamage, 0.0)
	
	if(get_pcvar_num(toggle_sp_glow) >= 1)
	{
		new CsTeams:team = cs_get_user_team(iVictimID)

		if( team == CS_TEAM_CT)  
			fm_set_rendering(iVictimID, kRenderFxGlowShell, iColorCT[0], iColorCT[1], iColorCT[2],  kRenderNormal, iColorCT[3])
		
		else if( team == CS_TEAM_T)
			fm_set_rendering(iVictimID, kRenderFxGlowShell, iColorT[0], iColorT[1], iColorT[2],  kRenderNormal, iColorT[3])
	}
	set_task( 0.3, "spawn_protection_message", iVictimID)
	set_task(get_pcvar_float(toggle_sp_time), "remove_spawn_protection", iVictimID)
}

public remove_spawn_protection(iVictimID)
{
	new Float:val
	pev(iVictimID, pev_takedamage, val)

	if(val == 0.0)
		set_pev(iVictimID, pev_takedamage, 1.0)

	if(get_pcvar_num(toggle_sp_glow) >= 1)
		fm_set_rendering(iVictimID, kRenderFxNone, 255,255,255, kRenderNormal, 255)
}

public spawn_protection_message(iVictimID)
{
	if(get_pcvar_num(toggle_sp_text))
	{
		new time
		time = get_pcvar_num(toggle_sp_time)	
			
		set_hudmessage( 255, 0, 0, 0.35, 0.50, 0, 6.0, 3.0 , 0.1, 0.2, 3 );
		show_hudmessage( iVictimID, "[AMXX] You have spawn protection for %d seconds", time)	
	}
}

//================================[ Create Main Menu ]=================================

public RespawnMenu(id)
{
	if(get_pcvar_num(toggle_plugin))
	{
		new theRespawnMenu[255]
		formatex(theRespawnMenu, 254, "\rARN - Main Menu^n^n\r1.\w Spawn Related^n\r2.\w Protection Related^n\r3.\w Weapon Related^n^n\r8.\d Back^n\r0.\w Exit")
		show_menu(id, Keysmenu, theRespawnMenu, 20, "Respawn Menu")
	}
	return 1;
}

//============================[ Menu Options - Main menu ]==========================

public respawn_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			RelatedMenu(id)
		}

		case 1:
		{
			ProtectionMenu(id)
		}

		case 2:
		{
			WeaponMenu(id)
		}

		case 7:
		{
			RespawnMenu(id)
		}

		case 9:
		{
			green_print(id, "Respawn Menu closed")
		}

		default:
		{
			RespawnMenu(id)
		}
	}     
}

//=============================[ Create Spawn Related menu ]=================================

public RelatedMenu(id) 
{
    new theRelatedMenu[255]
    formatex(theRelatedMenu, 254, "\rARN - Spawn Related Menu^n^n\r1.\w amx_respawn^n\r2.\w amx_respawn_delay^n\r3.\w amx_respawn_effect^n\r4.\w amx_respawn_abuse^n\r5.\w amx_respawn_health^n\r6.\w amx_respawn_click^n^n\r8.\w Back^n\r9.\w Next^n\r0.\w Exit")
    show_menu(id, Keysmenu, theRelatedMenu, 20, "Spawn Related Menu")
   
    return 1;
}

//==========================[ Menu Options - Spawn Related menu ]==========================

public respawn_related_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			AmxRespawn(id)
		}

		case 1:
		{
			AmxRespawnDelay(id)
		}

		case 2:
		{
			AmxRespawnEffect(id)
		}

		case 3:
		{
			AmxRespawnSay(id)
		}

		case 4:
		{
			AmxRespawnHealth(id)
		}

		case 5:
		{
			AmxClick(id)
		}

		case 7:
		{
			RespawnMenu(id)
		}

		case 8:
		{
			MoneyMenu(id)
		}

		case 9:
		{
			green_print(id, "Spawn Related Menu closed")
		}

		default:
		{
			RelatedMenu(id)
		}
	}     
}

//=============================[ Create amx_respawn Menu ]=================================

public AmxRespawn(id)
{
	//Create Menu - amx_respawn
	new theRespawn[300], maxlen = sizeof theRespawn - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_plugin)
   
	format(theRespawn, maxlen, "\rARN - Respawn Related Menu || \yamx_respawn Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(theRespawn, maxlen, "%s\r1. \dOn^n", theRespawn)
        	format(theRespawn, maxlen, "%s\r2. \wOff^n", theRespawn)
	} 
	else 
	{
        	format(theRespawn, maxlen, "%s\r1. \wOn^n", theRespawn)
        	format(theRespawn, maxlen, "%s\r2. \dOff^n", theRespawn)
	}
   
	format(theRespawn, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theRespawn)
	show_menu(id, Keysmenu, theRespawn, 20, "amx_respawn Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn menu ]==========================

public amx_respawn_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_plugin, 1)
			AmxRespawn(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_plugin, 0)
			AmxRespawn(id)
		}

		case 7:
		{
			RelatedMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn menu closed")
		}

		default:
		{
			AmxRespawn(id)
		}
	}     
}

//=============================[ Create amx_respawn_click Menu ]=================================

public AmxClick(id)
{
	//Create Menu - amx_respawn_click
	new theRespawn[300], maxlen = sizeof theRespawn - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_click)
   
	format(theRespawn, maxlen, "\rARN - Respawn Related Menu || \yamx_respawn_click Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(theRespawn, maxlen, "%s\r1. \dOn^n", theRespawn)
        	format(theRespawn, maxlen, "%s\r2. \wOff^n", theRespawn)
	} 
	else 
	{
        	format(theRespawn, maxlen, "%s\r1. \wOn^n", theRespawn)
        	format(theRespawn, maxlen, "%s\r2. \dOff^n", theRespawn)
	}
   
	format(theRespawn, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theRespawn)
	show_menu(id, Keysmenu, theRespawn, 20, "amx_respawn_click Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn menu ]==========================

public amx_respawn_click_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_click, 1)
			AmxClick(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_click, 0)
			AmxClick(id)
		}

		case 7:
		{
			RelatedMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_click menu closed")
		}

		default:
		{
			AmxClick(id)
		}
	}     
}

//=============================[ Create amx_respawn_abuse Menu ]=================================

public AmxRespawnSay(id)
{
	//Create Menu - amx_respawn_abuse
	new theSay[300], maxlen = sizeof theSay - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_say)
   
	format(theSay, maxlen, "\rARN - Respawn Related Menu || \yamx_respawn_abuse Cvar : %d^n^n", status)

	if (status == 0) 
	{
        	format(theSay, maxlen, "%s\r1. \dOff^n", theSay)
       		format(theSay, maxlen, "%s\r2. \wOnly while dead^n", theSay)
        	format(theSay, maxlen, "%s\r3. \wAlive and dead^n", theSay)
	}

	else if (status == 1) 
	{
        	format(theSay, maxlen, "%s\r1. \wOff^n", theSay)
       		format(theSay, maxlen, "%s\r2. \dOnly while dead^n", theSay)
        	format(theSay, maxlen, "%s\r3. \wAlive and dead^n", theSay)
	} 

	else if (status == 2) 
	{
        	format(theSay, maxlen, "%s\r1. \wOff^n", theSay)
       		format(theSay, maxlen, "%s\r2. \wOnly while dead^n", theSay)
        	format(theSay, maxlen, "%s\r3. \dAlive and dead^n", theSay)
	}

	else
	{
        	format(theSay, maxlen, "%s\r1. \wOff^n", theSay)
       		format(theSay, maxlen, "%s\r2. \wOnly while dead^n", theSay)
        	format(theSay, maxlen, "%s\r3. \wAlive and dead^n", theSay)
	}
   
	format(theSay, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theSay)
	show_menu(id, Keysmenu, theSay, 20, "amx_respawn_say Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_abuse menu ]==========================

public amx_respawn_say_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_say, 0)
			AmxRespawnSay(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_say, 1)
			AmxRespawnSay(id)
		}

		case 2:
		{
			set_pcvar_num(toggle_say, 2)
			AmxRespawnSay(id)
		}

		case 7:
		{
			RelatedMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_abuse menu closed")
		}

		default:
		{
			AmxRespawnSay(id)
		}
	}     
}

//=============================[ Create amx_respawn_effect Menu ]=================================

public AmxRespawnEffect(id)
{
	//Create Menu - amx_respawn_effect
	new theEffect[300], maxlen = sizeof theEffect - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_effect)
   
	format(theEffect, maxlen, "\rARN - Respawn Related Menu || \yamx_respawn_effect Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(theEffect, maxlen, "%s\r1. \dOn^n", theEffect)
        	format(theEffect, maxlen, "%s\r2. \wOff^n", theEffect)
	} 
	else 
	{
        	format(theEffect, maxlen, "%s\r1. \wOn^n", theEffect)
        	format(theEffect, maxlen, "%s\r2. \dOff^n", theEffect)
	}
   
	format(theEffect, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theEffect)
	show_menu(id, Keysmenu, theEffect, 20, "amx_respawn_effect Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_effect menu ]==========================

public amx_respawn_effect_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_effect, 1)
			AmxRespawnEffect(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_effect, 0)
			AmxRespawnEffect(id)
		}

		case 7:
		{
			RelatedMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_effect menu closed")
		}

		default:
		{
			AmxRespawnEffect(id)
		}
	}     
}

//=============================[ Create amx_respawn_delay Menu ]=================================

public AmxRespawnDelay(id)
{
	//Create Menu - amx_respawn_delay
	new theRespawnDelay[300], maxlen = sizeof theRespawnDelay - 1
   
	//Create integer to display cvar value
	new delay = get_pcvar_num(toggle_delay)
   
	format(theRespawnDelay, maxlen, "\rARN - Spawn Related Menu || \yamx_respawn_delay Cvar : %d^n^n", delay)
   
	if (delay == 1) 
	{
       		format(theRespawnDelay, maxlen, "%s\r1. \d1 second delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r2. \w3 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r3. \w5 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r4. \w10 seconds delay^n", theRespawnDelay)
	}

	else if (delay == 3)
	{
       		format(theRespawnDelay, maxlen, "%s\r1. \w1 second delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r2. \d3 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r3. \w5 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r4. \w10 seconds delay^n", theRespawnDelay)
	}

	else if (delay == 5)
	{
       		format(theRespawnDelay, maxlen, "%s\r1. \w1 second delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r2. \w3 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r3. \d5 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r4. \w10 seconds delay^n", theRespawnDelay)
	}

	else if (delay == 10)
	{
       		format(theRespawnDelay, maxlen, "%s\r1. \w1 second delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r2. \w3 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r3. \w5 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r4. \d10 seconds delay^n", theRespawnDelay)
	}

	else
	{
       		format(theRespawnDelay, maxlen, "%s\r1. \w1 second delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r2. \w3 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r3. \w5 seconds delay^n", theRespawnDelay)
        	format(theRespawnDelay, maxlen, "%s\r4. \w10 seconds delay^n", theRespawnDelay)
	}
   
	format(theRespawnDelay, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theRespawnDelay)
	show_menu(id, Keysmenu, theRespawnDelay, 20, "amx_respawn_delay Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_delay menu ]==========================

public amx_respawn_delay_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_delay, 1)
			AmxRespawnDelay(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_delay, 3)
			AmxRespawnDelay(id)
		}

		case 2:
		{
			set_pcvar_num(toggle_delay, 5)
			AmxRespawnDelay(id)
		}

		case 3:
		{
			set_pcvar_num(toggle_delay, 10)
			AmxRespawnDelay(id)
		}

		case 7:
		{
			RelatedMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_delay menu closed")
		}

		default:
		{
			AmxRespawnDelay(id)
		}
	}     
}

//=============================[ Create amx_respawn_health Menu ]=================================

public AmxRespawnHealth(id)
{
	//Create Menu - amx_respawn_health
	new theHealth[300], maxlen = sizeof theHealth - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_health)
   
	format(theHealth, maxlen, "\rARN - Spawn Related Menu || \yamx_respawn_health Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(theHealth, maxlen, "%s\r1. \d1 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r2. \w35 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r3. \w70 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r4. \w100 Health on Spawn^n", theHealth)
	}

	else if (status == 35)
	{
       		format(theHealth, maxlen, "%s\r1. \w1 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r2. \d35 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r3. \w70 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r4. \w100 Health on Spawn^n", theHealth)
	}

	else if (status == 70)
	{
       		format(theHealth, maxlen, "%s\r1. \w1 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r2. \w35 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r3. \d70 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r4. \w100 Health on Spawn^n", theHealth)
	}

	else if (status == 0)
	{
       		format(theHealth, maxlen, "%s\r1. \w1 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r2. \w35 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r3. \w70 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r4. \d100 Health on Spawn^n", theHealth)
	}

	else
	{
       		format(theHealth, maxlen, "%s\r1. \w1 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r2. \w35 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r3. \w70 Health on Spawn^n", theHealth)
        	format(theHealth, maxlen, "%s\r4. \w100 Health on Spawn^n", theHealth)
	}
   
	format(theHealth, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theHealth)
	show_menu(id, Keysmenu, theHealth, 20, "amx_respawn_health Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_health menu ]==========================

public amx_respawn_health_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_health, 1)
			AmxRespawnHealth(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_health, 35)
			AmxRespawnHealth(id)
		}

		case 2:
		{
			set_pcvar_num(toggle_health, 70)
			AmxRespawnHealth(id)
		}

		case 3:
		{
			set_pcvar_num(toggle_health, 0)
			AmxRespawnHealth(id)
		}

		case 7:
		{
			RelatedMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_health menu closed")
		}

		default:
		{
			AmxRespawnHealth(id)
		}
	}     
}

//=============================[ Money Related menu ]=================================

public MoneyMenu(id)
{
    new theMoney[255]
    formatex(theMoney, 254, "\rARN - Money Related Menu^n^n\r1.\w amx_respawn_money^n\r2.\w amx_respawn_amount^n\r3.\w amx_respawn_kill_money^n^n\r8.\w Back^n\r0.\w Exit")
    show_menu(id, Keysmenu, theMoney, 20, "Money Related Menu")
   
    return 1;
}

//==========================[ Menu Options - Money Related menu ]==========================

public money_related_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			AmxMoney(id)
		}

		case 1:
		{
			AmxAmount(id)
			AmxAmount(id)
		}

		case 2:
		{
			AmxKill(id)
		}

		case 7:
		{
			RelatedMenu(id)
		}

		case 9:
		{
			green_print(id, "Money Related Menu closed")
		}

		default:
		{
			MoneyMenu(id)
		}
	}
}

//=============================[ Create amx_respawn_money Menu ]=================================

public AmxMoney(id)
{
	//Create Menu - amx_respawn_money
	new theBig[300], maxlen = sizeof theBig - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_money)
   
	format(theBig, maxlen, "\rARN - Money Related Menu || \yamx_respawn_money Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(theBig, maxlen, "%s\r1. \dOn^n", theBig)
        	format(theBig, maxlen, "%s\r2. \wOff^n", theBig)
	} 
	else 
	{
        	format(theBig, maxlen, "%s\r1. \wOn^n", theBig)
        	format(theBig, maxlen, "%s\r2. \dOff^n", theBig)
	}
   
	format(theBig, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theBig)
	show_menu(id, Keysmenu, theBig, 20, "amx_respawn_money Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_money menu ]==========================

public amx_respawn_money_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_money, 1)
			AmxMoney(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_money, 0)
			AmxMoney(id)
		}

		case 7:
		{
			MoneyMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_money menu closed")
		}

		default:
		{
			AmxMoney(id)
		}
	}     
}

//=============================[ Create amx_respawn_amount Menu ]=================================

public AmxAmount(id)
{
	//Create Menu - amx_respawn_amount
	new theAmount[300], maxlen = sizeof theAmount - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_amount)
   
	format(theAmount, maxlen, "\rARN - Money Related Menu || \yamx_respawn_amount Cvar : %d^n^n", status)
   
	if (status == 600) 
	{
       		format(theAmount, maxlen, "%s\r1. \d600 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r2. \w1200 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r3. \w2500 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r4. \w5000 Money on Spawn^n", theAmount)
	}

	else if (status == 1200)
	{
       		format(theAmount, maxlen, "%s\r1. \w600 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r2. \d1200 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r3. \w2500 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r4. \w5000 Money on Spawn^n", theAmount)
	}

	else if (status == 2500)
	{
       		format(theAmount, maxlen, "%s\r1. \w600 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r2. \w1200 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r3. \d2500 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r4. \w5000 Money on Spawn^n", theAmount)
	}

	else if (status == 5000)
	{
       		format(theAmount, maxlen, "%s\r1. \w600 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r2. \w1200 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r3. \w2500 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r4. \d5000 Money on Spawn^n", theAmount)
	}

	else
	{
       		format(theAmount, maxlen, "%s\r1. \w600 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r2. \w1200 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r3. \w2500 Money on Spawn^n", theAmount)
        	format(theAmount, maxlen, "%s\r4. \w5000 Money on Spawn^n", theAmount)
	}
   
	format(theAmount, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theAmount)
	show_menu(id, Keysmenu, theAmount, 20, "amx_respawn_amount Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_amount menu ]==========================

public amx_respawn_amount_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_amount, 600)
			AmxAmount(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_amount, 1200)
			AmxAmount(id)
		}

		case 2:
		{
			set_pcvar_num(toggle_amount, 2500)
			AmxAmount(id)
		}

		case 3:
		{
			set_pcvar_num(toggle_amount, 5000)
			AmxAmount(id)
		}

		case 7:
		{
			MoneyMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_amount menu closed")
		}

		default:
		{
			AmxAmount(id)
		}
	}     
}

//=============================[ Create amx_respawn_kill_money Menu ]=================================

public AmxKill(id)
{
	//Create Menu - amx_respawn_kill_money
	new theKill[300], maxlen = sizeof theKill - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_kill_money)
   
	format(theKill, maxlen, "\rARN - Money Related Menu || \yamx_respawn_kill_money Cvar : %d^n^n", status)
   
	if (status == 0) 
	{
       		format(theKill, maxlen, "%s\r1. \d0 Off^n", theKill)
        	format(theKill, maxlen, "%s\r2. \w200 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r3. \w600 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r4. \w1500 Money on frag^n", theKill)
	}

	else if (status == 200)
	{
       		format(theKill, maxlen, "%s\r1. \w0 Off^n", theKill)
        	format(theKill, maxlen, "%s\r2. \d200 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r3. \w600 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r4. \w1500 Money on frag^n", theKill)
	}

	else if (status == 600)
	{
       		format(theKill, maxlen, "%s\r1. \w0 Off^n", theKill)
        	format(theKill, maxlen, "%s\r2. \w200 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r3. \d600 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r4. \w1500 Money on frag^n", theKill)
	}

	else if (status == 1500)
	{
       		format(theKill, maxlen, "%s\r1. \w0 Off^n", theKill)
        	format(theKill, maxlen, "%s\r2. \w200 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r3. \w600 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r4. \d1500 Money on frag^n", theKill)
	}

	else
	{
       		format(theKill, maxlen, "%s\r1. \w0 Off^n", theKill)
        	format(theKill, maxlen, "%s\r2. \w200 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r3. \w600 Money on frag^n", theKill)
        	format(theKill, maxlen, "%s\r4. \w1500 Money on frag^n", theKill)
	}
   
	format(theKill, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theKill)
	show_menu(id, Keysmenu, theKill, 20, "amx_respawn_kill_money Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_kill_money menu ]==========================

public amx_respawn_kill_money_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_kill_money, 0)
			AmxKill(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_kill_money, 200)
			AmxKill(id)
		}

		case 2:
		{
			set_pcvar_num(toggle_kill_money, 600)
			AmxKill(id)
		}

		case 3:
		{
			set_pcvar_num(toggle_kill_money, 1500)
			AmxKill(id)
		}

		case 7:
		{
			MoneyMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_kill_money menu closed")
		}

		default:
		{
			AmxKill(id)
		}
	}     
}

//=============================[ Create Protection Related menu ]=================================

public ProtectionMenu(id)
{
    new theProtectionMenu[255]
    formatex(theProtectionMenu, 254, "\rARN - Protection Related Menu^n^n\r1.\w amx_respawn_protection^n\r2.\w amx_respawn_protection_time^n\r3.\w amx_respawn_protection_glow^n\r4.\w amx_respawn_protection_message^n^n\r8.\w Back^n\r0.\w Exit")
    show_menu(id, Keysmenu, theProtectionMenu, 20, "Protection Related Menu")
   
    return 1;
}

//==========================[ Menu Options - Protection Related menu ]==========================

public protection_related_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			AmxProtection(id)
		}

		case 1:
		{
			AmxProtectionTime(id)
		}

		case 2:
		{
			AmxGlow(id)
		}

		case 3:
		{
			AmxMessage(id)
		}

		case 7:
		{
			RespawnMenu(id)
		}

		case 9:
		{
			green_print(id, "Protection Related Menu closed")
		}

		default:
		{
			ProtectionMenu(id)
		}
	}     
}

//=============================[ Create amx_respawn_protection menu ]=================================

public AmxProtection(id)
{
	//Create Menu - amx_respawn_protection
	new AmxProtectionMenu[300], maxlen = sizeof AmxProtectionMenu - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_sp)
   
	format(AmxProtectionMenu, maxlen, "\rARN - Protection Related Menu || \yamx_respawn_protection Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(AmxProtectionMenu, maxlen, "%s\r1. \dOn^n", AmxProtectionMenu)
        	format(AmxProtectionMenu, maxlen, "%s\r2. \wOff^n", AmxProtectionMenu)
	} 
	else 
	{
        	format(AmxProtectionMenu, maxlen, "%s\r1. \wOn^n", AmxProtectionMenu)
        	format(AmxProtectionMenu, maxlen, "%s\r2. \dOff^n", AmxProtectionMenu)
	}
   
	format(AmxProtectionMenu, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", AmxProtectionMenu)
	show_menu(id, Keysmenu, AmxProtectionMenu, 20, "amx_respawn_protection menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_protection menu ]==========================

public protection_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_sp, 1)
			AmxProtection(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_sp, 0)
			AmxProtection(id)
		}

		case 7:
		{
			ProtectionMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_protection menu closed")
		}

		default:
		{
			AmxProtection(id)
		}
	}     
}

//=======================[ Create amx_respawn_protection_time Menu ]=================================

public AmxProtectionTime(id)
{
	//Create Menu - amx_respawn_protection_time
	new ProtectionTime[300], maxlen = sizeof ProtectionTime - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_sp_time)
   
	format(ProtectionTime, maxlen, "\rARN - Protection Related Menu || \yamx_respawn_protection_time Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(ProtectionTime, maxlen, "%s\r1. \d1 second duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r2. \w3 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r3. \w5 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r4. \w10 seconds duration^n", ProtectionTime)
	}

	else if (status == 3)
	{
       		format(ProtectionTime, maxlen, "%s\r1. \w1 second duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r2. \d3 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r3. \w5 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r4. \w10 seconds duration^n", ProtectionTime)
	}

	else if (status == 5)
	{
       		format(ProtectionTime, maxlen, "%s\r1. \w1 second duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r2. \w3 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r3. \d5 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r4. \w10 seconds duration^n", ProtectionTime)
	}

	else if (status == 10)
	{
       		format(ProtectionTime, maxlen, "%s\r1. \w1 second duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r2. \w3 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r3. \w5 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r4. \d10 seconds duration^n", ProtectionTime)
	}

	else
	{
       		format(ProtectionTime, maxlen, "%s\r1. \w1 second duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r2. \w3 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r3. \w5 seconds duration^n", ProtectionTime)
        	format(ProtectionTime, maxlen, "%s\r4. \w10 seconds duration^n", ProtectionTime)
	}
   
	format(ProtectionTime, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", ProtectionTime)
	show_menu(id, Keysmenu, ProtectionTime, 20, "amx_respawn_protection_time menu")
   
	return 1;
}

//===================[ Menu Options - amx_respawn_protection_time menu ]==========================

public protection_time_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_sp_time, 1)
			AmxProtectionTime(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_sp_time, 3)
			AmxProtectionTime(id)
		}

		case 2:
		{
			set_pcvar_num(toggle_sp_time, 5)
			AmxProtectionTime(id)
		}

		case 3:
		{
			set_pcvar_num(toggle_sp_time, 10)
			AmxProtectionTime(id)
		}

		case 7:
		{
			ProtectionMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_protection_time menu closed")
		}

		default:
		{
			AmxProtectionTime(id)
		}
	}     
}

//======================[ Create amx_respawn_protection_glow menu ]=================================

public AmxGlow(id)
{
	//Create Menu - amx_respawn_protection_glow
	new AmxGlowMenu[300], maxlen = sizeof AmxGlowMenu - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_sp_glow)
   
	format(AmxGlowMenu, maxlen, "\rARN - Protection Related Menu || \yamx_respawn_protection_glow Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(AmxGlowMenu, maxlen, "%s\r1. \dOn^n", AmxGlowMenu)
        	format(AmxGlowMenu, maxlen, "%s\r2. \wOff^n", AmxGlowMenu)
	} 
	else 
	{
        	format(AmxGlowMenu, maxlen, "%s\r1. \wOn^n", AmxGlowMenu)
        	format(AmxGlowMenu, maxlen, "%s\r2. \dOff^n", AmxGlowMenu)
	}
   
	format(AmxGlowMenu, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", AmxGlowMenu)
	show_menu(id, Keysmenu, AmxGlowMenu, 20, "amx_respawn_protection_glow menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_protection_glow menu ]==========================

public protection_glow_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_sp_glow, 1)
			AmxGlow(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_sp_glow, 0)
			AmxGlow(id)
		}

		case 7:
		{
			ProtectionMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_protection_glow menu closed")
		}

		default:
		{
			AmxGlow(id)
		}
	}     
}

//======================[ Create amx_respawn_protection_message menu ]=================================

public AmxMessage(id)
{
	//Create Menu - amx_respawn_protection_message
	new AmxMsgMenu[300], maxlen = sizeof AmxMsgMenu - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_sp_text)
   
	format(AmxMsgMenu, maxlen, "\rARN - Protection Related Menu || \yamx_respawn_protection_message Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(AmxMsgMenu, maxlen, "%s\r1. \dOn^n", AmxMsgMenu)
        	format(AmxMsgMenu, maxlen, "%s\r2. \wOff^n", AmxMsgMenu)
	} 
	else 
	{
        	format(AmxMsgMenu, maxlen, "%s\r1. \wOn^n", AmxMsgMenu)
        	format(AmxMsgMenu, maxlen, "%s\r2. \dOff^n", AmxMsgMenu)
	}
   
	format(AmxMsgMenu, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", AmxMsgMenu)
	show_menu(id, Keysmenu, AmxMsgMenu, 20, "amx_respawn_protection_message menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_protection_message menu ]==========================

public protection_message_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_sp_text, 1)
			AmxMessage(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_sp_text, 0)
			AmxMessage(id)
		}

		case 7:
		{
			ProtectionMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_protection_message menu closed")
		}

		default:
		{
			AmxMessage(id)
		}
	}     
}

//=============================[ Create Weapon Related menu ]=================================

public WeaponMenu(id)
{
    new theWeaponMenu[255]
    formatex(theWeaponMenu, 254, "\rARN - Weapon Related Menu^n^n\r1.\w amx_respawn_pistol^n\r2.\w amx_respawn_ammo^n\r3.\w amx_respawn_armor^n\r4.\w amx_respawn_punish^n^n\r8.\w Back^n\r0.\w Exit")
    show_menu(id, Keysmenu, theWeaponMenu, 20, "Weapon Related Menu")
   
    return 1;
}

//==========================[ Menu Options - Weapon Related menu ]==========================

public weapon_related_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			AmxPistol(id)
		}

		case 1:
		{
			AmxAmmo(id)
		}

		case 2:
		{
			AmxArmor(id)
		}

		case 3:
		{
			AmxPunish(id)
		}

		case 7:
		{
			RespawnMenu(id)
		}

		case 9:
		{
			green_print(id, "Weapon Related Menu closed")
		}

		default:
		{
			WeaponMenu(id)
		}
	}     
}


//=============================[ Create amx_respawn_pistol Menu ]=================================

public AmxPistol(id)
{
	//Create Menu - amx_respawn_pistol
	new thePistol[300], maxlen = sizeof thePistol - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_mode)
   
	format(thePistol, maxlen, "\rARN - Weapon Related Menu || \yamx_respawn_pistol Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(thePistol, maxlen, "%s\r1. \dOn^n", thePistol)
        	format(thePistol, maxlen, "%s\r2. \wOff^n", thePistol)
	} 
	else 
	{
        	format(thePistol, maxlen, "%s\r1. \wOn^n", thePistol)
        	format(thePistol, maxlen, "%s\r2. \dOff^n", thePistol)
	}
   
	format(thePistol, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", thePistol)
	show_menu(id, Keysmenu, thePistol, 20, "amx_respawn_pistol Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_pistol menu ]==========================

public amx_pistol_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_mode, 1)
			AmxPistol(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_mode, 0)
			AmxPistol(id)
		}

		case 7:
		{
			WeaponMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_pistol menu closed")
		}

		default:
		{
			AmxPistol(id)
		}
	}     
}

//=============================[ Create amx_respawn_ammo Menu ]=================================

public AmxAmmo(id)
{
	//Create Menu - amx_respawn_ammo
	new theAmmo[300], maxlen = sizeof theAmmo - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_ammo)
   
	format(theAmmo, maxlen, "\rARN - Weapon Related Menu || \yamx_respawn_ammo Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(theAmmo, maxlen, "%s\r1. \dOn^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r2. \wOff^n", theAmmo)
	} 
	else 
	{
        	format(theAmmo, maxlen, "%s\r1. \wOn^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r2. \dOff^n", theAmmo)
	}
   
	format(theAmmo, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theAmmo)
	show_menu(id, Keysmenu, theAmmo, 20, "amx_respawn_ammo Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_ammo menu ]==========================

public amx_ammo_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_ammo, 1)
			AmxAmmo(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_ammo, 0)
			AmxAmmo(id)
		}

		case 7:
		{
			WeaponMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_ammo menu closed")
		}

		default:
		{
			AmxAmmo(id)
		}
	}     
}

//=======================[ Create amx_respawn_armor Menu ]=================================

public AmxArmor(id)
{
	//Create Menu - amx_respawn_armor
	new theAmmo[300], maxlen = sizeof theAmmo - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_kevlar)
   
	format(theAmmo, maxlen, "\rARN - Weapon Related Menu || \yamx_respawn_armor Cvar : %d^n^n", status)
   
	if (status == 0) 
	{
       		format(theAmmo, maxlen, "%s\r1. \dOff^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r2. \wKevlar^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r3. \wKevlar + Helmet^n", theAmmo)
	}

	else if (status == 1)
	{
       		format(theAmmo, maxlen, "%s\r1. \wOff^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r2. \dKevlar^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r3. \wKevlar + Helmet^n", theAmmo)
	}

	else if (status == 2)
	{
       		format(theAmmo, maxlen, "%s\r1. \wOff^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r2. \wKevlar^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r3. \dKevlar + Helmet^n", theAmmo)
	}

	else
	{
       		format(theAmmo, maxlen, "%s\r1. \wOff^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r2. \wKevlar^n", theAmmo)
        	format(theAmmo, maxlen, "%s\r3. \wKevlar + Helmet^n", theAmmo)
	}
   
	format(theAmmo, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", theAmmo)
	show_menu(id, Keysmenu, theAmmo, 20, "amx_respawn_armor menu")
   
	return 1;
}

//===================[ Menu Options - amx_respawn_armor menu ]==========================

public armor_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_kevlar, 0)
			AmxArmor(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_kevlar, 1)
			AmxArmor(id)
		}

		case 2:
		{
			set_pcvar_num(toggle_kevlar, 2)
			AmxArmor(id)
		}

		case 7:
		{
			WeaponMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_armor menu closed")
		}

		default:
		{
			AmxArmor(id)
		}
	}     
}

//=============================[ Create amx_respawn_punish Menu ]=================================

public AmxPunish(id)
{
	//Create Menu - amx_respawn_punish
	new thePistol[300], maxlen = sizeof thePistol - 1
   
	//Create integer to display cvar value
	new status = get_pcvar_num(toggle_punish)
   
	format(thePistol, maxlen, "\rARN - Weapon Related Menu || \yamx_respawn_punish Cvar : %d^n^n", status)
   
	if (status == 1) 
	{
       		format(thePistol, maxlen, "%s\r1. \dOn^n", thePistol)
        	format(thePistol, maxlen, "%s\r2. \wOff^n", thePistol)
	} 
	else 
	{
        	format(thePistol, maxlen, "%s\r1. \wOn^n", thePistol)
        	format(thePistol, maxlen, "%s\r2. \dOff^n", thePistol)
	}
   
	format(thePistol, maxlen, "%s^n\r8.\wBack^n\r0.\wExit", thePistol)
	show_menu(id, Keysmenu, thePistol, 20, "amx_respawn_punish Menu")
   
	return 1;
}

//==========================[ Menu Options - amx_respawn_pistol menu ]==========================

public amx_punish_menu(id, key) 
{
	switch (key)
	{
		case 0:
		{
			set_pcvar_num(toggle_punish, 1)
			AmxPunish(id)
		}

		case 1:
		{
			set_pcvar_num(toggle_punish, 0)
			AmxPunish(id)
		}

		case 7:
		{
			WeaponMenu(id)
		}

		case 9:
		{
			green_print(id, "amx_respawn_punish menu closed")
		}

		default:
		{
			AmxPunish(id)
		}
	}     
}

//=================================[ Green print "[AMXX]" ]================================

stock green_print(index, const message[])
{
	new finalmsg[192];
	formatex(finalmsg, 191, "^x04[AMXX] ^x01%s", message);
	message_begin(MSG_ONE, SayText, _, index);
	write_byte(index);
	write_string(finalmsg);
	message_end();
}

//=================================[ Set user Money Function ]================================

stock fm_set_user_money(index, money, flash = 1) //set money
{
	set_pdata_int(index, FM_MONEY_OFFSET, money);
 
	message_begin(MSG_ONE, get_user_msgid("Money"), _, index);
	write_long(money);
	write_byte(flash ? 1 : 0);
	message_end();
}