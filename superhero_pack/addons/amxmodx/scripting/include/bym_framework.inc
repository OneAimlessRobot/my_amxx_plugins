#define NO_WEAPON					-1
#define NewStaticInt(%1,%2)			static %1; %1 = %2
#define NewStaticFloat(%1,%2)		static Float: %1; %1 = %2

/**
*	@name 		bym_reset_everything
*	@description	Resets every ability that player has.
*	@example	bym_reset_everything( iPlayer )
*
*	@param		iPlayer	- int > Player id
*	@return 	void
*/

native bym_reset_everything( iPlayer );

/**
*	@name 		bym_set_jetpack
*	@description 	You can set or unset jetpack to player.
*	@example	bym_set_jetpack( iPlayer, JETPACK_SUPER )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue	- int > Jet Pack Type
*	@return 	void
*/

native bym_set_jetpack( iPlayer, iValue );

enum {
	JETPACK_NO = 0,
	JETPACK_ORDINARY,
	JETPACK_SUPER
}

/**
*	@name 		bym_is_shooting_at_back
*	@description 	Allows you to detect is player shooting antorher player to back
*	@example	if( bym_is_shooting_at_back( iPlayer, iTarget ) ) { Do something here }
*
*	@param		iPlayer	- int > Player id
*	@param		iTarget - int > Enemy
*	@return 	boolean
*/
native bool: bym_is_shooting_at_back( iPlayer, iTarget );

/**
*	@name 		bym_set_bullet_proof
*	@description 	You can set number of bullets, for which player does not take damage.
*	@example	bym_set_bullet_proof( iPlayer, 5 )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue	- int > Number of bullets
*	@return 	void
*/

native bym_set_bullet_proof( iPlayer, iValue );

/**
*	@name 		bym_set_instant_kill
*	@description 	You can give player instant kill on certain weapon with certain chance.
*	@example	bym_set_instant_kill( iPlayer, CSW_AK47, 7 )
*
*	@param		iPlayer	- int > Player id
*	@param		iWeapon	- int > Weapon id
*	@param		iChance - int > Chance
*	@return 	void
*/

native bym_set_instant_kill( iPlayer, iWeapon, iChance );

/**
*	@name 		bym_set_additional_damage
*	@description 	You can give player additional damage with certain weapon - If you want to add damage to all weapons of player, pass NO_WEAPON as value for iWeapon.
*	@example	bym_set_additional_damage( iPlayer, CSW_AK47, 50 )
*
*	@param		iPlayer	- int > Player id
*	@param		iWeapon	- int > Weapon id
*	@param		iDamage - int > Additional damage
*	@return 	void
*/

native bym_set_additional_damage( iPlayer, iWeapon, iDamage );

/**
*	@name 		bym_set_resistance
*	@description 	You can allow player to be resistant to certain weapon with certain chance.
*	@example	bym_set_resistance( iPlayer, CSW_KNIFE, 1 )
*
*	@param		iPlayer	- int > Player id
*	@param		iWeapon	- int > Weapon id
*	@param		iChance - int > Chance
*	@return 	void
*/

native bym_set_resistance( iPlayer, iWeapon, iChance );

/**
*	@name 		bym_set_ignore_resistance
*	@description 	You can allow player to be kill even resistant players
*	@example	bym_set_ignore_resistance( iPlayer, IGNORE_RESISTANCE_ON )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue - int > Toogle (IGNORE_RESISTANCE_OFF/IGNORE_RESISTANCE_ON)
*	@return 	void
*/

native bym_set_ignore_resistance( iPlayer, iValue );

enum {
	IGNORE_RESISTANCE_OFF,
	IGNORE_RESISTANCE_ON
}

/**
*	@name 		bym_set_instant_kill_resisance
*	@description 	You can allow player to be resistant to instant kills
*	@example	bym_set_instant_kill_resisance( iPlayer, INSTANT_KILL_RESISTANCE_ON )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue	- int > Toggle (INSTANT_KILL_RESISTANCE_OFF or INSTANT_KILL_RESISTANCE_ON)
*	@return 	void
*/

native bym_set_instant_kill_resisance( iPlayer, iValue );

enum {
	INSTANT_KILL_RESISTANCE_OFF = 0,
	INSTANT_KILL_RESISTANCE_ON
}

/**
*	@name 		bym_screen_shake
*	@description	Shakes screen of the player 
*	@example	bym_screen_shake( iPlayer, 7 )
*
*	@param		iPlayer	- int > Player id
*	@param		iSeconds - int > Number of seconds (Duration)
*	@return 	void
*/

native bym_screen_shake( iPlayer, iSeconds );

/**
*	@name 		bym_screen_fade
*	@description	Displayers certain color over the player screen with specified duration and hold time 
*	@example	bym_screen_fade( iPlayer, iDuration, iHoldTime, iFadeType, iRed, iGreen, iBlue, iAlpha )
*
*	@param		iPlayer	- int > Player id
*	@param		iDuration - int > Number of seconds (Duration)
*	@param		iHoldTime - int > Number of seconds (Duration)
*	@param		iFadeType - int > Fade type
*	@param		iRed	  - int > Red color ammount
*	@param		iGreen	  - int > Green color ammount
*	@param		iBlue	  - int > Blue color ammount
*	@param		iAlpha	  - int > Transparency
*	@return 	void
*/
native bym_screen_fade( iPlayer, iDuration, iHoldTime, iFadeType, iRed, iGreen, iBlue, iAlpha );

/**
*	@name 		bym_respawn_as_enemy
*	@description	Respawns player in enemy's base with certain chance
*	@example	bym_respawn_as_enemy( iPlayer, 8 )
*
*	@param		iPlayer	- int > Player id
*	@param		iChance - int > Chance for respawn
*	@return 	void
*/
native bym_respawn_as_enemy( iPlayer, iChance );

/**
*	@name 		bym_set_no_recoil
*	@description	Allows you to set or unset no recoil of player
*	@example	bym_set_no_recoil( iPlayer, NO_RECOIL_ON )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue  - int > Toggle (NO_RECOIL_OFF or NO_RECOIL_ON)
*	@return 	void
*/
native bym_set_no_recoil( iPlayer, iValue );

enum {
	NO_RECOIL_OFF = 0,
	NO_RECOIL_ON
}

/**
*	@name 		bym_set_fast_reload
*	@description	Allows you to set or unset no fast reload to player
*	@example	bym_set_fast_reload( iPlayer, FAST_RELOAD_ON )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue  - int > Toggle (FAST_RELOAD_OFF or FAST_RELOAD_ON)
*	@return 	void
*/
native bym_set_fast_reload( iPlayer, iValue );

enum {
	FAST_RELOAD_OFF = 0,
	FAST_RELOAD_ON
}

/**
*	@name 		bym_set_weapon_clip
*	@description	Allows you to set the clip of player's weapon
*	@example	bym_set_weapon_clip( iPlayer, 50 )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue  - int > Ammount of bullets
*	@return 	void
*/

native bym_set_weapon_clip( iPlayer, iValue );

/**
*	@name 		bym_set_unlimited_clip
*	@description	Allows you to give the player albility to have unlimited clip
*	@example	bym_set_unlimited_clip( iPlayer, UNLIMITED_CLIP_ON )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue  - int > Toggle (UNLIMITED_CLIP_OFF or UNLIMITED_CLIP_ON)
*	@return 	void
*/

native bym_set_unlimited_clip( iPlayer, iValue );

enum {
	UNLIMITED_CLIP_OFF = 0,
	UNLIMITED_CLIP_ON
}

/**
*	@name 		bym_set_hs_immunity
*	@description	Allows you to give player chance of avoiding damage when hitted at head
*	@example	bym_set_hs_immunity( iPlayer, 3 )
*
*	@param		iPlayer	- int > Player id
*	@param		iChance - int > Chance
*	@return 	void
*/

native bym_set_hs_immunity( iPlayer, iChance );

/**
*	@name 		bym_set_aim
*	@description	Allows you to give player chance for hitting enemies only in head with certain chance and certain weapon (To exclude weapon, pass NO_WEAPON as iWeapon parameter)
*	@example	With weapon and 1/1 chance: bym_set_aim( iPlayer, CSW_M4A1, 1 )
*	@example	Without weapon and 1/4 chance: bym_set_aim( iPlayer, -1, 3 )
*
*	@param		iPlayer	- int > Player id
*	@param		iWeapon - int > Weapon id
*	@param		iChance - int > Chance
*	@return 	void
*/

native bym_set_hs_only( iPlayer, iChance );

native bym_set_aim( iPlayer, iWeapon, iChance );

/**
*	@name 		bym_set_wall_climbing
*	@description	Allows you to give ability to climb to walls, to player
*	@example	bym_set_wall_climbing( iPlayer, WALL_CLIMB_ON )
*
*	@param		iPlayer	- int > Player id
*	@param		iValue  - int > Toggle (WALL_CLIMB_OFF or WALL_CLIMB_ON)
*	@return 	void
*/

native bym_set_wall_climbing( iPlayer, iValue );

enum {
	WALL_CLIMB_OFF = 0,
	WALL_CLIMB_ON
}

/**
*	@name 		bym_make_time_bar
*	@description	Allows you display player time bar for certain time and percentage
*	@example	bym_make_time_bar( iPlayer, 3, 70 )
*
*	@param		iPlayer	 - int > Player id
*	@param		iSeconds - int > Number of Seconds (Time)
*	@param		iPercent - int > Percentage (0-100)
*	@return 	void
*/

native bym_make_time_bar( iPlayer, iSeconds, iPercent );

/**
*	@name 		bym_set_multi_jump
*	@description	Allows you set or unset multi jump to player
*	@example	bym_set_multi_jump( iPlayer, 2 )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Number of jumps
*	@return 	void
*/

native bym_set_multi_jump( iPlayer, iValue );

/**
*	@name 		bym_set_xray
*	@description	Allows you to allow player to see invisible players (Except those who have Anti Xray ability)
*	@example	bym_set_xray( iPlayer, XRAY_ON )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Toggle (XRAY_OFF or XRAY_ON)
*	@return 	void
*/

native bym_set_xray( iPlayer, iValue );

enum {
	XRAY_OFF = 0,
	XRAY_ON
}

/**
*	@name 		bym_set_anti_xray
*	@description	Allows you to allow to avoid to be seen by players with xray ability
*	@example	bym_set_anti_xray( iPlayer, ANTI_XRAY_ON )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Toggle (ANTI_XRAY_OFF or ANTI_XRAY_ON)
*	@return 	void
*/

native bym_set_anti_xray( iPlayer, iValue );

enum {
	ANTI_XRAY_OFF = 0,
	ANTI_XRAY_ON
}

/**
*	@name 		bym_set_visibility
*	@description	Allows you to set player visibility level easily
*	@example	bym_set_visibility( iPlayer, 70 )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Visibility level (0-255)
*	@return 	void
*/

native bym_set_visibility( iPlayer, iValue );

/**
*	@name 		bym_set_weapon_invisiblity
*	@description	Allows you to set player visibility level on certain weapon easily
*	@example	bym_set_weapon_invisiblity( iPlayer, CSW_KNIFE, 8, 255 )
*
*	@param		iPlayer - int > Player id
*	@param 		iWeapon - int > Weapon id
*	@param		iVisibility - int > Visibility level (8-255)
*	@param 		iDefault	- int > Default invisibility level
*	@return 	void
*/

native bym_set_weapon_invisiblity( iPlayer, iWeapon, iVisibility, iDefault );

/**
*	@name 		bym_set_magician
*	@description	Allows you to allow player to be less visible while crouching, with certain visibility level
*	@example	bym_set_magician( iPlayer, NO_WEAPON, 8, 255 )
*
*	@param		iPlayer - int > Player id
*	@param		iPlayer - int > Weapon
*	@param		iValue  - int > Visibility level (8-255)
*	@param		iValue  - int > Default Visibility level (8-255)
*	@return 	void
*/

native bym_set_magician( iPlayer, iWeapon, iValue, iDefaultValue );

/**
*	@name 		bym_set_teleport
*	@description	Allow you to give player ability to teleport by pressing button E, every N secounds
*	@example	bym_set_teleport( iPlayer )
*
*	@param		iPlayer - int > Player id
*	@param 		iTime   - int > Seconds
*	@return 	void
*/

native bym_set_teleport( iPlayer, iTime );

/**
*	@name 		bym_set_vampire
*	@description	Allow you to give player vampire ability
*	@example	bym_set_vampire( iPlayer, cod_get_player_max_hp( iPlayer ) )
*
*	@param		iPlayer - int > Player id
*	@param 		iMaxHP  - int > Maximum hp that player can have
*	@return 	void
*/

native bym_set_vampire( iPlayer, iMaxHP );

/**
*	@name 		bym_set_military_secret
*	@description	Allow you to give player ability to blind an enemy while shooting at him
*	@example	bym_set_military_secret( iPlayer, 6 )
*
*	@param		iPlayer - int > Player id
*	@param 		iChance - int > Chance
*	@return 	void
*/
native bym_set_military_secret( iPlayer, iChance );

/**
*	@name 		bym_set_dropper
*	@description	Allow you to give player ability to make an enemy drop his weapon while shooting at him
*	@example	bym_set_dropper( iPlayer, 5 )
*
*	@param		iPlayer - int > Player id
*	@param 		iChance - int > Chance
*	@return 	void
*/
native bym_set_dropper( iPlayer, iChance );

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
