#if defined sh_aux_funcs_pt2
  #endinput
#endif
#define sh_aux_funcs_pt2
#include "sh_aux_stuff/sh_aux_inc.inc"
#define MAX_MAP_DIST_POSSIBLE (8192.0*floatsqroot(3.0))


stock Float:cross_product(Float:result[3], Float:input_a[3], Float:input_b[3]) {
	//[(a1 * b2 - a2 * b1), (a2 * b0 - a0 * b2), (a0 * b1 - a1 * b0)]
	
	result[0] = (input_a[1] * input_b[2]) - (input_a[2] * input_b[1]);
	result[1] = (input_a[2] * input_b[0]) - (input_a[0] * input_b[2]);
	result[2] = (input_a[0] * input_b[1]) - (input_a[1] * input_b[0]);
	
	new Float:length = VecLength(result);
	vector_norm(result, result);
	return length;
	
}
stock dir_vector_to_yaw_pitch_roll(Float:result[3], Float:input_a[3]) {
	
	vector_norm(vec_a, vec_a, vec_size);
	vec_result[0] = -1.0 * (1.0 * floatsin(vec_a[2])) * (180.0 / MATH_PI);
	vec_result[1] = floatatan2((1.0 * vec_a[1]), (1.0 * vec_a[0])) * (180.0 / MATH_PI);
	vec_result[2] = 0.0;
}

stock Float:angle_convert(Float:angle, bool:false_for_degrees_to_radians_true_for_radians_to_degrees = true) {
	
	return (false_for_degrees_to_radians_true_for_radians_to_degrees ? (angle * (180.0 / MATH_PI)):(angle * (MATH_PI / 180.0)));
	
}

stock draw_view_cone(player_id, Float:fov_to_contain, Float:distance_limit) {
	
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
	Float:length_a = vector_len(vec_a, 3);
	vector_mult(vec_a, vec_a, distance_limit / length_a, 3);
	fov_to_contain = angle_convert(fov_to_contain, false);
	rotate_vector3(vec_left, vec_a, -0.5 * (fov_to_contain));
	rotate_vector3(vec_right, vec_a, 0.5 * (fov_to_contain));
	add_3d_vectors(vec_a, aimorigin_a,origin_a);
	add_3d_vectors(vec_right, aimorigin_right,origin_a);
	add_3d_vectors(vec_left, aimorigin_left,origin_a);
	
	aimorigin_a[2] = aimorigin_right[2] = aimorigin_left[2] = origin_a[2];
	laser_line(player_id, origin_a, aimorigin_a,false);
	laser_beam(player_id, origin_a, aimorigin_right, false);
	laser_beam(player_id, origin_a, aimorigin_left, false);
	
}
stock bool:check_in_fov(player_id, player_hit, Float:fov_to_check, Float:distance_to_check, Float:fov_to_store[1]={0.0}) {
	static Float:origin_a[3], 
	Float:origin_b[3],
	Float:aimorigin_a[3], 
	Float:aimorigin_b[3], 
	Float:vec_a[3], 
	Float:vec_b[3];
	
	entity_get_vector(player_id, EV_VEC_origin,origin_a)
	entity_get_vector(player_hit, EV_VEC_origin,origin_b)
	get_player_aim_vector_raw(player_id, vec_a);
	get_entity_direction_vector_raw(player_id, player_hit, vec_b);
	new Float:length_a = VecLength(vec_a);
	new Float:new_length_a = floatmin(distance_to_check, VecLength(vec_a));
	new Float:length_b = VecLength(vec_b);
	multiply_3d_vector_by_scalar(vec_a, new_length_a / length_a, vec_a);
	multiply_3d_vector_by_scalar(vec_b, new_length_a / length_b, vec_b);
	add_3d_vectors(origin_a, vec_a, aimorigin_a);
	add_3d_vectors(origin_a, vec_b, aimorigin_b);
	aimorigin_b[2] = aimorigin_a[2] = origin_a[2];
	new Float:radians_to_check = angle_convert(fov_to_check * 0.5, false);
	new Float:our_angle = angle_between_vectors_radians(vec_a, vec_b);
	fov_to_store[0] = angle_convert(our_angle, true);
	
	new bool:we_got_em = (our_angle < radians_to_check);
	return we_got_em;
}

stock get_entity_direction_vector_raw(player_id, aimed_at_entity, Float:raw_aim_dir[3]) {
	if (!client_hittable(player_id) || !client_hittable(aimed_at_entity)) {
		return;
	}
	new Float:tg_aim_vector_raw[3];
	new Float:user_aim_vector_raw[3];
	new Float:user_coords[3];
	new Float:tg_coords[3];
	entity_get_vector(player_id, EV_VEC_origin, user_coords)
	entity_get_vector(aimed_at_entity, EV_VEC_origin,tg_coords)
	get_player_aim_vector_raw(player_id, user_aim_vector_raw);
	get_player_aim_vector_raw(aimed_at_entity, tg_aim_vector_raw);
	vector_norm(user_aim_vector_raw, user_aim_vector_raw);
	vector_norm(tg_aim_vector_raw, tg_aim_vector_raw);
	
	add_3d_vectors(tg_aim_vector_raw, tg_coords, tg_coords);
	sub_3d_vectors(tg_coords, user_coords, raw_aim_dir);
	
}

stock get_player_aim_vector_raw(player_id, Float:raw_aim_dir[3]) {
	if (!client_hittable(player_id)) {
		return;
	}
	new Float:user_coords[3];
	entity_get_vector(player_id, EV_VEC_origin,user_coords)
	new user_aimend[3];
	new Float:f_user_aimend[3];
	get_user_origin(player_id, user_aimend,2)
	IVecFVec(user_aimend,f_user_aimend)
	sub_3d_vectors(f_user_aimend, user_coords, raw_aim_dir);
	
}
stock yaw_pitch_roll_vector_to_dir(Float:input_vector[3], Float:output_vector[3],Float:desired_speed=1.0){
	
	output_vector[0]=floatcos(input_vector[0])*floatcos(input_vector[1])
	output_vector[1]=floatsin(input_vector[0])*floatcos(input_vector[1])
	output_vector[2]=-1.0*floatsin(input_vector[0])
	vector_norm(output_vector,output_vector)
	multiply_3d_vector_by_scalar(output_vector,desired_speed,output_vector);
}

stock vector_norm(Float:vec_result[3], Float:vec_in[3]) {
	
	new Float:len = VecLength(vec_in);
	new Float:inv_len = 1.0 / len;
	multiply_3d_vector_by_scalar(vec_result, inv_len, vec_in);
	
}
stock print_vector(Float:vec_in[3]) {
	
	server_print("Vector_print: (%0.2f, %0.2f, %0.2f)^n",vec_in[0],vec_in[1],vec_in[2])
	
}
stock rotate_vector3(Float:vec_result[3], Float:vec_input[3], Float:angle_to_rotate_by_in_radians) {
	
	
	vec_result[0] = floatcos(angle_to_rotate_by_in_radians) * vec_input[0] - floatsin(angle_to_rotate_by_in_radians) * vec_input[1];
	vec_result[1] = floatsin(angle_to_rotate_by_in_radians) * vec_input[0] + floatcos(angle_to_rotate_by_in_radians) * vec_input[1];
	vec_result[2] = vec_input[2];
	
	
	
}
stock projectile_air_drag_update_speed(parm[],Float:drag_const,Float:gravity_mult,Float:phys_update_time){

	

	new pid = parm[0]
	if (!is_valid_ent(pid))
	{
		return
	}
	new Float:speedz,Float:speedx,Float:speedy;
	new Float:velocity[3]
	new Float:velocity_copy[3]
	
	
	entity_get_vector(pid,EV_VEC_velocity,velocity);
	multiply_3d_vector_by_scalar(velocity,1.0,velocity_copy);
	speedx=velocity[0]
	speedy=velocity[1]
	speedz=velocity[2]
	new Float:velocity_num=VecLength(velocity_copy)
	
	new Float:gravity_const=get_cvar_float("sv_gravity")*gravity_mult
	new Float:delta_z=((drag_const*velocity_num*speedz)/gravity_const)*phys_update_time;
	new Float:delta_x=((drag_const*velocity_num*speedx)/gravity_const)*phys_update_time;
	new Float:delta_y=((drag_const*velocity_num*speedy)/gravity_const)*phys_update_time;
	
	speedx-=delta_x
	speedy-=delta_y
	speedz-=delta_z
	velocity_copy[0]=speedx
	velocity_copy[1]=speedy
	velocity_copy[2]=speedz
	entity_set_vector(pid,EV_VEC_velocity,velocity_copy);

}
