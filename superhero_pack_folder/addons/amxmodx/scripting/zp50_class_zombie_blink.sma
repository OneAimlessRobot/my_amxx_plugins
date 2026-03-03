/*================================================================================
	
		****************************************************
		*********** [Zombie Plague Blink 1.2.0] ************
		****************************************************
	
	----------------------
	-*- Licensing Info -*-
	----------------------
	
	Zombie Plague Blink
	by schmurgel1983(@msn.com)
	Copyright (C) 2010-2011 Stefan "schmurgel1983" Focke
	
	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.
	
	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
	Public License for more details.
	
	You should have received a copy of the GNU General Public License along
	with this program. If not, see <http://www.gnu.org/licenses/>.
	
	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.
	
	No warranties of any kind. Use at your own risk.
	
	-------------------
	-*- Description -*-
	-------------------
	
	Teleport on high or low places are now for Zombies, after teleport
	u can't attack, and have a black screen so u don't see anything.
	The Teleport has the flashbang sound and special effects.
	A cooldown cvar controlled the blink so u don't can spam.
	
	---------------------
	-*- Configuration -*-
	---------------------
	
	zp_blink_cooldown 15.0 // Cooldown befor allow next blink
	zp_blink_no_atk_time 1.5 // how long can't attack after blink in seconds
	zp_blink_range 1234 // Maximum range from blink
	zp_blink_nemesis 0 // Allow nemesis to blink [0-disabled / 1-enabled]
	zp_blink_button 1 // wich button u push to blink [0-use / 1-reload]
	zp_blink_bots 1 // bots automatic blink [0-disabled / 1-enabled]
	
	--------------------
	-*- Requirements -*-
	--------------------
	
	* Mods: Counter-Strike 1.6 or Condition-Zero
	* AMXX: Version 1.8.0 or later
	* Module: fakemeta, hamsandwich
	
	-----------------
	-*- Changelog -*-
	-----------------
	
	* v1.0.0:
	   - Initial release Privat (9th Aug 2010)
	   - Initial release Alliedmodders (4th Feb 2011)
	
	* v1.1.0: (5th Feb 2011)
	   - Added: cvar to choose the teleport button,
	      bots are use now Teleport too
	
	* v1.2.0: (6th Feb 2011)
	   - Added: cvar to controlled the "no attack time"
	      after teleport
	
=================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <xs>

#if AMXX_VERSION_NUM < 180
	#assert AMX Mod X v1.8.0 or later library required!
#endif

#include <hamsandwich>

/*================================================================================
 [Zombie Plague 5.0 Includes]
=================================================================================*/

#include <zp50_class_zombie>
#define LIBRARY_NEMESIS "zp50_class_nemesis"
#include <zp50_class_nemesis>

/*================================================================================
 [Constants, Offsets, Macros]
=================================================================================*/

// Plugin Version
new const PLUGIN_VERSION[] = "1.2.0 (zp50)"

// Blick Zombie
new const zclass_name[] = { "Blink Zombie" }
new const zclass_info[] = { "HP- Knockback+++ Teleport" }
new const zclass_model[][] = { "zombie_source" }
new const zclass_clawmodel[][] = { "models/zombie_plague/v_knife_zombie.mdl" }
const zclass_health = 1500
const Float:zclass_speed = 0.77
const Float:zclass_gravity = 1.0
const Float:zclass_knockback = 2.0

// Ham weapon const
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX_WEAPONS = 4

// Flashbang sound
new const SOUND_BLINK[] = { "weapons/flashbang-1.wav" }

// ScreenFade
const UNIT_SEC = 0x1000 // 1 second
const FFADE = 0x0000

/*================================================================================
 [Global Variables]
=================================================================================*/

// Player vars
new g_bBlink[33] // is Blink Zombie
new g_bAllowATK[33] // allow to attack
new Float:g_flNextBlink[33] // last blink time

// Game vars
new g_iBlinkIndex // index from the class
new g_iMaxPlayers // max player counter

// Message IDs vars
new g_msgSayText, g_msgScreenFade

// Sprites
new g_iShockwave, g_iFlare

// Cvar pointers
new cvar_Cooldown, cvar_Range, cvar_Nemesis,
cvar_Button, cvar_Bots, cvar_NoAttack

/*================================================================================
 [Precache and Init]
=================================================================================*/

public plugin_precache()
{
	register_plugin("[ZP] Zombie Class : Blink", PLUGIN_VERSION, "schmurgel1983")
	
	new index
	g_iBlinkIndex = zp_class_zombie_register(zclass_name, zclass_info, zclass_health, zclass_speed, zclass_gravity)
	zp_class_zombie_register_kb(g_iBlinkIndex, zclass_knockback)
	for (index = 0; index < sizeof zclass_model; index++)
		zp_class_zombie_register_model(g_iBlinkIndex, zclass_model[index])
	for (index = 0; index < sizeof zclass_clawmodel; index++)
		zp_class_zombie_register_claw(g_iBlinkIndex, zclass_clawmodel[index])
	
	g_iShockwave = precache_model( "sprites/shockwave.spr")
	g_iFlare = precache_model( "sprites/blueflare2.spr")
}

public plugin_init()
{
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("DeathMsg", "event_player_death", "a")
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwd_Knife_Blink")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fwd_Knife_Blink")
	
	register_forward(FM_CmdStart, "fwd_CmdStart")
	
	g_msgSayText = get_user_msgid("SayText")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	
	cvar_Cooldown = register_cvar("zp_blink_cooldown", "15.0")
	cvar_NoAttack = register_cvar("zp_blink_no_atk_time", "1.5")
	cvar_Range = register_cvar("zp_blink_range", "1234")
	cvar_Nemesis = register_cvar("zp_blink_nemesis", "0")
	cvar_Button = register_cvar("zp_blink_button", "1")
	cvar_Bots = register_cvar("zp_blink_bots", "1")
	
	register_cvar("Blink_Zombie_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("Blink_Zombie_version", PLUGIN_VERSION)
	
	g_iMaxPlayers = get_maxplayers()
}

public client_putinserver(id) reset_vars(id)

public client_disconnected(id) reset_vars(id)

public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}

public module_filter(const module[])
{
	if (equal(module, LIBRARY_NEMESIS))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

public event_round_start()
{
	for (new id = 1; id <= g_iMaxPlayers; id++)
		reset_vars(id)
}

public event_player_death() reset_vars(read_data(2))

public fwd_Knife_Blink(ent)
{
	static owner
	owner = ham_cs_get_weapon_ent_owner(ent)
	
	if (!g_bBlink[owner] || g_bAllowATK[owner]) return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public fwd_CmdStart(id, handle)
{
	if (!g_bBlink[id] || !is_user_alive(id) || get_gametime() < g_flNextBlink[id]) return
	
	static button
	button = get_uc(handle, UC_Buttons)
	if (button & IN_USE && !get_pcvar_num(cvar_Button) || button & IN_RELOAD && get_pcvar_num(cvar_Button))
	{
		if (teleport(id))
		{
			emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			g_bAllowATK[id] = false
			g_flNextBlink[id] = get_gametime() + get_pcvar_float(cvar_Cooldown)
			
			remove_task(id)
			set_task(get_pcvar_float(cvar_NoAttack), "allow_attack", id)
			set_task(get_pcvar_float(cvar_Cooldown), "show_blink", id)
		}
		else
		{
			g_flNextBlink[id] = get_gametime() + 1.0
			
			colored_print(id, "^x04[ZP]^x01 Found no reliable teleportation position.")
		}
	}
}

public zp_fw_core_cure_post(id) reset_vars(id)

public zp_fw_core_infect_post(id, attacker)
{
	if (zp_class_zombie_get_current(id) == g_iBlinkIndex)
	{
		if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(id) && !get_pcvar_num(cvar_Nemesis)) return
		
		g_bBlink[id] = true
		g_bAllowATK[id] = true
		g_flNextBlink[id] = get_gametime()
		
		show_blink(id)
	}
}

/*================================================================================
 [Other Functions]
=================================================================================*/

public allow_attack(id)
{
	if (!is_user_connected(id)) return
	
	g_bAllowATK[id] = true
}

reset_vars(id)
{
	remove_task(id)
	g_bBlink[id] = false
	g_bAllowATK[id] = true
}

public show_blink(id)
{
	if (!is_user_connected(id) || !g_bBlink[id] || !is_user_alive(id)) return
	
	if (!get_pcvar_num(cvar_Button))
		colored_print(id, "^x04[Blink Zombie]^x01 Blink ability is ready. Press +use button.")
	else
		colored_print(id, "^x04[Blink Zombie]^x01 Blink ability is ready. Press +reload button.")
	
	// Bot support
	if (is_user_bot(id) && get_pcvar_num(cvar_Bots))
		set_task(random_float(1.0, 5.0), "bot_will_teleport", id)
}

public bot_will_teleport(id)
{
	if (!is_user_connected(id) || !g_bBlink[id] || !is_user_alive(id) || !is_user_bot(id)) return
	
	if (teleport(id))
	{
		emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		g_bAllowATK[id] = false
		
		remove_task(id)
		set_task(get_pcvar_float(cvar_NoAttack), "allow_attack", id)
		set_task(get_pcvar_float(cvar_Cooldown), "show_blink", id)
	}
	else
	{
		set_task(random_float(1.0, 3.0), "bot_will_teleport", id)
	}
}

bool:teleport(id)
{
	new	Float:vOrigin[3], Float:vNewOrigin[3],
	Float:vNormal[3], Float:vTraceDirection[3],
	Float:vTraceEnd[3]
	
	pev(id, pev_origin, vOrigin)
	
	velocity_by_aim(id, get_pcvar_num(cvar_Range), vTraceDirection)
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd)
	
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0)
	
	new Float:flFraction
	get_tr2(0, TR_flFraction, flFraction)
	if (flFraction < 1.0)
	{
		get_tr2(0, TR_vecEndPos, vTraceEnd)
		get_tr2(0, TR_vecPlaneNormal, vNormal)
	}
	
	xs_vec_mul_scalar(vNormal, 40.0, vNormal) // do not decrease the 40.0
	xs_vec_add(vTraceEnd, vNormal, vNewOrigin)
	
	if (is_player_stuck(id, vNewOrigin))
		return false;
	
	emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
	tele_effect(vOrigin)
	
	engfunc(EngFunc_SetOrigin, id, vNewOrigin)
	
	tele_effect(vNewOrigin)
	tele_effect2(vNewOrigin)
	
	emessage_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
	ewrite_short(floatround(UNIT_SEC*get_pcvar_float(cvar_NoAttack)))
	ewrite_short(floatround(UNIT_SEC*get_pcvar_float(cvar_NoAttack)))
	ewrite_short(FFADE)
	ewrite_byte(0)
	ewrite_byte(0)
	ewrite_byte(0)
	ewrite_byte(255)
	emessage_end()
	
	return true;
}

colored_print(target, const message[], any:...)
{
	static buffer[512]
	
	vformat(buffer, charsmax(buffer), message, 3)
	
	message_begin(MSG_ONE, g_msgSayText, _, target)
	write_byte(target)
	write_string(buffer)
	message_end()
}

/*================================================================================
 [Stocks]
=================================================================================*/

stock is_player_stuck(id, Float:originF[3])
{
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

stock ham_cs_get_weapon_ent_owner(entity)
{
	if (pev_valid(entity) != 2)
		return 0;
	
	return get_pdata_cbase(entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

stock tele_effect(const Float:torigin[3])
{
	new origin[3]
	origin[0] = floatround(torigin[0])
	origin[1] = floatround(torigin[1])
	origin[2] = floatround(torigin[2])
	
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+60)
	write_short(g_iShockwave)
	write_byte(0)
	write_byte(0)
	write_byte(3)
	write_byte(60)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(0)
	message_end()
}

stock tele_effect2(const Float:torigin[3])
{
	new origin[3]
	origin[0] = floatround(torigin[0])
	origin[1] = floatround(torigin[1])
	origin[2] = floatround(torigin[2])
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITETRAIL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+40)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(g_iFlare)
	write_byte(30)
	write_byte(10)
	write_byte(1)
	write_byte(50)
	write_byte(10)
	message_end()
}
