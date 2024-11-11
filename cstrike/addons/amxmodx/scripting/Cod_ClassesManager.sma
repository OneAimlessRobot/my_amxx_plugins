// TO DO:
// - Class Models, Class Weapon Models

#include < amxmodx >
#include < bym_cod_2016 >
#include < bym_framework >
#include < cod_secoundary_weapons >
#include < engine >

#define MAX_CLASSES		100

#define Struct			enum
#define IsComment(%0)		%0[ 0 ] == EOS || ( %0[ 0 ] == ';' ) || ( %0[ 0 ] == '/' && %0[ 1 ] == '/' )
#define ToInt(%0)		str_to_num( %0 )
#define is_char(%1) 		( 0 < ( %1 ) <= 255 )

Struct _:StructClassInfo {
	g_szClassName[ 64 ],
	g_szClassDescription[ 64 ],
	g_szClassFaction[ 64 ],
	g_szClassWeapons[ 96 ],
	g_szClassFlag[ 5 ],
	g_szClassAbilities[ 768 ],
	g_szClassSpeed[ 5 ],
	g_iClassHp[ 5 ],
	g_iClassArmor[ 5 ],
	g_iClassVisibility[ 5 ],
	g_iClassPrice[ 5 ]
}

new g_szClassesInfo[ MAX_CLASSES ][ StructClassInfo ];

new g_iClasses[ MAX_CLASSES ];
new g_iLoadedClasses = 0;
new g_iRegisteredClasses = 0;

new const szClassFile[ ] = "addons/amxmodx/configs/ByM_Cod/Classes.ini";

new const szDefaultContent[ ][ ] = {
	"; Here you can add/register classes for Call of Duty: Modern Warfare Mode by Milutinke (ByM)",
	" ",
	"; Format for class addition/registration:",
	"; ^"Name^" ^"Description^" ^"Faction^" ^"Weapons^" ^"Flag^" ^"Abilities^" ^"Speed^" ^"Health^" ^"Armor^" ^"Visibility^" ^"Price^" ; Name (Non Lang)",
	" ",
	"; Rules for class addition/registration:",
	"; Name, Description and Faction must be defined in Cod_Classes.txt language file!!!",
	"; If class does not have flag or abilities just leave blank field",
	"; Weapons and Abilitites must be divided by character ,,:^"",
	"; Visibility can not be greather than 255 and lower than 0",
	"; ",
	" ",
	"; Example of class:",
	"; ^"ML_SPY^" ^"ML_D_SPY^" ^"ML_FREE_CLASSES^" ^"m4a1:ak47:usp^" ^"^" ^"InstantKill(m4a1,9):SilentWalking:KnifeInvisibility^" ^"1.3^" ^"100^" ^"100^" ^"255^" ^"0^" ; Spy",
	" ",
	"; Lines begining with black space, double slashs or semicolons are ignored (They are comments, just like this line)",
	" "
};

enum StructTypes {
	Type_String = 0,
	Type_Integer,
	Type_Float,
	Type_Boolean
}

new const g_szDeafultFunctions[ ][ ] = {
	"JetPack",
	"BulletProof",
	"InstantKill",
	"AdditionalDamage",
	"IgnoreResistance",
	"InstantKillResistance",
	"SpawnAsEnemy",
	"NoRecoil",
	"FastReload",
	"NoReload",
	"HsImmunity",
	"HsOnly",
	"Aim",
	"MultiJump",
	"WallClimb",
	"Xray",
	"AntiXray",
	"WeaponInvisibility",
	"Magician",
	"Teleport",
	"Vampire",
	"MilitarySecret",
	"Dropper"
};

new g_iForward;

public plugin_init( ) {
	register_plugin( "[ByM] CoD: Classes Loader", "1.0", "Milutinke (ByM)" );
	
	LoadClasses( szClassFile );
	
	for( new iClasses = 0; iClasses <= g_iLoadedClasses; iClasses ++ ) {
		g_iClasses[ iClasses ] = cod_register_class(
			// String parameters
			g_szClassesInfo[ iClasses ][ g_szClassName ],
			g_szClassesInfo[ iClasses ][ g_szClassDescription ],
			g_szClassesInfo[ iClasses ][ g_szClassFaction ],
			g_szClassesInfo[ iClasses ][ g_szClassWeapons ],
			g_szClassesInfo[ iClasses ][ g_szClassFlag ],
			g_szClassesInfo[ iClasses ][ g_szClassSpeed ],
			
			// Integer parameters
			ToInt( g_szClassesInfo[ iClasses ][ g_iClassHp ] ),
			ToInt( g_szClassesInfo[ iClasses ][ g_iClassArmor ] ),
			strlen( g_szClassesInfo[ iClasses ][ g_iClassVisibility ] ) > 0 ? ( ToInt( g_szClassesInfo[ iClasses ][ g_iClassVisibility ] ) < 8 ? 8 : ToInt( g_szClassesInfo[ iClasses ][ g_iClassVisibility ] ) ) : 255,
			strlen( g_szClassesInfo[ iClasses ][ g_iClassPrice ] ) > 0 ? ToInt( g_szClassesInfo[ iClasses ][ g_iClassPrice ] ) : 0
		);
		
		if( g_iClasses[ iClasses ] != -1 )
			g_iRegisteredClasses ++;
	}
	
	g_iForward = CreateMultiForward( "cod_custom_ability_executed", ET_CONTINUE, FP_CELL, FP_STRING );
}

public cod_abilities_set_pre( iPlayer, iClass ) {
	bym_reset_everything( iPlayer );
	cod_reset_secondary_weapons( iPlayer );
}

public cod_class_pre_selected( iPlayer, iClass )
	return 1;

public cod_abilities_set_post( iPlayer, iClass )
	SetAbilities( iPlayer, iClass );

public cod_class_selected( iPlayer, iClass )
	SetAbilities( iPlayer, iClass );

public SetAbilities( iPlayer, iClass ) {
	if( !is_user_alive( iPlayer ) )
		return;
		
	new szName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
	
	if( containi( szName, "[" ) != -1 )
		return;
		
	for( new iClasses = 0; iClasses <= g_iRegisteredClasses; iClasses ++ ) {
		if( iClass == g_iClasses[ iClasses ] ) {
			ParseAbilities( iPlayer, iClass, g_szClassesInfo[ iClasses ][ g_szClassAbilities ] );
			break;
		}
	} 
}
	
stock LoadClasses( const szFile[ ] ) {
	if( !file_exists( szFile ) ) {
		for( new iIterator = 0; iIterator < sizeof( szDefaultContent ); iIterator ++ ) 
			write_file( szFile, szDefaultContent[ iIterator ] );
	}
	
	new iFile = fopen( szFile, "rt" );
	
	if( !iFile )
		set_fail_state( "Classes failed to load because file failed to open!" );
		
	new szLine[ 2048 ];
	while( !feof( iFile ) ) {
		fgets( iFile, szLine, charsmax( szLine ) );
		
		if( IsComment( szLine ) )
			continue;
			
		if( g_iLoadedClasses ++ >= MAX_CLASSES )
			break;
			
		if( parse( szLine, 
			g_szClassesInfo[ g_iLoadedClasses ][ g_szClassName ], charsmax( g_szClassesInfo[ ][ g_szClassName ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_szClassDescription ], charsmax( g_szClassesInfo[ ][ g_szClassDescription ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_szClassFaction ], charsmax( g_szClassesInfo[ ][ g_szClassFaction ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_szClassWeapons ], charsmax( g_szClassesInfo[ ][ g_szClassWeapons ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_szClassFlag ], charsmax( g_szClassesInfo[ ][ g_szClassFlag ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_szClassAbilities ], charsmax( g_szClassesInfo[ ][ g_szClassAbilities ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_szClassSpeed ], charsmax( g_szClassesInfo[ ][ g_szClassSpeed ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_iClassHp ], charsmax( g_szClassesInfo[ ][ g_iClassHp ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_iClassArmor ], charsmax( g_szClassesInfo[ ][ g_iClassArmor ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_iClassVisibility ], charsmax( g_szClassesInfo[ ][ g_iClassVisibility ] ),
			g_szClassesInfo[ g_iLoadedClasses ][ g_iClassPrice ], charsmax( g_szClassesInfo[ ][ g_iClassPrice ] )
		) < 11 )
			continue;
	}
	
	server_print( "Loaded %d/%d classes from file.", g_iLoadedClasses, MAX_CLASSES );
	fclose( iFile );
}

stock ParseAbilities( iPlayer, iClass, const szFunctions[ ] ) {
	if( !strlen( szFunctions ) )
		return;
		
	new szFunctionsList[ 32 ][ 64 ];
	ExplodeString( szFunctions, ':', szFunctionsList, 32, charsmax( szFunctionsList ) );
	
	new szParameters[ 64 ];
	new szParametersList[ 12 ][ 12 ];
	new iParametersNumber = 0;
	new iResult;
	
	server_print( "^n================================= Parsing ==============================^n" );
	new iIterator = 0;
	for( iIterator = 0; iIterator < 32; iIterator ++ ) {
		if( szFunctionsList[ iIterator ][ 0 ] != EOS ) {
			if( !IsDeafaultFuncton( szFunctionsList[ iIterator ] ) ) {
				ExecuteForward( g_iForward, iResult, iPlayer, szFunctionsList[ iIterator ] );
				continue;
			}
			
			server_print( "Parsing function: %s", szFunctionsList[ iIterator ] );
			
			// Function without arguments
			if( containi( szFunctionsList[ iIterator ], "NoRecoil" ) != -1 ) {
				bym_set_no_recoil( iPlayer, NO_RECOIL_ON );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "FastReload" ) != -1 ) {
				bym_set_fast_reload( iPlayer, FAST_RELOAD_ON );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "NoReload" ) != -1 ) {
				bym_set_unlimited_clip( iPlayer, UNLIMITED_CLIP_ON );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "WallClimb" ) != -1 ) {
				bym_set_wall_climbing( iPlayer, WALL_CLIMB_ON );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "Xray" ) != -1 ) {
				bym_set_xray( iPlayer, XRAY_ON );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "AntiXray" ) != -1 ) {
				bym_set_anti_xray( iPlayer, ANTI_XRAY_ON );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "IgnoreResistance" ) != -1 ) {
				bym_set_ignore_resistance( iPlayer, IGNORE_RESISTANCE_ON );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "InstantKillResistance" ) != -1 ) {
				bym_set_instant_kill_resisance( iPlayer, INSTANT_KILL_RESISTANCE_ON );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "Vampire" ) != -1 ) {
				bym_set_vampire( iPlayer, cod_get_player_max_hp( iPlayer ) );
				continue;
			}
			
			// Functions with arguments
			if( containi( szFunctionsList[ iIterator ], "JetPack" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber ) {
						bym_set_jetpack( iPlayer, JETPACK_ORDINARY );
						continue;
					}
					
					iParametersNumber = iParametersNumber > 1 ? 1 : iParametersNumber;
					
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					bym_set_jetpack( iPlayer, ( equal( szParametersList[ 0 ], "1" ) || equal( szParametersList[ 0 ], "JETPACK_ORDINARY" ) ) ? JETPACK_ORDINARY : JETPACK_SUPER );
					continue;
				}
				
				bym_set_jetpack( iPlayer, JETPACK_ORDINARY );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "BulletProof" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber ) {
						bym_set_bullet_proof( iPlayer, 3 );
						continue;
					}
					
					iParametersNumber = iParametersNumber > 1 ? 1 : iParametersNumber;
					
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_Integer )
						continue;
					
					bym_set_bullet_proof( iPlayer, ToInt( szParametersList[ 0 ] ) );
					continue;
				}
				
				bym_set_bullet_proof( iPlayer, 3 );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "InstantKill" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
						
					if( iParametersNumber < 2 )
						continue;
					
					iParametersNumber = iParametersNumber > 2 ? 2 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_String )
						continue;
					
					if( DetermineType( szParametersList[ 1 ] ) != Type_Integer )
						continue;
					
					static iWeapon;
					iWeapon = GetWeaponId( szParametersList[ 0 ] );
					
					if( iWeapon == -1 )
						continue;
						
					bym_set_instant_kill( iPlayer, iWeapon, ToInt( szParametersList[ 1 ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "AdditionalDamage" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
						
					if( iParametersNumber < 2 )
						continue;
					
					iParametersNumber = iParametersNumber > 2 ? 2 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_String )
						continue;
					
					if( DetermineType( szParametersList[ 1 ] ) != Type_Integer )
						continue;
					
					bym_set_additional_damage( iPlayer, GetWeaponId( szParametersList[ 0 ] ), ToInt( szParametersList[ 1 ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "SpawnAsEnemy" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber ) {
						bym_respawn_as_enemy( iPlayer, 8 );
						continue;
					}
					
					iParametersNumber = iParametersNumber > 1 ? 1 : iParametersNumber;
					
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_Integer )
						continue;
					
					bym_respawn_as_enemy( iPlayer, ToInt( szParametersList[ 0 ] ) );
					continue;
				}
				
				bym_respawn_as_enemy( iPlayer, 8 );
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "Aim" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
					
					iParametersNumber = iParametersNumber > 2 ? 2 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_String )
						continue;
					
					if( DetermineType( szParametersList[ 1 ] ) != Type_Integer )
						continue;
	
					bym_set_aim( iPlayer, GetWeaponId( szParametersList[ 0 ] ), ToInt( szParametersList[ 1 ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "MultiJump" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
				
					iParametersNumber = iParametersNumber > 1 ? 1 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_Integer )
						continue;
					
					bym_set_multi_jump( iPlayer, ToInt( szParametersList[ 0 ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "WeaponInvisibility" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
						
					if( iParametersNumber < 2 )
						continue;
					
					iParametersNumber = iParametersNumber > 2 ? 2 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_String )
						continue;
					
					if( DetermineType( szParametersList[ 1 ] ) != Type_Integer )
						continue;
					
					static iWeapon;
					iWeapon = GetWeaponId( szParametersList[ 0 ] );
					
					if( iWeapon == -1 )
						continue;
						
					bym_set_weapon_invisiblity( iPlayer, iWeapon, ToInt( szParametersList[ 1 ] ), ToInt( g_szClassesInfo[ iClass ][ g_iClassVisibility ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "Magician" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
						
					if( iParametersNumber < 2 )
						continue;
					
					iParametersNumber = iParametersNumber > 2 ? 2 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_String )
						continue;
					
					if( DetermineType( szParametersList[ 1 ] ) != Type_Integer )
						continue;
					
					static iWeapon;
					iWeapon = GetWeaponId( szParametersList[ 0 ] );
					
					if( iWeapon == -1 )
						continue;
					
					bym_set_magician( iPlayer, iWeapon, ToInt( szParametersList[ 1 ] ), ToInt( g_szClassesInfo[ iClass ][ g_iClassVisibility ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "Teleport" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
					
					iParametersNumber = iParametersNumber > 1 ? 1 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_Integer )
						continue;
					
					bym_set_teleport( iPlayer, ToInt( szParametersList[ 0 ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "MilitarySecret" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
					
					iParametersNumber = iParametersNumber > 1 ? 1 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_Integer )
						continue;
					
					bym_set_military_secret( iPlayer, ToInt( szParametersList[ 0 ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "Dropper" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
					
					iParametersNumber = iParametersNumber > 1 ? 1 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_Integer )
						continue;
					
					bym_set_dropper( iPlayer, ToInt( szParametersList[ 0 ] ) );
					continue;
				}
				
				continue;
			}
			
			if( containi( szFunctionsList[ iIterator ], "Dropper" ) != -1 ) {
				if( HasParameters( szFunctionsList[ iIterator ] ) ) {
					iParametersNumber = GetFunctionParameters( szFunctionsList[ iIterator ], szParameters, charsmax( szParameters ) );
					
					if( !iParametersNumber )
						continue;
					
					iParametersNumber = iParametersNumber > 1 ? 1 : iParametersNumber;
					ExplodeString( szParameters, ',', szParametersList, iParametersNumber >= 12 ? 12 : iParametersNumber, charsmax( szParametersList ) );
					
					if( DetermineType( szParametersList[ 0 ] ) != Type_Integer )
						continue;
					
					bym_set_dropper( iPlayer, ToInt( szParametersList[ 0 ] ) );
					continue;
				}
				
				continue;
			}
		}
	}
	
	server_print( "^n================================= Parsing ==============================^n" );
}
			
stock bool: HasParameters( const szFunction[ ] )
	return bool: ( ( containi( szFunction, "(" ) != -1 ) && ( containi( szFunction, ")" ) != -1 ) ); 

stock GetFunctionParameters( const szFunction[ ], szFunctionParameters[ ], iLen ) {
	new bool: bOpenedPharanteses = false;
	new szParameters[ 64 ];
	new szCurrentCharacter[ 1 ];
	new iPositionInString = 0;
	
	// Loop through a each character of a function in order to extract parameters list
	for( new iCharacter = 0; iCharacter < strlen( szFunction ); iCharacter ++ ) {
		szCurrentCharacter[ 0 ] = szFunction[ iCharacter ];
		
		// Found oppening pharentesis, starting to copy parameters list to a new string variable
		if( szCurrentCharacter[ 0 ] == '(' ) {
			bOpenedPharanteses = true;
			continue;
		}
		
		// Closing pharentesis found, exiting out of the loop
		if( szCurrentCharacter[ 0 ] == ')' ) {
			bOpenedPharanteses = false;
			break;
		}
		
		// Add character to _szParameters
		if( bOpenedPharanteses ) {
			if( iPositionInString > 63 )
				break;
			
			if( iPositionInString == 63 )
				szParameters[ 63 ] = '^0';
			
			szParameters[ iPositionInString ] = szCurrentCharacter[ 0 ];
			iPositionInString ++;
		}
	}
	
	// Copy parameters
	copy( szFunctionParameters, iLen, szParameters );
	
	// Get the parameteres number
	new szParametersList[ 12 ][ 12 ];
	new iParametersNumber = 0;
	new iIterator = 0;
	
	ExplodeString( szParameters, ',', szParametersList, 12, charsmax( szParametersList ) );
	
	for( iIterator = 0; iIterator < 12; iIterator ++ ) {
		if( szParametersList[ iIterator ][ 0 ] != EOS )
			iParametersNumber ++;
	}
	
	return iParametersNumber;
}

stock StructTypes: DetermineType( const szParameter[ ] ) {
	if( is_str_num( szParameter ) )
		return StructTypes: Type_Integer;
		
	if( is_str_float( szParameter ) )
		return StructTypes: Type_Float;
		
	if( containi( szParameter, "true" ) != -1 || containi( szParameter, "false" ) != -1  )
		return StructTypes: Type_Boolean
		
	return StructTypes: Type_String;
}

// Originally by Excolent
stock bool: is_str_float( const szString[ ] ) {
	new cCharacter, iIterator, iP;
	
	while( is_char( cCharacter = szString[ iIterator ++ ] ) ) {
		if( !isdigit( cCharacter ) ) {
			if( cCharacter != '.' || iP )
				return false;
				
			iP = 1;
		}
	}
	
	return ( iIterator > 1 );
}

stock bool: IsDeafaultFuncton( const szFunction[ ] ) {
	new iIterator = 0;
	for( iIterator = 0; iIterator < sizeof( g_szDeafultFunctions ); iIterator ++ ) {
		if( containi( szFunction, g_szDeafultFunctions[ iIterator ] ) != -1 )
			return true;
	}
	
	return false;
}

stock GetWeaponId( const szWeaponName[ ] ) {
	if( containi( szWeaponName, "p228" ) != -1 )
		return CSW_P228;
		
	if( containi( szWeaponName, "scout" ) != -1 )
		return CSW_SCOUT;
		
	if( containi( szWeaponName, "he" ) != -1 )
		return CSW_HEGRENADE;
		
	if( containi( szWeaponName, "xm1014" ) != -1 )
		return CSW_XM1014;
		
	if( containi( szWeaponName, "mac10" ) != -1 )
		return CSW_MAC10;
		
	if( containi( szWeaponName, "aug" ) != -1 )
		return CSW_AUG;
		
	if( containi( szWeaponName, "elite" ) != -1 )
		return CSW_ELITE;
		
	if( containi( szWeaponName, "fiveseven" ) != -1 )
		return CSW_FIVESEVEN;
	
	if( containi( szWeaponName, "ump" ) != -1 )
		return CSW_UMP45;
		
	if( containi( szWeaponName, "sg550" ) != -1 )
		return CSW_SG550;
		
	if( containi( szWeaponName, "gali" ) != -1 )
		return CSW_GALIL;
		
	if( containi( szWeaponName, "famas" ) != -1 )
		return CSW_FAMAS;
		
	if( containi( szWeaponName, "usp" ) != -1 )
		return CSW_USP;
		
	if( containi( szWeaponName, "glock" ) != -1 )
		return CSW_GLOCK18;
		
	if( containi( szWeaponName, "awp" ) != -1 )
		return CSW_AWP;
		
	if( containi( szWeaponName, "mp5" ) != -1 )
		return CSW_MP5NAVY;
		
	if( containi( szWeaponName, "m249" ) != -1 )
		return CSW_M249;
		
	if( containi( szWeaponName, "m3" ) != -1 )
		return CSW_M3;

	if( containi( szWeaponName, "m4" ) != -1 )
		return CSW_M4A1;
		
	if( containi( szWeaponName, "tmp" ) != -1 )
		return CSW_TMP;
		
	if( containi( szWeaponName, "g3sg1" ) != -1 )
		return CSW_G3SG1;
		
	if( containi( szWeaponName, "deagle" ) != -1 )
		return CSW_DEAGLE;
		
	if( containi( szWeaponName, "sg552" ) != -1 )
		return CSW_SG550;
		
	if( containi( szWeaponName, "ak" ) != -1 )
		return CSW_AK47;
		
	if( containi( szWeaponName, "knife" ) != -1 )
		return CSW_KNIFE;
		
	if( containi( szWeaponName, "p90" ) != -1 )
		return CSW_P90;
		
	return -1;
}

// Originally by xeroblood
stock ExplodeString( const szInput[ ], const iCharacter, szOutput[ ][ ], const iMaxs, const iMaxLen ) {
	new iDo = 0, iLen = strlen( szInput ), iOutputLen = 0;
	
	do { iOutputLen += ( 1 + copyc( szOutput[ iDo++ ], iMaxLen, szInput[ iOutputLen ],  iCharacter ) ); }
	while( iOutputLen < iLen && iDo < iMaxs )
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
