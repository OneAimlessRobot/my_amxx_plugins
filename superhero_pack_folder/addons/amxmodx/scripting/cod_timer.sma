#include < amxmodx >
#include < amxmisc >
#include < bym_cod_2016 >
#include < colorchat >
#include < unixtime >
#include < engine >
#include < sqlx >

#define IsUserAuthorized(%1) ( g_PlayerInfo[ %1 ][ g_iConnected ] & FULL_STATUS == FULL_STATUS )

#define TASK_REWARD		9747
#define TIMER_LINK		"http://example.com" // It is important not to add slash (/) at the end

enum ( <<= 1 ) {
	CONNECTED = 1,
	AUTHORIZED
};

const FULL_STATUS = CONNECTED | AUTHORIZED;
new Handle: g_hSqlConnection;

enum _:StructPlayerInfo {
	g_szSteamId[ 32 ],
	g_szNick[ 32 ],
	g_szIp[ 20 ],
	
	g_iConnected,
	g_iTime,
	g_iId
}

new g_PlayerInfo[ 33 ][ StructPlayerInfo ];

// Class flags
new const g_szChars[ ][ ] = {
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1"
}

new bool: g_bDone = false;

public plugin_init( ) {
	register_plugin( "Cod: Timer", "1.0", "Milutinke (ByM)" );
	
	register_clcmd( "say /toptime", "TopTime" );
	register_clcmd( "say_team /toptime", "TopTime" );
	register_clcmd( "say /online", "MyTime" );
	register_clcmd( "say_team /online", "MyTime" );
	register_clcmd( "say /mytime", "MyTime" );
	register_clcmd( "say_team /mytime", "MyTime" );
	register_clcmd( "say /time", "MyTime" );
	register_clcmd( "say_team /time", "MyTime" );
	
	new szFile[ 256 ];
	get_localinfo( "amxx_configsdir", szFile, charsmax( szFile ) );
	add( szFile, charsmax( szFile ), "/ByM_Cod/Timer.cfg" );
	
	if( !file_exists( szFile ) )
		write_file( szFile, "; Here you can configure ByM Timer^nSQL_HOST = ^nSQL_USER = ^nSQL_PASS = ^nSQL_DB = " );
	
	new iFile = fopen( szFile, "rt" );
	
	if( !iFile )
		set_fail_state( "Failed to open config file." );
	
	new iPos, szHost[ 64 ], szUser[ 64 ], szPass[ 64 ], szDb[ 64 ];
	while( iFile && !feof( iFile ) ) {
		fgets( iFile, szFile, 255 );
		trim( szFile );
		
		if( !szFile[ 0 ] || szFile[ 0 ] == ';' )
			continue;
		
		if( ( iPos = contain( szFile, "=" ) ) < 0 )
			continue;
		
		else if( equal( szFile, "SQL_HOST", 7 ) )
			copy( szHost, charsmax( szHost ), szFile[ iPos + 2 ] );
		else if( equal( szFile, "SQL_USER", 7 ) )
			copy( szUser, charsmax( szUser ), szFile[ iPos + 2 ] );
		else if( equal( szFile, "SQL_PASS", 7 ) )
			copy( szPass, charsmax( szPass ), szFile[ iPos + 2 ] );
		else if( equal( szFile, "SQL_DB", 5 ) )
			copy( szDb, charsmax( szDb ), szFile[ iPos + 2 ] );
	}
	
	fclose( iFile );
	
	g_hSqlConnection = SQL_MakeDbTuple( szHost, szUser, szPass, szDb );
	//SQL_QueryMe( "CREATE TABLE IF NOT EXISTS `bymtimer` (`Id` INT NOT NULL AUTO_INCREMENT, `SteamID` VARCHAR(64) NOT NULL, `Nick` VARCHAR(32) NOT NULL, `PlayedTime` INT NOT NULL DEFAULT 0, `LastSeen` INT NOT NULL DEFAULT 0, PRIMARY KEY (`Id`), UNIQUE INDEX `Id_UNIQUE` (`Id` ASC), UNIQUE INDEX `SteamID_UNIQUE` (`SteamID` ASC));" );

	InitialiseRewardSystem( );
}

InitialiseRewardSystem( ) {
	new iEntity = create_entity( "info_target" );
	
	entity_set_string( iEntity, EV_SZ_classname, "RewardSystem" );
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 5.0 );
	
	register_think( "RewardSystem", "fw_EntityThinks" );
}

public fw_EntityThinks( iEntity ) {
	if( !is_valid_ent( iEntity ) || g_bDone )
		return;
		
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 30.0 );
	
	if( !CheckTime( ) )
		return;
	
	g_bDone = true;
	
	new iErrorCode;
	new szError[ 512 ];
	
	new szDate[ 32 ], szErrorForFile[ 256 ];
	get_time( "%d.%m.%y %H:%M:%S", szDate, charsmax( szDate ) );
	
	new Handle: hSqlConnection2 = SQL_Connect( g_hSqlConnection, iErrorCode, szError, charsmax( szError ) );
	if( hSqlConnection2 == Empty_Handle ) {
		formatex(  szErrorForFile, charsmax(  szErrorForFile ), "[%s] ERROR WITH TIMER REWARD SYSTEM: %s", szDate, szError ); 
		write_file( "TIMER_ERRORS.TXT", szErrorForFile  );
		set_fail_state( szError );
	}
	
	new Handle: hQuery = SQL_PrepareQuery( hSqlConnection2, "SELECT `SteamID`, `Nick`, `PlayedTime`, `LastSeen` FROM `bymtimer` ORDER BY `PlayedTime` DESC LIMIT 15;" );
   
	if( !SQL_Execute( hQuery ) ) {
		SQL_QueryError( hQuery, szError, charsmax( szError ) );
		formatex(  szErrorForFile, charsmax(  szErrorForFile ), "[%s] ERROR WITH TIMER REWARD SYSTEM: %s", szDate, szError ); 
		write_file( "TIMER_ERRORS.TXT", szErrorForFile  );
		SQL_FreeHandle( hQuery );
		SQL_FreeHandle( hSqlConnection2 );
		return;
	}
	
	new szData[ 4 ][ 64 ];
	while( SQL_MoreResults( hQuery ) ) {
		SQL_ReadResult( hQuery, 0, szData[ 0 ], charsmax( szData[ ] ) );
		SQL_ReadResult( hQuery, 1, szData[ 1 ], charsmax( szData[ ] ) );
		SQL_ReadResult( hQuery, 2, szData[ 2 ], charsmax( szData[ ] ) );
		SQL_ReadResult( hQuery, 3, szData[ 3 ], charsmax( szData[ ] ) );
		
		if( ( get_systime( ) - str_to_num( szData[ 3 ] ) ) >= ( ( ( 24 * 60 ) * 60 ) * 25 ) )
			continue;
		
		new szText[ 256 ], szDate[ 32 ];
		new iExpiration = get_systime( ) + ( ( ( 24 * 60 ) * 60 ) * 15 );
		new iDay, iMonth, iYear, iHour, iMinute, iSecond;
	
		UnixToTime( iExpiration, iYear, iMonth, iDay, iHour, iMinute, iSecond );
		formatex( szDate, charsmax( szDate ), "%02d/%02d/%d", iDay, iMonth, iYear );
	
		formatex( szText, charsmax( szText ), "^"%s^" ^"%s^" ^"%s^" ; %s", szData[ 0 ], szData[ 2 ], szDate, szData[ 1 ] );
		write_file( "PlayersToReward.txt", szText );
		
		SQL_NextRow( hQuery );
	}
   
	SQL_QueryMe( "DELETE * FROM `bymtimer`;" );
	SQL_FreeHandle( hQuery );
	SQL_FreeHandle( hSqlConnection2 );
}

public plugin_end( )
	if( g_hSqlConnection )
		SQL_FreeHandle( g_hSqlConnection );

public TopTime( iPlayer ) {
	new szLink[ 512 ];
	formatex( szLink, charsmax( szLink ), "%s/Timer/TopMotd.php", TIMER_LINK );
	show_motd( iPlayer, szLink );
}

public MyTime( iPlayer ) {
	new szLink[ 256 ];
	formatex( szLink, charsmax( szLink ), "%s/Timer/MyTimeMotd.php?Id=%d", TIMER_LINK, g_PlayerInfo[ iPlayer ][ g_iId ] );
	show_motd( iPlayer, szLink );
}
	
public client_authorized( iPlayer )
	if( ( g_PlayerInfo[ iPlayer ][ g_iConnected ] |= AUTHORIZED ) & CONNECTED )
		UserHasBeenAuthorized( iPlayer );

public client_putinserver( iPlayer ) {
	if( !is_user_bot( iPlayer ) && ( g_PlayerInfo[ iPlayer ][ g_iConnected ] |= CONNECTED ) & AUTHORIZED )
		UserHasBeenAuthorized( iPlayer );
	
	if( task_exists( iPlayer + TASK_REWARD ) )
		remove_task( iPlayer + TASK_REWARD );
		
	if( !is_user_bot( iPlayer ) )
		set_task( 15.0, "RewardPlayer", iPlayer + TASK_REWARD );
}

public client_disconnected( iPlayer ) {
	if( task_exists( iPlayer + TASK_REWARD ) )
		remove_task( iPlayer + TASK_REWARD );
		
	SQL_QueryMe( "UPDATE `bymtimer` SET `PlayedTime` = '%i' WHERE `Id` = '%i';", g_PlayerInfo[ iPlayer ][ g_iTime ] + get_user_time( iPlayer ), g_PlayerInfo[ iPlayer ][ g_iId ] );
	
	g_PlayerInfo[ iPlayer ][ g_iTime ] = 0;
	g_PlayerInfo[ iPlayer ][ g_iId ] = 0;
	g_PlayerInfo[ iPlayer ][ g_iConnected ] = 0;
}

public RewardPlayer( iPlayer ) {
	if( is_user_connected( iPlayer ) ) {
		new iHours = 0;
		
		if( CheckConditions( iPlayer, iHours ) == true ) {
			new szRandom[ 3 ];
			copy( szRandom, charsmax( szRandom ), g_szChars[ random( sizeof( g_szChars ) - 1 ) ] );

			if( !bym_get_flag( iPlayer, bym_get_flag_int( szRandom ) ) ) {
				new iClass = GetClassByFlag( szRandom );
				new szClass[ 64 ];
				cod_get_class_name( iClass, szClass, charsmax( szClass ) );

				ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
				ColorChat( iPlayer, GREEN, "You recieved class %L for spending %d Hours on server!", iPlayer, szClass, iHours );
				ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
						
				bym_give_flag( iPlayer, bym_get_flag_int( szRandom ), 15 );
			} else {
				copy( szRandom, charsmax( szRandom ), g_szChars[ random( sizeof( g_szChars ) - 1 ) ] );
				
				if( !bym_get_flag( iPlayer, bym_get_flag_int( szRandom ) ) ) {
					new iClass = GetClassByFlag( szRandom );
					new szClass[ 64 ];
					cod_get_class_name( iClass, szClass, charsmax( szClass ) );
	
					ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
					ColorChat( iPlayer, GREEN, "You recieved class %L for spending %d Hours on server!", iPlayer, szClass, iHours );
					ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
							
					bym_give_flag( iPlayer, bym_get_flag_int( szRandom ), 15 );
				}
				else {
					copy( szRandom, charsmax( szRandom ), g_szChars[ random( sizeof( g_szChars ) - 1 ) ] );
					
					if( !bym_get_flag( iPlayer, bym_get_flag_int( szRandom ) ) ) {
						new iClass = GetClassByFlag( szRandom );
						new szClass[ 64 ];
						cod_get_class_name( iClass, szClass, charsmax( szClass ) );

						ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
						ColorChat( iPlayer, GREEN, "You recieved class %L for spending %d Hours on server!", iPlayer, szClass, iHours );
						ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
						
						bym_give_flag( iPlayer, bym_get_flag_int( szRandom ), 15 );
					}
					else {
						copy( szRandom, charsmax( szRandom ), g_szChars[ random( sizeof( g_szChars ) - 1 ) ] );
						
						if( !bym_get_flag( iPlayer, bym_get_flag_int( szRandom ) ) ) {
							new iClass = GetClassByFlag( szRandom );
							new szClass[ 64 ];
							cod_get_class_name( iClass, szClass, charsmax( szClass ) );
	
							ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
							ColorChat( iPlayer, GREEN, "You recieved class %L for spending %d Hours on server!", iPlayer, szClass, iHours );
							ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
							
							bym_give_flag( iPlayer, bym_get_flag_int( szRandom ), 15 );
						}
						else {
							if( cod_is_vip( iPlayer ) ) {
								new iGold = random_num( 5000, 15000 );
								cod_set_gold( iPlayer, cod_get_gold( iPlayer ) + iGold );
								
								ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
								ColorChat( iPlayer, GREEN, "You recieved %d gold for spending %d Hours on server!", iGold, iHours );
								ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
								return;
							}
							
							cod_give_vip( iPlayer, 15 );
							cod_reload_vips( );
							
							ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
							ColorChat( iPlayer, GREEN, "You recieved vip for 15 days, for spending %d Hours on server!", iHours );
							ColorChat( iPlayer, RED, "================[Top Time Reward]================" );
						}
					}
				}
			}
		}
	}
}

public GetClassByFlag( const szFlag[ ] ) {
	new szClassFlag[ 3 ];
	new szClassName[ 64 ];
	
	for( new iIterator = 1; iIterator <= cod_classes_number( ); iIterator ++ ) {
		cod_get_class_flag( iIterator, szClassFlag, charsmax( szClassFlag ) );
		cod_get_class_name( iIterator, szClassName, charsmax( szClassName ) );
		
		if( contain( szClassFlag, "#" ) != -1 || containi( szClassFlag, "$" ) != -1 )
			continue;
			
		if( equal( szFlag, szClassFlag ) )
			return iIterator;
	}
	
	return 0;
}
		
UserHasBeenAuthorized( const iPlayer ) {
	g_PlayerInfo[ iPlayer ][ g_iTime ] = 0;
	g_PlayerInfo[ iPlayer ][ g_iId ] = 0;
	
	get_user_authid( iPlayer, g_PlayerInfo[ iPlayer ][ g_szSteamId ], charsmax( g_PlayerInfo[ ][ g_szSteamId ] ) );
	get_user_name( iPlayer, g_PlayerInfo[ iPlayer ][ g_szNick ], charsmax( g_PlayerInfo[ ][ g_szNick ] ) );
	get_user_ip( iPlayer, g_PlayerInfo[ iPlayer ][ g_szIp ], charsmax( g_PlayerInfo[ ][ g_szIp ] ), 1 );
	
	replace_all( g_PlayerInfo[ iPlayer ][ g_szNick ], charsmax( g_PlayerInfo[ ][ g_szNick ] ), "`", "" );
	replace_all( g_PlayerInfo[ iPlayer ][ g_szNick ], charsmax( g_PlayerInfo[ ][ g_szNick ] ), "^"", "" );
	replace_all( g_PlayerInfo[ iPlayer ][ g_szNick ], charsmax( g_PlayerInfo[ ][ g_szNick ] ), "'", "" );

	new szQuery[ 128 ], szPlayerId[ 1 ]; szPlayerId[ 0 ] = iPlayer;
	formatex( szQuery, charsmax( szQuery ), "SELECT `Id`, `PlayedTime` FROM `bymtimer` WHERE `SteamID` = '%s'", g_PlayerInfo[ iPlayer ][ g_szSteamId ] );
	
	SQL_ThreadQuery( g_hSqlConnection, "HandlePlayerConnect", szQuery, szPlayerId, 1 );
}

public HandlePlayerConnect( iFailState, Handle: hQuery, szError[ ], iError, szData[ ], iSize, Float: flQueueTime ) {
	if( SQL_IsFail( iFailState, iError, szError ) )
		return;
	
	new iPlayer = szData[ 0 ];
	
	if( !IsUserAuthorized( iPlayer ) )
		return;
		
	if( !SQL_NumResults( hQuery ) ) {
		new szQuery[ 256 ];
		formatex( szQuery, 255, "INSERT INTO `bymtimer` (`SteamID`, `Nick`, `PlayedTime`) VALUES (^"%s^", ^"%s^", '0')", g_PlayerInfo[ iPlayer ][ g_szSteamId ],  g_PlayerInfo[ iPlayer ][ g_szNick ] );
		
		SQL_ThreadQuery( g_hSqlConnection, "HandlePlayerInsert", szQuery, szData, 1 );
		
		return;
	}
	
	g_PlayerInfo[ iPlayer ][ g_iId ] = SQL_ReadResult( hQuery, 0 );
	g_PlayerInfo[ iPlayer ][ g_iTime ] = SQL_ReadResult( hQuery, 1 );
	
	replace_all( g_PlayerInfo[ iPlayer ][ g_szNick ], charsmax( g_PlayerInfo[ ][ g_szNick ] ), "`", "" );
	replace_all( g_PlayerInfo[ iPlayer ][ g_szNick ], charsmax( g_PlayerInfo[ ][ g_szNick ] ), "^"", "" );
	replace_all( g_PlayerInfo[ iPlayer ][ g_szNick ], charsmax( g_PlayerInfo[ ][ g_szNick ] ), "'", "" );
	
	SQL_QueryMe( "UPDATE `bymtimer` SET `LastSeen` = '%i', `Nick` = '%s' WHERE `Id` = '%i';", get_systime( ), g_PlayerInfo[ iPlayer ][ g_szNick ], g_PlayerInfo[ iPlayer ][ g_iId ] );
}

public HandlePlayerInsert( iFailState, Handle: hQuery, szError[ ], iError, szData[ ], iSize, Float: flQueueTime ) {
	if( SQL_IsFail( iFailState, iError, szError ) )
		return;
	
	new iPlayer = szData[ 0 ];
	
	if( !IsUserAuthorized( iPlayer ) )
		return;
	
	new szQuery[ 128 ], szPlayerId[ 1 ]; szPlayerId[ 0 ] = iPlayer;
	formatex( szQuery, charsmax( szQuery ), "SELECT `Id` FROM `bymtimer` WHERE `SteamID` = '%s'", g_PlayerInfo[ iPlayer ][ g_szSteamId ] );
	SQL_ThreadQuery( g_hSqlConnection, "HandlePlayerInsert2", szQuery, szPlayerId, 1 );
}

public HandlePlayerInsert2( iFailState, Handle: hQuery, szError[ ], iError, szData[ ], iSize, Float: flQueueTime ) {
	if( SQL_IsFail( iFailState, iError, szError ) )
		return;
	
	new iPlayer = szData[ 0 ];
	
	if( !IsUserAuthorized( iPlayer ) )
		return;
	
	g_PlayerInfo[ iPlayer ][ g_iId ] = SQL_ReadResult( hQuery, 0 );
	g_PlayerInfo[ iPlayer ][ g_iTime ] = 0;
	
	SQL_QueryMe( "UPDATE `bymtimer` SET `LastSeen` = '%i' WHERE `Id` = '%i';", get_systime( ), g_PlayerInfo[ iPlayer ][ g_iId ] );
}

public client_infochanged( iPlayer ) {
	new szName[ 32 ];
	get_user_info( iPlayer, "name", szName, charsmax( szName ) );
	
	if( !equal( g_PlayerInfo[ iPlayer ][ g_szNick ], szName ) )
		copy( g_PlayerInfo[ iPlayer ][ g_szNick ], charsmax( g_PlayerInfo[ ][ g_szNick ] ), szName );
}

SQL_QueryMe( const szQuery[ ], any:... ) {
	new szMessage[ 256 ];
	vformat( szMessage, charsmax( szMessage ), szQuery, 2 );
	
	SQL_ThreadQuery( g_hSqlConnection, "HandleQuery", szMessage );
}

SQL_IsFail( const iFailState, const iError, const szError[ ] ) {
	if( iFailState == TQUERY_CONNECT_FAILED ) {
		log_to_file( "SQL_Error.txt", "[Error] Could not connect to SQL database: %s", szError );
		return true;
	}
	else if( iFailState == TQUERY_QUERY_FAILED ) {
		log_to_file( "SQL_Error.txt", "[Error] Query failed: %s", szError );
		return true;
	}
	else if( iError ) {
		log_to_file( "SQL_Error.txt", "[Error] Error on query: %s", szError );
		return true;
	}
	
	return false;
}

public HandleQuery( iFailState, Handle: hQuery, szError[ ], iError, szData[ ], iSize, Float: flQueueTime )
	SQL_IsFail( iFailState, iError, szError );

stock bool: CheckConditions( iPlayer, &iHours ) {
	if( !file_exists( "PlayersToReward.txt" ) )
		return false;
	
	new iFile = fopen( "PlayersToReward.txt", "rt" );
	
	if( !iFile )
		return false;
	
	new szSteam[ 64 ];
	get_user_authid( iPlayer, szSteam, charsmax( szSteam ) );
		
	new szData[ 512 ], szPiece[ 3 ][ 64 ], iGiven, iLine = 0;
	while( iFile && !feof( iFile ) ) {
		iLine ++;
		
		fgets( iFile, szData, charsmax( szData ) );
		
		if( szData[ 0 ] == EOS )
			continue;
		
		if( szData[ 0 ] == '*' )
			iGiven ++;
			
		if( iGiven >= 15 ) {
			if( iFile ) fclose( iFile );
			unlink( "PlayersToReward.txt" );
			return false;
		}
			
		parse( szData, szPiece[ 0 ], charsmax( szPiece[ ] ), szPiece[ 1 ], charsmax( szPiece[ ] ), szPiece[ 2 ], charsmax( szPiece[ ] ) );
		
		if( CheckExpration( szPiece[ 2 ] ) == true ) {
			write_file( "PlayersToReward.txt", "*", iLine - 1 );
			iGiven ++;
			
			if( iGiven >= 15 ) {
				if( iFile ) fclose( iFile );
				unlink( "PlayersToReward.txt" );
				return false;
			}
			
			continue;
		}
			
		if( equal( szPiece[ 0 ], szSteam ) ) {
			write_file( "PlayersToReward.txt", "*", iLine - 1 );
			iGiven ++;
			
			iHours = str_to_num( szPiece[ 1 ] ) / 3600;
			
			if( iGiven >= 15 )
				unlink( "PlayersToReward.txt" );
				
			if( iFile ) fclose( iFile );
			
			return true;
		}
	}
	
	if( iFile ) 
		fclose( iFile );
		
	return false;
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

stock bool: CheckTime( ) {
	new iCurrentTime = get_systime( );
	new iYear, iMonth, iDay, iHour, iMinute, iSecond = 0;
	UnixToTime( iCurrentTime , iYear , iMonth , iDay , iHour , iMinute , iSecond );
	
	// First day in month and 1 'o clock at night and first minute
	return ( iDay == 1 ) && ( iHour == 1 ) && ( iMinute == 1 ) ? true : false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
