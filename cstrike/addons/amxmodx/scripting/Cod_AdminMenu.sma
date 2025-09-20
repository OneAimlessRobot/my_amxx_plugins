
#include < bym_cod_2016 >
#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >
//#include < dhudmessage >
//#include < bym_crypt >
#include < unixtime >
#include < fakemeta >
#include < cstrike >
#include < engine >
#include < nvault >
#include < httpx >
#include < fun >

#include < colorchat >

#define Struct enum

Struct StructPlayerInfo {
	g_iTarget,
	g_iOption,
	g_iCommand
}

new const g_szCodAdminMenu[ ][ ] = {
	"ML_ADMIN_MENU_CLASSES",
	"ML_ADMIN_MENU_VIP",
	"ML_ADMIN_MENU_PERKS",
	"ML_ADMIN_MENU_LEVEL",
	"ML_ADMIN_MENU_GOLD",
	"ML_ADMIN_USE_PLAYER_POINTS",
	"ML_ADMIN_SET_CLASS_MENU"
}

new const g_szLevelsMenu[ ][ ] = {
	"ML_GIVE_LEVELS",
	"ML_SET_LEVELS",
	"ML_TAKE_LEVELS"
}

new const g_szGoldMenu[ ][ ] = {
	"ML_GIVE_GOLD",
	"ML_SET_GOLD",
	"ML_TAKE_GOLD"
}

new const g_szAdminMenu[ ][ ] = {
	"Ban Menu",
	"Kick Menu",
	"Slap Menu",
	"Map Menu"
}

new g_iPlayerInfo[ 33 ][ StructPlayerInfo ];
new szReason[ 33 ][ 512 ];
new g_iMaxPlayers;

public plugin_init( ) {
	register_plugin( "Cod: Admin Menu", "1.0", "Milutinke (ByM)" );
	
	g_iMaxPlayers = get_maxplayers( );

	register_concmd( "ENTER_LEVEL_NUMBER", "LevelsEntered" );
	register_concmd( "ENTER_GOLD_NUMBER", "GoldEntered" );
	register_concmd( "ENTER_REASON", "ReasonEntered" );
	register_concmd( "ENTER_DAYS_NUMBER", "DaysEntered" );
	
	register_clcmd( "say /codadmin", "CodAdminMenu" );
	register_clcmd( "say /adminm", "AdminMenu" );
}

public plugin_precache( ) {
	engfunc( EngFunc_PrecacheSound, "ByM_Cod/select.wav" );
}

public CodAdminMenu( iPlayer ) {
	if( !( get_user_flags( iPlayer ) & ADMIN_LEVEL_C ) ) {
		ColorChat( iPlayer, RED, "%L", iPlayer, "ML_ADMIN_MENU_PERMISSION" );
		return;
	}
	
	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "%L:", iPlayer, "ML_ADMIN_MENU" );
	replace_all( szText, charsmax( szText ), "\d", "\r" );
	new iMenu = menu_create( szText, "CodAdminMenu_Handle" );
	
	for( new iIterator = 0; iIterator < sizeof g_szCodAdminMenu; iIterator ++ ) {
		formatex( szText, charsmax( szText ), "\y%L", iPlayer, g_szCodAdminMenu[ iIterator ] );
		menu_additem( iMenu, szText );
	}
	
	menu_display( iPlayer, iMenu );
}

public CodAdminMenu_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	g_iPlayerInfo[ iPlayer ][ g_iCommand ] = iItem + 1;
	ChoosePlayer( iPlayer );
	
	return PLUGIN_CONTINUE;
}

public AdminMenu( iPlayer ) {
	if( !( get_user_flags( iPlayer ) & ADMIN_LEVEL_D ) ) {
		ColorChat( iPlayer, RED, "%L", iPlayer, "ML_ADMIN_MENU_PERMISSION" );
		return;
	}
	
	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "%L:", iPlayer, "ML_ADMIN_MENU" );
	replace_all( szText, charsmax( szText ), "\d", "\r" );
	new iMenu = menu_create( szText, "AdminMenu_Handle" );
	
	for( new iIterator = 0; iIterator < sizeof g_szAdminMenu; iIterator ++ ) {
		formatex( szText, charsmax( szText ), "\y%s", g_szAdminMenu[ iIterator ] );
		menu_additem( iMenu, szText );
	}
	
	menu_display( iPlayer, iMenu );
}

public AdminMenu_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	switch( iItem ) {
		case 0: client_cmd( iPlayer, "amx_banmenu" );
		case 1: client_cmd( iPlayer, "amx_kickmenu" );
		case 2: client_cmd( iPlayer, "amx_slapmenu" );
		case 3: client_cmd( iPlayer, "amx_mapmenu" );
	}
	
	return PLUGIN_CONTINUE;
}

public LevelsMenu( iPlayer ) {
	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\r%L", iPlayer, "ML_LEVEL_MENU" );
	new iMenu = menu_create( szText, "LevelsMenu_Handle" );
	
	for( new iIterator = 0; iIterator < sizeof g_szLevelsMenu; iIterator ++ ) {
		formatex( szText, charsmax( szText ), "\y%L", iPlayer, g_szLevelsMenu[ iIterator ] );
		menu_additem( iMenu, szText );
	}
	
	menu_display( iPlayer, iMenu );
}

public LevelsMenu_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	g_iPlayerInfo[ iPlayer ][ g_iOption ] = iItem + 1;
	client_cmd( iPlayer, "messagemode ENTER_LEVEL_NUMBER" );
	
	return PLUGIN_CONTINUE;
}

public GoldMenu( iPlayer ) {
	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\r%L", iPlayer, "ML_GOLD_MENU" );
	new iMenu = menu_create( szText, "GoldMenu_Handle" );
	
	for( new iIterator = 0; iIterator < sizeof g_szGoldMenu; iIterator ++ ) {
		formatex( szText, charsmax( szText ), "\y%L", iPlayer, g_szGoldMenu[ iIterator ] );
		menu_additem( iMenu, szText );
	}
	
	menu_display( iPlayer, iMenu );
}

public GoldMenu_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	g_iPlayerInfo[ iPlayer ][ g_iOption ] = iItem + 1;
	client_cmd( iPlayer, "messagemode ENTER_GOLD_NUMBER" );
	
	return PLUGIN_CONTINUE;
}

public ChoosePlayer( iPlayer ) {
	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\r%L", iPlayer, "ML_CHOOSE_PLAYER" );
	new iMenu = menu_create( szText, "ChoosePlayer_Handle" );
	
	new szName[ 32 ], szNumber[ 5 ];
	for( new iIterator = 1; iIterator <= g_iMaxPlayers; iIterator ++ ) {
		if( !is_user_connected( iIterator ) )
			continue;
		
		get_user_name( iIterator, szName, charsmax( szName ) );
		replace_all( szName, charsmax( szName ), "\r", "\y" );
		num_to_str( iIterator, szNumber, charsmax( szNumber ) );
		menu_additem( iMenu, szName, szNumber );
	}
	
	menu_display( iPlayer, iMenu );
}

public ChoosePlayer_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack;
	new szNumber[ 5 ];
	menu_item_getinfo( iMenu, iItem, iAccess, szNumber, charsmax( szNumber ), _, _, iCallBack );
	iItem = str_to_num( szNumber );
	
	if( !is_user_connected( iItem ) )
		return PLUGIN_CONTINUE;
		
	g_iPlayerInfo[ iPlayer ][ g_iTarget ] = iItem;
	
	switch( g_iPlayerInfo[ iPlayer ][ g_iCommand ] ) {
		case 1: ChooseClass( iPlayer );
		case 2: client_cmd( iPlayer, "messagemode ENTER_DAYS_NUMBER" );
		case 3: ChoosePerk( iPlayer );
		case 4: LevelsMenu( iPlayer );
		case 5: GoldMenu( iPlayer );
		case 6: UsePlayerPoints( iPlayer);
		case 7: SetPlayerClass( iPlayer );
	}
	
	return PLUGIN_CONTINUE;
}

public ChooseClass( iPlayer ) {
	new szText[ 96 ];
	formatex( szText, charsmax( szText ) / 3, "\r%L", iPlayer, "ML_CHOOSE_CLASS" );
	new iMenu = menu_create( szText, "ChooseClass_Handle" );
	
	new szClassData[ 4 ][ 64 ];
	for( new iIterator = 1; iIterator <= cod_classes_number( ); iIterator ++ ) {
		cod_get_class_name( iIterator, szClassData[ 0 ], charsmax( szClassData[ ] ) );
		cod_get_class_faction( iIterator, szClassData[ 1 ], charsmax( szClassData[ ] ) );
		cod_get_class_flag( iIterator, szClassData[ 2 ], charsmax( szClassData[ ] ) );
		
		if( !strlen( szClassData[ 0 ] ) || !strlen( szClassData[ 1 ] ) || !strlen( szClassData[ 2 ] ) )
			continue;
			
		if( equal( szClassData[ 2 ], "$" ) || equal( szClassData[ 2 ], "#" ) )
			continue;
			
		formatex( szText, charsmax( szText ), "\y%L \d[\r%L\d]", iPlayer, szClassData[ 0 ], iPlayer, szClassData[ 1 ] );
		num_to_str( iIterator, szClassData[ 3 ], charsmax( szClassData[ ] ) ); 
		menu_additem( iMenu, szText, szClassData[ 3 ] );
	}
	
	menu_display( iPlayer, iMenu );
}

public ChooseClass_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack;
	new szNumber[ 5 ];
	menu_item_getinfo( iMenu, iItem, iAccess, szNumber, charsmax( szNumber ), _, _, iCallBack );
	iItem = str_to_num( szNumber );
	
	new szFlag[ 2 ];
	cod_get_class_flag( iItem, szFlag, charsmax( szFlag ) );
	
	
	if( bym_get_flag( g_iPlayerInfo[ iPlayer ][ g_iTarget ], bym_get_flag_int( szFlag ) ) ) {
		ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L", iPlayer, "ML_PLAYER_ALREADY_HAS_CLASS" );
		return PLUGIN_CONTINUE;
	}
	
	if( !is_user_connected( g_iPlayerInfo[ iPlayer ][ g_iTarget ] ) ) {
		ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L", iPlayer, "ML_NOT_CONNECTED" );
		return PLUGIN_CONTINUE;
	}
	
	g_iPlayerInfo[ iPlayer ][ g_iOption ] = iItem;
	client_cmd( iPlayer, "messagemode ENTER_DAYS_NUMBER" );

	return PLUGIN_CONTINUE;
}

public SetPlayerClass( iPlayer ) {
	new szText[ 96 ];
	formatex( szText, charsmax( szText ) / 3, "\r%L", iPlayer, "ML_CHOOSE_CLASS" );
	new iMenu = menu_create( szText, "SetPlayerClass_Handle" );
	
	new szClassData[ 4 ][ 64 ];
	for( new iIterator = 1; iIterator <= cod_classes_number( ); iIterator ++ ) {
		cod_get_class_name( iIterator, szClassData[ 0 ], charsmax( szClassData[ ] ) );
		cod_get_class_faction( iIterator, szClassData[ 1 ], charsmax( szClassData[ ] ) );
		cod_get_class_flag( iIterator, szClassData[ 2 ], charsmax( szClassData[ ] ) );
		
		if( !strlen( szClassData[ 0 ] ) || !strlen( szClassData[ 1 ] ) || !strlen( szClassData[ 2 ] ) )
			continue;
			
		if( equal( szClassData[ 2 ], "$" ) || equal( szClassData[ 2 ], "#" ) )
			continue;
			
		formatex( szText, charsmax( szText ), "\y%L \d[\r%L\d]", iPlayer, szClassData[ 0 ], iPlayer, szClassData[ 1 ] );
		num_to_str( iIterator, szClassData[ 3 ], charsmax( szClassData[ ] ) ); 
		menu_additem( iMenu, szText, szClassData[ 3 ] );
	}
	
	menu_display( iPlayer, iMenu );
}

public SetPlayerClass_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack;
	new szNumber[ 5 ];
	menu_item_getinfo( iMenu, iItem, iAccess, szNumber, charsmax( szNumber ), _, _, iCallBack );
	iItem = str_to_num( szNumber );
	
	new iTarget = g_iPlayerInfo[ iPlayer ][ g_iTarget ];
	
	new szFlag[ 2 ];
	cod_get_class_flag( iItem, szFlag, charsmax( szFlag ) );
	
	if( !is_user_connected( g_iPlayerInfo[ iPlayer ][ g_iTarget ] ) ) {
		ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L", iPlayer, "ML_NOT_CONNECTED" );
		return PLUGIN_CONTINUE;
	}
	menu_display( iPlayer, iMenu );
	cod_set_class( iTarget, iItem );
	return PLUGIN_CONTINUE;
}


public UsePlayerPoints( iPlayer) {
	new iTarget = g_iPlayerInfo[ iPlayer ][ g_iTarget ];
	use_points_for_someone_else( iPlayer, iTarget );
}
public ChoosePerk( iPlayer ) {
	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\r%L", iPlayer, "ML_CHOOSE_PERK" );
	new iMenu = menu_create( szText, "ChoosePerk_Handle" );
	
	new szPerkName[ 64 ];
	new szNumber[ 3 ];
	for( new iIterator = 1; iIterator <= cod_perks_number( ); iIterator ++ ) {
		cod_get_perk_name( iIterator, szPerkName, charsmax( szPerkName ) );
		
		if( !strlen( szPerkName ) )
			continue;
			
		formatex( szText, charsmax( szText ), "\y%L", iPlayer, szPerkName );
		num_to_str( iIterator, szNumber, charsmax( szNumber ) ); 
		menu_additem( iMenu, szText, szNumber );
	}
	
	menu_display( iPlayer, iMenu );
}

public ChoosePerk_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack;
	new szNumber[ 3 ];
	menu_item_getinfo( iMenu, iItem, iAccess, szNumber, charsmax( szNumber ), _, _, iCallBack );
	iItem = str_to_num( szNumber );
	
	new szPerkName[ 64 ];
	cod_get_perk_name( iItem, szPerkName, charsmax( szPerkName ) );
	
	new iTarget = g_iPlayerInfo[ iPlayer ][ g_iTarget ];
	
	if( !is_user_connected( iTarget ) )
		return PLUGIN_CONTINUE;
	
	cod_set_perk( iTarget, iItem );
	
	new szDate[ 32 ];
	get_time( "%d.%m.%Y %H:%M", szDate, charsmax( szDate ) );
	
	new szName[ 2 ][ 64 ];
	new szSteam[ 2 ][ 64 ];
	new szIp[ 2 ][ 64 ];
	
	get_user_name( iPlayer, szName[ 0 ], charsmax( szName[ ] ) );
	get_user_name( iTarget, szName[ 1 ], charsmax( szName[ ] ) );
	
	get_user_authid( iPlayer, szSteam[ 0 ], charsmax( szSteam[ ] ) );
	get_user_authid( iTarget, szSteam[ 1 ], charsmax( szSteam[ ] ) );
	
	get_user_ip( iPlayer, szIp[ 0 ], charsmax( szIp[ ] ) );
	get_user_ip( iTarget, szIp[ 1 ], charsmax( szIp[ ] ) );
	
	formatex( szReason[ iPlayer ], charsmax( szReason[ ] ), "%s -==- %s -==- %s -==- %s -==- %s -==- %s -==- %s -==- Give Perk (%L)  -==- ", szDate, szName[ 0 ], szSteam[ 0 ], szIp[ 0 ], szName[ 1 ], szSteam[ 1 ], szIp[ 1 ], LANG_SERVER, szPerkName );
	client_cmd( iPlayer, "messagemode ENTER_REASON" );
	
	ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L %L %L", iPlayer, "ML_YOU_GAVE_PERK", iPlayer, szPerkName, iPlayer, "ML_TO_PLAYER", szName[ 1 ] );
	ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L %L", iTarget, "ML_YOU_RECIEVED_PERK", szName[ 0 ], iTarget, szPerkName );
	
	return PLUGIN_CONTINUE;
}

public DaysEntered( iPlayer ) {
	new szNumber[ 4 ], iNumber, iTarget;
	
	read_argv( 1, szNumber, charsmax( szNumber ) );
	replace_all( szNumber, charsmax( szNumber ), "-", "" );
	
	if( !is_str_num( szNumber ) ) {
		iNumber = 30;
	}
	
	iNumber = str_to_num( szNumber );
	iTarget = g_iPlayerInfo[ iPlayer ][ g_iTarget ];

	if( !is_user_connected( iTarget ) ) {
		ColorChat( iPlayer, GREEN, "[CoD:Mw] 1%L", iPlayer, "ML_TARGET_NOT_FOUND" );
		return;
	}
	
	if( iNumber <= 0 )
		iNumber = 30;
	
	if( iNumber > 365 )
		iNumber = 365;

	new szDate[ 32 ];
	get_time( "%d.%m.%Y %H:%M", szDate, charsmax( szDate ) );
	
	new szName[ 2 ][ 64 ];
	new szSteam[ 2 ][ 64 ];
	new szIp[ 2 ][ 64 ];
	
	get_user_name( iPlayer, szName[ 0 ], charsmax( szName[ ] ) );
	get_user_name( iTarget, szName[ 1 ], charsmax( szName[ ] ) );
	
	get_user_authid( iPlayer, szSteam[ 0 ], charsmax( szSteam[ ] ) );
	get_user_authid( iTarget, szSteam[ 1 ], charsmax( szSteam[ ] ) );
	
	get_user_ip( iPlayer, szIp[ 0 ], charsmax( szIp[ ] ) );
	get_user_ip( iTarget, szIp[ 1 ], charsmax( szIp[ ] ) );
	
	new szCommand[ 64 ];
	switch( g_iPlayerInfo[ iPlayer ][ g_iCommand ] ) {
		case 1: {
			new szClassData[ 2 ][ 64 ];
			cod_get_class_name( g_iPlayerInfo[ iPlayer ][ g_iOption ], szClassData[ 0 ], charsmax( szClassData[ ] ) );
			cod_get_class_flag( g_iPlayerInfo[ iPlayer ][ g_iOption ], szClassData[ 1 ], charsmax( szClassData[ ] ) );
			
			formatex( szCommand, charsmax( szCommand ), "Give Class (%L - %d days)", LANG_SERVER, szClassData[ 0 ], iNumber );
			if( bym_give_flag( iTarget, bym_get_flag_int( szClassData[ 1 ] ), iNumber ) == 0 ) {
				ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L", iPlayer, "ML_PLAYER_ALREADY_HAS_CLASS" );
				return;
			}
			
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L ^4%L ^1%L %L", iPlayer, "ML_YOU_GAVE_CLASS", iPlayer, szClassData[ 0 ], iPlayer, "ML_TO_PLAYER", szName[ 1 ], iPlayer, "ML_FOR_DAYS", iNumber );
			ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L ^4%L ^1%L", iTarget, "ML_YOU_RECIEVED_CLASS", szName[ 0 ], iTarget, szClassData[ 0 ], iTarget, "ML_FOR_DAYS", iNumber );
		}
		
		case 2: {
			if( cod_is_vip( iTarget ) ) {
				ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L", iPlayer, "ML_ALREADY_VIP" );
				return;
			}
			
			formatex( szCommand, charsmax( szCommand ), "Give Vip (%d days)", iNumber );
			cod_give_vip( iTarget, iNumber );
			cod_reload_vips( );
			
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L %L %L", iPlayer, "ML_YOU_GAVE_VIP", iPlayer, "ML_TO_PLAYER", szName[ 1 ], iPlayer, "ML_FOR_DAYS", iNumber );
			ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L %L", iTarget, "ML_YOU_RECIEVED_VIP", szName[ 0 ], iTarget, "ML_FOR_DAYS", iNumber );
		}
	}

	formatex( szReason[ iPlayer ], charsmax( szReason[ ] ), "%s -==- %s -==- %s -==- %s -==- %s -==- %s -==- %s -==- %s -==- ", szDate, szName[ 0 ], szSteam[ 0 ], szIp[ 0 ], szName[ 1 ], szSteam[ 1 ], szIp[ 1 ], szCommand );
	client_cmd( iPlayer, "messagemode ENTER_REASON" );
}

public LevelsEntered( iPlayer ) {
	new szNumber[ 6 ], iNumber, iTarget;
	
	read_argv( 1, szNumber, charsmax( szNumber ) );
	iNumber = str_to_num( szNumber );
	iTarget = g_iPlayerInfo[ iPlayer ][ g_iTarget ];

	if( !is_user_connected( iTarget ) ) {
		ColorChat( iPlayer, GREEN, "[CoD:Mw] 1%L", iPlayer, "ML_TARGET_NOT_FOUND" );
		return;
	}

	new szDate[ 32 ];
	get_time( "%d.%m.%Y %H:%M", szDate, charsmax( szDate ) );
	
	new szName[ 2 ][ 64 ];
	new szSteam[ 2 ][ 64 ];
	new szIp[ 2 ][ 64 ];
	
	get_user_name( iPlayer, szName[ 0 ], charsmax( szName[ ] ) );
	get_user_name( iTarget, szName[ 1 ], charsmax( szName[ ] ) );
	
	get_user_authid( iPlayer, szSteam[ 0 ], charsmax( szSteam[ ] ) );
	get_user_authid( iTarget, szSteam[ 1 ], charsmax( szSteam[ ] ) );
	
	get_user_ip( iPlayer, szIp[ 0 ], charsmax( szIp[ ] ) );
	get_user_ip( iTarget, szIp[ 1 ], charsmax( szIp[ ] ) );
	
	if( iNumber > 2001 )
		iNumber = 2001;
				
	new szCommand[ 64 ];
	switch( g_iPlayerInfo[ iPlayer ][ g_iOption ] ) {
		case 1: {
			formatex( szCommand, charsmax( szCommand ), "Give levels (%d)", iNumber );
			cod_set_xp( iTarget, cod_calculate_level( cod_get_level( iTarget ) + iNumber ) );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L %L", iPlayer, "ML_YOU_GAVE_LEVELS", iNumber, iPlayer, "ML_TO_PLAYER", szName[ 1 ] );
			ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L", iTarget, "ML_YOU_RECIEVED_LEVELS", szName[ 0 ], iNumber );
		}
		
		case 2: {
			formatex( szCommand, charsmax( szCommand ), "Set levels (%d)", iNumber );
			cod_set_xp( iTarget, cod_calculate_level( iNumber ) );
			cod_set_level( iTarget, iNumber );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L %L", iPlayer, "ML_YOU_SET_LEVELS", iNumber, iPlayer, "ML_TO_PLAYER", szName[ 1 ] );
			ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L", iTarget, "ML_ADMIN_SET_YOUR_LEVELS", szName[ 0 ], iNumber );
		}
		
		case 3: {
			formatex( szCommand, charsmax( szCommand ), "Take levels (%d)", iNumber );
			cod_set_xp( iTarget, cod_calculate_level( iNumber >= cod_get_level( iPlayer ) ? cod_get_level( iPlayer ) : cod_get_level( iPlayer ) - iNumber ) );
			cod_set_level( iTarget, cod_get_level( iTarget ) - iNumber );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L %L", iPlayer, "ML_YOU_TAKEN_LEVELS", iNumber, iPlayer, "ML_FROM_PLAYER", szName[ 1 ] );
			ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L", iTarget, "ML_ADMIN_TAKEN_YOUR_LEVELS", szName[ 0 ], iNumber );
		}
	}

	formatex( szReason[ iPlayer ], charsmax( szReason[ ] ), "%s -==- %s -==- %s -==- %s -==- %s -==- %s -==- %s -==- %s -==- ", szDate, szName[ 0 ], szSteam[ 0 ], szIp[ 0 ], szName[ 1 ], szSteam[ 1 ], szIp[ 1 ], szCommand );
	client_cmd( iPlayer, "messagemode ENTER_REASON" );
}

public GoldEntered( iPlayer ) {
	new szNumber[ 6 ], iNumber, iTarget;
	
	read_argv( 1, szNumber, charsmax( szNumber ) );
	iNumber = str_to_num( szNumber );
	iTarget = g_iPlayerInfo[ iPlayer ][ g_iTarget ];

	if( !is_user_connected( iTarget ) ) {
		ColorChat( iPlayer, GREEN, "[CoD:Mw] 1%L", iPlayer, "ML_TARGET_NOT_FOUND" );
		return;
	}

	new szDate[ 32 ];
	get_time( "%d.%m.%Y %H:%M", szDate, charsmax( szDate ) );
	
	new szName[ 2 ][ 64 ];
	new szSteam[ 2 ][ 64 ];
	new szIp[ 2 ][ 64 ];
	
	get_user_name( iPlayer, szName[ 0 ], charsmax( szName[ ] ) );
	get_user_name( iTarget, szName[ 1 ], charsmax( szName[ ] ) );
	
	get_user_authid( iPlayer, szSteam[ 0 ], charsmax( szSteam[ ] ) );
	get_user_authid( iTarget, szSteam[ 1 ], charsmax( szSteam[ ] ) );
	
	get_user_ip( iPlayer, szIp[ 0 ], charsmax( szIp[ ] ) );
	get_user_ip( iTarget, szIp[ 1 ], charsmax( szIp[ ] ) );
	
	new szCommand[ 64 ];
	switch( g_iPlayerInfo[ iPlayer ][ g_iOption ] ) {
		case 1: {
			formatex( szCommand, charsmax( szCommand ), "Give gold (%d)", iNumber );
			cod_set_gold( iTarget, cod_get_gold( iTarget ) + iNumber );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L %L", iPlayer, "ML_YOU_GAVE_GOLD", iNumber, iPlayer, "ML_TO_PLAYER", szName[ 1 ] );
			ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L", iTarget, "ML_YOU_RECIEVED_GOLD", szName[ 0 ], iNumber );
		}
		
		case 2: {
			formatex( szCommand, charsmax( szCommand ), "Set gold (%d)", iNumber );
			cod_set_gold( iTarget, iNumber );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L %L", iPlayer, "ML_YOU_SET_GOLD", iNumber, iPlayer, "ML_TO_PLAYER", szName[ 1 ] );
			ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L", iTarget, "ML_ADMIN_SET_YOUR_GOLD", szName[ 0 ], iNumber );
		}
		
		case 3: {
			formatex( szCommand, charsmax( szCommand ), "Take gold (%d)", iNumber );
			cod_set_gold( iTarget, cod_get_gold( iTarget ) - iNumber );
			ColorChat( iPlayer, GREEN, "[CoD:Mw4] ^1%L %L", iPlayer, "ML_YOU_TAKEN_GOLD", iNumber, iPlayer, "ML_FROM_PLAYER", szName[ 1 ] );
			ColorChat( iTarget, GREEN, "[CoD:Mw4] ^1%L", iTarget, "ML_ADMIN_TAKEN_YOUR_GOLD", szName[ 0 ], iNumber );
		}
	}

	formatex( szReason[ iPlayer ], charsmax( szReason[ ] ), "%s -==- %s -==- %s -==- %s -==- %s -==- %s -==- %s -==- %s  -==- ", szDate, szName[ 0 ], szSteam[ 0 ], szIp[ 0 ], szName[ 1 ], szSteam[ 1 ], szIp[ 1 ], szCommand );
	client_cmd( iPlayer, "messagemode ENTER_REASON" );
}

public ReasonEntered( iPlayer ) {
	new szReason2[ 64 ];
	read_argv( 1, szReason2, charsmax( szReason2 ) );
	
	if( !strlen( szReason2 ) )
		add( szReason[ iPlayer ], charsmax( szReason[ ] ), "None" );
	else add( szReason[ iPlayer ], charsmax( szReason[ ] ), szReason2 );
	
	new szFile[ 128 ], szData[ 32 ];
	get_time( "%m_%Y", szData, charsmax( szData ) );
	formatex( szFile, charsmax( szFile ), "addons/amxmodx/configs/ByM_Cod/Logs/%s.txt", szData );
	
	write_file( szFile, szReason[ iPlayer ] );
}
	