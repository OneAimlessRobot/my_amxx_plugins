#include < amxmodx >
#include < amxmisc >
#include < unixtime >
#include < bym_cod_2016 >

enum _:StructTries {
	Trie: g_tFlagA,
	Trie: g_tFlagB,
	Trie: g_tFlagC,
	Trie: g_tFlagD,
	Trie: g_tFlagE,
	Trie: g_tFlagF,
	Trie: g_tFlagG,
	Trie: g_tFlagH,
	Trie: g_tFlagI,
	Trie: g_tFlagJ,
	Trie: g_tFlagK,
	Trie: g_tFlagL,
	Trie: g_tFlagM,
	Trie: g_tFlagN,
	Trie: g_tFlagO,
	Trie: g_tFlagP,
	Trie: g_tFlagQ,
	Trie: g_tFlagR,
	Trie: g_tFlagS,
	Trie: g_tFlagT,
	Trie: g_tFlagU,
	Trie: g_tFlagV,
	Trie: g_tFlagW,
	Trie: g_tFlagX,
	Trie: g_tFlagY,
	Trie: g_tFlagZ,
	Trie: g_tFlag1,
	Trie: g_tFlag2,
	Trie: g_tFlag3,
	Trie: g_tFlag4,
	Trie: g_tFlag5,
	Trie: g_tFlag6,
	Trie: g_tFlag7,
	Trie: g_tFlag8,
	Trie: g_tFlag9,
	Trie: g_tFlag0,
	Trie: g_tFlagEqual,
	Trie: g_tFlagParenthesis1,
	Trie: g_tFlagParenthesis2,
	Trie: g_tFlagParenthesis_square1,
	Trie: g_tFlagParenthesis_square2,
	Trie: g_tFlagAnd
}

new const g_szFlags[ ][ ] = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"=",
	"(",
	")",
	"[",
	"]",
	"&"
};

new Trie: g_tTries[ StructTries ];
new const g_szFolder[ ] = "addons/amxmodx/configs/ByM_Cod/Flags/";
new const g_szFile[ ] = "addons/amxmodx/configs/ByM_Cod/Flags/Flag_%s.txt";
new g_szSteamID[ 33 ][ 32 ];
new g_szNick[ 33 ][ 32 ];

public plugin_init( ) {
	register_plugin( "[ByM] Award System", "2.1", "Milutinke (ByM)" );
	register_concmd( "reload_classes", "ReloadFlags" ); 
	
	for( new i = 0; i < StructTries; i ++ )
		g_tTries[ i ] = TrieCreate( );
	
	for( new i = 0; i < sizeof( g_szFlags ); i ++ ) 
		LoadFlag( i );
}

public ReloadFlags( ) {
	for( new i = 0; i < StructTries; i ++ )
		TrieDestroy( g_tTries[ i ] );
		
	for( new i = 0; i < StructTries; i ++ )
		g_tTries[ i ] = TrieCreate( );
	
	for( new i = 0; i < sizeof( g_szFlags ); i ++ ) 
		LoadFlag( i );
		
	for( new iPlayer = 1; iPlayer <= get_maxplayers( ); iPlayer ++ ) {
		bym_delete_flags( iPlayer );
		
		for( new i = 0; i < sizeof( g_szFlags ); i++ )
			CheckFlag( iPlayer, i );
	}
}

LoadFlag( iFlag ) {
	if( !dir_exists( g_szFolder ) )
		mkdir( g_szFolder );
		
	new szFile[ 256 ];
	formatex( szFile, charsmax( szFile ), g_szFile, g_szFlags[ iFlag ] );
	
	if( equal( szFile, "addons/amxmodx/configs/ByM_Cod/Flags/Flag_.txt" ) )
		return;
	
	if( !file_exists( szFile ) )
		write_file( szFile, "; DO NOT TOUCH IF YOU DO NOT KNOW WHAT YOU ARE DOING!^n" );
	
	new iFile = fopen( szFile, "rt" );
	
	new szData[ 512 ];
	new szDataPieces[ 2 ][ 64 ];
	new iLine = 0;
	
	while( iFile && !feof( iFile ) ) {
		fgets( iFile, szData, charsmax( szData ) );
		
		iLine++;
		
		if( ( szData[ 0 ] == EOS ) || ( szData[ 0 ] == ';' ) || ( szData[ 0 ] == '/' && szData[ 1 ] == '/' ) )
			continue;
			
		if( parse( szData, szDataPieces[ 0 ], charsmax( szDataPieces[ ] ), szDataPieces[ 1 ], charsmax( szDataPieces[ ] ) ) < 2 )
			continue;
			
		if( CheckExpration( szDataPieces[ 1 ] ) == true ) {
			write_file( szFile, "// - Expired -", iLine - 1 );
			continue;
		}
		
		TrieSetString( g_tTries[ iFlag ], szDataPieces[ 0 ], szDataPieces[ 1 ] );
	}
	
	fclose( iFile );
}

public client_putinserver( iPlayer ) {
	if( is_user_bot( iPlayer ) )
		return;
		
	get_user_authid( iPlayer, g_szSteamID[ iPlayer ], charsmax( g_szSteamID[ ] ) );
	get_user_name( iPlayer, g_szNick[ iPlayer ], charsmax( g_szNick[ ] ) );
		
	for( new i = 0; i < sizeof( g_szFlags ); i++ )
		CheckFlag( iPlayer, i );
}

public CheckFlag( iPlayer, iFlag ) {
	if( TrieKeyExists( g_tTries[ iFlag ], g_szSteamID[ iPlayer ] ) ) {
		bym_set_flag( iPlayer, iFlag + 1 );
	}
}

public plugin_natives( ) {
	register_native( "bym_give_flag", "NativeGiveFlag", 1 );
	register_native( "bym_take_flag", "NativeTakeFlag", 1 );
	register_native( "bym_get_flag_expiration", "NativeGetExpiration", 1 );
}

public NativeGiveFlag( iPlayer, iFlag, iDays ) {
	if( bym_get_flag( iPlayer, iFlag ) )
		return 0;
	
	new iExpiration = get_systime( ) + ( ( ( 24 * 60 ) * 60 ) * iDays );
		
	new iDay, iMonth, iYear, iHour, iMinute, iSecond;
	new szTime[ 64 ];
	
	UnixToTime( iExpiration, iYear, iMonth, iDay, iHour, iMinute, iSecond );
	formatex( szTime, charsmax( szTime ), "%02d/%02d/%d", iDay, iMonth, iYear );
	
	new szFile[ 256 ], szFlag[ 6 ], szText[ 128 ];
	formatex( szText, charsmax( szText ), "^n^"%s^" ^"%s^" ;%s", g_szSteamID[ iPlayer ], szTime, g_szNick[ iPlayer ] );
	
	bym_get_flag_char( iFlag, szFlag, charsmax( szFlag ) );
	bym_set_flag( iPlayer, iFlag )
	
	formatex( szFile, charsmax( szFile ), g_szFile, szFlag ); 
	write_file( szFile, szText );
	
	return 1;
}

public NativeTakeFlag( iPlayer, iFlag ) {
	if( !bym_get_flag( iPlayer, iFlag ) )
		return 0;
	
	if( !dir_exists( g_szFolder ) )
		mkdir( g_szFolder );
		
	new szFile[ 256 ];
	formatex( szFile, charsmax( szFile ), g_szFile, g_szFlags[ iFlag ] );
	
	if( equal( szFile, "addons/amxmodx/configs/ByM_Cod/Flags/Flag_.txt" ) )
		return 0;
	
	new iFile = fopen( szFile, "rt" );
	
	new szData[ 512 ];
	new szDataPieces[ 2 ][ 64 ];
	new iLine = 0;
	
	while( iFile && !feof( iFile ) ) {
		fgets( iFile, szData, charsmax( szData ) );
		
		iLine ++;
		
		if( ( szData[ 0 ] == EOS ) || ( szData[ 0 ] == ';' ) || ( szData[ 0 ] == '/' && szData[ 1 ] == '/' ) )
			continue;
			
		if( parse( szData, szDataPieces[ 0 ], charsmax( szDataPieces[ ] ), szDataPieces[ 1 ], charsmax( szDataPieces[ ] ) ) < 2 )
			continue;
			
		if( equal( szDataPieces[ 0 ], g_szSteamID[ iPlayer ] ) ) {
			write_file( szFile, "// - Deleted -", iLine - 1 );
			fclose( iFile );
			ReloadFlags( );
			return 1;
		}
	}
	
	fclose( iFile );
	return 0;
}

public NativeGetExpiration( iPlayer, iFlag ) {
	if( bym_get_flag( iPlayer, iFlag ) ) {
		iFlag --; // Beause there is null flag we have to decrease flag id to fit the trie, damn that took me ages to figure it out
		
		if( TrieKeyExists( g_tTries[ iFlag ], g_szSteamID[ iPlayer ] ) == true ) {
			new szExpiration[ 64 ];
			TrieGetString( g_tTries[ iFlag ], g_szSteamID[ iPlayer ], szExpiration, charsmax( szExpiration ) );
			return GetExpiration( szExpiration );
		}
		
		return 0;
	}
	
	return 0;
}

stock bool: CheckExpration( const szExpiration[ ] ) {
	if( get_systime( ) >= GetExpiration( szExpiration ) )
		return true;
		
	return false;
}

stock GetExpiration( const szExpiration[ ] ) {
	new szExp[ 32 ];
	copy( szExp, charsmax( szExp ), szExpiration );
	
	replace_all( szExp, charsmax( szExp ), "/", " " );
	replace_all( szExp, charsmax( szExp ), ".", " " );
	
	new szTime[ 3 ][ 5 ];
	new iExpiration;
	
	if( parse( szExp, szTime[ 0 ], charsmax( szTime[ ] ), szTime[ 1 ], charsmax( szTime[ ] ), szTime[ 2 ], charsmax( szTime[ ] ) ) < 3 )
		return true;
	
	new iYear = str_to_num( szTime[ 2 ] );
	new iMonth  = str_to_num( szTime[ 1 ] );
	new iDay = str_to_num( szTime[ 0 ] );
	
	new iHour, iMinute, iSecond = 0;
	iExpiration = TimeToUnix( iYear, iMonth, iDay, iHour, iMinute, iSecond );
	
	return iExpiration;
}

public plugin_end( ) {
	for( new i = 0; i < StructTries; i ++ )
		TrieDestroy( g_tTries[ i ] );
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
