/************************************************************************************
* Copyright (C) 2006-2010 Space Headed Productions									*
* 																					*
* WeaponMod is free software; you can redistribute it and/or						*
* modify it under the terms of the GNU General Public License						*
* as published by the Free Software Foundation.										*
*																					*
* WeaponMod is distributed in the hope that it will be useful, 						*
* but WITHOUT ANY WARRANTY; without even the implied warranty of					*
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the						*
* GNU General Public License for more details.										*
*																					*
* You should have received a copy of the GNU General Public License					*
* along with WeaponMod; if not, write to the Free Software							*
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.		*
************************************************************************************/

/************************************************************************************
* Change Log:																		*
* v1.0 - Beta.																		*
* v1.1 - Released.																	*
* v1.2 - Fixed ugly loooooooooooong time screenfade bug.							*
* v1.3 - Fixed noise sound bug.														*
* v1.4 - Fixed crashed.																*
* v1.5 - Fixed animation.															*
* v2.0 - Plugin Rewritten.															*
************************************************************************************/

#include <amxmodx>
#include <fakemeta>
#include <weaponmod>
#include <weaponmod_stocks>

/******** EDITABLE ZONE ********/
#define NUKE_SPEED	500
#define NUKE_RADIUS	1500.0
#define NUKE_MAXDAMAGE	1200.0
#define NUKE_MIXDAMAGE	800.0
/****** EDITABLE ZONE END ******/

new const
	PLUGIN[ ]	= "WPN N74-Redeemer", 
	VERSION[ ]	= "2.0", 
	AUTHOR[ ]	= "A.F."

new WPN_NAME[ ] = "N74-Redeemer"
new WPN_SHORT[ ] = "N74"

new P_MODEL[ ] = "models/wpnmod/N74/p_nukelauncher.mdl"
new V_MODEL[ ] = "models/wpnmod/N74/v_nukelauncher.mdl"
new W_MODEL[ ] = "models/wpnmod/N74/w_nukelauncher.mdl"
new NUKE_MDL[ ] = "models/wpnmod/N74/nuke_missile.mdl"

enum SOUNDLIST
{
	FIRE = 0, 
	EXPLODE, 
	WARNING, 
	MISSILE, 
	RELOAD
}

new ACTION_SOUND[SOUNDLIST][ ] =
{
	"wpnmod/N74/nuke_firing.wav", 
	"wpnmod/N74/nuke_explode.wav", 
	"wpnmod/N74/nuke_warn.wav", 
	"wpnmod/N74/nuke_missile.wav", 
	"wpnmod/N74/nuke_reload.wav" 
}

// Sequences
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
	anim_idle2 
}

new g_wpnid
new NukeTrail, NukeFade, NukeShake, NukeFire

public plugin_precache( )
{
	precache_model( P_MODEL )
	precache_model( V_MODEL )
	precache_model( W_MODEL )
	precache_model( NUKE_MDL )

	precache_sound( "wpnmod/N74/nuke_fire2.wav" )
	precache_sound( "wpnmod/N74/nuke_explosion2.wav" )
	precache_sound( "wpnmod/N74/nuke_warn.wav" )
	precache_sound( "wpnmod/N74/nuke_missile.wav" )
	precache_sound( "wpnmod/N74/nuke_reload.wav" )

	NukeFire = precache_model( "sprites/wpnmod/nuke_fire.spr" )
	NukeTrail = precache_model( "sprites/smoke.spr" )
}

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR )
	register_forward( FM_Touch, "fwd_Touch" )
	NukeFade = get_user_msgid( "ScreenFade" )
	NukeShake = get_user_msgid( "ScreenShake" )
	create_weapon( )
}

create_weapon( )
{
	new wpnid = wpn_register_weapon( WPN_NAME, WPN_SHORT )

	if( wpnid == -1 )
		return PLUGIN_CONTINUE

	wpn_set_string( wpnid, wpn_viewmodel, V_MODEL )
	wpn_set_string( wpnid, wpn_weaponmodel, P_MODEL )
	wpn_set_string( wpnid, wpn_worldmodel, W_MODEL )

	wpn_register_event( wpnid, event_attack1, "ev_attack1" )
	wpn_register_event( wpnid, event_draw, "ev_draw" )
	wpn_register_event( wpnid, event_hide, "ev_hide" )
	wpn_register_event( wpnid, event_reload, "ev_reload" )

	wpn_set_float( wpnid, wpn_refire_rate1, 10.0 )
	wpn_set_float( wpnid, wpn_reload_time, 10.0 )
	wpn_set_float( wpnid, wpn_recoil1, 10.0 )
	wpn_set_float( wpnid, wpn_run_speed, 100.0 )

	wpn_set_integer( wpnid, wpn_ammo1, 1 )
	wpn_set_integer( wpnid, wpn_ammo2, 2 )
	wpn_set_integer( wpnid, wpn_bullets_per_shot1, 1 )
	wpn_set_integer( wpnid, wpn_cost, 300000 )

	g_wpnid = wpnid

	return PLUGIN_CONTINUE
}

public ev_attack1( id )
{
	wpn_playanim( id, anim_fire )

	new iNuke = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) )
	if( !iNuke ) return PLUGIN_CONTINUE

	// Strings
	set_pev( iNuke, pev_classname, "wpn_nukemissile" )
	engfunc( EngFunc_SetModel, iNuke, NUKE_MDL )

	// Integer
	set_pev( iNuke, pev_owner, id )
	set_pev( iNuke, pev_movetype, MOVETYPE_FLY )
	set_pev( iNuke, pev_solid, SOLID_BBOX )

	// Floats
	set_pev( iNuke, pev_mins, Float:{ -1.0, -1.0, -1.0 } )
	set_pev( iNuke, pev_maxs, Float:{ 1.0, 1.0, 1.0 } )

	new Float:fStart[3], Float:fVel[3], Float:fAngles[3]

	wpn_projectile_startpos( id, 40, 0, 10, fStart )
	set_pev( iNuke, pev_origin, fStart )

	velocity_by_aim( id, NUKE_SPEED, fVel )
	set_pev( iNuke, pev_velocity, fVel )

	vec_to_angle( fVel, fAngles )
	set_pev( iNuke, pev_angles, fAngles )

	message_begin( MSG_PVS, SVC_TEMPENTITY )
	write_byte( TE_BEAMFOLLOW )
	write_short( iNuke )
	write_short( NukeTrail )
	write_byte( 25 )
	write_byte( 5 )
	write_byte( 224 )
	write_byte( 224 )
	write_byte( 255 )
	write_byte( 255 )
	message_end( )

	emit_sound( iNuke, CHAN_VOICE, ACTION_SOUND[WARNING], 1.0, ATTN_NORM, 0, PITCH_NORM )
	emit_sound( iNuke, CHAN_ITEM, ACTION_SOUND[MISSILE], 1.0, ATTN_NORM, 0, PITCH_NORM )
	emit_sound( id, CHAN_WEAPON, ACTION_SOUND[FIRE], 1.0, ATTN_NORM, 0, PITCH_NORM )

	return PLUGIN_CONTINUE
}

public ev_draw( id )
{
	static wpn; wpn = wpn_has_weapon( id, g_wpnid )
	if( wpn_get_userinfo( id, usr_wpn_ammo1, wpn ) > 0 )
		wpn_playanim( id, anim_draw1 )	// Draw with rocket in rpg
	else
		wpn_playanim( id, anim_draw2 )	// Draw without rocket in rpg
}

public ev_hide( id )
{
	static wpn; wpn = wpn_has_weapon( id, g_wpnid )
	if( wpn_get_userinfo( id, usr_wpn_ammo1, wpn ) > 0 )
		wpn_playanim( id, anim_holster1 )	// Draw with rocket in rpg
	else
		wpn_playanim( id, anim_holster2 )	// Draw without rocket in rpg
}

public ev_reload( id )
{
	wpn_playanim( id, anim_reload )
	emit_sound( id, CHAN_VOICE, ACTION_SOUND[RELOAD], 1.0, ATTN_NORM, 0, PITCH_NORM )
}

public fwd_Touch( ptr, ptd )
{
	if( pev_valid( ptr ) && pev_valid( ptr ) )
	{
		new classname[32]
		pev( ptr, pev_classname, classname, sizeof( classname ) )
		
		if( equal( classname, "wpn_nukemissile" ) )
		{
			new Float:fOrigin[3]
			pev( ptr, pev_origin, fOrigin )

			new id = -1
			while( ( id = engfunc( EngFunc_FindEntityInSphere, id, fOrigin, NUKE_RADIUS + 8000 ) ) != 0 )
			{
				//players?
				if( pev_valid( id ) && pev( id, pev_flags ) & ( FL_CLIENT | FL_FAKECLIENT ) )
				{
					message_begin( MSG_ONE_UNRELIABLE, NukeFade, {0, 0, 0}, id )
					write_short( 1<<11 )	// fade lasts this long furation
					write_short( 1<<11 )	// fade lasts this long hold time
					write_short( 1<<12 )	// fade type ( in / out )
					write_byte( 255 )		//r
					write_byte( 255 )		//g
					write_byte( 255 )		//b
					write_byte( 255 )
					message_end( )

					message_begin( MSG_ONE_UNRELIABLE, NukeShake, {0, 0, 0}, id )
					write_short( 255<<8 )	// shake amount
					write_short( 90<<14 )	// shake lasts this long
					write_short( 255<<8 )	// shake noise frequency
					message_end( )
				}
				//next player in spehre.
				continue
			}
			
			engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0 )
			write_byte( TE_EXPLOSION )
			engfunc( EngFunc_WriteCoord, fOrigin[0] )
			engfunc( EngFunc_WriteCoord, fOrigin[1] )
			engfunc( EngFunc_WriteCoord, fOrigin[2] )
			write_short( NukeFire )
			write_byte( 188 )		// byte ( scale in 0.1's ) 188
			write_byte( 5 )			// byte ( framerate )
			write_byte( 0 )			// byte flags
			message_end( )
			
			new attacker = pev( ptr, pev_owner )
			wpn_radius_damage( g_wpnid, attacker, ptr, NUKE_RADIUS, random_float( NUKE_MIXDAMAGE, NUKE_MAXDAMAGE ), DMG_BLAST )
			wpn_entity_radius_damage( attacker, random_float( NUKE_MIXDAMAGE, NUKE_MAXDAMAGE ), fOrigin, NUKE_RADIUS )
			emit_sound( ptr, CHAN_WEAPON, ACTION_SOUND[EXPLODE], 1.0, ATTN_NORM, 0, PITCH_NORM )
			set_pev( ptr, pev_flags, FL_KILLME )
		}
	}
}

stock vec_to_angle( Float:vector[3], Float:output[3] )
{
	new Float:angles[3]
	engfunc( EngFunc_VecToAngles, vector, angles )
	output[0] = angles[0]
	output[1] = angles[1]
	output[2] = angles[2]
}