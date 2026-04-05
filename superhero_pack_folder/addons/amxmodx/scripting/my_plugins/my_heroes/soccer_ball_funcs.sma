#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "soccer_ball_inc/sh_roberto_get_set.inc"
#include "soccer_ball_inc/sh_soccer_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include <xs>

#define PLUGIN "Superhero roberto mk2 pt2"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new cheers[] = "shmod/roberto_carlos/cheers/big_goal.wav"
new bool:ball_pickable[MAX_ENTITIES]
new bool:kicked_ball[SH_MAXSLOTS+1]
new bool:tagged_by_baller[SH_MAXSLOTS+1][SH_MAXSLOTS+1]


stock BALL_REM_TASKID

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

	BALL_REM_TASKID=allocate_typed_task_id(entity_task)
	
	for( new i; i < sizeof szEntity; i++ )
		register_touch( BALL_CLASSNAME, szEntity[ i ], "FwdTouchWorld" );
}

public plugin_natives(){
	
	
	register_native( "clear_balls","_clear_balls",0)
	register_native( "kick_the_ball","kick_ball",0)
	
	
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
//

public vexd_pfntouch(pToucher, pTouched){
	
	if (pev_valid(pToucher)!=2){
		return
	}
	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if(equal(szClassName, BALL_CLASSNAME))
	{
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		
		if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
			if(client_hittable(pTouched))
			{		
				new Float:origin[3]
				entity_get_vector(pToucher,EV_VEC_origin,origin)
				if(sh_user_has_hero(pTouched,roberto_get_hero_id())&&(pTouched==oid)&&ball_pickable[pToucher] && BALL_RETRIEVE){
					
					roberto_set_num_balls(oid,roberto_get_num_balls(oid)+1)
					sh_chat_message(oid,roberto_get_hero_id(),"Youve picked up your ball back! You now have %d",roberto_get_num_balls(oid))
					ball_pickable[pToucher]=false
					kicked_ball[oid]=false
					remove_entity(pToucher);
					return
					
				}
				else if((pTouched!=oid)){
					if(!tagged_by_baller[oid][pTouched]){
						ball_pickable[pToucher]=true
						tagged_by_baller[oid][pTouched]=true
						set_velocity_from_origin(pTouched,origin,BALL_KNOCKBACK)
						emit_sound(0, CHAN_AUTO, cheers, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						sh_chat_message(oid,roberto_get_hero_id(),"*WWWWWWWWHHHHHHOOOOOAAAAAAAHHHHHHH!!!!*");
						set_task(BALL_REM_TIME,"remove_ball",pToucher+BALL_REM_TASKID)
						return
					}
				}
			}
		}
		else if(pev(pTouched,pev_solid)==SOLID_BSP){
			ball_pickable[pToucher]=true
			set_task(BALL_REM_TIME,"remove_ball",pToucher+BALL_REM_TASKID)
			return
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
	
	if(!sh_user_has_hero(id,roberto_get_hero_id())||!is_user_alive(id)||!is_user_connected(id)) return PLUGIN_HANDLED
	
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
	
	VelocityByAim(id, floatround(BALL_SPEED) , Velocity)
	
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	
	set_pev(Ent, pev_vuser1, Velocity)
	
	if(!is_user_bot(id)){
		client_print(id,print_center,"You have %d balls left!",roberto_get_num_balls(id))
	}
	
	roberto_dec_num_balls(id)
	
	
	kicked_ball[id]=true
	emit_sound(id, CHAN_WEAPON, kicked, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	arrayset(tagged_by_baller[id],false,sizeof tagged_by_baller[]);
	glow(Ent,ballcolor[0],ballcolor[1],ballcolor[2],255,10)
	create_fired_shot_disk(Origin,id,false)
	entity_set_float( Ent, EV_FL_nextthink, get_gametime( ) + 0.05 );
	trail(Ent,BLUE,10,5)
	
	
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
	if ( !client_hittable(id,sh_user_has_hero(id,roberto_get_hero_id()))) {
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
	
	precache_sound(kicked)
	precache_sound(gotball)
	precache_sound(cheers)
	
	
	
}