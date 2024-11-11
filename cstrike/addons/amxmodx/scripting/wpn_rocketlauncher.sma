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
new const PLUGIN[] = "WPN RocketLauncher"
new const VERSION[] = "0.42"
new const AUTHOR[] = "DevconeS"

// Weapon information
new WPN_NAME[] = "F-7 Plasma Rocket Launcher"
new WPN_SHORT[] = "rocket"

// Entity data
new ENTITY_NAME[] = "wpn_rpgrocket"

// Models
new P_MODEL[] = "models/p_rpg.mdl"
new V_MODEL[] = "models/v_rpg.mdl"
new W_MODEL[] = "models/w_rpg.mdl"

// Rocket model and sound
new ROCKET_MDL[] = "sprites/c-tele1.spr"
new ROCKET_SOUND[] = "wpnmod/plasma_rocket.wav"

// Rocket information
#define ROCKET_SPEED	600		// Rocket fly speed
#define ROCKET_RADIUS	500.0	// Rocket explosion radius
#define ROCKET_DAMAGE	300.0	// Rocket explosion damage (in center)
#define REACTION_SPEED	0.0		// How fast the rocket should react

// Trail information
new const ROCKET_TRAIL[][] = {{255, 255, 0}, {255, 0, 0}}	// Trail color of the rocket (RGB)

// User Rocket information
enum
{
	rocket_entity,	// Entity index
	rocket_mode,	// 0 = User aim, 1 = Remote Control
	rocket_nreact,	// Next reaction
}

// Animations
enum
{
	anim_idle,
	anim_fidget,
	anim_reload,
	anim_fire,
	anim_holster1,
	anim_draw1,
	anim_holster2,
	anim_draw2,
	anim_idle2,
	anim_fidget2
}

new g_UserRocket[33][5]
new g_wpnid
new g_Trail, g_Explosion

// Precache required files
public plugin_precache()
{
	precache_model(P_MODEL)
	precache_model(V_MODEL)
	precache_model(W_MODEL)
	
	precache_model(ROCKET_MDL)
	precache_sound(ROCKET_SOUND)
	
	g_Trail = precache_model("sprites/smoke.spr")
	g_Explosion = precache_model("sprites/c-tele1.spr")
}

// Initialize plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_Touch, "fwd_Touch")
	register_forward(FM_StartFrame, "fwd_StartFrame")
	
	create_weapon();
}

// Register weapon to WeaponMod
create_weapon()
{
	new wpnid = wpn_register_weapon(WPN_NAME, WPN_SHORT)
	if(!wpnid) return PLUGIN_CONTINUE
	
	// Strings
	wpn_set_string(wpnid, wpn_viewmodel, V_MODEL)
	wpn_set_string(wpnid, wpn_weaponmodel, P_MODEL)
	wpn_set_string(wpnid, wpn_worldmodel, W_MODEL)
	
	// Event handlers
	wpn_register_event(wpnid, event_attack1, "ev_attack2")
	wpn_register_event(wpnid, event_attack2, "ev_attack1")
	wpn_register_event(wpnid, event_draw, "ev_draw")
	wpn_register_event(wpnid, event_reload, "ev_reload")
	wpn_register_event(wpnid, event_hide, "ev_hide")
	
	// Floats
	wpn_set_float(wpnid, wpn_refire_rate1, 1.0)
	wpn_set_float(wpnid, wpn_refire_rate2, 1.0)
	wpn_set_float(wpnid, wpn_reload_time, 1.0)
	wpn_set_float(wpnid, wpn_recoil1, 3.0)
	wpn_set_float(wpnid, wpn_recoil2, 3.0)
	wpn_set_float(wpnid, wpn_run_speed, 200.0)
	
	// Integers
	wpn_set_integer(wpnid, wpn_ammo1, 1)
	wpn_set_integer(wpnid, wpn_ammo2, 7)
	wpn_set_integer(wpnid, wpn_bullets_per_shot1, 1)
	wpn_set_integer(wpnid, wpn_bullets_per_shot2, 1)
	wpn_set_integer(wpnid, wpn_cost, 89000)
	
	g_wpnid = wpnid
	
	return PLUGIN_CONTINUE
}

// Attack 1 (remotely controlled missle)
public ev_attack1(id)
{
	if(g_UserRocket[id][rocket_entity] != -1) return PLUGIN_CONTINUE
	shoot_rocket(id, 0)
	return PLUGIN_CONTINUE
}

// Attack 2 (attached view)
public ev_attack2(id)
{
	if(g_UserRocket[id][rocket_entity] != -1) return PLUGIN_CONTINUE
	shoot_rocket(id, 1)
	return PLUGIN_CONTINUE
}

// Weapon draw
public ev_draw(id)
{
	new wpn = wpn_has_weapon(id, g_wpnid)
	if(wpn_get_userinfo(id, usr_wpn_ammo1, wpn) > 0)
		wpn_playanim(id, anim_draw1)	// Draw with rocket in rpg
	else
		wpn_playanim(id, anim_draw2)	// Draw without rocket in rpg
}

// Reload
public ev_reload(id)
{
	wpn_playanim(id, anim_reload)
}

// Hide
public ev_hide(id)
{
	new wpn = wpn_has_weapon(id, g_wpnid)
	if(wpn_get_userinfo(id, usr_wpn_ammo1, wpn) > 0)
		wpn_playanim(id, anim_fidget)	// Fidget with rocket in rpg
	else
		wpn_playanim(id, anim_fidget2)// Fidgets without rocket in rpg
}

// Fires rocket using the specified mode
shoot_rocket(id, mode)
{
	// Try to create a new entity
	new rocket = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!rocket) return PLUGIN_CONTINUE
	
	// Strings
	set_pev(rocket, pev_classname, ENTITY_NAME)
	engfunc(EngFunc_SetModel, rocket, ROCKET_MDL)
	
	// Integer
	set_pev(rocket, pev_owner, id)
	set_pev(rocket, pev_movetype, MOVETYPE_FLY)
	set_pev(rocket, pev_solid, SOLID_BBOX)
	set_pev(rocket,pev_rendermode,kRenderTransAdd)
	set_pev(rocket,pev_renderamt,255.0) 
		
	
	// Floats
	set_pev(rocket, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(rocket, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	// Calculate start position and view of the rocket
	new Float:fAim[3], Float:fAngles[3], Float:fOrigin[3]
	velocity_by_aim(id, 64, fAim)
	vector_to_angle(fAim, fAngles)
	pev(id, pev_origin, fOrigin)
	
	fOrigin[0] += fAim[0]
	fOrigin[1] += fAim[1]
	fOrigin[2] += fAim[2]
	
	// Set the origin and view
	set_pev(rocket, pev_origin, fOrigin)
	set_pev(rocket, pev_angles, fAngles)
	
	// If we used secondary fire (mode 1), the user view's attached to the rocket
	if(mode == 1)
		engfunc(EngFunc_SetView, id, rocket)
	
	// Calculate rocket flight speed
	new Float:fVel[3]
	velocity_by_aim(id, ROCKET_SPEED, fVel)	
	set_pev(rocket, pev_velocity, fVel)
	
	// Keep some information about the rocket
	g_UserRocket[id][rocket_entity] = rocket
	g_UserRocket[id][rocket_mode] = mode
	g_UserRocket[id][rocket_nreact] = floatround((get_gametime()+REACTION_SPEED)*1000)
	
	// Add trail
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)	// Temp entity type
	write_short(rocket)		// entity
	write_short(g_Trail)	// sprite index
	write_byte(25)	// life time in 0.1's
	write_byte(5)	// line width in 0.1's
	write_byte(ROCKET_TRAIL[mode][0])	// red (RGB)
	write_byte(ROCKET_TRAIL[mode][1])	// green (RGB)
	write_byte(ROCKET_TRAIL[mode][2])	// blue (RGB)
	write_byte(255)	// brightness 0 invisible, 255 visible
	message_end()
	
	// Play fire sound
	emit_sound(rocket, CHAN_WEAPON, ROCKET_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return PLUGIN_CONTINUE
}

// Called each time a new frame starts
public fwd_StartFrame()
{
	// Declare static variables
	static Float:gtime
	static ctime
	static nreact
	static id
	
	// Declare rocket information variables
	static rocket, iOrigin[3], Float:fOrigin[3], Float:Vel[3], Float:Angles[3]
	
	// Get data
	gtime = get_gametime()
	ctime = floatround(gtime*1000)
	floatround((gtime+REACTION_SPEED)*1000)
	
	// Cycle through all players
	for(id = 1; id < 33; id++)
	{
		// If the user is not alive, does not have the rpg weapon and
		// even isn't in the attached view mode, we do nothing in here
		if(!is_user_alive(id) && wpn_has_weapon(id, g_wpnid) == -1 && g_UserRocket[id][rocket_mode] == 0) continue
		
		// The delay time hasn't been reached yet
		if(g_UserRocket[id][rocket_nreact] > ctime) continue
		g_UserRocket[id][rocket_nreact] = nreact
		
		// Get the rocket entity
		rocket = g_UserRocket[id][rocket_entity]
		if(rocket != -1 && pev_valid(rocket))
		{
			// The rocket entity is still valid, now do the specified action
			switch(g_UserRocket[id][rocket_mode])
			{
				case 0:	// Follow player's aim
				{
					// Get player's target origin
					get_user_origin(id, iOrigin, 3)
					
					// Reformat to floats
					fOrigin[0] = float(iOrigin[0])
					fOrigin[1] = float(iOrigin[1])
					fOrigin[2] = float(iOrigin[2])
					
					// Set rocket's view to player's view and change the velocity
					wpn_set_entity_view(rocket, fOrigin)
					velocity_by_aim(rocket, ROCKET_SPEED, Vel)
					set_pev(rocket, pev_velocity, Vel)
				}
				
				case 1:	// Attached view mode
				{
					// Get player's aim and update rocket's aim
					velocity_by_aim(id, ROCKET_SPEED, Vel)
					set_pev(rocket, pev_velocity, Vel)
					
					// Reformat velocity to angles
					vector_to_angle(Vel, Angles)
					/*Angles[0] = 360-Angles[0]
					set_pev(rocket, pev_angles, Angles)*/
					
					// Do some calculations so the view of the rocket looks fine
					Angles[0] = 360-Angles[0]
					set_pev(rocket, pev_angles, Angles)
					Angles[0] *= -1
					set_pev(rocket, pev_v_angle, Angles)
					//set_pev(rocket, pev_fixangle, 1)
				}
			}
		}
	}
	return FMRES_IGNORED
}

// Client disconnected, reset his data
public client_connect(id)
{
	g_UserRocket[id][rocket_entity] = -1
	g_UserRocket[id][rocket_nreact] = 0
}

// Called each time an entity was touched
public fwd_Touch(ptr, ptd)
{
	if(pev_valid(ptr))
	{
		// Valid entity, check if it's a rocket
		static classname[32]
		pev(ptr, pev_classname, classname, 31)
		
		if(equal(classname, ENTITY_NAME))
		{
			// RPG Rocket, get origin
			new Float:fOrigin[3]
			pev(ptr, pev_origin, fOrigin)
			
			// Explosion
			engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, fOrigin, 0)
			write_byte(TE_EXPLOSION)
			engfunc(EngFunc_WriteCoord, fOrigin[0])
			engfunc(EngFunc_WriteCoord, fOrigin[1])
			engfunc(EngFunc_WriteCoord, fOrigin[2])
			write_short(g_Explosion)
			write_byte(30)
			write_byte(15)
			write_byte(0)
			message_end()
			
			// Create damage impact on rocket's location
			new attacker = pev(ptr, pev_owner)
			wpn_radius_damage(g_wpnid, attacker, ptr, ROCKET_RADIUS, ROCKET_DAMAGE, DMG_BLAST)
			
			if(pev_valid(ptd))
			{
				// Check if the touched entity is breakable, if so, break it :)
				pev(ptd, pev_classname, classname, 31)
				if(equal(classname, "func_breakable"))
					dllfunc(DLLFunc_Use, ptd, ptr)
			}
			
			// Kill the rocket and reset data
			set_pev(ptr, pev_flags, FL_KILLME)
			g_UserRocket[attacker][rocket_entity] = -1
			
			// Remove view from rocket
			if(g_UserRocket[attacker][rocket_mode] == 1)
			{
				engfunc(EngFunc_SetView, attacker, attacker)
			}
		}
	}
	return FMRES_IGNORED
}