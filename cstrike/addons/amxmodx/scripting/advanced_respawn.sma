/***********************************************************************************
*										    
*	  		Plugin : Advanced - Respawn	
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
* V 2.1
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

new const PLUGIN_NAME[] = "Advanced - Respawn"
new const PLUGIN_AUTHOR[] = "Atomen"
new VERSION[] = {"2.1"}

#define MAX_PLAYERS 32
#define FM_MONEY_OFFSET 115
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