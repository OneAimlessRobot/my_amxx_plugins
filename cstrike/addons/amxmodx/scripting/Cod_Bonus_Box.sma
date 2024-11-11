#include < amxmodx >
#include < hamsandwich >
#include < ByM_Cod_2016 >
#include < bym_framework >
#include < colorchat >
#include < fakemeta >
#include < engine >
#include < fun >
#include < xs >

// Credits to Opo4uMapy for helping me out with box sprite!

new const g_szBoxModel[ ] = "models/ByM_Cod/BonusBox.mdl";
new const g_szBoxPickupSound[ ] = "ByM_Cod/BoxTouched.wav";
new const g_szSprite[ ] = "sprites/ByM_Cod/BonusBox.spr";

public plugin_init( ) {
	register_plugin( "[ByM] Bonus Box", "1.3", "Milutinke (ByM)" );
	
	RegisterHam( Ham_Killed, "player", "fw_HamPlayerDeath", .Post = true );
	
	register_forward( FM_Touch, "fw_FmBoxTouched" );
	register_forward( FM_AddToFullPack, "Fw_AddToFullPack", 1 );
	register_forward( FM_CheckVisibility, "fw_FmCheckVisibility" );
	
	register_think( "BonusBox", "fw_BoxThink" );
}

public plugin_precache( ) {
	precache_model( g_szBoxModel );
	precache_sound( g_szBoxPickupSound );
	precache_model( g_szSprite );
}

public fw_HamPlayerDeath( iVictim, iAttacker, iSh ) {
	if( !is_user_connected( iVictim ) )
		return HAM_IGNORED;
	
	new Float: fOrigin[ 3 ];
	pev( iVictim, pev_origin, fOrigin );
	CreateBox( fOrigin );
	
	return HAM_IGNORED;
}

public fw_FmCheckVisibility( iEntity, S ) {
	if( !is_valid_ent( iEntity ) )
		return FMRES_IGNORED;
	
	static szClassName[ 20 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	if( !equal( szClassName, "BoxSprite" ) )
		return FMRES_IGNORED;
	
	forward_return( FMV_CELL, 1 );
	
	return FMRES_SUPERCEDE;
}

public Fw_AddToFullPack( iEsHandle, e, iEntity, iHost, iHostFlags, iPlayer, pSet ) {
	if( !is_user_connected( iHost ) || !is_user_alive( iHost ) )
		return FMRES_IGNORED;

	if( !is_valid_ent( iEntity ) )
		return FMRES_IGNORED;
	
	static szClassName[ 20 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	if( !equal( szClassName, "BoxSprite" ) )
		return FMRES_IGNORED;

	if( !is_valid_ent( iEntity ) || !is_user_connected( iHost ) )
		return FMRES_IGNORED;

	set_es( iEsHandle, ES_Effects, !is_user_alive( iHost ) ? ( get_es( iEsHandle, ES_Effects ) | EF_NODRAW ) : get_es( iEsHandle, ES_Effects ) & ~EF_NODRAW  );

	static iPointTrace;
	iPointTrace = create_tr2( );
	static Float: fStart[ 3 ], Float: fEnd[ 3 ], Float: fEndPosition[ 3 ], Float: fNormal[ 3 ];
	
	entity_get_vector( iHost, EV_VEC_origin, fStart );
	entity_get_vector( iEntity, EV_VEC_origin, fEnd );
	
	engfunc( EngFunc_TraceLine, fStart, fEnd, IGNORE_MONSTERS, iEntity, iPointTrace );
	static Float: fFriction;
	get_tr2( iPointTrace, TR_flFraction, fFriction );		

	get_tr2( iPointTrace, TR_vecEndPos, fEndPosition );
	get_tr2( iPointTrace, TR_vecPlaneNormal, fNormal );

	xs_vec_mul_scalar( fNormal, 7.0, fNormal );
	xs_vec_add( fEndPosition, fNormal, fNormal );
	
	set_es( iEsHandle, ES_Origin, fNormal );
	static Float: fDistance, Float: fSpriteScale;
	
	entity_get_vector( iEntity, EV_VEC_origin, fStart );
	entity_get_vector( iHost, EV_VEC_origin, fEnd );
	fDistance = get_distance_f( fStart, fEnd );

	if( fDistance <= 39.37 * 100.0 && is_valid_ent( entity_get_int( iEntity, EV_INT_iuser1 ) ) ) {
		set_es( iEsHandle, ES_Frame, ( fDistance > 1.0 ) ? float( 101 - floatround( fDistance / 39.37 ) ) : 0.0 );

		fDistance = get_distance_f( fEndPosition, fEnd );
		fSpriteScale = 10.0 / fDistance;
	
		if( fSpriteScale > 0.5 )
			fSpriteScale = 0.5;

		if( fFriction != 1.0 ) {	
			if( fSpriteScale < 0.5 )
				fSpriteScale = 0.5;
		}
		else {
			if( fSpriteScale < 0.5 )
				fSpriteScale = 0.5;
		}
		
		set_es( iEsHandle, ES_Scale, fSpriteScale );
	}
	else {
		set_es( iEsHandle, ES_Effects, get_es( iEsHandle, ES_Effects ) | EF_NODRAW );
		remove_entity( iEntity );
	}
	
	free_tr2( iPointTrace );
	return FMRES_IGNORED
	
}

public CreateBox( Float: fOrigin[ 3 ] ) {
	new iEntity = create_entity( "info_target" );
	
	if( !is_valid_ent( iEntity ) )
		return;
	
	entity_set_string( iEntity, EV_SZ_classname, "BonusBox" );
	set_pev( iEntity, pev_origin, fOrigin );
	entity_set_model( iEntity, g_szBoxModel );
	entity_set_int( iEntity, EV_INT_body, random_num( 1, 2 ) );

	entity_set_vector( iEntity, EV_VEC_maxs, Float: { 10.0, 10.0, 25.0 } );
	entity_set_vector( iEntity, EV_VEC_mins, Float: { -10.0, -10.0, 0.0 } );
	entity_set_vector( iEntity, EV_VEC_size, Float: { 10.0, 10.0, 25.0 } );
	entity_set_int( iEntity, EV_INT_solid, SOLID_TRIGGER );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_NOCLIP );
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 0.1 );
	drop_to_floor( iEntity );

	CreateSprite( iEntity );
}

public fw_BoxThink( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return;
		
	static szClassName[ 14 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	if( !equal( szClassName, "BonusBox" ) )
		return;
	
	if( is_valid_ent( iEntity ) )
		drop_to_floor( iEntity );
}

public CreateSprite( iEntityId ) {
	new iEntity, Float: fOrigin[ 3 ];

	pev( iEntityId, pev_origin, fOrigin );
	iEntity = create_entity( "info_target" );

	if( !is_valid_ent( iEntity ) )
		return;

	fOrigin[ 2 ] += 35.0;

	entity_set_string( iEntity, EV_SZ_classname, "BoxSprite" );
	set_pev( iEntity, pev_origin, fOrigin );
	entity_set_int( iEntityId, EV_INT_iuser1, iEntity );
	entity_set_int( iEntity, EV_INT_iuser1, iEntityId );
	entity_set_model( iEntity, g_szSprite );
	set_rendering( iEntity, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 240 );
	entity_set_int( iEntity, EV_INT_solid, SOLID_NOT );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_NONE );
}

public fw_FmBoxTouched( iEntity, iPlayer ) {
	if( !is_valid_ent( iEntity ) )
		return HAM_IGNORED;
	
	if( !is_user_alive( iPlayer ) || !is_user_connected( iPlayer ) )
		return HAM_IGNORED;
	
	static szClassName[ 20 ];
	entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
	
	if( !equal( szClassName, "BonusBox" ) )
		return HAM_IGNORED;
	
	BoxTouched( iPlayer );
	
	remove_entity( iEntity );
	engfunc( EngFunc_EmitSound, iPlayer, CHAN_ITEM, g_szBoxPickupSound, 1.0, ATTN_NORM, 0, PITCH_NORM );

	return HAM_IGNORED;
}

public BoxTouched( iPlayer ) {
	bym_screen_fade( iPlayer, 1 << 10, 1 << 10, 1 << 4, 0, 255, 255, 70 );
	
	switch( random_num( 0, 11 ) ) {
		case 0: {
			cod_set_xp( iPlayer, cod_get_xp( iPlayer ) + 100 );
			ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_BONUS_100XP" );
		}
		
		case 1: {
			cod_set_xp( iPlayer, cod_get_xp( iPlayer ) + 200 );
			ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_BONUS_200XP" );
		}
		
		case 2: {
			cod_set_xp( iPlayer, cod_get_xp( iPlayer ) + 500 );
			ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_BONUS_500XP" );
		}
		
		case 3: {
			cod_set_xp( iPlayer, cod_get_xp( iPlayer ) + 1000 );
			ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_BONUS_1000XP" );
		}
		
		case 4: ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_NOTHING" );
		
		case 5: {
			cod_set_gold( iPlayer, cod_get_gold( iPlayer ) + 1 );
			ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_BONUS_1_GOLD" );
		}
		
		case 6: {
			cod_set_gold( iPlayer, cod_get_gold( iPlayer ) + 2 );
			ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_BONUS_2_GOLD" );
		}
		
		case 7: {
			cod_set_gold( iPlayer, cod_get_gold( iPlayer ) + 3 );
			ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_BONUS_3_GOLD" );
		}
		
		case 8: ColorChat( iPlayer, GREEN, "[CoD:Mw] ^1%L", iPlayer, "ML_NOTHING" );
	} 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
