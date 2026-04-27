#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "freeze_fx/freeze_fx.inc"
#include "girlb_includes/girlb_get_set.inc"
#include "girlb_includes/girlb_ice_glob_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"

#define PLUGIN "Superhero girlb ice glob funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_think(GLOB_CLASSNAME, "glob_think")
	
	register_entity_as_wall_touchable(GLOB_CLASSNAME,"FwdTouch")
	register_custom_touchable(GLOB_CLASSNAME,"FwdTouch",player_vector,1)

}

public plugin_natives(){
	

	register_native( "launch_ice_glob","_launch_ice_glob",0)
	
	
}

public FwdTouch( Glob, World ) {
	if(!is_valid_ent(Glob)) return FMRES_IGNORED

	static Float:glob_origin[3]

	entity_get_vector(Glob,EV_VEC_origin,glob_origin)
	
	new vExplodeAt[3]
	vExplodeAt[0] = floatround(glob_origin[0])
	vExplodeAt[1] = floatround(glob_origin[1])
	vExplodeAt[2] = floatround(glob_origin[2])

	make_shockwave(vExplodeAt,GLOB_RADIUS,
				LineColors[FROZEN_BLUE],1,5,8,4)


	emit_sound(Glob, CHAN_WEAPON,FROZEN_SFX,
					VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	static entlist[33];
	new numfound = find_sphere_class(Glob,"player",GLOB_RADIUS,entlist,charsmax(entlist));

	for( new i= 0;(i< numfound);i++){

		new pid = entlist[i];
		if( !client_hittable(pid) ) continue
		
		sh_freeze_user(pid,7.0,130.0)
	}
	remove_entity(Glob)
	return FMRES_IGNORED
}
public _launch_ice_glob(iPlugin,iParams)
{
	
	new id= get_param(1)
	
	if(!sh_user_has_hero(id,girlb_get_hero_id())||!is_user_alive(id)) return
	
	if(girlb_get_num_globs(id)<=0){
		
		client_print(id,print_center,"You ran out of ice globs")
		return
		
	}
	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent
	new Float: advance[3]

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	velocity_by_aim(id,30,advance)
	
	add_3d_vectors(Origin,advance,Origin)
	
	Ent = create_entity("info_target")
	
	if (!Ent){
		sh_chat_message(id,girlb_get_hero_id(),"Ball failure!");
		return
	}
	
	entity_set_string(  Ent, EV_SZ_classname, GLOB_CLASSNAME );
	entity_set_int(  Ent , EV_INT_solid, SOLID_BBOX);
	entity_set_int( Ent, EV_INT_movetype, MOVETYPE_BOUNCE );
	entity_set_int( Ent, EV_INT_effects, 64) //rocket shine fx
	entity_set_int( Ent,EV_INT_rendermode,kRenderTransColor)
	entity_set_int( Ent,EV_INT_renderfx,kRenderFxGlowShell)
	entity_set_float(  Ent ,EV_FL_renderamt,30.0 ); //hard to see
	entity_set_model(  Ent , SPHERE_MODEL );
	entity_set_size(  Ent, Float:{ -2.0, -2.0, 0.0 }, Float:{ 2.0, 2.0, 2.0 } );
	
	entity_set_float(  Ent, EV_FL_framerate, 0.0 );
	entity_set_int(  Ent , EV_INT_sequence, 0 );
	
	
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)
	
	entity_set_edict(Ent, EV_ENT_owner, id)
	
	velocity_by_aim(id, floatround(GLOB_SPEED) , Velocity)
	
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	
	set_pev(Ent, pev_vuser1, Velocity)
	
	girlb_dec_num_globs(id)

	if(!is_user_bot(id)){
		client_print(id,print_center,"You have %d globs left!",girlb_get_num_globs(id))
	}
	
	/*
	//set removal timer
	entity_set_float( Ent, EV_FL_fuser1, BALL_REM_TIME);
	//set pickability status
	entity_set_int( Ent, EV_INT_iuser2, false);
	//set "tagged someone" boolean
	entity_set_int( Ent, EV_INT_iuser3, false);*/
	// faint glow
	trail(Ent,FROZEN_BLUE,10,5)
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, SPHERE_MODEL );
	engfunc(EngFunc_PrecacheSound, FROZEN_SFX );
}