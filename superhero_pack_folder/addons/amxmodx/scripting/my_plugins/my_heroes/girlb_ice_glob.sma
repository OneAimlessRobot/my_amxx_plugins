#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_QUICK_CHECKS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_CUSTOM_COLORS
#define I_WANT_ENTITY_VECTORS
#define I_WANT_PDATA_ALIASES
#include "../my_include/superheromod.inc"
#include "freeze_fx/freeze_fx.inc"
#include "girlb_includes/girlb_get_set.inc"
#include "girlb_includes/girlb_ice_glob_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt15.inc"

#define PLUGIN "Superhero girlb ice glob funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

#define GLOB_THINK_PERIOD 0.1111

#define GLOB_FIELD_LIFE_TIME 2.0

#define GLOB_CLASSNAME "girlb_ice_glob"

#define GLOB_MIN_FRICTION 0.03333335

#define GLOB_SPEED 999.0

#define GLOB_DMG 90

#define GLOB_DAMAGE_RADIUS 145.0

#define GLOB_RENDER_RADIUS 490.0

#define GLOB_SKATING_RADIUS 700.0

#define GIRLB_ACCEL_SOUND "shmod/girlb/girlb_tron_accel.wav"

new can_skate_mask = 0
new is_skating_mask = 0
new is_glowing_mask = 0
new was_skating_mask = 0
new Float:g_player_old_friction[SH_MAXSLOTS+1] = {0.0, ...},
	Float:g_player_new_friction[SH_MAXSLOTS+1] = {0.0, ...}

#define STEAM_SPRITE_FILENAME "sprites/steam1.spr"
new gSpriteSmoke = 0


#define SKATING_GLOBAL_TASK_PERIOD 0.1


#define ICE_GLOB_TASK_PERIOD 0.1


#define DUCKING_STANDING_HEIGHT_RATIO 0.87

#define PLAYER_AREA ((cvar_val(float,pcvar_height)*cvar_val(float,pcvar_height))*M_PI)
#define PLAYER_DRAG_CONST (PLAYER_AREA*cvar_val(float,pcvar_car))

//cvar floats!

new pcvar_girlb_force,
	pcvar_girlb_air_drag,
	pcvar_mass,
	pcvar_car,
	pcvar_height,
	pcvar_speed_cap

new generic_dmg_source_freezing = -1

new const DEBUG = 0

new PLUGIN_ID_HERE

#define GIRLB_MONITOR_PROXIMITY_THINKER_ENTITY_CLASSNAME "girlB_Monitor_Proximity_Entity"
#define GIRLB_MONITOR_SKATING_THINKER_ENTITY_CLASSNAME "girlB_Monitor_Skating_Entity"

new girlb_monitor_proximity_thinker_entity = -1,
	girlb_monitor_skating_thinker_entity = -1

new proximity_forward_id = -1,
	skating_forward_id = -1

public plugin_init(){
	PLUGIN_ID_HERE = register_plugin(PLUGIN, VERSION, AUTHOR);


	pcvar_mass = create_cvar("girlb_mass", "1.0",_,"Mass cannot be lower than zero",true, 0.1,false)
	pcvar_car = create_cvar("girlb_car", "0.2")
	pcvar_height = create_cvar("girlb_height", "1.0")
	pcvar_girlb_air_drag = create_cvar("girlb_air_drag_coeff", "0.5")
	pcvar_girlb_force = create_cvar("girlb_thrust_force_persec", "50.0")
	pcvar_speed_cap = create_cvar("girlb_speed_cap", "1500.0",_, _,true,700.0)
	

	register_think(GLOB_CLASSNAME, "ice_field_think")
	
	register_entity_as_wall_touchable(GLOB_CLASSNAME,"FwdTouch")
	register_custom_touchable(GLOB_CLASSNAME,"player_touch",player_vector,1)
	register_forward(FM_CmdStart, "girlb_skating")

	RegisterHam(Ham_Player_PreThink,"player","Ham_Think_Pre",_,true)


	if(girlb_monitor_proximity_thinker_entity<=0){

		proximity_forward_id = register_think(GIRLB_MONITOR_PROXIMITY_THINKER_ENTITY_CLASSNAME, "player_on_ice_glob_checks")

		girlb_monitor_proximity_thinker_entity = create_entity("info_target")


		if(!girlb_monitor_proximity_thinker_entity){

			set_fail_state("GirlB Proximity Monitor entity could not be initialized!")
			unregister_think(proximity_forward_id)
			return
		}

		entity_set_string(girlb_monitor_proximity_thinker_entity,EV_SZ_classname,GIRLB_MONITOR_PROXIMITY_THINKER_ENTITY_CLASSNAME)

		entity_set_float(girlb_monitor_proximity_thinker_entity, EV_FL_nextthink, get_gametime() + ICE_GLOB_TASK_PERIOD)




	}

	if(girlb_monitor_skating_thinker_entity<=0){

		skating_forward_id = register_think(GIRLB_MONITOR_SKATING_THINKER_ENTITY_CLASSNAME, "girlb_skating_loop")

		girlb_monitor_skating_thinker_entity = create_entity("info_target")


		if(!girlb_monitor_skating_thinker_entity){

			set_fail_state("GirlB Monitor entity could not be initialized!")
			unregister_think(skating_forward_id)
			unregister_think(proximity_forward_id)
			return
		}

		entity_set_string(girlb_monitor_skating_thinker_entity,EV_SZ_classname,GIRLB_MONITOR_SKATING_THINKER_ENTITY_CLASSNAME)

		entity_set_float(girlb_monitor_skating_thinker_entity, EV_FL_nextthink, get_gametime() + SKATING_GLOBAL_TASK_PERIOD)




	}

}
public Ham_Think_Pre(id) {
	
	if(!sh_is_active()) return HAM_IGNORED

	if(sh_is_freezetime()) return HAM_IGNORED
	
	if(!is_user_alive(id)) return HAM_IGNORED

	if(!sh_get_user_has_hero(id,gHeroID)){

		return HAM_IGNORED

	}
	if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(id,SH_USER_IS_FLYING)){


		return HAM_IGNORED

	}
	if(sh_get_stun(id)){
		
		return HAM_IGNORED
	
	}
	if(!Get_BitVar(is_skating_mask,id)){

		return HAM_IGNORED

	}
	entity_set_float(id, EV_FL_friction,g_player_new_friction[id])
	
	return HAM_IGNORED
}
public plugin_cfg(){

	gHeroID = girlb_get_hero_id()
	generic_dmg_source_freezing = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_FREEZE)
}
/*


*/
public girlb_skating_loop(ent_id){


	if(!is_valid_ent(ent_id)){

		return
	}
	if(!sh_is_active()){

		entity_set_float(ent_id, EV_FL_nextthink, get_gametime() + SKATING_GLOBAL_TASK_PERIOD)
	}
	if(sh_is_freezetime()){
		
		entity_set_float(ent_id, EV_FL_nextthink, get_gametime() + SKATING_GLOBAL_TASK_PERIOD)
	}
	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		id = the_players[i]
        
		static Float:final_velocity_player[3],
					Float:velocity_player[3],
					Float:propel_force,
					bool:ducking = false

		ducking = false
		
		if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)) continue

		if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(id,SH_USER_IS_FLYING)){

			continue
		}
		if(sh_get_stun(id)){
			
			continue
		
		}
		if(!Get_BitVar(is_skating_mask,id)){

			continue

		}
		if((entity_get_int(id, EV_INT_flags)&FL_DUCKING)){
			
			ducking = true
		}

		propel_force = (cvar_val(float, pcvar_girlb_force)*SKATING_GLOBAL_TASK_PERIOD)/cvar_val(float, pcvar_mass)
		
		entity_get_vector(id,EV_VEC_velocity,velocity_player)

		new Float:speed = vector_length(velocity_player)

		my_velocity_by_aim(id,min_macro(cvar_val(float, pcvar_speed_cap),propel_force+speed),final_velocity_player,dummy_vector)

		final_velocity_player[2] = 0.0

		entity_set_vector(id,EV_VEC_velocity,final_velocity_player)

		player_air_drag_update_speed(id,(ducking?(DUCKING_STANDING_HEIGHT_RATIO*DUCKING_STANDING_HEIGHT_RATIO):1.0)*PLAYER_DRAG_CONST*cvar_val(float, pcvar_girlb_air_drag),SKATING_GLOBAL_TASK_PERIOD)

		entity_get_vector(id,EV_VEC_velocity,velocity_player)

		if(!Get_BitVar(is_glowing_mask,id)){
			Set_BitVar(is_glowing_mask,id)
			
		}
		if(!(CSW_KNIFE==get_user_weapon(id))){
			engclient_cmd(id, "weapon_knife")
		}
	}

	entity_set_float(ent_id, EV_FL_nextthink, get_gametime() + SKATING_GLOBAL_TASK_PERIOD)
}
public girlb_skating(id, uc_handle, seed)
{	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)){
		return FMRES_IGNORED;
	}

	if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(id,SH_USER_IS_FLYING)){

		return FMRES_IGNORED

	}
	if(!sh_get_user_has_hero(id,gHeroID)){

		return FMRES_IGNORED
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
	inground=bool:(pev( id, pev_flags ) & FL_ONGROUND  )
	should_skate=((buttons &IN_JUMP)&&(buttons &IN_FORWARD))&&Get_BitVar(can_skate_mask,id)&&inground
	//should_skate=((buttons &IN_FORWARD))&&Get_BitVar(can_skate_mask,id)&&inground
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
			
			emit_sound(id, CHAN_STATIC,GIRLB_ACCEL_SOUND,
					VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		return return_result;
    }
	else if(Get_BitVar(is_glowing_mask,id)){//avoids calling it too many times (heavy function)
		UnSet_BitVar(is_glowing_mask,id)
		if(Get_BitVar(was_skating_mask,id)){
			kill_trails_on_user(id)
			emit_sound(id, CHAN_STATIC,GIRLB_ACCEL_SOUND,
				VOL_NORM, ATTN_NONE, SND_STOP, PITCH_NORM)
		}
	}
	return return_result;
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		pev(id, pev_friction, g_player_old_friction[id]);
		
		if(sh_get_user_has_hero(id,gHeroID)){
			UnSet_BitVar(can_skate_mask,id);
		}
	}
	
}
public player_on_ice_glob_checks(ent_id){


	if(!is_valid_ent(ent_id)){

		return
	}
	if(!sh_is_active()){

		entity_set_float(ent_id, EV_FL_nextthink, get_gametime() + SKATING_GLOBAL_TASK_PERIOD)
	}
	if(sh_is_freezetime()){
		
		entity_set_float(ent_id, EV_FL_nextthink, get_gametime() + SKATING_GLOBAL_TASK_PERIOD)
	}

	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]
		
		if(sh_get_stun(id)) continue

		if(!(pev(id, pev_flags ) & FL_ONGROUND  )){
			
			set_pev(id, pev_friction,g_player_old_friction[id])
			UnSet_BitVar(can_skate_mask,id)
			continue
		
		}

		
		static entlist[33];
		static num_found;
		static Float:curr_player_friction
		pev(id, pev_friction, curr_player_friction)
		num_found = find_sphere_class(id,GLOB_CLASSNAME,GLOB_SKATING_RADIUS,entlist,charsmax(entlist))
		if((num_found>0)){

			static count;
			count = 0
			for(new fid=0;fid < num_found;fid++){
				
				new field= entlist[fid]

				//check if field landed on ground
				new bool:has_landed = bool:pev(field, pev_iuser1)
				
				if(!has_landed){
					
					continue
				}
				count++
				
				static Float:the_distance
				the_distance = entity_range(id,field)

				curr_player_friction -= (((1.0)-clamp_macro((the_distance/GLOB_SKATING_RADIUS),GLOB_MIN_FRICTION,1.0))*g_player_old_friction[id])
				


			}

			if(DEBUG){
						
				sh_chat_message(id, gHeroID, "We found %d grounded fields!",count)
			
			}

			if(!count){

				
				
				set_pev(id, pev_friction,g_player_old_friction[id])
				
				if(sh_get_user_has_hero(id,gHeroID)){
					if(Get_BitVar(can_skate_mask,id)){
						UnSet_BitVar(can_skate_mask,id)
					}
				}
				continue
			}

			g_player_new_friction[id] = clamp_macro(curr_player_friction,GLOB_MIN_FRICTION,g_player_old_friction[id])
			
			
			set_pev(id, pev_friction,g_player_new_friction[id])


			if(sh_get_user_has_hero(id,gHeroID)){
				if(!Get_BitVar(can_skate_mask,id)){
					Set_BitVar(can_skate_mask,id)
				}
			}

		}
		else{
			set_pev(id, pev_friction,g_player_old_friction[id])
			
			if(sh_get_user_has_hero(id,gHeroID)){
				if(Get_BitVar(can_skate_mask,id)){
					UnSet_BitVar(can_skate_mask,id)
				}
			}
		}

		if(DEBUG){
		
			sh_chat_message(id, gHeroID, "We found %d fields!",num_found)
		
		}
		
	}
	entity_set_float(ent_id, EV_FL_nextthink, get_gametime() + ICE_GLOB_TASK_PERIOD)
}
public plugin_natives(){
	

	register_native( "launch_ice_glob","_launch_ice_glob")
	
	
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
				_,_,_,_,_,
				SH_NEW_DMG_FREEZE,
				generic_dmg_source_freezing)

		if(!sh_get_id_bit(Other_Entity, SH_IS_FROZEN)){
			sh_freeze_user(Other_Entity,7.0,130.0)
		}
	}
	return true
}
public FwdTouch( Glob, World ) {
	if(!pev_valid(Glob)) return

	if(pev(Glob, pev_iuser1)){

		return
	}
	new owner_edict=pev(Glob, pev_owner)

	static Float:glob_origin[3]
	pev(Glob, pev_origin,glob_origin)

	static entlist[33];
	new numfound = find_sphere_class(Glob,"player",
					GLOB_DAMAGE_RADIUS,
					entlist,
					sizeof entlist);

	emit_sound(Glob, CHAN_WEAPON, FROZEN_SFX, 1.0, ATTN_NORM, 0, PITCH_NORM)

	for( new i= 0;(i< numfound);i++){

		new pid = entlist[i];
		if( !is_user_alive(pid) ) continue
		
		if(pid==owner_edict) continue

		if( sh_clients_are_same_team(pid,owner_edict)) continue
		
		if(!sh_get_id_bit(pid, SH_IS_FROZEN)){
			sh_freeze_user(pid,7.0,130.0)
		}

	}
	//set it as not landed in the ground until it does
	//and we just did.
	set_pev(Glob, pev_iuser1, 1)
	set_pev(Glob, pev_movetype, MOVETYPE_TOSS)

}
public player_touch( Glob, Player ) {
	if(!is_valid_ent(Glob)) return

	if(player_touch_logic(Glob, Player)){
		
		if(!is_valid_ent(Glob)) return

		new owner= entity_get_edict(Glob,EV_ENT_owner)
		if(Player==owner){
			return
		}

	}
	return
}

public plugin_end(){

	if(proximity_forward_id>=0){

		unregister_think(proximity_forward_id)

	}
	if(skating_forward_id>=0){

		unregister_think(skating_forward_id)

	}

	if(is_valid_ent(girlb_monitor_proximity_thinker_entity)){

		remove_entity(girlb_monitor_proximity_thinker_entity)
	}

	if(is_valid_ent(girlb_monitor_skating_thinker_entity)){

		remove_entity(girlb_monitor_skating_thinker_entity)
	}

}

public sh_round_end(){

    remove_entity_name(GLOB_CLASSNAME)
}
//----------------------------------------------------------------------------------------------
public ice_field_think(ent)
{
	
	if (!is_valid_ent(ent)){
		
	
			return
	
	}

	static Float:ent_pos[3]

	if (entity_get_float(ent,EV_FL_fuser1)<0.0) {
		remove_entity(ent)
		return
	}
	else{
		pev(ent, pev_origin, ent_pos)
		
		//get landed status to produce shockwave in that case
		if(entity_get_int(ent,EV_INT_iuser1)){
			make_shockwave(ent_pos,GLOB_RENDER_RADIUS*2,LineColors[FROZEN_BLUE],1,5,8,4,60)
		}

		// Steam sprite
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, {0,0,0}, 0)
		write_byte(TE_SPRITE)			// TE_SPRITE
		write_coord_f(ent_pos[0])	// center position
		write_coord_f(ent_pos[1])
		write_coord_f(ent_pos[2])
		write_short(gSpriteSmoke)	// sprite index
		write_byte(30)		// scale in 0.1's
		write_byte(40)			// brightness
		message_end()

		entity_set_float(ent,EV_FL_fuser1,floatsub(entity_get_float(ent,EV_FL_fuser1),GLOB_THINK_PERIOD))
		entity_set_float(ent,EV_FL_nextthink,floatadd(get_gametime(),GLOB_THINK_PERIOD))
	
	}
}


public girlb_glob_post_launch_callback(Ent, id, Float:Velocity[3], &bool:modified_speed_flag){


	if(!is_valid_ent(Ent)){

		return
	}
	if(!is_user_alive(id)){

		return
		
	}
	static Float:Origin[3],
			Float:advance[3]

	entity_get_vector(id, EV_VEC_origin , Origin)

	my_velocity_by_aim(id,5.0,advance,dummy_vector)

	add_3d_vectors(Origin,advance,Origin)
	
	entity_set_origin(Ent,Origin)

	if(!is_user_bot(id)){
		client_print(id,print_center,"You have %d globs left!",girlb_get_num_globs(id))
	}

	//set it as not landed in the ground until it has
	entity_set_int(Ent,EV_INT_iuser1, 0)



	//set field timer
	entity_set_float(Ent,EV_FL_fuser1, GLOB_FIELD_LIFE_TIME)

	girlb_dec_num_globs(id)

}

public _launch_ice_glob(iPlugin,iParams)
{
	
	new id= get_param(1)
	
	if(!sh_get_user_has_hero(id,gHeroID)||!is_user_alive(id)) return
	
	static func_id;

	func_id = get_func_id("girlb_glob_post_launch_callback",PLUGIN_ID_HERE)


	launch_projectile_native(id,
		GLOB_SPEED,
		GLOB_THINK_PERIOD,
		GLOB_CLASSNAME,
		"",
		"info_target",
		Float:{ -10.0, -10.0, 0.0 },
		Float:{ 10.0, 10.0, 10.0 } ,
		0.0,
		SOLID_TRIGGER,
		MOVETYPE_FLY,
		EF_DIMLIGHT,
		1.0,
		PLUGIN_ID_HERE,
		func_id)

}

public plugin_precache()
{
	
	gSpriteSmoke = engfunc(EngFunc_PrecacheModel,STEAM_SPRITE_FILENAME)

	engfunc(EngFunc_PrecacheSound, FROZEN_SFX );
	engfunc(EngFunc_PrecacheSound, GIRLB_ACCEL_SOUND );
}