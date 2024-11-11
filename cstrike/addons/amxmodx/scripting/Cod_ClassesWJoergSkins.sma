//=================================================================================================
//				 	Libraries
//=================================================================================================

//#include < bym_api > // Removed, because I am using Framework now
#include < amxmodx >
#include < hamsandwich >
#include < bym_cod_2016 >
#include < cs_player_models_api >
#include < fakemeta >
#include < cstrike >
#include < engine >
#include < fun >

#include < bym_framework >
#include < cod_secoundary_weapons >

//=================================================================================================
//				 	Macors
//=================================================================================================

// Other
#define Struct			enum
#define TASK_NOCLIP_OFF		3431

//=================================================================================================
//				 	Structures
//=================================================================================================
Struct StructClasses {
	// Ordinary classes
	Marine,
         Exekuttor,
	 MiniTerminator,
	HeadShooter,
	Kamikaze,
	SWAT,
	Price,
	Sandman,
	ProShooter,
	Attacker,
	ProMiner,
	Solider,
	JSO,
	OPS,
	Rambo,
	Gunner,
	FireSupport,
	Sniperman,
	Crysis,
	Partisan,
	Phantom,
	Ironman,
	
	// Steam Only Classes
	Froki,
	ExekuttorL,
	Adrenaline,
	
	// Premium Classes
	Cadet,
	General,
	Assassin,
	ExekuttorXL,
	Hitler,
	SergeantMajor,
	Vojskovodja,
	Officer,
	Admiral,
	VasiliZaitsev,
	JohnWayane,
	ProSwat,
	
	// Super Classes
	Hitman,
	Indian,
	Simke,
	ReanimatorXXL,
	ExekuttorXXL,
	Camper,
	TerminatorXXL,
	Mordereca,
	MadMax,
	Destroyer,
	Ninja,
	Rocker,
	
	// Extra Premium Classes
	Ghost,
	Glacier,
	Shredder,
	Tokelian,
	Prosiak,
	JoergSprave,
	Psikopaktik,
	Predator,
	TerminatorXXXLUltimate,
	Wolverine,
	ProAssassin,
	Frankestein,
	
	// Vip Classes
	Taliban,
	Jumper,
	Samurai,
	Warior
}

Struct _:StructPlayerInfo {
	g_iClass,
	
	g_iTeam,
	g_iPowersNumber,
	g_iCountdown,
	g_iEnergy,
	g_iHasFootKick,
	g_iFootKick,
	g_iSkipModelChange
}

Struct _:StructModels {
	Model_KatanaV,
	Model_KatanaP,
	Model_HandsV,
	Model_HandsP,
	Model_ClawsV,
	Model_ClawsP,
	Model_CrossbowP,
         Model_CrossbowV,
	Model_JoergMiniP,
         Model_JoergMiniV,
         Model_JoergKnifeV,
	Model_DoubleCrossbowV,
	Model_RepeatingCrossbowP,
	Model_RepeatingCrossbowV,
	Model_Foot,
	Model_Guitar,
	Model_PhantomKnife,
	Model_PredatorScout,
	Model_HitmanUSP,
	Model_Predator,
	Model_Hitman
}

new const g_iMaxClip[ 31 ] = {
	-1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
	10,  30, 100,  8, 30,  30, 20,  1,  7, 30, 30, -1,  50
};
//=================================================================================================
//				 	Variables
//=================================================================================================

new const g_szClasses[ StructClasses ][ 10 ][ ] = {
	// Ordinary classes
	// 	Name			Description		Faction			Weapons			Flag	Speed	HP	AP	Visibility	Price
	{	"ML_MARINE",		"ML_D_MARINE",		"ML_ORDIRARY_CLASSES",	"tmp:deagle",		"",	"1.55",	"140",	"100",	"255",		"0"		},
	{        "ML_EXEKUTTOR",	         "ML_D_EXEKUTTOR",	"ML_ORDIRARY_CLASSES",	"xm1014:glock18",	"",	"1.3",	"120",	"100",	"255",		"0"		},
	{        "ML_MINI_TERMINATOR",	"ML_D_MINI_TERMINATOR",	"ML_ORDIRARY_CLASSES",	"scout:deagle:knife",	"",	"1.2",	"130",	"120",	"255",		"0"		},
	{	"ML_HEAD_SHOOTER",	"ML_D_HEAD_SHOOTER",	"ML_ORDIRARY_CLASSES",	"galil:p228",		"",	"1.3",	"150",	"100",	"255",		"0"		},
	{	"ML_KAMIKAZE",		"ML_D_KAMIKAZE",	"ML_ORDIRARY_CLASSES",	"ump45:glock18",	"",	"1.5",	"130",	"100",	"255",		"0"		},
	{	"ML_SWAT",		"ML_D_SWAT",		"ML_ORDIRARY_CLASSES",	"m4a1:usp",		"",	"1.2",	"100",	"100",	"255",		"0"		},
	{	"ML_PRICE",		"ML_D_PRICE",		"ML_ORDIRARY_CLASSES",	"usp:knife",		"",	"1.2",	"100",	"100",	"255",		"0"		},
	{	"ML_SANDMAN",		"ML_D_SANDMAN",		"ML_ORDIRARY_CLASSES",	"m4a1:usp",		"",	"1.8",	"105",	"100",	"255",		"0"		},
	{	"ML_PRO_SHOOTER",	"ML_D_PRO_SHOOTER",	"ML_ORDIRARY_CLASSES",	"m4a1:awp",		"",	"1.2",	"120",	"100",	"255",		"0"		},
	{	"ML_ATTACKER",		"ML_D_ATTACKER",	"ML_ORDIRARY_CLASSES",	"xm1014:p90:usp",	"",	"1.3",	"120",	"100",	"255",		"0"		},
	{	"ML_PRO_MINER",		"ML_D_PRO_MINER",	"ML_ORDIRARY_CLASSES",	"p90:deagle",		"",	"1.2",	"100",	"100",	"255",		"0"		},
	{	"ML_SOLDIER",		"ML_D_SOLDIER",		"ML_ORDIRARY_CLASSES",	"famas:p228",		"",	"1.5",	"110",	"100",	"255",		"0"		},
	{	"ML_JSO",		"ML_D_JSO",		"ML_ORDIRARY_CLASSES",	"ak47:mp5navy:elite",	"",	"1.8",	"100",	"100",	"255",		"0"		},
	{	"ML_OPS",		"ML_D_OPS",		"ML_ORDIRARY_CLASSES",	"deagle:shield",	"",	"1.2",	"100",	"100",	"255",		"0"		},
	{	"ML_RAMBO",		"ML_D_RAMBO",		"ML_ORDIRARY_CLASSES",	"m249:fiveseven",	"",	"1.35",	"130",	"100",	"255",		"0"		},
	{	"ML_GUNNER",		"ML_D_GUNNER",		"ML_ORDIRARY_CLASSES",	"g3sg1:usp",		"",	"1.5",	"125",	"100",	"255",		"0"		},
	{	"ML_FIRE_SUPPORT",	"ML_D_FIRE_SUPPORT",	"ML_ORDIRARY_CLASSES",	"mp5navy:hegrenade",	"",	"1.2",	"105",	"100",	"255",		"0"		},
	{	"ML_SNIPERMAN",		"ML_D_SNIPERMAN",	"ML_ORDIRARY_CLASSES",	"awp:deagle",		"",	"1.4",	"120",	"100",	"70",		"0"		},
	{	"ML_CRYSIS",		"ML_D_CRYSIS",		"ML_ORDIRARY_CLASSES",	"m4a1:sg550:deagle",	"",	"1.6",	"110",	"100",	"255",		"0"		},
	{	"ML_PARTISAN",		"ML_D_PARTISAN",	"ML_ORDIRARY_CLASSES",	"p90:glock18",		"",	"1.3",	"100",	"100",	"70",		"0"		},
	{	"ML_PHANTOM",		"ML_D_PHANTOM",		"ML_ORDIRARY_CLASSES",	"deagle:knife",		"",	"1.4",	"110",	"100",	"255",		"0"		},
	{	"ML_IRONMAN",		"ML_D_IRONMAN",		"ML_ORDIRARY_CLASSES",	"mp5navy:aug:usp",	"",	"1.5",	"100",	"100",	"255",		"0"		},
	
	// Steam Only Classes
	{	"ML_FROKI",		"ML_D_FROKI",		"ML_STEAM_CLASSES",	"awp:deagle",		"$",	"1.0",	"100",	"100",	"255",		"0"		},
	{	"ML_EXEKUTTOR_L",	"ML_D_EXEKUTTOR_L",	"ML_STEAM_CLASSES",	"xm1014:glock18",	"$",	"1.3",	"200",	"300",	"255",		"0"		},
	{	"ML_ADRENALINE",	"ML_D_ADRENALINE",	"ML_STEAM_CLASSES",	"m4a1:deagle",		"$",	"1.2",	"120",	"100",	"255",		"0"		},
	
	// Premium Classes
	{	"ML_CADET",		"ML_D_CADET",		"ML_PREMIUM_CLASSES",	"usp:knife",		"a",	"1.15",	"160",	"100",	"255",		"0"		},
	{	"ML_GENERAL",		"ML_D_GENERAL",		"ML_PREMIUM_CLASSES",	"famas:glock18",	"b",	"1.25",	"150",	"100",	"255",		"0"		},
	{	"ML_ASSASSIN",		"ML_D_ASSASSIN",	"ML_PREMIUM_CLASSES",	"famas:glock18",	"c",	"1.1",	"100",	"100",	"255",		"0"		},
	{	"ML_EXEKUTTOR_XL",	"ML_D_EXEKUTTOR_XL",	"ML_PREMIUM_CLASSES",	"xm1014:glock18",	"c",	"1.8",	"200",	"300",	"255",		"0"		},
	{	"ML_HITLER",		"ML_D_HITLER",		"ML_PREMIUM_CLASSES",	"ak47:deagle",		"d",	"1.2",	"350",	"100",	"255",		"0"		},
	{	"ML_SERGEANT_MAJOR",	"ML_D_SERGEANT_MAJOR",	"ML_PREMIUM_CLASSES",	"ak47:xm1014:usp",	"e",	"1.3",	"130",	"100",	"80",		"0"		},
	{	"ML_VOJSKOVODJA",	"ML_D_VOJSKOVODJA",	"ML_PREMIUM_CLASSES",	"mp5navy:ump45",	"f",	"0.95",	"160",	"100",	"255",		"0"		},
	{	"ML_OFFICER",		"ML_D_OFFICER",		"ML_PREMIUM_CLASSES",	"m4a1:tmp:p228",	"g",	"1.3",	"150",	"100",	"255",		"0"		},
	{	"ML_ADMIRAL",		"ML_D_ADMIRAL",		"ML_PREMIUM_CLASSES",	"m4a1:p228",		"h",	"1.2",	"120",	"100",	"255",		"0"		},
	{	"ML_VASILI_ZAITSEV",	"ML_D_VASILI_ZAITSEV",	"ML_PREMIUM_CLASSES",	"awp:deagle",		"i",	"1.25",	"200",	"100",	"255",		"0"		},
	{	"ML_JOHN_WAYANE",	"ML_D_JOHN_WAYANE",	"ML_PREMIUM_CLASSES",	"elite:knife",		"j",	"1.3",	"150",	"100",	"255",		"0"		},
	{	"ML_PRO_SWAT",		"ML_D_PRO_SWAT",	"ML_PREMIUM_CLASSES",	"m4a1:deagle",		"k",	"1.2",	"120",	"100",	"255",		"0"		},
	
	// Super Classes
	{	"ML_HITMAN",		"ML_D_HITMAN",		"ML_SUPER_CLASSES",	"usp:knife",		"m",	"1.3",	"200",	"100",	"255",		"0"		},
	{	"ML_INDIAN",		"ML_D_INDIAN",		"ML_SUPER_CLASSES",	"usp:knife",		"n",	"1.0",	"100",	"100",	"255",		"0"		},
	{	"ML_SIMKE",		"ML_D_SIMKE",		"ML_SUPER_CLASSES",	"elite:deagle:usp",	"p",	"2.0",	"200",	"100",	"255",		"0"		},
	{	"ML_REANIMATOR_XXL",	"ML_D_REANIMATOR_XXL",	"ML_SUPER_CLASSES",	"mp5navy:glock18",	"p",	"3.0",	"250",	"50",	"255",		"0"		},
	{	"ML_EXEKUTTOR_XXL",	"ML_D_EXEKUTTOR_XXL",	"ML_SUPER_CLASSES",	"xm1014:glock18",	"p",	"2.5",	"200",	"300",	"255",		"0"		},
	{	"ML_CAMPER",		"ML_D_CAMPER",		"ML_SUPER_CLASSES",	"awp:deagle",	         "p",	"1.7",	"150",	"200",	"255",		"0"		},
	{	"ML_TERMINATOR_XXL",	"ML_D_TERMINATOR_XXL",	"ML_SUPER_CLASSES",	"scout:awp:deagle",	"p",	"2.3",	"250",	"300",	"255",		"0"		},
	{	"ML_MORDERECA",		"ML_D_MORDERECA",	"ML_SUPER_CLASSES",	"hegrenade:mp5navy:fiveseven",	         "p",	"2.9",	"350",	"480",	"255",		"0"		},
	{	"ML_MAD_MAX",		"ML_D_MAD_MAX",		"ML_SUPER_CLASSES",	"galil:usp:hegrenade",	"q",	"2.5",	"200",	"100",	"255",		"0"		},
	{	"ML_DESTROYER",		"ML_D_DESTROYER",	"ML_SUPER_CLASSES",	"ak47:deagle",		"r",	"1.0",	"100",	"100",	"255",		"0"		},
	{	"ML_NINJA",		"ML_D_NINJA",		"ML_SUPER_CLASSES",	">Katana:glock18",	"s",	"2.6",	"100",	"120",	"255",		"0"		},
	{	"ML_ROCKER",		"ML_D_ROCKER",		"ML_SUPER_CLASSES",	">Guitar:usp",		"t",	"1.1",	"150",	"110",	"255",		"0"		},
	
	// Extra Premium Classes
	{	"ML_GHOST",		"ML_D_GHOST",		"ML_EXTRA_P_CLASSES",	"awp:xm1014:usp",	"u",	"1.5",	"50",	"110",	"255",		"0"		},
	{	"ML_GLACIER",		"ML_D_GLACIER",		"ML_EXTRA_P_CLASSES",	"ak47:m4a1:usp",	"v",	"1.6",	"200",	"110",	"255",		"0"		},
	{	"ML_SHREDDER",		"ML_D_SHREDDER",	"ML_EXTRA_P_CLASSES",	"ak47:deagle",		"w",	"1.5",	"150",	"120",	"8",		"0"		},
	{	"ML_TOKELIAN",		"ML_D_TOKELIAN",	"ML_EXTRA_P_CLASSES",	"m4a1:hegrenade:awp:deagle",	"y",	"1.0",	"500",	"200",	"255",		"0"		},
	{	"ML_PROSIAK",		"ML_D_PROSIAK",	         "ML_EXTRA_P_CLASSES",	"awp:deagle",	         "y",	"2.1",	"500",	"200",	"255",		"0"		},
	{	"ML_JOERG_SPRAVE",	"ML_D_JOERG_SPRAVE",	"ML_EXTRA_P_CLASSES",	">Crossbow:>CombatAxe:>JoergMini:>doublecrossbow:>RepeatingCrossbow",	"y",	"0.9",	"350",	"600",	"255",		"0"		},
	{	"ML_PSIKOPAKTIK",	"ML_D_PSIKOPAKTIK",	"ML_EXTRA_P_CLASSES",	"usp:knife",	         "y",	"7",	"25",	"0",	"5",		"0"		},
	{	"ML_PREDATOR",		"ML_D_PREDATOR",	"ML_EXTRA_P_CLASSES",	">SperaGun:xm1014",		"y",	"1.5",	"250",	"150",	"255",		"0"		},
	{	"ML_TERMINATOR_XXXL_ULTIMATE",		"ML_D_TERMINATOR_XXXL_ULTIMATE",	"ML_EXTRA_P_CLASSES",	"scout:hegrenade:m249:glock18:mp5navy:deagle:m4a1:awp:galil:famas:p90:aug:g3sg1",		"y",	"50",	"1000",	"1000",	"1",		"0"		},
	{	"ML_WOLVERINE",		"ML_D_WOLVERINE",	"ML_EXTRA_P_CLASSES",	">Claws:deagle",	"z",	"1.5",	"120",	"120",	"25",		"0"		},
	{	"ML_PRO_ASSASSIN",	"ML_D_PRO_ASSASSIN",	"ML_EXTRA_P_CLASSES",	"deagle:usp:mp5navy",	"0",	"1.4",	"120",	"100",	"1",		"0"		},
	{	"ML_FRANKESTEIN",	"ML_D_FRANKESTEIN",	"ML_EXTRA_P_CLASSES",	"ak47:m4a1:usp",	"1",	"2.0",	"150",	"100",	"255",		"0"		},
	
	// Vip Classes
	{	"ML_TALIBAN",		"ML_D_TALIBAN",		"ML_VIP_CLASSES",	"ak47:usp",		"#",	"1.5",	"120",	"100",	"255",		"0"		},
	{	"ML_JUMPER",		"ML_D_JUMPER",		"ML_VIP_CLASSES",	"mp5navy:elite",	"#",	"1.5",	"200",	"120",	"255",		"0"		},
	{	"ML_SAMURAI",		"ML_D_SAMURAI",		"ML_VIP_CLASSES",	">Katana:deagle",	"#",	"1.5",	"120",	"120",	"255",		"0"		},
	{	"ML_WARIOR",		"ML_D_WARIOR",		"ML_VIP_CLASSES",	"famas:deagle",		"#",	"1.2",	"110",	"150",	"255",		"0"		}
};

new g_iClasses[ StructClasses ];
new g_iPlayerInfo[ 33 ][ StructPlayerInfo ];

new const g_szModels[ StructModels ][ ] = {
	"models/ByM_Cod/v_katana.mdl",
	"models/ByM_Cod/p_katana.mdl",
	"models/ByM_Cod/v_wolverine.mdl",
	"models/ByM_Cod/p_wolverine.mdl",
	"models/ByM_Cod/v_wolverine_claws.mdl",
	"models/ByM_Cod/p_wolverine_claws.mdl",
	"models/ByM_Cod/p_crossbow.mdl",
	"models/ByM_Cod/v_crossbow.mdl",
	"models/ByM_Cod/p_joergmini.mdl",
	"models/ByM_Cod/v_joergmini.mdl",
	"models/ByM_Cod/v_joergknife.mdl",
	"models/ByM_Cod/v_doublecrossbow.mdl",
	"models/ByM_Cod/p_repeatingcrossbow.mdl",
	"models/ByM_Cod/v_repeatingcrossbow.mdl",
	"models/ByM_Cod/v_foot.mdl",
	"models/ByM_Cod/v_guitar.mdl",
	"models/ByM_Cod/v_phantom_knife.mdl",
	"models/ByM_Cod/v_predator_scout.mdl",
	"models/ByM_Cod/v_hitman_usp.mdl",
	"models/player/Cod_Predator/Cod_Predator.mdl",
	"models/player/Cod_Hitman/Cod_Hitman.mdl"
};

new const g_szPlayerModels[ ][ ][ ] = {
	// Terrorist models
	{	"arctic",	"leet",		"guerilla",	"terror"	},
	
	// Counter-Terrorist models
	{	"sas",		"gsg9",		"urban",	"gign"		}
};

new const g_szSounds[ ][ ] = {
	"weapons/hit1_wolverine.wav",
	"weapons/hit2_wolverine.wav",
	"weapons/hit3_wolverine.wav",
	"weapons/hit4_wolverine.wav",
	"weapons/wall1_wolverine.wav",
	"weapons/wall2_wolverine.wav",
	"weapons/claws_off_wolverine.wav"
};

new g_iModelIndex[ StructModels ];

native cod_give_compound_bow( iPlayer );
native cod_get_compound_bow( iPlayer );

new g_iMaxPlayers;

//=================================================================================================
//				 	Plugin Initialisation
//=================================================================================================
public plugin_init( ) {
	register_plugin( "[ByM] Cod 2016: Classes", "6.0.3", "Milutinke (ByM)" );
	
	g_iMaxPlayers = get_maxplayers( );
	
	// Initialise ByM API
	//ByM::Initialise( );
	
	// Ham Module Forwards
	RegisterHam( Ham_Killed, "player", "fw_HamPlayerDeath" );
	RegisterHam( Ham_TakeDamage, "player", "fw_HamTakeDamagePre" );
	RegisterHam( Ham_Player_PreThink, "player", "fw_HamPlayerPreThink" );
	
	// Fakemeta Module Forwards
	register_forward( FM_EmitSound, "fw_EmitSound" );
	register_forward( FM_SetModel, "fw_SetModel" );

	// Events
	register_event( "CurWeapon", "fw_CurWeapon", "be", "1=1" );
	
	// Language System
	register_dictionary( "Cod_Classes.txt" );
	
	// Register Classes
	for( new StructClasses: iIterator = Marine; iIterator < StructClasses; iIterator ++ )
		g_iClasses[ iIterator ] = cod_register_class( g_szClasses[ iIterator ][ 0 ], g_szClasses[ iIterator ][ 1 ], g_szClasses[ iIterator ][ 2 ], g_szClasses[ iIterator ][ 3 ], g_szClasses[ iIterator ][ 4 ], g_szClasses[ iIterator ][ 5 ], str_to_num( g_szClasses[ iIterator ][ 6 ] ), str_to_num( g_szClasses[ iIterator ][ 7 ] ), str_to_num( g_szClasses[ iIterator ][ 8 ] ), str_to_num( g_szClasses[ iIterator ][ 9 ] ) );
		
	CreateCleaner( );
}

CreateCleaner( ) {
	new iEntity = create_entity( "info_target" );
	
	if( !iEntity )
		return;
	
	entity_set_string( iEntity, EV_SZ_classname, "Cleaner" );
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 10.0 );
	
	register_think( "Cleaner", "fw_CleanerThink" );
}

public fw_CleanerThink( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return;
		
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 60.0 );

	new iEntityMine = find_ent_by_class( -1, "Mine" );
	while( iEntityMine > 0 )  {
		remove_entity( iEntityMine );
		iEntityMine = find_ent_by_class( iEntityMine, "Mine" );	
	}
	
	new iEntityBonusBox = find_ent_by_class( -1, "BonusBox" );
	while( iEntityBonusBox > 0 )  {
		remove_entity( iEntityBonusBox );
		iEntityBonusBox = find_ent_by_class( iEntityBonusBox, "BonusBox" );
	}
}

public fw_SetModel( iEntity, const szModel[ ] ) {
	if( !is_valid_ent( iEntity ) )
		return;
		
	new szClassName[ 32 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	if( !equal( szClassName, "weaponbox" ) )
		return;
	
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 0.1 );
}

//=================================================================================================
//				 	Precache
//=================================================================================================
public plugin_precache( ) {
	for( new iIterator = 0; iIterator < StructModels; iIterator ++ )
		g_iModelIndex[ iIterator ] = precache_model( g_szModels[ iIterator ] );

	for( new iSounds = 0; iSounds < sizeof( g_szSounds ); iSounds ++ )
		precache_sound( g_szSounds[ iSounds ] );
}

//=================================================================================================
//				 	Events and Forwards, etc...
//=================================================================================================
public cod_abilities_set_pre( iPlayer, iClass ) {
	if( is_user_alive( iPlayer ) ) {
		cs_reset_player_model( iPlayer );
		set_user_footsteps( iPlayer, 0 );
	}

	g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] = 0;
	g_iPlayerInfo[ iPlayer ][ g_iHasFootKick ] = 0;
	g_iPlayerInfo[ iPlayer ][ g_iSkipModelChange ] = 0;
	
	cod_set_weapon_pickup( iPlayer, 0 );
	cod_get_compound_bow( iPlayer );
	
	bym_reset_everything( iPlayer );
	cod_reset_secondary_weapons( iPlayer );
	
	g_iPlayerInfo[ iPlayer ][ g_iTeam ] = get_user_team( iPlayer );
}

public cod_class_pre_selected( iPlayer, iClass ) {
	return 1;
}

public cod_abilities_set_post( iPlayer, iClass ) {
	g_iPlayerInfo[ iPlayer ][ g_iClass ] = iClass;
	SetAbilities( iPlayer, iClass );
}

public cod_class_selected( iPlayer, iClass ) {
	g_iPlayerInfo[ iPlayer ][ g_iClass ] = iClass;
	SetAbilities( iPlayer, iClass );
}

public cod_class_changed( iPlayer, iOldClass, iNewClass ) {
	g_iPlayerInfo[ iPlayer ][ g_iClass ] = iNewClass;
}

public cod_used_ability( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	if( g_iPlayerInfo[ iPlayer ][ g_iClass ] == g_iClasses[ Wolverine ] ) {
		if( get_user_weapon( iPlayer) != CSW_KNIFE )
			engclient_cmd( iPlayer, "weapon_knife" );
				
		entity_set_string( iPlayer, EV_SZ_viewmodel, ( ( g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] == 0 ) ? g_szModels[ Model_ClawsV ] : g_szModels[ Model_HandsV ] ) );
		entity_set_string( iPlayer, EV_SZ_weaponmodel, ( ( g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] == 0 ) ? g_szModels[ Model_ClawsP ] : g_szModels[ Model_HandsP ] ) );
				
		entity_set_float( iPlayer, EV_FL_speed, ( ( g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] == 0 ) ? ( entity_get_float( iPlayer, EV_FL_speed ) + 5.0 ) : ( entity_get_float( iPlayer, EV_FL_speed ) - 5.0 ) ) );
		entity_set_float( iPlayer, EV_FL_gravity, ( ( g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] == 0 ) ? 0.65 : 0.8 ) );
				
		emit_sound( iPlayer, CHAN_WEAPON, "ByM_Cod/claws_off_wolverine.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] = g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] ? 0 : 1;
	}

	if( g_iPlayerInfo[ iPlayer ][ g_iClass ] == g_iClasses[ Frankestein ]  && g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] > 0 ) {
		set_task( 0.1, "TurnOnClip", iPlayer, "", 0, "a", 1 );
		g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] = 0;
	}
}

public TurnOnClip( iPlayer ) {
	if( is_user_alive( iPlayer ) ) {
		set_user_noclip( iPlayer, 1 ); 
		g_iPlayerInfo[ iPlayer ][ g_iCountdown ] = 15;
	
		if( task_exists( iPlayer + TASK_NOCLIP_OFF ) )
			remove_task( iPlayer + TASK_NOCLIP_OFF );
	
		set_task( 1.0, "TurnOffClip", iPlayer + TASK_NOCLIP_OFF, _, _, "b" );
	}
}

public TurnOffClip( iTaskId ) {
	new iPlayer = iTaskId - TASK_NOCLIP_OFF;
	
	if( is_user_alive( iPlayer ) ) {
		g_iPlayerInfo[ iPlayer ][ g_iCountdown ] --;
	
		if( g_iPlayerInfo[ iPlayer ][ g_iCountdown ] > 0 )
			client_print( iPlayer, print_center, "%L %d", iPlayer, "ML_NO_CLIP", g_iPlayerInfo[ iPlayer ][ g_iCountdown ] );
		else if( g_iPlayerInfo[ iPlayer ][ g_iCountdown ] < 1 ) {
			if( task_exists( iTaskId ) )
				remove_task( iTaskId );
				
			if( is_user_alive( iPlayer ) )
				set_user_noclip( iPlayer, 0 ); 
				
			g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] = 0;
		} 
	}
}

public SetAbilities( iPlayer, iClass ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	// Perks
	if( cod_get_perk( iPlayer ) == cod_get_perk_id( "ML_SWAT_SHIELD" ) ) {
		cod_set_explosion_resistance( iPlayer, EXPLOSION_RESISTANCE_ON );
		bym_set_instant_kill_resisance( iPlayer, INSTANT_KILL_RESISTANCE_ON );
	}
	
	// Ordinary Classes
	if( iClass == g_iClasses[ Marine ] ) bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
	if( iClass == g_iClasses[ Exekuttor ] ) {
	bym_set_instant_kill( iPlayer, CSW_KNIFE, 2 );
	bym_set_instant_kill( iPlayer, CSW_XM1014, 7 );
	cod_set_rockets( iPlayer, 1, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
	}
	if( iClass == g_iClasses[ MiniTerminator ] ) {
	bym_set_instant_kill( iPlayer, CSW_DEAGLE, 7 );
	bym_set_instant_kill( iPlayer, CSW_SCOUT, 2 );
	bym_set_multi_jump( iPlayer, 2 );
	cod_set_mines( iPlayer, 1, MINE_TYPE_ORDINARY );
	}
	if( iClass == g_iClasses[ HeadShooter ] ) bym_set_aim( iPlayer, NO_WEAPON, 6 );
	if( iClass == g_iClasses[ Sniperman ] ) bym_set_instant_kill( iPlayer, CSW_AWP, 2 );
	if( iClass == g_iClasses[ Kamikaze ] ) bym_set_xray( iPlayer, XRAY_ON );
	if( iClass == g_iClasses[ SWAT ] ) bym_set_resistance( iPlayer, CSW_KNIFE, 1 );
	if( iClass == g_iClasses[ Sandman ] ) bym_set_no_recoil( iPlayer, NO_RECOIL_ON );
	if( iClass == g_iClasses[ ProShooter ] ) {
		cod_set_rockets( iPlayer, 3, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
		bym_set_instant_kill( iPlayer, CSW_AWP, 3 );
	}
	if( iClass == g_iClasses[ Attacker ] ) cod_set_dynamites( iPlayer, 3 );
	if( iClass == g_iClasses[ ProMiner ] ) cod_set_mines( iPlayer, 5, MINE_TYPE_ORDINARY );
	if( iClass == g_iClasses[ Solider ] ) {
		bym_set_bullet_proof( iPlayer, 3 );
		cod_set_rockets( iPlayer, 1, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
	}
	if( iClass == g_iClasses[ JSO ] ) bym_set_no_recoil( iPlayer, NO_RECOIL_ON );
	if( iClass == g_iClasses[ OPS ] ) bym_set_instant_kill( iPlayer, CSW_DEAGLE, 3 );
	if( iClass == g_iClasses[ Rambo ] ) bym_set_magician( iPlayer, NO_WEAPON, 8, str_to_num( g_szClasses[ Rambo ][ 8 ] ) );
	if( iClass == g_iClasses[ Gunner ] ) {
		cod_set_rockets( iPlayer, 1, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
		bym_set_no_recoil( iPlayer, NO_RECOIL_ON );
	}
	if( iClass == g_iClasses[ FireSupport ] ) {
		cod_set_rockets( iPlayer, 3, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
		SetCamouflage( iPlayer );
		g_iPlayerInfo[ iPlayer ][ g_iSkipModelChange ] = 1;
	}
	if( iClass == g_iClasses[ Crysis ] ) cod_set_rockets( iPlayer, 3, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
	if( iClass == g_iClasses[ Partisan ] ) cod_set_mines( iPlayer, 1, MINE_TYPE_ORDINARY );
	if( iClass == g_iClasses[ Phantom ] ) {
		bym_set_wall_climbing( iPlayer, WALL_CLIMB_ON );
		bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, str_to_num( g_szClasses[ Phantom ][ 8 ] ) );
	}
	if( iClass == g_iClasses[ Ironman ] ) bym_set_instant_kill( iPlayer, CSW_AUG, 11 );
	
	// Steam Only Classes
	if( iClass == g_iClasses[ Froki ] ) {
		set_user_footsteps( iPlayer, 1 );
		cod_set_rockets( iPlayer, 2, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 );
	}
	if( iClass == g_iClasses[ ExekuttorL ] ) {
	bym_set_instant_kill( iPlayer, CSW_KNIFE, 2 );
	bym_set_instant_kill( iPlayer, CSW_XM1014, 5 );
	cod_set_rockets( iPlayer, 1, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
	}
	if( iClass == g_iClasses[ Adrenaline ] ) {
		bym_set_magician( iPlayer, NO_WEAPON, 8, str_to_num( g_szClasses[ Adrenaline ][ 8 ] ) );
		bym_set_instant_kill( iPlayer, CSW_DEAGLE, 3 );
	}
	
	// Premium Classes
	if( iClass == g_iClasses[ Cadet ] ) {
		cod_set_explosion_resistance( iPlayer, EXPLOSION_RESISTANCE_ON );
		bym_set_instant_kill( iPlayer, CSW_USP, 3 );
	}
	if( iClass == g_iClasses[ General ] ) {
		bym_set_instant_kill( iPlayer, CSW_FAMAS, 6 );
		bym_set_instant_kill( iPlayer, CSW_GLOCK18, 4 );
	}
	if( iClass == g_iClasses[ Assassin ] ) {
		bym_set_anti_xray( iPlayer, ANTI_XRAY_ON );
		bym_set_instant_kill( iPlayer, CSW_DEAGLE, 3 );
		bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, 255 );
         }
	if( iClass == g_iClasses[ ExekuttorXL ] ) {
         bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
         bym_set_instant_kill( iPlayer, CSW_XM1014, 4 );
	 cod_set_rockets( iPlayer, 2, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
	}
	if( iClass == g_iClasses[ Hitler ] ) bym_set_instant_kill( iPlayer, CSW_AK47, 9 );
	if( iClass == g_iClasses[ SergeantMajor ] ) {
		cod_set_mines( iPlayer, 3, MINE_TYPE_ORDINARY );
		bym_set_instant_kill( iPlayer, CSW_AK47, 8 );
		bym_set_instant_kill( iPlayer, CSW_XM1014, 8 );
	}
	if( iClass == g_iClasses[ Vojskovodja ] ) {
		cod_set_rockets( iPlayer, 5, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
		bym_set_instant_kill( iPlayer, CSW_UMP45, 8 );
	}
	if( iClass == g_iClasses[ Officer ] ) {
		bym_set_magician( iPlayer, NO_WEAPON, 8, str_to_num( g_szClasses[ Officer ][ 8 ] ) );
		bym_set_instant_kill( iPlayer, CSW_TMP, 11 );
	}
	if( iClass == g_iClasses[ Admiral ] ) {
		cod_set_dynamites( iPlayer, 5 );
		bym_set_additional_damage( iPlayer, NO_WEAPON, 8 );
	}
	if( iClass == g_iClasses[ VasiliZaitsev ] ) {
		bym_set_bullet_proof( iPlayer, 3 );
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 );
	}
	if( iClass == g_iClasses[ JohnWayane ] ) {
		bym_set_xray( iPlayer, XRAY_ON );
		bym_set_instant_kill( iPlayer, CSW_ELITE, 6 );
	}
	if( iClass == g_iClasses[ ProSwat ] ) {
		cod_set_explosion_resistance( iPlayer, EXPLOSION_RESISTANCE_ON );
		bym_set_resistance( iPlayer, CSW_KNIFE, 1 );
		bym_set_instant_kill( iPlayer, CSW_M4A1, 5 );
	}
	
	// Super Classes
	if( iClass == g_iClasses[ Hitman ] ) {
		cod_set_weapon_pickup( iPlayer, 1 );
		cs_reset_player_model( iPlayer );
		cs_set_player_model( iPlayer, "Cod_Hitman" );
		g_iPlayerInfo[ iPlayer ][ g_iSkipModelChange ] = 1;
		bym_set_instant_kill( iPlayer, NO_WEAPON, 7 );
		bym_set_instant_kill( iPlayer, CSW_USP, 4 );
	}
	if( iClass == g_iClasses[ Indian ] ) {
		set_user_footsteps( iPlayer, 1 );
		cod_give_compound_bow( iPlayer );
		engclient_cmd( iPlayer, "weapom_xm1014" );
		bym_set_xray( iPlayer, XRAY_ON );
		bym_set_instant_kill( iPlayer, CSW_XM1014, 1 );
	}
	if( iClass == g_iClasses[ Simke ] ) {
		cod_set_rockets( iPlayer, 1, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
		bym_set_aim( iPlayer, CSW_DEAGLE, 1 );
		bym_set_instant_kill( iPlayer, CSW_ELITE, 6 );
		bym_set_instant_kill( iPlayer, CSW_USP, 4 );
	}
	if( iClass == g_iClasses[ ReanimatorXXL ] ) {
		cod_set_medkits( iPlayer, 15 );
		bym_set_additional_damage( iPlayer, CSW_MP5NAVY, 60 );
		bym_set_magician( iPlayer, CSW_KNIFE, 8, str_to_num( g_szClasses[ ReanimatorXXL ][ 8 ] ) );
		bym_set_instant_kill( iPlayer, CSW_ELITE, 6 );
		bym_set_instant_kill( iPlayer, CSW_USP, 4 );
	}
	if( iClass == g_iClasses[ ExekuttorXXL ] ) {
	cod_set_rockets( iPlayer, 5, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
	bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
	bym_set_instant_kill( iPlayer, CSW_XM1014, 2 );
	}
	if( iClass == g_iClasses[ Camper ] ) {
		cod_set_rockets( iPlayer, 2, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF);
		bym_set_magician( iPlayer, NO_WEAPON, 8, str_to_num( g_szClasses[ Camper ][ 8 ] ));
		bym_set_instant_kill( iPlayer, CSW_DEAGLE, 5 );
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 );
	}
	if( iClass == g_iClasses[ TerminatorXXL ] ) {
		cod_set_mines( iPlayer, 2, MINE_TYPE_ORDINARY );
		bym_set_instant_kill( iPlayer, CSW_DEAGLE, 4 );
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 );
		bym_respawn_as_enemy( iPlayer, 5 );
		bym_set_instant_kill( iPlayer, CSW_SCOUT, 1 );
		bym_set_multi_jump( iPlayer, 2 );
	}

	if( iClass == g_iClasses[ Mordereca ] ) {
		bym_set_additional_damage( iPlayer, CSW_MP5NAVY, 200 );
		bym_set_unlimited_clip( iPlayer, UNLIMITED_CLIP_ON );
		bym_set_instant_kill( iPlayer, CSW_HEGRENADE, 2 );
		bym_set_instant_kill( iPlayer, CSW_MP5NAVY, 3 );
		bym_set_multi_jump( iPlayer, 3 );
	}
	if( iClass == g_iClasses[ MadMax ] ) {
		bym_set_jetpack( iPlayer, JETPACK_ORDINARY );
		bym_set_instant_kill( iPlayer, CSW_USP, 4 );
	}
	if( iClass == g_iClasses[ Destroyer ] ) {
		bym_set_magician( iPlayer, NO_WEAPON, 8, str_to_num( g_szClasses[ Destroyer ][ 8 ] ));
		cod_set_dynamites( iPlayer, 10 );
		bym_set_instant_kill( iPlayer, CSW_AK47, 10 );
	}
	if( iClass == g_iClasses[ Ninja ] ) {
		bym_set_jetpack( iPlayer, JETPACK_ORDINARY );
		bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, str_to_num( g_szClasses[ Ninja ][ 8 ] ) );
		set_user_footsteps( iPlayer, 1 );
		entity_set_float( iPlayer, EV_FL_gravity, 0.8 );
		bym_set_wall_climbing( iPlayer, WALL_CLIMB_ON );
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
	}
	if( iClass == g_iClasses[ Rocker ] ) {
		give_item( iPlayer, "weapon_scout" );
		engclient_cmd( iPlayer, "weapon_scout" );
		g_iPlayerInfo[ iPlayer ][ g_iHasFootKick ] = 1;
		bym_set_instant_kill( iPlayer, CSW_SCOUT, 1 );
	}
	
	// Extra premium classes
	if( iClass == g_iClasses[ Ghost ] ) {
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 );
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
		bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, str_to_num( g_szClasses[ Ghost ][ 8 ] ) );
	}
	if( iClass == g_iClasses[ Glacier ] ) {
		bym_set_no_recoil( iPlayer, NO_RECOIL_ON );
		bym_set_unlimited_clip( iPlayer, UNLIMITED_CLIP_ON );
		bym_set_instant_kill( iPlayer, CSW_AK47, 9 );
		bym_set_instant_kill( iPlayer, CSW_M4A1, 9 );
	}
	if( iClass == g_iClasses[ Shredder ] ) {
		set_user_footsteps( iPlayer, 1 );
		bym_set_instant_kill( iPlayer, CSW_AK47, 10 );
		bym_set_weapon_invisiblity( iPlayer, NO_WEAPON, 8, str_to_num( g_szClasses[ Shredder ][ 8 ] ) );
	}	
	if( iClass == g_iClasses[ Tokelian ] ) {
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 );
		bym_set_instant_kill( iPlayer, CSW_M4A1, 6 );
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
		bym_set_instant_kill( iPlayer, CSW_HEGRENADE, 1 );
		bym_set_multi_jump( iPlayer, 2 );
		cod_set_rockets( iPlayer, 2, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
	}	
	if( iClass == g_iClasses[ Prosiak ] ) {
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 );
		bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, str_to_num( g_szClasses[ Prosiak ][ 8 ] ) );
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
		entity_set_float( iPlayer, EV_FL_gravity, 0.7 );
	}	
	if( iClass == g_iClasses[ JoergSprave ] ) {
		bym_set_additional_damage( iPlayer, CSW_G3SG1, 100 );
		bym_set_additional_damage( iPlayer, CSW_SCOUT, 450 );
		bym_set_additional_damage( iPlayer, CSW_AWP, 700 );
		give_item( iPlayer, "weapon_scout" );
		give_item( iPlayer, "weapon_awp" );
		give_item( iPlayer, "weapon_g3sg1" );
		give_item( iPlayer, "weapon_m249" );
		cod_give_compound_bow( iPlayer );
		bym_set_hs_only( iPlayer, 1 );
		bym_set_no_recoil( iPlayer, NO_RECOIL_ON );
		give_item( iPlayer, "weapon_knife" );
		cod_set_dynamites( iPlayer, 1000 );
		cs_set_user_bpammo(iPlayer, CSW_FLASHBANG, 5)
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
		bym_set_instant_kill( iPlayer, CSW_M249, 12 );
		entity_set_float( iPlayer, EV_FL_gravity, 1.2);
	}	
	if( iClass == g_iClasses[ Psikopaktik ] ) {
		bym_set_instant_kill( iPlayer, CSW_USP, 2 );
		bym_set_weapon_invisiblity( iPlayer, NO_WEAPON, 5, str_to_num( g_szClasses[ Psikopaktik ][ 5 ] ) );
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
		entity_set_float( iPlayer, EV_FL_gravity, 0.5 );
		bym_set_anti_xray( iPlayer, ANTI_XRAY_ON );
		bym_set_multi_jump( iPlayer, 3 );
	}
	if( iClass == g_iClasses[ Predator ] ) {
		cs_reset_player_model( iPlayer );
		give_item( iPlayer, "weapon_scout" );
		cs_set_player_model( iPlayer, "Cod_Predator" );
		g_iPlayerInfo[ iPlayer ][ g_iSkipModelChange ] = 1;
		bym_set_unlimited_clip( iPlayer, UNLIMITED_CLIP_ON );
		bym_set_instant_kill( iPlayer, CSW_XM1014, 11 );
		bym_set_instant_kill( iPlayer, CSW_SCOUT, 1 );
	}
	if( iClass == g_iClasses[ TerminatorXXXLUltimate ] ) {
		bym_set_weapon_invisiblity( iPlayer, NO_WEAPON, 1, str_to_num( g_szClasses[ TerminatorXXXLUltimate ][ 1 ] ) );
		bym_set_unlimited_clip( iPlayer, UNLIMITED_CLIP_ON );
		bym_set_instant_kill( iPlayer, CSW_AWP, 1 );
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
		bym_set_instant_kill( iPlayer, CSW_XM1014, 1 );
		bym_set_instant_kill( iPlayer, CSW_HEGRENADE, 1 );
		bym_set_instant_kill( iPlayer, CSW_M4A1, 1 );
		bym_set_instant_kill( iPlayer, CSW_SCOUT, 1 );
		bym_set_instant_kill( iPlayer, CSW_AK47, 1 );
		bym_set_instant_kill( iPlayer, CSW_MP5NAVY, 1 );
		bym_set_instant_kill( iPlayer, CSW_DEAGLE, 1 );
		bym_set_instant_kill( iPlayer, CSW_ELITE, 1 );
		bym_set_instant_kill( iPlayer, CSW_M3, 1 );
		bym_set_instant_kill( iPlayer, CSW_TMP, 1 );
		bym_set_instant_kill( iPlayer, CSW_UMP45, 1 );
		bym_set_instant_kill( iPlayer, CSW_FAMAS, 1 );
		bym_set_instant_kill( iPlayer, CSW_GLOCK18, 1 );
		bym_set_instant_kill( iPlayer, CSW_AUG, 1 );
		bym_set_instant_kill( iPlayer, CSW_USP, 1 );
		bym_set_instant_kill( iPlayer, CSW_MAC10, 1 );
		bym_set_instant_kill( iPlayer, CSW_FIVESEVEN, 1 );
		bym_set_instant_kill( iPlayer, CSW_GALIL, 1 );
		bym_set_instant_kill( iPlayer, CSW_M249, 1 );
		bym_set_instant_kill( iPlayer, CSW_G3SG1, 1 );
		bym_set_instant_kill( iPlayer, CSW_P90, 1 );
		bym_set_instant_kill( iPlayer, CSW_P228, 1 );
		cod_set_dynamites( iPlayer, 1000 );
		bym_set_multi_jump( iPlayer, 2000 );
		bym_set_hs_only( iPlayer, 1 );
		bym_set_hs_immunity( iPlayer, 1 );
		cod_set_explosion_resistance( iPlayer, EXPLOSION_RESISTANCE_ON );
		bym_set_aim( iPlayer, NO_WEAPON, 1 );
		cod_set_mines( iPlayer, 2000, MINE_TYPE_INSTANT );
		bym_set_no_recoil( iPlayer, NO_RECOIL_ON );
		cod_set_rockets( iPlayer, 500, ROCKET_TYPE_INSTANT, ROCKET_TRACER_ON );
	}
	if( iClass == g_iClasses[ Wolverine ] ) { 
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
		bym_set_hs_immunity( iPlayer, 4 );
		bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, str_to_num( g_szClasses[ Wolverine ][ 8 ] ) );
	}
	if( iClass == g_iClasses[ ProAssassin ] ){
	bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
	bym_set_instant_kill( iPlayer, CSW_DEAGLE, 3 );
	bym_set_instant_kill( iPlayer, CSW_MP5NAVY, 5 );
	bym_set_weapon_invisiblity( iPlayer, NO_WEAPON, 1, str_to_num( g_szClasses[ ProAssassin ][ 1 ] ) );
	cod_set_rockets( iPlayer, 2, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
         }
	if( iClass == g_iClasses[ Frankestein ] ) {
		g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] = 1;
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
	}
	
	// Vip Classes
	if( iClass == g_iClasses[ Taliban ] ) cod_set_rockets( iPlayer, 2, ROCKET_TYPE_ORDINARY, ROCKET_TRACER_OFF );
	if( iClass == g_iClasses[ Jumper ] ) {
		bym_set_jetpack( iPlayer, JETPACK_ORDINARY );
		bym_set_multi_jump( iPlayer, 2 );
	}
	
	if( iClass == g_iClasses[ Samurai ] ) {
		bym_set_wall_climbing( iPlayer, WALL_CLIMB_ON );
		bym_set_instant_kill( iPlayer, CSW_KNIFE, 1 );
	}
	
	if( iClass == g_iClasses[ Warior ] ) {
		bym_set_instant_kill( iPlayer, CSW_FAMAS, 6 );
		bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, str_to_num( g_szClasses[ Warior ][ 8 ] ) );
	}
}

public fw_HamTakeDamagePre(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageType ) {
	
	if( !is_user_connected( iAttacker ) || !is_user_alive( iAttacker ) || !( 1 <= iAttacker <= g_iMaxPlayers ) || ( iAttacker == iVictim ) )
		return HAM_IGNORED;
		
	if( !is_user_connected( iVictim ) || !is_user_alive( iVictim ) || ( g_iPlayerInfo[ iAttacker ][ g_iTeam ] == g_iPlayerInfo[ iVictim ][ g_iTeam ] ) )
		return HAM_IGNORED;
	
	if( cod_get_perk( iVictim ) == cod_get_perk_id( "ML_SWAT_SHIELD" ) )
		return HAM_IGNORED;
	
	if( g_iPlayerInfo[ iAttacker ][ g_iClass ] == g_iClasses[ Ironman ] && Chance( 5 ) )
		bym_screen_fade( iVictim, ( 1 << 14 ), ( 1 << 14 ), ( 1 << 16 ), 255, 155, 50, 230 );
	
	return HAM_IGNORED;
}

public fw_HamPlayerDeath( iVictim, iAttacker, iSh ) {
	if( task_exists( iVictim + TASK_NOCLIP_OFF ) )
		remove_task( iVictim + TASK_NOCLIP_OFF );
	
	if( is_user_connected( iAttacker ) && iAttacker != iVictim )
		bym_screen_fade( iAttacker, 1 << 10, 1 << 10, 1 << 4, 0, 255, 255, 70 );

	if( is_user_connected( iVictim ) && g_iPlayerInfo[ iVictim ][ g_iClass ] == g_iClasses[ Kamikaze ] )
		cod_create_explosion( iVictim, iVictim, false, 1200.0, true );
		
	if( is_user_connected( iVictim ) && g_iPlayerInfo[ iVictim ][ g_iClass ] == g_iClasses[ ReanimatorXXL ] && Chance( 2 ) )
		cod_create_explosion( iVictim, iVictim, false, 1200.0, true );
		
	if( is_user_connected( iVictim ) && g_iPlayerInfo[ iVictim ][ g_iClass ] == g_iClasses[ Psikopaktik ] )
		cod_create_explosion( iVictim, iVictim, false, 1200.0, true );
	
	if( is_user_connected( iAttacker ) && g_iPlayerInfo[ iAttacker ][ g_iClass ] == g_iClasses[ ExekuttorXXL ] && is_user_alive( iAttacker ) )
		bym_set_weapon_clip( iAttacker, g_iMaxClip[ get_user_weapon( iAttacker ) ] );
		
	if( is_user_connected( iVictim ) && g_iPlayerInfo[ iVictim ][ g_iClass ] == g_iClasses[ TerminatorXXXLUltimate ] )
		cod_create_explosion( iVictim, iVictim, false, 1000000.0, true );
		

	return HAM_IGNORED;
}

// Original author: Dias
public fw_HamPlayerPreThink( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return;
	
	static Float: fNextAttack; 
	fNextAttack = get_pdata_float( iPlayer, 83, 5 );
	
	if( fNextAttack >= 0.0 && g_iPlayerInfo[ iPlayer ][ g_iFootKick ] )
		set_pev( iPlayer, pev_velocity, { 0.0,0.0,0.0 } );
		
	if( fNextAttack <= 0.0 && g_iPlayerInfo[ iPlayer ][ g_iFootKick ] ) {
		static iWeapon; 
		iWeapon = get_pdata_cbase( iPlayer, 373 ); 
		
		if( pev_valid( iWeapon ) ) {
			ExecuteHamB( Ham_Item_Deploy, iWeapon );
			g_iPlayerInfo[ iPlayer ][ g_iFootKick ] = 0;
		}
	}
	
	static iButton;
	iButton = get_user_button( iPlayer ) ;
	if( ( iButton & IN_USE ) && g_iPlayerInfo[ iPlayer ][ g_iHasFootKick ] )
		FootKick( iPlayer );
}

// Original author: Dias
public FootKick( iPlayer ) {
	if( g_iPlayerInfo[ iPlayer ][ g_iHasFootKick ] && is_user_connected( iPlayer ) && is_user_alive( iPlayer ) && get_pdata_float( iPlayer, 83 ) <= 0.0 && !( entity_get_int( iPlayer, EV_INT_flags ) & FL_DUCKING ) ) {
		set_pev( iPlayer, pev_velocity, { 0.0 } );
		entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_Foot ] );
			
		PlayAnimation( iPlayer, 1 );
		set_pdata_float( iPlayer, 83, 0.6 );
		g_iPlayerInfo[ iPlayer ][ g_iFootKick ] = 1;
			
		new iTarget, iBody;
		get_user_aiming( iPlayer, iTarget, iBody, 100 );
			
		if( iTarget && is_user_connected( iTarget ) && is_user_alive( iTarget ) && !( g_iPlayerInfo[ iPlayer ][ g_iTeam ] == g_iPlayerInfo[ iTarget ][ g_iTeam ] ) ) {
			static Float: fVelocity[ 3 ] ;
			velocity_by_aim( iPlayer, 500, fVelocity );
			fVelocity[ 2 ] = 300.0;
			entity_set_vector( iTarget, EV_VEC_velocity, fVelocity );
			
			user_kill( iTarget );
			set_user_frags( iPlayer, get_user_frags( iPlayer ) + 1 );
		}
	}
}

// It would be more optimizes if you are using: Ham_Item_Deploy, but it does not work for some reason :P
public fw_CurWeapon( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	new iCurrentClass = g_iPlayerInfo[ iPlayer ][ g_iClass ];
	new iWeapon = get_user_weapon( iPlayer );
	
	if( iWeapon == CSW_KNIFE ) {
		if( iCurrentClass == g_iClasses[ Phantom ] )
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_PhantomKnife ] );
			
		if( iCurrentClass == g_iClasses[ JoergSprave ] )
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_JoergKnifeV ] );
			
		if( iCurrentClass == g_iClasses[ Ninja ] || iCurrentClass == g_iClasses[ Samurai ] ) {
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_KatanaV ] );
			entity_set_string( iPlayer, EV_SZ_weaponmodel, g_szModels[ Model_KatanaP ] );
		}
		
		if( iCurrentClass == g_iClasses[ Wolverine ] ) {
			entity_set_string( iPlayer, EV_SZ_viewmodel, ( ( g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] == 0 ) ? g_szModels[ Model_ClawsV ] : g_szModels[ Model_HandsV ] ) );
			entity_set_string( iPlayer, EV_SZ_weaponmodel, ( ( g_iPlayerInfo[ iPlayer ][ g_iPowersNumber ] == 0 ) ? g_szModels[ Model_ClawsP ] : g_szModels[ Model_HandsP ] ) );
		}
	}
	if( iWeapon == CSW_AWP ) {
		if( iCurrentClass == g_iClasses[ JoergSprave ] )
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_DoubleCrossbowV ] );
	}
	if( iWeapon == CSW_SCOUT ) {
		if( iCurrentClass == g_iClasses[ Rocker ] )
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_Guitar ] );
			
		if( iCurrentClass == g_iClasses[ JoergSprave ] )
			entity_set_string( iPlayer, EV_SZ_weaponmodel, g_szModels[ Model_CrossbowP ] );
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_CrossbowV ] );
			
		if( iCurrentClass == g_iClasses[ Predator ] )
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_PredatorScout ] );
	}
	if( iWeapon == CSW_USP ) {
		if( iCurrentClass == g_iClasses[ Hitman ] )
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_HitmanUSP ] );
	}
	if( iWeapon == CSW_G3SG1 ) {
		if( iCurrentClass == g_iClasses[ JoergSprave ] )
		entity_set_string( iPlayer, EV_SZ_weaponmodel, g_szModels[ Model_RepeatingCrossbowP ] );
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_RepeatingCrossbowV ] );
	}
	if( iWeapon == CSW_M249 ) {
		if( iCurrentClass == g_iClasses[ JoergSprave ] )
 			entity_set_string( iPlayer, EV_SZ_weaponmodel, g_szModels[ Model_JoergMiniP ] );
			entity_set_string( iPlayer, EV_SZ_viewmodel, g_szModels[ Model_JoergMiniV ] );
         }
}

public fw_EmitSound( iPlayer, iChannel, const szSample[ ], Float: fVolume, Float: fAttn, iFlags, iPitch ) {
	if( !is_user_connected( iPlayer ) || !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;
	
	if( g_iPlayerInfo[ iPlayer ][ g_iClass ] == g_iClasses[ Wolverine ] && ( get_user_weapon( iPlayer ) == CSW_KNIFE ) ) {
		if( equal( szSample, "weapons/knife_hit1.wav" ) ) {
			emit_sound( iPlayer, iChannel, "weapons/hit1_wolverine.wav", fVolume, fAttn, iFlags, iPitch );
			return FMRES_SUPERCEDE;
		}
				
		if( equal( szSample, "weapons/knife_hit2.wav" ) ) {
			emit_sound( iPlayer, iChannel, "weapons/hit2_wolverine.wav", fVolume, fAttn, iFlags, iPitch );
			return FMRES_SUPERCEDE;
		}
				
		if( equal( szSample, "weapons/knife_hit3.wav" ) ) {
			emit_sound( iPlayer, iChannel, "weapons/hit3_wolverine.wav", fVolume, fAttn, iFlags, iPitch );
			return FMRES_SUPERCEDE;
		}
				
		if( equal( szSample, "weapons/knife_hit4.wav" ) ) {
			emit_sound( iPlayer, iChannel, "weapons/hit4_wolverine.wav", fVolume, fAttn, iFlags, iPitch );
			return FMRES_SUPERCEDE;
		}
				
		if( equal( szSample, "weapons/knife_hitwall1.wav" ) ) {
			emit_sound( iPlayer, iChannel, "weapons/wall1_wolverine.wav", fVolume, fAttn, iFlags, iPitch );
			return FMRES_SUPERCEDE;
		}
				
		if( equal( szSample, "weapons/knife_hitwall2.wav" ) ) {
			emit_sound( iPlayer, iChannel, "weapons/wall2_wolverine.wav", fVolume, fAttn, iFlags, iPitch );
			return FMRES_SUPERCEDE;
		}
				
		if( equal( szSample, "weapons/knife_stab.wav" ) || equal( szSample, "weapons/knife_slash1.wav" ) || equal( szSample, "weapons/knife_slash1.wav" ) )
			return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

//=================================================================================================
//				 	Clear data
//=================================================================================================

public client_putinserver( iPlayer ) {
	for( new iIterator = 0; iIterator < StructPlayerInfo; iIterator ++ )
		g_iPlayerInfo[ iPlayer ][ iIterator ] = 0;
}

public client_disconnect( iPlayer ) {
	for( new iIterator = 0; iIterator < StructPlayerInfo; iIterator ++ )
		g_iPlayerInfo[ iPlayer ][ iIterator ] = 0;
}

//=================================================================================================
//				 	 Stocks
//=================================================================================================
stock SetCamouflage( iPlayer ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	cs_reset_player_model( iPlayer );
	switch( cs_get_user_team( iPlayer ) ) {
		case CS_TEAM_T: cs_set_player_model( iPlayer, g_szPlayerModels[ 1 ][ random_num( 0, 3 ) ] );
		case CS_TEAM_CT: cs_set_player_model( iPlayer, g_szPlayerModels[ 0 ][ random_num( 0, 3 ) ] );
	}
}	

stock Float: AimDistance( iPlayer ) {
	static iA, Float: fB;
	return get_user_aiming( iPlayer, iA, _:fB );
}

stock PlayAnimation( const iPlayer, const iSequence ) {
	set_pev( iPlayer, pev_weaponanim, iSequence);
	message_begin( MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = iPlayer );
	write_byte( iSequence );
	write_byte( pev( iPlayer, pev_body ) );
	message_end( );
}
