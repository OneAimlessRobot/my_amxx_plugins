/*
	-====================<([ ByM CoD Mod ])>=====================-
	Name: Call Of Duty: Modern Warfare 
	Version: 6.2.4b
	Author: Milutinke (ByM)
	Contact: milutinke@gmx.com
	Last modified: 12.08.2017
	
	MOLIM VAS DA NE MENJATE ATUORA!
	PLASE DO NOT CHANGE THE AUTOR!
	-====================<([ ByM CoD Mod ])>=====================-
*/

//=================================================================================================
//				Libraries (Inlcudes)
//=================================================================================================

#include < bym_api > // Temporarely removed
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

#tryinclude "cod_xp.cfg"

//=================================================================================================
//					Preprocesors
//=================================================================================================
#define SameTeam(%0,%1)			bool: ( g_iPlayerInfo[ %0 ][ g_iTeam ] == g_iPlayerInfo[ %1 ][ g_iTeam ] )

#define CvarValue(%1)			( g_iCvars[ %1 ][ 1 ] ) 	// Cvar Value

#define iMaxClasses			150				// Max Classes
#define iMaxPerks			100				// Max Perks

#define Struct				enum

#define iMaxEnergy 			1000			// Max Energy
#define iMaxResisance 			1000			// Max Resistance
#define iMaxStamina			1000			// Max Stamina
#define iMaxDamage 			1000			// Max Damage

//#define ClassPricesSupport		1

#define DEATH_MATCH_ENABLED		1				// Is Deathmatch enabled
#define CLASS_STATISTICS_ENABLED 	1				// Is gathering of classes statistics enbabled
#define START_LEVEL			1				// Start level (Default: 50)

#if defined CLASS_STATISTICS_ENABLED
	#include < fvault >
#endif

//=================================================================================================
//				Structs (Enumerations)
//=================================================================================================
Struct _:StructClassData {
	g_szClassName[ 64 ],
	g_szClassDescription[ 64 ],
	g_szClassFaction[ 64 ],
	g_szClassWeapons[ 96 ],
	g_szClassFlag[ 5 ],
	g_szClassSpeed[ 5 ],
	g_iClassHp,
	g_iClassArmor,
	g_iClassVisibility,
	g_iClassPrice
}

Struct _:StructPerkData {
	g_szPerkName[ 64 ],
	g_szPerkDescription[ 64 ],
	g_szPerkBlocks[ 368 ],
	g_iPerkPrice
}

Struct _:StructIntPlayerInfo {
	g_iClass,
	g_iNewClass,
	
	g_iXp,
	g_iLevel,
	
	g_iPoints,
	g_iEnergy,
	g_iResistance,
	g_iStamina,
	g_iDamage,
	g_iAddNumber,
	
	g_iGold,
	g_iPerk,
	g_iTeam,
	g_iProgress,
	g_iAllowWeaponPickup,
	g_iTrading,
	g_iTargetedPlayer,
	g_iDoubleXP
	
	#if defined DEATH_MATCH_ENABLED
		, g_iSpawnProtection,
		g_iCountDown,
		g_iClassChoosingProcess,
		g_iFirstTime
	#endif
}

Struct _:StructStrPlayerInfo {
	g_szSteamID[ 32 ],
	g_szName[ 32 ],
	g_szIp[ 24 ],
	
	g_szProgress[ 22 ]
}

Struct _:StructFloatPlayerInfo {
	Float: g_fMaxHp,
	Float: g_fSpeed,
	Float: g_fResistance
}

Struct _:StructCvars {
	g_cXpForKill,
	g_cXpForKillHeadShot,
	g_cXpForC4,
	
	g_cGoldForKill,
	g_cGoldForKillHeadShot,
	g_cGoldForC4,
	
	g_cRoundWinXp,
	g_cHappyHour,
	g_cPerkSellMoney
}

Struct _:StructFiles {
	g_szFolder,
	g_szLogsFolder,
	g_szCvarsFile
}

Struct _:StructForwards {
	g_fwClassSelected,
	g_fwClassPreSelected,
	g_fwClassChanged,
	
	g_fwPerkGot,
	g_fwPerkChanged,

	g_fwAbilitiesSetPre,
	g_fwAbilitiesSetPost,
	
	g_fwCodDeath,
	g_fwCodLevelUp,
	g_fwCodUsedAbility,
	g_fwCodHudTicked
}

Struct StructTags {
	TagOnOFF,
	TagIP,
	TagReason
}

//=================================================================================================
//					Variables
//=================================================================================================

new g_ClassData[ iMaxClasses ][ StructClassData ];
new g_iRegisteredClasses = 0;

new g_PerkData[ iMaxPerks ][ StructPerkData ];
new g_iRegisteredPerks = 0;

// Player related
new g_iPlayerInfo[ 33 ][ StructIntPlayerInfo ];
new g_szPlayerInfo[ 33 ][ StructStrPlayerInfo ];
new Float: g_fPlayerInfo[ 33 ][ StructFloatPlayerInfo ];

// Server related
new const g_szCvars[ StructCvars ][ ][ ] = {
	{	"cod_kill_xp",		"70",		"Ammount of XP which player is getting for every Kill"			},
	{	"cod_kill_xp_hs",	"10",		"Ammount of XP which player is getting for every Head Shot"		},
	{	"cod_c4_xp",		"50",		"Ammount of XP which player is getting for defusing/planting C4"	},
	
	{	"cod_kill_gold",	"1",		"Ammount of Gold which player is getting for every Kill"		},
	{	"cod_kill_gold_hs",	"1",		"Ammount of Gold which player is getting for every Head Shot"		},
	{	"cod_c4_gold",		"2",		"Ammount of Gold which player is getting for defusing/planting C4"	},
	
	{	"cod_round_win_xp",	"10",		"Ammount of XP which player is getting for winnign round"		},
	{	"cod_happy_hour",	"22-7",		"Happy Hour Double XP and Gold hours"					},
	{	"cod_sell_perk_money",	"2500",		"Money wich player gets for selling his perk"				}
}

new g_iCvars[ StructCvars ][ 2 ];
new g_szHappyHourData[ 3 ][ 5 ];

new const g_szFiles[ StructFiles ][ ] = {
	"addons/amxmodx/configs/ByM_Cod/",
	"addons/amxmodx/configs/ByM_Cod/Logs/",
	"addons/amxmodx/configs/ByM_Cod/Settings.cfg"
};

new const g_iMaxAmmo[ 31 ] = {
	0, 52, 0, 90, 1, 32, 1, 100, 90,
	1, 120, 100, 100, 90, 90, 90,
	100, 120, 30, 120, 200, 32, 90,
	120, 90, 2, 35, 90, 90, 0, 100
};

new const g_iAddPointsNumber[ ] = { 1, 2, 5, 10, 25, 50, -1 };
new const g_szAddPointsNumber[ ][ ] = { "1", "2", "5", "10", "25", "50", "All" };

new g_iMaxPlayers;
new g_iMessageChat;
new g_iStatusMessage;
new g_iMessageScreenFade;
new g_iVault;
new g_iHud[ 2 ];
new g_bFreezeTime = true;

new const g_szForwards[ StructForwards ][ ] = {
	"cod_class_selected",
	"cod_class_pre_selected",
	"cod_class_changed",
	
	"cod_perk_got",
	"cod_perk_changed",

	"cod_abilities_set_pre",
	"cod_abilities_set_post",
	
	"cod_death",
	"cod_level_up",
	"cod_used_ability",
	"cod_hud_ticked"
}

new g_fwForwards[ StructForwards ];

new const g_szModMenu[ ][ ] = {
	"ML_CHOOSE_CLASS_MENU",
	"ML_SHOP",
	"ML_CHOOSE_TEAM",
	"ML_DESCRIPTION",
	"ML_HTBS",
	"ML_COD_ADMIN_MENU",
	"ML_ADMIN_MENU"
};

new const g_szShop[ ][ ] = {
	"ML_ORDINARY_SHOP",
	"ML_PERK_SHOP"
};

new const g_szOrdinaryShop[ ][ ][ ] = {
	{	"ML_ASPIRIN",		"ML_D_ASPIRIN",		"3000" 		},
	{	"ML_MORFIUM",		"ML_D_MORFIUM",		"5000" 		},
	{	"ML_RED_BULL",		"ML_D_RED_BULL",	"7000" 		},
	{	"ML_SHOP_XP",		"ML_D_SHOP_XP",		"5000" 		},
	{	"ML_SHOP_BXP",		"ML_D_SHOP_BXP",	"10000" 	},
	{	"ML_RANDOM",		"ML_D_RANDOM",		"3000" 		}
};

new const g_szTeamMenuData[][] = {
	"\yTerrorist \w[\rT\w]",
	"\yCounter-Terrorist \w[\rCT\w]^n",
	"\wSpectacing \w[\dSPEC\w]"
};

new const g_szStartSounds[ ][ ] = {
	"sound/ByM_Cod/match_start02.mp3",
	"sound/ByM_Cod/match_start03.mp3",
	"sound/ByM_Cod/match_start04.mp3",
	"sound/ByM_Cod/match_start05.mp3",
	"sound/ByM_Cod/match_start06.mp3",
	"sound/ByM_Cod/match_start07.mp3",
	"sound/ByM_Cod/match_start08.mp3",
	"sound/ByM_Cod/match_start09.mp3"
};

// Ako editujete mod, dodajte svoje ime pored mog
// Kome vidim drugicje ddosujem ga!
// Budite zahalni sto ga delim besplatno
// Please do not change my name, add your next to the mine if you are editing mode

new const g_szHudFormat[ ][ ] = {
	"[%L: %d]^n[%L: %.1f%% / 100%%]^n[%L: %L]^n[%L: %L]^n[%L: %d]^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n[%L: %s]^n[%L: %d / 1000 | %L: %d | Mode by Milutinke - v6.2.4b]",
	"[%L: %d]^n[%L: %.1f%% / 100%%]^n[%L: %L]^n[%L: %L]^n[%L: %d]^n^n^n^n^n^n[%L: %s]^n[%L: %d / 1000 | %L: %d | Mode by Milutinke - v6.2.4b]"
};

//=================================================================================================
//					Plugin Initialisation
//=================================================================================================

public plugin_init( ) {
	register_plugin( "[ByM] Cod Mod Core", "6.2.4b", "Milutinke (ByM)" );
	
	// Protection
	/*new szUrl[ 128 ];
	if( DecryptAndGenerateUrl( szUrl, charsmax( szUrl ) ) )
		HTTPX_Download( szUrl, LICENSE_FILE, "DownloadCompleted" );
	else set_fail_state( "Doslo je do greske prilikom dekripcije!" );*/
	
	//Ham Module Forwards
	RegisterHam( Ham_Spawn, "player", "fw_HamPlayerSpawnPost", .Post = true );
	RegisterHam( Ham_TakeDamage, "player", "fw_HamTakleDamagePre" );
	RegisterHam( Ham_Item_PreFrame, "player", "fw_HamItemPreFramePost", .Post = true );
	RegisterHam( Ham_Touch, "armoury_entity", "fw_HamPlayerTouchPre" );
	RegisterHam( Ham_Touch, "weaponbox", "fw_HamPlayerTouchPre" );
	
	//Events
	register_event( "DeathMsg", "fw_PlayerDeath", "ade" );
	register_event( "CurWeapon", "fw_CurrentWeapon", "be", "1=1" );
	register_event( "HLTV", "fw_NewRound", "a", "1=0", "2=0" );
	register_event( "ResetHUD", "fw_ResetHud", "b" );
	register_logevent( "fw_RoundStart", 2, "1=Round_Start" ); 
	register_event( "StatusValue", 	"fw_ShowStatus", "be", "1=2", "2!0" );
	register_event( "StatusValue", 	"fw_HideStatus", "be", "1=1", "2=0" );
	register_event( "Health", "fw_EventHealth", "b" )
	
	//Fakemeta forwards
	register_forward( FM_EmitSound, "fw_EmiteSound" );
	
	g_iMaxPlayers = get_maxplayers( );
	
	//Messages
	g_iMessageChat = get_user_msgid( "SayText" );
	g_iStatusMessage = get_user_msgid( "StatusText" );
	g_iMessageScreenFade = get_user_msgid( "ScreenFade" )
	register_message( get_user_msgid( "StatusValue" ), "fw_StatusMessage" );
	register_message( get_user_msgid( "TextMsg" ), "fw_RoundEnd" );
	register_message( get_user_msgid( "StatusIcon" ), "fw_StatusIcon" );
	
	// Commands
	register_clcmd( "say", "fw_ChatPrefix" );
	register_clcmd( "say_team", "fw_ChatPrefixTeam" );
	register_clcmd( "chooseteam", "OpenModMenu" );
	register_clcmd( "nightvision", "OpenModMenuN" );
	register_clcmd( "jointeam", "OpenModMenu" );
	register_clcmd( "say /klasa", "ChooseFaction" );
	register_clcmd( "say_team /klasa", "ChooseFaction" );
	register_clcmd( "say /class", "ChooseFaction" );
	register_clcmd( "say_team /class", "ChooseFaction" );
	register_clcmd( "say /klase", "ChooseFaction" );
	register_clcmd( "say_team /klase", "ChooseFaction" );
	register_clcmd( "say /classes", "ChooseFaction" );
	register_clcmd( "say_team /classes", "ChooseFaction" );
	register_clcmd( "say /opis", "FactionDescription" );
	register_clcmd( "say_team /opis", "FactionDescription" );
	register_clcmd( "say /description", "FactionDescription" );
	register_clcmd( "say_team /description", "FactionDescription" );
	register_clcmd( "say /desc", "FactionDescription" );
	register_clcmd( "say_team /desc", "FactionDescription" );
	register_clcmd( "say /predmet", "ChoosePerk" );
	register_clcmd( "say_team /predmet", "ChoosePerk" );
	register_clcmd( "say /perk", "ChoosePerk" );
	register_clcmd( "say_team /perk", "ChoosePerk" );
	register_clcmd( "say /item", "ChoosePerk" );
	register_clcmd( "say_team /item", "ChoosePerk" );
	register_clcmd( "say /shop", "Shop" );
	register_clcmd( "say_team /shop", "Shop" );
	register_clcmd( "say /menu", "ModMenu" );
	register_clcmd( "say_team /menu", "ModMenu" );
	register_clcmd( "say /zameni", "ChangePerk" );
	register_clcmd( "say_team /zameni", "ChangePerk" );
	register_clcmd( "say /trade", "ChangePerk" );
	register_clcmd( "say_team /trade", "ChangePerk" );
	register_clcmd( "say /switch", "ChangePerk" );
	register_clcmd( "say_team /switch", "ChangePerk" );
	register_clcmd( "say /daj", "GivePerkToPlayer" );
	register_clcmd( "say_team /daj", "GivePerkToPlayer" );
	register_clcmd( "say /give", "GivePerkToPlayer" );
	register_clcmd( "say_team /give", "GivePerkToPlayer" );
	register_clcmd( "say /prodaj", "SellPerk" );
	register_clcmd( "say_team /prodaj", "SellPerk" );
	register_clcmd( "say /sell", "SellPerk" );
	register_clcmd( "say_team /sell", "SellPerk" );
	register_clcmd( "say /reset", "Reset" );
	register_clcmd( "say_team /reset", "Reset" );
	
	//Config, etc...
	register_dictionary( "ByM_Cod_Mod_2016.txt" );
	InitialiseConfig( );
	InitialiseForwards( );
	InitialiseHud( );
	InitialiseMenus( );
	InitialiseReloadTimer( );
	
	// Initialise ByM API
	// ByM::Inisitalise( );
}

//=================================================================================================
//					License
//=================================================================================================

// Removed

//=================================================================================================
//					Configs
//=================================================================================================
InitialiseConfig( ) {
	LoadCvars( );
	AddDefaults( );
	g_iVault = nvault_open( "ByM_CoD_Mw4" );
}

AddDefaults( ) {
	copy( g_ClassData[ 0 ][ g_szClassName ], charsmax( g_ClassData[ ][ g_szClassName ] ), "ML_NONE" );
	copy( g_ClassData[ 0 ][ g_szClassDescription ], charsmax( g_ClassData[ ][ g_szClassDescription ] ), "ML_NONE" );
	
	copy( g_PerkData[ 0 ][ g_szPerkName ], charsmax( g_PerkData[ ][ g_szPerkName ] ), "ML_NONE" );
	copy( g_PerkData[ 0 ][ g_szPerkDescription ], charsmax( g_PerkData[ ][ g_szPerkDescription ] ), "ML_NONE" );
}

LoadCvars( ) {
	for( new i = 0; i < StructCvars; i++ )
		g_iCvars[ i ][ 0 ] = register_cvar( g_szCvars[ i ][ 0 ], g_szCvars[ i ][ 1 ] );
	
	if( !dir_exists( g_szFiles[ g_szFolder ] ) )
		mkdir( g_szFiles[ g_szFolder ] );
		
	if( !dir_exists( g_szFiles[ g_szLogsFolder ] ) )
		mkdir( g_szFiles[ g_szLogsFolder ] );
		
	if( !file_exists( g_szFiles[ g_szCvarsFile ] ) ) {
		new szLine[ 256 ];
		
		for( new i = 0; i < StructCvars; i++ ) {
			formatex( szLine, charsmax( szLine ), "^"%s^" ^"%s^" 		//%s", g_szCvars[ i ][ 0 ], g_szCvars[ i ][ 1 ], g_szCvars[ i ][ 2 ] );
			write_file( g_szFiles[ g_szCvarsFile ], szLine );
		}
	}
	
	server_cmd( "exec %s", g_szFiles[ g_szCvarsFile ] );
	server_exec( );
	
	set_task( 0.1, "LoadCvarsPost" );
}

public LoadCvarsPost( ) {
	for( new i = 0; i < StructCvars; i++ )
		g_iCvars[ i ][ 1 ] = get_pcvar_num( g_iCvars[ i ][ 0 ] );
		
	get_pcvar_string( g_iCvars[ g_cHappyHour ][ 0 ], g_szHappyHourData[ 0 ], charsmax( g_szHappyHourData[ ] ) );
	replace_all( g_szHappyHourData[ 0 ], charsmax( g_szHappyHourData[ ] ), "-", " " );
	parse( g_szHappyHourData[ 0 ], g_szHappyHourData[ 1 ], charsmax( g_szHappyHourData[ ] ), g_szHappyHourData[ 2 ], charsmax( g_szHappyHourData[ ] ) ); 
}

InitialiseForwards( ) {
	g_fwForwards[ g_fwClassSelected ] = CreateMultiForward( g_szForwards[ g_fwClassSelected ], ET_CONTINUE, FP_CELL, FP_CELL );
	g_fwForwards[ g_fwClassPreSelected ] = CreateMultiForward( g_szForwards[ g_fwClassPreSelected ], ET_CONTINUE, FP_CELL, FP_CELL );
	g_fwForwards[ g_fwClassChanged ] = CreateMultiForward( g_szForwards[ g_fwClassChanged ], ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL )
	g_fwForwards[ g_fwPerkGot ] = CreateMultiForward( g_szForwards[ g_fwPerkGot ], ET_CONTINUE, FP_CELL, FP_CELL );
	g_fwForwards[ g_fwPerkChanged ] = CreateMultiForward( g_szForwards[ g_fwPerkChanged ], ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL );
	
	g_fwForwards[ g_fwAbilitiesSetPre ] = CreateMultiForward( g_szForwards[ g_fwAbilitiesSetPre ], ET_IGNORE, FP_CELL, FP_CELL );
	g_fwForwards[ g_fwAbilitiesSetPost ] = CreateMultiForward( g_szForwards[ g_fwAbilitiesSetPost ], ET_IGNORE, FP_CELL, FP_CELL );
	
	g_fwForwards[ g_fwCodDeath ] = CreateMultiForward( g_szForwards[ g_fwCodDeath ], ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL );
	g_fwForwards[ g_fwCodLevelUp ] = CreateMultiForward( g_szForwards[ g_fwCodLevelUp ], ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL );
	g_fwForwards[ g_fwCodUsedAbility ] = CreateMultiForward( g_szForwards[ g_fwCodUsedAbility ], ET_CONTINUE, FP_CELL );
	g_fwForwards[ g_fwCodHudTicked ] = CreateMultiForward( g_szForwards[ g_fwCodHudTicked ], ET_CONTINUE, FP_CELL );
}

InitialiseReloadTimer( ) {
	new iEntity = create_entity( "info_target" );
	
	entity_set_string( iEntity, EV_SZ_classname, "ReloaderTimer" );
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 10.0 );
	register_think( "ReloaderTimer", "fw_EntityReloaderThinks" );
}

public fw_EntityReloaderThinks( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return;
		
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 60.0 );
	server_cmd( "reload_classes" );
}

//=================================================================================================
//					Hud Information
//=================================================================================================

InitialiseHud( ) {
	new iEntity = create_entity( "info_target" );
	
	entity_set_string( iEntity, EV_SZ_classname, "HudInfo" );
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 4.0 );
	
	g_iHud[ 0 ] = CreateHudSyncObj( );
	g_iHud[ 1 ] = CreateHudSyncObj( );
	
	register_think( "HudInfo", "fw_EntityThinks" );
}

public fw_EntityThinks( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return;
		
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 0.1 );
	
	static iPlayer, iResult;
	for( iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer ++ ) {
		if( !is_user_connected( iPlayer ) )
			continue;
			
		ShowHud( iPlayer );
		ExecuteForward( g_fwForwards[ g_fwCodHudTicked ], iResult, iPlayer );
	}
}

ShowHud( iPlayer ) {
	static iTarget;
	iTarget = is_user_alive( iPlayer ) ? iPlayer : entity_get_int( iPlayer, EV_INT_iuser2 );
	
	if( is_user_alive( iPlayer ) )
		set_pdata_int( iPlayer, 361, ( 1 << 3 ) );
	
	if( is_user_connected( iTarget ) ) {
		static iLastLevelXp, Float: fXpPercent;
		iLastLevelXp = ( g_iPlayerInfo[ iTarget ][ g_iLevel ] > 1 ) ? ( g_iPlayerInfo[ iTarget ][ g_iLevel ] - 1 ) : 0;
		fXpPercent = 100 * ( Float: ( g_iPlayerInfo[ iTarget ][ g_iXp ] - iLastLevelXp ) / Float: ( g_iLevelXP[ g_iPlayerInfo[ iTarget ][ g_iLevel ] ] - iLastLevelXp ) );
		g_iPlayerInfo[ iTarget ][ g_iProgress ] = ( floatround( fXpPercent ) / 10 );
		
		static iPlayerClass, iPlayerPerk;
		iPlayerClass = g_iPlayerInfo[ iTarget ][ g_iClass ];
		iPlayerPerk = g_iPlayerInfo[ iTarget ][ g_iPerk ];
		
		static i, iIterator;
		for( i = 0; i < sizeof( g_szPlayerInfo[ ][ g_szProgress ] ); i ++ )
			g_szPlayerInfo[ iTarget ][ g_szProgress ][ i ] = EOS;
				
		for( iIterator = 1; iIterator <= 10; iIterator ++ ) {
			if( iIterator <= g_iPlayerInfo[ iTarget ][ g_iProgress ] ) add( g_szPlayerInfo[ iTarget ][ g_szProgress ], charsmax( g_szPlayerInfo[ ][ g_szProgress ] ), "||" );
			else add( g_szPlayerInfo[ iTarget ][ g_szProgress ], charsmax( g_szPlayerInfo[ ][ g_szProgress ] ), "--" );
		}

		set_hudmessage( 0, 255, 255, is_user_alive( iPlayer ) ? 0.02 : 0.6, is_user_alive( iPlayer ) ? 0.2 : 0.5, 0, 6.0, 0.1 );
		ShowSyncHudMsg( iPlayer, g_iHud[ 0 ], is_user_alive( iPlayer ) ? g_szHudFormat[ 0 ] : g_szHudFormat[ 1 ], iPlayer, "ML_LEVEL", g_iPlayerInfo[ iTarget ][ g_iLevel ], iPlayer, "ML_XP", fXpPercent, iPlayer, "ML_CLASS", iPlayer, g_ClassData[ iPlayerClass ][ g_szClassName ],
		iPlayer, "ML_PERK", iPlayer, g_PerkData[ iPlayerPerk ][ g_szPerkName ], iPlayer, "ML_GOLD", g_iPlayerInfo[ iTarget ][ g_iGold ], 
		iPlayer, "ML_XP", g_szPlayerInfo[ iTarget ][ g_szProgress ], iPlayer, "ML_HP", ( get_user_health( iTarget ) > 0 ? get_user_health( iTarget ) : 0 ), iPlayer, "ML_ARMOR", floatround( entity_get_float( iTarget, EV_FL_armorvalue ) > 0 ? entity_get_float( iTarget, EV_FL_armorvalue ) : 0.0 ) );
	}
}

public fw_StatusMessage( )
	set_msg_block( g_iStatusMessage, BLOCK_SET );

public fw_ShowStatus( iPlayer ) {
	static iTarget;
	iTarget = read_data( 2 );
	
	if( !is_user_connected( iPlayer ) || !is_user_alive( iPlayer ) || !is_user_alive( iTarget ) || !is_user_connected( iTarget ) )
		return;
	
	static iLastLevelXp, Float: fXpPercent;
	iLastLevelXp = ( g_iPlayerInfo[ iTarget ][ g_iLevel ] > 1 ) ? ( g_iPlayerInfo[ iTarget ][ g_iLevel ] - 1 ) : 0;
	fXpPercent = 100 * ( Float: ( g_iPlayerInfo[ iTarget ][ g_iXp ] - iLastLevelXp ) / Float: ( g_iLevelXP[ g_iPlayerInfo[ iTarget ][ g_iLevel ] ] - iLastLevelXp ) );

	static bool: bSameTeam;
	bSameTeam = ( g_iPlayerInfo[ iPlayer ][ g_iTeam ] != g_iPlayerInfo[ iTarget ][ g_iTeam ] ) ? false : true;
	
	set_hudmessage( bSameTeam == true ? 0 : 255, bSameTeam == true ? 225 : 0, bSameTeam == true ? 225 : 0, -1.0, 0.58, 1, 0.01, 3.0, 0.01, 0.1 );
	ShowSyncHudMsg( iPlayer, g_iHud[ 1 ], "[Nick: %s]^n[%L: %L]^n[%L: %L]^n[%L: %i]^n[%L: %.1f%% / 100%%]^n[%L: %d]", g_szPlayerInfo[ iTarget ][ g_szName ], iPlayer, "ML_CLASS",
	iPlayer, g_ClassData[ g_iPlayerInfo[ iTarget ][ g_iClass ] ][ g_szClassName ], iPlayer, "ML_PERK", iPlayer, g_PerkData[ g_iPlayerInfo[ iTarget ][ g_iPerk ] ][ g_szPerkName ], iPlayer, "ML_LEVEL",
	g_iPlayerInfo[ iTarget ][ g_iLevel ], iPlayer, "ML_XP", fXpPercent, iPlayer, "ML_HP", ( get_user_health( iTarget ) > 0 ? get_user_health( iTarget ) : 0 ) );
	client_cmd( iPlayer, "cl_crosshair_color ^"%s^"", bSameTeam == true ? "0 255 0" : "255 0 0" );
}

public fw_HideStatus( iPlayer ) {
	client_cmd( iPlayer, "cl_crosshair_color ^"0 255 255^"" );
	ClearSyncHud( iPlayer, g_iHud[ 1 ] );
}

public fw_EmiteSound( iPlayer, iChanel, const szSound[ ], Float: fVolume, Float: fAtn, iFlags, iPitch ) {
	if( !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;
	
	if( equal( szSound, "common/wpn_denyselect.wav" ) ) {
		new iResult;
		ExecuteForward( g_fwForwards[ g_fwCodUsedAbility ], iResult, iPlayer );
		
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

//=================================================================================================
//				  	Map Parameters & Precache
//=================================================================================================

public plugin_precache( ) {
	DisallowBuying( );
	engfunc( EngFunc_PrecacheSound, "ByM_Cod/select.wav" );
	engfunc( EngFunc_PrecacheSound, "ByM_Cod/levelup.wav" );

	for( new iSound = 0; iSound < sizeof( g_szStartSounds ); iSound ++ )
		engfunc( EngFunc_PrecacheGeneric, g_szStartSounds[ iSound ] );
}

DisallowBuying( ) {
	new iEntity = create_entity( "info_map_parameters" );
        
	DispatchKeyValue( iEntity, "buying", "3" );
	DispatchSpawn( iEntity );
}

public pfn_keyvalue( iEntity ) { 
	new szEntityName[ 20 ], szData[ 2 ];
	copy_keyvalue( szEntityName, charsmax( szEntityName ), szData, charsmax( szData ), szData, charsmax( szData ) );
        
	if( equal( szEntityName, "info_map_parameters" ) )  { 
		remove_entity( iEntity );
		return PLUGIN_HANDLED ;
	} 
        
	return PLUGIN_CONTINUE;
}

//=================================================================================================
//				 	Events and Forwards
//=================================================================================================
public fw_HamPlayerSpawnPost( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return HAM_IGNORED;
		
	g_iPlayerInfo[ iPlayer ][ g_iTeam ] = get_user_team( iPlayer );
	
	#if defined DEATH_MATCH_ENABLED
		if( !g_iPlayerInfo[ iPlayer ][ g_iClassChoosingProcess ] ) {
			g_iPlayerInfo[ iPlayer ][ g_iSpawnProtection ] = 1;
			g_iPlayerInfo[ iPlayer ][ g_iCountDown ] = 0;
			set_task( 0.01, "TurnOffSpawnProtection", iPlayer );
		}
	
		g_iPlayerInfo[ iPlayer ][ g_iClassChoosingProcess ] = 0;
	#endif
	
	if( g_iPlayerInfo[ iPlayer ][ g_iNewClass ] ) {
		new iResult;
		ExecuteForward( g_fwForwards[ g_fwClassChanged ], iResult, iPlayer, g_iPlayerInfo[ iPlayer ][ g_iClass ], g_iPlayerInfo[ iPlayer ][ g_iNewClass ] );

		g_iPlayerInfo[ iPlayer ][ g_iClass ] = g_iPlayerInfo[ iPlayer ][ g_iNewClass ];
		g_iPlayerInfo[ iPlayer ][ g_iNewClass ] = 0;
		LoadData( iPlayer, g_iPlayerInfo[ iPlayer ][ g_iClass ] );
	}
	
	if( !g_iPlayerInfo[ iPlayer ][ g_iClass ] ) {
		ChooseFaction( iPlayer );
		return HAM_IGNORED;
	}
		
	if( g_iPlayerInfo[ iPlayer ][ g_iPoints ] > 0 )
		UsePoints( iPlayer );
		
	if( g_iPlayerInfo[ iPlayer ][ g_iLevel ] <= START_LEVEL ) {
		g_iPlayerInfo[ iPlayer ][ g_iLevel ] = START_LEVEL;
		g_iPlayerInfo[ iPlayer ][ g_iXp ] = g_iLevelXP[ g_iPlayerInfo[ iPlayer ][ g_iLevel ] - 1 ];
		SaveData( iPlayer );
	}
	
	SetAbilities( iPlayer, g_iPlayerInfo[ iPlayer ][ g_iClass ] ), sab( iPlayer );
	
	return HAM_IGNORED;
}

#if defined DEATH_MATCH_ENABLED
	public CountDown( iPlayer) {
		if( is_user_connected( iPlayer ) && g_iPlayerInfo[ iPlayer ][ g_iCountDown ] ) {
			set_task( 1.0, "CountDown", iPlayer );
			set_hudmessage( 255, 0, 255, -1.0, 0.3, 0, 6.0, 1.0 );
			show_hudmessage( iPlayer, "%L", iPlayer, "ML_RESPAWN_IN", g_iPlayerInfo[ iPlayer ][ g_iCountDown ] );
			g_iPlayerInfo[ iPlayer ][ g_iCountDown ] --;
		}
	}
	
	public TurnOffSpawnProtection( iPlayer )
		g_iPlayerInfo[ iPlayer ][ g_iSpawnProtection ] = 0;
#endif

public SetAbilities( iPlayer, iClassId ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	if( !g_iRegisteredClasses )
		return;

	g_fPlayerInfo[ iPlayer ][ g_fMaxHp ] = float( g_ClassData[ iClassId ][ g_iClassHp ] ) + ( g_iPlayerInfo[ iPlayer ][ g_iEnergy ] * 2 ) > 1000.0 ? 1000.0 : float( g_ClassData[ iClassId ][ g_iClassHp ] ) + ( g_iPlayerInfo[ iPlayer ][ g_iEnergy ] * 2 ) ;
	g_fPlayerInfo[ iPlayer ][ g_fSpeed ] = ( 250.0 * str_to_float( g_ClassData[ iClassId ][ g_szClassSpeed ] ) + floatround( g_iPlayerInfo[ iPlayer][ g_iStamina ] * 1.3 ) );
	g_fPlayerInfo[ iPlayer ][ g_fResistance ] = ( 0.7 * ( 1.0 - floatpower( 1.1, -0.112311341 * float( g_iPlayerInfo[ iPlayer ][ g_iResistance ] ) ) ) );
	
	new iResult;
	ExecuteForward( g_fwForwards[ g_fwAbilitiesSetPre ], iResult, iPlayer, g_iPlayerInfo[ iPlayer ][ g_iClass ] );
	
	entity_set_float( iPlayer, EV_FL_health, g_fPlayerInfo[ iPlayer ][ g_fMaxHp ] );
	entity_set_float( iPlayer, EV_FL_armorvalue, float( g_ClassData[ iClassId ][ g_iClassArmor ] ) );
	set_user_rendering( iPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, g_ClassData[ iClassId ][ g_iClassVisibility ] );

	strip_user_weapons( iPlayer );
	give_item( iPlayer, "weapon_knife" );
	
	new szWeaponList[ 21 ][ 22 ], szWeapon[ 32 ], i;
	ExplodeString( g_ClassData[ iClassId ][ g_szClassWeapons ], ':', szWeaponList, 20, charsmax( szWeaponList ) );

	for( i = 0; i <= 21; i++ ) {
		if( szWeaponList[ i ][ 0 ] != EOS ) {
			if( szWeaponList[ i ][ 0 ] == '>' ) 
				continue;
				
			formatex( szWeapon, charsmax( szWeapon ), "weapon_%s", szWeaponList[ i ] );
			give_item( iPlayer, szWeapon );
		} else { break; }
	}
	
	GiveAmmo( iPlayer );
	ExecuteForward( g_fwForwards[ g_fwAbilitiesSetPost ], iResult, iPlayer, g_iPlayerInfo[ iPlayer ][ g_iClass ] );
}

public fw_HamTakleDamagePre( iVictim, iInflictor, iAttacker, Float: fDamage, iDamageType ) {
	if( !is_user_connected( iAttacker ) || !g_iPlayerInfo[ iAttacker ][ g_iClass ] || !is_user_alive( iVictim ) || !is_user_connected( iVictim ) || ( iAttacker == iVictim ) )
		return HAM_IGNORED;
		
	#if defined DEATH_MATCH_ENABLED
		if( is_user_alive( iVictim ) && g_iPlayerInfo[ iVictim ][ g_iSpawnProtection ] )
			return HAM_SUPERCEDE;
	#endif
		
	if( g_iPlayerInfo[ iAttacker ][ g_iTeam ] == g_iPlayerInfo[ iVictim ][ g_iTeam ] )
		return HAM_IGNORED;
		
	static Float: fHealth;
	fHealth = entity_get_float( iVictim, EV_FL_health );
	
	if( fHealth < 2.0 )
		return HAM_IGNORED;
		
	if( iDamageType & DMG_BULLET ) {
		set_hudmessage( 170, 255, 255, -1.0, -1.0, 1, 0.01, 3.0, 0.01, 2.0 );
		ShowSyncHudMsg( iAttacker, g_iHud[ 1 ], ">X<" );
	}
	
	static iBonusForDamage;
	iBonusForDamage = floatround( fDamage );

	while( iBonusForDamage > 30 ) {
		iBonusForDamage -= 30;
		g_iPlayerInfo[ iAttacker ][ g_iXp ] ++;
		CheckLevel( iAttacker );
	}
	
	if( g_iPlayerInfo[ iVictim ][ g_iResistance ] > 0 )
		fDamage -= g_fPlayerInfo[ iVictim ][ g_fResistance ] * fDamage;
	
	if( g_iPlayerInfo[ iAttacker ][ g_iDamage ] > 0 )
		fDamage += float( g_iPlayerInfo[ iAttacker ][ g_iDamage ] / 4 );
		
	if( g_iPlayerInfo[ iAttacker ][ g_iLevel ] > 500 && g_iPlayerInfo[ iVictim ][ g_iLevel ] < 500 )
		fDamage -= random_float( 3.0, 9.0 );
		
	SetHamParamFloat( 4, fDamage );
	return HAM_IGNORED;
}

public fw_PlayerDeath( ) {
	new iAttacker = read_data( 1 );
	new iVictim = read_data( 2 );
	new iHs = read_data( 3 );
	
	#if defined DEATH_MATCH_ENABLED
		if( ( 1 <= iVictim <= g_iMaxPlayers ) && is_user_connected( iVictim ) ) {
			if( cs_get_user_team( iVictim ) != CS_TEAM_SPECTATOR ) {
				g_iPlayerInfo[ iVictim ][ g_iTeam ] = get_user_team( iVictim );
				set_task( 3.0, "Respawn", iVictim );
				
				g_iPlayerInfo[ iVictim ][ g_iCountDown ] = 3;
				set_task( 0.0, "CountDown", iVictim );
			}
		}
	#endif
	
	if( !is_user_connected( iAttacker ) || !g_iPlayerInfo[ iAttacker ][ g_iClass ] )
		return;
		
	if( g_iPlayerInfo[ iAttacker ][ g_iTeam ] == g_iPlayerInfo[ iVictim ][ g_iTeam ] || iAttacker == iVictim )
		return;
		
	new iNewXp[ 2 ], iNewGold[ 2 ];
	iNewXp[ 0 ] += ( iHs ? ( CvarValue( g_cXpForKill  ) + CvarValue( g_cXpForKillHeadShot ) ) : CvarValue( g_cXpForKill  ) );
	iNewXp[ 1 ] += ( IsHappyHour( ) || g_iPlayerInfo[ iAttacker ][ g_iDoubleXP ] ? ( iNewXp[ 0 ] * 2 ) : iNewXp[ 0 ] );
	
	iNewGold[ 0 ] += ( iHs ? ( CvarValue( g_cGoldForKill  ) + CvarValue( g_cGoldForKillHeadShot ) ) : CvarValue( g_cGoldForKill  ) );
	iNewGold[ 1 ] += ( IsHappyHour( ) ? ( iNewGold[ 0 ] * 2 ) : iNewGold[ 0 ] );
	
	set_dhudmessage( 0, 255, 255, -1.0, 0.3, 0, 6.0, 3.0 )
	show_dhudmessage( iAttacker, "%L^n%L", iAttacker, "ML_NEW_XP", iNewXp[ 1 ], iAttacker, "ML_NEW_GOLD", iNewGold[ 1 ] );
		
	g_iPlayerInfo[ iAttacker ][ g_iXp ] += iNewXp[ 1 ];
	g_iPlayerInfo[ iAttacker ][ g_iGold ] += iNewGold[ 1 ];
	
	CheckLevel( iAttacker );
	
	if( !g_iPlayerInfo[ iAttacker ][ g_iPerk ] )
		GivePerk( iAttacker, random_num( 1, g_iRegisteredPerks ) );
		
	new iResult;
	ExecuteForward( g_fwForwards[ g_fwCodDeath ], iResult, iAttacker, iVictim, iHs );
}

#if defined DEATH_MATCH_ENABLED
public Respawn( iPlayer ) {
	if( !is_user_connected( iPlayer ) )
		return;
		
	ExecuteHamB( Ham_CS_RoundRespawn, iPlayer );
	
	if( iPlayer >= 1 && iPlayer <= g_iMaxPlayers )
		cs_set_user_team( iPlayer, CsTeams: g_iPlayerInfo[ iPlayer ][ g_iTeam ] );
}
#endif

public CheckLevel( iPlayer ) {
	if( !is_user_connected( iPlayer ) || !g_iPlayerInfo[ iPlayer ][ g_iClass ] )
		return;
	
	SaveGold( iPlayer );
	
	new iOldLevel = g_iPlayerInfo[ iPlayer ][ g_iLevel ];
	
	if( iOldLevel >= 2001 ) {
		g_iPlayerInfo[ iPlayer ][ g_iLevel ] = 2001;
		return;
	}
		
	while( ( g_iPlayerInfo[ iPlayer ][ g_iXp ] >= g_iLevelXP[ g_iPlayerInfo[ iPlayer ][ g_iLevel ] ] ) && ( g_iPlayerInfo[ iPlayer ][ g_iLevel ] < 2001 ) )
		g_iPlayerInfo[ iPlayer ][ g_iLevel ] ++;
		
	if( iOldLevel < g_iPlayerInfo[ iPlayer ][ g_iLevel ] ) {
		set_dhudmessage( 0, 255, 255, -1.0, 0.2, 0, 6.0, 3.0 )
		show_dhudmessage( iPlayer, "%L", iPlayer, "ML_LEVEL_UP_HUD", g_iPlayerInfo[ iPlayer ][ g_iLevel ] );
		
		new iResult;
		ExecuteForward( g_fwForwards[ g_fwCodLevelUp ], iResult, iPlayer, iOldLevel, g_iPlayerInfo[ iPlayer ][ g_iLevel ] );
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_LEVEL_UP_CHAT", g_iPlayerInfo[ iPlayer ][ g_iLevel ] );
		
		client_cmd( iPlayer, "spk ByM_Cod/levelup" );
	}
	
	g_iPlayerInfo[ iPlayer ][ g_iPoints ] = ( ( g_iPlayerInfo[ iPlayer ][ g_iLevel ] - 1 ) * 2 - g_iPlayerInfo[ iPlayer ][ g_iEnergy ] - g_iPlayerInfo[ iPlayer ][ g_iResistance ] - g_iPlayerInfo[ iPlayer ][ g_iStamina ] - g_iPlayerInfo[ iPlayer ][ g_iDamage ] );
	SaveData( iPlayer );
}

public fw_HamPlayerTouchPre( iEntity, iPlayer ) {
	if( !is_user_connected( iPlayer ) || !is_user_alive( iPlayer ) ) 
		return HAM_IGNORED;
	
	set_pdata_int( iPlayer, 361, ( 1 << 3 ) );
	
	static szModel[ 23 ];
	entity_get_string( iEntity, EV_SZ_model, szModel, charsmax( szModel ) );
	
	if( entity_get_edict( iEntity, EV_ENT_owner ) == iPlayer || containi( szModel, "w_backpack" ) != -1 || g_iPlayerInfo[ iPlayer ][ g_iAllowWeaponPickup ] )
		return HAM_IGNORED;
	
	return HAM_SUPERCEDE;
}

public fw_HamItemPreFramePost( iPlayer ) {
	if( !is_user_connected( iPlayer ) || !is_user_connected( iPlayer ) || !g_iPlayerInfo[ iPlayer ][ g_iClass ] || g_bFreezeTime )
		return HAM_IGNORED;
	
	set_user_maxspeed( iPlayer, g_fPlayerInfo[ iPlayer ][ g_fSpeed ] );
	return HAM_IGNORED;
}

public GivePerk( iPlayer, iPerkId ) {
	if( !g_iRegisteredPerks )
		return;
		
	new iOldPerk = g_iPlayerInfo[ iPlayer ][ g_iPerk ];
	
	DeletePerk( iPlayer );
	
	new iResult[ 2 ];
	ExecuteForward( g_fwForwards[ g_fwPerkGot ], iResult[ 0 ], iPlayer, iPerkId );
	ExecuteForward( g_fwForwards[ g_fwPerkChanged ], iResult[ 1 ], iPlayer, iOldPerk, iPerkId );
	
	if( iResult[ 0 ] == 5 || iResult[ 1 ] == 5 ) {
		GivePerk( iPlayer, random_num( 1, g_iRegisteredPerks ) );
		return;
	}
	
	if( IsPerkBlocked( g_iPlayerInfo[ iPlayer ][ g_iClass ], iPerkId ) ) {
		GivePerk( iPlayer, random_num( 1, g_iRegisteredPerks ) );
		return;
	}
		
	g_iPlayerInfo[ iPlayer ][ g_iPerk ] = iPerkId;
	PrintToChat( iPlayer, "!g[CoD:Mw] !n%L: !g%L", iPlayer, "ML_YOU_HAVE_GOT", iPlayer, g_PerkData[ iPerkId ][ g_szPerkName ] ); 
}

public fw_CurrentWeapon( iPlayer ) {
	if( !is_user_connected( iPlayer ) || !is_user_alive( iPlayer ) )
		return;

	GiveAmmo( iPlayer );
}

public fw_NewRound( ) {
	g_bFreezeTime = true;
}

public fw_RoundStart( ) {
	g_bFreezeTime = false;
	
	for( new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer ++ ) {
		if( !is_user_connected( iPlayer ) )
			continue;
		
		client_cmd( iPlayer, "mp3 play %s", g_szStartSounds[ random_num( 0, sizeof( g_szStartSounds ) - 1 ) ] );
	}
}

public fw_ResetHud( iPlayer ) {
	set_pdata_int( iPlayer, 361, ( 1 << 3 ) );
}

public bomb_defused( iPlayer )
	fw_BombDefused( iPlayer );
	
public bomb_planted( iPlayer )
	fw_BombPlanted( iPlayer );

public fw_BombDefused( iPlayer ) {
	if( !is_user_connected( iPlayer ) || !is_user_alive( iPlayer ) || !g_iPlayerInfo[ iPlayer ][ g_iClass ] )
		return;
	
	new iNewXp, iNewGold;
	iNewXp = ( IsHappyHour( ) ? ( CvarValue( g_cXpForC4 ) * 2 ) : CvarValue( g_cXpForC4 ) );
	iNewGold = ( IsHappyHour( ) ? ( CvarValue( g_cGoldForC4 ) * 2 ) : CvarValue( g_cGoldForC4 ) );
	
	g_iPlayerInfo[ iPlayer ][ g_iXp ] += iNewXp;
	g_iPlayerInfo[ iPlayer ][ g_iGold ] += iNewGold;
	CheckLevel( iPlayer );
	
	PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_C4_DEFUSED", iNewXp, iNewGold );
	if( ( iNewXp / 2 ) == 1 || ( iNewXp / 2 ) == 0 )
		return;
			
	ForEachPlayer( i ) {
		if( i == iPlayer )
			continue;
		
		if( !is_user_alive( i ) || !g_iPlayerInfo[ i ][ g_iClass ] || get_user_team( i ) != get_user_team( iPlayer ) )
			continue;
			
		g_iPlayerInfo[ i ][ g_iXp ] += ( iNewXp / 2 );
		PrintToChat( i, "!g[CoD:Mw] !n%L", i, "ML_C4_DEFUSED_TEAM", ( iNewXp / 2 ) );
		CheckLevel( i );
	}
}

public fw_BombPlanted( iPlayer ) {
	if( !is_user_connected( iPlayer ) || !is_user_alive( iPlayer ) || !g_iPlayerInfo[ iPlayer ][ g_iClass ] )
		return;
		
	new iNewXp, iNewGold;
	iNewXp = ( IsHappyHour( ) ? ( CvarValue( g_cXpForC4 ) * 2 ) : CvarValue( g_cXpForC4 ) );
	iNewGold = ( IsHappyHour( ) ? ( CvarValue( g_cGoldForC4 ) * 2 ) : CvarValue( g_cGoldForC4 ) );
	
	g_iPlayerInfo[ iPlayer ][ g_iXp ] += iNewXp;
	g_iPlayerInfo[ iPlayer ][ g_iGold ] += iNewGold;
	CheckLevel( iPlayer );
	
	PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_C4_PLANTED", iNewXp, iNewGold );
	if( ( iNewXp / 2 ) == 1 || ( iNewXp / 2 ) == 0 )
		return;
		
	ForEachPlayer( i ) {
		if( i == iPlayer )
			continue;
		
		if( !is_user_alive( i ) || !g_iPlayerInfo[ i ][ g_iClass ] || get_user_team( i ) != get_user_team( iPlayer ) )
			continue;
			
		g_iPlayerInfo[ i ][ g_iXp ] += ( iNewXp / 2 );
		PrintToChat( i, "!g[CoD:Mw] !n%L", i, "ML_C4_PLANTED_TEAM", ( iNewXp / 2 ) );
		CheckLevel( i );
	}
}

public fw_RoundEnd( iMessageId, iMessageDestination, iMessageEntity ) {
	new szMessage[ 36 ];
	get_msg_arg_string( 2, szMessage, charsmax( szMessage ) );
	
	if( equal( szMessage, "#Terrorists_Win" ) ) {
		set_dhudmessage( 255, 0, 0, -1.0, 0.25, 0, 6.0, 3.0 );
		show_dhudmessage( 0, "Terrorist Win!" );
		
		RoundWon( 1 );
		
		set_msg_arg_string( 2, "" );
		return PLUGIN_HANDLED;
	}
	else if( equal( szMessage, "#CTs_Win" ) || equal( szMessage, "#Target_Saved" ) ) {
		set_dhudmessage( 0, 0, 255, -1.0, 0.25, 0, 6.0, 3.0 );
		show_dhudmessage( 0, "Counter-Terrorists Win!" );
		
		RoundWon( 2 );
		
		set_msg_arg_string( 2, "" );
		return PLUGIN_HANDLED;
	}
		
	return PLUGIN_HANDLED
}

public RoundWon( iTeam ) {
	new iNewXp = ( IsHappyHour( ) ? ( CvarValue( g_cRoundWinXp ) * 2 ) : CvarValue( g_cRoundWinXp ) );
	
	ForEachPlayer( iPlayer ) {
		if( get_user_team( iPlayer ) != iTeam || !is_user_connected( iPlayer ) || !is_user_alive( iPlayer ) )
			continue;
			
		g_iPlayerInfo[ iPlayer ][ g_iXp ] += iNewXp;
		CheckLevel( iPlayer );
		
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_ROUND_WIN_XP", g_cRoundWinXp );
	}
}

public fw_StatusIcon( iMessageId, iMessageDestination, iPlayer ) {
	if( is_user_alive( iPlayer ) ) {
		static szMessage[ 8 ];
		get_msg_arg_string( 2, szMessage, charsmax( szMessage ) );
		
		if( equal( szMessage, "buyzone" ) ) {
			set_pdata_int( iPlayer, 268, get_pdata_int( iPlayer, 268 ) & ~( 1 << 0 ) );
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public fw_EventHealth( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	if( entity_get_float( iPlayer, EV_FL_health ) > 1000.0 ) {
		entity_set_float( iPlayer, EV_FL_health, 1000.0 );
		return;
	}
}

public fw_ChatPrefix( iPlayer ) {
	if( !is_user_connected( iPlayer ) || !( 1 <= iPlayer <= g_iMaxPlayers ) )
		return 2;
		
	static szSaid[ 191 ];
	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	
	static szMessage[ 191 ], szRank[ 64 ], iPlayers;

	if( !szSaid[ 0 ] || szSaid[ 0 ] == '/' )
		return 2;
		
	if( containi( szSaid, "[MILF AntiReklama]" ) != -1 )
		return 2;
		
	if( szSaid[ 0 ] == '@' ) {
		replace_all( szSaid, charsmax( szSaid ), "@", "" );
		
		if( strlen( szSaid ) <= 0 )
			return 2;
		
		for( iPlayers = 1; iPlayers <= g_iMaxPlayers; iPlayers ++ ) {
			if( !is_user_connected( iPlayers ) || !( 1 <= iPlayers <= g_iMaxPlayers ) )
				continue;
				
			if( !( get_user_flags( iPlayers ) & ADMIN_RESERVATION ) )
				continue;
				
			formatex( szMessage, charsmax( szMessage ), "%s%s ^4adminima ^1: ^4%s", ( get_user_flags( iPlayer ) & ADMIN_RESERVATION ) ? "^4" : "^3", g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
			
			DisplayMessage( szMessage, iPlayer, iPlayers );
		}
		
		if( !( get_user_flags( iPlayer ) & ADMIN_RESERVATION ) ) DisplayMessage( szMessage, iPlayer, iPlayer );
		PrintToChat( iPlayer, "^4%L", iPlayer, "ML_MESSAGE_SENT_TO_ADMINS" );
		return 2;
	}
	
	for( iPlayers = 1; iPlayers <= g_iMaxPlayers; iPlayers ++ ) {
		if( !is_user_connected( iPlayers ) )
			continue;
			
		if( is_user_admin( iPlayer ) ) {
			if( get_user_flags( iPlayer ) & ADMIN_RCON )
				formatex( szRank, charsmax( szRank ), "%L", iPlayers, "ML_OWNER" );
			else if( get_user_flags( iPlayer ) & ADMIN_LEVEL_C )
				formatex( szRank, charsmax( szRank ), "%L", iPlayers, "ML_HEAD" );
			else if( get_user_flags( iPlayer ) & ADMIN_KICK )
				formatex( szRank, charsmax( szRank ), "%L", iPlayers, "ML_O_ADMIN" );
				
			if( cod_is_vip( iPlayer ) )
				formatex( szMessage, charsmax( szMessage ), "^3[%s]^4[VIP][%L - %d] ^3%s ^1: %s", szRank, iPlayers, g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
			else formatex( szMessage, charsmax( szMessage ), "^3[%s]^4[%L - %d] ^3%s ^1: %s", szRank, iPlayers, g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
		} else {
			if( cod_is_vip( iPlayer ) )
				formatex( szMessage, charsmax( szMessage ), "^4[VIP][%L - %d] ^3%s ^1: %s", iPlayers, g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
			else formatex( szMessage, charsmax( szMessage ), "^4[%L - %d] ^3%s ^1: %s", iPlayers, g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
		}
		
		DisplayMessage( szMessage, iPlayer, iPlayers );
	}
	
	return 2;
}

public fw_ChatPrefixTeam( iPlayer ) {
	if( !is_user_connected( iPlayer ) || !( 1 <= iPlayer <= g_iMaxPlayers ) )
		return 2;
		
	static szSaid[ 191 ];
	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	
	static szMessage[ 191 ], szRank[ 64 ], iPlayers;

	if( !szSaid[ 0 ] || szSaid[ 0 ] == '/' )
		return 2;
		
	if( containi( szSaid, "[MILF AntiReklama]" ) != -1 )
		return 2;
		
	if( szSaid[ 0 ] == '@' ) {
		replace_all( szSaid, charsmax( szSaid ), "@", "" );
		
		if( strlen( szSaid ) <= 0 )
			return 2;
		
		for( iPlayers = 1; iPlayers <= g_iMaxPlayers; iPlayers ++ ) {
			if( !is_user_connected( iPlayers ) || !( 1 <= iPlayers <= g_iMaxPlayers ) )
				continue;
				
			if( !( get_user_flags( iPlayers ) & ADMIN_RESERVATION ) )
				continue;
				
			formatex( szMessage, charsmax( szMessage ), "%s%s ^4adminima ^1: ^4%s", ( get_user_flags( iPlayer ) & ADMIN_RESERVATION ) ? "^4" : "^3", g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
			
			DisplayMessage( szMessage, iPlayer, iPlayers );
		}
		
		if( !( get_user_flags( iPlayer ) & ADMIN_RESERVATION ) ) DisplayMessage( szMessage, iPlayer, iPlayer );
		PrintToChat( iPlayer, "^4%L", iPlayer, "ML_MESSAGE_SENT_TO_ADMINS" );
		return 2;
	}
	
	for( iPlayers = 1; iPlayers <= g_iMaxPlayers; iPlayers ++ ) {
		if( !is_user_connected( iPlayers ) )
			continue;
			
		if( is_user_admin( iPlayer ) ) {
			if( get_user_flags( iPlayer ) & ADMIN_RCON )
				formatex( szRank, charsmax( szRank ), "%L", iPlayers, "ML_OWNER" );
			else if( get_user_flags( iPlayer ) & ADMIN_LEVEL_C )
				formatex( szRank, charsmax( szRank ), "%L", iPlayers, "ML_HEAD" );
			else if( get_user_flags( iPlayer ) & ADMIN_KICK )
				formatex( szRank, charsmax( szRank ), "%L", iPlayers, "ML_O_ADMIN" );
				
			if( cod_is_vip( iPlayer ) )
				formatex( szMessage, charsmax( szMessage ), "^3[%s]^4[VIP][%L - %d] ^3%s ^1: %s", szRank, iPlayers, g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
			else formatex( szMessage, charsmax( szMessage ), "^3[%s]^4[%L - %d] ^3%s ^1: %s", szRank, iPlayers, g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
		} else {
			if( cod_is_vip( iPlayer ) )
				formatex( szMessage, charsmax( szMessage ), "^4[VIP][%L - %d] ^3%s ^1: %s", iPlayers, g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
			else formatex( szMessage, charsmax( szMessage ), "^4[%L - %d] ^3%s ^1: %s", iPlayers, g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_szPlayerInfo[ iPlayer ][ g_szName ], szSaid );
		}
		
		DisplayMessage( szMessage, iPlayer, iPlayers );
	}
	
	return 2;
}

DisplayMessage( const szMessage_[ ], const iPlayer_, const i_ ) {
	message_begin( MSG_ONE, g_iMessageChat, { 0, 0, 0 }, i_ );
	write_byte( iPlayer_ );
	write_string( szMessage_ );
	message_end( );
}

public client_infochanged( iPlayer ) {
	new szName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
	
	if( !equal( g_szPlayerInfo[ iPlayer ][ g_szName ], szName ) )
		copy( g_szPlayerInfo[ iPlayer ][ g_szName ], charsmax( g_szPlayerInfo[ ][ g_szName ] ), szName );
}

//=================================================================================================
//				Clearing, loading and saving data
//=================================================================================================
public client_connect( iPlayer ) {
	DeletePlayerData( iPlayer );
}

public client_authorized( iPlayer ) {
	get_user_authid( iPlayer, g_szPlayerInfo[ iPlayer ][ g_szSteamID ],  charsmax( g_szPlayerInfo[ ][ g_szSteamID ] ) );
	get_user_name( iPlayer, g_szPlayerInfo[ iPlayer ][ g_szName ],  charsmax( g_szPlayerInfo[ ][ g_szName ] ) );
	get_user_ip( iPlayer, g_szPlayerInfo[ iPlayer ][ g_szIp ],  charsmax( g_szPlayerInfo[ ][ g_szIp ] ), 1 );

	LoadGold( iPlayer );
	g_iPlayerInfo[ iPlayer ][ g_iLevel ] = 1;
}

public client_disconnect( iPlayer ) {
	SaveData( iPlayer );
	SaveGold( iPlayer );
	DeletePlayerData( iPlayer );
}

DeletePlayerData( iPlayer ) {
	for( new i = 0; i < StructIntPlayerInfo; i++ )
		g_iPlayerInfo[ iPlayer ][ i ] = 0;
}

DeletePerk( iPlayer ) {
	g_iPlayerInfo[ iPlayer ][ g_iPerk ] = 0;
	
	if( is_user_alive( iPlayer ) ) {
		set_user_rendering( iPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255 );
		set_user_footsteps( iPlayer, 0 );
		set_user_noclip( iPlayer, 0 );
		set_user_godmode( iPlayer, 0 );
	}
}

public SaveGold( iPlayer ) {
	//if( is_user_bot( iPlayer ) ) 
	//	return;
		
	new szKey[ 64 ], szData[ 12 ];
	formatex( szKey, charsmax( szKey ), "%s-gold", g_szPlayerInfo[ iPlayer ][ g_szSteamID ] );
	num_to_str( g_iPlayerInfo[ iPlayer ][ g_iGold ], szData, charsmax( szData ) );
		
	nvault_set( g_iVault, szKey, szData );
}

public LoadGold( iPlayer ) {
	//if( is_user_bot( iPlayer ) ) 
	//	return;

	new szKey[ 64 ], szData[ 12 ];
	formatex( szKey, charsmax( szKey ), "%s-gold", g_szPlayerInfo[ iPlayer ][ g_szSteamID ] );
	nvault_get( g_iVault, szKey, szData, charsmax( szData ) );

	g_iPlayerInfo[ iPlayer ][ g_iGold ] = str_to_num( szData );
}

public SaveData( iPlayer ) {
	//if( is_user_bot( iPlayer ) || !g_iPlayerInfo[ iPlayer ][ g_iClass ] )
	if( !g_iPlayerInfo[ iPlayer ][ g_iClass ] ){
		return;
	}
		
	new szKey[ 96 ], szData[ 96 ];
	formatex( szKey, charsmax( szKey ), "%s-%s", g_szPlayerInfo[ iPlayer ][ g_szSteamID ], g_ClassData[ g_iPlayerInfo[ iPlayer ][ g_iClass ] ][ g_szClassName ] );
	formatex( szData, charsmax( szData ), "%i %i %i %i %i %i", g_iPlayerInfo[ iPlayer ][ g_iXp ], g_iPlayerInfo[ iPlayer ][ g_iLevel ], g_iPlayerInfo[ iPlayer ][ g_iEnergy ],
	g_iPlayerInfo[ iPlayer ][ g_iResistance ], g_iPlayerInfo[ iPlayer ][ g_iStamina ], g_iPlayerInfo[ iPlayer ][ g_iDamage ] );
		
	nvault_set( g_iVault, szKey, szData );
}
	
public LoadData( iPlayer, iClassId ) {
	//if( is_user_bot( iPlayer ) || !iClassId ){
	if( !iClassId ){
		return;
	}
		
	new szKey[ 96 ], szData[ 96 ], szDataPieces[ 6 ][ 10 ];
	formatex( szKey, charsmax( szKey ), "%s-%s", g_szPlayerInfo[ iPlayer ][ g_szSteamID ], g_ClassData[ iClassId ][ g_szClassName ] );
	nvault_get( g_iVault, szKey, szData, charsmax( szData ) );
		
	parse( szData, szDataPieces[ 0 ], charsmax( szDataPieces[ ] ), szDataPieces[ 1 ], charsmax( szDataPieces[ ] ), szDataPieces[ 2 ], charsmax( szDataPieces[ ] ),
	szDataPieces[ 3 ], charsmax( szDataPieces[ ] ), szDataPieces[ 4 ], charsmax( szDataPieces[ ] ), szDataPieces[ 5 ], charsmax( szDataPieces[ ] ) );
		
	g_iPlayerInfo[ iPlayer ][ g_iXp ] = str_to_num( szDataPieces[ 0 ] );
	g_iPlayerInfo[ iPlayer ][ g_iLevel ] =  str_to_num( szDataPieces[ 1 ] ) ? str_to_num( szDataPieces[ 1 ] ) : 1;
	g_iPlayerInfo[ iPlayer ][ g_iEnergy ] = str_to_num( szDataPieces[ 2 ] );
	g_iPlayerInfo[ iPlayer ][ g_iResistance ] = str_to_num( szDataPieces[ 3 ] );
	g_iPlayerInfo[ iPlayer ][ g_iStamina ] = str_to_num( szDataPieces[ 4 ] );
	g_iPlayerInfo[ iPlayer ][ g_iDamage ] = str_to_num( szDataPieces[ 5 ] );

	g_iPlayerInfo[ iPlayer ][ g_iPoints ] = ( ( g_iPlayerInfo[ iPlayer ][ g_iLevel ] - 1 ) * 2 - g_iPlayerInfo[ iPlayer ][ g_iEnergy ] - g_iPlayerInfo[ iPlayer ][ g_iResistance ] - g_iPlayerInfo[ iPlayer ][ g_iStamina ] - g_iPlayerInfo[ iPlayer ][ g_iDamage ] );
}

//=================================================================================================
//				Menus
//=================================================================================================
InitialiseMenus( ) {
	register_menucmd( register_menuid( "Class Description" ), 1023, "Class_Description_Handle" );
	register_menucmd( register_menuid( "Perk Description" ), 1023, "Perk_Description_Handle" );
}

public ChooseFaction( iPlayer ) {
	new szText[ 64 ];
	formatex( szText, charsmax( szText ), "\r%L\y:", iPlayer, "ML_CHOOSE_CLASS" );
	new iMenu = menu_create( szText, "ChooseFaction_Handle" );
	
	for( new i = 1; i <= g_iRegisteredClasses; i ++ ) {
		if( IsItInPrevious( g_ClassData[ i ][ g_szClassFaction ], i ) || ( g_ClassData[ i ][ g_szClassFaction ][ 0 ] == EOS ) )
			continue;
			
		formatex( szText, charsmax( szText ), "%L", iPlayer, g_ClassData[ i ][ g_szClassFaction ] );
		menu_additem( iMenu, szText, g_ClassData[ i ][ g_szClassFaction ] );
	}

	menu_display( iPlayer, iMenu );
	
	if( menu_items( iMenu ) <= 0 ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_NO_CLASSES" );
		return;
	}
}

public ChooseFaction_Handle( iPlayer, iOldMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iOldMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack;
	new szItemName[ 5 ], szData[ 64 ];
	menu_item_getinfo( iOldMenu, iItem, iAccess, szData, charsmax( szData ), szItemName, charsmax( szItemName ), iCallBack );
	
	new szText[ 96 ];
	formatex( szText, charsmax( szText ) / 2, "\r%L\y:", iPlayer, "ML_CHOOSE_CLASS" );
	new iMenu = menu_create( szText, "ChooseClass_Handle" );
	
	new szNumber[ 5 ];
	new iHasClass = 0;
	
	for( new i = 1; i <= g_iRegisteredClasses; i ++ ) {
		if( ( g_ClassData[ i ][ g_szClassName ][ 0 ] == EOS ) || !equal( g_ClassData[ i ][ g_szClassFaction ], szData ) )
			continue;
			
		LoadData( iPlayer, i );
		iHasClass = ( ( g_iPlayerInfo[ iPlayer ][ g_iClass ] == i ) ? 1 : 0 );
		
		num_to_str( i, szNumber, charsmax( szNumber ) );
		
		if( g_ClassData[ i ][ g_iClassPrice ] )
			formatex( szText, charsmax( szText ), "\y%L \d[\y%L: \r%d\d%L \y- \r%d \yBoost%s", iPlayer, g_ClassData[ i ][ g_szClassName ], iPlayer, "ML_LEVEL", g_iPlayerInfo[ iPlayer ][ g_iLevel ] < START_LEVEL ? START_LEVEL : g_iPlayerInfo[ iPlayer ][ g_iLevel ], iPlayer, iHasClass ? "ML_HAS_CLASS_BRACKET" : "ML_BRACKET", g_ClassData[ i ][ g_iClassPrice ], g_ClassData[ i ][ g_iClassPrice ] == 1 ? "" : "s"  );
		else formatex( szText, charsmax( szText ), "\y%L \d[\y%L: \r%d\d%L", iPlayer, g_ClassData[ i ][ g_szClassName ], iPlayer, "ML_LEVEL", g_iPlayerInfo[ iPlayer ][ g_iLevel ] < START_LEVEL ? START_LEVEL : g_iPlayerInfo[ iPlayer ][ g_iLevel ], iPlayer, iHasClass ? "ML_HAS_CLASS_BRACKET" : "ML_BRACKET" ); 
		
		menu_additem( iMenu, szText, szNumber );
	}
	
	LoadData( iPlayer, g_iPlayerInfo[ iPlayer ][ g_iClass ] );
	menu_display( iPlayer, iMenu );
	return PLUGIN_CONTINUE;
}

public ChooseClass_Handle( iPlayer, iOldMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	ScreenFade( iPlayer, 1 << 10, 1 << 10, 1 << 4, 0, 255, 255, 50 );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iOldMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack, iClassId;
	new szItemName[ 5 ], szData[ 5 ];
	menu_item_getinfo( iOldMenu, iItem, iAccess, szData, charsmax( szData ), szItemName, charsmax( szItemName ), iCallBack );
	iClassId = str_to_num( szData );
	
	if( iClassId == g_iPlayerInfo[ iPlayer ][ g_iClass ] ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_ALREADY_HAVE" );
		return PLUGIN_CONTINUE;
	}
	
	new iResult_, bool: bFree = false;
	ExecuteForward( g_fwForwards[ g_fwClassPreSelected ], iResult_, iPlayer, iClassId );
	
	if( iResult_ == 1 ) {
		if( strlen( g_ClassData[ iClassId ][ g_szClassFlag ] ) > 0 ) {
			if( g_ClassData[ iClassId ][ g_szClassFlag ][ 0 ] == '#' ) {
				if( !cod_is_vip( iPlayer ) ) {
					PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DO_NOT_HAVE_VIP_CLASS" );
					return PLUGIN_CONTINUE;
				} else goto SkipFlagCheck;
			} if( g_ClassData[ iClassId ][ g_szClassFlag ][ 0 ] == '$' ) {
				if( !IsSteamPlayer( iPlayer ) ) {
					PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DO_NOT_HAVE_STEAM_CLASS" );
					return PLUGIN_CONTINUE;
				} else goto SkipFlagCheck;
			} else {
				if( !bym_get_flag( iPlayer, bym_get_flag_int( g_ClassData[ iClassId ][ g_szClassFlag ] ) ) ) {
					PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DO_NOT_HAVE_CLASS" );
					return PLUGIN_CONTINUE;
				} else goto SkipFlagCheck;
			}
		} else bFree = true;
	}

	SkipFlagCheck:
	
	#if defined CLASS_STATISTICS_ENABLED
		if( bFree ) {
			new szValue[ 5 ];
			fvault_get_data( "ClassesStatistics", g_ClassData[ iClassId ][ g_szClassName ], szValue, charsmax( szValue ) );
			num_to_str( ( str_to_num( szValue ) + 1 ), szValue, charsmax( szValue ) );
			fvault_set_data( "ClassesStatistics", g_ClassData[ iClassId ][ g_szClassName ], szValue );
		}
	#endif
	
	if( g_iPlayerInfo[ iPlayer ][ g_iPerk ] ) {
		if( IsPerkBlocked( iClassId, g_iPlayerInfo[ iPlayer ][ g_iPerk ] ) ) 
			DeletePerk( iPlayer );
	}
	
	if( !g_iPlayerInfo[ iPlayer ][ g_iClass ] ) {
		new iResult;
		ExecuteForward( g_fwForwards[ g_fwClassSelected ], iResult, iPlayer, iClassId );
		
		#if defined DEATH_MATCH_ENABLED
			g_iPlayerInfo[ iPlayer ][ g_iClassChoosingProcess ] = 1;
		#endif
		
		g_iPlayerInfo[ iPlayer ][ g_iClass ] = iClassId;
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L !g%L", iPlayer, "ML_YOU_HAVE_CHOOSE", iPlayer, g_ClassData[ iClassId ][ g_szClassName ] );
		LoadData( iPlayer, iClassId );
		fw_HamPlayerSpawnPost( iPlayer );
	
		return PLUGIN_CONTINUE;
	} else {
		g_iPlayerInfo[ iPlayer ][ g_iNewClass ] = iClassId;
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_NEXT_ROUND" );
		
		return PLUGIN_CONTINUE;
	}
}

public FactionDescription( iPlayer ) {
	new szText[ 64 ];
	formatex( szText, charsmax( szText ) / 2, "\r%L:", iPlayer, "ML_CHOOSE_CLASS" );
	new iMenu = menu_create( szText, "FactionDescription_Handle" );
	
	for( new i = 1; i <= g_iRegisteredClasses; i ++ ) {
		if( IsItInPrevious( g_ClassData[ i ][ g_szClassFaction ], i ) || ( g_ClassData[ i ][ g_szClassFaction ][ 0 ] == EOS ) )
			continue;
		
		formatex( szText, charsmax( szText ), "%L", iPlayer, g_ClassData[ i ][ g_szClassFaction ] );
		menu_additem( iMenu, szText, g_ClassData[ i ][ g_szClassFaction ] );
	}
	
	menu_display( iPlayer, iMenu );
	
	if( menu_items( iMenu ) <= 0 ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_NO_CLASSES" );
		return;
	}
}

public FactionDescription_Handle( iPlayer, iOldMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iOldMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack;
	new szItemName[ 5 ], szData[ 64 ];
	menu_item_getinfo( iOldMenu, iItem, iAccess, szData, charsmax( szData ), szItemName, charsmax( szItemName ), iCallBack );
	
	new szText[ 64 ], szNumber[ 5 ];
	formatex( szText, charsmax( szText ), "\r%L:", iPlayer, "ML_CHOOSE_CLASS" );
	new iMenu = menu_create( szText, "ClassDescription_Handle" );
	
	for( new i = 1; i <= g_iRegisteredClasses; i ++ ) {
		if( !strlen( g_ClassData[ i ][ g_szClassName ] ) || !equal( g_ClassData[ i ][ g_szClassFaction ], szData ) )
			continue;
			
		num_to_str( i, szNumber, charsmax( szNumber ) );
		formatex( szText, charsmax( szText ), "\y%L", iPlayer, g_ClassData[ i ][ g_szClassName ] );
		menu_additem( iMenu, szText, szNumber );
	}
	
	menu_display( iPlayer, iMenu );
	return PLUGIN_CONTINUE;
}

public ClassDescription_Handle( iPlayer, iOldMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iOldMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack, iClassId;
	new szItemName[ 5 ], szData[ 5 ];
	menu_item_getinfo( iOldMenu, iItem, iAccess, szData, charsmax( szData ), szItemName, charsmax( szItemName ), iCallBack );
	iClassId = str_to_num( szData );
	
	new szClassWeapons[ 96 ];
	copy( szClassWeapons, charsmax( szClassWeapons ), g_ClassData[ iClassId ][ g_szClassWeapons ] );
	replace_all( szClassWeapons, charsmax( szClassWeapons ), ":", ", " );
	replace_all( szClassWeapons, charsmax( szClassWeapons ), ">", "" );
	strtoupper( szClassWeapons );
	
	new szDescription[ 2048 ];
	formatex( szDescription, charsmax( szDescription ), "\r%L: \y%L^n%L^n%L^n%s", iPlayer, "ML_CLASS", iPlayer,  g_ClassData[ iClassId ][ g_szClassName ], iPlayer, "ML_CLASS_DESC",
	g_ClassData[ iClassId ][ g_iClassHp ], g_ClassData[ iClassId ][ g_iClassArmor ], ( floatround( str_to_float( g_ClassData[ iClassId ][ g_szClassSpeed ] ) * 100 ) ), g_ClassData[ iClassId ][ g_iClassVisibility ], szClassWeapons, iPlayer, g_ClassData[ iClassId ][ g_szClassDescription ], "Cod mod by Miluitnke (ByM)" );
	
	show_menu( iPlayer, 1023, szDescription, -1, "Class Description" );
	
	return PLUGIN_CONTINUE;
}

public ChoosePerkOption( iPlayer ) {
	new szText[ 64 ];
	formatex( szText, charsmax( szText ), "\r%L:", iPlayer, "ML_CHOOSE_PERK_OPTION" );
	new iMenu = menu_create( szText, "Handle_ChoosePerkOption" );
	
	formatex( szText, charsmax( szText ), "%L", iPlayer, "ML_YOUR_PERK_DESC" );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "%L", iPlayer, "ML_LIST_PERK_DESC" );
	menu_additem( iMenu, szText );
	
	menu_display( iPlayer, iMenu );
}

public Handle_ChoosePerkOption( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	switch( iItem ) {
		case 0: {
			if( !g_iPlayerInfo[ iPlayer ][ g_iPerk ] ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_DO_NOT_HAVE_PERK" );
				return PLUGIN_CONTINUE;
			}
			
			new szDescription[ 1024 ];
			new iPerkId = g_iPlayerInfo[ iPlayer ][ g_iPerk ];
	
			formatex( szDescription, charsmax( szDescription ), "\r%L: \y%L^n\r%L: \y%L^n%s", iPlayer, "ML_PERK", iPlayer,  g_PerkData[ iPerkId ][ g_szPerkName ], iPlayer, "ML_PERKS_DESCRIPTION", iPlayer, g_PerkData[ iPerkId ][ g_szPerkDescription ], "Cod Mod By Milutinke (ByM)" );
			show_menu( iPlayer, 1023, szDescription, -1, "Your Perk Description" );
		}
		
		case 1: ChoosePerk( iPlayer );
	}
	
	return PLUGIN_CONTINUE;
}

public ChoosePerk( iPlayer ) {
	new szText[ 64 ];
	formatex( szText, charsmax( szText ), "\r%L:", iPlayer, "ML_CHOOSE_PERK" );
	new iMenu = menu_create( szText, "Handle_ChoosePerk" );
	new szNumber[ 5 ];
	
	for( new i = 1; i <= g_iRegisteredPerks; i ++ ) {
		formatex( szText, charsmax( szText ), "\y%L", iPlayer, g_PerkData[ i ][ g_szPerkName ] );
		num_to_str( i, szNumber, charsmax( szNumber ) );
		menu_additem( iMenu, szText, szNumber );
	}
	
	menu_display( iPlayer, iMenu );
}

public Handle_ChoosePerk( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack, iPerkId;
	new szItemName[ 5 ], szData[ 5 ];
	menu_item_getinfo( iMenu, iItem, iAccess, szData, charsmax( szData ), szItemName, charsmax( szItemName ), iCallBack );
	iPerkId = str_to_num( szData );
	
	new szDescription[ 1024 ];
	formatex( szDescription, charsmax( szDescription ), "\r%L: \y%L^n\r%L: \y%L", iPlayer, "ML_PERK", iPlayer,  g_PerkData[ iPerkId ][ g_szPerkName ], iPlayer, "ML_PERKS_DESCRIPTION", iPlayer, g_PerkData[ iPerkId ][ g_szPerkDescription ] );
	show_menu( iPlayer, 1023, szDescription, -1, "Perk Description" );
	
	return PLUGIN_CONTINUE;
}

public Class_Description_Handle( iPlayer, iKey ) {
	FactionDescription( iPlayer );
}

public Perk_Description_Handle( iPlayer, iKey ) {
	ChoosePerk( iPlayer );
}

public DescriptionMenu( iPlayer ) {
	new szText[ 64 ];
	formatex( szText, charsmax( szText ), "\r%L:", iPlayer, "ML_DESCRIPTION" );
	new iMenu = menu_create( szText, "Handle_DescriptionMenu" );
	
	formatex( szText, charsmax( szText ), "\y%L", iPlayer, "ML_CLASSES_DESCRIPTION" );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "\y%L", iPlayer, "ML_PERKS_DESCRIPTION" );
	menu_additem( iMenu, szText );

	menu_display( iPlayer, iMenu );
}

public Handle_DescriptionMenu( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	switch( iItem ) {
		case 0: FactionDescription( iPlayer );
		case 1: ChoosePerkOption( iPlayer );
	}
	
	return PLUGIN_CONTINUE;
}

public UsePoints( iPlayer ) {
	new szText[ 86 ];
	formatex( szText, charsmax( szText ), "\r%L \d[\y%i\d] \w:", iPlayer, "ML_USE_POINTS", g_iPlayerInfo[ iPlayer ][ g_iPoints ] );
	new iMenu = menu_create( szText, "Handle_UsePoints" );
	
	formatex( szText, charsmax( szText ), "\y%L \w: \d[ \r%d \y/ \r%d \d]", iPlayer, "ML_ENERGY", g_iPlayerInfo[ iPlayer ][ g_iEnergy ], iMaxEnergy );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "\y%L \w: \d[ \r%d \y/ \r%d \d]", iPlayer, "ML_RESISTANCE", g_iPlayerInfo[ iPlayer ][ g_iResistance ], iMaxResisance );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "\y%L \w: \d[ \r%d \y/ \r%d \d]", iPlayer, "ML_STAMINA", g_iPlayerInfo[ iPlayer ][ g_iStamina ], iMaxStamina );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "\y%L \w: \d[ \r%d \y/ \r%d \d]^n", iPlayer, "ML_DAMAGE", g_iPlayerInfo[ iPlayer ][ g_iDamage ], iMaxDamage );
	menu_additem( iMenu, szText );

	formatex( szText, charsmax( szText ), "\y%L \w: \r[ \y%s \r]", iPlayer, "ML_NUMBER_OF_POINTS", g_szAddPointsNumber[ g_iPlayerInfo[ iPlayer ][ g_iAddNumber ] ] );
	menu_additem( iMenu, szText );
	
	menu_display( iPlayer, iMenu );
}

public Handle_UsePoints( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) { 
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	if( g_iPlayerInfo[ iPlayer ][ g_iPoints ] < 1 )
		return PLUGIN_CONTINUE;
	
	new iNumberForAdding = 0;
	
	if( g_iAddPointsNumber[ g_iPlayerInfo[ iPlayer ][ g_iAddNumber ] ] == -1 )
		iNumberForAdding = g_iPlayerInfo[ iPlayer ][ g_iPoints ];
	else 
		iNumberForAdding = ( g_iAddPointsNumber[ g_iPlayerInfo[ iPlayer ][ g_iAddNumber ] ] > g_iPlayerInfo[ iPlayer ][ g_iPoints ] ) ? g_iPlayerInfo[ iPlayer ][ g_iPoints ] : g_iAddPointsNumber[ g_iPlayerInfo[ iPlayer ][ g_iAddNumber ] ];

	switch( iItem ) {
		case 0: {
			if( g_iPlayerInfo[ iPlayer ][ g_iEnergy ] < iMaxEnergy ) {
				if( iNumberForAdding > iMaxEnergy - g_iPlayerInfo[ iPlayer ][ g_iEnergy ] )
					iNumberForAdding = iMaxEnergy - g_iPlayerInfo[ iPlayer ][ g_iEnergy ];

				g_iPlayerInfo[ iPlayer ][ g_iEnergy ] += iNumberForAdding;
				g_iPlayerInfo[ iPlayer ][ g_iPoints ] -= iNumberForAdding;
			} 
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_MAX_ENERGY" );
		}

		case 1: {
			if( g_iPlayerInfo[ iPlayer ][ g_iResistance ] < iMaxResisance ) {
				if( iNumberForAdding > iMaxResisance - g_iPlayerInfo[ iPlayer ][ g_iResistance ] )
					iNumberForAdding = iMaxResisance - g_iPlayerInfo[ iPlayer ][ g_iResistance ];
				
				g_iPlayerInfo[ iPlayer ][ g_iResistance ] += iNumberForAdding;
				g_iPlayerInfo[ iPlayer ][ g_iPoints ] -= iNumberForAdding;
			} 
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_MAX_RESISTANCE" );
		}

		case 2: {
			if( g_iPlayerInfo[ iPlayer ][ g_iStamina ] < iMaxStamina ) {
				if( iNumberForAdding > iMaxStamina - g_iPlayerInfo[ iPlayer ][ g_iStamina ] )
					iNumberForAdding = iMaxStamina - g_iPlayerInfo[ iPlayer ][ g_iStamina ];
				
				g_iPlayerInfo[ iPlayer ][ g_iStamina ] += iNumberForAdding;
				g_iPlayerInfo[ iPlayer ][ g_iPoints ] -= iNumberForAdding;
			} 
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_MAX_STAMINA" );
		}

		case 3: {
			if( g_iPlayerInfo[ iPlayer ][ g_iDamage ] < iMaxDamage ) {
				
				if( iNumberForAdding > iMaxDamage - g_iPlayerInfo[ iPlayer ][ g_iDamage ] )
					iNumberForAdding = iMaxDamage - g_iPlayerInfo[ iPlayer ][ g_iDamage ];
				
				g_iPlayerInfo[ iPlayer ][ g_iDamage ] += iNumberForAdding;
				g_iPlayerInfo[ iPlayer ][ g_iPoints ] -= iNumberForAdding;
			} 
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_MAX_DAMAGE" );
		}

		case 4: {
			if( g_iPlayerInfo[ iPlayer ][ g_iAddNumber ] < charsmax( g_iAddPointsNumber ) ) 
				g_iPlayerInfo[ iPlayer ][ g_iAddNumber ] ++;
			else g_iPlayerInfo[ iPlayer ][ g_iAddNumber ] = 0;
		}
	}
	
	if( g_iPlayerInfo[ iPlayer ][ g_iPoints ] > 0 )
		UsePoints( iPlayer );
	
	SaveData( iPlayer );
	return PLUGIN_CONTINUE;
}


public OpenModMenuN( iPlayer ) {
	ModMenu( iPlayer );
	return PLUGIN_HANDLED;
}

public OpenModMenu( iPlayer ) {
	if( cs_get_user_team( iPlayer ) == CS_TEAM_SPECTATOR || cs_get_user_team( iPlayer ) == CS_TEAM_UNASSIGNED )
		return PLUGIN_CONTINUE;
	
	ModMenu( iPlayer );
	return PLUGIN_HANDLED;
}

public ModMenu( iPlayer ) {
	new szText[ 64 ];
	formatex( szText, charsmax( szText ), "%L", iPlayer, "ML_MOD_MENU" );
	
	new iMenu = menu_create( szText, "ModMenu_Handle" );
	for( new i = 0; i < sizeof( g_szModMenu ); i ++ ) {
		formatex( szText, charsmax( szText ), "%L", iPlayer, g_szModMenu[ i ] );
		menu_additem( iMenu, szText );
	}
	
	menu_display( iPlayer, iMenu );
}

public ModMenu_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	ScreenFade( iPlayer, 1 << 10, 1 << 10, 1 << 4, 0, 255, 255, 50 );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	switch( iItem ) {
		case 0: ChooseFaction( iPlayer );
		case 1: client_cmd( iPlayer, "say /shop" );
		case 2: ChooseTeam( iPlayer ); 
		case 3: DescriptionMenu( iPlayer );
		case 4: client_cmd( iPlayer, "say /htbs" );
		case 5: client_cmd( iPlayer, "say /codadmin" );
		case 6: client_cmd( iPlayer, "say /adminm" );
	}
	
	return PLUGIN_CONTINUE;
}

public ChooseTeam( iPlayer ) {
	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\r%L \w:", iPlayer, "ML_CHOOSE_TEAM" );
	new iMenu = menu_create( szText, "ChooseTeam_Handle" );
	
	for( new iIterator = 0; iIterator < sizeof( g_szTeamMenuData ); iIterator ++ )
		menu_additem( iMenu, g_szTeamMenuData[ iIterator ][ 0 ] );
	
	menu_display( iPlayer, iMenu );
}

public ChooseTeam_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	ScreenFade( iPlayer, 1 << 10, 1 << 10, 1 << 4, 0, 255, 255, 50 );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	new CsTeams: iTeam = cs_get_user_team( iPlayer );
	
	switch( iItem ) {
		case 0: {
			if( iTeam != CS_TEAM_T )
				cs_set_user_team( iPlayer, CS_TEAM_T );
		}
		case 1: {
			if( iTeam != CS_TEAM_CT )
				cs_set_user_team( iPlayer, CS_TEAM_CT );
		}
		case 2: {
			if( iTeam != CS_TEAM_SPECTATOR )
				cs_set_user_team( iPlayer, CS_TEAM_SPECTATOR );
		}
	}
	
	if( is_user_alive( iPlayer ) )
		user_kill( iPlayer );
	
	return PLUGIN_CONTINUE;
}

public Shop( iPlayer ) {
	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "%s\r%L:", cod_is_vip( iPlayer ) ? "\d[\rVIP\d] " : "", iPlayer, "ML_SHOP" );
	new iMenu = menu_create( szText, "Shop_Handle" );
	
	for( new iIterator = 0; iIterator < sizeof( g_szShop ); iIterator ++ ) {
		formatex( szText, charsmax( szText ), "%s\y%L", cod_is_vip( iPlayer ) ? "\d[\rVIP\d] " : "", iPlayer, g_szShop[ iIterator ] );
		menu_additem( iMenu, szText );
	}

	menu_display( iPlayer, iMenu );
}

public Shop_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	switch( iItem ) {
		case 0: OrdinaryShop( iPlayer );
		case 1: PerkShop( iPlayer );
	}
	
	return PLUGIN_CONTINUE;
}

public OrdinaryShop( iPlayer ) {
	new szText[ 96 ];
	formatex( szText, charsmax( szText ), "%s\r%L:", cod_is_vip( iPlayer ) ? "\d[\rVIP\d] " : "", iPlayer, "ML_ORDINARY_SHOP" );
	new iMenu = menu_create( szText, "OrdinaryShop_Handle" );
	
	new iIterator, iPrice = 0;
	for( iIterator = 0; iIterator < sizeof( g_szOrdinaryShop ); iIterator ++ ) {
		iPrice = !cod_is_vip( iPlayer ) ? str_to_num( g_szOrdinaryShop[ iIterator ][ 2 ] ) : ( str_to_num(g_szOrdinaryShop[ iIterator ][ 2 ] ) / 2 );
		formatex( szText, charsmax( szText ), "\y%L \w[\d%L\w] \y(%L: \r%d\w$\y)", iPlayer, g_szOrdinaryShop[ iIterator ][ 0 ], iPlayer, g_szOrdinaryShop[ iIterator ][ 1 ], iPlayer, "ML_SHOP_PRICE", iPrice );
		menu_additem( iMenu, szText );
	}

	menu_display( iPlayer, iMenu );
}

public OrdinaryShop_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iPrice = !cod_is_vip( iPlayer ) ? str_to_num( g_szOrdinaryShop[ iItem ][ 2 ] ) : ( str_to_num( g_szOrdinaryShop[ iItem ][ 2 ] ) / 2 );
	
	if( cs_get_user_money( iPlayer ) < iPrice ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DO_NOT_HAVE_MONEY", iPrice - g_iPlayerInfo[ iPlayer ][ g_iGold ] );
		return PLUGIN_CONTINUE;
	}
	
	switch( iItem ) {
		case 0: {
			if( !is_user_alive( iPlayer ) ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_ARE_DEAD" );
				return PLUGIN_CONTINUE;
			}
	
			entity_set_float( iPlayer, EV_FL_health, entity_get_float( iPlayer, EV_FL_health ) + 50.0  );
		}
		
		case 1: {
			if( !is_user_alive( iPlayer ) ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_ARE_DEAD" );
				return PLUGIN_CONTINUE;
			}
			
			entity_set_float( iPlayer, EV_FL_health, entity_get_float( iPlayer, EV_FL_health ) + 100.0  );
		}
		
		case 2: {
			if( !is_user_alive( iPlayer ) ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_ARE_DEAD" );
				return PLUGIN_CONTINUE;
			}
				
			g_fPlayerInfo[ iPlayer ][ g_fSpeed ] += 10.0;
		}
		
		case 3: {
			g_iPlayerInfo[ iPlayer ][ g_iXp ] += 400;
			CheckLevel( iPlayer );
		}
		
		case 4: {
			g_iPlayerInfo[ iPlayer ][ g_iXp ] += 1000;
			CheckLevel( iPlayer );
		}
		
		case 5: GivePerk( iPlayer, random_num( 1, g_iRegisteredPerks ) );
	}
	
	cs_set_user_money( iPlayer, cs_get_user_money( iPlayer ) - iPrice );
	PrintToChat( iPlayer, "!g[CoD:Mw] %L %L %L", iPlayer, "ML_BOUGHT", iPlayer, g_szOrdinaryShop[ iItem ][ 0 ], iPlayer, "ML_FOR_MONEY", iPrice );
	
	Shop( iPlayer );
	return PLUGIN_CONTINUE;
}

public PerkShop( iPlayer ) {
	new szText[ 96 ];
	formatex( szText, charsmax( szText ), "%s\r%L:", cod_is_vip( iPlayer ) ? "\d[\rVIP\d] " : "", iPlayer, "ML_PERK_SHOP" );
	new iMenu = menu_create( szText, "PerkShop_Handle" );

	new iPrice = 0;
	new szNumber[ 5 ];
	for( new iIterator = 1; iIterator <= g_iRegisteredPerks; iIterator ++ ) {
		if( !g_PerkData[ iIterator ][ g_iPerkPrice ] || ( g_iPlayerInfo[ iPlayer ][ g_iPerk ] == iIterator ) || IsPerkBlocked( g_iPlayerInfo[ iPlayer ][ g_iClass ], iIterator ) )
			continue;
			
		iPrice = !cod_is_vip( iPlayer ) ? g_PerkData[ iIterator ][ g_iPerkPrice ] : ( g_PerkData[ iIterator ][ g_iPerkPrice ] / 2 );
		formatex( szText, charsmax( szText ), "\y%L \d[\w%L: \r%d \yGold\d]", iPlayer, g_PerkData[ iIterator ][ g_szPerkName ], iPlayer, "ML_SHOP_PRICE", iPrice );
		num_to_str( iIterator, szNumber, charsmax( szNumber ) );
		menu_additem( iMenu, szText, szNumber );
	}

	menu_display( iPlayer, iMenu );
}

public PerkShop_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	new iAccess, iCallBack, iPerkId;
	new szItemName[ 5 ], szData[ 5 ];
	menu_item_getinfo( iMenu, iItem, iAccess, szData, charsmax( szData ), szItemName, charsmax( szItemName ), iCallBack );
	iPerkId = str_to_num( szData );
	new iPrice = !cod_is_vip( iPlayer ) ? g_PerkData[ iPerkId ][ g_iPerkPrice ] : ( g_PerkData[ iPerkId ][ g_iPerkPrice ] / 2 );
	
	if( g_iPlayerInfo[ iPlayer ][ g_iGold ] < iPrice ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DO_NOT_HAVE_GOLD", iPrice - g_iPlayerInfo[ iPlayer ][ g_iGold ] );
		return PLUGIN_CONTINUE;
	}
	
	if( IsPerkBlocked( g_iPlayerInfo[ iPlayer ][ g_iClass ], iPerkId ) ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !nYou can not have this perk!" );
		return PLUGIN_CONTINUE;
	}
	
	g_iPlayerInfo[ iPlayer ][ g_iGold ] -= iPrice;
	GivePerk( iPlayer, iPerkId );
	PrintToChat( iPlayer, "!g[CoD:Mw] !n%L %L %L", iPlayer, "ML_BOUGHT", iPlayer, g_PerkData[ iPerkId ][ g_szPerkName ], iPlayer, "ML_FOR_GOLD", iPrice );
	
	Shop( iPlayer );
	return PLUGIN_CONTINUE;
}


public ChangePerk( iPlayer ) {
	if( !g_iPlayerInfo[ iPlayer ][ g_iPerk ] ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DO_NOT_HAVE_PERK" );
		return;
	}

	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\y%L", iPlayer, "ML_SWITCH_PERK" );
	new iMenu = menu_create( szText, "ChangePerk_Handle" );
	
	new szNumber[ 3 ];
	ForEachPlayer( iTarget ) {
		if( !is_user_connected( iPlayer ) || iPlayer == iTarget || !g_iPlayerInfo[ iTarget ][ g_iPerk ] || g_iPlayerInfo[ iTarget ][ g_iTrading ] )
			continue;

		num_to_str( iTarget, szNumber, charsmax( szNumber ) );
		menu_additem( iMenu, g_szPlayerInfo[ iTarget ][ g_szName ], szNumber );
	}

	menu_display( iPlayer, iMenu );
}

public ChangePerk_Handle( iPlayer, iOldMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iOldMenu );
		return PLUGIN_CONTINUE;
	}

	new iAccess, iCallBack;
	new szPlayerId[ 3 ];
	menu_item_getinfo( iOldMenu, iItem, iAccess, szPlayerId, charsmax( szPlayerId ), _, _, iCallBack );
	new iTarget = str_to_num( szPlayerId );

	if( !is_user_connected( iTarget ) ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_NOT_CONNECTED" );
		return PLUGIN_CONTINUE;
	}

	if( !g_iPlayerInfo[ iTarget ][ g_iPerk ] ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DOES_NOT_HAVE_PERK" );
		return PLUGIN_CONTINUE;
	}

	if( g_iPlayerInfo[ iTarget ][ g_iTrading ] ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_PLAYER_ALREADY_TRADING" );
		return PLUGIN_CONTINUE;
	}
	
	if( IsPerkBlocked( g_iPlayerInfo[ iTarget ][ g_iClass ], g_iPlayerInfo[ iTarget ][ g_iPerk ] ) ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_PLAYER_CANNOT_HAVE_THIS_PERK" );
		return PLUGIN_CONTINUE;
	}

	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\y%L (%L: %L)", iTarget, "ML_SWITCH_PERK_WITH", g_szPlayerInfo[ iPlayer ][ g_szName ], iTarget, "ML_PERK", iTarget, g_PerkData[ g_iPlayerInfo[ iPlayer ][ g_iPerk ] ][ g_szPerkName ] );
	new iMenu = menu_create( szText, "AcceptChangePerk_Handle" );
	
	formatex( szText, charsmax( szText ), "\y%L", iTarget, "ML_YES" );
	menu_additem( iMenu, szText );

	formatex( szText, charsmax( szText ), "\r%L", iTarget, "ML_NO" );
	menu_additem( iMenu, szText );

	menu_display( iTarget, iMenu );
	g_iPlayerInfo[ iTarget ][ g_iTrading ] = iPlayer;
	g_iPlayerInfo[ iPlayer ][ g_iTrading ] = iTarget;

	return PLUGIN_CONTINUE;
}

public AcceptChangePerk_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		new iTarget = g_iPlayerInfo[ iPlayer ][ g_iTrading ];
		PrintToChat( iTarget, "!g[CoD:Mw] !n%L", iTarget, "ML_PLAYER_REFUSED_SWICTH" );
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_HAVE_REFUSED_SWICTH" );
		g_iPlayerInfo[ iTarget ][ g_iTrading ] = 0;
		g_iPlayerInfo[ iPlayer ][ g_iTrading ] = 0;
		
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}

	switch( iItem ) {
		case 0: {
			new iTarget = g_iPlayerInfo[ iPlayer ][ g_iTrading ];
			if( !is_user_connected( iTarget ) ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_NOT_CONNECTED" );
				g_iPlayerInfo[ iPlayer ][ g_iTrading ] = 0;
				return PLUGIN_CONTINUE;
			}

			if( !g_iPlayerInfo[ iTarget ][ g_iPerk ] ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DOES_NOT_HAVE_PERK" );
				g_iPlayerInfo[ iTarget ][ g_iTrading ] = 0;
				g_iPlayerInfo[ iPlayer ][ g_iTrading ] = 0;
				return PLUGIN_CONTINUE;
			}
			
			if( IsPerkBlocked( g_iPlayerInfo[ iTarget ][ g_iClass ], g_iPlayerInfo[ iTarget ][ g_iPerk ] ) ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_PLAYER_CANNOT_HAVE_THIS_PERK" );
				return PLUGIN_CONTINUE;
			}
			
			new iYourPerk = g_iPlayerInfo[ iPlayer ][ g_iPerk ];
			new iTargetPerk = g_iPlayerInfo[ iTarget ][ g_iPerk ];

			GivePerk( iPlayer, iTargetPerk );
			GivePerk( iTarget, iYourPerk );

			PrintToChat( iTarget, "!g[CoD:Mw] !n%L", iTarget, "ML_SWITCHED_PERK", g_szPlayerInfo[ iPlayer ][ g_szName ] );
			PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_SWITCHED_PERK", g_szPlayerInfo[ iTarget ][ g_szName ] );
			g_iPlayerInfo[ iTarget ][ g_iTrading ] = 0;
			g_iPlayerInfo[ iPlayer ][ g_iTrading ] = 0;
		}

		case 1: {
			new iTarget = g_iPlayerInfo[ iPlayer ][ g_iTrading ];
			PrintToChat( iTarget, "!g[CoD:Mw] !n%L", iTarget, "ML_PLAYER_REFUSED_SWICTH" );
			PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_HAVE_REFUSED_SWICTH" );
			g_iPlayerInfo[ iTarget ][ g_iTrading ] = 0;
			g_iPlayerInfo[ iPlayer ][ g_iTrading ] = 0;
		}
	}

	return PLUGIN_CONTINUE;
}

public GivePerkToPlayer( iPlayer ) {
	if( !g_iPlayerInfo[ iPlayer ][ g_iPerk ] ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DO_NOT_HAVE_PERK" );
		return;
	}

	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\y%L", iPlayer, "ML_GIVE_PERK" );
	new iMenu = menu_create( szText, "GivePerk_Handle" );
	
	new szNumber[ 3 ];
	ForEachPlayer( iTarget ) {
		if( !is_user_connected( iPlayer ) || iPlayer == iTarget || g_iPlayerInfo[ iTarget ][ g_iPerk ] || g_iPlayerInfo[ iTarget ][ g_iTrading ] )
			continue;

		num_to_str( iTarget, szNumber, charsmax( szNumber ) );
		menu_additem( iMenu, g_szPlayerInfo[ iTarget ][ g_szName ], szNumber );
	}

	menu_display( iPlayer, iMenu );
}

public GivePerk_Handle( iPlayer, iOldMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iOldMenu );
		return PLUGIN_CONTINUE;
	}

	new iAccess, iCallBack;
	new szPlayerId[ 3 ];
	menu_item_getinfo( iOldMenu, iItem, iAccess, szPlayerId, charsmax( szPlayerId ), _, _, iCallBack );
	new iTarget = str_to_num( szPlayerId );

	if( !is_user_connected( iTarget ) ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_NOT_CONNECTED" );
		return PLUGIN_CONTINUE;
	}

	if( g_iPlayerInfo[ iTarget ][ g_iPerk ] ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_ALREADY_HAS_PERK" );
		return PLUGIN_CONTINUE;
	}

	if( g_iPlayerInfo[ iTarget ][ g_iTrading ] ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_PLAYER_IS_TRADING" );
		return PLUGIN_CONTINUE;
	}
	
	if( IsPerkBlocked( g_iPlayerInfo[ iTarget ][ g_iClass ], g_iPlayerInfo[ iTarget ][ g_iPerk ] ) ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_PLAYER_CANNOT_HAVE_THIS_PERK" );
		return PLUGIN_CONTINUE;
	}

	new szText[ 32 ];
	formatex( szText, charsmax( szText ), "\y%L", iPlayer, "ML_GIVE_PERK_TO", g_szPlayerInfo[ iTarget ][ g_szName ] );
	new iMenu = menu_create( szText, "GivePerkAcceped_Handle" );
	
	formatex( szText, charsmax( szText ), "\y%L", iPlayer, "ML_YES" );
	menu_additem( iMenu, szText );

	formatex( szText, charsmax( szText ), "\r%L", iPlayer, "ML_NO" );
	menu_additem( iMenu, szText );

	menu_display( iPlayer, iMenu );

	g_iPlayerInfo[ iPlayer ][ g_iTargetedPlayer ] = iTarget;

	return PLUGIN_CONTINUE;
}

public GivePerkAcceped_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		g_iPlayerInfo[ iPlayer ][ g_iTargetedPlayer ] = 0;
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_HAVE_CANCELED" );
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}

	switch( iItem ) {
		case 0: {
			new iTarget = g_iPlayerInfo[ iPlayer ][ g_iTargetedPlayer ];
			
			if( !is_user_connected( iTarget ) ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_NOT_CONNECTED" );
				g_iPlayerInfo[ iPlayer ][ g_iTargetedPlayer ] = 0;
				return PLUGIN_CONTINUE;
			}

			if( g_iPlayerInfo[ iTarget ][ g_iPerk ] ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_ALREADY_HAS_PERK" );
				g_iPlayerInfo[ iPlayer ][ g_iTargetedPlayer ] = 0;
				return PLUGIN_CONTINUE;
			}

			if( g_iPlayerInfo[ iTarget ][ g_iTrading ] ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_PLAYER_IS_TRADING" );
				g_iPlayerInfo[ iPlayer ][ g_iTargetedPlayer ] = 0;
				return PLUGIN_CONTINUE;
			}

			if( IsPerkBlocked( g_iPlayerInfo[ iTarget ][ g_iClass ], g_iPlayerInfo[ iTarget ][ g_iPerk ] ) ) {
				PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_PLAYER_CANNOT_HAVE_THIS_PERK" );
				return PLUGIN_CONTINUE;
			}
	
			new iYourPerk = g_iPlayerInfo[ iPlayer ][ g_iPerk ]
			g_iPlayerInfo[ iPlayer ][ g_iPerk ] = 0;
			GivePerk( iTarget, iYourPerk );
			client_cmd( iPlayer, "say /updateperk" );

			PrintToChat( iTarget, "!g[CoD:Mw] !n%L !n%L!n.", iTarget, "ML_PLAYER_GAVE_TO_YOU", g_szPlayerInfo[ iPlayer ][ g_szName ], iTarget, g_PerkData[ iYourPerk ][ g_szName ] );
			PrintToChat( iPlayer, "!g[CoD:Mw] !n%L !n%L!n.", iPlayer, "ML_YOU_GAVE", g_szPlayerInfo[ iTarget ][ g_szName ], iPlayer, g_PerkData[ iYourPerk ][ g_szName ] );
		}

		case 1: {
			g_iPlayerInfo[ iPlayer ][ g_iTargetedPlayer ] = 0;
			PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_HAVE_CANCELED" );
			return PLUGIN_CONTINUE;
		}
	}

	return PLUGIN_CONTINUE;
}

public SellPerk( iPlayer ) {
	if( !g_iPlayerInfo[ iPlayer ][ g_iPerk ] ) {
		PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_DO_NOT_HAVE_PERK" );
		return;
	}
			
	cs_set_user_money( iPlayer, cs_get_user_money( iPlayer ) + CvarValue( g_cPerkSellMoney ) );
	g_iPlayerInfo[ iPlayer ][ g_iPerk ] = 0;
	PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_YOU_HAVE_SOLD_PERK", CvarValue( g_cPerkSellMoney ) );
}

public Reset( iPlayer ) {
	new szText[ 64 ];
	formatex( szText, charsmax( szText ), "\r%L", iPlayer, "ML_DO_YOU_WANT_TO_RESET" );
	
	new iMenu = menu_create( szText, "Reset_Handle" );
	formatex( szText, charsmax( szText ), "\r%L", iPlayer, "ML_YES" );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "\y%L", iPlayer, "ML_NO" );
	menu_additem( iMenu, szText );
	
	menu_display( iPlayer, iMenu );
}

public Reset_Handle( iPlayer, iMenu, iItem ) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	
	if( iItem == MENU_EXIT ) {
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	switch( iItem ) {
		case 0: {
			g_iPlayerInfo[ iPlayer ][ g_iPoints ] = ( g_iPlayerInfo[ iPlayer ][ g_iLevel ] - 1 ) * 2;
			g_iPlayerInfo[ iPlayer ][ g_iEnergy ] = 0;
			g_iPlayerInfo[ iPlayer ][ g_iResistance ] = 0;
			g_iPlayerInfo[ iPlayer ][ g_iStamina ] = 0;
			g_iPlayerInfo[ iPlayer ][ g_iDamage ] = 0;
			
			if( g_iPlayerInfo[ iPlayer ][ g_iPoints ] > 0 )
				UsePoints( iPlayer );
			
			PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", iPlayer, "ML_RESETING" );
		}
	}
	
	return PLUGIN_CONTINUE;
}

//=================================================================================================
//					Natives
//=================================================================================================

public plugin_natives( ) {
	// Classes
	register_native( "cod_register_class", "NativeRegisterClass" );
	register_native( "cod_classes_number", "NativeNumberOfClasses" );
	register_native( "cod_get_class_id", "NativeGetClassId" );
	register_native( "cod_get_class_name", "NativeGetClassName", 1 );
	register_native( "cod_get_class_description", "NativeGetClassDescription", 1 );
	register_native( "cod_get_class_faction", "NativeGetClassFaction", 1 );
	register_native( "cod_get_class_flag", "NativeGetClassFlag", 1 );
	
	// Perks
	register_native( "cod_register_perk", "NativeRegisterPerk" );
	register_native( "cod_perks_number", "NativeNumberOfPerks" );
	register_native( "cod_get_perk_id", "NativeGetPerkId" );
	register_native( "cod_get_perk_name", "NativeGetPerkName", 1 );
	register_native( "cod_get_perk_description", "NativeGetPerkDescription", 1 );
	register_native( "cod_get_perk_price", "NativeGetPerkPrice" );
	
	register_native( "use_points_for_someone_else", "UsePointsForSomeoneElse" );

	// Levels
	register_native( "cod_get_level", "NativeGetLevel" );
	register_native( "cod_set_level", "NativeSetLevel" );
	register_native( "cod_get_xp", "NativeGetXp" );
	register_native( "cod_set_xp", "NativeSetXp" );
	
	// Gold
	register_native( "cod_get_gold", "NativeGetGold" );
	register_native( "cod_set_gold", "NativeSetGold" );
	
	// Player Class
	register_native( "cod_get_class", "NativeGetClass" );
	register_native( "cod_set_class", "NativeSetClass" );
	
	// Player Perk
	register_native( "cod_get_perk", "NativeGetPerk" );
	register_native( "cod_set_perk", "NativeSetPerk" );

	// Player Max HP
	register_native( "cod_get_player_max_hp", "NativeGetMaxHp", 1 );
	register_native( "cod_set_player_max_hp", "NativeSetMaxHp", 1 );
	
	// Points
	register_native( "cod_get_energy", "NativeGetEnergy" );
	register_native( "cod_set_energy", "NativeSetEnergy" );
	register_native( "cod_get_resistance", "NativeGetResistance" );
	register_native( "cod_set_resistance", "NativeSetResistance" );
	register_native( "cod_get_stamina", "NativeGetStamina" );
	register_native( "cod_set_stamina", "NativeSetStamina" );
	register_native( "cod_get_damage", "NativeGetDamage" );
	register_native( "cod_set_damage", "NativeSetDamage" );

	// Other
	register_native( "cod_set_weapon_pickup", "NativeSetWeaponPickup" );
	register_native( "cod_calculate_level", "NativeCalculateLevel" );
	register_native( "cod_set_double_xp", "NativeSetDoubleXp" );
}

//		 ======== Classes ========
public NativeRegisterClass( iPlugin, iParams ) {
	if( iParams != 10 )
		return PLUGIN_CONTINUE;
		
	if( g_iRegisteredClasses ++ > iMaxClasses )
		return -1;
		
	get_string( 1, g_ClassData[ g_iRegisteredClasses ][ g_szClassName ], charsmax( g_ClassData[ ][ g_szClassName ] ) );
	get_string( 2, g_ClassData[ g_iRegisteredClasses ][ g_szClassDescription ], charsmax( g_ClassData[ ][ g_szClassDescription ] ) );
	get_string( 3, g_ClassData[ g_iRegisteredClasses ][ g_szClassFaction ], charsmax( g_ClassData[ ][ g_szClassFaction ] ) );
	get_string( 4, g_ClassData[ g_iRegisteredClasses ][ g_szClassWeapons ], charsmax( g_ClassData[ ][ g_szClassWeapons ] ) );
	get_string( 5, g_ClassData[ g_iRegisteredClasses ][ g_szClassFlag ], charsmax( g_ClassData[ ][ g_szClassFlag ] ) );
	get_string( 6, g_ClassData[ g_iRegisteredClasses ][ g_szClassSpeed ], charsmax( g_ClassData[ ][ g_szClassSpeed ] ) );
	
	g_ClassData[ g_iRegisteredClasses ][ g_iClassHp ] = get_param( 7 );
	g_ClassData[ g_iRegisteredClasses ][ g_iClassArmor ] = get_param( 8 );
	g_ClassData[ g_iRegisteredClasses ][ g_iClassVisibility ] = get_param( 9 ) > 255 ? 255 : get_param( 9 );
	g_ClassData[ g_iRegisteredClasses ][ g_iClassPrice ] = get_param( 10 );
	
	return g_iRegisteredClasses;
}

public NativeNumberOfClasses( iPlugin, iParams )
	return g_iRegisteredClasses;
	
public NativeGetClassId( iPlugin, iParams ) {
	if( iParams != 1 )
		return 0;
		
	new szClassName[ 64 ];
	get_string( 1, szClassName, charsmax( szClassName ) );
		
	for( new i = 1; i <= g_iRegisteredClasses; i ++ ) {
		if( equal( szClassName, g_ClassData[ i ][ g_szClassName ] ) )
			return i;
	}
	
	return 0;
}

public NativeGetClassName( iClassId, szName[ ], iLen ) {
	if( iClassId < 0 || iClassId > g_iRegisteredClasses ) {
		copy( szName, iLen, "Error" );
		return;
	}

	param_convert( 2 );
	copy( szName, iLen, g_ClassData[ iClassId ][ g_szClassName ] );
}

public NativeGetClassDescription( iClassId, szDescription[ ], iLen ) {
	if( iClassId < 0 || iClassId > g_iRegisteredClasses ) {
		copy( szDescription, iLen, "Error" );
		return;
	}

	param_convert( 2 );
	copy( szDescription, iLen, g_ClassData[ iClassId ][ g_szClassDescription ] );
}

public NativeGetClassFaction( iClassId, szFaction[ ], iLen ) {
	if( iClassId < 0 || iClassId > g_iRegisteredClasses ) {
		copy( szFaction, iLen, "Error" );
		return;
	}

	param_convert( 2 );
	copy( szFaction, iLen, g_ClassData[ iClassId ][ g_szClassFaction ] );
}

public NativeGetClassFlag( iClassId, szFlag[ ], iLen ) {
	if( iClassId < 0 || iClassId > g_iRegisteredClasses ) {
		copy( szFlag, iLen, "" );
		return;
	}

	param_convert( 2 );
	copy( szFlag, iLen, g_ClassData[ iClassId ][ g_szClassFlag ] );
}

//		 ======== Perks ========
public NativeRegisterPerk( iPlugin, iParams ) {
	if( iParams != 4 )
		return PLUGIN_CONTINUE;
		
	if( g_iRegisteredPerks ++ > iMaxPerks )
		return -1;
	
	get_string( 1, g_PerkData[ g_iRegisteredPerks ][ g_szPerkName ], charsmax( g_PerkData[ ][ g_szPerkName ] ) );
	get_string( 2, g_PerkData[ g_iRegisteredPerks ][ g_szPerkDescription ], charsmax( g_PerkData[ ][ g_szPerkDescription ] ) );
	g_PerkData[ g_iRegisteredPerks ][ g_iPerkPrice ] = get_param( 3 );
	get_string( 4, g_PerkData[ g_iRegisteredPerks ][ g_szPerkBlocks ], charsmax( g_PerkData[ ][ g_szPerkBlocks ] ) );
	
	return g_iRegisteredPerks;
}

public NativeNumberOfPerks( iPlugin, iParams )
	return g_iRegisteredPerks;
	
public NativeGetPerkId( iPlugin, iParams ) {
	if( iParams != 1 )
		return 0;
		
	new szPerkName[ 64 ];
	get_string( 1, szPerkName, charsmax( szPerkName ) );
		
	for( new i = 1; i <= g_iRegisteredPerks; i ++ ) {
		if( equal( szPerkName, g_PerkData[ i ][ g_szPerkName ] ) )
			return i;
	}
	
	return 0;
}

public NativeGetPerkName( iPerkId, szName[ ], iLen ) {
	if( iPerkId < 0 || iPerkId > g_iRegisteredPerks ) {
		copy( szName, iLen, "Error" );
		return;
	}

	param_convert( 2 );
	copy( szName, iLen, g_PerkData[ iPerkId ][ g_szPerkName ] );
}

public NativeGetPerkDescription( iPerkId, szDescription[ ], iLen ) {
	if( iPerkId < 0 || iPerkId > g_iRegisteredPerks ) {
		copy( szDescription, iLen, "Error" );
		return;
	}

	param_convert( 2 );
	copy( szDescription, iLen, g_PerkData[ iPerkId ][ g_szPerkDescription ] );
}

public NativeGetPerkPrice( iPlugin, iParams ) {
	if( iParams != 1 )
		return 0;

	new iPerkId = get_param( 1 ); 

	if( iPerkId < 0 || iPerkId > g_iRegisteredPerks ) 
		return 0;
	
	return g_PerkData[ iPerkId ][ g_iPerkPrice ];
}

//		 ======== Player Levels ========
public NativeGetLevel( iPlugin, iParams ) {
	if( iParams != 1 )
		return 0;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iLevel ];
}

public NativeSetLevel( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
		
	g_iPlayerInfo[ get_param( 1 ) ][ g_iLevel ] = get_param( 2 );
	SaveData( get_param( 1 ) );
}

public NativeGetXp( iPlugin, iParams ) {
	if( iParams != 1 )
		return 0;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iXp ];
}

public NativeSetXp( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
	
	new iPlayer = get_param( 1 );
		
	g_iPlayerInfo[ iPlayer ][ g_iXp ] = get_param( 2 );
	CheckLevel( iPlayer );
}

//		 ======== Player Gold ========
public NativeGetGold( iPlugin, iParams ) {
	if( iParams != 1 )
		return 0;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iGold ];
}

public NativeSetGold( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
	
	new iPlayer = get_param( 1 );
	g_iPlayerInfo[ iPlayer ][ g_iGold ] = get_param( 2 );
	SaveGold( iPlayer );
}

//		 ======== Player Class ========
public NativeGetClass( iPlugin, iParams ) {
	if( iParams != 1 )
		return PLUGIN_CONTINUE;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iClass ];
}

public NativeSetClass( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
		
	g_iPlayerInfo[ get_param( 1 ) ][ g_iClass ] = get_param( 2 );
}

//		 ======== Player Perks ========
public NativeGetPerk( iPlugin, iParams ) {
	if( iParams != 1 )
		return PLUGIN_CONTINUE;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iPerk ];
}

public NativeSetPerk( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
		
	GivePerk( get_param( 1 ), get_param( 2 ) );
}

//		 ======== Player Max HP ========
public NativeGetMaxHp( iPlayer ) {
	return floatround( g_fPlayerInfo[ iPlayer ][ g_fMaxHp ] );
}

public NativeSetMaxHp( iPlayer, iValue ) {
	g_fPlayerInfo[ iPlayer ][ g_fMaxHp ] = float( iValue > 1000 ? 1000 : iValue );
}

//		 ======== Points ========

public UsePointsForSomeoneElse( iPlayer,iTarget ) {
	new szText[ 86 ];
	formatex( szText, charsmax( szText ), "\r%L \d[\y%i\d] \w:", iPlayer, "ML_USE_POINTS", g_iPlayerInfo[iTarget][ g_iPoints ] );
	new iMenu = menu_create( szText, "Handle_UsePointsForSomeoneElse" );
	
	formatex( szText, charsmax( szText ), "\y%L \w: \d[ \r%d \y/ \r%d \d]", iPlayer, "ML_ENERGY", g_iPlayerInfo[iTarget ][ g_iEnergy ], iMaxEnergy );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "\y%L \w: \d[ \r%d \y/ \r%d \d]", iPlayer, "ML_RESISTANCE", g_iPlayerInfo[iTarget ][ g_iResistance ], iMaxResisance );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "\y%L \w: \d[ \r%d \y/ \r%d \d]", iPlayer, "ML_STAMINA", g_iPlayerInfo[ iTarget][ g_iStamina ], iMaxStamina );
	menu_additem( iMenu, szText );
	
	formatex( szText, charsmax( szText ), "\y%L \w: \d[ \r%d \y/ \r%d \d]^n", iPlayer, "ML_DAMAGE", g_iPlayerInfo[ iTarget ][ g_iDamage ], iMaxDamage );
	menu_additem( iMenu, szText );

	formatex( szText, charsmax( szText ), "\y%L \w: \r[ \y%s \r]", iPlayer, "ML_NUMBER_OF_POINTS", g_szAddPointsNumber[ g_iPlayerInfo[ iTarget][ g_iAddNumber ] ] );
	menu_additem( iMenu, szText );
	
	menu_display( iPlayer,iMenu );
}

public Handle_UsePointsForSomeoneElse( iPlayer, iMenu, iItem) {
	client_cmd( iPlayer, "spk ByM_Cod/select" );
	new target=g_iTargetedPlayer;
	if( iItem == MENU_EXIT ) { 
		menu_destroy( iMenu );
		return PLUGIN_CONTINUE;
	}
	
	if( g_iPlayerInfo[ iPlayer ][ g_iPoints ] < 1 )
		return PLUGIN_CONTINUE;
	
	new iNumberForAdding = 0;
	
	if( g_iAddPointsNumber[ g_iPlayerInfo[ target ][ g_iAddNumber ] ] == -1 )
		iNumberForAdding = g_iPlayerInfo[ target ][ g_iPoints ];
	else 
		iNumberForAdding = ( g_iAddPointsNumber[ g_iPlayerInfo[ target][ g_iAddNumber ] ] > g_iPlayerInfo[ target][ g_iPoints ] ) ? g_iPlayerInfo[ target ][ g_iPoints ] : g_iAddPointsNumber[ g_iPlayerInfo[ target ][ g_iAddNumber ] ];

	switch( iItem ) {
		case 0: {
			if( g_iPlayerInfo[ target ][ g_iEnergy ] < iMaxEnergy ) {
				if( iNumberForAdding > iMaxEnergy - g_iPlayerInfo[target][ g_iEnergy ] )
					iNumberForAdding = iMaxEnergy - g_iPlayerInfo[ target ][ g_iEnergy ];

				g_iPlayerInfo[ target][ g_iEnergy ] += iNumberForAdding;
				g_iPlayerInfo[ target][ g_iPoints ] -= iNumberForAdding;
			} 
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L",target, "ML_MAX_ENERGY" );
		}

		case 1: {
			if( g_iPlayerInfo[ target ][ g_iResistance ] < iMaxResisance ) {
				if( iNumberForAdding > iMaxResisance - g_iPlayerInfo[ target ][ g_iResistance ] )
					iNumberForAdding = iMaxResisance - g_iPlayerInfo[ target ][ g_iResistance ];
				
				g_iPlayerInfo[ target][ g_iResistance ] += iNumberForAdding;
				g_iPlayerInfo[ target][ g_iPoints ] -= iNumberForAdding;
			} 
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L",target, "ML_MAX_RESISTANCE" );
		}

		case 2: {
			if( g_iPlayerInfo[ target][ g_iStamina ] < iMaxStamina ) {
				if( iNumberForAdding > iMaxStamina - g_iPlayerInfo[target ][ g_iStamina ] )
					iNumberForAdding = iMaxStamina - g_iPlayerInfo[ target][ g_iStamina ];
				
				g_iPlayerInfo[ target][ g_iStamina ] += iNumberForAdding;
				g_iPlayerInfo[ target ][ g_iPoints ] -= iNumberForAdding;
			} 
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L", target, "ML_MAX_STAMINA" );
		}

		case 3: {
			if( g_iPlayerInfo[ target][ g_iDamage ] < iMaxDamage ) {
				
				if( iNumberForAdding > iMaxDamage - g_iPlayerInfo[ target ][ g_iDamage ] )
					iNumberForAdding = iMaxDamage - g_iPlayerInfo[target ][ g_iDamage ];
				
				g_iPlayerInfo[ target][ g_iDamage ] += iNumberForAdding;
				g_iPlayerInfo[ target ][ g_iPoints ] -= iNumberForAdding;
			} 
			else PrintToChat( iPlayer, "!g[CoD:Mw] !n%L",target, "ML_MAX_DAMAGE" );
		}

		case 4: {
			if( g_iPlayerInfo[ target ][ g_iAddNumber ] < charsmax( g_iAddPointsNumber ) ) 
				g_iPlayerInfo[target][ g_iAddNumber ] ++;
			else g_iPlayerInfo[target][ g_iAddNumber ] = 0;
		}
	}
	
	if( g_iPlayerInfo[ target][ g_iPoints ] > 0 )
		UsePointsForSomeoneElse( iPlayer,target );
	
	SaveData( target );
	return PLUGIN_CONTINUE;
}
public NativeGetEnergy( iPlugin, iParams ) {
	if( iParams != 1 )
		return PLUGIN_CONTINUE;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iEnergy ];
}

public NativeSetEnergy( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
		
	g_iPlayerInfo[ get_param( 1 ) ][ g_iEnergy ] = get_param( 2 );
}

public NativeGetResistance( iPlugin, iParams ) {
	if( iParams != 1 )
		return PLUGIN_CONTINUE;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iResistance ];
}

public NativeSetResistance( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
		
	g_iPlayerInfo[ get_param( 1 ) ][ g_iResistance ] = get_param( 2 );
}

public NativeGetStamina( iPlugin, iParams ) {
	if( iParams != 1 )
		return PLUGIN_CONTINUE;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iStamina ];
}

public NativeSetStamina( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
		
	g_iPlayerInfo[ get_param( 1 ) ][ g_iStamina ] = get_param( 2 );
}

public NativeGetDamage( iPlugin, iParams ) {
	if( iParams != 1 )
		return PLUGIN_CONTINUE;
		
	return g_iPlayerInfo[ get_param( 1 ) ][ g_iDamage ];
}

public NativeSetDamage( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
		
	g_iPlayerInfo[ get_param( 1 ) ][ g_iDamage ] = get_param( 2 );
}

// ========= Other =========
public NativeSetWeaponPickup( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
	
	g_iPlayerInfo[ get_param( 1 ) ][ g_iAllowWeaponPickup ] = get_param( 2 );
}

public NativeCalculateLevel( iPlugin, iParams ) {
	if( iParams != 1 )
		return 0;
	
	return g_iLevelXP[ get_param( 1 ) ];
}

public NativeSetDoubleXp( iPlugin, iParams ) {
	if( iParams != 2 )
		return;
		
	g_iPlayerInfo[ get_param( 1 ) ][ g_iDoubleXP ] = get_param( 2 );
}

//=================================================================================================
//					Stocks
//=================================================================================================

stock bool: IsItInPrevious( szFaction[ ], iClassId ) {
	for( new iIterator = iClassId - 1; iIterator >= 1; iIterator -- ) {
		if( equali( g_ClassData[ iIterator ][ g_szClassFaction ], szFaction ) )
			return true;
	}
	
	return false;
}

// Originally by Unknown Author
// Found this on the internet
stock bool: IsSteamPlayer( iPlayer ) {
	new iDpPointer;
	
	if( iDpPointer || ( iDpPointer = get_cvar_pointer( "dp_r_id_provider" ) ) ) {
		server_cmd( "dp_clientinfo %d", iPlayer );
		server_exec( );
		return ( get_pcvar_num( iDpPointer ) == 2 ) ? true : false
	}
	
	return false
}

stock PrintToChat( iPlayer, const szInput[ ], any:... ) {
	static szMessage[ 191 ];
	vformat( szMessage, charsmax( szMessage ), szInput, 3 );
	replace_all( szMessage, charsmax( szMessage ), "!g", "^4" );
	replace_all( szMessage, charsmax( szMessage ), "!t", "^3" );
	replace_all( szMessage, charsmax( szMessage ), "!n", "^1" );
     
	if( !iPlayer ) {
		for( new iTarget = 1; iTarget <= g_iMaxPlayers; iTarget ++ ) {
			//if( !is_user_connected( iTarget ) || is_user_bot( iTarget ) )
			if( !is_user_connected( iTarget ))
				continue;
		
			message_begin( MSG_ONE_UNRELIABLE, g_iMessageChat, _, iTarget );
			write_byte( iTarget );
			write_string( szMessage );
			message_end( );
		}
	} else {
		//if( !is_user_connected( iPlayer ) || is_user_bot( iPlayer ) )
		if( !is_user_connected( iPlayer ))
			return;
		
		message_begin( MSG_ONE_UNRELIABLE, g_iMessageChat, _, iPlayer );
		write_byte( iPlayer );
		write_string( szMessage );
		message_end( );
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

stock bool: IsHappyHour( ) {
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

stock bool: IsPerkBlocked( iClass, iPerkId ) {
	if( strlen( g_PerkData[ iPerkId ][ g_szPerkBlocks ] ) > 0 ) {
		new szClassList[ 35 ][ 35 ], i;
		ExplodeString( g_PerkData[ iPerkId ][ g_szPerkBlocks ], ':', szClassList, 34, charsmax( szClassList ) );
	
		for( i = 1; i <= 34; i++ ) {
			if( szClassList[ i ][ 0 ] != EOS ) {
				if( equal( szClassList[ i ], g_ClassData[ iClass ][ g_szClassName ] )  || equal( szClassList[ i ], g_ClassData[ iClass ][ g_szClassFaction ] ) )
					return true;
			}
		}
	}
	
	return false;
}

// Author: xeroblood
stock ExplodeString( const szInput[ ], const iCharacter, szOutput[ ][ ], const iMaxs, const iMaxLen ) {
	new iDo = 0, iLen = strlen( szInput ), iOutputLen = 0;
	
	do { iOutputLen += ( 1 + copyc( szOutput[ iDo++ ], iMaxLen, szInput[ iOutputLen ],  iCharacter ) ); }
	while( iOutputLen < iLen && iDo < iMaxs )
}

stock GiveAmmo( iPlayer ) {
	static szWeapons[ 32 ], iWeaponsNumber, i;
	get_user_weapons( iPlayer, szWeapons, iWeaponsNumber );
	
	for( i = 0; i < iWeaponsNumber; i++ ) {
		if( is_user_alive( iPlayer ) ) {
			if( g_iMaxAmmo[ szWeapons[ i ] ] > 0 )
				cs_set_user_bpammo( iPlayer, szWeapons[ i ], g_iMaxAmmo[ szWeapons[ i ] ] );
		}
	}
}

stock ScreenFade( iPlayer, iDuration, iHoldTime, iFadeType, iRed, iGreen, iBlue, iAlpha ) {
	if( !is_user_connected( iPlayer ) )
		return;
		
	message_begin( MSG_ONE, g_iMessageScreenFade, { 0,0,0 }, iPlayer );
	write_short( iDuration );
	write_short( iHoldTime );
	write_short( iFadeType );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iAlpha );
	message_end( );
}

//=================================================================================================
//					Plugin end
//=================================================================================================
public plugin_end( ) {
	for( new i = 0; i < StructForwards; i ++ )
		DestroyForward( g_fwForwards[ i ] );

	nvault_close( g_iVault );
}
