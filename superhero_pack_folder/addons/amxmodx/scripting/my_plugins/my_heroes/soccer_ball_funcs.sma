#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "soccer_ball_inc/sh_roberto_get_set.inc"
#include "soccer_ball_inc/sh_soccer_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"

#define PLUGIN "Superhero roberto mk2 pt2"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new cheers[] = "shmod/roberto_carlos/cheers/big_goal.wav"


public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_think(BALL_CLASSNAME, "ball_think")
	
	register_entity_as_wall_touchable(BALL_CLASSNAME,"FwdTouchWorld")
	register_custom_touchable(BALL_CLASSNAME,"ball_touch_player",player_vector,1)

}

public plugin_natives(){
	

	register_native( "kick_the_ball","kick_ball",0)
	
	
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
	entity_set_int(Ball,EV_INT_iuser2,true)
	return PLUGIN_CONTINUE;
}
//

public ball_touch_player(Ball, Player ) {
	new oid = entity_get_edict(Ball, EV_ENT_owner)
	if(client_hittable(Player))
	{		
		new Float:origin[3]
		entity_get_vector(Ball,EV_VEC_origin,origin)
		//get pickability status
		new ball_pickable=entity_get_int(Ball,EV_INT_iuser2)
		if(sh_user_has_hero(Player,roberto_get_hero_id())&&(Player==oid)&&ball_pickable&& BALL_RETRIEVE){
			
			roberto_set_num_balls(oid,roberto_get_num_balls(oid)+1)
			sh_chat_message(oid,roberto_get_hero_id(),"Youve picked up your ball back! You now have %d",roberto_get_num_balls(oid))
			
			//set pickability status
			entity_set_int(Ball,EV_INT_iuser2,false)
			remove_entity(Ball);
			return
			
		}
		else if((Player!=oid)){

			//get "touched someone" boolean
			new touched_someone=entity_get_int(Ball,EV_INT_iuser3)
			if(!touched_someone){
				//set pickability status
				entity_set_int(Ball,EV_INT_iuser2,true)
				entity_set_int(Ball,EV_INT_iuser3,true)
				set_velocity_from_origin(Player,origin,BALL_KNOCKBACK)
				emit_sound(0, CHAN_AUTO, cheers, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				sh_chat_message(oid,roberto_get_hero_id(),"*WWWWWWWWHHHHHHOOOOOAAAAAAAHHHHHHH!!!!*");
			}
		}
	}
}
public kick_ball(iPlugin,iParams)
{
	
	new id= get_param(1)
	
	if(!sh_user_has_hero(id,roberto_get_hero_id())||!is_user_alive(id)||!is_user_connected(id)) return PLUGIN_HANDLED
	
	if(!roberto_get_num_balls(id)){
		
		client_print(id,print_center,"You ran out of balls")
		return PLUGIN_HANDLED
		
	}
	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent
	
	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	Origin[2]+=50.0
	Ent = create_entity("info_target")
	
	if (!Ent){
		sh_chat_message(id,roberto_get_hero_id(),"Ball failure!");
		return PLUGIN_HANDLED
	}
	
	entity_set_string(  Ent, EV_SZ_classname, BALL_CLASSNAME );
	entity_set_int(  Ent , EV_INT_solid, SOLID_BBOX);
	entity_set_int( Ent, EV_INT_movetype, MOVETYPE_BOUNCE );
	entity_set_model(  Ent , g_szBallModel );
	entity_set_size(  Ent, Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 12.0 } );
	
	entity_set_float(  Ent, EV_FL_framerate, 0.0 );
	entity_set_int(  Ent , EV_INT_sequence, 0 );
	
	
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)
	
	entity_set_edict(Ent, EV_ENT_owner, id)
	set_pev(Ent,pev_iuser1, id)
	
	velocity_by_aim(id, floatround(BALL_SPEED) , Velocity)
	
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	
	set_pev(Ent, pev_vuser1, Velocity)
	
	if(!is_user_bot(id)){
		client_print(id,print_center,"You have %d balls left!",roberto_get_num_balls(id))
	}
	
	roberto_dec_num_balls(id)
	//set removal timer
	entity_set_float( Ent, EV_FL_fuser1, BALL_REM_TIME);
	//set pickability status
	entity_set_int( Ent, EV_INT_iuser2, false);
	//set "tagged someone" boolean
	entity_set_int( Ent, EV_INT_iuser3, false);
						
	emit_sound(id, CHAN_WEAPON, kicked, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	glow(Ent,LineColors[GREEN][0],LineColors[GREEN][1],LineColors[GREEN][2],255,10)
	create_fired_shot_disk(Origin,id,false)
	entity_set_float( Ent, EV_FL_nextthink, get_gametime( ) + BALL_THINK_TIME );
	trail(Ent,GREEN,10,5)
	
	
	return PLUGIN_CONTINUE
}

//----------------------------------------------------------------------------------------------
public ball_think(ent)
{	
	
	if(pev_valid(ent)!=2){
		
		return FMRES_IGNORED
		
	}

	new id=pev(ent,pev_iuser1)
	if ( !client_hittable(id,sh_user_has_hero(id,roberto_get_hero_id()))) {
		remove_entity(ent)
		return FMRES_IGNORED
	}
	//get removal timer
	new Float:removal_timer=entity_get_float( ent, EV_FL_fuser1);
	if(removal_timer>=0.0){
		entity_set_float( ent, EV_FL_fuser1, removal_timer-BALL_THINK_TIME);

	}
	else{

		remove_entity(ent)
		return FMRES_IGNORED

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
	entity_set_float( ent, EV_FL_nextthink, get_gametime( ) + BALL_THINK_TIME );
	return FMRES_IGNORED
}
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, g_szBallModel );
	engfunc(EngFunc_PrecacheSound, BALL_BOUNCE_GROUND );
	
	engfunc(EngFunc_PrecacheSound,kicked)
	engfunc(EngFunc_PrecacheSound,gotball)
	engfunc(EngFunc_PrecacheSound,cheers)
	
	
	
}