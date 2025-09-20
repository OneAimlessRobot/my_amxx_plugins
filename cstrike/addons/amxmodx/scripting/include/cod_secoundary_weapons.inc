enum {
	ROCKET_TYPE_ORDINARY = 0,
	ROCKET_TYPE_INSTANT
}

enum {
	ROCKET_TRACER_OFF = 0,
	ROCKET_TRACER_ON
}

enum {
	MINE_TYPE_ORDINARY = 0,
	MINE_TYPE_INSTANT
}

enum {
	EXPLOSION_RESISTANCE_OFF,
	EXPLOSION_RESISTANCE_ON
}

/**
*	@name 		cod_set_rockets
*	@description	Allows you to give rockets to player
*	@example	cod_set_rockets( iPlayer, 3, ROCKET_TYPE_NORMAL, ROCKER_TRACER_OFF )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Number of rockets
*	@param		iInstant - int > Is rocket instant (Togggle: ROCKET_TYPE_ORDINARY or ROCKET_TYPE_INSTANT)
*	@param		iTracer - int > Does rocket track players (Toggle: ROCKET_TRACER_OFF or ROCKET_TRACER_ON)
*	@return 	void
*/

native cod_set_rockets( iPlayer, iValue, iInstant, iTracer );

/**
*	@name 		cod_set_medkits
*	@description	Allows you to give med kits to player
*	@example	cod_set_medkits( iPlayer, 2 )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Number of med kits
*	@return 	void
*/

native cod_set_medkits( iPlayer, iValue );

/**
*	@name 		cod_set_poisonkits
*	@description	Allows you to give poison kits to player
*	@example	cod_set_poisonkits( iPlayer, 2 )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Number of poison kits
*	@return 	void
*/

native cod_set_poisonkits( iPlayer, iValue );

/**
*	@name 		cod_set_magnets
*	@description	Allows you to give magnets to player
*	@example	cod_set_magnets( iPlayer, 2 )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Number of magnets
*	@return 	void
*/

native cod_set_magnets( iPlayer, iValue );

/**
*	@name 		cod_set_dynamites
*	@description	Allows you to give dynamites to player
*	@example	cod_set_dynamites( iPlayer, 5 )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Number of dynamites
*	@return 	void
*/

native cod_set_dynamites( iPlayer, iValue );

/**
*	@name 		cod_set_mines
*	@description	Allows you to give mines to player
*	@example	cod_set_mines( iPlayer, 3, MINE_TYPE_INSTANT )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Number of mines
*	@param		iInstant - int > Is mine instant (Togggle: MINE_TYPE_ORDINARY or MINE_TYPE_INSTANT)
*	@return 	void
*/

native cod_set_mines( iPlayer, iValue, iInstant );

/**
*	@name 		cod_set_lightnings
*	@description	Allows you to give lightnings to player
*	@example	cod_set_lightnings( iPlayer, 7 )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Number of lightnings
*	@return 	void
*/

native cod_set_lightnings( iPlayer, iValue );

/**
*	@name 		cod_set_explosion_resistance
*	@description	Allows you to give resistance to explosions caused by Rockets, Mines and Dynamites
*	@example	cod_set_explosion_resistance( iPlayer, 7 )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Toggle: EXPLOSION_RESISTANCE_OFF or EXPLOSION_RESISTANCE_ON
*	@return 	void
*/

native cod_set_explosion_resistance( iPlayer, iValue );

/**
*	@name 		cod_reset_secondary_weapons
*	@description	Resets Rocets, MedKits, Poison Kits, Dynamites. Mines, Explosion Resistance and Lightnings.
*	@example	cod_reset_secondary_weapons( iPlayer )
*
*	@param		iPlayer - int > Player id
*	@param		iValue  - int > Toggle: EXPLOSION_RESISTANCE_OFF or EXPLOSION_RESISTANCE_ON
*	@return 	void
*/

native cod_reset_secondary_weapons( iPlayer );

/**
*	@name 		cod_create_explosion
*	@description	Creates explosion
*	@example	cod_create_explosion( iAttacker, iAttacker, false, 130.0, true );
*
*	@param		iAttacker - int > Owner id
*	@param		iEntity - int > Entity which is creating explosion (Can be player, rocket, etc...)
*	@param		bJustExplode - bool > If it is true does not hurt nearby players (Toggle: true/false)
*	@param 		fHealth - float > How mutch HP is taking per explosion
*	@param 		bBeamCylinder - bool > Does create beam ring effect (Toggle: true/false)
*	@return 	void
*/

native cod_create_explosion( iAttacker, iEntity, bool: bJustExplode, Float: fHealth, bool: bBeamCylinder );

/**
*	@name 		cod_create_beam_ring
*	@description	Creates beam ring effect
*	@example	cod_create_beam_ring( iOrigin, 300, 0, 0, 10, 10, 255, 0, 255, 255, 255, 1 );
*
*	@param		iOrigin - int > Origin with 3 dimensions
*	@param		iPlusOrigin - int > Radius
*	@param		iStartFrame - int > Start frame of sprite
*	@param 		iFrameRate - int > Frame rate of sprite (How mutch frames per secound)
*	@param 		iLife - int > Life in mili secounds
*	@param 		iWidth - int > Width
*	@param 		iNoise - int > Noise
*	@param 		iRed - int > Red color ammount
*	@param 		iGreen - int > Green color ammount
*	@param 		iBlue - int > Blue color ammount
*	@param 		iAlpha - int > Opcity/Transparency
*	@param 		iSpeed - int > Speed of effect
*	@return 	void
*/
native cod_create_beam_ring( iOrigin[ 3 ], iPlusOrigin, iStartFrame, iFrameRate, iLife, iWidth, iNoise, iRed, iGreen, iBlue, iAlpha, iSpeed );

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
