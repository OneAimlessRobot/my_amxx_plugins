#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_QUICK_CHECKS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "freeze_fx/freeze_fx.inc"
#include "girlb_includes/girlb_get_set.inc"
#include "girlb_includes/girlb_ice_glob_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"

#define PLUGIN "Superhero girlb ice glob funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new can_skate_mask = 0
new is_skating_mask = 0
new is_glowing_mask = 0
new was_skating_mask = 0
new Float:g_player_old_friction[SH_MAXSLOTS+1] = {0.0, ...}
#define STEAM_SPRITE_FILENAME "sprites/steam1.spr"
new gSpriteSmoke = 0
new ICE_GLOB_GLOBAL_TASKID

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_think(GLOB_CLASSNAME, "ice_field_think")
	
	register_entity_as_wall_touchable(GLOB_CLASSNAME,"FwdTouch")
	register_custom_touchable(GLOB_CLASSNAME,"player_touch",player_vector,1)
	register_forward(FM_CmdStart, "girlb_skating")

	register_event("ResetHUD","ice_glob_new_round","b")

	set_task(0.333,"player_on_ice_glob_checks",ICE_GLOB_GLOBAL_TASKID,_,_,"b")
}

public girlb_skating(id, uc_handle, seed)
{	
	if(!sh_is_active()){
		return FMRES_IGNORED
	}
	if(sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!sh_user_has_hero(id,girlb_get_hero_id())||!is_user_alive(id)){
		return FMRES_IGNORED;
	}
	if(sh_get_stun(id)){
		return FMRES_IGNORED
	}
	static buttons

	if(Get_BitVar(is_skating_mask,id)){

		Set_BitVar(was_skating_mask,id)
	}
	else{

		UnSet_BitVar(was_skating_mask,id)

	}
	buttons = get_uc(uc_handle, UC_Buttons)
	static bool:should_skate,bool:inground;
	inground=bool:(entity_get_int( id, EV_INT_flags ) & FL_ONGROUND  )
	should_skate=((buttons &IN_JUMP)&&(buttons &IN_FORWARD))&&Get_BitVar(can_skate_mask,id)&&inground
	new return_result = FMRES_IGNORED

	if(should_skate){

		Set_BitVar(is_skating_mask,id)
		buttons &= (~(IN_JUMP))
		set_uc(uc_handle, UC_Buttons, buttons);
		return_result=FMRES_SUPERCEDE
	}
	else{

		UnSet_BitVar(is_skating_mask,id)

	}


	
	
	if(Get_BitVar(is_skating_mask,id))
	{
		if(!Get_BitVar(was_skating_mask,id)){
			
			trail(id,LTBLUE,6,20)
			
			emit_sound(id, CHAN_WEAPON,FROZEN_SFX,
					VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		if(generate_int(0, FlameAndSoundRate) <3)
		{
			static Float:Velocity[3],Float:our_velocity[3]
			
			entity_get_vector(id, EV_VEC_velocity,our_velocity)

			velocity_by_aim(id, floatround(GLOB_ICE_SKATE_SPEED), Velocity)
			
			Velocity[2]=our_velocity[2]

			
			entity_set_vector(id, EV_VEC_velocity, Velocity)
		
			if(!Get_BitVar(is_glowing_mask,id)){
				Set_BitVar(is_glowing_mask,id)
				
			}

        }
		if(!(CSW_KNIFE==get_user_weapon(id))){
			engclient_cmd(id, "weapon_knife")
		}
		return return_result;
    }
	else if(Get_BitVar(is_glowing_mask,id)){//avoids calling it too many times (heavy function)
		UnSet_BitVar(is_glowing_mask,id)
	}
	return return_result;
}
//----------------------------------------------------------------------------------------------
public ice_glob_new_round(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		g_player_old_friction[id] = entity_get_float(id,EV_FL_friction);
		
		if(sh_user_has_hero(id,girlb_get_hero_id())){
			UnSet_BitVar(can_skate_mask,id);
		}
	}
	
}
public player_on_ice_glob_checks(task_id){

	if(!sh_is_active()||sh_is_freezetime()) return


	for(new id=1;id< sh_maxplayers()+1;id++){
		if(!is_user_alive(id)) continue
		
		if(sh_get_stun(id)) continue

		if(!(entity_get_int( id, EV_INT_flags ) & FL_ONGROUND  )){
			
			entity_set_float(id,EV_FL_friction,g_player_old_friction[id])
			UnSet_BitVar(can_skate_mask,id)
			continue
		
		}

		
		static entlist[33];
		static num_found;
		static Float:curr_player_friction
		curr_player_friction=entity_get_float(id,EV_FL_friction)
		num_found = find_sphere_class(id,GLOB_CLASSNAME,GLOB_RADIUS,entlist,charsmax(entlist))
		if((num_found>0)){

			if(sh_user_has_hero(id,girlb_get_hero_id())){
				if(!Get_BitVar(can_skate_mask,id)){
					Set_BitVar(can_skate_mask,id)
				}
			}
			
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
			curr_player_friction = floatclamp(GLOB_MIN_FRICTION,curr_player_friction,g_player_old_friction[id])
			
			
			if(!Get_BitVar(is_skating_mask,id)){
			
				entity_set_float(id,EV_FL_friction,curr_player_friction)
			}
			else{
				

				entity_set_float(id,EV_FL_friction,g_player_old_friction[id])
				
			}
		}
		else{
			entity_set_float(id,EV_FL_friction,g_player_old_friction[id])
			
			if(sh_user_has_hero(id,girlb_get_hero_id())){
				if(Get_BitVar(can_skate_mask,id)){
					UnSet_BitVar(can_skate_mask,id)
				}
			}
		}
		
	}
}
public plugin_natives(){
	

	register_native( "launch_ice_glob","_launch_ice_glob",0)
	
	
}
//assumes both are valid
public bool:player_touch_logic(Glob, Other_Entity){

	if( !is_user_alive(Other_Entity) ) return false
	
	new owner_edict=entity_get_edict(Glob,EV_ENT_owner)

	if(!is_user_alive(owner_edict)){

		return false
	}
	if((Other_Entity != owner_edict )&&!sh_clients_are_same_team(Other_Entity,owner_edict)){
		sh_extra_damage(Other_Entity, owner_edict, GLOB_DMG,
				new_dmg_type_names[_:SH_NEW_DMG_FREEZE],_,_,_,_,_,_,
				SH_NEW_DMG_FREEZE,
				get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_FREEZE))
		if(!sh_is_user_frozen(Other_Entity)){
			sh_freeze_user(Other_Entity,7.0,130.0)
		}
	}
	return true
}
public FwdTouch( Glob, World ) {
	if(!is_valid_ent(Glob)) return FMRES_IGNORED

	if(entity_get_int(Glob,EV_INT_iuser1)){

		return FMRES_IGNORED
	}
	new owner_edict=entity_get_edict(Glob,EV_ENT_owner)

	static Float:glob_origin[3]
	entity_get_vector(Glob,EV_VEC_origin,glob_origin)

	static entlist[33];
	new numfound = find_sphere_class(Glob,"player",
					GLOB_RADIUS,
					entlist,
					sizeof entlist);

	emit_sound(Glob, CHAN_WEAPON, FROZEN_SFX, 1.0, ATTN_NORM, 0, PITCH_NORM)

	for( new i= 0;(i< numfound);i++){

		new pid = entlist[i];
		if( !is_user_alive(pid) ) continue
		
		if(pid==owner_edict) continue

		if( sh_clients_are_same_team(pid,owner_edict)) continue
		
		if(!sh_is_user_frozen(pid)){
			sh_freeze_user(pid,7.0,130.0)
		}

	}
	//set it as not landed in the ground until it does
	//and we just did.
	entity_set_int(Glob,EV_INT_iuser1, 1)
	entity_set_int(Glob,EV_INT_movetype, MOVETYPE_TOSS)

	return FMRES_IGNORED
}
public player_touch( Glob, Player ) {
	if(!is_valid_ent(Glob)) return FMRES_IGNORED

	if(player_touch_logic(Glob, Player)){
		
		if(!is_valid_ent(Glob)) return FMRES_IGNORED

		new owner= entity_get_edict(Glob,EV_ENT_owner)
		if(Player==owner){
			return FMRES_IGNORED
		}

	}
	return FMRES_IGNORED
}

//----------------------------------------------------------------------------------------------
public ice_field_think(ent)
{
	if(!is_valid_ent(ent)) return FMRES_IGNORED
	
	if ( pev_valid(ent)!=2 ){
		
	
			return FMRES_IGNORED
	
	}

	static Float:ent_pos[3]
	static ient_pos[3]

	if (entity_get_float(ent,EV_FL_fuser1)<0.0) {
		if(pev_valid(ent)==2){
			remove_entity(ent)
		}
		return FMRES_IGNORED
	}
	else{
		entity_get_vector(ent, EV_VEC_origin, ent_pos)
		FVecIVec(ent_pos,ient_pos)
		
		//get landed status to produce shockwave in that case
		if(entity_get_int(ent,EV_INT_iuser1)){
			make_shockwave(ient_pos,GLOB_RADIUS*2,LineColors[FROZEN_BLUE],1,5,8,4,60)
		}

		// Steam sprite
		message_begin(MSG_ALL, SVC_TEMPENTITY, ient_pos, 0)
		write_byte(TE_SPRITE)			// TE_SPRITE
		write_coord(ient_pos[0])	// center position
		write_coord(ient_pos[1])
		write_coord(ient_pos[2])
		write_short(gSpriteSmoke)	// sprite index
		write_byte(30)		// scale in 0.1's
		write_byte(40)			// brightness
		message_end()

		entity_set_float(ent,EV_FL_fuser1,floatsub(entity_get_float(ent,EV_FL_fuser1),GLOB_THINK_PERIOD))
		entity_set_float(ent,EV_FL_nextthink,floatadd(get_gametime(),GLOB_THINK_PERIOD))
	
	}
	return FMRES_IGNORED
}
public _launch_ice_glob(iPlugin,iParams)
{
	
	new id= get_param(1)
	
	if(!sh_user_has_hero(id,girlb_get_hero_id())||!is_user_alive(id)) return
	
	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent
	new Float: advance[3]

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	velocity_by_aim(id,5,advance)

	add_3d_vectors(Origin,advance,Origin)
	
	Ent = create_entity("info_target")
	
	if (!is_valid_ent(Ent)){
		sh_chat_message(id,girlb_get_hero_id(),"Glob failure!");
		return
	}
	
	entity_set_string(  Ent, EV_SZ_classname, GLOB_CLASSNAME );
	entity_set_int(  Ent , EV_INT_solid, SOLID_TRIGGER );
	entity_set_int( Ent, EV_INT_movetype, MOVETYPE_FLY );
	entity_set_size(  Ent, Float:{ -2.0, -2.0, 0.0 }, Float:{ 2.0, 2.0, 2.0 } );
	
	entity_set_float(  Ent, EV_FL_framerate, 0.0 );
	entity_set_int(  Ent , EV_INT_sequence, 0 );
	
	
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)
	
	entity_set_edict(Ent, EV_ENT_owner, id)
	
	velocity_by_aim(id, floatround(GLOB_SPEED) , Velocity)
	
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

	//set it as not landed in the ground until it has
	entity_set_int(Ent,EV_INT_iuser1, 0)
	
	girlb_dec_num_globs(id)

	if(!is_user_bot(id)){
		client_print(id,print_center,"You have %d globs left!",girlb_get_num_globs(id))
	}
	//set field timer
	entity_set_float(Ent,EV_FL_fuser1, GLOB_FIELD_LIFE_TIME)

	entity_set_float(Ent,EV_FL_nextthink, get_gametime() + GLOB_THINK_PERIOD)
}

public plugin_precache()
{
	
	gSpriteSmoke = engfunc(EngFunc_PrecacheModel,STEAM_SPRITE_FILENAME)
	engfunc(EngFunc_PrecacheSound, FROZEN_SFX );
}