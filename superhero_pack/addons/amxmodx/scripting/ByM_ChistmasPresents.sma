// Libraries
#include < amxmodx >
#include < hamsandwich >
#include < bym_cod_2016 >
#include < colorchat >
#include < dhudmessage >
#include < fakemeta >
#include < nvault >
#include < engine >
#include < xs >

// Macros
#define Struct			enum
#define MAX_SPAWNS		30

// Structs
Struct StructFiles {
	g_szFolder,
	g_szLocationsFile,
	g_szLogsFile
}

// Variables
new const g_szFiles[ StructFiles ][ ] = {
	"addons/amxmodx/configs/ByM_ChristmasPresent/",
	"addons/amxmodx/configs/ByM_ChristmasPresent/Locations.ini",
	"addons/amxmodx/configs/ByM_ChristmasPresent/Logs.txt"
};

new const g_szModels[ 3 ][ ] = {
	"models/ByM_Present1.mdl",
	"models/ByM_Present2.mdl",
	"models/ByM_Present3.mdl"
}

new const g_szSprite[ ] = "sprites/ByM_Present.spr";
new const g_szSantaSound[ ] = "sound/ByM_Santa.mp3";

new g_iModelIndex[ 3 ];

new Float: g_fSpawns[ MAX_SPAWNS ][ 3 ];
new g_iSpawns = 0;

new bool: g_bDisplaySpawns[ 33 ] = false;
new bool: g_bCanSee[ 33 ] = false;
new g_iMaxPlayers;

new const g_szChars[ ][ ] = {
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1"
}

new bool: g_bFistTime = false;
new g_iRandom = 5;

public plugin_init( ) {
	// Register plugin
	register_plugin( "[ByM] Christmas Present", "1.0", "Milutinke (ByM)" );
	
	// Register Ham Sandwich Module Forwards
	RegisterHam( Ham_TakeDamage, "player", "fw_HamTakeDamage" );
	
	// Fake Meta forwards
	register_forward( FM_AddToFullPack, "fw_FmAddFullToPack", 1 );
	register_forward( FM_CheckVisibility, "fw_FmCheckVisibility" );
	register_forward( FM_Touch, "fw_FmTouchPresent" );
	
	// Register commands
	register_clcmd( "say /presents", "fw_CommandPresentsMenu" );
	register_clcmd( "say /pr", "fw_CommandPresentsMenu" );
	register_clcmd( "say /ptr", "fw_CommandTest" );
}

InitialiseTimer( ) {
	// Create new entity
	new iEntity = create_entity( "info_target" );
	
	// Check if entity is valid
	if( !iEntity )
		return;
		
	// Get max players number
	g_iMaxPlayers = get_maxplayers( );
		
	// Set entity class name and next think
	entity_set_string( iEntity, EV_SZ_classname, "PresentsTimer" );
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 10.0 );
	
	// Register think for entity (timer)
	register_think( "PresentsTimer", "fw_PresentsTimer" );
	
	new szMapName[ 32 ];
	get_mapname( szMapName, charsmax( szMapName ) );
	
	if( equal( szMapName, "de_inferno" ) ) g_iRandom = 7;
	else if( equal( szMapName, "de_dust2000" ) ) g_iRandom = 7;
	else if( equal( szMapName, "cs_militia" ) || equal( szMapName, "de_dust4ever" ) ) g_iRandom = 6;
	else if( equal( szMapName, "de_dust2006" ) ) g_iRandom = 9;
	else if( equal( szMapName, "de_dustyaztec" ) ) g_iRandom = 6;
	else if( equal( szMapName, "de_dust" ) ) g_iRandom = 6;
	else if( equal( szMapName, "de_westwood" ) ) g_iRandom = 6;
	else if( equal( szMapName, "cs_assault_upc" ) ) g_iRandom = 6;
}

public plugin_natives( ) {
	register_native( "bym_set_cansee", "NativeSetCanSee", 1 );
}

public NativeSetCanSee( iPlayer, iValue )
	g_bCanSee[ iPlayer ] = bool: iValue;

public fw_PresentsTimer( iEntity ) {
	// Check if entity (timer) is valid
	if( !is_valid_ent( iEntity ) )
		return;
	
	// Cancel the timer if time-left is less than 120 secound
	if( get_timeleft( ) < 120 && get_timeleft( ) != 0 )
		return;
		
	// Set new task to new delay
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + GetNextTime( ) );
	
	// Do not spawn present first time
	if( g_bFistTime ) {
		g_bFistTime = false;
		return;
	}
	
	// Chance for present to spawn
	if( !( random_num( 1, g_iRandom ) == 1 ) )
		return;
		
	// If there is no online players then skip
	if( GetOnlinePlayers( ) <= 0 )
		return;
	
	// Remove all previous presents which haven't been found
	new iEntityPresent = find_ent_by_class( -1, "ChristmasPresent" );
	while( iEntityPresent >  0)  {
		remove_entity( iEntityPresent );
		iEntityPresent = find_ent_by_class( iEntityPresent, "ChristmasPresent" );	
	}
	
	new iEntitySprite = find_ent_by_class( -1, "PresentSprite" );
	while( iEntitySprite >  0)  {
		remove_entity( iEntitySprite );
		iEntitySprite = find_ent_by_class( iEntitySprite, "PresentSprite" );	
	}
	
	// Create new present on random spawn
	CreatePresent( random_num( 0, g_iSpawns ) );
		
	// Notfy all alive and connected players about the present
	static iPlayer;
	for( iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer ++ ) {
		if( is_user_connected( iPlayer ) ) {
			set_dhudmessage( 255, 0, 255, -1.0, 0.7, 0, 6.0, 10.0 );
			show_dhudmessage( iPlayer, "%L", iPlayer, "ML_PRESENT_APPEREAD" );
			
			client_cmd( iPlayer, "mp3 stop; mp3 play %s", g_szSantaSound );
		}
	}
}

public plugin_precache( ) {
	// Precache model
	for( new iModels = 0; iModels < sizeof( g_szModels ); iModels ++ )
		g_iModelIndex[ iModels ] = engfunc( EngFunc_PrecacheModel, g_szModels[ iModels ] );
		
	precache_model( g_szSprite );
	precache_generic( g_szSantaSound );
		
	// Load spawns
	LoadSpawns( );
}

LoadSpawns( ) {
	// Check if directory with presents exists, if it does not, then create it
	if( !dir_exists( g_szFiles[ g_szFolder ] ) )
		mkdir( g_szFiles[ g_szFolder ] );
	
	// Check if file with present locations exists
	if( !file_exists( g_szFiles[ g_szLocationsFile ] ) )
		return;
		
	// Open the file with snowmans
	new iFile = fopen( g_szFiles[ g_szLocationsFile ], "rt" );
	
	// Initialise local temporary variables
	new szData[ 256 ], szDataPieces[ 4 ][ 32 ], szMapName[ 32 ];
	
	// Get map name
	get_mapname( szMapName, charsmax( szMapName ) );

	while( iFile && !feof( iFile ) ) {
		fgets( iFile, szData, charsmax( szData ) );

		// Skip Comments
		if( szData[ 0 ] == EOS || ( szData[ 0 ] == ';' ) || ( szData[ 0 ] == '/' && szData[ 1 ] == '/' ) )
			continue;
		
		// Parse variables (if there is less than 4 then skip)
		if( parse( szData, szDataPieces[ 0 ], charsmax( szDataPieces[ ] ), szDataPieces[ 1 ], charsmax( szDataPieces[ ] ), szDataPieces[ 2 ], charsmax( szDataPieces[ ] ),  szDataPieces[ 3 ], charsmax( szDataPieces[ ] ) ) < 4 )
			continue;
	
		// Skip other maps
		if( !equal( szDataPieces[ 0 ], szMapName ) )
			continue;
			
		// Add Snowmans to the list
		g_fSpawns[ g_iSpawns ][ 0 ] = str_to_float( szDataPieces[ 1 ] );
		g_fSpawns[ g_iSpawns ][ 1 ] = str_to_float( szDataPieces[ 2 ] );
		g_fSpawns[ g_iSpawns ][ 2 ] = str_to_float( szDataPieces[ 3 ] );
		
		// Increase spawn count
		g_iSpawns ++;
		
		// Check if there is maximum spawns, if there is exit out of the loop (break)
		if( g_iSpawns > MAX_SPAWNS )
			break;
	}
	
	// Log message
	server_print( "[ByM Christmas Presents] Loaded %d/%d spawns", g_iSpawns, MAX_SPAWNS );

	// Close file handle if it exists
	if( iFile ) 
		fclose( iFile );
		
	// Initialise timer if there is spawn places on the map
	if( g_iSpawns > 0 )
		InitialiseTimer( );
}

public fw_HamTakeDamage( iVictim, iInfilictor, iAttacker, Float: fDamage, iDamageType ) {
	if( !is_user_connected( iVictim ) || !g_bDisplaySpawns[ iVictim ] )
		return HAM_IGNORED;
		
	return HAM_SUPERCEDE;
}

// Snow spawn locations to player with presents admin menu opened
public fw_FmAddFullToPack( iEsHandle, iE, iEntity, iHost, iHostFlags, iPlayer, iPset ) {
	// Skip if player is not connected and if entity is invalid
	if( !is_user_connected( iHost ) || !is_valid_ent( iEntity ) )
		return FMRES_IGNORED;
	
	// Get entity class name
	static szClassName[ 32 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	if( equal( szClassName, "PresentSprite" ) && g_bCanSee[ iHost ] ) {
		if( !is_user_alive( iHost ) ) set_es( iEsHandle, ES_Effects, get_es( iEsHandle, ES_Effects ) | EF_NODRAW );
		else if( is_user_alive( iHost ) ) set_es( iEsHandle, ES_Effects, get_es( iEsHandle, ES_Effects ) & ~EF_NODRAW );
	
		static iPointTrace;
		iPointTrace = create_tr2( );
		static Float: fStart[ 3 ], Float: fEnd[ 3 ], Float: fEndVector[ 3 ], Float: fNormalised[ 3 ];
		
		entity_get_vector( iHost, EV_VEC_origin, fStart );
		entity_get_vector( iEntity, EV_VEC_origin, fEnd );
		
		engfunc( EngFunc_TraceLine, fStart, fEnd, IGNORE_MONSTERS, iEntity, iPointTrace );
		static Float: fFriction;
		get_tr2( iPointTrace, TR_flFraction, fFriction );		
	
		get_tr2( iPointTrace, TR_vecEndPos, fEndVector );
		get_tr2( iPointTrace, TR_vecPlaneNormal, fNormalised );
	
		xs_vec_mul_scalar( fNormalised, 7.0, fNormalised );
		xs_vec_add( fEndVector, fNormalised, fNormalised );
		
		set_es( iEsHandle, ES_Origin, fNormalised );
		static Float: fDistance, Float: fSpriteScale;
		
		entity_get_vector( iEntity, EV_VEC_origin, fStart );
		entity_get_vector( iHost, EV_VEC_origin, fEnd );
		
		fDistance = get_distance_f( fStart, fEnd );
	
		if( fDistance <= 39.37 * 100.0 && is_valid_ent( entity_get_int( iEntity, EV_INT_iuser1 ) ) ) {
			fDistance = get_distance_f( fEndVector, fEnd );
			fSpriteScale = 10.0 / fDistance;
		
			if( fSpriteScale > 0.5 )
				fSpriteScale = 0.5;
	
			if( fFriction != 1.0 ) {	
				if( fSpriteScale < 0.5 )
					fSpriteScale = 0.5;
			}
			else {
				if( fSpriteScale < 0.5 )
					fSpriteScale = 0.5;
			}
			
			set_es( iEsHandle, ES_Scale, fSpriteScale );
		}
		else {
			set_es( iEsHandle, ES_Effects, get_es( iEsHandle, ES_Effects ) | EF_NODRAW );
			remove_entity( iEntity );
		}
		
		free_tr2( iPointTrace );
	}
	
	// Skip if entity is not present spawn
	if( equal( szClassName, "PresentSpawn" ) && g_bDisplaySpawns[ iHost ] ) {
		// Show spawn location to admin with admin menu opened
		set_es( iEsHandle, ES_RenderFx, kRenderFxSolidSlow );
		set_es( iEsHandle, ES_RenderColor, { 0, 255, 255 } );
		set_es( iEsHandle, ES_RenderMode, kRenderTransAdd );
		set_es( iEsHandle, ES_RenderAmt, 255 );
	}
	
	return FMRES_IGNORED;
}

public fw_FmCheckVisibility( iEntity, S ) {
	if( !is_valid_ent( iEntity ) )
		return FMRES_IGNORED;
	
	static szClassName[ 32 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	if( !equal( szClassName, "PresentSprite" ) )
		return FMRES_IGNORED;
	
	forward_return( FMV_CELL, 1 );
	
	return FMRES_SUPERCEDE;
}

public fw_FmTouchPresent( iEntity, iPlayer ) {
	// Check if player isn't connected and if entity is invalid, if true then skip
	if( !is_user_alive( iPlayer ) || !is_valid_ent( iEntity ) )
		return FMRES_IGNORED;
		
	// Get entity class name
	new szClassName[ 32 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	// Check if entity is present
	if( !equal( szClassName, "ChristmasPresent" ) )
		return FMRES_IGNORED;
		
	// Get player origin for effects
	new iOrigin[ 3 ];
	get_user_origin( iPlayer, iOrigin );
		
	// Particles implode
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_IMPLOSION );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_byte( 400 );
	write_byte( 100 );
	write_byte( 7 );
	message_end( );
		
	// Particles explode
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_PARTICLEBURST );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( 300 );
	write_byte( 111 );
	write_byte( 40 );
	message_end( );
	
	// Screen Fade
	message_begin( MSG_ONE, get_user_msgid( "ScreenFade" ), { 0,0,0 }, iPlayer );
	write_short( 1 << 10 );
	write_short( 1 << 10 );
	write_short( 1 << 4 );
	write_byte( 255 );
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 50 );
	message_end( );
	
	// Initialise temporary variables
	new szName[ 32 ], szDate[ 32 ], szText[ 128 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
	get_time( "%d.%m.%Y %H:%M:%S", szDate, charsmax( szDate ) );
	
	// Give random reward to lucky bastard
	switch( random( 40 ) ) {
		case 0 .. 9: {
			new iXP = random_num( 500, 5000 );
			formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won %d XP", szDate, szName, iXP );
			
			cod_set_xp( iPlayer, cod_get_xp( iPlayer ) + iXP );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won ^4%d ^1XP!", iXP );
			ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won ^4%d ^1XP for christmas/new year!", szName, iXP );
		}
		
		case 10 .. 19: {
			new iGold = random_num( 100, 1700 );
			formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won %d gold", szDate, szName, iGold );
			cod_set_gold( iPlayer, cod_get_xp( iPlayer ) + iGold );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won ^4%d ^1gold!", iGold );
			ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won ^4%d ^1gold for christmas/new year!", szName, iGold );
		}
		
		case 20 .. 29: {
			if( cod_is_vip( iPlayer ) ) {
				new iGold = random_num( 100, 1700 );
				formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won %d gold", szDate, szName, iGold );
				cod_set_gold( iPlayer, cod_get_xp( iPlayer ) + iGold );
				ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won ^4%d ^1gold!", iGold );
				ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won ^4%d ^1gold for christmas/new year!", szName, iGold );
				return FMRES_IGNORED;
			}
			
			new iDays = random_num( 5, 30 );
			formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won VIP for %d days", szDate, szName, iDays );
			cod_give_vip( iPlayer, iDays );
			cod_reload_vips( );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won ^4VIP ^1for ^4%d ^1days.", iDays );
			ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won ^4VIP ^1for ^4%d ^1days for christmas/new year!", szName, iDays );
		}
		
		case 30 .. 40: {
			new szRandom[ 3 ];
			new szClass[ 64 ];
			copy( szRandom, charsmax( szRandom ), g_szChars[ random( sizeof( g_szChars ) - 1 ) ] );
			new iDays = random_num( 5, 30 );
			
			if( !bym_get_flag( iPlayer, bym_get_flag_int( szRandom ) ) ) {
				new iClass = GetClassByFlag( szRandom );
				cod_get_class_name( iClass, szClass, charsmax( szClass ) );

				ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won class ^4%L ^1for ^4%d ^1days.", iPlayer, szClass, iDays );
				ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won class ^4%L ^1for ^4%d ^1days for christmas/new year!", szName, LANG_PLAYER, szClass, iDays );
						
				bym_give_flag( iPlayer, bym_get_flag_int( szRandom ), iDays );
				formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won class %L for %d days", szDate, szName, LANG_SERVER, szClass, iDays );
			} else {
				copy( szRandom, charsmax( szRandom ), g_szChars[ random( sizeof( g_szChars ) - 1 ) ] );
				
				if( !bym_get_flag( iPlayer, bym_get_flag_int( szRandom ) ) ) {
					new iClass = GetClassByFlag( szRandom );
					cod_get_class_name( iClass, szClass, charsmax( szClass ) );
	
					ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won class ^4%L ^1for ^4%d ^1days.", iPlayer, szClass, iDays );
					ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won class ^4%L ^1for ^4%d ^1days for christmas/new year!", szName, LANG_PLAYER, szClass, iDays );
							
					bym_give_flag( iPlayer, bym_get_flag_int( szRandom ), iDays );
					formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won class %L for %d days", szDate, szName, LANG_SERVER, szClass, iDays );
				}
				else {
					copy( szRandom, charsmax( szRandom ), g_szChars[ random( sizeof( g_szChars ) - 1 ) ] );
					
					if( !bym_get_flag( iPlayer, bym_get_flag_int( szRandom ) ) ) {
						new iClass = GetClassByFlag( szRandom );
						cod_get_class_name( iClass, szClass, charsmax( szClass ) );
		
						ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won class ^4%L ^1for ^4%d ^1days.", iPlayer, szClass, iDays );
						ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won class ^4%L ^1for ^4%d ^1days for christmas/new year!", szName, LANG_PLAYER, szClass, iDays );
								
						bym_give_flag( iPlayer, bym_get_flag_int( szRandom ), iDays );
						formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won class %L for %d days", szDate, szName, LANG_SERVER, szClass, iDays );
					} else {
						if( cod_is_vip( iPlayer ) ) {
							new iGold = random_num( 100, 1700 );
							formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won %d gold", szDate, szName, iGold );
							cod_set_gold( iPlayer, cod_get_xp( iPlayer ) + iGold );
							ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won ^4%d ^1gold!", iGold );
							ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won ^4%d ^1gold for christmas/new year!", szName, iGold );
							return FMRES_IGNORED;
						}
					
						formatex( szText, charsmax( szText ), "[%s] Player %s has found present and won VIP for %d days", szDate, szName, iDays );
						cod_give_vip( iPlayer, iDays );
						cod_reload_vips( );
						ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1Congratulations, you won ^4VIP ^1for ^4%d ^1days.", iDays );
						ColorChat( 0, GREEN, "[CoD:Mw4] ^1Player ^4%s ^1has found present and won ^4VIP ^1for ^4%d ^1days for christmas/new year!", szName, iDays );
					}
				}
			}
		}
	}
	
	remove_entity( iEntity );
	
	write_file( g_szFiles[ g_szLogsFile ], szText );
		
	return FMRES_IGNORED;
}

// Reset player variables
public client_connect( iPlayer ) {
	g_bDisplaySpawns[ iPlayer ] = false;
	g_bCanSee[ iPlayer ] = false;
}

public client_disconnect( iPlayer ) {
	g_bDisplaySpawns[ iPlayer ] = false;
	g_bCanSee[ iPlayer ] = false;
}

public fw_CommandPresentsMenu( iPlayer ) {
	// Allow access only for server owners
	if( !( get_user_flags( iPlayer ) & ADMIN_RCON ) ) {
		ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^3You do not have permission to access to this option!" );
		return;
	}
	
	// Spavn all temporary entities for spawn location
	for( new iSpawn = 0; iSpawn <= g_iSpawns; iSpawn ++ )
		CreateSpawnLocation( g_fSpawns[ iSpawn ] );
	
	// Create menu with options
	CreateMenu( iPlayer );

	// Set player variable so he can see all temporary entities for spawn location
	g_bDisplaySpawns[ iPlayer ] = true;
}

public fw_CommandTest( iPlayer ) {
	// Check if player is alive, if he is not then skip
	if( !is_user_alive( iPlayer ) ) {
		ColorChat( iPlayer, RED, "You must be alive!" );
		return;
	}
	
	// Allow access only for server owners
	if( !( get_user_flags( iPlayer ) & ADMIN_RCON ) ) {
		ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^3You do not have permission to access to this option!" );
		return;
	}
	
	// Get player origin (positon)
	new Float: fOrigin[ 3 ];
	entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
	
	// Move position away from the player
	fOrigin[ 0 ] += 30;
	fOrigin[ 1 ] += 30;
	
	// Spawn present on postion
	// Create entity
	new iEntity = create_entity( "info_target" );
			
	// Check if entity is valid, if it is not then skip
	if( !is_valid_ent( iEntity ) )
		return;
				
	// Pickup random model
	new iModel = random_num( 0, sizeof( g_szModels ) - 1 );
	
	// Set class name and model to entity
	entity_set_string( iEntity, EV_SZ_classname, "ChristmasPresent" );
	entity_set_model( iEntity, g_szModels[ iModel ] );
			
	// Set entity as solid and movetype to none, and set model index
	entity_set_int( iEntity, EV_INT_solid, SOLID_BBOX );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_NONE );
	entity_set_int( iEntity, EV_INT_modelindex, g_iModelIndex[ iModel ] );
	entity_set_int( iEntity, EV_INT_body, random_num( 1, 2 ) );
			
	// Set entity origin (position) and size
	entity_set_origin( iEntity, fOrigin );
	entity_set_vector( iEntity, EV_VEC_maxs, Float: { 10.0, 10.0, 25.0 } );
	entity_set_vector( iEntity, EV_VEC_mins, Float: { -10.0, -10.0, 0.0 } );
	entity_set_vector( iEntity, EV_VEC_size, Float: { 10.0, 10.0, 25.0 } );
			
	// Spawn entity
	drop_to_floor( iEntity );
	
	// Log creatingon
	new szDate[ 32 ], szName[ 32 ], szText[ 128 ], szMapName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
	get_mapname( szMapName, charsmax( szMapName ) );
	get_time( "%d.%m.%Y %H:%M:%S", szDate, charsmax( szDate ) );
	formatex( szText, charsmax( szText ), "[%s] Admin %s spawned box on %s (X: %.2f - Y: %.2f - Z: %.2f)", szDate, szName, szMapName, fOrigin[ 0 ], fOrigin[ 1 ], fOrigin[ 2 ] );
	write_file( g_szFiles[ g_szLogsFile ], szText );
}

public CreateMenu( iPlayer ) {
	// Create menu with options
	new iMenu = menu_create( "\d[\rByM\d] \yChristmas Presents Options\d:", "MainMenu_Handle" );
	
	// Add options to menu
	new szText[ 64 ];
	formatex( szText, charsmax( szText ), "Create spawn location \d[\r%d \yleft free\d]", MAX_SPAWNS - g_iSpawns );
	menu_additem( iMenu, szText );
	menu_additem( iMenu, "Delete spawn location" );
	menu_additem( iMenu, "Save & Exit" );
	
	// Display menu
	menu_display( iPlayer, iMenu );
}

public MainMenu_Handle( iPlayer, iMenu, iItem ) {
	// Close menu if 0 is pressed
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	// Do actions when option is selected
	switch( iItem ) {
		case 0: CreateSpawn( iPlayer );
		case 1: DeleteSpawn( iPlayer );
		case 2: {
			// Delete all temporary entities for spawn location
			new iEntity = find_ent_by_class( -1, "PresentSpawn" );
			while( iEntity >  0)  {
				remove_entity( iEntity );
				iEntity = find_ent_by_class( iEntity, "PresentSpawn" );	
			}
			
			// Reset player variable so he can not see temporary entities for spawn location
			g_bDisplaySpawns[ iPlayer ] = false;
			return PLUGIN_CONTINUE;
		}
	}
	
	// Display menu again
	CreateMenu( iPlayer );
	
	return PLUGIN_CONTINUE;
}

stock CreateSpawn( iPlayer ) {
	// Intialise temporary local variables
	new Float: fStart[ 3 ], Float: fViewOfs[ 3 ], Float: fDest[ 3 ], Float: fDstOrigin[ 3 ], Float: fNormal[ 3 ];
	
	// Get player origin (postion) and view offset
	entity_get_vector( iPlayer, EV_VEC_origin, fStart );
	entity_get_vector( iPlayer, EV_VEC_view_ofs, fViewOfs );
	
	// Add player origin (postion) vector to view offset vector
	xs_vec_add( fStart, fViewOfs, fStart );
	
	// Get destination (end) vector
	entity_get_vector( iPlayer, EV_VEC_v_angle, fDest );
	engfunc( EngFunc_MakeVectors, fDest );
	global_get( glb_v_forward, fDest );
	
	// Mutiply destination vector with scalar 999 and add it start vector to destination vector
	xs_vec_mul_scalar( fDest, 999.0, fDest );
	xs_vec_add( fStart, fDest, fDest );
	
	// Traceline
	engfunc( EngFunc_TraceLine, fStart, fDest, 0, iPlayer, 0 );
	get_tr2( 0, TR_vecEndPos, fDstOrigin );
	
	// Check if player is looking at the sky, if he does then skip
	if( engfunc( EngFunc_PointContents, fDstOrigin ) == CONTENTS_SKY )
		return;
	
	// Normalise vectors
	get_tr2( 0, TR_vecPlaneNormal, fNormal );
	xs_vec_mul_scalar( fNormal, 50.0, fNormal );
	xs_vec_add( fDstOrigin, fNormal, fDstOrigin );
	
	// Check if there is maximum spawns, if there is print message to player
	if( g_iSpawns ++ > MAX_SPAWNS ) {
		g_iSpawns --;
		ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^3There is maximum spawns on the map! (%d/%d)", g_iSpawns, MAX_SPAWNS );
		return;
	}
	
	// Add current present spawn to global array
	g_fSpawns[ g_iSpawns ] = fDstOrigin;
	
	// Create entity for present spawn
	if( !CreateSpawnLocation( fDstOrigin ) ) {
		ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^3Something gone wrong!" );
		return;
	}
	
	// Add present spawn to the file
	new szData[ 256 ], szMapName[ 32 ];
	get_mapname( szMapName, charsmax( szMapName ) );
	formatex( szData, charsmax( szData ), "^"%s^" ^"%f^" ^"%f^" ^"%f^"", szMapName, fDstOrigin[ 0 ], fDstOrigin[ 1 ], fDstOrigin[ 2 ] );
	write_file( g_szFiles[ g_szLocationsFile ], szData );
	
	// Print success message
	ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^1Spawn has be created successfuly %d/%d", g_iSpawns, MAX_SPAWNS );
}

stock CreateSpawnLocation( Float: fOrigin[ 3 ] ) {
	// Create entity
	new iEntity = create_entity( "info_target" );
			
	// Check if entity is valid, if it is not then skip
	if( !is_valid_ent( iEntity ) )
		return 0;
	
	// Pickup random model		
	new iModel = random_num( 0, sizeof( g_szModels ) - 1 );
	
	// Set class name and model to entity
	entity_set_string( iEntity, EV_SZ_classname, "PresentSpawn" );
	entity_set_model( iEntity, g_szModels[ iModel ] );
			
	// Set entity as solid and movetype to none, and set model index
	entity_set_int( iEntity, EV_INT_solid, SOLID_BBOX );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_NONE );
	entity_set_int( iEntity, EV_INT_modelindex, g_iModelIndex[ iModel ] );
			
	// Set entity origin (position) and size
	entity_set_origin( iEntity, fOrigin );
	entity_set_vector( iEntity, EV_VEC_maxs, Float: { 10.0, 10.0, 25.0 } );
	entity_set_vector( iEntity, EV_VEC_mins, Float: { -10.0, -10.0, 0.0 } );
	entity_set_vector( iEntity, EV_VEC_size, Float: { 10.0, 10.0, 25.0 } );

	// Spawn entity
	drop_to_floor( iEntity );
	
	return 1;
}

stock CreatePresent( iPresent ) {
	// Create entity
	new iEntity = create_entity( "info_target" );
			
	// Check if entity is valid, if it is not then skip
	if( !is_valid_ent( iEntity ) )
		return 0;
				
	// Pickup random model
	new iModel = random_num( 0, sizeof( g_szModels ) - 1 );
	
	// Set class name and model to entity
	entity_set_string( iEntity, EV_SZ_classname, "ChristmasPresent" );
	entity_set_model( iEntity, g_szModels[ iModel ] );
			
	// Set entity as solid and movetype to none, and set model index
	entity_set_int( iEntity, EV_INT_solid, SOLID_BBOX );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_NONE );
	entity_set_int( iEntity, EV_INT_modelindex, g_iModelIndex[ iModel ] );
	entity_set_int( iEntity, EV_INT_body, random_num( 1, 2 ) );
			
	// Set entity origin (position) and size
	new Float: fOrigin[ 3 ];
	fOrigin = g_fSpawns[ iPresent ];
	
	entity_set_origin( iEntity, fOrigin );
	entity_set_vector( iEntity, EV_VEC_maxs, Float: { 10.0, 10.0, 25.0 } );
	entity_set_vector( iEntity, EV_VEC_mins, Float: { -10.0, -10.0, 0.0 } );
	entity_set_vector( iEntity, EV_VEC_size, Float: { 10.0, 10.0, 25.0 } );
			
	// Spawn entity
	drop_to_floor( iEntity );
	
	// Create sprite entity
	new iSpriteEntity = create_entity( "info_target" );

	// Check if it is valid
	if( !is_valid_ent( iSpriteEntity ) )
		return 0;

	// Move above present
	fOrigin[ 2 ] += 15.0;

	// Set entity data
	entity_set_string( iSpriteEntity, EV_SZ_classname, "PresentSprite" );
	entity_set_vector( iSpriteEntity, EV_VEC_origin, fOrigin );
	entity_set_int( iEntity, EV_INT_iuser1, iSpriteEntity );
	entity_set_int( iSpriteEntity, EV_INT_iuser1, iEntity );
	entity_set_model( iSpriteEntity, g_szSprite );
	set_rendering( iSpriteEntity, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 240 );
	entity_set_int( iSpriteEntity, EV_INT_solid, SOLID_NOT );
	entity_set_int( iSpriteEntity, EV_INT_movetype, MOVETYPE_NONE );
	
	return 1;
}

stock DeleteSpawn( iPlayer ) {
	// Check if player is connected
	if( !is_user_connected( iPlayer ) )
		return;
		
	// Check if player is alive
	if( !is_user_alive( iPlayer ) ) {
		ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^1You must be alive!" );
		return;
	}
	
	// Get entity which player is looking at
	new iEntity, iBody;
	get_user_aiming( iPlayer, iEntity, iBody, 600 );
	
	// Check if entity is valid
	if( !is_valid_ent( iEntity ) ) {
		ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^1You aren't looking at present spawn!" );
		return;
	}
	
	// Get entity class name
	new szClassName[ 32 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	// Check if player is looking at the present spawn location
	if( !equal( szClassName, "PresentSpawn" ) ) {
		ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^1You must look directly at spawn location!" );
		return;
	}
	
	// Remove entity
	RemoveSpawn( iEntity );
	ColorChat( iPlayer, GREEN, "[ByM Christmas Presents] ^1Succesfuly deleted spawn. (%d/%d)", g_iSpawns, MAX_SPAWNS );
}

stock RemoveSpawn( iEntity ) {
	// Get spawn position
	new Float: fOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
	
	// Open the file with spawns
	new iFile = fopen( g_szFiles[ g_szLocationsFile ], "rt" );
	
	// Check if file is not opened
	if( !iFile ) set_fail_state( "Change permissions of file Locations.ini to 777!" );
	
	// Initialise local temporary variables
	new szData[ 256 ], szDataPieces[ 4 ][ 32 ], szMapName[ 32 ], iLine, bool: bDeleted = false;
	
	// Get map name
	get_mapname( szMapName, charsmax( szMapName ) );
	
	while( iFile && !feof( iFile ) ) {
		// Get line from file
		fgets( iFile, szData, charsmax( szData ) );
		
		// Count the lines
		iLine ++;
		
		// Skip Comments
		if( szData[ 0 ] == EOS || ( szData[ 0 ] == ';' ) || ( szData[ 0 ] == '/' && szData[ 1 ] == '/' ) )
			continue;
		
		// Parse variables (if there is less than 4 then skip)
		if( parse( szData, szDataPieces[ 0 ], charsmax( szDataPieces[ ] ), szDataPieces[ 1 ], charsmax( szDataPieces[ ] ), szDataPieces[ 2 ], charsmax( szDataPieces[ ] ),  szDataPieces[ 3 ], charsmax( szDataPieces[ ] ) ) < 4 )
			continue;
			
		// Skip other maps
		if( !equal( szDataPieces[ 0 ], szMapName ) )
			continue;
			
		// Delete line if location of spawn matches with one from the file
		if( ( str_to_float( szDataPieces[ 1 ] ) == fOrigin[ 0 ] ) && ( str_to_float( szDataPieces[ 2 ] ) == fOrigin[ 1 ] ) ) {
			write_file( g_szFiles[ g_szLocationsFile ], "", iLine - 1 );
			bDeleted = true;
			break;
		}
	}
	
	// Delete spawn from global list
	if( bDeleted ) {
		new iSpawn = -1;
		
		// Loopt through spawns to get spawn id
		for( new iSpawns = 0; iSpawns <= MAX_SPAWNS; iSpawns ++ ) {
			if( ( g_fSpawns[ iSpawns ][ 0 ] == fOrigin[ 0 ] ) && ( g_fSpawns[ iSpawns ][ 1 ] == fOrigin[ 1 ] ) ) {
				iSpawn = iSpawns;
				break;
			}
		}
		
		// If spawn id is valid then remove it from list
		if( iSpawn != -1 ) {
			// Delete origin (postion) of spawn
			g_fSpawns[ iSpawn ][ 0 ] = 0.0;
			g_fSpawns[ iSpawn ][ 1 ] = 0.0;
			g_fSpawns[ iSpawn ][ 2 ] = 0.0;
			
			// Decrease spawns
			g_iSpawns --;
		}
	}
	
	// Close file if it exists
	if( iFile ) 
		fclose( iFile );
		
	// Remove entity
	remove_entity( iEntity );
}

stock GetClassByFlag( const szFlag[ ] ) {
	new szClassFlag[ 3 ];
	
	for( new iIterator = 1; iIterator < cod_classes_number( ); iIterator ++ ) {
		cod_get_class_flag( iIterator, szClassFlag, charsmax( szClassFlag ) );
		
		if( contain( szClassFlag, "#" ) != -1 || containi( szClassFlag, "$" ) != -1 )
			continue;
			
		if( equal( szFlag, szClassFlag ) )
			return iIterator;
	}
	
	return 0;
}

stock Float: GetNextTime( ) {
	new Float: fTime;
	
	switch( GetOnlinePlayers( ) ) {
		case 0: fTime = 60.0;
		case 1 .. 9:fTime = 120.0;
		case 10 .. 19: fTime = 180.0;
		case 20 .. 32: fTime = 240.0;
	}
	
	return fTime;
}

stock GetOnlinePlayers( ) {
	new iPlayers = 0;
	
	for( new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer ++ ) {
		if( is_user_connected( iPlayer ) )
			iPlayers ++;
	}
	
	return iPlayers;
}

// Remove all entites on map change
public plugin_end( ) {
	new iEntity = find_ent_by_class( -1, "PresentSpawn" );
	while( iEntity >  0)  {
		remove_entity( iEntity );
		iEntity = find_ent_by_class( iEntity, "PresentSpawn" );	
	}
	
	new iEntityPresent = find_ent_by_class( -1, "ChristmasPresent" );
	while( iEntityPresent >  0)  {
		remove_entity( iEntityPresent );
		iEntityPresent = find_ent_by_class( iEntityPresent, "ChristmasPresent" );	
	}
	
	new iEntitySprite = find_ent_by_class( -1, "PresentSprite" );
	while( iEntitySprite >  0)  {
		remove_entity( iEntitySprite );
		iEntitySprite = find_ent_by_class( iEntitySprite, "PresentSprite" );	
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
