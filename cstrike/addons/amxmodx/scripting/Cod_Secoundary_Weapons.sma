//=================================================================================================
//				 	Libraries
//=================================================================================================
#include < amxmodx >
#include < bym_cod_2016 >
#include < hamsandwich >
#include < fakemeta >
#include < cstrike >
#include < engine >
#include < fun >
#include < xs >

//=================================================================================================
//				 	Preprocesors
//=================================================================================================

#define Struct				enum

//=================================================================================================
//				 	Structures
//=================================================================================================

Struct _:StructPlayerInfo {
	g_iRockets,
	g_iMedKits,
	g_iPoisonKits,
	g_iDynamites,
	g_iMines,
	g_iExplosionResistance,
	g_iLightnings,
	g_iHerfestPower,
	g_iRetraction,
	g_iTracerRocket,
	g_iInstantRocket,
	g_iInstantMine,
	g_iMagnets
}

Struct _:StructModels {
	Model_Rocket,
	Model_MedKit,
	Model_MedKitT,
	Model_Mine,
	
	Sprite_Explosion,
	Sprite_Beam,
	Sprite_White,
	Sprite_Lightning,
	Sprite_FireExplosion,
	Sprite_Smoke
}

//=================================================================================================
//				 	Variables
//=================================================================================================

new g_iPlayerInfo[ 33 ][ StructPlayerInfo ];
new Float: g_fLastUsed[ 33 ];

new const g_szModels[ StructModels ][ ] = {
	"models/ByM_Cod/s_rocket.mdl",
	"models/ByM_Cod/w_medkit.mdl",
	"models/ByM_Cod/w_medkitT.mdl",
	"models/ByM_Cod/w_mine.mdl",
	
	"sprites/dexplo.spr",
	"sprites/laserbeam.spr",
	"sprites/white.spr",
	"sprites/lgtning.spr",
	"sprites/zerogxplode.spr",
	"sprites/effects/rainsplash.spr"
};

new g_iMaxPlayers;
new g_iModelIndex[ StructModels ];
new g_iHud;

//=================================================================================================
//				 	Plugin Intialisation
//=================================================================================================
public plugin_init( ) {
	register_plugin( "[ByM] Cod: Secoundary Weapons" , "1.0", "Milutinke (ByM)" );
	
	if( is_plugin_loaded( "[ByM] Cod Mod Core" ) == -1 )
		set_fail_state( "Oce l' to majstore :D" );
	
	// Entities
	register_touch( "Rocket", "*", "fw_RocketTouch" );
	register_touch( "Mine", "player", "fw_MineTouch" );
	register_think( "MedKit", "fw_MedKitThink" );
	register_think( "PoisonKit", "fw_PoisonKitThink" );
	register_think( "Rocket", "fw_RocketThink" );
	register_think( "Magnet", "fw_MagnetThink" );
	
	// Events
	register_event( "HLTV", "fw_NewRound", "a", "1=0", "2=0" );
	
	// Other
	g_iMaxPlayers = get_maxplayers( );
	g_iHud = CreateHudSyncObj( );
}

public plugin_precache( ) {
	for( new iIterator = 0; iIterator < StructModels; iIterator ++ )
		g_iModelIndex[ iIterator ] = precache_model( g_szModels[ iIterator ] );
		
	precache_sound( "ambience/thunder_clap.wav" );
}

//=================================================================================================
//				 	Other
//=================================================================================================
public fw_NewRound( ) {
	new iEntityMine = find_ent_by_class( -1, "Mine" );
	while( iEntityMine >  0)  {
		remove_entity( iEntityMine );
		iEntityMine = find_ent_by_class( iEntityMine, "Mine" );	
	}
	
	new iEntityRocket = find_ent_by_class( -1, "Rocket" );
	while( iEntityRocket >  0)  {
		remove_entity( iEntityRocket );
		iEntityRocket = find_ent_by_class( iEntityRocket, "Rocket" );	
	}
	
	new iEntityMedKit = find_ent_by_class( -1, "MedKit" );
	while( iEntityMedKit >  0)  {
		remove_entity( iEntityMedKit );
		iEntityMedKit = find_ent_by_class( iEntityMedKit, "MedKit" );	
	}
	
	new iMagnets = find_ent_by_class( -1, "Magnet" );
	while( iMagnets >  0)  {
		remove_entity( iMagnets );
		iMagnets = find_ent_by_class( iMagnets, "Magnet" );	
	}
	
	new iEntityBonusBox = find_ent_by_class( -1, "BonusBox" );
	while( iEntityBonusBox >  0)  {
		remove_entity( iEntityBonusBox );
		iEntityBonusBox = find_ent_by_class( iEntityBonusBox, "BonusBox" );	
	}
	
	new iSentry = find_ent_by_class( -1, "Sentry" );
	while( iSentry >  0)  {
		remove_entity( iSentry );
		iSentry = find_ent_by_class( iSentry, "Sentry" );	
	}
}

public cod_hud_ticked( iPlayer ) {	
	if( !is_user_alive( iPlayer ) )
		return;
	
	new szText[ 64 ];
	if( g_iPlayerInfo[ iPlayer ][ g_iRockets ] > 0 )
		formatex( szText, charsmax( szText ), "[%L: %d]", iPlayer, "ML_ROCKETS", g_iPlayerInfo[ iPlayer ][ g_iRockets ] );
	else if( g_iPlayerInfo[ iPlayer ][ g_iMedKits ] > 0 )
		formatex( szText, charsmax( szText ), "[%L: %d]", iPlayer, "ML_MED_KITS", g_iPlayerInfo[ iPlayer ][ g_iMedKits ] );
	else if( g_iPlayerInfo[ iPlayer ][ g_iPoisonKits ] > 0 )
		formatex( szText, charsmax( szText ), "[%L: %d]", iPlayer, "ML_POISON_KITS", g_iPlayerInfo[ iPlayer ][ g_iPoisonKits ] );
	else if( g_iPlayerInfo[ iPlayer ][ g_iDynamites ] > 0 )
		formatex( szText, charsmax( szText ), "[%L: %d]", iPlayer, "ML_DYNAMITES", g_iPlayerInfo[ iPlayer ][ g_iDynamites ] );
	else if( g_iPlayerInfo[ iPlayer ][ g_iMines ] > 0 )
		formatex( szText, charsmax( szText ), "[%L: %d]", iPlayer, "ML_MINES", g_iPlayerInfo[ iPlayer ][ g_iMines ] );
	else if( g_iPlayerInfo[ iPlayer ][ g_iLightnings ] > 0 )
		formatex( szText, charsmax( szText ), "[%L: %d]", iPlayer, "ML_LIGHTNINGS", g_iPlayerInfo[ iPlayer ][ g_iLightnings ] );
	else if( g_iPlayerInfo[ iPlayer ][ g_iMagnets ] > 0 )
		formatex( szText, charsmax( szText ), "[%L: %d]", iPlayer, "ML_MAGNETS", g_iPlayerInfo[ iPlayer ][ g_iMagnets ] );
		
	if( szText[ 0 ] == EOS )
		return;
		
	set_hudmessage( 0, 255, 255, 0.8, 0.25, 0, 6.0, 0.1 );
	ShowSyncHudMsg( iPlayer, g_iHud, "%s", szText );
}

public cod_used_ability( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	if( g_iPlayerInfo[ iPlayer ][ g_iRockets ] > 0 ) {
		CreateRocket( iPlayer );
		return;
	}
	
	if( g_iPlayerInfo[ iPlayer ][ g_iMedKits ] > 0 ) {
		CreateMedKit( iPlayer );
		return;
	}
	
	if( g_iPlayerInfo[ iPlayer ][ g_iPoisonKits ] > 0 ) {
		CreatePoisonKit( iPlayer );
		return;
	}
	
	if( g_iPlayerInfo[ iPlayer ][ g_iMagnets ] > 0 ) {
		CreateMagnet( iPlayer );
		return;
	}
		
	if( g_iPlayerInfo[ iPlayer ][ g_iDynamites ] > 0 ) {
		CreateDynamite( iPlayer );
		return;
	}
	
	if( g_iPlayerInfo[ iPlayer ][ g_iMines ] > 0 ) {
		CreateMine( iPlayer );
		return;
	}
	
	if( g_iPlayerInfo[ iPlayer ][ g_iLightnings ] > 0 ) {
		CreateLightning( iPlayer );
		return;
	}
}

public client_connect( iPlayer ) 
	ResetVariables( iPlayer );

public client_disconnect( iPlayer ) 
	ResetVariables( iPlayer );

ResetVariables( iPlayer ) {
	new iIterator;
	for( iIterator = 0; iIterator < StructPlayerInfo; iIterator ++ )
		g_iPlayerInfo[ iPlayer ][ iIterator ] = 0;
		
	g_fLastUsed[ iPlayer ] = 0.0;
}

//=================================================================================================
//				 	Rockets, Dynamites, Mines...
//=================================================================================================
public CreateRocket( iPlayer ) {
	if( !g_iPlayerInfo[ iPlayer ][ g_iRockets ] ) {
		set_hudmessage( 255, 0, 0, -1.0, 0.2, 0, 6.0, 2.0 );
		ShowSyncHudMsg( iPlayer, g_iHud, "%L", iPlayer, "ML_NO_ROCKETS");
		return PLUGIN_CONTINUE;
	}
	
	if( is_user_alive( iPlayer ) ) {
		if( g_fLastUsed[ iPlayer ] > get_gametime( ) ) {
			set_hudmessage( 255, 0, 0, -1.0, 0.2, 0, 6.0, 2.0 );
			ShowSyncHudMsg( iPlayer, g_iHud, "%L", iPlayer, "ML_WAIT_FOR", g_fLastUsed[ iPlayer ] - get_gametime( ) );
			return PLUGIN_CONTINUE;
		}
		
		g_fLastUsed[ iPlayer ] = get_gametime( ) + 2.0;
		g_iPlayerInfo[ iPlayer ][ g_iRockets ] --;
		
		new Float: fOrigin[ 3 ], Float: fAngle[ 3 ], Float: fVelocity[ 3 ];
		
		entity_get_vector( iPlayer, EV_VEC_v_angle, fAngle );
		entity_get_vector( iPlayer, EV_VEC_origin , fOrigin );
		
		new iEntity = create_entity( "info_target" );
		
		entity_set_string( iEntity, EV_SZ_classname, "Rocket" );
		entity_set_model( iEntity, g_szModels[ Model_Rocket ] );
		
		fAngle[ 0 ] *= -1.0;
		
		entity_set_origin( iEntity, fOrigin );
		entity_set_vector( iEntity, EV_VEC_angles, fAngle );
		
		entity_set_int( iEntity, EV_INT_effects, 2 );
		entity_set_int( iEntity, EV_INT_solid, SOLID_BBOX );
		entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_FLY );
		entity_set_edict( iEntity, EV_ENT_owner, iPlayer );
		
		VelocityByAim( iPlayer, 1000, fVelocity );
		entity_set_vector( iEntity, EV_VEC_velocity, fVelocity );
		
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte( 22 );
		write_short( iEntity );
		write_short( g_iModelIndex[ Sprite_Beam ] );
		write_byte( 45 );
		write_byte( 4 );
		write_byte( 0 );
		write_byte( 255 );
		write_byte( 255 );
		write_byte( 50 );
		message_end( );
		
		if( g_iPlayerInfo[ iPlayer ][ g_iTracerRocket ] ) {
			entity_set_int( iEntity, EV_INT_iuser4, 0 );
			entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.1 );
		}
	}

	return PLUGIN_CONTINUE;
}

public fw_RocketThink( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return;
	
	static iOwner;
	iOwner = entity_get_edict( iEntity, EV_ENT_owner );
	
	if( !is_user_connected( iOwner ) )
		return;
		
	static Float: fOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
		
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SPRITE );
	engfunc( EngFunc_WriteCoord, fOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, fOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, fOrigin[ 2 ] );
	write_short( g_iModelIndex[ Sprite_Smoke ] ); 
	write_byte( 2 );
	write_byte( 200 );
	message_end( );
	
	static iVictim;
	static Float: fDistance;
	
	if( entity_get_int( iEntity, EV_INT_iuser4 ) == 0 ) {
		static Float: fMaximalDistance; fMaximalDistance = 300.0;
		static iPlayers;
		
		for( iPlayers = 1; iPlayers <= g_iMaxPlayers; iPlayers ++ ){
			if( is_user_alive( iPlayers ) && is_valid_ent( iPlayers ) && ( 1 <= iPlayers <= g_iMaxPlayers ) && can_see_fm( iEntity, iPlayers ) && ( iOwner != iPlayers ) && ( cs_get_user_team( iOwner ) != cs_get_user_team( iPlayers ) ) ) {
				fDistance = entity_range( iEntity, iPlayers );
				
				if( fDistance <= fMaximalDistance ) {
					fMaximalDistance = fDistance;
					iVictim = iPlayers;
				}
			}
		}
		
		if( is_user_alive( iVictim ) )
			entity_set_int( iEntity, EV_INT_iuser4, iVictim );
	} else {
		iVictim = entity_get_int( iEntity, EV_INT_iuser4 );
		
		if( is_user_alive( iVictim ) ) {
			static Float: fVictimOrigin[ 3 ];
			entity_get_vector( iVictim, EV_VEC_origin, fVictimOrigin );
			
			static Float: fNewAngle[ 3 ];
			entity_get_vector( iEntity, EV_VEC_angles, fNewAngle );
				
			static Float: fX;
			fX = fVictimOrigin[ 0 ] - fOrigin[ 0 ];
			
			static Float: fZ;
			fZ = fVictimOrigin[ 1 ] - fOrigin[ 1 ];
		
			static Float: fRadians;
			fRadians = floatatan( fZ / fX, radian );
			fNewAngle[ 1 ] = fRadians * ( 180 / 3.14 );
				
			if( fVictimOrigin[ 0 ] < fOrigin[ 0 ] )
				fNewAngle[ 1 ] -= 180.0;
			
			entity_set_vector( iEntity, EV_VEC_angles, fNewAngle );
			
			static Float: fVelocity[ 3 ];
			fDistance = get_distance_f( fOrigin, fVictimOrigin );
		
			if( fDistance > 10.0 ) {
				static Float: fTime;
				fTime = fDistance / 500.0;
		
				fVelocity[ 0 ] = ( fVictimOrigin[ 0 ] - fOrigin[ 0 ] ) / fTime;
				fVelocity[ 1 ] = ( fVictimOrigin[ 1 ] - fOrigin[ 1 ] ) / fTime;
				fVelocity[ 2 ] = ( fVictimOrigin[ 2 ] - fOrigin[ 2 ] ) / fTime;
			} else {
				fVelocity[ 0 ] = 0.0;
				fVelocity[ 1 ] = 0.0;
				fVelocity[ 2 ] = 0.0;
			}
		
			entity_set_vector( iEntity, EV_VEC_velocity, fVelocity );
		} else entity_set_int( iEntity, EV_INT_iuser4, 0 );
	}
		
	entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.075 );
}

public fw_RocketTouch( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return;
	
	new iAttacker = entity_get_edict( iEntity, EV_ENT_owner );
	
	new iOrigin[ 3 ], Float: fOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
	FVecIVec( fOrigin, iOrigin );
	Create_TE_EXPLOSION( iOrigin, g_iModelIndex[ Sprite_Explosion ], 32, 20, 0 );
	Create_TE_BEAMCYLINDER( iOrigin, 300, g_iModelIndex[ Sprite_White ], 0, 0, 10, 10, 255, 0, 255, 255, 255, 1 );
	
	new szEntList[ 33 ];
	new iNumFound = find_sphere_class( iEntity, "player", 90.0, szEntList, charsmax( szEntList ) );
	new iVictim = 0;
	
	for( new i = 0; i < iNumFound; i ++ ) {              
		iVictim = szEntList[ i ];
			
		if( !is_user_connected( iVictim ) || !is_user_alive( iVictim ) || ( get_user_team( iVictim ) == get_user_team( iAttacker ) ) || g_iPlayerInfo[ iVictim ][ g_iExplosionResistance ] )
			continue;
			
		ExecuteHam( Ham_TakeDamage, iVictim, iEntity, iAttacker, g_iPlayerInfo[ iAttacker ][ g_iInstantRocket ] ? 5000.0 : ( 150.0 + float( cod_get_damage( iAttacker ) ) ), 1 );
	}
	
	remove_entity( iEntity );
}

public CreateMedKit( iPlayer ) {
	if( !g_iPlayerInfo[ iPlayer ][ g_iMedKits ] ) {
		set_hudmessage( 0, 128, 255, -1.0, 0.30, 0, 6.0, 2.0 );
		ShowSyncHudMsg( iPlayer, g_iHud, "%L", iPlayer, "ML_NO_MEDKITS" );
	}
	
	if( is_user_alive( iPlayer ) ) {
		g_iPlayerInfo[ iPlayer ][ g_iMedKits ] --;
		
		new Float: fOrigin[ 3 ];
		entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
		
		new iEntity = create_entity( "info_target" );
		entity_set_string( iEntity, EV_SZ_classname, "MedKit" );
		entity_set_edict( iEntity, EV_ENT_owner, iPlayer );
		entity_set_int( iEntity, EV_INT_solid, SOLID_NOT );
		entity_set_vector( iEntity, EV_VEC_origin, fOrigin );
		entity_set_float( iEntity, EV_FL_ltime, halflife_time( ) + 10.0 );
		
		entity_set_model( iEntity, g_szModels[ Model_MedKit ] );
		set_rendering( iEntity, kRenderFxGlowShell, 255, 0, 0, kRenderFxNone, 255 );
		drop_to_floor( iEntity );
		
		entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.1 );	
	}
}

public fw_MedKitThink( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return PLUGIN_HANDLED;
	
	new iPlayer = entity_get_edict( iEntity, EV_ENT_owner );
	new iHP = 5 + floatround( cod_get_resistance( iPlayer ) * 0.5 );
	
	if( entity_get_edict( iEntity, EV_ENT_euser2 ) == 1 ) {              
		new Float: fOrigin[ 3 ], iOrigin[ 3 ];
		entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
		FVecIVec( fOrigin, iOrigin );
		
		new szEntList[ 33 ], iIterator, iVictim, iNewHealth, iNumFound;
		iNumFound = find_sphere_class( 0, "player", 300.0, szEntList, charsmax( szEntList ), fOrigin );
		
		for( iIterator = 0; iIterator < iNumFound; iIterator ++ ) {     
			iVictim = szEntList[ iIterator ];
			
			if( !is_user_alive( iVictim ) || !( 1 <= iVictim <= g_iMaxPlayers ) || get_user_team( iVictim ) != get_user_team( iPlayer ) )
				continue;
			
			iNewHealth = ( get_user_health( iVictim ) + iHP < cod_get_player_max_hp( iVictim ) ) ? get_user_health( iVictim ) + iHP : cod_get_player_max_hp( iVictim );
			set_user_health( iVictim, iNewHealth );          
		}
		
		entity_set_edict( iEntity, EV_ENT_euser2, 0 );
		entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 1.5 );
		
		return PLUGIN_CONTINUE;
	}
	
	if( entity_get_float( iEntity, EV_FL_ltime ) < halflife_time( ) || !is_user_alive( iPlayer ) ) {
		remove_entity( iEntity );
		return PLUGIN_CONTINUE;
	}
	
	if( entity_get_float( iEntity, EV_FL_ltime ) - 2.0 < halflife_time( ) )
		set_rendering( iEntity, kRenderFxNone, 255, 255, 255, kRenderTransAlpha, 100 );
	
	new Float: fOrigin[ 3 ], iOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
	FVecIVec( fOrigin, iOrigin );
	
	Create_TE_BEAMCYLINDER( iOrigin, 300, g_iModelIndex[ Sprite_White ], 0, 0, 10, 10, 255, 255, 100, 100, 128, 5 );
	
	entity_set_edict( iEntity, EV_ENT_euser2 ,1 );
	entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.5 );
	
	return PLUGIN_CONTINUE;
}

public CreatePoisonKit( iPlayer ) {
	if( !g_iPlayerInfo[ iPlayer ][ g_iPoisonKits ] ) {
		set_hudmessage( 0, 128, 255, -1.0, 0.30, 0, 6.0, 2.0 );
		ShowSyncHudMsg( iPlayer, g_iHud, "%L", iPlayer, "ML_NO_POISONKITS" );
	}
	
	if( is_user_alive( iPlayer ) ) {
		g_iPlayerInfo[ iPlayer ][ g_iPoisonKits ] --;
		
		new Float: fOrigin[ 3 ];
		entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
		
		new iEntity = create_entity( "info_target" );
		entity_set_string( iEntity, EV_SZ_classname, "PoisonKit" );
		entity_set_edict( iEntity, EV_ENT_owner, iPlayer );
		entity_set_int( iEntity, EV_INT_solid, SOLID_NOT );
		entity_set_vector( iEntity, EV_VEC_origin, fOrigin );
		entity_set_float( iEntity, EV_FL_ltime, halflife_time( ) + 10.0 );
		
		entity_set_model( iEntity, g_szModels[ Model_MedKit ] );
		set_rendering( iEntity, kRenderFxGlowShell, 0, 255, 0, kRenderFxNone, 255 );
		drop_to_floor( iEntity );
		
		entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.1 );	
	}
}

public fw_PoisonKitThink( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return PLUGIN_HANDLED;
	
	new iPlayer = entity_get_edict( iEntity, EV_ENT_owner );
	new iHP = 15 + floatround( cod_get_damage( iPlayer ) * 0.5 );
	
	if( entity_get_edict( iEntity, EV_ENT_euser2 ) == 1 ) {              
		new Float: fOrigin[ 3 ], iOrigin[ 3 ];
		entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
		FVecIVec( fOrigin, iOrigin );
		
		new szEntList[ 33 ], iIterator, iVictim, iNumFound;
		iNumFound = find_sphere_class( 0, "player", 300.0, szEntList, charsmax( szEntList ), fOrigin );
		
		for( iIterator = 0; iIterator < iNumFound; iIterator ++ ) {     
			iVictim = szEntList[ iIterator ];
			
			if( !is_user_alive( iVictim ) || !( 1 <= iVictim <= g_iMaxPlayers ) || get_user_team( iVictim ) == get_user_team( iPlayer ) )
				continue;
			
			ExecuteHam( Ham_TakeDamage, iVictim, iEntity, iPlayer, float( get_user_health( iVictim ) - iHP ), 1 );
		}
		
		entity_set_edict( iEntity, EV_ENT_euser2, 0 );
		entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 1.5 );
		
		return PLUGIN_CONTINUE;
	}
	
	if( entity_get_float( iEntity, EV_FL_ltime ) < halflife_time( ) || !is_user_alive( iPlayer ) ) {
		remove_entity( iEntity );
		return PLUGIN_CONTINUE;
	}
	
	if( entity_get_float( iEntity, EV_FL_ltime ) - 2.0 < halflife_time( ) )
		set_rendering( iEntity, kRenderFxNone, 255, 255, 255, kRenderTransAlpha, 100 );
	
	new Float: fOrigin[ 3 ], iOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
	FVecIVec( fOrigin, iOrigin );
	
	Create_TE_BEAMCYLINDER( iOrigin, 300, g_iModelIndex[ Sprite_White ], 0, 0, 10, 10, 0, 255, 100, 0, 128, 5 );
	
	entity_set_edict( iEntity, EV_ENT_euser2 ,1 );
	entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.5 );
	
	return PLUGIN_CONTINUE;
}

public CreateMagnet( iPlayer ) {
	if( is_user_alive( iPlayer ) ) {
		g_iPlayerInfo[ iPlayer ][ g_iMagnets ] --;
		
		new Float: fOrigin[ 3 ];
		entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
		
		new iEntity = create_entity( "info_target" );
		entity_set_string( iEntity, EV_SZ_classname, "Magnet" );
		entity_set_edict( iEntity, EV_ENT_owner, iPlayer );
		entity_set_int( iEntity, EV_INT_solid, SOLID_NOT );
		entity_set_vector( iEntity, EV_VEC_origin, fOrigin );
		entity_set_float( iEntity, EV_FL_ltime, halflife_time( ) + 10.0 );
		
		entity_set_model( iEntity, g_szModels[ Model_MedKit ] );
		set_rendering( iEntity, kRenderFxGlowShell, 0, 255, 255, kRenderFxNone, 70 );
		drop_to_floor( iEntity );
		
		entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.1 );	
	}
}

public fw_MagnetThink( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return PLUGIN_HANDLED;
	
	new iPlayer = entity_get_edict( iEntity, EV_ENT_owner );
	
	if( entity_get_edict( iEntity, EV_ENT_euser2 ) == 1 ) {              
		new Float: fOrigin[ 3 ], iOrigin[ 3 ];
		entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
		FVecIVec( fOrigin, iOrigin );
		
		new szEntList[ 33 ], iIterator, iVictim, iNumFound, iWeapons, iNumberOfWeapons, szWeaponName[ 32 ];
		iNumFound = find_sphere_class( 0, "player", 400.0, szEntList, charsmax( szEntList ), fOrigin );
		
		for( iIterator = 0; iIterator < iNumFound; iIterator ++ ) {     
			iVictim = szEntList[ iIterator ];
			
			if( !is_user_alive( iVictim ) || !( 1 <= iVictim <= g_iMaxPlayers ) || get_user_team( iVictim ) == get_user_team( iPlayer ) )
				continue;
				
			iWeapons = entity_get_int( iVictim, EV_INT_weapons );
			
			for( iNumberOfWeapons = 1; iNumberOfWeapons <= 32; iNumberOfWeapons ++ ) {
				if( ( 1 << iNumberOfWeapons ) & iWeapons ) {
					get_weaponname( iNumberOfWeapons, szWeaponName, charsmax( szWeaponName ) );
					engclient_cmd( iVictim, "drop", szWeaponName );
				}
			}
		}
		
		entity_set_edict( iEntity, EV_ENT_euser2, 0 );
		entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 1.5 );
		
		iNumFound = find_sphere_class( 0, "weaponbox", 400.0, szEntList, charsmax( szEntList ), fOrigin );
       
		for( new iIterator = 0; iIterator < iNumFound; iIterator ++ ) {
			if( get_entity_distance( iEntity, szEntList[ iIterator ] ) > 50.0 )
				set_velocity_to_origin( szEntList[ iIterator ], fOrigin, 999.0 );
		}
	
		return PLUGIN_CONTINUE;
	}
	
	if( entity_get_float( iEntity, EV_FL_ltime ) < halflife_time( ) || !is_user_alive( iPlayer ) ) {
		remove_entity( iEntity );
		return PLUGIN_CONTINUE;
	}
	
	if( entity_get_float( iEntity, EV_FL_ltime ) - 2.0 < halflife_time( ) )
		set_rendering( iEntity, kRenderFxNone, 255, 255, 255, kRenderTransAlpha, 100 );
	
	new Float: fOrigin[ 3 ], iOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
	FVecIVec( fOrigin, iOrigin );
	
	Create_TE_BEAMCYLINDER( iOrigin, 300, g_iModelIndex[ Sprite_White ], 0, 0, 10, 10, 0, 0, 255, 255, 128, 5 );
	
	entity_set_edict( iEntity, EV_ENT_euser2, 1 );
	entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.5 );
	
	return PLUGIN_CONTINUE;
}

public CreateDynamite( iPlayer ) {
	if( !g_iPlayerInfo[ iPlayer ][ g_iDynamites ] ) {
		set_hudmessage( 0, 128, 255, -1.0, 0.30, 0, 6.0, 2.0 );
		ShowSyncHudMsg( iPlayer, g_iHud, "%L", iPlayer, "ML_NO_DYNAMITES" );
	}
	
	if( is_user_alive( iPlayer ) ) {
		g_iPlayerInfo[ iPlayer ][ g_iDynamites ] --;
		CreateExplosion( iPlayer, iPlayer, false, ( 120.0 + float( cod_get_damage( iPlayer ) ) ), true );
	}
}

public CreateMine( iPlayer ) {
	if( !g_iPlayerInfo[ iPlayer ][ g_iMines ] ) {
		set_hudmessage( 0, 128, 255, -1.0, 0.30, 0, 6.0, 2.0 );
		ShowSyncHudMsg( iPlayer, g_iHud, "%L", iPlayer, "ML_NO_MINES" );
		return PLUGIN_CONTINUE;
	}
	
	if( is_user_alive( iPlayer ) ) {
		g_iPlayerInfo[ iPlayer ][ g_iMines ] --;
		
		new Float: fOrigin[ 3 ];
		entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
		
		new iEntity = create_entity( "info_target" );
		entity_set_string( iEntity, EV_SZ_classname, "Mine" );
		entity_set_edict( iEntity, EV_ENT_owner, iPlayer );
		entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_TOSS );
		entity_set_origin( iEntity, fOrigin );
		entity_set_int( iEntity, EV_INT_solid, SOLID_BBOX );
		
		entity_set_model( iEntity, g_szModels[ Model_Mine ] );
		entity_set_size( iEntity, Float: { -16.0, -16.0, 0.0 }, Float: { 16.0, 16.0, 2.0 } );
		
		drop_to_floor( iEntity );
		
		entity_set_float( iEntity, EV_FL_nextthink, halflife_time(  ) + 0.01 ) ;
		
		set_rendering( iEntity, kRenderFxNone, 0, 0, 0, kRenderTransTexture, 50 );
	}

	return PLUGIN_CONTINUE;
}

public fw_MineTouch( iEntity, iToucher ) {
	new iAttacker = entity_get_edict( iEntity, EV_ENT_owner );
	
	if( !is_user_connected( iAttacker ) )
		return;
	
	if( iAttacker <= 0 || iAttacker > g_iMaxPlayers )
		return;
		
	if( get_user_team( iAttacker ) == get_user_team( iToucher ) )
		return;
	
	new iOrigin[ 3 ], Float: fOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
	FVecIVec( fOrigin, iOrigin );
		
	Create_TE_EXPLOSION( iOrigin, g_iModelIndex[ Sprite_Explosion ], 32, 20, 0 );
	Create_TE_BEAMCYLINDER( iOrigin, 300, g_iModelIndex[ Sprite_White ], 0, 0, 10, 10, 255, 0, 255, 255, 255, 1 );
		
	new szEntList[ 33 ];
	new iNumFound = find_sphere_class( iEntity, "player", 90.0, szEntList, charsmax( szEntList ) );
		
	for( new i = 0; i < iNumFound; i ++ ) {              
		new iVictim = szEntList[ i ];
		
		if( iVictim <= 0 || iVictim > g_iMaxPlayers )
			continue;
			
		if( !is_user_connected( iVictim ) || !is_user_alive( iVictim ) || iVictim == iAttacker || get_user_team( iVictim ) == get_user_team( iAttacker ) || !( 1 <= iVictim <= g_iMaxPlayers ) || g_iPlayerInfo[ iVictim ][ g_iExplosionResistance ] )
			continue;
			
		ExecuteHam( Ham_TakeDamage, iVictim, iEntity, iAttacker, g_iPlayerInfo[ iAttacker ][ g_iInstantMine ] ? 5000.0 : 100.0 + float( cod_get_damage( iAttacker ) ), 1 );
	}
	
	remove_entity( iEntity );
}

public CreateLightning( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	new iTarget, iBody;
	get_user_aiming( iPlayer, iTarget, iBody );
		
	if( is_user_connected( iTarget ) && is_user_alive( iTarget ) && ( 1 <= iTarget <= g_iMaxPlayers ) ) {
		if( get_user_team( iTarget ) == get_user_team( iPlayer ) )
			return;
			
		if( g_fLastUsed[ iPlayer ] > get_gametime( ) ) {
			set_hudmessage( 255, 0, 0, -1.0, 0.2, 0, 6.0, 2.0 );
			ShowSyncHudMsg( iPlayer, g_iHud, "%L", iPlayer, "ML_WAIT_FOR", g_fLastUsed[ iPlayer ] - get_gametime( ) );
			return;
		}
		
		g_fLastUsed[ iPlayer ] = get_gametime( ) + 2.0;
		g_iPlayerInfo[ iPlayer ][ g_iLightnings ] --;
			
		new iEntity = create_entity( "info_target" );
		
		if( !is_valid_ent( iEntity ) )
			return;
		
		entity_set_string( iEntity, EV_SZ_classname, "ByM_Lightning" );
			
		ExecuteHam( Ham_TakeDamage, iTarget, iEntity, iPlayer, 90.0 + float( cod_get_damage( iPlayer ) ), 1 );
		remove_entity( iEntity );
			
		Create_TE_BEAMENTS( iPlayer, iTarget, g_iModelIndex[ Sprite_Lightning ], 0, 10, floatround( 1.0 * 10 ), 150, 5, 200, 200, 200, 200, 10 );
			
		emit_sound( iPlayer, CHAN_WEAPON, "ambience/thunder_clap.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		emit_sound( iTarget, CHAN_WEAPON, "ambience/thunder_clap.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}

//=================================================================================================
//				 	Natives
//=================================================================================================

public plugin_natives( ) {
	register_native( "cod_set_rockets", "NativeSetRockets", 1 );
	register_native( "cod_set_medkits", "NativeSetMedKits", 1 );
	register_native( "cod_set_poisonkits", "NativeSetPoisonKits", 1 );
	register_native( "cod_set_magnets", "NativeSetMagnets", 1 );
	register_native( "cod_set_dynamites", "NativeSetDynamites", 1 );
	register_native( "cod_set_mines", "NativeSetMines", 1 );
	register_native( "cod_set_lightnings", "NativeSetLightnings", 1 );
	register_native( "cod_set_explosion_resistance", "NativeSetExpResis", 1 );
	register_native( "cod_reset_secondary_weapons", "NativeReset", 1 );
	register_native( "cod_create_explosion", "NativeCreateExplosion", 1 );
	register_native( "cod_create_beam_ring", "NativeCreateBeamRing", 1 );
}

public NativeSetRockets( iPlayer, iValue, iInstant, iTracer ) {
	g_iPlayerInfo[ iPlayer ][ g_iRockets ] = iValue;
	g_iPlayerInfo[ iPlayer ][ g_iInstantRocket ] = iInstant;
	g_iPlayerInfo[ iPlayer ][ g_iTracerRocket ] = iTracer;
}

public NativeSetMedKits( iPlayer, iValue ) 
	g_iPlayerInfo[ iPlayer ][ g_iMedKits ] = iValue;
	
public NativeSetPoisonKits( iPlayer, iValue ) 
	g_iPlayerInfo[ iPlayer ][ g_iPoisonKits ] = iValue;
	
public NativeSetMagnets( iPlayer, iValue )
	g_iPlayerInfo[ iPlayer ][ g_iMagnets ] = iValue;
	
public NativeSetDynamites( iPlayer, iValue ) 
	g_iPlayerInfo[ iPlayer ][ g_iDynamites ] = iValue;
	
public NativeSetMines( iPlayer, iValue, iInstant )  {
	g_iPlayerInfo[ iPlayer ][ g_iMines ] = iValue;
	g_iPlayerInfo[ iPlayer ][ g_iInstantMine ] = iInstant;
}

public NativeSetLightnings( iPlayer, iValue, iInstant ) 
	g_iPlayerInfo[ iPlayer ][ g_iLightnings ] = iValue;
	
public NativeSetExpResis( iPlayer, iValue ) 
	g_iPlayerInfo[ iPlayer ][ g_iExplosionResistance ] = iValue;
	
public NativeReset( iPlayer )
	ResetVariables( iPlayer );
	
public NativeCreateExplosion( iAttacker, iEntity, bool: bJustExplode, Float: fHealth, bool: bBeamCylinder )
	CreateExplosion( iAttacker, iEntity, bJustExplode, fHealth, bBeamCylinder );
	
public NativeCreateBeamRing( iOrigin[ 3 ], iPlusOrigin, iStartFrame, iFrameRate, iLife, iWidth, iNoise, iRed, iGreen, iBlue, iAlpha, iSpeed )
	Create_TE_BEAMCYLINDER( iOrigin, iPlusOrigin, g_iModelIndex[ Sprite_White ], iStartFrame, iFrameRate, iLife, iWidth, iNoise, iRed, iGreen, iBlue, iAlpha, iSpeed );
	
//=================================================================================================
//				 	Stocks
//=================================================================================================
stock Create_TE_BEAMENTS( iStartEntity, iEndEntity, iSprite, iStartFrame, iFrameRate, iLife, iWidth, iNoise, iRed, iGreen, iBlue, iAlpha, iSpeed ) {
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMENTS );
	write_short( iStartEntity );
	write_short( iEndEntity );
	write_short( iSprite );
	write_byte( iStartFrame );
	write_byte( iFrameRate );
	write_byte( iLife );
	write_byte( iWidth );
	write_byte( iNoise );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iAlpha );
	write_byte( iSpeed );
	message_end( );
}

stock Create_TE_BEAMCYLINDER( iOrigin[ 3 ], iPlusOrigin, iSprite, iStartFrame, iFrameRate, iLife, iWidth, iNoise, iRed, iGreen, iBlue, iAlpha, iSpeed ) {
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] + iPlusOrigin );
	write_coord( iOrigin[ 2 ] + iPlusOrigin );
	write_short( iSprite );
	write_byte( iStartFrame );
	write_byte( iFrameRate );
	write_byte( iLife );
	write_byte( iWidth );
	write_byte( iNoise );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iAlpha );
	write_byte( iSpeed );
	message_end(  );
}

stock Create_TE_EXPLOSION( iOrigin[ 3 ], iSprite, iScale, iFrameRate, iFlags ) {
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY, iOrigin );
	write_byte( TE_EXPLOSION );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( iSprite );
	write_byte( iScale );
	write_byte( iFrameRate );
	write_byte( iFlags );
	message_end(  );
}

stock CreateExplosion( iAttacker, iEntity, bool: bJustExplode = true, Float: fHealth, bool: bBeamCylinder = false ) {
	new Float: fOrigin[ 3 ], iOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
	FVecIVec( fOrigin, iOrigin );
		
	Create_TE_EXPLOSION( iOrigin, g_iModelIndex[ Sprite_Explosion ], 32, 20, 0 );
	if( bBeamCylinder ) Create_TE_BEAMCYLINDER( iOrigin, 300, g_iModelIndex[ Sprite_White ], 0, 0, 10, 10, 255, 0, 255, 255, 255, 1 );
	
	if( bJustExplode ) 
		return;
	
	new szEntityList[ 33 ], iNumFound, iVictim, iIterator;
	iNumFound = find_sphere_class( iEntity, "player", 100.0, szEntityList, charsmax( szEntityList ) );
		
	for( iIterator = 0; iIterator < iNumFound; iIterator ++ ) {              
		iVictim = szEntityList[ iIterator ];
		
		if( !is_user_connected( iAttacker ) )
			break;

		if( iVictim == iAttacker || !is_user_alive( iVictim ) || !( 1 <= iVictim <= g_iMaxPlayers ) || g_iPlayerInfo[ iVictim ][ g_iExplosionResistance ] )
			continue;
			
		ExecuteHam( Ham_TakeDamage, iVictim, iEntity, iAttacker, fHealth - float( cod_get_resistance( iVictim ) ), 1 );
	}
}

// Original author: NST
stock bool: can_see_fm( iEntity1, iEntity2 ) {
	if( !iEntity1 || !iEntity2 )
		return false;

	if ( is_valid_ent( iEntity1 ) && is_valid_ent( iEntity1 ) ) {
		new iFlags = entity_get_int( iEntity1, EV_INT_flags );
		
		if( iFlags & EF_NODRAW || iFlags & FL_NOTARGET )
			return false;

		new Float: fLookerOrigin[ 3 ];
		new Float: fTargetBaseOrigin[ 3 ];
		new Float: fTargetOrigin[ 3 ];
		new Float: fTemporary[ 3 ];

		pev( iEntity1, pev_origin, fLookerOrigin );
		pev( iEntity1, pev_view_ofs, fTemporary );
		
		fLookerOrigin[ 0 ] += fTemporary[ 0 ];
		fLookerOrigin[ 1 ] += fTemporary[ 1 ];
		fLookerOrigin[ 2 ] += fTemporary[ 2 ];

		pev( iEntity2, pev_origin, fTargetBaseOrigin );
		pev( iEntity2, pev_view_ofs, fTemporary );
		fTargetOrigin[ 0 ] = fTargetBaseOrigin[ 0 ] + fTemporary[ 0 ];
		fTargetOrigin[ 1 ] = fTargetBaseOrigin[ 1 ] + fTemporary[ 1 ];
		fTargetOrigin[ 2 ] = fTargetBaseOrigin[ 2 ] + fTemporary[ 2 ];

		engfunc( EngFunc_TraceLine, fLookerOrigin, fTargetOrigin, 0, iEntity1, 0 );
		if( get_tr2( 0, TraceResult:TR_InOpen ) && get_tr2( 0, TraceResult:TR_InWater ) )
			return false;
		else {
			new Float: fFraction;
			get_tr2( 0, TraceResult: TR_flFraction, fFraction );
			if( fFraction == 1.0 || ( get_tr2( 0, TraceResult: TR_pHit ) == iEntity2 ) )
				return true;
			else {
				fTargetOrigin[ 0 ] = fTargetBaseOrigin[ 0 ];
				fTargetOrigin[ 1 ] = fTargetBaseOrigin[ 1 ];
				fTargetOrigin[ 2 ] = fTargetBaseOrigin[ 2 ];
				
				engfunc( EngFunc_TraceLine, fLookerOrigin, fTargetOrigin, 0, iEntity1, 0 );
				get_tr2( 0, TraceResult: TR_flFraction, fFraction );
				if( fFraction == 1.0 || ( get_tr2( 0, TraceResult:TR_pHit ) == iEntity2 ) )
					return true;
				else {
					fTargetOrigin[ 0 ] = fTargetBaseOrigin[ 0 ];
					fTargetOrigin[ 1 ] = fTargetBaseOrigin[ 1 ];
					fTargetOrigin[ 2 ] = fTargetBaseOrigin[ 2 ] - 17.0;
					
					engfunc( EngFunc_TraceLine, fLookerOrigin, fTargetOrigin, 0, iEntity1, 0 );
					get_tr2( 0, TraceResult: TR_flFraction, fFraction );
					if( fFraction == 1.0 || ( get_tr2( 0, TraceResult: TR_pHit ) == iEntity2 ) )
						return true;
				}
			}
		}
	}
	
	return false;
}

stock get_velocity_to_origin( iEntity, Float: fOrigin[ 3 ], Float: fSpeed, Float: fVelocity[ 3 ] ) {
	new Float: fEntOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fEntOrigin );
	
	new Float: fDistance[ 3 ];
	fDistance[ 0 ] = fEntOrigin[ 0 ] - fOrigin[ 0 ];
	fDistance[ 1 ] = fEntOrigin[ 1 ] - fOrigin[ 1 ];
	fDistance[ 2 ] = fEntOrigin[ 2 ] - fOrigin[ 2 ];
	
	new Float: fTime = -( vector_distance( fEntOrigin,fOrigin ) / fSpeed );
	
	fVelocity[ 0 ] = fDistance[ 0 ] / fTime;
	fVelocity[ 1 ] = fDistance[ 1 ] / fTime;
	fVelocity[ 2 ] = fDistance[ 2 ] / fTime + 50.0;
	
	return ( fVelocity[ 0 ] && fVelocity[ 1 ] && fVelocity[ 2 ] );
}

stock set_velocity_to_origin( iEntity, Float: fOrigin[ 3 ], Float: fSpeed ) {
        new Float: fVelocity[ 3 ];
        get_velocity_to_origin( iEntity, fOrigin, fSpeed, fVelocity );
       
        entity_set_vector( iEntity, EV_VEC_velocity, fVelocity );
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
