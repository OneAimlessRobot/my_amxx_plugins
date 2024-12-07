#include "../my_include/superheromod.inc"
#include "soccer_ball_inc/sh_roberto_get_set.inc"
#include "soccer_ball_inc/sh_soccer_funcs.inc"
#include <xs>

#define PLUGIN "Superhero roberto mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


new cheers[] = "shmod/roberto_carlos/cheers/big_goal.wav"
new m_trail

new bool:ball_pickable[MAX_ENTITIES]
public plugin_init(){
	
	arrayset(ball_pickable,false,MAX_ENTITIES)
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
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

//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
}
client_hittable(vic_userid){
	
	return (is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid)
	
}
client_isnt_hitter(gatling_user){
	
	
	return (!roberto_get_has_roberto(gatling_user)||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)
	
}

public _clear_balls(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, BALL_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
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
public kick_ball(iPlugin,iParams)
{
	
new id= get_param(1)

if(!roberto_get_has_roberto(id)||!is_user_alive(id)||!is_user_connected(id)) return PLUGIN_HANDLED

if(!roberto_get_num_balls(id)){

	client_print(id,print_center,"You ran out of balls")
	return PLUGIN_HANDLED

}
entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)

Origin[2]+=50.0
Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(  Ent, EV_SZ_classname, BALL_CLASSNAME );
entity_set_int(  Ent , EV_INT_solid, SOLID_TRIGGER);
entity_set_int( Ent, EV_INT_movetype, MOVETYPE_BOUNCE );
entity_set_model(  Ent , g_szBallModel );
entity_set_size(  Ent, Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 12.0 } );

entity_set_float(  Ent, EV_FL_framerate, 0.0 );
entity_set_int(  Ent , EV_INT_sequence, 0 );

entity_set_float( Ent, EV_FL_nextthink, get_gametime( ) + 0.05 );

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, vAngle)

entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(BALL_SPEED) , Velocity)
/*new Float:fl_Velocity[3], AimVec[3], velOrigin[3]

velOrigin[0] = floatround(vOrigin[0])
velOrigin[1] = floatround(vOrigin[1])
velOrigin[2] = floatround(vOrigin[2])

get_user_origin(id, AimVec, 3)

new distance = get_distance(velOrigin, AimVec)

// Stupid Check but lets make sure you don't devide by 0
if (!distance) distance = 1

new Float:invTime = BALL_SPEED / distance
fl_Velocity[0] = (AimVec[0] - vOrigin[0]) * invTime
fl_Velocity[1] = (AimVec[1] - vOrigin[1]) * invTime
fl_Velocity[2] = (AimVec[2] - vOrigin[2]) * invTime

Entvars_Set_Vector(newEnt, EV_VEC_velocity, fl_Velocity)*/

entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

glow(Ent,ballcolor[0],ballcolor[1],ballcolor[2],10)

client_print(id,print_center,"You have %d balls left!",roberto_get_num_balls(id))

roberto_dec_num_balls(id)

new parm[1]
parm[0] = Ent
emit_sound(id, CHAN_WEAPON, kicked, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

beam(10,Ent)
/*
new args[2]

		// Pass varibles used to guide entity with
args[0] = id
args[1] = Ent

set_task(0.1, "curve_ball", Ent+BALL_CURVE_TASKID, args, 2)*/

return PLUGIN_CONTINUE
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
//----------------------------------------------------------------------------------------------
public move_enemy(parm[])
{
	new victim = parm[3]
	new id = parm[4]
	
	new Float:fl_velocity[3]
	fl_velocity[0] = float(parm[0])
	fl_velocity[1] = float(parm[1])
	fl_velocity[2] = float(parm[2])
	
	set_pev(victim, pev_velocity, fl_velocity)
	
	// do some damage
	new damage = BALL_DMG
	if ( damage > 0 ) {
		
		if ( !is_user_alive(victim) ) return
		
		sh_extra_damage(victim, id, damage, "Ball")
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
			remove_entity(pToucher);
				
		}
		else if(pTouched!=oid){
			
			ball_pickable[pToucher]=true
			emit_sound(0, CHAN_AUTO, cheers, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			ball_in_the_face(pToucher,oid,pTouched)
			set_task(BALL_REM_TIME,"remove_ball",pToucher+BALL_REM_TASKID)
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
ball_pickable[id_ball]=false
remove_entity(id_ball)


}
// ported from AMXX's core get_user_origin(..., 3) (suggested by Greenberet)
stock fm_get_aim_origin(index, Float:origin[3]) {
    new Float:start[3], Float:view_ofs[3];
    pev(index, pev_origin, start);
    pev(index, pev_view_ofs, view_ofs);
    xs_vec_add(start, view_ofs, start);

    new Float:dest[3];
    pev(index, pev_v_angle, dest);
    engfunc(EngFunc_MakeVectors, dest);
    global_get(glb_v_forward, dest);
    xs_vec_mul_scalar(dest, 9999.0, dest);
    xs_vec_add(start, dest, dest);

    engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
    get_tr2(0, TR_vecEndPos, origin);

    return 1;
} 
//----------------------------------------------------------------------------------------------
public curve_ball(args[],id)
{	
	id-=BALL_CURVE_TASKID
	new Float:AimVec[3]
	new Float:fl_origin[3]
	new iPos[3]
	new iAimVec[3]
	new Float:Pos[3]
	new id = args[0]
	new ent = args[1]
	
	if ( !is_valid_ent(ent) ) return

	if ( !is_user_connected(id) ) {
		vexd_pfntouch(ent, 0)
		return
	}
	new Float:velocityVec[ 3 ];
	entity_get_vector( ent, EV_VEC_velocity, velocityVec );
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
	length = floatsqroot(AimDirVector[0]*AimDirVector[0] + AimDirVector[1]*AimDirVector[1] + AimDirVector[2]*AimDirVector[2])
	
	
	AimDirVector[0]*=(CURVE_APEX_DIST/(length))
	AimDirVector[1]*=(CURVE_APEX_DIST/(length))
	AimDirVector[2]*=(CURVE_APEX_DIST/(length))
	
	new Float:end_point[3]
	
	end_point[0]=Pos[0]+AimDirVector[0]
	end_point[1]=Pos[1]+AimDirVector[1]
	end_point[2]=Pos[2]+AimDirVector[2]
	
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte (0)     //TE_BEAMENTPOINTS 0
	write_coord_f(Pos[0])
	write_coord_f(Pos[1])
	write_coord_f(Pos[2])
	write_coord_f(end_point[0])
	write_coord_f(end_point[1])
	write_coord_f(end_point[2])
	write_short( m_trail )
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(5) // life
	write_byte(10) // width
	write_byte(0) // noise
	write_byte( 255 )     // r, g, b
	write_byte( 200 )       // r, g, b
	write_byte( 200 )
	write_byte(200) // brightness
	write_byte(150) // speed
	message_end()
	//velocityVec[0] = 0
	//velocityVec[0]=AimVec[0]-origin[0]
	//velocityVec[0] = velocityVec[0]+(AimVec[0])
	velocityVec[1] = velocityVec[1]+((AimVec[1]-fl_origin[1])/BALL_MASS)
	velocityVec[2] = velocityVec[2]-(AVG_FACTOR*(2.0))

	length = floatsqroot(velocityVec[0]*velocityVec[0] + velocityVec[1]*velocityVec[1] + velocityVec[2]*velocityVec[2])
	// Stupid Check but lets make sure you don't devide by 0
	if ( !length ) length = 1.0

	velocityVec[0] = velocityVec[0]*BALL_SPEED/length
	velocityVec[1] = velocityVec[1]*BALL_SPEED/length
	velocityVec[2] = velocityVec[2]*BALL_SPEED/length


	entity_set_vector(ent, EV_VEC_velocity, velocityVec)


	set_task(0.1, "curve_ball", ent, args, 2)
}
public plugin_precache()
{
precache_model( g_szBallModel );
precache_sound( BALL_BOUNCE_GROUND );

beamspr = precache_model( "sprites/laserbeam.spr" );
precache_sound(kicked)
precache_sound(gotball)
m_trail = precache_model("sprites/laserbeam.spr")
precache_sound(cheers)


}

public glow(id, r, g, b, on) {
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
