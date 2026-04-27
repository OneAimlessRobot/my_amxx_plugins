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

new is_flying_mask = 0
new Float:g_player_old_friction[SH_MAXSLOTS+1] = {0.0, ...}

new ICE_GLOB_GLOBAL_TASKID

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_think(GLOB_CLASSNAME, "ice_field_think")
	
	register_entity_as_wall_touchable(GLOB_CLASSNAME,"FwdTouch")
	register_custom_touchable(GLOB_CLASSNAME,"player_touch",player_vector,1)

	register_event("ResetHUD","ice_glob_new_round","b")

	set_task(0.35,"player_on_ice_glob_checks",ICE_GLOB_GLOBAL_TASKID,_,_,"b")
}

//----------------------------------------------------------------------------------------------
public ice_glob_new_round(id)
{	
	if(sh_is_active()&&client_hittable(id)){
		g_player_old_friction[id] = entity_get_float(id,EV_FL_friction);
		UnSet_BitVar(is_flying_mask,id);
	}
	
}
public player_on_ice_glob_checks(task_id){

	if(!sh_is_active()||sh_is_freezetime()) return


	for(new id=1;id< sh_maxplayers()+1;id++){
		if(!is_user_alive(id)) continue
		
		if(sh_get_stun(id)) continue

		/*if((entity_get_int( id, EV_INT_flags ) & FL_ONGROUND  )){
					
			continue
		
		}*/
		static entlist[33];
		static num_found;
		static Float:curr_player_friction
		curr_player_friction=entity_get_float(id,EV_FL_friction)
		num_found = find_sphere_class(id,GLOB_CLASSNAME,GLOB_RADIUS,entlist,charsmax(entlist))
		if((num_found>0)){
			for(new fid=0;fid < num_found;fid++){
				
				new field= entlist[fid]

				//check if field landed on ground
				new bool:has_landed = bool:entity_get_int(field,EV_INT_iuser1)
				
				if(!has_landed){

					continue
				}
				
				static Float:the_distance
				the_distance = entity_range(id,field)

				curr_player_friction -= (((1.0)-(the_distance/GLOB_RADIUS))*g_player_old_friction[id])
				


			}
			if(!Get_BitVar(is_flying_mask,id)){
				entity_set_int(id,EV_INT_movetype,MOVETYPE_FLY)
			}
			static Float:clamp_to_use;
			clamp_to_use=((get_entity_velocity(id)<1500.0)?GLOB_MIN_FRICTION:0.1)
			curr_player_friction = floatclamp(clamp_to_use,curr_player_friction,g_player_old_friction[id])
			
			entity_set_float(id,EV_FL_friction,curr_player_friction)
		
		}
		else{

			entity_set_float(id,EV_FL_friction,g_player_old_friction[id])
			if(Get_BitVar(is_flying_mask,id)){
				entity_set_int(id,EV_INT_movetype,MOVETYPE_WALK)
			}
		}
		
	}
}
public plugin_natives(){
	

	register_native( "launch_ice_glob","_launch_ice_glob",0)
	
	
}
//assumes both are valid
public touch_shared_logic(Glob, Other_Entity){

	static Float:glob_origin[3]

	entity_get_vector(Glob,EV_VEC_origin,glob_origin)
	
	new owner = entity_get_edict(Glob,EV_ENT_owner)
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
		if( pid != owner ){
			
			sh_freeze_user(pid,7.0,130.0)
		
		}
	}
}
public FwdTouch( Glob, World ) {
	if(!is_valid_ent(Glob)) return FMRES_IGNORED

	
	touch_shared_logic(Glob, World)
	
	//set field timer
	
	entity_set_float(Glob,EV_FL_fuser1, GLOB_FIELD_LIFE_TIME)

	//set it as not landed in the ground until it does
	//and we just did.
	entity_set_int(Glob,EV_INT_iuser1, 1)
	
	entity_set_float(Glob,EV_FL_nextthink, get_gametime() + GLOB_THINK_PERIOD)
	return FMRES_IGNORED
}
public player_touch( Glob, Player ) {
	if(!is_valid_ent(Glob)) return FMRES_IGNORED
	
	if(!is_user_alive(Player)) return FMRES_IGNORED

	touch_shared_logic(Glob, Player)
	
	remove_entity(Glob)
	
	return FMRES_IGNORED
}

//----------------------------------------------------------------------------------------------
public ice_field_think(ent)
{
	if ( pev_valid(ent)!=2 ){
		
	
			return FMRES_IGNORED
	
	}

	static Float:ent_pos[3]
	static ient_pos[3]
	new owner=pev(ent,pev_owner)

	if (entity_get_float(ent,EV_FL_fuser1)<0.0) {
		if(pev_valid(ent)==2){
			sh_chat_message(owner,girlb_get_hero_id(),"Ice field died!")
			
			remove_entity(ent)
		}
		return FMRES_IGNORED
	}
	else{
		entity_get_vector(ent, EV_VEC_origin, ent_pos)
		FVecIVec(ent_pos,ient_pos)
		make_shockwave(ient_pos,GLOB_RADIUS,LineColors[FROZEN_BLUE],1,5,8,4,60)

		entity_set_float(ent,EV_FL_fuser1,floatsub(entity_get_float(ent,EV_FL_fuser1),GLOB_THINK_PERIOD))
		entity_set_float(ent,EV_FL_nextthink,floatadd(get_gametime(),GLOB_THINK_PERIOD))
	
	}
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
	entity_set_int(  Ent , EV_INT_solid, SOLID_BBOX );
	entity_set_int( Ent, EV_INT_movetype, MOVETYPE_TOSS );
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

	//set it as not landed in the ground until it does
	entity_set_int(Ent,EV_INT_iuser1, 0)
	
	girlb_dec_num_globs(id)

	if(!is_user_bot(id)){
		client_print(id,print_center,"You have %d globs left!",girlb_get_num_globs(id))
	}
	trail(Ent,FROZEN_BLUE,10,5)
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, SPHERE_MODEL );
	engfunc(EngFunc_PrecacheSound, FROZEN_SFX );
}