#include "../my_include/superheromod.inc"
#include "soccer_ball_inc/sh_roberto_get_set.inc"
#include "soccer_ball_inc/sh_soccer_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include <xs>

#define PLUGIN "Superhero roberto mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


new cheers[] = "shmod/roberto_carlos/cheers/big_goal.wav"
new bool:ball_pickable[MAX_ENTITIES]
new bool:kicked_ball[SH_MAXSLOTS+1]
new bool:tagged_by_baller[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
public plugin_init(){
	
	arrayset(ball_pickable,false,MAX_ENTITIES)
	arrayset(kicked_ball,false,SH_MAXSLOTS+1)
	for(new i=0;i<=SH_MAXSLOTS;i++){
		
		
		arrayset(tagged_by_baller[i],false,SH_MAXSLOTS+1)
		
		
	}
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	register_forward(FM_Think, "ball_think")
	
	new const szEntity[ ][ ] = {
		"worldspawn", "func_wall", "func_door",  "func_door_rotating",
		"func_wall_toggle", "func_breakable", "func_pushable", "func_train",
		"func_illusionary", "func_button", "func_rot_button", "func_rotating"
	}
	
	for( new i; i < sizeof szEntity; i++ )
		register_touch( BALL_CLASSNAME, szEntity[ i ], "FwdTouchWorld" );
}

public plugin_natives(){
	
	
	register_native( "clear_balls","_clear_balls",0)
	register_native( "kick_the_ball","kick_ball",0)
	
	
}

client_isnt_hitter(gatling_user){
	
	
	return (!roberto_get_has_roberto(gatling_user)||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)
	
}

public _clear_balls(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, BALL_CLASSNAME)
	while(grenada) {
		remove_ball(grenada+BALL_REM_TASKID)
		grenada = find_ent_by_class(grenada, BALL_CLASSNAME)
	}
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

public beam(life,ball) {
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(22); // TE_BEAMFOLLOW
	write_short(ball); // ball
	write_short(beamspr); // laserbeam
	write_byte(life); // life
	write_byte(5); // width
	write_byte(ballbeam[0]); // R
	write_byte(ballbeam[1]); // G
	write_byte(ballbeam[2]); // B
	write_byte(175); // brightness
	message_end();
}

//----------------------------------------------------------------------------------------------
public ball_in_the_face(ball,id,vic)
{
	if ( !is_user_alive(id)||!is_user_alive(vic) ) return
	
	new parm[5],Float:b_vel[3],Float:b_origin[3]
	
	new CsTeams:idTeam = cs_get_user_team(id)
	
	Entvars_Get_Vector(ball, EV_VEC_velocity, b_vel)
	
	new Float:velocity=vector_length(b_vel)
	
	b_vel[0]/=velocity
	b_vel[1]/=velocity
	b_vel[2]/=velocity
	
	
	Entvars_Get_Vector(ball, EV_VEC_origin, b_origin)
	
	
	
	if ( vic != id  && (idTeam != cs_get_user_team(vic)) ) {
		
		
		parm[0] = floatround(b_vel[0]*velocity*BALL_MASS)
		parm[1] = floatround(b_vel[1]*velocity*BALL_MASS)
		parm[2] = floatround(b_vel[2]*velocity*BALL_MASS)
		parm[3] = vic
		parm[4] = id
		
		
		// First lift them
		set_pev(vic, pev_velocity, {0.0, 0.0, 200.0})
		
		// Then push them back in x seconds after lift and do some damage
		set_task(0.1, "move_enemy", 0, parm, 5)
	}
}
public vexd_pfntouch(pToucher, pTouched)
{
	
	if (pToucher <= 0) return
	if (!is_valid_ent(pToucher)) return
	
	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if(equal(szClassName, BALL_CLASSNAME))
	{
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		//new Float:origin[3],dist
		
		if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
			if(client_hittable(pTouched))
			{		
				if(roberto_get_has_roberto(pTouched)&&(pTouched==oid)&&ball_pickable[pToucher] && BALL_RETRIEVE){
					
					roberto_set_num_balls(oid,roberto_get_num_balls(oid)+1)
					sh_chat_message(oid,roberto_get_hero_id(),"Youve picked up your ball back! You now have %d",roberto_get_num_balls(oid))
					ball_pickable[pToucher]=false
					kicked_ball[oid]=false
					remove_entity(pToucher);
					
				}
				//else if(pTouched!=oid){
				else if((pTouched!=oid)){
					if(!tagged_by_baller[oid][pTouched]){
						ball_pickable[pToucher]=true
						tagged_by_baller[oid][pTouched]=true
						ball_in_the_face(pToucher,oid,pTouched)
						emit_sound(0, CHAN_AUTO, cheers, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						tagged_by_baller[oid][pTouched]=false
						set_task(BALL_REM_TIME,"remove_ball",pToucher+BALL_REM_TASKID)
					}
				}
			}
		}
		else if(pev(pTouched,pev_solid)==SOLID_BSP){
			ball_pickable[pToucher]=true
			set_task(BALL_REM_TIME,"remove_ball",pToucher+BALL_REM_TASKID)
		}
		
		
	}
}

public remove_ball(id_ball){
	id_ball-=BALL_REM_TASKID
	
	if(!is_valid_ent(id_ball)) return
	new oid=pev(id_ball,pev_iuser1)
	if(!kicked_ball[oid]) return
	ball_pickable[id_ball]=false
	kicked_ball[oid]=false
	remove_entity(id_ball)
	
	
}
public kick_ball(iPlugin,iParams)
{
	
	new id= get_param(1)
	
	if(!roberto_get_has_roberto(id)||!is_user_alive(id)||!is_user_connected(id)) return PLUGIN_HANDLED
	
	if(!roberto_get_num_balls(id)){
		
		client_print(id,print_center,"You ran out of balls")
		return PLUGIN_HANDLED
		
	}
	if(kicked_ball[id]){
		
		client_print(id,print_center,"Wait for the next ball!")
		return PLUGIN_HANDLED
		
	}
	entity_set_int(id, EV_INT_weaponanim, 3)
	
	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent
	
	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	Origin[2]+=50.0
	Ent = create_entity("info_target")
	
	if (!Ent){
		sh_chat_message(id,roberto_get_hero_id(),"Ball failure!");
		return PLUGIN_HANDLED
	}
	
	arrayset(tagged_by_baller[id],false,SH_MAXSLOTS+1)
	entity_set_string(  Ent, EV_SZ_classname, BALL_CLASSNAME );
	entity_set_int(  Ent , EV_INT_solid, SOLID_TRIGGER);
	entity_set_int( Ent, EV_INT_movetype, MOVETYPE_BOUNCE );
	entity_set_model(  Ent , g_szBallModel );
	entity_set_size(  Ent, Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 12.0 } );
	
	entity_set_float(  Ent, EV_FL_framerate, 0.0 );
	entity_set_int(  Ent , EV_INT_sequence, 0 );
	
	
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)
	
	entity_set_edict(Ent, EV_ENT_owner, id)
	set_pev(Ent,pev_iuser1, id)
	
	VelocityByAim(id, floatround(BALL_SPEED) , Velocity)
	
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	
	set_pev(Ent, pev_vuser1, Velocity)
	
	client_print(id,print_center,"You have %d balls left!",roberto_get_num_balls(id))
	
	roberto_dec_num_balls(id)
	
	
	kicked_ball[id]=true
	emit_sound(id, CHAN_WEAPON, kicked, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	glow(Ent,ballcolor[0],ballcolor[1],ballcolor[2],10)
	shoteffects(Origin,id)
	entity_set_float( Ent, EV_FL_nextthink, get_gametime( ) + 0.05 );
	beam(10,Ent)
	
	return PLUGIN_CONTINUE
}

//----------------------------------------------------------------------------------------------
public ball_think(ent)
{	
	
	if(!pev_valid(ent)){
		
		return
		
	}
	new szClassName[32]
	entity_get_string(ent, EV_SZ_classname, szClassName, 31)
	if(!equal(szClassName, BALL_CLASSNAME))
	{
		return;
	}
	new id=pev(ent,pev_iuser1)
	if ( client_isnt_hitter(id )) {
		set_task(0.1,"remove_ball",ent+BALL_REM_TASKID)
		return
	}
	new Float:newVelocity[3],Float:velocityVec[ 3 ],Float:fl_origin[3],iAimVec[3],iPos[3],Float:Pos[3],Float:AimVec[3]
	entity_get_vector( ent, EV_VEC_velocity, velocityVec );
	entity_get_vector( ent, EV_VEC_velocity, newVelocity );
	entity_get_vector( ent, EV_VEC_origin, fl_origin );
	get_user_origin(id,iAimVec,3)
	get_user_origin(id, iPos)
	
	
	IVecFVec(iPos,Pos)
	
	IVecFVec(iAimVec,AimVec)
	
	new Float:AimDirVector[3];
	
	AimDirVector[0]=AimVec[0]-Pos[0]
	AimDirVector[1]=AimVec[1]-Pos[1]
	AimDirVector[2]=AimVec[2]-Pos[2]
	
	
	new  Float:length
	length = vector_length(AimDirVector)
	
	AimDirVector[0]*=(CURVE_APEX_DIST/(length))
	AimDirVector[1]*=(CURVE_APEX_DIST/(length))
	AimDirVector[2]*=(CURVE_APEX_DIST/(length))
	
	new Float:end_point[3]
	
	end_point[0]=Pos[0]+AimDirVector[0]
	end_point[1]=Pos[1]+AimDirVector[1]
	end_point[2]=Pos[2]+AimDirVector[2]
	
	
	
	//velocityVec[0] = 0
	//velocityVec[0]=AimVec[0]-origin[0]
	//velocityVec[0] = velocityVec[0]+(AimVec[0])
	velocityVec[0] = velocityVec[0]+((AimDirVector[0])/BALL_MASS)
	velocityVec[1] = velocityVec[1]+((AimDirVector[1])/BALL_MASS)
	
	length = vector_length(velocityVec)
	// Stupid Check but lets make sure you don't devide by 0
	if ( !length ) length = 1.0
	
	newVelocity[0]= velocityVec[0]*BALL_SPEED/length
	newVelocity[1] = velocityVec[1]*BALL_SPEED/length
	newVelocity[2]= velocityVec[2]
	
	
	entity_set_vector(ent, EV_VEC_velocity ,newVelocity)
	set_pev(ent, pev_vuser1, newVelocity)
	entity_set_float( ent, EV_FL_nextthink, get_gametime( ) + 0.05 );
	
}
public plugin_precache()
{
	precache_model( g_szBallModel );
	precache_sound( BALL_BOUNCE_GROUND );
	
	beamspr = precache_model( "sprites/laserbeam.spr" );
	precache_sound(kicked)
	precache_sound(gotball)
	precache_sound(cheers)
	precache_explosion_fx()
	
	
}
stock shoteffects(Float:Pos[3],ent){
	if(client_isnt_hitter(ent)) return
	new Float:vOrigin[3]
	pev(ent, pev_origin, vOrigin)
	
	new Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vNormal[3]
	
	velocity_by_aim(ent, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + vOrigin[0]
	vTraceEnd[1] = vTraceDirection[1] + vOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + vOrigin[2]
	
	new tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, 0, ent, tr)
	get_tr2(tr, TR_vecPlaneNormal, vNormal)
	new iPos[3],iTD[3]
	FVecIVec(Pos,iPos)
	FVecIVec(vTraceDirection,iTD)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMTORUS)
	write_coord(iPos[0])
	write_coord(iPos[1])
	write_coord(iPos[2])
	write_coord(iTD[0])
	write_coord(iTD[1])
	write_coord(iTD[2])
	write_short(sprite1)
	write_byte(1)
	write_byte(5)
	write_byte(5)
	write_byte(14)
	write_byte(1)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(1)
	message_end()
	
}

stock glow(id, r, g, b, on) {
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
