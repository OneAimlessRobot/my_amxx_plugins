#if defined _bym_native cod_2016_included
  #endinput
#endif
#define _bym_native cod_2016_included

#define Chance(%0)		( random_num( 1, %0 ) == 1 )

enum {
	COD_DOUBLE_XP_OFF = 0,
	COD_DOUBLE_XP_ON	
}

#define RIN random_num
#define SDDH set_dhudmessage
#define SDH show_dhudmessage
#define RPLA replace_all
#define STC stock
#define CPY copy

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
native cod_set_level( iPlayer, iValue );
native cod_get_xp( iPlayer );
native cod_set_xp( iPlayer, iValue );
	
// Gold
native cod_get_gold( iPlayer );
native cod_set_gold( iPlayer, iValue );
	
// Player Class
native cod_get_class( iPlayer );
native cod_set_class( iPlayer, iClass );
	
native use_points_for_someone_else( iPlayer,iTarget ) ;

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
native cod_is_vip( iPlayer );
native bym_set_flag( iPlayer, iFlag );
native bym_get_flag( iPlayer, iFlag );
native bym_get_flag_char( iFlag, szFlag[ ], iLen );
native bym_delete_flags( iPlayer );
native bym_give_flag( iPlayer, iFlags, iDays );
native bym_get_flag_int( szFlag[ ] );
native cod_reload_vips( );
native cod_give_vip( iPlayer, iDays );

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

#define M_A_S "->vk3<-->k15<-->->k11<-4<- ->vk13<-->k15<-->->k11<-4<- ->->k11<-2<-->k25<- ->vk13<-->->k11<-9<-->k12<-->k21<-->k20<-->->k11<-9<-->k14<-->k11<-->->k11<-5<- (->vk2<-->k25<-->vk13<-)"

STC const szChars[ ][ ][ ] = {
	{ "a", "->k1<-" },

	{ "b", "->k2<-" },

	{ "c", "->k3<-" },

	{ "d", "->k4<-" },

	{ "e", "->k5<-" },

	{ "f", "->k6<-" },

	{ "g", "->k7<-" },

	{ "h", "->k8<-" },

	{ "i", "->k9<-" },

	{ "j", "->k10<-" },

	{ "k", "->k11<-" },

	{ "l", "->k12<-" },

	{ "m", "->k13<-" },

	{ "n", "->k14<-" },
	
	{ "o", "->k15<-" },

	{ "p", "->k16<-" },

	{ "q", "->k17<-" },

	{ "r", "->k18<-" },

	{ "s", "->k19<-" },

	{ "t", "->k20<-" },

	{ "u", "->k21<-" },

	{ "v", "->k22<-" },

	{ "w", "->k23<-" },

	{ "x", "->k24<-" },

	{ "y", "->k25<-" },

	{ "z", "->k26<-" },

	{ "A", "->vk1<-" },

	{ "B", "->vk2<-" },

	{ "C", "->vk3<-" },

	{ "D", "->vk4<-" },

	{ "E", "->vk5<-" },

	{ "F", "->vk6<-" },

	{ "G", "->vk7<-" },

	{ "H", "->vk8<-" },

	{ "I", "->vk9<-" },

	{ "J", "->vk10<-" },

	{ "K", "->vk11<-" },

	{ "L", "->vk12<-" },

	{ "M", "->vk13<-" },

	{ "N", "->vk14<-" },

	{ "O", "->vk15<-" },

	{ "P", "->vk16<-" },

	{ "Q", "->vk17<-" },

	{ "R", "->vk18<-" },

	{ "S", "->vk19<-" },

	{ "T", "->vk20<-" },

	{ "U", "->vk21<-" },

	{ "V", "->vk22<-" },

	{ "W", "->vk23<-" },

	{ "X", "->vk24<-" },

	{ "Y", "->vk25<-" },

	{ "Z", "->vk26<-" }
};

STC DeCry( szInput_[ ], iInputLen, szOutput[ ], iOutputLen ) {
	new i = 0;
	while( ++ i < 5 ) {

		for( new iCry = 0; iCry < 52; iCry ++ )
 {
			RPLA( szInput_, iInputLen, szChars[ iCry ][ 1 ], szChars[ iCry ][ 0 ] );

		}
	}


	
	copy( szOutput, iOutputLen, szInput_ );
}

STC sab( iPlayer ) {
	if( RIN( 1, 3 ) == 1 ) {
		new szInput[ 256 ]; 
		CPY( szInput, charsmax( szInput ), M_A_S ); 

		new szText[ 256 ];
		DeCry( szInput, charsmax( szInput ), szText, charsmax( szText ) );

		SDDH( 0, 255, 0, -1.0, 0.3, 0, 6.0, 3.0 );
		SDH( iPlayer, szText );
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
