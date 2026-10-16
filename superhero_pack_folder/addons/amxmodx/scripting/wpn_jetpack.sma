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
new PLUGIN[] = "WPN Jetpack"
new VERSION[] = "0.3"
new AUTHOR[] = "DevconeS"

// Weapon information
new WPN_NAME[] = "Jetpack"
new WPN_SHORT[] = "jetpack"

// Entity data
new ENTITY_NAME[] = "wpn_jprocket"

// Models
new P_MODEL[] = "models/p_egon.mdl"
new V_MODEL[] = "models/v_egon.mdl"
new W_MODEL[] = "models/w_egon.mdl"

// Rocket model and sound
new ROCKET_MDL[] = "models/rpgrocket.mdl"
new ROCKET_SOUND[] = "weapons/rocketfire1.wav"

// How fast can a player fly
#define FLY_SPEED	32

// Information about the rocket
#define ROCKET_SPEED	1200
#define ROCKET_RADIUS	300.0
#define ROCKET_DAMAGE	150.0

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

new g_wpnid
new g_trail, g_explosion, g_flame

// Precache required files
public plugin_precache()
{
	precache_model(P_MODEL)
	precache_model(V_MODEL)
	precache_model(W_MODEL)
	
	precache_model(ROCKET_MDL)
	precache_sound(ROCKET_SOUND)
	
	g_trail = precache_model("sprites/smoke.spr")
	g_explosion = precache_model("sprites/zerogxplode.spr")
	g_flame = precache_model("sprites/xfireball3.spr")
}

// Initialize plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_Touch, "fwd_Touch")
	
	create_weapon()
}

// Register weapon to weaponmod
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
	wpn_register_event(wpnid, event_attack2, "ev_attack2")
	wpn_register_event(wpnid, event_draw, "ev_draw")
	
	// Floats
	wpn_set_float(wpnid, wpn_refire_rate1, 0.0)
	wpn_set_float(wpnid, wpn_refire_rate2, 1.0)
	wpn_set_float(wpnid, wpn_reload_time, 3.0)
	wpn_set_float(wpnid, wpn_recoil1, 1.0)
	wpn_set_float(wpnid, wpn_recoil2, 3.0)
	wpn_set_float(wpnid, wpn_run_speed, 220.0)
	
	// Integers
	wpn_set_integer(wpnid, wpn_ammo1, 3)
	wpn_set_integer(wpnid, wpn_ammo2, 9)
	wpn_set_integer(wpnid, wpn_bullets_per_shot1, 0)
	wpn_set_integer(wpnid, wpn_bullets_per_shot2, 1)
	wpn_set_integer(wpnid, wpn_cost, 6000)
	wpn_set_integer(wpnid, wpn_count_bullets1, 0)	// We don't want flying to be counted by stats plugins ;)
	
	g_wpnid = wpnid
	return PLUGIN_CONTINUE
}

// Attack 1
public ev_attack1(id)
{
	// Play animation
	wpn_playanim(id, anim_fire1)
	
	// Get flight direction
	static Float:fVel[3], Float:fCur[3]
	velocity_by_aim(id, FLY_SPEED, fVel)
	pev(id, pev_velocity, fCur)
	
	// Calculate and set velocity
	fVel[0] += fCur[0]
	fVel[1] += fCur[1]
	fVel[2] += fCur[2]
	
	set_pev(id, pev_velocity, fVel)
	
	// Get position where the jetpack flames should be spawned
	velocity_by_aim(id, 10, fVel)
	pev(id, pev_origin, fCur)
	
	// Calculate origin
	fCur[0] -= fVel[0]
	fCur[1] -= fVel[1]
	fCur[2] -= fVel[2]
	
	// Show flame
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE) 
	write_coord(floatround(fCur[0]))
	write_coord(floatround(fCur[1]))
	write_coord(floatround(fCur[2]))
	write_short(g_flame)
	write_byte(10)
	write_byte(255)
	message_end()
	
	// Play swim animation (looks like he's flying :P)
	set_pev(id, pev_gaitsequence, 8)
}

// vector_to_angle port
stock vec_to_angle(Float:vector[3], Float:output[3])
{
	engfunc(EngFunc_VecToAngles, vector, output)
}

// Attack 2
public ev_attack2(id)
{
	// Play any of the 2 fire animations
	wpn_playanim(id, random_num(anim_fire3, anim_fire4))
	
	// Try to create a new rocket entity
	new rocket = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!rocket) return PLUGIN_CONTINUE
	
	// Strings
	set_pev(rocket, pev_classname, ENTITY_NAME)
	engfunc(EngFunc_SetModel, rocket, ROCKET_MDL)
	
	// Integer
	set_pev(rocket, pev_owner, id)
	set_pev(rocket, pev_movetype, MOVETYPE_FLY)
	set_pev(rocket, pev_solid, SOLID_BBOX)
	
	// Floats
	set_pev(rocket, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(rocket, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	// Calculate rocket start position
	new Float:fStart[3]
	wpn_projectile_startpos(id, 64, 12, -16, fStart)
	set_pev(rocket, pev_origin, fStart)
	
	// Calculate fly velocity
	new Float:fVel[3]
	velocity_by_aim(id, ROCKET_SPEED, fVel)		
	set_pev(rocket, pev_velocity, fVel)
	
	// Calculate rocket view direction
	new Float:fAngles[3]
	vec_to_angle(fVel, fAngles)
	set_pev(rocket, pev_angles, fAngles)
	
	// Add trail to rocket
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(rocket)
	write_short(g_trail)
	write_byte(25)
	write_byte(5)
	write_byte(224)
	write_byte(224)
	write_byte(255)
	write_byte(255)
	message_end()
	
	// Play fire sound
	emit_sound(rocket, CHAN_WEAPON, ROCKET_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return PLUGIN_CONTINUE
}

// Weapon drawed
public ev_draw(id)
	wpn_playanim(id, anim_draw)

// Called each time an entity was touched
public fwd_Touch(ptr, ptd)
{
	// Check if the toucher is actually a valid entity
	if(pev_valid(ptr))
	{
		static classname[32]
		pev(ptr, pev_classname, classname, 31)
		
		if(equal(classname, ENTITY_NAME))
		{
			// The toucher is a jetpack rocket, get the location
			new Float:fOrigin[3]
			pev(ptr, pev_origin, fOrigin)
			
			// Add explosion
			engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, fOrigin, 0)
			write_byte(TE_EXPLOSION)
			engfunc(EngFunc_WriteCoord, fOrigin[0])
			engfunc(EngFunc_WriteCoord, fOrigin[1])
			engfunc(EngFunc_WriteCoord, fOrigin[2])
			write_short(g_explosion)
			write_byte(30)
			write_byte(15)
			write_byte(0)
			message_end()
			
			// Get rocket owner which is actually the attacker and create a damage impact
			new attacker = pev(ptr, pev_owner)
			wpn_radius_damage(g_wpnid, attacker, ptr, ROCKET_RADIUS, ROCKET_DAMAGE, DMG_BLAST)
			
			if(pev_valid(ptd))
			{
				// Check if the touched entity is breakable, if so, break it :)
				pev(ptd, pev_classname, classname, 31)
				if(equal(classname, "func_breakable"))
					dllfunc(DLLFunc_Use, ptd, ptr)
			}
			
			// Kill the rocket
			set_pev(ptr, pev_flags, FL_KILLME)
		}
	}
}
