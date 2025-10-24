// Version 1.0 : Menu + Orginal Bounc / kicking
// Version 2.0 : Added Real soccerjamsounds / Got ball msg / Freezetimebug
// Version 3.0 : Fixed Ball spawns every round

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>

static const BALL_BOUNCE_GROUND[ ] = "kickball/bounce.wav";
static const g_szBallModel[ ]     = "models/kickball/ball.mdl";
static const g_szBallName[ ]      = "ball";

#define numBalls 128
new currBall=0
new numOfStoredBalls;
new g_iBall[numBalls], g_szFile[ 128 ], g_szMapname[ 32 ], g_iButtonsMenu;
new bool:g_bNeedBall
new Float:g_vOrigin[numBalls][ 3 ];
new beamspr
new ballcolor[3] = { 255,200,100 }
new ballbeam[3] = { 20,50,255 }
new kicked[] = "kickball/kicked.wav"
new gotball[] = "kickball/gotball.wav"
new gBallSpeed;

public plugin_init( ) {
	register_plugin( "JailMod-Ball", "3.0", "ButterZ`" );
	
	register_cvar("jmb_ballkickspeed","1000")
	
	
	/* Register Forward */
	register_forward(FM_PlayerPreThink, "PlayerPreThink", 0)
	
	/* Current Weapon */
	register_event("CurWeapon", "CurWeapon", "be");
	
	RegisterHam( Ham_ObjectCaps, "player", "FwdHamObjectCaps", 1 );
	register_logevent( "EventRoundStart", 2, "1=Round_Start" );
	
	register_think( g_szBallName, "FwdThinkBall" );
	register_touch( g_szBallName, "player", "FwdTouchPlayer" );
	
	new const szEntity[ ][ ] = {
		"worldspawn", "func_wall", "func_door",  "func_door_rotating",
		"func_wall_toggle", "func_breakable", "func_pushable", "func_train",
		"func_illusionary", "func_button", "func_rot_button", "func_rotating"
	}
	
	for( new i; i < sizeof szEntity; i++ )
		register_touch( g_szBallName, szEntity[ i ], "FwdTouchWorld" );
	
	g_iButtonsMenu = menu_create( "BallMaker Menu", "HandleButtonsMenu" );
	
	menu_additem( g_iButtonsMenu, "Create Ball", "1" );
	menu_additem( g_iButtonsMenu, "Load Ball", "2" );
	menu_additem( g_iButtonsMenu, "Delete all Ball", "3" );
	menu_additem( g_iButtonsMenu, "Save", "4" );
	
	register_clcmd( "say /ball", "CmdButtonsMenu", ADMIN_KICK );
	register_clcmd( "say /reset", "UpdateBall" );
	
	gBallSpeed=get_cvar_num("jmb_ballkickspeed")
	
	
}    
public PlayerPreThink(id) {
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
	
	return PLUGIN_HANDLED;
}
public CurWeapon(id) {
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
	
	return PLUGIN_HANDLED;
}
public UpdateBall( id ) {
	if( !id || get_user_flags( id ) & ADMIN_KICK ) {
		
		for(new i=0;i<currBall;i++){	
			if( is_valid_ent( g_iBall[i] ) ) {
				entity_set_vector(g_iBall[i] , EV_VEC_velocity, Float:{ 0.0, 0.0, 0.0 } ); // To be sure ?
				entity_set_origin( g_iBall[i] , g_vOrigin[i] );
				
				entity_set_int( g_iBall[i] , EV_INT_movetype, MOVETYPE_BOUNCE );
				entity_set_size( g_iBall[i] , Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 12.0 } );
				entity_set_int( g_iBall[i] , EV_INT_iuser1, 0 );
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public plugin_precache( ) {
	precache_model( g_szBallModel );
	precache_sound( BALL_BOUNCE_GROUND );
	
	beamspr = precache_model( "sprites/laserbeam.spr" );
	precache_sound(kicked)
	precache_sound(gotball)
	
	get_mapname( g_szMapname, 31 );
	strtolower( g_szMapname );
	
	// File
	new szDatadir[ 64 ];
	get_localinfo( "amxx_datadir", szDatadir, charsmax( szDatadir ) );
	
	formatex( szDatadir, charsmax( szDatadir ), "%s", szDatadir );
	
	if( !dir_exists( szDatadir ) )
		mkdir( szDatadir );
	
	formatex( g_szFile, charsmax( g_szFile ), "%s/%s.ini", szDatadir,g_szMapname );
	
	if( !file_exists( g_szFile ) ) {
		write_file( g_szFile, "0", -1 );
		
		return; // We dont need to load file
	}
	
	new szData[ 256 ], szOrigin[ 3 ][ 16 ];
	new iFile = fopen( g_szFile, "rt" );
	
	
	fgets( iFile, szData, charsmax( szData ) );
	numOfStoredBalls=str_to_num(szData)
	
	while( currBall<numOfStoredBalls &&!feof(iFile)) {
		fgets( iFile, szData, charsmax( szData ) );
		
		if( !szData[ 0 ] || szData[ 0 ] == ';' || szData[ 0 ] == ' ' || ( szData[ 0 ] == '/' && szData[ 1 ] == '/' ) )
			continue;
		
		parse( szData, szOrigin[ 0 ], 15, szOrigin[ 1 ], 15, szOrigin[ 2 ], 15 );
		
		new Float:vOrigin[ 3 ];
		
		vOrigin[ 0 ] = str_to_float( szOrigin[ 0 ] );
		vOrigin[ 1 ] = str_to_float( szOrigin[ 1 ] );
		vOrigin[ 2 ] = str_to_float( szOrigin[ 2 ] );
		
		CreateBall( 0, vOrigin );
		
		g_vOrigin[currBall-1] = vOrigin;
	}
	
	fclose( iFile );
}

public CmdButtonsMenu( id ) {
	if( get_user_flags( id ) & ADMIN_RCON )
		menu_display( id, g_iButtonsMenu, 0 );
	
	return PLUGIN_HANDLED;
}

public HandleButtonsMenu( id, iMenu, iItem ) {
	if( iItem == MENU_EXIT )
		return PLUGIN_HANDLED;
	
	new szKey[ 2 ], _Access, _Callback;
	menu_item_getinfo( iMenu, iItem, _Access, szKey, 1, "", 0, _Callback );
	
	new iKey = str_to_num( szKey );
	/*new players[32],num;
	get_players(players,num);
	for(new i=0;i<num;i++){
	*/
	console_print(id,"Numero de bolas a carregar at spawn: %d^n",numOfStoredBalls)
	
	//}*/
	switch( iKey ) {
		case 1:    {
			// if( pev_valid( g_iBall[currBall-1]  ) )
			//    return PLUGIN_CONTINUE;
			
			CreateBall( id );
		}
		case 2: {
			for(new i=0;i<currBall;i++){
				if( is_valid_ent( g_iBall[i]  ) ) {
					entity_set_vector( g_iBall[i] , EV_VEC_velocity, Float:{ 0.0, 0.0, 0.0 } ); // To be sure ?
					entity_set_origin( g_iBall[i] , g_vOrigin[i] );
					
					entity_set_int( g_iBall[i] , EV_INT_movetype, MOVETYPE_BOUNCE );
					entity_set_size( g_iBall[i] , Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 12.0 } );
					entity_set_int( g_iBall[i] , EV_INT_iuser1, 0 );
					client_print( id, print_chat, "*** Loading Ball ***" );
				}
			}
		}
		case 3: {
			new iEntity;
			
			while( ( iEntity = find_ent_by_class( iEntity, g_szBallName ) ) > 0 ){
				remove_entity( iEntity );
				client_print( id, print_chat, "*** Ball Deleted ! ***" );
			}
			currBall=0
		}
		case 4: {
			new  Float:vOrigin[ 3 ];
			new iFile = fopen( g_szFile, "w+" );
			new szString[ 256 ];
			
			numOfStoredBalls=currBall
			formatex( szString, 255, "%d", currBall);
			write_file(g_szFile,szString,-1)
			for(new i=0;i<currBall;i++){
				
				if( g_iBall[i] > 0 ){
					entity_get_vector( g_iBall[i] , EV_VEC_origin, vOrigin );
				}
				else{
					client_print( id, print_chat, "Ball is zero!!!!" );
					return PLUGIN_HANDLED;
				}
				
				if( !iFile ){
					client_print( id, print_chat, "No such file: %s",g_szFile );
					return PLUGIN_HANDLED;
				}
				
				new szString2[ 256 ];
				formatex( szString2, 255, "%f %f %f",  vOrigin[ 0 ], vOrigin[ 1 ], vOrigin[ 2 ] );
					
				write_file( g_szFile, szString2, - 1 );
				
				
				client_print( id, print_chat, "*** Ball Saved ! ***" );
			}
			
			fclose( iFile );
			
		}
		default: return PLUGIN_HANDLED;
	}
	menu_display( id, g_iButtonsMenu, 0 );
	
	return PLUGIN_HANDLED;
}

public EventRoundStart(id) {
	if( !g_bNeedBall )
		return;
	
	for(new i=0;i<currBall;i++){
		if( !is_valid_ent( g_iBall[i]   ) )
			CreateBall( 0, g_vOrigin[i] );
		else {
			entity_set_vector( g_iBall[i]  , EV_VEC_velocity, Float:{ 0.0, 0.0, 0.0 } ); // To be sure ?
			entity_set_origin( g_iBall[i]  , g_vOrigin[i] );
			
			entity_set_int( g_iBall[i]  , EV_INT_solid, SOLID_BBOX );
			entity_set_int( g_iBall[i]  , EV_INT_movetype, MOVETYPE_BOUNCE );
			entity_set_size( g_iBall[i]  , Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 12.0 } );
			entity_set_int( g_iBall[i]  , EV_INT_iuser1, 0 );
		}
	}
}

public FwdHamObjectCaps( id ) {
	for(new i=0;i<currBall;i++){
		if( pev_valid( g_iBall[i]  ) && is_user_alive( id ) ) {
			static iOwner; iOwner = pev( g_iBall[i] , pev_iuser1 );
			
			if( iOwner == id ){
				KickBall( id ,i);
				break;
			}
		}
	}
}

// BALL BRAIN :)
////////////////////////////////////////////////////////////
public FwdThinkBall( iEntity ) {
	
	for(new i=0;i<currBall;i++){
		if( !is_valid_ent( g_iBall[i]   ) )
			return PLUGIN_HANDLED;
		
		entity_set_float( iEntity, EV_FL_nextthink, halflife_time( ) + 0.05 );
		
		static Float:vOrigin[ 3 ], Float:vBallVelocity[ 3 ];
		entity_get_vector( iEntity, EV_VEC_origin, vOrigin );
		entity_get_vector( iEntity, EV_VEC_velocity, vBallVelocity );
		
		static iOwner; iOwner = pev( iEntity, pev_iuser1 );
		static iSolid; iSolid = pev( iEntity, pev_solid );
		
		
		if( iOwner > 0 ) {
			static Float:vOwnerOrigin[ 3 ];
			entity_get_vector( iOwner, EV_VEC_origin, vOwnerOrigin );
			
			static const Float:vVelocity[ 3 ] = { 1.0, 1.0, 0.0 };
			
			if( !is_user_alive( iOwner ) ) {
				entity_set_int( iEntity, EV_INT_iuser1, 0 );
				
				vOwnerOrigin[ 2 ] += 5.0;
				
				entity_set_origin( iEntity, vOwnerOrigin );
				entity_set_vector( iEntity, EV_VEC_velocity, vVelocity );
				
				return PLUGIN_CONTINUE;
			}
			
			if( iSolid != SOLID_NOT )
				set_pev( iEntity, pev_solid, SOLID_NOT );
			
			static Float:vAngles[ 3 ], Float:vReturn[ 3 ];
			entity_get_vector( iOwner, EV_VEC_v_angle, vAngles );
			
			vReturn[ 0 ] = ( floatcos( vAngles[ 1 ], degrees ) * 55.0 ) + vOwnerOrigin[ 0 ];
			vReturn[ 1 ] = ( floatsin( vAngles[ 1 ], degrees ) * 55.0 ) + vOwnerOrigin[ 1 ];
			vReturn[ 2 ] = vOwnerOrigin[ 2 ];
			vReturn[ 2 ] -= ( entity_get_int( iOwner, EV_INT_flags ) & FL_DUCKING ) ? 10 : 30;
			
			entity_set_vector( iEntity, EV_VEC_velocity, vVelocity );
			entity_set_origin( iEntity, vReturn );
			} else {
			if( iSolid != SOLID_BBOX )
				set_pev( iEntity, pev_solid, SOLID_BBOX );
			
			static Float:flLastVerticalOrigin;
			
			if( vBallVelocity[ 2 ] == 0.0 ) {
				static iCounts;
				
				if( flLastVerticalOrigin > vOrigin[ 2 ] ) {
					iCounts++;
					
					if( iCounts > 10 ) {
						iCounts = 0;
						
						UpdateBall( 0);
					}
					} else {
					iCounts = 0;
					
					if( PointContents( vOrigin ) != CONTENTS_EMPTY )
						UpdateBall( 0 );
				}
				
				flLastVerticalOrigin = vOrigin[ 2 ];
			}
		}
	}
	return PLUGIN_CONTINUE;
}

KickBall( id ,i ) {
	//set_user_maxspeed(id, 230.0)
	static Float:vOrigin[ 3 ];
	entity_get_vector( g_iBall[i] , EV_VEC_origin, vOrigin );
	
	vOrigin[2] += 35;
	
	if( PointContents( vOrigin ) != CONTENTS_EMPTY )
		return PLUGIN_HANDLED;
	
	new Float:vVelocity[ 3 ];
	velocity_by_aim( id, gBallSpeed, vVelocity );
	
	beam(10)
	emit_sound(g_iBall[i], CHAN_STATIC, kicked, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	set_pev( g_iBall[i]  , pev_solid, SOLID_BBOX );
	entity_set_size( g_iBall[i] , Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 12.0 } );
	entity_set_int( g_iBall[i]  , EV_INT_iuser1, 0 );
	entity_set_origin(g_iBall[i] ,vOrigin)
	entity_set_vector( g_iBall[i]  , EV_VEC_velocity, vVelocity );
	
	return PLUGIN_CONTINUE;
}

// BALL TOUCHES
////////////////////////////////////////////////////////////
public FwdTouchPlayer( Ball, id ) {
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
	
	static iOwner; iOwner = pev( Ball, pev_iuser1 );
	
	if( iOwner == 0 ) {
		entity_set_int( Ball, EV_INT_iuser1, id );
		beam(10)
		emit_sound(Ball, CHAN_ITEM, gotball, 1.0, ATTN_NORM, 0, PITCH_NORM);
		set_hudmessage(255, 20, 20, -1.0, 0.4, 1, 1.0, 1.5, 0.1, 0.1)
		show_hudmessage(id,"*** YOU HAVE THE BALL! ***")
		// set_user_maxspeed(id, 230.0)
	}
	return PLUGIN_CONTINUE;
}

public FwdTouchWorld( Ball, World ) {
	static Float:vVelocity[ 3 ];
	entity_get_vector( Ball, EV_VEC_velocity, vVelocity );
	
	if( floatround( vector_length( vVelocity ) ) > 10 ) {
		vVelocity[ 0 ] *= 0.85;
		vVelocity[ 1 ] *= 0.85;
		vVelocity[ 2 ] *= 0.85;
		
		entity_set_vector( Ball, EV_VEC_velocity, vVelocity );
		
		emit_sound( Ball, CHAN_ITEM, BALL_BOUNCE_GROUND, 1.0, ATTN_NORM, 0, PITCH_NORM );
	}
	
	return PLUGIN_CONTINUE;
}


// ENTITIES CREATING
////////////////////////////////////////////////////////////
CreateBall( id, Float:vOrigin[ 3 ] = { 0.0, 0.0, 0.0 } ) {
	if(!id && vOrigin[ 0 ] == 0.0 && vOrigin[ 1 ] == 0.0 && vOrigin[ 2 ] == 0.0&&currBall==numBalls)
		return 0;
	
	g_bNeedBall = true;
	
	g_iBall[currBall] = create_entity( "info_target" );
	
	if( is_valid_ent( g_iBall[currBall] ) ) {
		entity_set_string( g_iBall[currBall] , EV_SZ_classname, g_szBallName );
		entity_set_int( g_iBall[currBall] , EV_INT_solid, SOLID_BBOX );
		entity_set_int( g_iBall[currBall], EV_INT_movetype, MOVETYPE_BOUNCE );
		entity_set_model( g_iBall[currBall] , g_szBallModel );
		entity_set_size( g_iBall[currBall] , Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 12.0 } );
		
		entity_set_float( g_iBall[currBall], EV_FL_framerate, 0.0 );
		entity_set_int( g_iBall[currBall] , EV_INT_sequence, 0 );
		
		entity_set_float(g_iBall[currBall] , EV_FL_nextthink, get_gametime( ) + 0.05 );
		
		glow(g_iBall[currBall],ballcolor[0],ballcolor[1],ballcolor[2],10)
		
		client_print( id, print_chat, "*** Ball Spawned! ***" );
		
		if( id > 0 ) {
			new iOrigin[ 3 ];
			get_user_origin( id, iOrigin, 3 );
			IVecFVec( iOrigin, vOrigin );
			
			vOrigin[ 2 ] += 5.0;
			
			entity_set_origin( g_iBall[currBall] , vOrigin );
		} 
		else{
			entity_set_origin( g_iBall[currBall] , vOrigin );
		}
		
		g_vOrigin[currBall] = vOrigin;
		return g_iBall[currBall++] ;
	}
	
	return -1;
}

beam(life) {
	for(new i=0;i<currBall;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(22); // TE_BEAMFOLLOW
		write_short(g_iBall[i]); // ball
		write_short(beamspr); // laserbeam
		write_byte(life); // life
		write_byte(5); // width
		write_byte(ballbeam[0]); // R
		write_byte(ballbeam[1]); // G
		write_byte(ballbeam[2]); // B
		write_byte(175); // brightness
		message_end();
	}
}
glow(id, r, g, b, on) {
	if(on == 1) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
	else if(!on) {
		set_rendering(id, kRenderFxNone, r, g, b,  kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
	else if(on == 10) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
