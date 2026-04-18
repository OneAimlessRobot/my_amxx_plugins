#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_consts.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_quick_checks.inc"
#include "sh_aux_stuff/sh_aux_math_funcs_pt1.inc"
#include "../my_include/stripweapons.inc"


#define PLUGIN "Superhero fx natives pt2"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);
	prepare_shero_aux_lib_pt2()

}
public plugin_precache(){

	precache_native_fx_pt2()
}
public plugin_natives(){


	register_native("fx_invisible","_fx_invisible",0);
	register_native("fx_blood","_fx_blood",0);
	register_native("strip_weapon_for_my_grenade_heroes","_strip_weapon_for_my_grenade_heroes",0);
	register_native("fx_bleed","_fx_bleed",0);
	register_native("fx_blood_small","_fx_blood_small",0);
	register_native("fx_blood_large","_fx_blood_large",0);
	register_native("fx_gib_explode","_fx_gib_explode",0);
	register_native("blood_spray","_blood_spray",0);
	register_native("fx_extra_blood","_fx_extra_blood",0);
	register_native("fx_headshot","_fx_headshot",0);
	register_native("anime_kill_fx","_anime_kill_fx",0);
	register_native("precache_gibs","_precache_gibs",0);
	register_native("draw_view_cone","_draw_view_cone",0);
	register_native("gross_kill_gibs_fx","_gross_kill_gibs_fx",0)
	register_native("precache_native_fx_pt2","_precache_native_fx_pt2",0)
	register_native("prepare_shero_aux_lib_pt2","_prepare_shero_aux_lib_pt2",0);
}


public _prepare_shero_aux_lib_pt2(iPlugins, iParams){
	
	server_print("%s innited!^n",LIBRARY_NAME)
}
	
public _precache_native_fx_pt2(iPlugin,iParams){

	engfunc(EngFunc_PrecacheSound,SUCK_IN_SOUND_FILE_NAME)
	
	precache_gibs()

}
public _fx_invisible(iPlugins, iParams){

	new id=get_param(1)


	if(is_user_connected(id)){
		set_pev(id, pev_renderfx, kRenderFxNone)
		set_pev(id, pev_rendermode, kRenderTransAlpha)
		set_pev(id, pev_renderamt, 0.0)
	}
}

public _fx_blood(iPlugins, iParams){

	new origin[3],origin2[3]

	get_array(1,origin,3)
	get_array(2,origin2,3)
	new HitPlace=get_param(3)
	new alien=get_param(4)

	//Crash Checks
	if (HitPlace < 0 || HitPlace > 7) HitPlace = 0
	new rDistance = get_distance(origin,origin2) ? get_distance(origin,origin2) : 1

	new rX = ((origin[0]-origin2[0]) * 300) / rDistance
	new rY = ((origin[1]-origin2[1]) * 300) / rDistance
	new rZ = ((origin[2]-origin2[2]) * 300) / rDistance

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSTREAM)
	write_coord(origin[0]+Offset[HitPlace][0])
	write_coord(origin[1]+Offset[HitPlace][1])
	write_coord(origin[2]+Offset[HitPlace][2])
	write_coord(rX) // x
	write_coord(rY) // y
	write_coord(rZ) // z
	write_byte(alien?BLOOD_STREAM_YELLOW:BLOOD_STREAM_RED) // color
	write_byte(generate_int(100,200)) // speed
	message_end()
}
public _strip_weapon_for_my_grenade_heroes(iPlugins, iParams){

	new id=get_param(1)


	if(!is_user_connected(id)) return 

	new message[128]

	get_string(2,message,127)

	new classid=get_param(3)

	new optional_bool=get_param(4)

	if(optional_bool){
		if(!is_user_bot(id)){
			client_print(id, print_center, message)
		}
		ham_strip_user_weapon(id, classid, _, false);
		sh_drop_weapon(id,classid,true)
		cs_set_user_bpammo(id, classid,0);
	}
}
public _fx_bleed(iPlugins, iParams){
	new origin[3]

	get_array(1,origin,3)

	new alien=get_param(2)
	// Blood spray
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSTREAM)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(generate_int(-360,360)) // x
	write_coord(generate_int(-360,360)) // y
	write_coord(-10) // z
	write_byte(alien?BLOOD_STREAM_YELLOW:BLOOD_STREAM_RED) // color
	write_byte(generate_int(50,100)) // speed
	message_end()
}

public _fx_blood_small(iPlugins, iParams){
	new origin[3]

	get_array(1,origin,3)

	new num=get_param(2)

	// Write Small splash decal
	for (new j = 0; j < num; j++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+generate_int(-100,100))
		write_coord(origin[1]+generate_int(-100,100))
		write_coord(origin[2]-36)
		write_byte(blood_small_red[generate_int(0,BLOOD_SM_NUM - 1)]) // index
		message_end()
	}
}

public _fx_blood_large(iPlugins, iParams){
	new origin[3]

	get_array(1,origin,3)

	new num=get_param(2)
	// Write Large splash decal
	for (new i = 0; i < num; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+generate_int(-50,50))
		write_coord(origin[1]+generate_int(-50,50))
		write_coord(origin[2]-36)
		write_byte(blood_large_red[generate_int(0,BLOOD_LG_NUM - 1)]) // index
		message_end()
	}
}

public _fx_gib_explode(iPlugins, iParams){
	new origin[3],origin2[3]

	get_array(1,origin,3)
	get_array(2,origin2,3)

	new flesh[2]
	flesh[0] = mdl_gib_flesh
	flesh[1] = mdl_gib_meat
	new mult = 80, gibtime = 400 //40 seconds
						

	new rDistance = get_distance(origin,origin2) ? get_distance(origin,origin2) : 1
	new rX = ((origin[0]-origin2[0]) * mult) / rDistance
	new rY = ((origin[1]-origin2[1]) * mult) / rDistance
	new rZ = ((origin[2]-origin2[2]) * mult) / rDistance
	new rXm = rX >= 0 ? 1 : -1
	new rYm = rY >= 0 ? 1 : -1
	new rZm = rZ >= 0 ? 1 : -1

	// Gib explosions

	// Head
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+40)
	write_coord(rX + (rXm * generate_int(0,80)))
	write_coord(rY + (rYm * generate_int(0,80)))
	write_coord(rZ + (rZm * generate_int(80,200)))
	write_angle(generate_int(0,360))
	write_short(mdl_gib_head)
	write_byte(0) // bounce
	write_byte(gibtime) // life
	message_end()

	// Parts
	for(new i = 0; i < 4; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(rX + (rXm * generate_int(0,80)))
		write_coord(rY + (rYm * generate_int(0,80)))
		write_coord(rZ + (rZm * generate_int(80,200)))
		write_angle(generate_int(0,360))
		write_short(flesh[generate_int(0,1)])
		write_byte(0) // bounce
		write_byte(gibtime) // life
		message_end()
	}

	// Spine
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+30)
	write_coord(rX + (rXm * generate_int(0,80)))
	write_coord(rY + (rYm * generate_int(0,80)))
	write_coord(rZ + (rZm * generate_int(80,200)))
	write_angle(generate_int(0,360))
	write_short(mdl_gib_spine)
	write_byte(0) // bounce
	write_byte(gibtime) // life
	message_end()

	// Lung
	for(new i = 0; i <= 1; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]+10)
		write_coord(rX + (rXm * generate_int(0,80)))
		write_coord(rY + (rYm * generate_int(0,80)))
		write_coord(rZ + (rZm * generate_int(80,200)))
		write_angle(generate_int(0,360))
		write_short(mdl_gib_lung)
		write_byte(0) // bounce
		write_byte(gibtime) // life
		message_end()
	}

	//Legs
	for(new i = 0; i <= 1; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]-10)
		write_coord(rX + (rXm * generate_int(0,80)))
		write_coord(rY + (rYm * generate_int(0,80)))
		write_coord(rZ + (rZm * generate_int(80,200)))
		write_angle(generate_int(0,360))
		write_short(mdl_gib_legbone)
		write_byte(0) // bounce
		write_byte(gibtime) // life
		message_end()
	}

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+20)
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(BLOOD_COLOR_RED) // color index
	write_byte(10) // size
	message_end()
}

public _fx_extra_blood(iPlugins, iParams){
	new origin[3]

	get_array(1,origin,3)

	new x, y, z

	for(new i = 0; i < 3; i++) {
		x = generate_int(-15,15)
		y = generate_int(-15,15)
		z = generate_int(-20,25)
		for(new j = 0; j < 2; j++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0]+(x*j))
			write_coord(origin[1]+(y*j))
			write_coord(origin[2]+(z*j))
			write_short(spr_blood_drop)
			write_short(spr_blood_drop)
			write_byte(BLOOD_COLOR_RED) // color index
			write_byte(15) // size
			message_end()
		}
	}
}

public _fx_headshot(iPlugins, iParams){
	new origin[3]

	get_array(1,origin,3)

	new Sprays = 8

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+40)
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(BLOOD_COLOR_RED) // color index
	write_byte(15) // size
	message_end()

	// Blood sprays
	for (new i = 0; i < Sprays; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BLOODSTREAM)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]+40)
		write_coord(generate_int(-30,30)) // x
		write_coord(generate_int(-30,30)) // y
		write_coord(generate_int(80,300)) // z
		write_byte(BLOOD_STREAM_RED) // color
		write_byte(generate_int(100,200)) // speed
		message_end()
	}
}

public _anime_kill_fx(iPlugins, iParams){
	new origin[3]

	get_array(1,origin,3)

	message_begin(MSG_ALL, SVC_TEMPENTITY) 
	write_byte(10)	// TE_LAVASPLASH 
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]-26) 
	message_end() 

}
public _gross_kill_gibs_fx(iPlugins,iParm){

	new id=get_param(1)
	if(!is_user_connected(id)) return
	if(is_user_alive(id)) return
	new Float:vic_origin[3],Float:origin[3]
	new ivExplodeAt[3],ivicOrigin[3]
	get_array_f(2,vic_origin,3)
	get_array_f(3,origin,3)


	fx_invisible(id)

	FVecIVec(vic_origin,ivicOrigin)
	FVecIVec(origin,ivExplodeAt)
	fx_gib_explode(ivicOrigin,ivExplodeAt)
	fx_blood_large(ivicOrigin,4)
	fx_blood_small(ivicOrigin,4)

	fx_blood_small(ivicOrigin,8)
	fx_extra_blood(ivicOrigin)
	fx_blood_large(ivExplodeAt,2)
	fx_blood_small(ivicOrigin,4)

}
//----------------------------------------------------------------------------------------------
public _blood_spray(iPlugins, iParams){


	new Float:vicOrigin[3]

	get_array_f(1,vicOrigin,3)

	new scale=get_param(2)

	new Float:x
	new Float:y
	for(new i = 0; i < 2; i++) {
		x = float(generate_int(-10, 10))
		y = float(generate_int(-10, 10))
		for(new Float:j = 0.0; j < 2.0; j+=1.0) {
			// Blood spray
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(115)				// TE_BLOODSPRITE
			write_coord_f(vicOrigin[0]+(x*j))	// position
			write_coord_f(vicOrigin[1]+(y*j))
			write_coord_f(vicOrigin[2]+21.0)
			write_short(spr_blood_drop)	// sprite1 index
			write_short(spr_blood_spray)	// sprite2 index
			write_byte(248) 			// color RED = 248 YELLOW = 196
			write_byte(scale) 			// scale
			message_end()
		}
	}
}

public _precache_gibs(iPlugins, iParams){

	spr_blood_drop = engfunc(EngFunc_PrecacheModel,"sprites/blood.spr")
	spr_blood_spray = engfunc(EngFunc_PrecacheModel,"sprites/bloodspray.spr")

	mdl_gib_flesh = engfunc(EngFunc_PrecacheModel,"models/Fleshgibs.mdl")
	mdl_gib_meat = engfunc(EngFunc_PrecacheModel,"models/GIB_B_Gib.mdl")
	mdl_gib_head = engfunc(EngFunc_PrecacheModel,"models/GIB_Skull.mdl")
	
	mdl_gib_spine = engfunc(EngFunc_PrecacheModel,"models/GIB_B_Bone.mdl")
	mdl_gib_lung = engfunc(EngFunc_PrecacheModel,"models/GIB_Lung.mdl")
	mdl_gib_legbone = engfunc(EngFunc_PrecacheModel,"models/GIB_Legbone.mdl")
}

public _draw_view_cone(iPlugins, iParams){
	new player_id= get_param(1)
	new Float:fov_to_contain=get_param_f(2)
	new Float:distance_limit=get_param_f(3)
	static 
	Float:origin_a[3], 
	Float:aimorigin_a[3], 
	Float:aimorigin_left[3], 
	Float:aimorigin_right[3], 
	Float:vec_a[3], 
	Float:vec_left[3], 
	Float:vec_right[3];
	
	entity_get_vector(player_id, EV_VEC_origin,origin_a)
	get_player_aim_vector_raw(player_id, vec_a);
	new Float:length_a = vector_length(vec_a);
	multiply_3d_vector_by_scalar(vec_a,distance_limit / length_a,  vec_a);
	fov_to_contain = angle_convert(fov_to_contain, false);
	rotate_vector3(vec_left, vec_a, -0.5 * (fov_to_contain));
	rotate_vector3(vec_right, vec_a, 0.5 * (fov_to_contain));
	add_3d_vectors(vec_a, aimorigin_a,origin_a);
	add_3d_vectors(vec_right, aimorigin_right,origin_a);
	add_3d_vectors(vec_left, aimorigin_left,origin_a);
	
	aimorigin_a[2] = aimorigin_right[2] = aimorigin_left[2] = origin_a[2];
	laser_line(player_id, origin_a, aimorigin_a,false);
	laser_line(player_id, origin_a, aimorigin_right, false);
	laser_line(player_id, origin_a, aimorigin_left, false);
	
}
