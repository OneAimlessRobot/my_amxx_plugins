/* Copyright (C) 2006-2008 Space Headed Productions
* 
* WeaponMod is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation.
*
* WeaponMod is distributed in the hope that it will be useful, 
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with WeaponMod; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/ 

#include <amxmodx>
#include <fakemeta>
#include <weaponmod>

// Plugin information
new const PLUGIN[] = "WPN FlameThrower"
new const VERSION[] = "0.72"
new const AUTHOR[] = "DevconeS"

// Weapon information
new WPN_NAME[] = "DEMON Breath"
new WPN_SHORT[] = "demon"

// Entity data
new ENTITY_NAME[] = "wpn_flame"

// Models
new P_MODEL[] = "models/wpnmod/p_dbreath.mdl"
new V_MODEL[] = "models/wpnmod/v_dbreath.mdl"
new W_MODEL[] = "models/wpnmod/w_dbreath.mdl"
new WT_MODEL[] = "models/wpnmod/w_dbreatht.mdl"

// Sprites
new FLAME_SPRITE[] = "sprites/xfireball3.spr"

// Sounds
new SOUND_STARTUP[] = "weapons/egon_windup2.wav"
new SOUND_OFF[] = "weapons/egon_off1.wav"
new SOUND_RUN[] = "weapons/egon_run3.wav"

// Flame definitions
#define FLAME_SPEED		1000
#define FLAME_FRAMES	20.0
#define LIFE_TIME		0.7
#define ANI_SPEED		0.7
#define FRAME_INCREASE	0.3

// Weapon definitions
#define LOAD_UP_TIME	0.4
#define SHUT_DOWN_TIME	0.2
#define SHOOT_LENGTH	10000.0

// Damage a flame can cause
#define MIN_DAMAGE		100
#define MAX_DAMAGE		150

// Sequences
enum
{
	anim_idle1,
	anim_fidget1,
	anim_altfireon,
	anim_altfirecycle,
	anim_altfireoff,
	anim_fire1,
	anim_fire2,
	anim_fire3,
	anim_fire4,
	anim_draw,
	anim_holster
}

// Types
enum
{
	act_none,
	act_load_up,
	act_run
}

new g_wpnid
new Float:g_lastShot[33]
new Float:g_nextSound[33]
new g_plAction[33]
new g_MaxPlayers

// Precache required files
public plugin_precache()
{
	precache_model(P_MODEL)
	precache_model(V_MODEL)
	precache_model(W_MODEL)
	precache_model(WT_MODEL)
	
	precache_sound(SOUND_STARTUP)
	precache_sound(SOUND_OFF)
	precache_sound(SOUND_RUN)
	
	precache_model(FLAME_SPRITE)
}

// Initialize plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_Think, "fwd_Think")
	register_forward(FM_Touch, "fwd_Touch")
	register_forward(FM_StartFrame, "fwd_StartFrame")
	
	g_MaxPlayers = get_maxplayers()
	
	create_weapon()
}

// Registers the weapon to weapon mod
create_weapon()
{
	new wpnid = wpn_register_weapon(WPN_NAME, WPN_SHORT)
	if(wpnid == -1) return PLUGIN_CONTINUE
	
	// Strings
	wpn_set_string(wpnid, wpn_viewmodel, V_MODEL)
	wpn_set_string(wpnid, wpn_weaponmodel, P_MODEL)
	wpn_set_string(wpnid, wpn_worldmodel, W_MODEL)
	
	// Event handlers
	wpn_register_event(wpnid, event_attack1, "ev_attack1")
	wpn_register_event(wpnid, event_reload, "ev_reload")
	wpn_register_event(wpnid, event_draw, "ev_draw")
	
	// Floats
	wpn_set_float(wpnid, wpn_refire_rate1, 0.01)
	wpn_set_float(wpnid, wpn_reload_time, 3.0)
	wpn_set_float(wpnid, wpn_recoil1, 1.0)
	wpn_set_float(wpnid, wpn_run_speed, 600.0)
	
	// Integers
	wpn_set_integer(wpnid, wpn_ammo1, 500)
	wpn_set_integer(wpnid, wpn_ammo2, 1000)
	wpn_set_integer(wpnid, wpn_bullets_per_shot1, 1)
	wpn_set_integer(wpnid, wpn_bullets_per_shot2, 0)
	wpn_set_integer(wpnid, wpn_cost, 200000)
	
	g_wpnid = wpnid
	return PLUGIN_CONTINUE
}

// Called each time an entity "thinks"
public fwd_Think(entid)
{
	static classname[32]
	if(!pev_valid(entid)) return PLUGIN_CONTINUE
	
	pev(entid, pev_classname, classname, 31)
	if(equal(classname, ENTITY_NAME))
	{
		// It's a flame, handle its animation
		set_pev(entid, pev_nextthink, ANI_SPEED)
		
		static Float:ltime
		pev(entid, pev_ltime, ltime)
		if(ltime <= get_gametime())
		{
			// This flame is old enough, kill it
			set_pev(entid, pev_flags, FL_KILLME)
		} else {
			// Flame is still alive, move to the next frame
			static Float:frame
			pev(entid, pev_frame, frame)
			if(frame+FRAME_INCREASE <= FLAME_FRAMES)
			{
				// More frames available
				set_pev(entid, pev_frame, frame+FRAME_INCREASE)
			} else {
				// No more frames, start from the beginning
				set_pev(entid, pev_frame, 0.0)
			}
		}
	}
	return PLUGIN_CONTINUE
}

// Weapon reloads
public ev_reload(id)
	wpn_playanim(id, anim_fidget1)

// Weapon drawn
public ev_draw(id)
	wpn_playanim(id, anim_draw)

// Attack 1 (shoot fire)
public ev_attack1(id)
{
	// Play animation
	wpn_playanim(id, random_num(anim_fire1, anim_fire4))
	
	static Float:gtime
	gtime = get_gametime()
	g_lastShot[id] = gtime
	
	if(g_nextSound[id] <= gtime)
	{
		// A sound has to be played, find out which
		switch(g_plAction[id])
		{
			case act_none:
			{
				// Player did nothing, so he's loading up
				emit_sound(id, CHAN_WEAPON, SOUND_STARTUP, 0.8, ATTN_NORM, 0, PITCH_NORM)
				g_nextSound[id] = gtime+LOAD_UP_TIME
				g_plAction[id] = act_load_up
				return PLUGIN_CONTINUE
			}
			case act_load_up:
			{
				// User already load up, so he's firing
				emit_sound(id, CHAN_WEAPON, SOUND_RUN, 0.8, ATTN_NORM, 0, PITCH_NORM)
				g_nextSound[id] = gtime
				g_plAction[id] = act_run
				return PLUGIN_CONTINUE
			}
		}
	}
	
	// Try to create a flame
	static flame
	flame = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!flame) return PLUGIN_CONTINUE
	
	// Strings
	set_pev(flame, pev_classname, ENTITY_NAME)
	engfunc(EngFunc_SetModel, flame, FLAME_SPRITE)
	
	// Integers
	set_pev(flame, pev_owner, id)
	set_pev(flame, pev_rendermode, kRenderTransAdd)
	set_pev(flame, pev_renderamt, 255.0)
	set_pev(flame, pev_movetype, MOVETYPE_BOUNCEMISSILE)
	set_pev(flame, pev_solid, SOLID_TRIGGER)
	
	// Floats
	set_pev(flame, pev_mins, Float:{-8.0, -8.0, -8.0})
	set_pev(flame, pev_maxs, Float:{8.0, 8.0, 8.0})
	set_pev(flame, pev_ltime, get_gametime()+LIFE_TIME)
	
	// Calculate start position
	static Float:fStart[3]
	wpn_projectile_startpos(id, 16, 12, 4, fStart)
	set_pev(flame, pev_origin, fStart)
	
	// Calculate flight direction
	static Float:fVel[3]
	velocity_by_aim(id, FLAME_SPEED, fVel)
	set_pev(flame, pev_velocity, fVel)
	set_pev(flame, pev_nextthink, ANI_SPEED)
	
	return PLUGIN_CONTINUE
}

// Called each time an entity touched something (e.g. wall or another entity)
public fwd_Touch(ptr, ptd)
{
	if(pev_valid(ptr) && pev_valid(ptd))
	{
		// Both entities are valid, check if we got a flame and a player
		static classname[32]
		pev(ptr, pev_classname, classname, 31)
		
		if(equal(classname, ENTITY_NAME) && (pev(ptd, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
		{
			// Flame and player found, kill the entity and add some damage to the player
			static attacker
			attacker = pev(ptr, pev_owner)
			wpn_damage_user(g_wpnid, ptd, attacker, random_num(3, 5), random_num(MIN_DAMAGE, MAX_DAMAGE), DMG_BURN)
			
			set_pev(ptr, pev_flags, FL_KILLME)	// remove_entity
		}
	}
}

// Called each time a new frame starts (used for checking if the turn off sound has to be played)
public fwd_StartFrame()
{
	static Float:gtime
	static pwpn
	static id
	
	gtime = get_gametime()
	
	// Cycle through all players
	for(id = 1; id < g_MaxPlayers; id++)
	{
		if(g_plAction[id] != act_none)
		{
			// User was firing before, so check if he actually got the flamethrower
			// is not firing and the last shot was a few seconds before
			pwpn = wpn_has_weapon(id, g_wpnid)
			if((!(pev(id, pev_button) & IN_ATTACK) && g_lastShot[id]+0.2 < gtime)  || (pwpn == -1))
			{
				// Everything's fine, play the turn off sound
				emit_sound(id, CHAN_WEAPON, SOUND_OFF, 0.8, ATTN_NORM, 0, PITCH_NORM)
				g_plAction[id] = act_none
			}
		}
	}
}
