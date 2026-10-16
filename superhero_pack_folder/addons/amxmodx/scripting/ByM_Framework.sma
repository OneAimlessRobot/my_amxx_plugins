/*
	Name: [ByM] Framework
	Version: 1.0.
	Author: Milutinke (ByM)
	Started: 30.04.2017 20:04
	Last edited: 5.06.2017 14:39

	Cahngelog:
		- 1.0.0 First Version > {
			Date: 30.04.2017

			- Added ByM API
			- Added basic functionality
			- Added Jet Pack
			- Added Shooting At Back Detection
			- Added Screen Fade
			- Added Screen Shake
			- Added Bullet Proof
			- Added Intant Kill
			- Added Wall Climbing
			- Added Magician
			- Added Xray
			- Added Weapon Aim
			- Added Head Shoot Immunity/Resistance
			- Added Multi Jump
			- Added Fast Reload
			- Added No Recoill
			- Added Unlimited Clip
			- Added Additional Damage
			- Added Anti Xray
		}
		
		- 1.0.1 Version > {
			Date: 5.05.2017

			- Added weapon resistance
			- Added invisibility with certain weapon
			- Added Teleport
			- Added player models
			- Added vampire ability
			- Added instant kill resistance
		}
		
		- 1.0.2 Version > {
			Date: 5.06.2017

			- Added Military Secret
			- Added Dropper
		}
*/

// =============================================================================================
//				Libraries
// =============================================================================================
#include < amxmodx >
#include < hamsandwich >
#include < fakemeta >
#include < cstrike >
#include < engine >
#include < fun >
#include < xs >

// =============================================================================================
//				Preprocessors
// =============================================================================================

#define Chance(%0)			bool: ( random_num( 1, %0 ) == 1 )
#define IsValidPlayer(%0)		bool: ( 1 <= %0 <= g_iMaxPlayers )
#define Struct				enum

// =============================================================================================
//				Structures
// =============================================================================================

Struct _:StructPlayerInfo {
	g_iJetPack,
	g_iJetPackResetTime,
	g_iNoRecoil,
	g_iFastReload,
	g_iUnlimitedClip,
	g_iMultiJump,
	g_iWallClimb,
	g_iMagician,
	g_iMagicianWeapon,
	g_iXray,
	g_iHsImmunity,
	g_iHsOnly,
	g_iAim,
	g_iAimWeapon,
	g_iBullets,
	g_iJumps,
	g_iAdditionalDamage,
	g_iAdditionalDamageWeapon,
	g_iAntiXray,
	g_iResistanceChance,
	g_iResistanceWeapon,
	g_iTeleport,
	g_iTeleportSeconds,
	g_iWeaponInvisibilityWeapon,
	g_iWeaponInvisibility,
	g_iDefaultVisibility,
	g_iVampire,
	g_iInstantKillResistance,
	g_iIgnoreResistance,
	g_iMilitarySecret,
	g_iDropper
}

Struct _:StructInstantKill {
	g_iInstantKillChance,
	g_iInstantKillWeapon
}

// =============================================================================================
//				Variables
// =============================================================================================

// Player
new g_iPlayerInfo[ 33 ][ StructPlayerInfo ];
new g_iPlayerInstantKill[ 33 ][ 10 ][ StructInstantKill ];
new Float: g_fPunchAngle[ 33 ][ 3 ];
new Float: g_fPlayerPosition[ 33 ][ 3 ];
new Float: g_fLastUsed[ 33 ];

// Weapons
new const g_iMaxClip[ 31 ] = {
	-1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
	10,  30, 100,  8, 30,  30, 20,  1,  7, 30, 30, -1,  50
};

const g_iExcludedWeapons = ( 1 << CSW_KNIFE | 1 << CSW_HEGRENADE | 1 << CSW_FLASHBANG | 1 << CSW_SMOKEGRENADE | 1 << CSW_C4 );

// Messages
new g_iScreenShake;
new g_iScreenFade;
new g_iMessageBarTime;

// Other
new g_iMaxPlayers;

// =============================================================================================
//				Plugin initialisation i Configuration
// =============================================================================================
public plugin_init( ) {
	register_plugin( "[ByM] Framework", "1.0.2", "Milutinke (ByM)" );
		
	if( is_plugin_loaded( "[ByM] Cod Mod Core" ) == -1 )
		set_fail_state( "Oce l' to majstore :D" );
		
	// Ham module forwards
	RegisterHam( Ham_Player_Jump, "player", "fw_HamPlayerJump" );
	RegisterHam( Ham_TakeDamage, "player", "fw_HamTakeDamagePre" );

	new szWeaponName[ 24 ]
	for( new i = 1; i <= 30; i ++ ) {
		if( !( g_iExcludedWeapons & 1 << i ) && get_weaponname( i, szWeaponName, charsmax( szWeaponName ) ) ) {
			RegisterHam( Ham_Weapon_PrimaryAttack, szWeaponName, "fw_Weapon_PrimaryAttack_Pre" );
			RegisterHam( Ham_Weapon_PrimaryAttack, szWeaponName, "fw_Weapon_PrimaryAttack_Post", .Post = true );
			RegisterHam( Ham_Weapon_Reload, szWeaponName, "fw_Ham_Weapon_Reload_Post", .Post = true );
			RegisterHam( Ham_Item_Holster, szWeaponName, "fw_Ham_Item_Holster" );
		}
	}

	// Fake meta module forwards
	register_forward( FM_CmdStart, "fw_FmCmdStart" );
	register_forward( FM_Touch, "fw_FmTouch" );
	register_forward( FM_TraceLine,"fw_FmTaceLine" );
	register_forward( FM_AddToFullPack, "fw_FmAddFullToPack_Post", 1 );
	register_forward( FM_EmitSound, "fw_EmiteSound" );

	// Engine Events
	register_event( "CurWeapon", "fw_CurWeapon", "be", "1=1" );

	// Messages
	g_iScreenFade = get_user_msgid( "ScreenFade" );
	g_iScreenShake = get_user_msgid( "ScreenShake" );
	g_iMessageBarTime = get_user_msgid( "BarTime2" );
	
	// Other
	g_iMaxPlayers = get_maxplayers( );
}

// =============================================================================================
//				Ham Module Forwards
// =============================================================================================
public fw_HamTakeDamagePre( iVictim, iInflictor, iAttacker, Float: fDamage, iDamageType ) {
	//if( !is_user_connected( iAttacker ) || !is_user_alive( iAttacker ) || !IsValidPlayer( iAttacker ) || ( iAttacker == iVictim ) || is_user_bot( iAttacker ) )
	if( !is_user_connected( iAttacker ) || !is_user_alive( iAttacker ) || !IsValidPlayer( iAttacker ) || ( iAttacker == iVictim ) )
		return HAM_IGNORED;
		
	if( !is_user_connected( iVictim ) || !is_user_alive( iVictim ) || ( get_user_team( iAttacker ) == get_user_team( iVictim ) ) )
		return HAM_IGNORED;
		
	if( g_iPlayerInfo[ iAttacker ][ g_iMilitarySecret ] && Chance( g_iPlayerInfo[ iAttacker ][ g_iMilitarySecret ] ) )
		ScreenFade( iVictim, ( 1 << 14 ), ( 1 << 14 ), ( 1 << 16 ), 255, 155, 50, 230 );
		
	if( g_iPlayerInfo[ iAttacker ][ g_iDropper ] && Chance( g_iPlayerInfo[ iAttacker ][ g_iDropper ] ) )
		client_cmd( iVictim, "drop" );
		
	if( g_iPlayerInfo[ iVictim ][ g_iBullets ] > 0 && ( iDamageType & DMG_BULLET ) ) {
		g_iPlayerInfo[ iVictim ][ g_iBullets ] --;
		return HAM_SUPERCEDE;
	}
	
	if( g_iPlayerInfo[ iAttacker ][ g_iVampire ] && Chance( 5 ) )
		entity_set_float( iAttacker, EV_FL_health, floatmin( float( g_iPlayerInfo[ iAttacker ][ g_iVampire ] ), entity_get_float( iAttacker, EV_FL_health ) + fDamage ) );
	
	static iWeapon;
	iWeapon = get_user_weapon( iAttacker );
	
	if( CheckResistance( iVictim, iWeapon ) )
		return HAM_SUPERCEDE;
	
	fDamage += AdditionalDamage( iAttacker, iWeapon );
	
	if( CheckInstantKill( iAttacker, iVictim, iWeapon ) )
		fDamage = entity_get_float( iVictim, EV_FL_health );
		
	SetHamParamFloat( 4, fDamage );
	return HAM_IGNORED;
}

public fw_HamPlayerJump( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return HAM_IGNORED;
		
	if( !g_iPlayerInfo[ iPlayer ][ g_iMultiJump ] )
		return HAM_IGNORED;

	static iFlags;
	iFlags = entity_get_int( iPlayer, EV_INT_flags );
	
	if( iFlags & FL_WATERJUMP || entity_get_int( iPlayer, EV_INT_waterlevel ) >= 2 || !( get_pdata_int( iPlayer, 246, 5 ) & IN_JUMP ) )
		return HAM_IGNORED;
	
	if( iFlags & FL_ONGROUND ) {
		g_iPlayerInfo[ iPlayer ][ g_iJumps ] = 0;
		return HAM_IGNORED;
	}

	if( ++ g_iPlayerInfo[ iPlayer ][ g_iJumps ] < g_iPlayerInfo[ iPlayer ][ g_iMultiJump ] ) {
		static Float: fVelocity[ 3 ];
		entity_get_vector( iPlayer, EV_VEC_velocity, fVelocity );
		fVelocity[ 2 ] = random_float( 265.0, 285.0 );
		entity_set_vector( iPlayer, EV_VEC_velocity, fVelocity ); 

		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

public fw_Weapon_PrimaryAttack_Pre( iEntity ) {
	static iPlayer;
	iPlayer = entity_get_edict( iEntity, EV_ENT_owner );
	
	if( g_iPlayerInfo[ iPlayer ][ g_iNoRecoil ] ) {
		entity_get_vector( iPlayer, EV_VEC_punchangle, g_fPunchAngle[ iPlayer ] );
		return HAM_IGNORED;
	}
	
	return HAM_IGNORED;
}

public fw_Weapon_PrimaryAttack_Post( iEntity ) {
	static iPlayer;
	iPlayer = entity_get_edict( iEntity, EV_ENT_owner );

	if( g_iPlayerInfo[ iPlayer ][ g_iNoRecoil ] ) {
		static Float: fPush[ 3 ]
		entity_get_vector( iPlayer, EV_VEC_punchangle, fPush );
		
		xs_vec_sub( fPush, g_fPunchAngle[ iPlayer ], fPush );
		xs_vec_mul_scalar( fPush, 0.0, fPush );
		xs_vec_add( fPush, g_fPunchAngle[ iPlayer ], fPush );
		
		entity_set_vector( iPlayer, EV_VEC_punchangle, fPush );
		
		return HAM_IGNORED;
	}
	
	return HAM_IGNORED;
}

public fw_Ham_Weapon_Reload_Post( iEntity ) {
	if( get_pdata_int( iEntity, 54, 4 ) ) {
		static iPlayer;
		iPlayer = get_pdata_cbase( iEntity, 41, 4 );
		
		if( !is_user_alive( iPlayer ) )
			return;
		
		if( g_iPlayerInfo[ iPlayer ][ g_iFastReload ] ) {
			static Float: fNextAttack;
			fNextAttack = get_pdata_float( iPlayer, 83, 5 ) * 0.1;
			set_pdata_float( iPlayer, 83, fNextAttack, 5 );
			
			static iSeconds;
			iSeconds = floatround( fNextAttack, floatround_ceil );
			Make_BarTime2( iPlayer, iSeconds, 100 - floatround( ( fNextAttack / iSeconds ) * 100 ) );
		}
	}
}

public fw_Ham_Item_Holster( iEntity ) {
	if( get_pdata_int( iEntity, 54, 4 ) ) {
		static iPlayer;
		iPlayer = get_pdata_cbase( iEntity, 41, 4 );
		
		if( !is_user_alive( iPlayer ) )
			return;
			
		if( g_iPlayerInfo[ iPlayer ][ g_iFastReload ] )
			Make_BarTime2( iPlayer, 0, 0 );
	}
}

// =============================================================================================
//				Fake Meta Module Forwards
// =============================================================================================
public fw_FmCmdStart( iPlayer, iHandleUC ) {
	if( !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;

	static iButton, iFlags;
	iButton = get_uc( iHandleUC, UC_Buttons );
	iFlags = pev( iPlayer, pev_flags );
	
	if( g_iPlayerInfo[ iPlayer ][ g_iJetPack ] != 0 && ( iButton & IN_JUMP ) && ( iButton & IN_DUCK ) && ( iFlags & FL_ONGROUND ) && ( get_gametime( ) > ( g_iPlayerInfo[ iPlayer ][ g_iJetPackResetTime ] + 4.0 ) ) ) {
		g_iPlayerInfo[ iPlayer ][ g_iJetPackResetTime ] = floatround( get_gametime( ) );
		
		static Float: fVelocity[ 3 ];
		VelocityByAim( iPlayer, g_iPlayerInfo[ iPlayer ][ g_iJetPack ] == 2 ? 1000 : 700, fVelocity );
		fVelocity[ 2 ] = ( ( g_iPlayerInfo[ iPlayer ][ g_iJetPack ] == 2 ) ? random_float( 300.0, 320.0 ) : random_float( 265.0, 285.0 ) );
		entity_set_vector( iPlayer, EV_VEC_velocity, fVelocity );
	}

	if( g_iPlayerInfo[ iPlayer ][ g_iWallClimb ] ) {
		if( iButton & IN_USE )
			Climb( iPlayer );
	}

	if( g_iPlayerInfo[ iPlayer ][ g_iMagician ] )
		set_user_rendering( iPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, ( ( iButton & IN_DUCK ) && ( g_iPlayerInfo[ iPlayer ][ g_iMagicianWeapon ] == -1 ? true : ( g_iPlayerInfo[ iPlayer ][ g_iMagicianWeapon ] == get_user_weapon( iPlayer ) ) ) ) ? g_iPlayerInfo[ iPlayer ][ g_iMagician ] : g_iPlayerInfo[ iPlayer ][ g_iDefaultVisibility ] );
	
	return FMRES_IGNORED;
}

public fw_FmTouch( iPlayer, iWorld ) {
	if( !IsValidPlayer( iPlayer ) )
		return FMRES_IGNORED;
		
	if( !is_valid_ent( iPlayer ) )
		return FMRES_IGNORED;
		
	//if( is_user_bot( iPlayer ) )
	//	return FMRES_IGNORED;
		
	if( !g_iPlayerInfo[ iPlayer ][ g_iWallClimb ] )
		return FMRES_IGNORED;
		
	if( !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;
		
	entity_get_vector( iPlayer, EV_VEC_origin, g_fPlayerPosition[ iPlayer ] );	
	return FMRES_IGNORED;
}

public fw_FmAddFullToPack_Post( iHandle, iE, iEntity, iHost, iHostFlags, iPlayer, iPset ) {
	if( !is_user_connected( iHost ) || !is_user_alive( iHost ) )
		return FMRES_IGNORED;

	if( !is_user_connected( iEntity ) )
		return FMRES_IGNORED;
		
	if( g_iPlayerInfo[ iEntity ][ g_iAntiXray ] )
		return FMRES_IGNORED;

	if( g_iPlayerInfo[ iHost ][ g_iXray ] )
		set_es( iHandle, ES_RenderAmt, 255.0 );
	
	return FMRES_IGNORED;
}

public fw_FmTaceLine( Float: fStartVector[ 3 ], Float: fEndVector[ 3 ], iIgnore, iAttacker, iTrace ) {
	if( !is_user_connected( iAttacker ) || !is_user_alive( iAttacker ) || !IsValidPlayer( iAttacker ) )
		return FMRES_IGNORED;
	
	new iVictim, iHitZone;

	iVictim = get_tr2( iTrace, TR_pHit );
	iHitZone = get_tr2( iTrace, TR_iHitgroup );
	
	if( !is_user_alive( iVictim ) )
		return FMRES_IGNORED;
	
	if( g_iPlayerInfo[ iVictim ][ g_iHsImmunity ] && ( iHitZone == HIT_HEAD ) ) {
		if( Chance( g_iPlayerInfo[ iVictim ][ g_iHsImmunity ] ) )
			set_tr2( iTrace, TR_iHitgroup, 8 );
         }
	if( g_iPlayerInfo[ iVictim ][ g_iHsOnly ] && ( iHitZone != HIT_HEAD ) ) {
		if( Chance( g_iPlayerInfo[ iVictim ][ g_iHsOnly ] ) )
	                  set_tr2( iTrace, TR_iHitgroup, 8 );
	}

	if( g_iPlayerInfo[ iAttacker ][ g_iAim ] && ( iHitZone != HIT_HEAD ) ) {
		if( Chance( g_iPlayerInfo[ iAttacker ][ g_iAim ] ) ) {
			if( g_iPlayerInfo[ iAttacker ][ g_iAimWeapon ] != -1 && ( get_user_weapon( iAttacker ) != g_iPlayerInfo[ iAttacker ][ g_iAimWeapon ] ) )
				return FMRES_IGNORED;

			set_tr2( iTrace, TR_iHitgroup, HIT_HEAD );
		}
	}
		
	return FMRES_IGNORED;
}

public fw_EmiteSound( iPlayer, iChanel, const szSound[ ], Float: fVolume, Float: fAtn, iFlags, iPitch ) {
	if( !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;
	
	if( equal( szSound, "common/wpn_denyselect.wav" ) ) {
		if( g_iPlayerInfo[ iPlayer ][ g_iTeleport ] ) {
			if( g_fLastUsed[ iPlayer ] > get_gametime( ) )
				return FMRES_IGNORED;
		
			g_fLastUsed[ iPlayer ] = get_gametime( ) + g_iPlayerInfo[ iPlayer ][ g_iTeleportSeconds ];
		
			Teleport( iPlayer );
		}
		
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

// =============================================================================================
//				Engine Events
// =============================================================================================

public fw_CurWeapon( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return;

	static iWeapon;
	iWeapon = get_user_weapon( iPlayer );
	
	if( g_iPlayerInfo[ iPlayer ][ g_iUnlimitedClip ] && g_iMaxClip[ iWeapon ] != -1 )
		SetUserClip( iPlayer, g_iMaxClip[ iWeapon ] );
		
	NativeSetVisibility( iPlayer, ( g_iPlayerInfo[ iPlayer ][ g_iWeaponInvisibilityWeapon ] != -1 && ( iWeapon == g_iPlayerInfo[ iPlayer ][ g_iWeaponInvisibilityWeapon ] ) ) ? g_iPlayerInfo[ iPlayer ][ g_iWeaponInvisibility ] : g_iPlayerInfo[ iPlayer ][ g_iDefaultVisibility ] );
}

// =============================================================================================
//				Player Connection/Disconnection
// =============================================================================================

public client_putinserver( iPlayer ) {
	ResetVariables( iPlayer );
}

public client_disconnected( iPlayer ) {
	ResetVariables( iPlayer );

	for( new iIterator = 0; iIterator < 10; iIterator ++ ) {
		g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillChance ] = 0;
		g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillWeapon ] = 0;
	}
	
	g_iPlayerInfo[ iPlayer ][ g_iAdditionalDamageWeapon ] = 0;
	g_iPlayerInfo[ iPlayer ][ g_iResistanceWeapon ] = 0;
	g_iPlayerInfo[ iPlayer ][ g_iWeaponInvisibilityWeapon ] = 0;
	g_iPlayerInfo[ iPlayer ][ g_iMagicianWeapon ] = 0;
}

ResetVariables( iPlayer ) {
	for( new iIterator = 0; iIterator < StructPlayerInfo; iIterator ++ )
		g_iPlayerInfo[ iPlayer ][ iIterator ] = 0;
		
	g_fLastUsed[ iPlayer] = 0.0;
	
	for( new iIterator = 0; iIterator < 10; iIterator ++ ) {
		g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillChance ] = 0;
		g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillWeapon ] = -1;
	}
	
	
	g_iPlayerInfo[ iPlayer ][ g_iAdditionalDamageWeapon ] = -1;
	g_iPlayerInfo[ iPlayer ][ g_iResistanceWeapon ] = -1;
	g_iPlayerInfo[ iPlayer ][ g_iWeaponInvisibilityWeapon ] = -1;
	g_iPlayerInfo[ iPlayer ][ g_iMagicianWeapon ] = -1;
	g_iPlayerInfo[ iPlayer ][ g_iDefaultVisibility ] = 255;
}

// =============================================================================================
//				Natives
// =============================================================================================

public plugin_natives( ) {
	// Reset
	register_native( "bym_reset_everything", "NativeResetEverything", 1 );

	// Jet pack
	register_native( "bym_set_jetpack", "NativeSetJetPack", 1 );

	// Damage Related
	register_native( "bym_is_shooting_at_back", "NativeIsShootingAtBack", 1 );
	register_native( "bym_set_bullet_proof", "NativeSetBulletProof", 1 );
	register_native( "bym_set_instant_kill", "NativeSetInstantKill", 1 );
	register_native( "bym_set_additional_damage", "NativeSetAdditionalDamage", 1 );
	register_native( "bym_set_resistance", "NativeSetResistance", 1 );
	register_native( "bym_set_ignore_resistance", "NativeSetIgnoreResistance", 1 );
	register_native( "bym_set_instant_kill_resisance", "NativeSetInsantKillResistance", 1 );

	// Screen Utils
	register_native( "bym_screen_shake", "NativeScreenShake", 1 );
	register_native( "bym_screen_fade", "NativeScreenFade", 1 );

	// Respawn As Enemy
	register_native( "bym_respawn_as_enemy", "NativeRespawnAsEnemy", 1 );

	// Weapons related
	register_native( "bym_set_no_recoil", "NativeSetNoRecoil", 1 );
	register_native( "bym_set_fast_reload", "NativeSetFastReload", 1 );
	register_native( "bym_set_weapon_clip", "NativeSetWeaponClip", 1 );
	register_native( "bym_set_unlimited_clip", "NativeSetUnlimitedClip", 1 );
	register_native( "bym_set_hs_immunity", "NativeSetHsImmunity", 1 );
	register_native( "bym_set_hs_only", "NativeSetHsOnly", 1 );
	register_native( "bym_set_aim", "NativeSetAim", 1 );

	// Respawn As Enemy
	register_native( "bym_make_time_bar", "NativeMakeTimeBar", 1 );

	// Multi Jump
	register_native( "bym_set_multi_jump", "NativeSetMultiJump", 1 );

	// Walll Climbing
	register_native( "bym_set_wall_climbing", "NativeSetWallClimbing", 1 );

	// Xray
	register_native( "bym_set_xray", "NativeSetXray", 1 );
	register_native( "bym_set_anti_xray", "NativeSetAntiXray", 1 );
	
	// Visibility
	register_native( "bym_set_visibility", "NativeSetVisibility", 1 );
	register_native( "bym_set_weapon_invisiblity", "NativeSetWeaponVisibility", 1 );
	register_native( "bym_set_magician", "NativeSetMagician", 1 );
	
	// Teleport
	register_native( "bym_set_teleport", "NativeSetTeleport", 1 );
	
	// Vampire
	register_native( "bym_set_vampire", "NativeSetVampire", 1 );
	
	// Military Secret
	register_native( "bym_set_military_secret", "NativeSetMilitarySecret", 1 );
	
	// Dropper
	register_native( "bym_set_dropper", "NativeSetDropper", 1 );
}

public NativeResetEverything( iPlayer )
	ResetVariables( iPlayer );

public NativeSetJetPack( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iJetPack ]  = iValue;

public NativeIsShootingAtBack( iPlayer, iTarget )
	return IsShotingAtTheBack( iPlayer, iTarget );

public NativeSetBulletProof( iPlayer, iBullets )
	g_iPlayerInfo[ iPlayer ][ g_iBullets ] = iBullets;

public NativeSetInstantKill( iPlayer, iWeapon, iChance )
	SetInstantKill( iPlayer, iWeapon, iChance );
	
public NativeSetAdditionalDamage( iPlayer, iWeapon, iDamage ) {
	g_iPlayerInfo[ iPlayer ][ g_iAdditionalDamage ] = iDamage;
	g_iPlayerInfo[ iPlayer ][ g_iAdditionalDamageWeapon ] = iWeapon;
}

public NativeSetIgnoreResistance( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iIgnoreResistance ] = iValue;

public NativeSetResistance( iPlayer, iWeapon, iChance ) {
	g_iPlayerInfo[ iPlayer ][ g_iResistanceChance ] = iChance;
	g_iPlayerInfo[ iPlayer ][ g_iResistanceWeapon ] = iWeapon;
}

public NativeSetInsantKillResistance( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iInstantKillResistance ] = iValue;

public NativeScreenShake( iPlayer, iSeconds ) 
	ScreenShake( iPlayer, iSeconds );

public NativeScreenFade( iPlayer, iDuration, iHoldTime, iFadeType, iRed, iGreen, iBlue, iAlpha ) 
	ScreenFade( iPlayer, iDuration, iHoldTime, iFadeType, iRed, iGreen, iBlue, iAlpha );

public NativeRespawnAsEnemy( iPlayer, iChance ) {
	if( !is_user_alive( iPlayer ) )
		return;

	if( Chance( iChance ) ) {
		new CsTeams: iTeam = cs_get_user_team( iPlayer );
		cs_set_user_team( iPlayer, ( iTeam == CS_TEAM_CT ) ? CS_TEAM_T : CS_TEAM_CT );
		ExecuteHam( Ham_CS_RoundRespawn, iPlayer );
		cs_set_user_team( iPlayer, iTeam );
	}
}

public NativeSetNoRecoil( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iNoRecoil ] = iValue;

public NativeSetFastReload( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iFastReload ] = iValue;

public NativeSetWeaponClip( iPlayer, iAmmo )
	SetUserClip( iPlayer, iAmmo );
	
public NativeSetUnlimitedClip( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iUnlimitedClip ] = iValue;

public NativeSetHsImmunity( iPlayer, iChance )
	g_iPlayerInfo[ iPlayer ][ g_iHsImmunity ] = iChance;
	
public NativeSetHsOnly( iPlayer, iChance )
	g_iPlayerInfo[ iPlayer ][ g_iHsOnly ] = iChance;

public NativeSetAim( iPlayer, iWeapon, iChance ) {
	g_iPlayerInfo[ iPlayer ][ g_iAimWeapon ] = iWeapon;
	g_iPlayerInfo[ iPlayer ][ g_iAim ] = iChance;
}

public NativeMakeTimeBar( iPlayer, iSeconds, iPercent )
	Make_BarTime2( iPlayer, iSeconds, iPercent );

public NativeSetMultiJump( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iMultiJump ] = iValue;

public NativeSetWallClimbing( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iWallClimb ] = iValue;

public NativeSetXray( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iXray ] = iValue;

public NativeSetAntiXray( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iAntiXray ] = iValue;

public NativeSetVisibility( iPlayer, iValue ) {
	if( is_user_alive( iPlayer ) )
		set_user_rendering( iPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, ( iValue < 0 ? 0 : ( iValue > 255 ? 255 : iValue ) ) );
}

public NativeSetWeaponVisibility( iPlayer, iWeapon, iVisibility, iDefault ) {
	g_iPlayerInfo[ iPlayer ][ g_iWeaponInvisibilityWeapon ] = iWeapon;
	g_iPlayerInfo[ iPlayer ][ g_iWeaponInvisibility ] = iVisibility <= 8 ? 8 : ( iVisibility >= 255 ? 255 : iVisibility );
	g_iPlayerInfo[ iPlayer ][ g_iDefaultVisibility ] = iDefault;
}

public NativeSetMagician( iPlayer, iWeapon, iValue, iDefaultValue ) {
	g_iPlayerInfo[ iPlayer ][ g_iMagicianWeapon ] = iWeapon;
	g_iPlayerInfo[ iPlayer ][ g_iMagician ] = iValue;
	g_iPlayerInfo[ iPlayer ][ g_iDefaultVisibility ] = iDefaultValue;
}
	
public NativeSetTeleport( iPlayer, iTime ) {
	g_iPlayerInfo[ iPlayer ][ g_iTeleport ] = 1;
	g_iPlayerInfo[ iPlayer ][ g_iTeleportSeconds ] = iTime;
}

public NativeSetVampire( iPlayer, iMaxHP ) 
	g_iPlayerInfo[ iPlayer ][ g_iVampire ] = iMaxHP;
	
public NativeSetMilitarySecret( iPlayer, iChance )
	g_iPlayerInfo[ iPlayer ][ g_iMilitarySecret ] = iChance;
	
public NativeSetDropper( iPlayer, iChance )
	g_iPlayerInfo[ iPlayer ][ g_iDropper ] = iChance;

// =============================================================================================
//				Stocks
// =============================================================================================

stock bool: IsShotingAtTheBack( iPlayer, iTarget )
	return ( !IsItInFov( iTarget, iPlayer ) && IsItInFov( iPlayer, iTarget ) ) ? true : false;

stock bool: IsItInFov( iPlayer, iTarget )
	return ( FindAngle( iPlayer, iTarget, 9999.9 ) > 0.0 ) ? true : false;
 
stock Float: FindAngle( iPlayer, iTarget, Float: fDistance ) {
	static Float: fVecTolos[ 2 ];
	static Float: fDot;
	static Float: fPlayerOrigin[ 3 ];
	static Float: fTargetOrigin[ 3 ];
	static Float: fPlayerAngles[ 3 ];
	
	pev( iPlayer, pev_origin, fPlayerOrigin );
	pev( iTarget, pev_origin, fTargetOrigin );
	
	if( get_distance_f( fPlayerOrigin, fTargetOrigin ) > fDistance )
		return 0.0;
	
	pev( iPlayer, pev_angles, fPlayerAngles );
	
	for( new iIterator = 0; iIterator  < 2; iIterator  ++ )
		fVecTolos[ iIterator  ] = fTargetOrigin[ iIterator  ] - fPlayerOrigin[ iIterator ];
	
	static Float: fVectorLength;
	fVectorLength = Vec2DLength( fVecTolos );
	
	if( fVectorLength <= 0.0 ) {
		fVecTolos[ 0 ] = 0.0;
		fVecTolos[ 1 ] = 0.0;
	}
	else {
		static Float: fLen;
		fLen = 1.0 / fVectorLength;
		fVecTolos[ 0 ] = fVecTolos[ 0 ] * fLen;
		fVecTolos[ 1 ] = fVecTolos[ 1 ] * fLen;
	}

	engfunc( EngFunc_MakeVectors, fPlayerAngles );
	
	static Float: fForward[ 3 ];
	static Float: fForward2D[ 2 ];
	get_global_vector( GL_v_forward, fForward );
	
	fForward2D[ 0 ] = fForward[ 0 ];
	fForward2D[ 1 ] = fForward[ 1 ];
	
	fDot = fVecTolos[ 0 ] * fForward2D[ 0 ] + fVecTolos[ 1 ] * fForward2D[ 1 ];
	
	if ( fDot > 0.5 )  {
		return fDot;
	}
	
	return 0.0;
}

stock Float: Vec2DLength( Float: fVec[ 2 ] )
	return floatsqroot( fVec[ 0 ] * fVec[ 0 ] + fVec[ 1 ] * fVec[ 1 ] );

stock ScreenShake( iPlayer, iSeconds ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	message_begin( MSG_ONE, g_iScreenShake, { 0, 0, 0 }, iPlayer );
	write_short( ( 1 << 12 ) * iSeconds );
	write_short( ( 1 << 12 ) * iSeconds );
	write_short( ( 1 << 12 ) * iSeconds  );
	message_end( );
}

stock ScreenFade( iPlayer, iDuration, iHoldTime, iFadeType, iRed, iGreen, iBlue, iAlpha ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	message_begin( MSG_ONE, g_iScreenFade, { 0, 0, 0 }, iPlayer );
	write_short( iDuration );
	write_short( iHoldTime );
	write_short( iFadeType );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iAlpha );
	message_end( );
}

stock Make_BarTime2( iPlayer, iSeconds, iPercent ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	message_begin( MSG_ONE_UNRELIABLE, g_iMessageBarTime, _, iPlayer );
	write_short( iSeconds );
	write_short( iPercent );
	message_end( );
}

stock SetUserClip( iPlayer, iAmmo ) {
	if( !is_user_alive( iPlayer ) )
		return 0;
		
	engclient_cmd( iPlayer, "slot1" );
	
	new szWeaponName[ 32 ], iWeaponID = -1, szWeapon = get_user_weapon( iPlayer, _, _ );
	get_weaponname( szWeapon, szWeaponName, charsmax( szWeaponName ) );
	
	while( ( iWeaponID = find_ent_by_class( iWeaponID, szWeaponName ) ) != 0 ) {
		if( entity_get_edict( iWeaponID, EV_ENT_owner ) == iPlayer ) {
			set_pdata_int( iWeaponID, 51, iAmmo, 4 );
			return iWeaponID;
		}
	}
	
	return 0;
}

stock Climb( iPlayer ) {
	if( !IsValidPlayer( iPlayer ) )
		return FMRES_IGNORED;
	
	if( !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;
		
	static Float: fOrigin[ 3 ];
	entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
	
	if( get_distance_f( fOrigin, g_fPlayerPosition[ iPlayer ] ) > 25.0 )
		return FMRES_IGNORED;
	
	if( entity_get_int( iPlayer, EV_INT_flags ) & FL_ONGROUND )
		return FMRES_IGNORED;
	
	static iButton;
	iButton = entity_get_int( iPlayer, EV_INT_button );
	
	if( ( iButton & IN_FORWARD ) || ( iButton & IN_BACK ) ) {
		static Float: fVelocity[ 3 ];
		VelocityByAim( iPlayer, ( ( iButton & IN_FORWARD ) ? 120 : -120 ), fVelocity );
		entity_set_vector( iPlayer, EV_VEC_velocity, fVelocity );
	}
	
	return FMRES_IGNORED;
}

stock SetInstantKill( iPlayer, iWeapon, iChance ) {
	if( iWeapon == -1 )
		return;
	
	for( new iIterator = 0; iIterator < 10; iIterator ++ ) {
		if( g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillWeapon ] != -1 && g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillChance ] )
			continue;

		g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillWeapon ] = iWeapon;
		g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillChance ] = iChance;
		break;
	}
}

stock bool: CheckInstantKill( iPlayer, iVictim, iWeapon ) {
	if( g_iPlayerInfo[ iVictim ][ g_iInstantKillResistance ] && !g_iPlayerInfo[ iPlayer ][ g_iIgnoreResistance ] )
		return false;
	
	static iIterator;
	for( iIterator = 0; iIterator < 10; iIterator ++ ) {
		if( g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillWeapon ] != -1 && ( iWeapon != g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillWeapon ] ) )
			continue;

		if( g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillChance ] && Chance( g_iPlayerInstantKill[ iPlayer ][ iIterator ][ g_iInstantKillChance ] ) )
			return true;
	}
	
	return false;
}

stock Float: AdditionalDamage( iPlayer, iWeapon ) {
	if( g_iPlayerInfo[ iPlayer ][ g_iAdditionalDamage ] ) {
		if( g_iPlayerInfo[ iPlayer ][ g_iAdditionalDamageWeapon ] != -1 && ( iWeapon != g_iPlayerInfo[ iPlayer ][ g_iAdditionalDamageWeapon ] ) )
			return 0.0;
			
		return float( g_iPlayerInfo[ iPlayer ][ g_iAdditionalDamage ] );
	}
	
	return 0.0;
}

stock bool: CheckResistance( iPlayer, iWeapon ) {
	if( g_iPlayerInfo[ iPlayer ][ g_iResistanceChance ] ) {
		if( g_iPlayerInfo[ iPlayer ][ g_iResistanceWeapon ] != -1 && ( iWeapon != g_iPlayerInfo[ iPlayer ][ g_iResistanceWeapon ] ) )
			return false;
			
		return g_iPlayerInfo[ iPlayer ][ g_iResistanceChance ] && Chance( g_iPlayerInfo[ iPlayer ][ g_iResistanceChance ] );
	}
	
	return false;
}

stock Teleport( iPlayer ) {
	new Float: fStart[ 3 ], Float: fViewOfs[ 3 ], Float: fDest[ 3 ], Float: fDstOrigin[ 3 ], Float: fNormal[ 3 ];
	
	entity_get_vector( iPlayer, EV_VEC_origin, fStart );
	entity_get_vector( iPlayer, EV_VEC_view_ofs, fViewOfs );
	xs_vec_add( fStart, fViewOfs, fStart );
	
	entity_get_vector( iPlayer, EV_VEC_v_angle, fDest );
	engfunc( EngFunc_MakeVectors, fDest );
	global_get( glb_v_forward, fDest );
	xs_vec_mul_scalar( fDest, 999.0, fDest );
	xs_vec_add( fStart, fDest, fDest );
	
	engfunc( EngFunc_TraceLine, fStart, fDest, 0, iPlayer, 0 );
	get_tr2( 0, TR_vecEndPos, fDstOrigin );
	
	if( engfunc( EngFunc_PointContents, fDstOrigin ) == CONTENTS_SKY )
		return;
	
	get_tr2( 0, TR_vecPlaneNormal, fNormal );
	xs_vec_mul_scalar( fNormal, 50.0, fNormal );
	xs_vec_add( fDstOrigin, fNormal, fDstOrigin );
	entity_set_vector( iPlayer, EV_VEC_origin, fDstOrigin );
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
