#include < bym_api >
#include < hamsandwich >
#include < bym_cod_2016 >
#include < fakemeta >
#include < unixtime >
#include < engine >
#include < time >
#include < fun >
#include < xs >

#define PLUGIN_VERSION		"1.0"
#define CvarValue(%1)		( g_iCvars[ %1 ][ 1 ] ) 

Struct StructFiles {
	g_szFolder,
	g_szVipsFile,
	g_szConfigFile,
	g_szVipInfoFile
}

Struct StructTries {
	Trie: g_tAuth,
	Trie: g_tPassword,
	Trie: g_tExpiration
}

Struct _:StructCvars {
	g_cVipHp,
	g_cVipAp,
	g_cVipDamage,
	g_cVipResistance,
	g_cVipNoRecoill,
	g_cVipBhop,
	g_cVipDoubleJump,
	g_cVipHeResistance,
	g_cVipFallDamageDisabled,
	
	g_cXpForKill,
	g_cXpForKillHeadShot,
	g_cXpForC4,
	g_cHpForKill,
	g_cApForKill,
	g_cHpForKillHeadShot,
	g_cApForKillHeadShot,
	
	g_cGoldForKill,
	g_cGoldForKillHeadShot,
	g_cGoldForC4,
	
	g_cHappyHour,
	g_cNotification,
	g_cNotificationColor,
	g_cFreeForSteam
}

Struct _:StructStrPlayerInfo {
	g_szSteamID[ 32 ],
	g_szName[ 32 ],
	g_szPassword[ 16 ],
	g_szExpiration[ 32 ],
	g_szIp[ 24 ]
}

new g_szFiles[ StructFiles ][ ] = {
	"addons/amxmodx/configs/ByM_Cod/Vip/",
	"addons/amxmodx/configs/ByM_Cod/Vip/Vips.ini",
	"addons/amxmodx/configs/ByM_Cod/Vip/Configs.cfg",
	"addons/amxmodx/configs/ByM_Cod/Vip/Info.txt"
};

new const g_szDefaultContent[ ][ ] = {
	"; Here you can add vips for Legion Cod Vip plugin", 
	"; Format: <Nick/SteamID/Ip> <Password> <Expiration Date (dd/mm/yyyy)>",
	" ",
	"; Comment characters: ; and // (Without and)",
	"; Examples:",
	"; ^"STEAM_0:0:298272626^" ^"^" ^"12/03/2017^" ; milutinke",
	"; ^"milutinke^" ^"mypassword123^" ^"02/07/2017^"; milutinke",
	"; ^"12.312.52.34^" ^"^" ^"07/12/2020^"; milutinke",
	" "
};

new const g_szDefaultVipInfoContent[ ][ ] = {
	"<!DOCTYPE html>",
	"<html>",
	" <head>",
	"	<style type=^"text/css^">",
	"		body {",
	"			background-color: #000000;",
	"			font-family:Verdana,Tahoma;",
	"		}",
	"	</style>",
	"	<meta http-equiv=^"Content-Type^" content=^"text/html; charset=UTF-8^">",
	" </head>",
	" <body>",
	"  <h1>TO DO</h1>",
	" </body>",
	"</html>"
};

new const g_szCvars[ StructCvars ][ ][ ] = {
	{	"cod_vip_hp",				"35",		"Additional health wich vip is getting on spawn"					},
	{	"cod_vip_armor",			"50",		"Additional armor wich vip is getting on spawn"						},
	{	"cod_vip_damage",			"3",		"Additional damage wich vip is giving to the enemy"					},
	{	"cod_vip_resistance",			"3",		"Damage which is decreased vhen vip is taking damage"					},
	{	"cod_vip_norecoill",			"0",		"Does vip has no recoill"								},
	{	"cod_vip_bhop",				"1",		"Does vip has bunny hop"								},
	{	"cod_vip_double_jump",			"1",		"Does vip has double jump"								},
	{	"cod_vip_he_resistance",		"1",		"Vip is resistant to HE Grenade"							},
	{	"cod_vip_fall_damage_disabled",		"1",		"Vip is resistant to Fall Damage"							},
	
	{	"cod_vip_kill_xp",			"25",		"Ammount of additional XP which vip is getting for every kill"				},
	{	"cod_vip_kill_xp_hs",			"35",		"Ammount of additional XP which vip is getting for every kill with head shot"		},
	{	"cod_vip_c4_xp",			"50",		"Ammount of additional XP which vip is getting for defusing/planting C4"		},
	{	"cod_vip_kill_hp",			"15",		"Ammount of additional health wich vip is getting for every kill"			},
	{	"cod_vip_kill_armor",			"20",		"Ammount of additional armor wich vip is getting for every kill"			},
	{	"cod_vip_kill_hp_hs",			"25",		"Ammount of additional health wich vip is getting for every kill with head shot"	},
	{	"cod_vip_kill_armor_hs",		"35",		"Ammount of additional armor wich vip is getting for every kill with head shot"		},
	
	{	"cod_vip_kill_gold",			"1",		"Ammount of additional Gold which vip is getting for every kill"			},
	{	"cod_vip_kill_gold_hs",			"1",		"Ammount of additional Gold which vip is getting for every with head shot"		},
	{	"cod_vip_c4_gold",			"2",		"Ammount of additional Gold which vip is getting for defusing/planting C4"		},
	
	{	"cod_vip_happy_hour",			"22-7",		"Vip happy hour (To turn it off type: off)"						},
	{	"cod_vip_notification",			"1",		"Notification when vip connects to server"						},
	{	"cod_vip_notification_color",		"000 255 255",	"Color of notification when vip connects to server"					},
	{	"cod_vip_free_for_steam",		"0",		"Free vip for Steam Players"								}
}

new g_iCvars[ StructCvars ][ 2 ];
new g_szHappyHourData[ 3 ][ 5 ];
new g_iMessageChat;

new Trie: g_tTries[ StructTries ];
new g_szLoginField[ 32 ];

new g_szPlayerInfo[ 33 ][ StructStrPlayerInfo ];
new Float: g_fPunchAngle[ 33 ][ 3 ];
new g_iJumps[ 33 ];
new g_iFalling;

const g_iExcludedWeapons = ( 1 << CSW_KNIFE | 1 << CSW_HEGRENADE | 1 << CSW_FLASHBANG | 1 << CSW_SMOKEGRENADE | 1 << CSW_C4 );
new g_iMaxPlayers;

public plugin_init( ) {
	// Plugin Initialisation
	register_plugin( "[ByM] Cod: Vip", "5.1b", "Milutinke (ByM)" );
	
	// Ham Module Forwards
	RegisterHam( Ham_TakeDamage, "player", "fw_PlayerTakeDamage" );
	RegisterHam( Ham_Player_Jump, "player", "fw_HamPlayerJump" );
	
	new szWeaponName[ 24 ]
	for( new i = 1; i <= 30; i ++ ) {
		if( !( g_iExcludedWeapons & 1 << i ) && get_weaponname( i, szWeaponName, charsmax( szWeaponName ) ) ) {
			RegisterHam( Ham_Weapon_PrimaryAttack, szWeaponName, "fw_Weapon_PrimaryAttack_Pre" );
			RegisterHam( Ham_Weapon_PrimaryAttack, szWeaponName, "fw_Weapon_PrimaryAttack_Post", .Post = true );
		}
	}
	
	g_iMaxPlayers = get_maxplayers( );
	 
	// ByM Api Intialisation
	ByM::Initialise( );
	
	// Commands
	register_clcmd( "say /vips", "OnlineVips" );
	register_clcmd( "say_team /vips", "OnlineVips" );
	register_clcmd( "say /vipovi", "OnlineVips" );
	register_clcmd( "say_team /vipovi", "OnlineVips" );
	register_clcmd( "say /vipinfo", "VipInfo" );
	register_clcmd( "say_team /vipinfo", "VipInfo" );
	register_clcmd( "say /vip", "MyVipInfo" );
	register_clcmd( "say_team /vip", "MyVipInfo" );
	register_clcmd( "say /myvip", "MyVipInfo" );
	register_clcmd( "say_team /myvip", "MyVipInfo" );

	// Messages
	register_message( get_user_msgid( "ScoreAttrib" ), "fw_MessageScore" );
	g_iMessageChat = get_user_msgid( "SayText" );
	
	// Other
	LoadCvars( );
	LoadVips( );
}

LoadCvars( ) {
	for( new iIterator = 0; iIterator < StructCvars; iIterator ++ )
		g_iCvars[ iIterator ][ 0 ] = register_cvar( g_szCvars[ iIterator ][ 0 ], g_szCvars[ iIterator ][ 1 ] );
	
	InitialiseFiles( );
	
	server_cmd( "exec %s", g_szFiles[ g_szConfigFile ] );
	server_exec( );
	
	set_task( 0.1, "LoadCvarsPost" );
}

public LoadCvarsPost( ) {
	for( new iIterator = 0; iIterator < StructCvars; iIterator ++ )
		g_iCvars[ iIterator ][ 1 ] = get_pcvar_num( g_iCvars[ iIterator ][ 0 ] );
		
	get_pcvar_string( g_iCvars[ g_cHappyHour ][ 0 ], g_szHappyHourData[ 0 ], charsmax( g_szHappyHourData[ ] ) );
	replace_all( g_szHappyHourData[ 0 ], charsmax( g_szHappyHourData[ ] ), "-", " " );
	parse( g_szHappyHourData[ 0 ], g_szHappyHourData[ 1 ], charsmax( g_szHappyHourData[ ] ), g_szHappyHourData[ 2 ], charsmax( g_szHappyHourData[ ] ) ); 
	get_cvar_string( "amx_password_field", g_szLoginField, charsmax( g_szLoginField ) );
}

InitialiseFiles( ) {
	if( !dir_exists( g_szFiles[ g_szFolder ] ) )
		mkdir( g_szFiles[ g_szFolder ] );
		
	if( !file_exists( g_szFiles[ g_szVipsFile ] ) ) {
		for( new iIterator = 0; iIterator < sizeof( g_szDefaultContent ); iIterator ++ )
			write_file( g_szFiles[ g_szVipsFile ], g_szDefaultContent[ iIterator ] );
	}
	
	if( !file_exists( g_szFiles[ g_szVipInfoFile ] ) ) {
		for( new iIterator = 0; iIterator < sizeof( g_szDefaultVipInfoContent ); iIterator ++ )
			write_file( g_szFiles[ g_szVipInfoFile ], g_szDefaultVipInfoContent[ iIterator ] );
	}
	
	if( !file_exists( g_szFiles[ g_szConfigFile ] ) ) {
		new szLine[ 256 ];
		
		for( new iIterator = 0; iIterator < StructCvars; iIterator ++ ) {
			formatex( szLine, charsmax( szLine ), "^"%s^" ^"%s^" 		//%s", g_szCvars[ iIterator ][ 0 ], g_szCvars[ iIterator ][ 1 ], g_szCvars[ iIterator ][ 2 ] );
			write_file( g_szFiles[ g_szConfigFile ], szLine );
		}
	}
}

DestroyTries( ) {
	if( g_tTries[ g_tAuth ] )
		TrieDestroy( g_tTries[ g_tAuth ] );
		
	if( g_tTries[ g_tPassword ] )
		TrieDestroy( g_tTries[ g_tPassword ] );
		
	if( g_tTries[ g_tExpiration ] )
		TrieDestroy( g_tTries[ g_tExpiration ] );
}

LoadVips( ) {
	DestroyTries( );
	
	g_tTries[ g_tAuth ] = TrieCreate( );
	g_tTries[ g_tPassword ] = TrieCreate( );
	g_tTries[ g_tExpiration ] = TrieCreate( );
	
	new iFile = fopen( g_szFiles[ g_szVipsFile ], "rt" );
	new szData[ 128 ], szPiece[ 3 ][ 64 ], iLine, iLoaded, iExpired;
	
	while( iFile && !feof( iFile ) ) {
		iLine ++;
		
		fgets( iFile, szData, charsmax( szData ) );
		
		if( szData[ 0 ] == EOS || ( szData[ 0 ] == ';' ) || ( szData[ 0 ] == '/' && szData[ 1 ] == '/' ) )
			continue;
		
		if( parse( szData, szPiece[ 0 ], charsmax( szPiece[ ] ), szPiece[ 1 ], charsmax( szPiece[ ] ), szPiece[ 2 ], charsmax( szPiece[ ] ) ) < 3 )
			continue;
			
		if( CheckExpration( szPiece[ 2 ] ) == true ) {
			iExpired ++;
			write_file( g_szFiles[ g_szVipsFile ], "", iLine - 1 );
			continue;
		}
		
		iLoaded ++;
			
		TrieSetString( g_tTries[ g_tAuth ], szPiece[ 0 ], szPiece[ 0 ] );
		TrieSetString( g_tTries[ g_tPassword ], szPiece[ 0 ], szPiece[ 1 ] );
		TrieSetString( g_tTries[ g_tExpiration ], szPiece[ 0 ], szPiece[ 2 ] );
	}
	
	fclose( iFile );
}

public plugin_natives( ) {
	register_native( "cod_is_vip", "Native_IsVip", 1 );
	register_native( "cod_reload_vips", "ReloadVips", 1 );
	register_native( "cod_give_vip", "GiveVip", 1 );
}

public Native_IsVip( iPlayer )
	return IsPlayer->Vip( iPlayer ) ? true : false;
	
public VipInfo( iPlayer ) {
	if( !IsPlayer->Vip( iPlayer ) ) {
		MyVipInfo( iPlayer );
		return;
	}
	
	if( IsHappyHour( ) ) {
		PrintToChat( iPlayer, "!g[VIP] You have free vip." );
		return;
	}
	
	show_motd( iPlayer, g_szFiles[ g_szVipInfoFile ], "VIP INFO" );
}

public OnlineVips( iPlayer ) {
	if( IsHappyHour( ) ) {
		PrintToChat( iPlayer, "!g[VIP] !n%L", iPlayer, "ML_HAPPY_HOUR" );
		return;
	}
	
	new szMessage[ 190 ];
	formatex( szMessage, charsmax( szMessage ), "!g%L:!n ", iPlayer, "ML_ONLINE_VIPS" );
	
	for( new iIterator = 1; iIterator <= g_iMaxPlayers; iIterator ++ ) {
		if( !IsPlayer->Vip( iIterator ) )
			continue;
			
		if( strlen( szMessage ) >= 185 ) {
			formatex( szMessage, charsmax( szMessage ), "%s ... ", szMessage );
			break;
		}
		
		formatex( szMessage, charsmax( szMessage ), "%s%s, ", szMessage, g_szPlayerInfo[ iIterator ][ g_szName ] );
	}

	PrintToChat( iPlayer, szMessage );
}

public MyVipInfo( iPlayer ) {
	if( IsHappyHour( ) ) {
		PrintToChat( iPlayer, "!g[VIP] You have free vip, beacuse it is happy hour." );
		return;
	}
	
	PrintToChat( iPlayer, "!g[VIP] !n%L: !g%s", iPlayer, "ML_VIP_EXPIRES", g_szPlayerInfo[ iPlayer ][ g_szExpiration ] );
}

public cod_abilities_set_pre( iPlayer, iClass ) {
	if( !IsPlayer->Vip( iPlayer ) )
		return;
		
	cod_set_player_max_hp( iPlayer, cod_get_player_max_hp( iPlayer ) + CvarValue( g_cVipHp ) );
}

public cod_abilities_set_post( iPlayer, iClass ) {
	if( !IsPlayer->Vip( iPlayer ) )
		return;
		
	entity_set_float( iPlayer, EV_FL_armorvalue, ( entity_get_float( iPlayer, EV_FL_armorvalue ) + CvarValue( g_cVipAp ) ) );
	give_item( iPlayer, "weapon_hegrenade" );
	give_item( iPlayer, "weapon_flashbang" );
	give_item( iPlayer, "weapon_flashbang" );
	give_item( iPlayer, "weapon_smokegrenade" );
}

public cod_death( iAttacker, iVictim, iHs ) {
	if( !IsPlayer->Vip( iAttacker ) || IsPlayer->Bot( iAttacker ) )
		return;
		
	cod_set_xp( iAttacker, cod_get_xp( iAttacker ) + ( iHs ? CvarValue( g_cXpForKillHeadShot ) : CvarValue( g_cXpForKill ) ) );
	cod_set_gold( iAttacker, cod_get_gold( iAttacker ) + ( iHs ? CvarValue( g_cGoldForKillHeadShot ) : CvarValue( g_cGoldForKill ) ) );
	
	if( IsPlayer->Alive( iAttacker ) && IsPlayer->Connected( iAttacker ) ) {
		entity_set_float( iAttacker, EV_FL_health, entity_get_float( iAttacker, EV_FL_health ) + float( iHs ? CvarValue( g_cHpForKillHeadShot ) : CvarValue( g_cHpForKill ) ) );
		entity_set_float( iAttacker, EV_FL_armorvalue, entity_get_float( iAttacker, EV_FL_armorvalue ) + float( iHs ? CvarValue( g_cApForKillHeadShot ) : CvarValue( g_cApForKill ) ) );
	}
}

public bomb_defused( iPlayer )
	fw_BombDefused( iPlayer );
	
public bomb_planted( iPlayer )
	fw_BombPlanted( iPlayer );

public fw_BombDefused( iPlayer ) {
	if( IsPlayer->Vip( iPlayer ) && IsPlayer->Connected( iPlayer ) && IsPlayer->Alive( iPlayer ) )
		cod_set_xp( iPlayer, cod_get_xp( iPlayer ) + CvarValue( g_cXpForC4 ) );
}

public fw_BombPlanted( iPlayer ) {
	if( IsPlayer->Vip( iPlayer ) && IsPlayer->Connected( iPlayer ) && IsPlayer->Alive( iPlayer ) )
		cod_set_xp( iPlayer, cod_get_xp( iPlayer ) + CvarValue( g_cXpForC4 ) );
}

public fw_HamPlayerJump( iPlayer ) {
	if( !CvarValue( g_cVipDoubleJump ) )
		return HAM_IGNORED;
		
	if( !IsPlayer->Alive( iPlayer ) || !IsPlayer->Connected( iPlayer ) )
		return HAM_IGNORED;
		
	if( !IsPlayer->Vip( iPlayer ) )
		return HAM_IGNORED;

	static iFlags;
	iFlags = entity_get_int( iPlayer, EV_INT_flags );
	
	if( iFlags & FL_WATERJUMP || entity_get_int( iPlayer, EV_INT_waterlevel ) >= 2 || !( get_pdata_int( iPlayer, 246, 5 ) & IN_JUMP ) )
		return HAM_IGNORED;
	
	if( iFlags & FL_ONGROUND ) {
		g_iJumps[ iPlayer ] = 0;
		return HAM_IGNORED;
	}

	if( ++ g_iJumps[ iPlayer ] < 2 ) {
		static Float: fVelocity[ 3 ];
		entity_get_vector( iPlayer, EV_VEC_velocity, fVelocity );
		fVelocity[ 2 ] = random_float( 265.0, 285.0 );
		entity_set_vector( iPlayer, EV_VEC_velocity, fVelocity ); 

		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

public fw_PlayerTakeDamage( iVictim, iInflictor, iAttacker, Float: fDamage, iDamageType )  {
	if( !IsPlayer->Connected( iAttacker ) || !IsPlayer->Alive( iAttacker ) || !IsValidPlayer( iAttacker ) )
		return HAM_IGNORED;
		
	if( !IsPlayer->Connected( iVictim ) || !IsPlayer->Alive( iVictim ) )
		return HAM_IGNORED;
		
	if( IsPlayer->Vip( iVictim ) ) {
		if( ( iDamageType & ( 1 << 24 ) ) && CvarValue( g_cVipHeResistance ) )
			return HAM_SUPERCEDE;
			
		fDamage -= float( CvarValue( g_cVipResistance ) );
	}
	
	if( IsPlayer->Vip( iAttacker ) )
		fDamage += CvarValue( g_cVipDamage );
	
	SetHamParamFloat( 4, fDamage );
	return HAM_IGNORED;
}

public fw_Weapon_PrimaryAttack_Pre( iEntity ) {
	static iPlayer;
	iPlayer = entity_get_edict( iEntity, EV_ENT_owner );
	
	if( IsPlayer->Vip( iPlayer ) ) {
		entity_get_vector( iPlayer, EV_VEC_punchangle, g_fPunchAngle[ iPlayer ] );
		return HAM_IGNORED;
	}
	
	return HAM_IGNORED;
}

public fw_Weapon_PrimaryAttack_Post( iEntity ) {
	static iPlayer;
	iPlayer = entity_get_edict( iEntity, EV_ENT_owner );

	if( IsPlayer->Vip( iPlayer ) ) {
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

public fw_MessageScore( ) {
	if( IsPlayer->Vip( get_msg_arg_int( 1 ) ) && !get_msg_arg_int( 2 ) )
		set_msg_arg_int( 2, ARG_BYTE, ( 1 << 2 ) );
}

public client_PreThink( iPlayer ) {
	if( !IsPlayer->Vip( iPlayer ) )
		return;
		
	if( !IsPlayer->Connected( iPlayer ) || !IsPlayer->Alive( iPlayer ) || !IsValidPlayer( iPlayer ) )
		return;
	
	if( CvarValue( g_cVipBhop ) ) {
		entity_set_float( iPlayer, EV_FL_fuser2, 0.0 );
		
		if( entity_get_int( iPlayer, EV_INT_button ) & 2 ) {
			static iFlags;
			iFlags = entity_get_int( iPlayer, EV_INT_flags );
			
			if( iFlags & ( 1 << 11 ) || entity_get_int( iPlayer, EV_INT_waterlevel ) >= 2 || !( iFlags & ( 1 << 9 ) ) )
				return;
			
			static Float: fVelocity[ 3 ];
			entity_get_vector( iPlayer, EV_VEC_velocity, fVelocity );
			fVelocity[ 2 ] += 250.0;
			entity_set_vector( iPlayer, EV_VEC_velocity, fVelocity );
			
			entity_set_int( iPlayer, EV_INT_gaitsequence, 6 );
		}
	}
	
	if( CvarValue( g_cVipFallDamageDisabled ) ) {
		if( entity_get_float( iPlayer, EV_FL_flFallVelocity ) >= 350.0 )
			SetBitVar( g_iFalling, iPlayer );
		else DelBitVar( g_iFalling, iPlayer );
	}
}

public client_PostThink( iPlayer ) {
	if( !CvarValue( g_cVipFallDamageDisabled ) )
		return;
		
	if( !IsPlayer->Vip( iPlayer ) )
		return;
		
	if( !IsPlayer->Connected( iPlayer ) || !IsPlayer->Alive( iPlayer ) || !IsValidPlayer( iPlayer ) || !GetBitVar( g_iFalling, iPlayer ) )
		return;
	
	entity_set_int( iPlayer, EV_INT_watertype, -3 );
}


public client_putinserver( iPlayer ) {
	ByM::PlayerConnected( iPlayer );
	DelBitVar( g_iFalling, iPlayer );
	g_iJumps[ iPlayer ] = 0;
	
	get_user_authid( iPlayer, g_szPlayerInfo[ iPlayer ][ g_szSteamID ],  charsmax( g_szPlayerInfo[ ][ g_szSteamID ] ) );
	get_user_name( iPlayer, g_szPlayerInfo[ iPlayer ][ g_szName ],  charsmax( g_szPlayerInfo[ ][ g_szName ] ) );
	get_user_ip( iPlayer, g_szPlayerInfo[ iPlayer ][ g_szIp ],  charsmax( g_szPlayerInfo[ ][ g_szIp ] ), 1 );
	get_user_info( iPlayer, g_szLoginField, g_szPlayerInfo[ iPlayer ][ g_szPassword ], charsmax( g_szPlayerInfo[ ][ g_szPassword ] ) );
	
	CheckPlayer( iPlayer );
}

public client_disconnect( iPlayer ) {
	ByM::PlayerDisconnected( iPlayer );
	DelBitVar( g_iFalling, iPlayer );
	g_iJumps[ iPlayer ] = 0;
}

public CheckPlayer( iPlayer ) {
	if( IsPlayer->Bot( iPlayer ) )
		return;
		
	if( IsHappyHour( ) || ( IsPlayerSteam( iPlayer ) && CvarValue( g_cFreeForSteam ) ) ) {
		ByM::SetVip( iPlayer );
		formatex( g_szPlayerInfo[ iPlayer ][ g_szExpiration ], charsmax( g_szPlayerInfo[ ][ g_szExpiration ] ), "%d h.", str_to_num( g_szHappyHourData[ 2 ] ) );
		goto Notification;
	}
	
	new szExpiration[ 32 ], szPassword[ 16 ];
	if( TrieKeyExists( g_tTries[ g_tAuth ], g_szPlayerInfo[ iPlayer ][ g_szSteamID ] ) ) {
		TrieGetString( g_tTries[ g_tExpiration ], g_szPlayerInfo[ iPlayer ][ g_szSteamID ], szExpiration, charsmax( szExpiration ) );
		TrieGetString( g_tTries[ g_tPassword ], g_szPlayerInfo[ iPlayer ][ g_szSteamID ], szPassword, charsmax( szPassword ) );
		CheckStatus( iPlayer, szPassword, szExpiration );
	} else if( TrieKeyExists( g_tTries[ g_tAuth ], g_szPlayerInfo[ iPlayer ][ g_szName ] ) ) {
		TrieGetString( g_tTries[ g_tExpiration ], g_szPlayerInfo[ iPlayer ][ g_szName ], szExpiration, charsmax( szExpiration ) );
		TrieGetString( g_tTries[ g_tPassword ], g_szPlayerInfo[ iPlayer ][ g_szName ], szPassword, charsmax( szPassword ) );
		CheckStatus( iPlayer, szPassword, szExpiration );
	} else if( TrieKeyExists( g_tTries[ g_tAuth ], g_szPlayerInfo[ iPlayer ][ g_szIp ] ) ) {
		TrieGetString( g_tTries[ g_tExpiration ], g_szPlayerInfo[ iPlayer ][ g_szIp ], szExpiration, charsmax( szExpiration ) );
		TrieGetString( g_tTries[ g_tPassword ], g_szPlayerInfo[ iPlayer ][ g_szIp ], szPassword, charsmax( szPassword ) );
		CheckStatus( iPlayer, szPassword, szExpiration );
	}
	
	Notification:
	if( CvarValue( g_cNotification ) && IsPlayer->Vip( iPlayer ) ) {
		set_hudmessage( 0, 255, 255, -1.0, random_float( 0.7, 0.9 ), 0, 6.0, 3.0 );
		show_hudmessage( 0, "%L", LANG_PLAYER, "ML_VIP_CONNECTED", g_szPlayerInfo[ iPlayer ][ g_szName ] );
	}
}

public CheckStatus( iPlayer, const szPassword[ ], const szExpiration[ ] ) {
	if( !strlen( szPassword ) || equal( szPassword, g_szPlayerInfo[ iPlayer ][ g_szPassword ] ) ) {
		ByM::SetVip( iPlayer );
		copy( g_szPlayerInfo[ iPlayer ][ g_szExpiration ], charsmax( g_szPlayerInfo[ ][ g_szExpiration ] ), szExpiration );
	}
	else server_cmd( "kick ^"#%d^" ^"%L^"", get_user_userid( iPlayer ), iPlayer, "ML_INVALID_PASSWORD" );
}

public ReloadVips( ) {
	LoadVips( );
	
	ForEachPlayer( iPlayer ) {
		ByM::DelVip( iPlayer );
		CheckPlayer( iPlayer );
	}
}

public client_infochanged( iPlayer ) {
	if( IsPlayer->Bot( iPlayer ) || !IsPlayer->Connected( iPlayer ) )
		return;
		
	new szName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
	
	if( !equal( g_szPlayerInfo[ iPlayer ][ g_szName ], szName ) ) {
		copy( g_szPlayerInfo[ iPlayer ][ g_szName ], charsmax( g_szPlayerInfo[ ][ g_szName ] ), szName );
		CheckPlayer( iPlayer );
	}
}

public GiveVip( iPlayer, iDays ) {
	if( IsPlayer->Vip( iPlayer ) || IsPlayer->Bot( iPlayer ) || !IsPlayer->Connected( iPlayer ) )
		return 0;
		
	new iExpiration = get_systime( ) + ( ( ( 24 * 60 ) * 60 ) * iDays );
	
	if( get_systime( ) >= iExpiration )
		return 2;
		
	new iDay, iMonth, iYear, iHour, iMinute, iSecond;
	new szTime[ 32 ], szText[ 128 ];
	
	UnixToTime( iExpiration, iYear, iMonth, iDay, iHour, iMinute, iSecond );
	formatex( szTime, charsmax( szTime ), "%02d/%02d/%d", iDay, iMonth, iYear );
	
	formatex( szText, charsmax( szText ), "^n^"%s^" ^"^" ^"%s^" ; %s", g_szPlayerInfo[ iPlayer ][ g_szSteamID ], szTime, g_szPlayerInfo[ iPlayer ][ g_szName ] );
	write_file( g_szFiles[ g_szVipsFile ], szText );
	ByM::SetVip( iPlayer );
	
	return 1;
}

public RemoveVip( iPlayer ) {
	if( !IsPlayer->Vip( iPlayer ) || IsPlayer->Bot( iPlayer ) || !IsPlayer->Connected( iPlayer ) )
		return;
	
	new szText[ 128 ], iLine, iLen, szLineData[ 3 ][ 32 ];
	
	while( ( iLine = read_file( g_szFiles[ g_szVipsFile ], iLine, szText, charsmax( szText ), iLen ) ) ) {
		if( !iLen || szText[ 0 ] == ';' || ( szText[ 0 ] == '/' && szText[ 1 ] == '/' ) )
			continue;
				
		if( parse( szText, szLineData[ 0 ], charsmax( szLineData[ ] ), szLineData[ 1 ], charsmax( szLineData[ ] ), szLineData[ 2 ], charsmax( szLineData[ ] ) ) < 3 )
			continue;
				
		if( equal( g_szPlayerInfo[ iPlayer ][ g_szName ], szLineData[ 0 ] ) || equal( g_szPlayerInfo[ iPlayer ][ g_szSteamID ], szLineData[ 0 ] ) || equal( g_szPlayerInfo[ iPlayer ][ g_szIp ], szLineData[ 0 ] ) ) {
			write_file( g_szFiles[ g_szVipsFile ], "", iLine - 1 );
			ByM::DelVip( iPlayer );
			break;
		}
	}
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

stock bool: IsPlayerSteam( iPlayer ) {
        static iRequest;
	
        if( iRequest || ( iRequest = get_cvar_pointer( "dp_r_id_provider" ) ) ) {
            server_cmd( "dp_clientinfo %d", iPlayer );
            server_exec( );
	    
            return ( get_pcvar_num( iRequest ) == 2 ) ? true : false;
        }
	
        return false;
}

stock ColorExplode( iCvar, &iRed, &iGreen, &iBlue ) {
	new szColors[ 16 ], szPiece[ 5 ];
	get_pcvar_string( iCvar, szColors, charsmax( szColors ) );
	
	strbreak( szColors, szPiece, charsmax( szPiece ), szColors, charsmax( szColors ) );
	iRed = str_to_num( szPiece );
	
	strbreak( szColors, szPiece, charsmax( szPiece ), szColors, charsmax( szColors ) );
	iGreen = str_to_num( szPiece );
	iBlue = str_to_num( szColors );
}

stock bool: IsHappyHour( ) {
	if( containi( g_szHappyHourData[ 0 ], "off" ) != -1 )
		return false;
		
	static iHours, iMinutes, iSeconds;
	time( iHours, iMinutes, iSeconds );
       
	new iBeginHour = str_to_num( g_szHappyHourData[ 1 ] );
	new iEndHour  = str_to_num( g_szHappyHourData[ 2 ] );
       
	if( iBeginHour == iEndHour )
		return false;
       
	if( iBeginHour > iEndHour && ( iHours >= iBeginHour || iHours < iEndHour ) )
		return true;
       
	if( iBeginHour < iEndHour && ( iHours >= iBeginHour || iHours < iEndHour ) )
		return true;
       
	return false;
}

stock PrintToChat( iPlayer, const szInput[ ], any:... ) {
	static szMessage[ 191 ];
	vformat( szMessage, charsmax( szMessage ), szInput, 3 );
	replace_all( szMessage, charsmax( szMessage ), "!g", "^4" );
	replace_all( szMessage, charsmax( szMessage ), "!t", "^3" );
	replace_all( szMessage, charsmax( szMessage ), "!n", "^1" );
     
	if( !iPlayer ) {
		for( new iTarget = 1; iTarget <= g_iMaxPlayers; iTarget ++ ) {
			if( !IsPlayer->Connected( iTarget ) || IsPlayer->Bot( iTarget ) || !IsValidPlayer( iTarget ) )
				continue;
		
			message_begin( MSG_ONE_UNRELIABLE, g_iMessageChat, _, iTarget );
			write_byte( iTarget );
			write_string( szMessage );
			message_end( );
		}
	} else {
		if( !IsPlayer->Connected( iPlayer ) || IsPlayer->Bot( iPlayer ) || !IsValidPlayer( iPlayer ) )
			return;
		
		message_begin( MSG_ONE_UNRELIABLE, g_iMessageChat, _, iPlayer );
		write_byte( iPlayer );
		write_string( szMessage );
		message_end( );
	}
}


public plugin_end( )
	DestroyTries( );
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
