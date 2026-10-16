#include < amxmodx >
#include < hamsandwich >
#include < bym_cod_2016 >
#include < bym_framework >
#include < cs_player_models_api >
#include < fakemeta >
#include < cstrike >
#include < engine >
#include < fun >

//=================================================================================================
//				 	Macors
//=================================================================================================

#define	TASK_REVIVE		9184
#define Struct			enum

//=================================================================================================
//				 	Structures
//=================================================================================================
Struct StructPerks {
	SilentBoots,
	SecretOfMarine,
	TitaniumBullets,
	BulletsOfColonel,
	MilitarySecret,
	ReactiveArmor,
	AwpMaster,
	HeResistance,
	SwatShield,
	DoubleJump,
	TripleJump,
	M4Swat,
	M4Aim,
	Ak47Aim,
	Xray,
	Magician,
	SecretOfAssassin,
	FastReload,
	NoRecoil,
	Camouflage,
	SecretOfVampire,
	SecretOfShaman,
	JetPack,
	SuperJetPack,
	DeagleAim,
	SecretOfRambo,
	DeagleManiac,
	WallClimb,
	HsImmunity,
	HsOnly,
	M3Pro,
	BulletProof,
	SupriseEnemies,
	Respawn,
	Gravity,
	Plus100Ap,
	ScoutExpert,
	Plus10XP,
	KnifeResistance,
	HeExpert
}

Struct _:StructPlayerInfo {
	g_iPerk
}

//=================================================================================================
//				 	Variables
//=================================================================================================

new const g_szPerks[ StructPerks ][ 4 ][ ] = {
	//  	Name                        	Description                 	Price       Blocks
	{	"ML_SILENT_BOOTS",		"ML_D_SILENT_BOOTS",		"50",       ""																																			},      // 1
	{	"ML_SECRET_OF_MARINE",		"ML_D_SECRET_OF_MARINE",	"200",      "ML_MARINE:ML_REBEL:ML_ASSASSIN:ML_AL_CAPONE:ML_BLADE:ML_VIN_DIESEL:ML_WARIOR:ML_PRO_NINJA:ML_WOLVERINE:ML_OFFICER:ML_GHOST"																				},      // 2
	{	"ML_TITANIUM_BULLETS",		"ML_D_TITANIUM_BULLETS",	"60",       ""																																			},      // 3
	{	"ML_BULLETS_OF_COLONEL",	"ML_D_BULLETS_OF_COLONEL",	"70",       ""																																			},      // 4
	{	"ML_MILITARY_SECRET",		"ML_D_MILITARY_SECRET",		"170",      "ML_REBEL:ML_OFFICER"																																},      // 5
	{	"ML_REACTIVE_ARMOR",		"ML_D_REACTIVE_ARMOR",		"300",      "ML_PREMIUM_CLASSES:ML_E_PREMIUM_CLASSES:ML_ASSASSINS_CLASSES:ML_SNIPERMAN:ML_CRANK:ML_PRO_SHOOTER" 																							},      // 6
	{	"ML_AWP_MASTER",		"ML_D_AWP_MASTER",		"200",      "ML_FBI"																																		},      // 7
	{	"ML_HE_RESISTANCE",		"ML_D_HE_RESISTANCE",		"90",       ""																																			},      // 8
	{	"ML_SWAT_SHIELD",		"ML_D_SWAT_SHIELD",		"400",      "ML_PREMIUM_CLASSES:ML_E_PREMIUM_CLASSES:ML_ASSASSINS_CLASSES:ML_SNIPERMAN:ML_CRANK:ML_PRO_SHOOTER"																							},      // 9
	{	"ML_DOUBLE_JUMP",		"ML_D_DOUBLE_JUMP",		"50",       ""																																			},      // 10
	{	"ML_TRIPLE_JUMP",		"ML_D_TRIPLE_JUMP",		"70",       ""																																			},      // 11
	{	"ML_M4SWAT",			"ML_D_M4SWAT",			"190",      "ML_FBI:ML_CRANK:"																																	},      // 12
	{	"ML_M4AIM",			"ML_D_M4AIM",			"170",      "ML_PRO_SWAT:ML_TELEPORTER:ML_HUNTER"																														},      // 13
	{	"ML_AK47AIM",			"ML_D_AK47AIM",			"170",      "ML_HUNTER:ML_COMRADE_TITO:ML_DESTROYER:ML_BIN_LADEN"																												},      // 14
	{	"ML_XRAY",			"ML_D_XRAY",			"250",      "ML_COMRADE_TITO:ML_DEADPOOL:ML_IRON_MAN"																														},      // 15
	{	"ML_MAGICIAN_PERK",		"ML_D_MAGICIAN_PERK",		"160",      "ML_NINJA:ML_BAD_BOY:ML_INDIAN:ML_CHOUKER:ML_CAMPER_MAESTRO"																												},      // 16
	{	"ML_SECRET_OF_ASSASSIN",	"ML_D_SECRET_OF_ASSASSIN",	"200",      "ML_ASSASSIN:ML_PRO_NINJA:ML_WOLVERINE"																														},      // 17
	{	"ML_FAST_RELOAD",		"ML_D_FAST_RELOAD",		"300",      ""																																			},      // 18
	{	"ML_NO_RECOIL",			"ML_D_NO_RECOIL",		"180",      ""																																			},      // 19
	{	"ML_CAMOUFLAGE",		"ML_D_CAMOUFLAGE",		"130",      "ML_ASSASSIN:ML_MONSTER:ML_BIN_LADEN:ML_IRON_MAN:ML_WOLVERINE:ML_DEADPOOL"																										},      // 20
	{	"ML_SECRET_OF_VAMPIRE",		"ML_D_SECRET_OF_VAMPIRE",	"120",      ""																																			},      // 21
	{	"ML_SECRET_OF_SHAMAN",		"ML_D_SECRET_OF_SHAMAN",	"90",       ""																																			},      // 22
	{	"ML_JET_PACK",			"ML_D_JET_PACK",		"40",       "ML_KURWA:ML_WARIOR:ML_IRON_MAN:ML_DEADPOOL:ML_JUMPER"																												},      // 23
	{	"ML_SUPER_JET_PACK",		"ML_D_SUPER_JET_PACK",		"80",       "ML_KURWA:ML_WARIOR:ML_IRON_MAN:ML_DEADPOOL:ML_JUMPER"																												},      // 24
	{	"ML_DEAGLE_AIM",		"ML_D_DEAGLE_AIM",		"135",      ""																																			},      // 25
	{	"ML_SECRET_OF_RAMBO",		"ML_D_SECRET_OF_RAMBO",		"125",      ""																																			},      // 26
	{	"ML_DEAGLE_MANIAC",		"ML_D_DEAGLE_MANIAC",		"70",       ""																																			},      // 27
	{	"ML_WALL_CLIMB",		"ML_D_WALL_CLIMB",		"270",      "ML_PRO_NINJA"																																	},      // 28
	{	"ML_HS_IMMUNITY",		"ML_D_HS_IMMUNITY",		"75",       "ML_PRO_SHOOTER2"                                                                                                                                                                                                                                                                                                         },
	{	"ML_HS_ONLY",		         "ML_D_HS_ONLY",		         "75",       ""                                                                                                                                                                                                                                                                                                                          },      // 29
	{	"ML_M3_PRO",			"ML_D_M3_PRO",			"160",      ""																																			},      // 30
	{	"ML_BULLET_PROOF",		"ML_D_BULLET_PROOF",		"115",      "ML_DEMOLITIONS:ML_COMRADE_TITO:ML_VIN_DIESEL:ML_IRON_MAN"																												},      // 31
	{	"ML_SUPRISE_ENEMIES",		"ML_D_SUPRISE_ENEMIES",		"270",      ""																																			},      // 32
	{	"ML_RESPAWN",			"ML_D_RESPAWN",			"70",       "" 																																			},      // 33
	{	"ML_GRAVITY",			"ML_D_GRAVITY",			"45",       ""																																			},      // 34
	{	"ML_PLUS_100AP",		"ML_D_PLUS_100AP",		"210",      ""																																			},      // 35
	{	"ML_SCOUT_EXPERT",		"ML_D_SCOUT_EXPERT",		"165",      "ML_FBI"																																		},      // 36
	{	"ML_PLUS_10XP",			"ML_D_PLUS_10XP",		"290",      ""																																			},      // 37
	{	"ML_KNIFE_RESISTANCE",		"ML_D_KNIFE_RESISTANCE", 	"140",      "ML_SWAT:ML_KILLER:ML_PRO_SWAT:ML_VIN_DIESEL:ML_WARIOR:ML_ROBIN_HOOD:ML_OFFICER"																									},      // 38
	{	"ML_HE_EXPERT",			"ML_D_HE_EXPERT", 		"399",      ""																																			}       // 39
};

new g_iPerks[ StructPerks ];
new g_iPlayerInfo[ 33 ][ StructPlayerInfo ];

new const g_szPlayerModels[ ][ ][ ] = {
	// Terrorist models
	{	"arctic",	"leet",		"guerilla",	"terror"	},
	
	// Counter-Terrorist models
	{	"sas",		"gsg9",		"urban",	"gign"		}
};

new const g_iMaxClip[ 31 ] = {
	-1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
	10,  30, 100,  8, 30,  30, 20,  1,  7, 30, 30, -1,  50
};

new g_iMessageFOV;
new g_iMaxPlayers;

//=================================================================================================
//				 	Plugin Initialisation
//=================================================================================================
public plugin_init( ) {
	register_plugin( "[ByM] Cod 2016: Perks", "7.0.0", "Milutinke (ByM)" );
	
	g_iMaxPlayers = get_maxplayers( );
	
	// Ham Module Forwards
	RegisterHam( Ham_Killed, "player", "fw_HamPlayerDeath" );
	RegisterHam( Ham_TakeDamage, "player", "fw_HamTakeDamagePre" );
	
	// Messages
	g_iMessageFOV = get_user_msgid( "SetFOV" );

	// Language System
	register_dictionary( "Cod_Perks.txt" );
	
	// Register Perks
	for( new StructPerks: iIterator = SilentBoots; iIterator < StructPerks; iIterator ++ )
		g_iPerks[ iIterator ] = cod_register_perk( g_szPerks[ iIterator ][ 0 ], g_szPerks[ iIterator ][ 1 ], str_to_num( g_szPerks[ iIterator ][ 2 ] ), g_szPerks[ iIterator ][ 3 ] );

	// Commands
	register_clcmd( "say /updateperk", "UpdatePerk" );
}

//=================================================================================================
//				 	Events and Forwards, etc...
//=================================================================================================
public cod_abilities_set_pre( iPlayer, iClass ) {
	if( is_user_alive( iPlayer ) ) {
		cs_reset_player_model( iPlayer );
		set_user_footsteps( iPlayer, 0 );
	}
	
	bym_reset_everything( iPlayer );
}

public UpdatePerk( iPlayer ) {
	g_iPlayerInfo[ iPlayer ][ g_iPerk ] = cod_get_perk( iPlayer );
}

public cod_perk_got( iPlayer, iPerk ) {
	g_iPlayerInfo[ iPlayer ][ g_iPerk ] = iPerk;
	
	SetAbilities( iPlayer, iPerk );
} 

public cod_perk_changed( iPlayer, iOldPerk, iNewPerk ) {
	g_iPlayerInfo[ iPlayer ][ g_iPerk ] = iNewPerk;
	
	SetAbilities( iPlayer, iNewPerk );
}

public cod_abilities_set_post( iPlayer ) {
	SetAbilities( iPlayer, cod_get_perk( iPlayer ) );
}

public SetAbilities( iPlayer, iPerk ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	if( iPerk == g_iPerks[ SilentBoots ] )
		set_user_footsteps( iPlayer );
		
	if( iPerk == g_iPerks[ SecretOfMarine ] )
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 ); // 1/1
		
	if( iPerk == g_iPerks[ AwpMaster ] ) {
		give_item( iPlayer, "weapon_awp" );
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 ); // 1/1
	}
	
	if( iPerk == g_iPerks[ DoubleJump ] || iPerk == g_iPerks[ TripleJump ] )
		bym_set_multi_jump( iPlayer, iPerk == g_iPerks[ DoubleJump ] ? 2 : 3 );
	
	if( iPerk == g_iPerks[ M4Swat ] || iPerk == g_iPerks[ M4Aim ] ) {
		give_item( iPlayer, "weapon_m4a1" );
		
		if( iPerk == g_iPerks[ M4Swat ] )
			bym_set_instant_kill( iPlayer, CSW_M4A1, 4 ); // 1/4
			
		if( iPerk == g_iPerks[ M4Aim ] )
			bym_set_aim( iPlayer, CSW_M4A1, 4 );
	}
		
	if( iPerk == g_iPerks[ Ak47Aim ] ) {
		give_item( iPlayer, "weapon_ak47" );
		bym_set_aim( iPlayer, CSW_AK47, 4 );
	}
		
	if( iPerk == g_iPerks[ M3Pro ] ) {
		give_item( iPlayer, "weapon_m3" );
		bym_set_instant_kill( iPlayer, CSW_M3, 4 );
	}
		
	if( iPerk == g_iPerks[ DeagleManiac ] || iPerk == g_iPerks[ DeagleAim ] ) {
		give_item( iPlayer, "weapon_deagle" );
		
		if( iPerk == g_iPerks[ DeagleManiac ] )
			bym_set_instant_kill( iPlayer, CSW_DEAGLE, 5 );
			
		if( iPerk == g_iPerks[ DeagleAim ] )
			bym_set_aim( iPlayer, CSW_DEAGLE, 3 );
	}
		
	if( iPerk == g_iPerks[ BulletProof ] )
		bym_set_bullet_proof( iPlayer, 3 );
		
	if( iPerk == g_iPerks[ Camouflage ] ) {
		give_item( iPlayer, "weapon_hegrenade" );
		SetCamouflage( iPlayer );
	}
	
	if( iPerk == g_iPerks[ SupriseEnemies ] )
		give_item( iPlayer, "weapon_flashbang" );
		
	if( iPerk == g_iPerks[ Gravity ] )
		entity_set_float( iPlayer, EV_FL_gravity, 0.65 );
		
	if( iPerk == g_iPerks[ Plus100Ap ] )
		entity_set_float( iPlayer, EV_FL_armorvalue, entity_get_float( iPlayer, EV_FL_armorvalue ) + 100.0 );
		
	if( iPerk == g_iPerks[ ScoutExpert ] ) {
		give_item( iPlayer, "weapon_scout" );
		bym_set_instant_kill( iPlayer, CSW_SCOUT, 1 ); // 1/1
	}
	
	if( iPerk == g_iPerks[ JetPack ] )
		bym_set_jetpack( iPlayer, JETPACK_SUPER );
		
	if( iPerk == g_iPerks[ SuperJetPack ] )
		bym_set_jetpack( iPlayer, JETPACK_SUPER );
		
	if( iPerk == g_iPerks[ SecretOfAssassin ] )
		bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, 255 );
		
	if( iPerk == g_iPerks[ WallClimb ] )
		bym_set_wall_climbing( iPlayer, WALL_CLIMB_ON );

	if( iPerk == g_iPerks[ Magician ] )
		bym_set_magician( iPlayer, NO_WEAPON, 8, 255 );
		
	if( iPerk == g_iPerks[ KnifeResistance ] )
		bym_set_resistance( iPlayer, CSW_KNIFE, 1 );
		
	if( iPerk == g_iPerks[ HsImmunity ] )
		bym_set_hs_immunity( iPlayer, 1 );
		
	if( iPerk == g_iPerks[ Xray ] )
		bym_set_xray( iPlayer, XRAY_ON );
		
	if( iPerk == g_iPerks[ FastReload ] )
		bym_set_fast_reload( iPlayer, FAST_RELOAD_ON );
		
	if( iPerk == g_iPerks[ NoRecoil ] )
		bym_set_no_recoil( iPlayer, NO_RECOIL_ON );
		
	if( iPerk == g_iPerks[ HeExpert ] )
		give_item( iPlayer, "weapon_hegrenade" );
} 

public fw_HamTakeDamagePre( iVictim, iInflictor, iAttacker, Float: fDamage, iDamageType ) {
	if( !is_user_connected( iAttacker ) || !is_user_alive( iAttacker ) || !( 1 <= iAttacker <= g_iMaxPlayers ) || ( iAttacker == iVictim ) )
		return HAM_IGNORED;
		
	if( !is_user_connected( iVictim ) || !is_user_alive( iVictim ) || g_iPlayerInfo[ iVictim ][ g_iPerk ] == g_iPerks[ SwatShield ] )
		return HAM_IGNORED;
	
	if( g_iPlayerInfo[ iVictim ][ g_iPerk ] == g_iPerks[ HeResistance ] && ( iDamageType & ( 1 << 24 ) ) )
		return HAM_SUPERCEDE;
		
	new Float: fHealth = entity_get_float( iVictim, EV_FL_health );
	
	if( g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ SupriseEnemies ] && bym_is_shooting_at_back( iAttacker, iVictim ) ) 
		fDamage *= 2;
	
	if( g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ SecretOfShaman ] && Chance( 6 ) ) {
		message_begin( MSG_ONE, g_iMessageFOV, { 0, 0, 0 }, iVictim );
		write_byte( 180 );
		message_end( );
	}
	
	if( g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ MilitarySecret ] && Chance( 5 ) )
		bym_screen_fade( iVictim, ( 1 << 14 ), ( 1 << 14 ), ( 1 << 16 ), 255, 155, 50, 230 );
		
	if( ( g_iPlayerInfo[ iVictim ][ g_iPerk ] == g_iPerks[ ReactiveArmor ] ) && Chance( 6 ) ) {
		ExecuteHam( Ham_TakeDamage, iAttacker, iVictim, iVictim, fDamage, 1 );
		return HAM_SUPERCEDE;
	}
		
	if( g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ TitaniumBullets ] || g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ BulletsOfColonel ] )
		fDamage += g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ TitaniumBullets ] ? 10 : 15;
		
	if( g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ Camouflage ] && Chance( 3 ) && ( iDamageType & ( 1 << 24 ) ) )
		fDamage = fHealth;
		
	if( g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ HeExpert ] && get_user_weapon( iAttacker ) == CSW_HEGRENADE )
		fDamage = fHealth;
	 
	SetHamParamFloat( 4, fDamage );
	return HAM_IGNORED;
}

public fw_HamPlayerDeath( iVictim, iAttacker, iSh ) {	
	if( is_user_connected( iVictim ) && g_iPlayerInfo[ iVictim ][ g_iPerk ] == g_iPerks[ Respawn ] && Chance( 7 ) )
		set_task( 0.2, "fw_Respawn", iVictim + TASK_REVIVE );
		
	if( is_user_connected( iAttacker ) ) {
		if( g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ Plus10XP ] )
			cod_set_xp( iAttacker, cod_get_xp( iAttacker ) + 10 );
	}
	
	if( is_user_connected( iAttacker ) && g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ SecretOfVampire ] && is_user_alive( iAttacker ) && ( g_iMaxClip[ get_user_weapon( iAttacker ) ] != -1 ) ) {
		entity_set_float( iAttacker, EV_FL_health, ( ( ( floatround( entity_get_float( iAttacker, EV_FL_health ) ) + 20 ) < cod_get_player_max_hp(  iAttacker ) ) ? entity_get_float( iAttacker, EV_FL_health ) + 20.0 : float( cod_get_player_max_hp( iAttacker ) ) ) );
	}
	
	if( is_user_connected( iAttacker ) && g_iPlayerInfo[ iAttacker ][ g_iPerk ] == g_iPerks[ SecretOfRambo ] && is_user_alive( iAttacker ) ) {
		bym_set_weapon_clip( iAttacker, g_iMaxClip[ get_user_weapon( iAttacker ) ] );
		entity_set_float( iAttacker, EV_FL_health, ( ( ( floatround( entity_get_float( iAttacker, EV_FL_health ) ) + 40 ) < cod_get_player_max_hp(  iAttacker ) ) ? entity_get_float( iAttacker, EV_FL_health ) + 40.0 : float( cod_get_player_max_hp( iAttacker ) ) ) );
	}
}

public fw_Respawn( iTask ) {
	new iPlayer = iTask - TASK_REVIVE;
	
	if( is_user_connected( iPlayer ) )
		ExecuteHamB( Ham_CS_RoundRespawn, iPlayer );
}

//=================================================================================================
//				 	Clear data
//=================================================================================================

public client_putinserver( iPlayer ) {
	for( new iIterator = 0; iIterator < StructPlayerInfo; iIterator ++ )
		g_iPlayerInfo[ iPlayer ][ iIterator ] = 0;
		
	if( task_exists( iPlayer + TASK_REVIVE ) )
		remove_task( iPlayer + TASK_REVIVE );
}

public client_disconnected( iPlayer ) {
	for( new iIterator = 0; iIterator < StructPlayerInfo; iIterator ++ )
		g_iPlayerInfo[ iPlayer ][ iIterator ] = 0;
		
	if( task_exists( iPlayer + TASK_REVIVE ) )
		remove_task( iPlayer + TASK_REVIVE );
}

//=================================================================================================
//				 	 Stocks
//=================================================================================================
stock SetCamouflage( iPlayer ) {
	//if( !IsPlayer->Connected( iPlayer ) || !IsPlayer->Alive( iPlayer ) )
	if( !is_user_alive( iPlayer ) )
		return;
		
	cs_reset_player_model( iPlayer );
		
	switch( cs_get_user_team( iPlayer ) ) {
		case CS_TEAM_CT: cs_set_player_model( iPlayer, g_szPlayerModels[ 0 ][ random_num( 0, 3 ) ] );
		case CS_TEAM_T: cs_set_player_model( iPlayer, g_szPlayerModels[ 1 ][ random_num( 0, 3 ) ] );
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
