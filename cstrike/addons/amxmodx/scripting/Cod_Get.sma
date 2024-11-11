#include < amxmodx >
#include < bym_cod_2016 >
#include < nvault >

new const szNvaultName[ ] = "ByM_Get";
new g_iMessageChat;
new g_iMaxPlayers;

new g_szSteamID[ 33 ][ 32 ];
new g_iPlayerTime[ 33 ];
new bool: g_bPlayerLoaded[ 33 ];

public plugin_init( ) {
	register_plugin( "[ByM] Get", "1,0", "Unknown & Milutinke (ByM)" );
	
	g_iMessageChat = get_user_msgid( "SayText" );
	g_iMaxPlayers = get_maxplayers( );
	
	register_clcmd( "say /get", "fw_CmdGet" );
	register_clcmd( "say_team /get", "fw_CmdGet" );
	
	register_dictionary( "Cod_Get.txt" );
}

public fw_CmdGet( iPlayer ) { 
	new iVault = nvault_open( szNvaultName ); 
	
	if( iVault == INVALID_HANDLE ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_FARAL_NVAULT_ERROR" ) 
		return; 
	} 
		
	new szTextTime[ 64 ], szTextLevels[ 10 ]; 
	new iLevels = 50, iMinutes = 1440;
	
	formatex( szTextLevels, charsmax( szTextLevels ), "%L",  iPlayer, "ML_LEVELS" ); 
	BuildTime( iPlayer, iMinutes, szTextTime, charsmax( szTextTime ) ); 
	
	if( g_bPlayerLoaded[ iPlayer ] ) { 
		if( cod_get_class( iPlayer ) ) {
			if( cod_get_level( iPlayer ) < 250 ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOUR_JUST_RECIEVED", iLevels, szTextLevels, szTextTime );
				
				cod_set_xp( iPlayer, cod_calculate_level( cod_get_level( iPlayer ) + iLevels ) );
				g_bPlayerLoaded[ iPlayer ] = false;
				nvault_touch( iVault, g_szSteamID[ iPlayer ], g_iPlayerTime[ iPlayer ] = get_systime( ) ); 
				return; 
			}
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOUR_LEVEL_IS_TOO_HIGH" );
		}
		else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_DO_NOT_HAVE_CLASS" );
	}
	
	new iPlayerTime = get_systime( ) - g_iPlayerTime[ iPlayer ]; 
	new iMinutesDifference = ( iPlayerTime < ( iMinutes * 60 ) ) ? iMinutes - ( iPlayerTime / 60 ) : iMinutes; 
	BuildTime( iPlayer, iMinutesDifference, szTextTime, charsmax( szTextTime ) ); 
	
	if( iPlayerTime >= ( iMinutes * 60 ) ) { 
		if( cod_get_class( iPlayer ) ) {
			if( cod_get_level( iPlayer ) < 250 ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOUR_RECIEVED_AGAIN", iLevels, szTextLevels, szTextTime );
				
				cod_set_xp( iPlayer, cod_calculate_level( cod_get_level( iPlayer ) + iLevels ) );
				g_bPlayerLoaded[ iPlayer ] = false;
				nvault_touch( iVault, g_szSteamID[ iPlayer ], g_iPlayerTime[ iPlayer ] = get_systime( ) ); 
				return; 
			}
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOUR_LEVEL_IS_TOO_HIGH" );
		}
		else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_DO_NOT_HAVE_CLASS" );
	}
	else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_TRY_AGAIN", szTextTime, iLevels, szTextLevels );
	
	nvault_close( iVault ); 
} 

public client_authorized( iPlayer ) {
	new iNvault, szData[ 32 ]; 
	get_user_authid( iPlayer, g_szSteamID[ iPlayer ], charsmax( g_szSteamID[ ] ) );
	
	g_iPlayerTime[ iPlayer ] = get_systime( ); 
	g_bPlayerLoaded[ iPlayer ] = false;
	formatex( szData, charsmax( szData ), "%d", g_iPlayerTime[ iPlayer ] ); 
	
	if( ( iNvault = nvault_open( szNvaultName ) ) == INVALID_HANDLE ) 
		return; 
	
	if( !nvault_lookup( iNvault, g_szSteamID[ iPlayer ], szData, charsmax( szData ), g_iPlayerTime[ iPlayer ] ) ) { 
		nvault_set( iNvault, g_szSteamID[ iPlayer ], szData ); 
		g_bPlayerLoaded[ iPlayer ] = true; 
	}
	
	nvault_close( iNvault ); 
}

stock PrintToChat( iPlayer, const szInput[ ], any:... ) {
	static szMessage[ 191 ];
	vformat( szMessage, charsmax( szMessage ), szInput, 3 );
	replace_all( szMessage, charsmax( szMessage ), "!g", "^4" );
	replace_all( szMessage, charsmax( szMessage ), "!t", "^3" );
	replace_all( szMessage, charsmax( szMessage ), "!n", "^1" );
     
	if( !iPlayer ) {
		for( new iTarget = 1; iTarget <= g_iMaxPlayers; iTarget ++ ) {
			if( !is_user_connected( iTarget ) || is_user_bot( iTarget ) )
				continue;
		
			message_begin( MSG_ONE_UNRELIABLE, g_iMessageChat, _, iTarget );
			write_byte( iTarget );
			write_string( szMessage );
			message_end( );
		}
	} else {
		if( !is_user_connected( iPlayer ) || is_user_bot( iPlayer ) )
			return;
		
		message_begin( MSG_ONE_UNRELIABLE, g_iMessageChat, _, iPlayer );
		write_byte( iPlayer );
		write_string( szMessage );
		message_end( );
	}
}

stock BuildTime( iPlayer, iMinutes, szData[ ], iLen ) {
	new szText[ 128 ];
	
	if( iMinutes == 1 )
		formatex( szText, charsmax( szText ), "1 %L", iPlayer, "ML_MINUTE" );
	else if( iMinutes != 1 && ( iMinutes < 60 ) )
		formatex( szText, charsmax( szText ), "%d %L", iMinutes, iPlayer, "ML_MINUTES" );
	else if( iMinutes == 60 )
		formatex( szText, charsmax( szText ), "1 %L", iPlayer, "ML_HOUR" );
	else {
		new iTime = iMinutes / 60;
		if( ( iTime * 60 ) == iMinutes )
			formatex( szText, charsmax( szText ), "%d %L", iTime, iPlayer, iTime == 1 ? "ML_HOUR" : "ML_HOURS" );
		else {
			new iDifference = iMinutes - iTime * 60;
			formatex( szText, charsmax( szText ), "%d %L %L %d %L", iTime, iPlayer, "ML_HOURS", iPlayer, "ML_AND", iDifference, iPlayer, "ML_MINUTES" );
		}
	}
	
	copy( szData, iLen, szText );
}
