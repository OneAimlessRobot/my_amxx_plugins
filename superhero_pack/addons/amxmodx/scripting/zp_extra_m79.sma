/*
	[ZP] Extra Item: M79 Grenade Launcher
	Copyright (C) 2009-2010 by NiHiLaNTh

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.

	--- Introduction ---
	This plugin add new weapon to zombie plague - m79 grenade launcher.This
	is powerful weapon which shoot with grenades.It has 1 grenade in a clip
	and 10 in back pack.Also you can buy grenades for M79.To get this plugin
	work correctly, put plugin name in plugins-zplague.ini BEFORE MAIN PLUGIN.
	
	--- CVARs ---
	zp_m79_maxdmg 450 -- Maximal damage
	zp_m79_radius 500 -- Damage radius
	zp_m79_oneround 1 -- If 1 weapon will stay only 1 round
	zp_m79_knockback 10 -- Knockback power
	
	--- Credits ---
	NiHiLaNTh - Plugin
	Shalun - M79 model
	meTaLiCroSS - FM_SetModel, EV_INT_WEAPONKEY
	Arkshine - Play weapon animation stock/grenade angles
	
	--- Changelog ---
	v1.0 - Initial release 
	v1.1 - Completely rewrited plugin
	v1.2 - Fixed bug with unlimited ammo
	     - Removed a lot of unnecessary code
*/

#include < amxmodx >
#include < cstrike >
#include < engine >
#include < fakemeta >
#include < fun >
#include < hamsandwich >
#include < zombieplague >

// Version
#define VERSION "1.2"

// Maxplayers
#define MAXPLAYERS		32

// FCVAR stuff
#define FCVAR_FLAGS		( FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED )

// Null
#define NULLENT			-1

// EV_INT field used to store ak47 index
#define EV_INT_WEAPONKEY	EV_INT_impulse

// pev_ field used to stor m79 bpammo
#define pev_weaponammo		pev_iuser2

// M79 weapon key
#define M79_WEAPONKEY		1756

// CS offsets
#define OFFSET_PLAYER		41
#define OFFSET_NEXTPRIMATTACK	46
#define OFFSET_NEXTSECATTACK	47
#define OFFSET_WEAPONIDLE	48
#define OFFSET_PRIMAMMOTYPE	49
#define OFFSET_CLIP		51
#define OFFSET_RELOAD		54
#define OFFSET_NEXTATTACK	83
#define OFFSET_PLAYERSLOT	376
#define LINUX_DIFF		4
#define LINUX_DIFF_WPN		5

//================================ Customization starts below ==============================
#define MAXCLIP			1 // I strictly recommend you to dont change this value!^^
#define MAXBPAMMO		10 // Bp ammo
#define RELOAD_TIME		3.2 // Don't set this lower that 3.0
#define REFIRE_RATE		1.5 // Refire rate
#define TRAIL_RED		255 // (0-255).Red amount in trail
#define TRAIL_GREEN		255 // (0-255).Green amount in trail
#define TRAIL_BLUE		255 // (0-255).Blue amount in trail

// Grenade model
new const grenade_model [ ] = "models/grenade.mdl"

// Sounds
new const fire_sound [ ] [ ] = { "weapons/m79_fire1.wav", "weapons/m79_fire2.wav" }
new const sound_buy [ ] [ ] =  { "items/9mmclip1.wav" }
//================================ Customization end! =======================================
// Models
new const p_m79 [ ] = "models/p_m79.mdl"
new const v_m79 [ ] = "models/v_m79.mdl" // You should'nt change this model
new const w_m79 [ ] = "models/w_m79.mdl"

// Little note about sounds listed below.If you are using original weapon models (which are
// provdied in this plugin) DON'T CHANGE SOUND PATHS, or you'll not hear reload sound.
new const sound_reload [ ] [ ] = { "weapons/m79_clipin.wav", "weapons/m79_clipon.wav", "weapons/m79_clipout.wav" }

// Entities
new const g_DefaultEntity [ ] = "info_target"
new const g_GrenadeEntity [ ] = "zp_m79_grenade"
new const g_AkEntity [ ] = "weapon_ak47"
new const g_PlayerEntity [ ] = "player"

// Cached sprite indexes
new m_iTrail, m_iExplo

// Player variables
new g_hasLauncher [ MAXPLAYERS+1 ] 
new Float:g_LastShotTime [ MAXPLAYERS+1 ]
new g_CurrentWeapon [ MAXPLAYERS+1 ]

// Global variables
new g_MaxPlayers, g_Restarted

// Booleans
new bool:bIsAlive [ MAXPLAYERS+1 ]

// CVAR pointers
new cvar_maxdmg, cvar_radius, cvar_oneround, cvar_knockback

// Item IDs
new g_m79, g_m79nade

// Message ID
new g_msgScoreInfo, g_msgDeathMsg, g_msgAmmoPickup, g_msgCurWeapon, g_msgAmmoX

// Animation sequences
enum
{
	m79_idle,
	m79_shoot1, // Shoot & Reload
	m79_shoot2,
	m79_draw
}

// Primary weapons bit-sum
const PRIMARY_WEAPONS_BITSUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

// Precache
public plugin_precache ( )
{
	// Models
	precache_model ( p_m79 )
	precache_model ( v_m79 )
	precache_model ( w_m79 )
	precache_model ( grenade_model )
	
	// Sound
	new i
	for ( i = 0 ; i < sizeof fire_sound; i++ )
		precache_sound ( fire_sound [ i ] )
	for ( i = 0 ; i < sizeof sound_buy; i++ )
		precache_sound ( sound_buy [ i ] )	
	for ( i = 0; i < sizeof sound_reload; i++ )
		precache_sound ( sound_reload [ i ] )

	// Sprites
	m_iTrail = precache_model ( "sprites/laserbeam.spr" )
	m_iExplo = precache_model ( "sprites/zerogxplode.spr" )
}

// Initialization
public plugin_init ( )
{
	// New plugin
	register_plugin ( "[ZP] Extra Item:M79", VERSION, "NiHiLaNTh" )
	
	// Game-Monitor support
	register_cvar ( "zp_m79_version", VERSION, FCVAR_FLAGS )
	
	// New extra items
	g_m79 = zp_register_extra_item ( "M79 Grenade Launcher", 25, ZP_TEAM_HUMAN )
	g_m79nade = zp_register_extra_item ( "40mm M79 Grenade", 5, ZP_TEAM_HUMAN )
	
	// Buyammo1 commands from zombie plague
	register_clcmd ( "buyammo1", "clcmd_buyammo1" )
	register_clcmd ( "buyammo2", "clcmd_buyammo1" )
	
	// Events
	register_event("CurWeapon", "Event_CurrentWeapon", "be", "1=1")
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_event("TextMsg", "Event_GameRestart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in")
	register_event ( "DeathMsg", "Event_DeathMsg", "a" )
	
	// Forwards
	register_forward ( FM_CmdStart, "fw_CmdStart" )
	register_forward ( FM_UpdateClientData, "fw_UpdateClientData_Post", 1 )
	register_forward ( FM_SetModel, "fw_SetModel" )
	RegisterHam ( Ham_Item_Deploy, g_AkEntity, "fw_LauncherDeploy_Post", 1 )
	RegisterHam ( Ham_Item_AddToPlayer, g_AkEntity, "fw_LauncherAddToPlayer" )
	RegisterHam ( Ham_Item_PostFrame, g_AkEntity, "fw_LauncherPostFrame" )
	RegisterHam ( Ham_Spawn, g_PlayerEntity, "fw_PlayerSpawn_Post", 1 )
	
	// Touch
	register_touch ( g_GrenadeEntity, "*", "touch_m79nade" )
	
	// CVARs
	cvar_maxdmg = register_cvar ( "zp_m79_maxdmg", "450" )
	cvar_radius = register_cvar ( "zp_m79_radius", "500" )
	cvar_oneround = register_cvar ( "zp_m79_oneround", "1" )
	cvar_knockback = register_cvar ( "zp_m79_knockback" ,"10" )
	
	// Message
	g_msgScoreInfo = get_user_msgid ( "ScoreInfo" )
	g_msgDeathMsg = get_user_msgid ( "DeathMsg" )
	g_msgAmmoPickup = get_user_msgid ( "AmmoPickup" )
	g_msgCurWeapon = get_user_msgid ( "CurWeapon" )
	g_msgAmmoX = get_user_msgid ( "AmmoX" )

	// Maxplayers
	g_MaxPlayers = get_maxplayers ( )
}

// Connected
public client_connect ( Player )
{
	bIsAlive [ Player ] = false
}

// Disconnect
public client_disconnect ( Player )
{
	// Update
	g_hasLauncher [ Player ] = false
	bIsAlive [ Player ] = false
}

// User infected post
public zp_user_infected_post ( Player, Infector )
{
	g_hasLauncher [ Player ] = false
}

// User transfered into Survivor
public zp_user_humanized_post ( Player, Survivor )
{
	g_hasLauncher [ Survivor ] = false
}

// Buy ammo attempt
public clcmd_buyammo1 ( Player )
{
	// Block ammo buying while holding M79
	if ( g_hasLauncher [ Player ] )
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}

// Buy an extra item
public zp_extra_item_selected ( Player, Item )
{
	// M79
	if ( Item == g_m79 )
	{
		// Already own it
		if ( g_hasLauncher [ Player ] )
		{
			// Warning
			client_print ( Player, print_chat, "[ZP] Already have M79 Grenade Launcher" )
			return ZP_PLUGIN_HANDLED
		}
		else
		{
			// Drop primary guns
			drop_primary_weapons ( Player ) 
			
			// Update array
			g_hasLauncher [ Player ] = true
			
			// Ak47
			give_item ( Player, g_AkEntity )
			
			// Clip ammo
			new ak = find_ent_by_owner ( NULLENT, g_AkEntity, Player )
			set_pdata_int ( ak, OFFSET_CLIP, MAXCLIP, LINUX_DIFF )
			
			// BP ammo
			cs_set_user_bpammo ( Player, CSW_AK47, MAXBPAMMO )
		}
	}
	// M79 grenade
	else if ( Item == g_m79nade )
	{	
		// Don't have Launcher
		if ( !g_hasLauncher [ Player ] )
		{
			client_print ( Player, print_chat, "[ZP] You don't have M79 Grenade Launcher" )
			return ZP_PLUGIN_HANDLED
		}
		
		// Too many grenades
		new bpammo = cs_get_user_bpammo ( Player, CSW_AK47 )
		if ( bpammo >= MAXBPAMMO )
		{
			client_print ( Player, print_chat, "[ZP] You cannot buy more Grenades" )
			return ZP_PLUGIN_HANDLED
		}
		else
		{
			// Ammo pickup
			message_begin ( MSG_ONE, g_msgAmmoPickup, _, Player )
			write_byte ( 12 ) // Ammo ID
			write_byte ( 1 ) // Ammo amount
			message_end ( )
			
			// Buy sound
			emit_sound ( Player, CHAN_ITEM, sound_buy[random_num(0, sizeof sound_buy-1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM )
			
			// Increase bp ammo
			cs_set_user_bpammo ( Player, CSW_AK47, bpammo+1 )
	
		}
	}		
		
	return PLUGIN_CONTINUE
}

// Current weapon player is holding
public Event_CurrentWeapon ( Player )
{
	// Not alive or dont have M79
	if ( !bIsAlive [ Player ] || !g_hasLauncher [ Player ] )
		return PLUGIN_CONTINUE
		
	// Update
	g_CurrentWeapon [ Player ] = read_data ( 2 )
		
	// AK47	
	if ( g_CurrentWeapon [ Player ] == CSW_AK47 )
	{
		// Models
		set_pev ( Player, pev_viewmodel2, v_m79 )
		set_pev ( Player, pev_weaponmodel2, p_m79 )
		
		// Find ak47
		new ak47 = find_ent_by_owner ( -1, "weapon_ak47", Player )
		
		// Get clip
		new clip = cs_get_weapon_ammo ( ak47 )
		
		// Get bp ammo
		new bpammo = cs_get_user_bpammo ( Player, CSW_AK47 )
		
		// We have more than required
		if ( clip > MAXCLIP || bpammo > MAXBPAMMO )
		{
			// Return it back
			cs_set_weapon_ammo ( ak47, MAXCLIP )
			cs_set_user_bpammo ( Player, CSW_AK47, MAXBPAMMO )
			
			// Call for HUD update
			update_hud ( Player )
		}
	}
	return PLUGIN_CONTINUE
}

// New round started
public Event_NewRound ( )
{
	// Game was restarted
	if ( g_Restarted )
	{
		// Update
		arrayset ( g_hasLauncher, false, 33 )
	}
	
	// Update
	g_Restarted = false
	
	// One round cvar
	if ( get_pcvar_num ( cvar_oneround ) >= 1 )
	{
	
		// Loop
		for ( new i  = 1; i < g_MaxPlayers; i++ )
		{
			// Remove ak47 from inventory
			ham_strip_user_gun ( i, "weapon_ak47" )
		}
	}	
}

// Restart
public Event_GameRestart ( )
{
	g_Restarted = true
}

// Someone died
public Event_DeathMsg ( )
{
	// Get victim
	new victim = read_data ( 2 )
	
	// Not connected
	if ( !is_user_connected ( victim ) )
		return
		
	// Update
	bIsAlive [ victim ] = false
		
	if ( g_hasLauncher [ victim ] )
	{
		// Force to drop
		engclient_cmd ( victim, "drop" )
	}
}

// Cmd start
public fw_CmdStart ( Player, UC_Handle, Seed )
{
	// Not alive / dont have m79 / weapon isnt ak47
	if ( !bIsAlive [ Player ] || !g_hasLauncher [ Player ] || g_CurrentWeapon [ Player ] != CSW_AK47 )
		return FMRES_IGNORED
		
	// Get buttons
	static buttons ; buttons = get_uc ( UC_Handle, UC_Buttons )
	
	// Primary attack button
	if ( buttons & IN_ATTACK )
	{
		// Remove attack buttons from their button mask
		buttons &= ~IN_ATTACK
		set_uc ( UC_Handle, UC_Buttons, buttons )
		
		// No way...That's too  fast
		if ( get_gametime ( ) - g_LastShotTime [ Player ] < REFIRE_RATE )
			return FMRES_IGNORED
		
		// Weapon entity
		static ak47 ; ak47 = find_ent_by_owner ( NULLENT, g_AkEntity, Player )
		
		// Clip
		static Clip ; Clip = get_pdata_int ( ak47, OFFSET_CLIP, LINUX_DIFF )
		
		// Out of ammo ?
		if ( Clip <= 0 ) return FMRES_IGNORED
		
		// Reloading ?
		static Reload ; Reload = get_pdata_int ( ak47, OFFSET_RELOAD, LINUX_DIFF )
		
		// Don't fire while reloading
		if ( Reload ) return FMRES_IGNORED
		
		// Bp ammo
		static BpAmmo ; BpAmmo = cs_get_user_bpammo ( Player, CSW_AK47 )
		
		// Fire!!
		FireGrenade ( Player )
				
		// Decrease ammo count
		cs_set_weapon_ammo ( ak47, Clip-1 )
						
		// Remember last shot time
		g_LastShotTime [ Player ] = get_gametime ( )
				
		// We are out of ammo
		if ( Clip <= 0 && BpAmmo <= 0 )
		{
			// Empty sound
			ExecuteHamB ( Ham_Weapon_PlayEmptySound, ak47 )
			return FMRES_IGNORED
		}
	}
	return FMRES_HANDLED
}

// Update client data post
public fw_UpdateClientData_Post ( Player, SendWeapons, CD_Handle )
{
	// Not alive / dont have m79 / weapon isnt ak47
	if ( !bIsAlive [ Player ] || !g_hasLauncher [ Player ] || g_CurrentWeapon [ Player ] != CSW_AK47 )
		return FMRES_IGNORED
		
	// Block default sounds/animations
	set_cd ( CD_Handle, CD_flNextAttack, halflife_time ( ) + 0.001 )
	return FMRES_HANDLED
}

// Set world model(meTaLiCroSS)
public fw_SetModel ( Entity, const Model [ ] )
{
	// Entity is not valid
	if ( !is_valid_ent ( Entity ) )
		return FMRES_IGNORED
		
	// Not ak47
	if ( !equal ( Model, "models/w_ak47.mdl" ) ) 
		return FMRES_IGNORED;
		
	// Get classname
	static szClassName [ 33 ]
	entity_get_string ( Entity, EV_SZ_classname, szClassName, charsmax ( szClassName ) )
		
	// Not a Weapon box
	if ( !equal ( szClassName, "weaponbox" ) )
		return FMRES_IGNORED
	
	// Some vars
	static iOwner, iStoredAkID
	
	// Get owner
	iOwner = entity_get_edict ( Entity, EV_ENT_owner )
	
	// Get drop weapon index
	iStoredAkID = find_ent_by_owner ( NULLENT, "weapon_ak47", Entity )
	
	// Entity classname is weaponbox, and ak47 was founded
	if( g_hasLauncher [ iOwner ] && is_valid_ent ( iStoredAkID ) )
	{
		// Setting weapon options
		entity_set_int ( iStoredAkID, EV_INT_WEAPONKEY, M79_WEAPONKEY )
		
		// Save bp ammo
		set_pev ( iStoredAkID, pev_weaponammo, cs_get_user_bpammo ( iOwner, CSW_AK47 ) )
		
		// Reset user vars
		g_hasLauncher [ iOwner ] = false
		
		// Replace world model
		entity_set_model ( Entity, w_m79 )
		
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

// Launcher deploy
public fw_LauncherDeploy_Post ( Launcher )
{
	// Owner
	new Player = get_pdata_cbase ( Launcher, OFFSET_PLAYER, LINUX_DIFF_WPN )
	
	// Owns Launcher
	if ( g_hasLauncher [ Player ] )
	{
		// Deploy animation
		UTIL_PlayWeaponAnimation ( Player, m79_draw )
	}
	return HAM_IGNORED
}

// Give launcher to a player
public fw_LauncherAddToPlayer ( Launcher, Player )
{
	// Make sure that this is M79
	if( is_valid_ent ( Launcher ) && is_user_connected ( Player ) && entity_get_int ( Launcher,  EV_INT_WEAPONKEY ) == M79_WEAPONKEY )
	{
		// Update
		g_hasLauncher [ Player ] = true
		
		// BP ammo
		cs_set_user_bpammo ( Player, CSW_AK47, pev ( Launcher, pev_weaponammo ) )
		
		// Reset weapon options
		entity_set_int ( Launcher, EV_INT_WEAPONKEY, 0)
		
		return HAM_HANDLED
	}
	
	return HAM_IGNORED
}
	
// Launcher post frame
public fw_LauncherPostFrame ( Launcher )
{
	// Owner
	new Player = get_pdata_cbase ( Launcher, OFFSET_PLAYER, LINUX_DIFF_WPN )
	
	// Owns Launcher
	if ( is_user_connected ( Player ) && g_hasLauncher [ Player ] )
	{
		// Reload offset
		new fInReload = get_pdata_int ( Launcher, OFFSET_RELOAD, LINUX_DIFF )
		
		// Next attack time
		new Float:flNextAttack = get_pdata_float ( Player, OFFSET_NEXTATTACK, LINUX_DIFF_WPN )
		
		// Clip
		new iClip ; iClip = get_pdata_int ( Launcher, OFFSET_CLIP, LINUX_DIFF )
		
		// Ammo type
		new iAmmoType = OFFSET_PLAYERSLOT + get_pdata_int( Launcher, OFFSET_PRIMAMMOTYPE, LINUX_DIFF )
		
		// BP ammo
		new iBpAmmo ; iBpAmmo = get_pdata_int( Player, iAmmoType, LINUX_DIFF_WPN )	
		
		// Reloading
		if( fInReload && flNextAttack <= 0.0 )
		{
			// Calculate the difference
			new j = min(MAXCLIP - iClip, iBpAmmo)
			
			// Set new clip
			set_pdata_int ( Launcher, OFFSET_CLIP, iClip + j, LINUX_DIFF )
			
			// Decrease 'x' bullets from backpack(depending on new clip)
			set_pdata_int ( Player, iAmmoType, iBpAmmo-j, LINUX_DIFF_WPN )
			
			// Not reloding anymore
			set_pdata_int ( Launcher, OFFSET_RELOAD, 0, LINUX_DIFF )
			fInReload = 0
		}
		
		// Get buttons
		static iButton ; iButton = pev( Player, pev_button)
		
		// Attack/Attack2 buttons and next prim/sec attack time hasnt' come yet
		if(	(iButton & IN_ATTACK2 && get_pdata_float( Launcher, OFFSET_NEXTSECATTACK, LINUX_DIFF ) <= 0.0)
		||	(iButton & IN_ATTACK && get_pdata_float( Launcher, OFFSET_NEXTPRIMATTACK, LINUX_DIFF ) <= 0.0)	)
		{
			return
		}
		
		// Reload button / not reloading
		if( iButton & IN_RELOAD && !fInReload )
		{
			// Old clip is more/equal than/to new
			if( iClip >= MAXCLIP )
			{
				// Remove reload button
				set_pev ( Player, pev_button, iButton & ~IN_RELOAD )
				
				//Don't play reload animation
				UTIL_PlayWeaponAnimation( Player, -1 )
			}
			else	
			{
				// No need to reload if we are out of ammo
				if ( !iBpAmmo ) return 
				
				// Next attack time
				set_pdata_float( Player, OFFSET_NEXTATTACK, RELOAD_TIME+0.5, LINUX_DIFF_WPN )
			
				// Reload animation
				UTIL_PlayWeaponAnimation ( Player, m79_shoot1 )
						
				// Reload offset
				set_pdata_int ( Launcher, OFFSET_RELOAD, 1, LINUX_DIFF )
	
				// Idle time
				set_pdata_float ( Launcher, OFFSET_WEAPONIDLE, RELOAD_TIME + 1.0, LINUX_DIFF )
			}
		}
	}
}	

// Spawn
public fw_PlayerSpawn_Post ( Player )
{
	// Dead
	if ( !is_user_alive ( Player ) )
		return
		
	// Update
	bIsAlive [ Player ] = true
}

// Fire grenade
public FireGrenade ( Player )
{
	// Velocity
	static Float:fVelocity [ 3 ]
	
	// Create ent
	new grenade = create_entity ( g_DefaultEntity )
	
	// Not grenade
	if (!grenade ) return PLUGIN_HANDLED
	
	// Classname
	entity_set_string ( grenade, EV_SZ_classname, g_GrenadeEntity )
	
	// Model
	entity_set_model ( grenade, grenade_model )
	
	// Origin
	static Float:origin [ 3 ], Float:angle [ 3 ]
	engfunc ( EngFunc_GetAttachment, Player, 2, origin, angle )
	entity_set_origin ( grenade, origin )
	
	// Size
	engfunc ( EngFunc_SetSize, grenade, Float:{ 0.0, 0.0, 0.0 }, Float:{ 0.0, 0.0, 0.0 } )
	
	// Interaction
	entity_set_int ( grenade, EV_INT_solid, SOLID_SLIDEBOX )
	
	// Movetype
	entity_set_int ( grenade, EV_INT_movetype, MOVETYPE_TOSS )
	
	// Owner
	entity_set_edict ( grenade, EV_ENT_owner, Player )
	
	// Velocity
	VelocityByAim( Player, 2000, fVelocity )
	
	// Velocity
	entity_set_vector ( grenade, EV_VEC_velocity, fVelocity )
	
	// Angles
	static Float:flAngle [ 3 ]
	engfunc ( EngFunc_VecToAngles, fVelocity, flAngle )
	entity_set_vector ( grenade, EV_VEC_angles, flAngle )
	
	// Animation
	UTIL_PlayWeaponAnimation ( Player, m79_shoot1 )
	
	// Recoil
	set_pev ( Player, pev_punchangle, Float:{12.0, 6.0,0.0} )
	
	// Launch sound
	emit_sound ( grenade, CHAN_WEAPON, fire_sound[random_num(0, sizeof fire_sound-1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM )
	
	// Trail
	message_begin ( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_BEAMFOLLOW) // Temporary entity ID
	write_short(grenade) // Entity
	write_short( m_iTrail ) // Sprite index
	write_byte(10) // Life
	write_byte(3) // Line width
	write_byte(TRAIL_RED) // Red
	write_byte(TRAIL_GREEN) // Green
	write_byte(TRAIL_BLUE) // Blue
	write_byte(255) // Alpha
	message_end() 
	
	return PLUGIN_CONTINUE
}
	
// Grenade hit something
public touch_m79nade ( Nade, Other )
{
	// Invalid entity ?
	if ( !pev_valid ( Nade ) )
		return
		
	// Get it's origin
	static Float:origin [ 3 ]
	pev ( Nade, pev_origin, origin )
	
	// Explosion
	engfunc ( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0 )
	write_byte ( TE_EXPLOSION )
	engfunc ( EngFunc_WriteCoord, origin [ 0 ] ) // Position X
	engfunc ( EngFunc_WriteCoord, origin [ 1 ] ) // Position Y
	engfunc ( EngFunc_WriteCoord, origin [ 2 ] ) // Position Z
	write_short ( m_iExplo ) // Sprite index
	write_byte ( 30 ) // Scale
	write_byte ( 15 ) // Frame rate
	write_byte ( 0 ) // Flags
	message_end ( )
	
	// Owner
	static owner  ; owner = pev ( Nade, pev_owner )	
	
	// Make a loop
	for ( new i = 1; i < g_MaxPlayers; i++ )
	{
		// Not alive
		if ( !bIsAlive [ i ] )
			continue
			
		// Godmode
		if ( get_user_godmode ( i ) == 1 )
			continue
			
		// Human/Survivor
		if ( !zp_get_user_zombie ( i ) || zp_get_user_survivor ( i ) )
			continue
			
		// Get victims origin
		static Float:origin2 [ 3 ]
		pev ( i, pev_origin, origin2 )
		
		// Get distance between those origins
		static Float:distance_f ; distance_f = get_distance_f ( origin, origin2 )
		
		// Convert distnace to non-float
		static distance ; distance = floatround ( distance_f )
		
		// Radius
		static radius ; radius = get_pcvar_num ( cvar_radius )
		
		// We are in damage radius
		if ( distance <= radius )
		{
			// Fake damage
			fakedamage ( i, "grenade", 0.0, DMG_BLAST )
			
			// Max damage
			static maxdmg ; maxdmg = get_pcvar_num ( cvar_maxdmg )
			
			// Normal dmg
			new Damage
			Damage = maxdmg - floatround ( floatmul ( float ( maxdmg ), floatdiv ( float ( distance ), float ( radius ) ) ) )
			
			// Calculate health
			new health = get_user_health ( i )
			
			// We have at least 1 hp
			if ( health - Damage >= 1 )
			{
				// New heakth
				set_user_health ( i, health - Damage )
				
				// Make knockback
				make_knockback ( i, origin, get_pcvar_float ( cvar_knockback ) * Damage )
			}
			else
			{
				// We must die
				death_message ( owner, i, "grenade", 1 )
				
				// I hope they'll not find the bodies....
				origin2 [ 2 ] -= 45.0
			}
		}
	}
	
	// Breakable
	static ClassName [ 32 ]
	pev ( Other, pev_classname, ClassName, charsmax ( ClassName ) )
	if ( equal ( ClassName, "func_breakable" ) )
	{
		// Entity health
		static Float:health
		health = entity_get_float ( Other, EV_FL_health )
		
		if ( health <= get_pcvar_num ( cvar_maxdmg ) )
		{
			// Break it
			force_use ( owner, Other )
		}
	}
	
	// Remove grenade
	engfunc ( EngFunc_RemoveEntity, Nade )
}

// Death message
public death_message ( Killer, Victim, const Weapon [ ], ScoreBoard )
{
	// Block death msg
	set_msg_block(g_msgDeathMsg, BLOCK_SET)
	ExecuteHamB(Ham_Killed, Victim, Killer, 2)
	set_msg_block(g_msgDeathMsg, BLOCK_NOT)
	
	// Death
	make_deathmsg ( Killer, Victim, 0, Weapon )
	
	// Ammo packs
	zp_set_user_ammo_packs ( Killer, zp_get_user_ammo_packs ( Killer ) + 1 )
	
	// Update score board
	if ( ScoreBoard )
	{
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte( Killer ) // id
		write_short(pev(Killer, pev_frags)) // frags
		write_short(cs_get_user_deaths(Killer)) // deaths
		write_short(0) // class?
		write_short(get_user_team(Killer)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(Victim) // id
		write_short(pev(Victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(Victim)) // deaths
		write_short(0) // class?
		write_short(get_user_team(Victim)) // team
		message_end()
	}
}
	
// Make knockback
public make_knockback ( Victim, Float:origin [ 3 ], Float:maxspeed )
{
	// Get and set velocity
	new Float:fVelocity[3];
	kickback ( Victim, origin, maxspeed, fVelocity)
	entity_set_vector( Victim, EV_VEC_velocity, fVelocity);

	return (1);
}

// Extra calulation for knockback
stock kickback( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3])
{
	// Find origin
	new Float:fEntOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

	// Do some calculations
	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];
	new Float:fTime = (vector_distance( fEntOrigin,fOrigin ) / fSpeed);
	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;

	return (fVelocity[0] && fVelocity[1] && fVelocity[2]);
}

// Play weapon animation stock
stock UTIL_PlayWeaponAnimation ( const Player, const Sequence )
{
	set_pev ( Player, pev_weaponanim, Sequence )
	
	message_begin ( MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player )
	write_byte ( Sequence )
	write_byte ( pev ( Player, pev_body ) )
	message_end ( )
}

// Drop all primary guns
stock drop_primary_weapons ( Player )	
{
	// Get user weapons
	static weapons [ 32 ], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons ( Player, weapons, num )
	
	// Loop through them and drop primaries
	for ( i = 0; i < num; i++ )
	{
		// Prevent re-indexing the array
		weaponid = weapons [ i ]
		
		// We definetely are holding primary gun
		if  ( ( (1<<weaponid) & PRIMARY_WEAPONS_BITSUM ) )		
		{
			// Get weapon entity
			static wname[32]
			get_weaponname(weaponid, wname, charsmax(wname))
				
			// Player drops the weapon and looses his bpammo
			engclient_cmd( Player, "drop", wname)
		}
	}
}

// Update HUD
stock update_hud ( Player )
{
	// Weapon ent
	new Ent = find_ent_by_owner ( -1,"weapon_ak47", Player )
	
	// Clip
	new clip  = cs_get_weapon_ammo ( Ent )
	
	// BP Ammo
	new bpammo = cs_get_user_bpammo ( Player, CSW_AK47 )
	
	if ( clip != -1 )
	{
		// Update HUD
		message_begin ( MSG_ONE, g_msgCurWeapon, _, Player )
		write_byte ( 1 )
		write_byte ( CSW_AK47 )
		write_byte ( clip )
		message_end ( )
	}
	
	if ( bpammo != -1 )
	{
		// Update HUD
		message_begin ( MSG_ONE, g_msgAmmoX, _, Player )
		write_byte ( 2 )
		write_byte ( bpammo )
		message_end ( )
	}
}

// HAM strip user gun
stock ham_strip_user_gun (id, weapon[])
{
	if(!equal(weapon,"weapon_",7)) 
		return 0
	
	new wId = get_weaponid(weapon)
	
	if(!wId) return 0
	
	new wEnt
	
	while((wEnt = find_ent_by_class(wEnt, weapon)) && entity_get_edict(wEnt, EV_ENT_owner) != id) {}
	
	if(!wEnt) return 0
	
	if(get_user_weapon(id) == wId) 
		ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);
	
	if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt)) 
		return 0
		
	ExecuteHamB(Ham_Item_Kill, wEnt)
	
	entity_set_int(id, EV_INT_weapons, entity_get_int(id, EV_INT_weapons) & ~(1<<wId))

	return 1
}

