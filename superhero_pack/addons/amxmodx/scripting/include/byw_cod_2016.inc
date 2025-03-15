#if defined _byw_native cod_2016_included
  #endinput
#endif
#define _byw_native cod_2016_included

#define Chance(%0)		( random_num( 1, %0 ) == 1 )

enum {
	COD_DOUBLE_XP_OFF = 0,
	COD_DOUBLE_XP_ON	
}

// Classes
native cod_register_class( const szName[ ], const szDescrption[ ], const szFaction[ ], const szWeapons[ ], const szFlag[ ], const szSpeed[ ], iHealth, iArmor, iVisibility, iPrice );
native cod_classes_number( );
native cod_get_class_id( const szName[ ] );
native cod_get_class_name( iClassId, szName[ ], iLen );
native cod_get_class_description( iClassId, szDescription[ ], iLen )
native cod_get_class_faction( iClassId, szFaction[ ], iLen )
native cod_get_class_flag( iClassId, szFlag[ ], iLen )
	
// Perks
native cod_register_perk( const szName[ ], const szDescrption[ ], iPrice, const szBlocks[ ] );
native cod_perks_number( );
native cod_get_perk_id( const szName[ ] );
native cod_get_perk_name( iPerkId, szName[ ], iLen )
native cod_get_perk_description( iPerkId, szDescription[ ], iLen )
native cod_get_perk_price( iPerk );

// Levels
native cod_get_level( iPlayer );
native cod_get_xp( iPlayer );
native cod_set_xp( iPlayer, iValue );
	
// Gold
native cod_get_gold( iPlayer );
native cod_set_gold( iPlayer, iValue );
	
// Player Class
native cod_get_class( iPlayer );
native cod_set_class( iPlayer, iClass );
	
// Player Perk
native cod_get_perk( iPlayer );
native cod_set_perk( iPlayer, iPerk );

// Player Max HP
native cod_get_player_max_hp( iPlayer );
native cod_set_player_max_hp( iPlayer, iValue );
	
// Points
native cod_get_energy( iPlayer );
native cod_set_energy( iPlayer, iValue );
native cod_get_resistance( iPlayer );
native cod_set_resistance( iPlayer, iValue );
native cod_get_stamina( iPlayer );
native cod_set_stamina( iPlayer, iValue );
native cod_get_damage( iPlayer );
native cod_set_damage( iPlayer, iValue );

// Other
native cod_set_weapon_pickup( iPlayer, iValue );
native cod_calculate_level( iLevel );
native cod_set_double_xp( iPlayer, iValue );

// Forwards
forward cod_class_selected( iPlayer, iClass );
forward cod_class_pre_selected( iPlayer, iClass );
forward cod_class_changed( iPlayer, iOldClass, iNewClass );
	
forward cod_perk_got( iPlayer, iPerk );
forward cod_perk_changed( iPlayer, iOldPerk, iNewPerk );

forward cod_abilities_set_pre( iPlayer, iClass );
forward cod_abilities_set_post( iPlayer, iClass );
	
forward cod_death( iAttcker, iVictim, iHs );
forward cod_level_up( iPlayer, iOldLevel, iNewLevel );
forward cod_used_ability( iPlayer );