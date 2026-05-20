#if defined sh_aux_funcs_misc
  #endinput
#endif
#define sh_aux_funcs_misc


#define ALPHA_PCT_CALC_FROM_RENDER_MODE_AND_AMT(%1,%2) (((%1==kRenderTransAlpha)||(%1==kRenderTransColor))?floatround(100.0*(1.0-(%2/255.0))):0)


stock g_msgBarTime

/*

only exec in plugin_init() forward!
the var which will be initialized is
the "g_msgBarTime" variable.
The entire code of this function is:

stock g_msgBarTime

stock init_progress_bar_msg_var(){

	g_msgBarTime = get_user_msgid("BarTime")
}

It is located in the sh_aux_funcs_misc.inc header

This is meant to setup the "progressBar" stock

Its entire code is just:

stock progressBar(id, seconds)
{
	message_begin(MSG_ONE, g_msgBarTime, {0,0,0}, id)
	write_byte(seconds)
	write_byte(0)
	message_end()
}


*/
stock init_progress_bar_msg_var(){

	g_msgBarTime = get_user_msgid("BarTime")
}
//----------------------------------------------------------------------------------------------
stock progressBar(id, seconds)
{
	message_begin(MSG_ONE, g_msgBarTime, {0,0,0}, id)
	write_byte(seconds)
	write_byte(0)
	message_end()
}

stock Eject_Shell(id, Shell_ModelIndex, Float:Time) // By Dias
{
	static Ent; Ent = get_pdata_cbase(id, m_pActiveItem, XTRA_OFS_PLAYER)
	if(!pev_valid(Ent))
		return

	set_pdata_int(Ent, m_iShellId, Shell_ModelIndex, XO_WEAPON)
	set_pdata_float(id, m_flEjectBrass, get_gametime() + Time, XTRA_OFS_PLAYER)
}
stock native_playanim(id,anim)
{	
	if(!is_user_alive(id)){
		return
	}
	set_pev(id, pev_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}
/**
only use this at plugin_init forward!!!
*/
stock register_entity_as_wall_touchable(const entity_name[], const func_name[]){

	for( new i; i < sizeof szWallEntities; i++ ){
		register_touch( entity_name, szWallEntities[ i ], func_name );
	}
}
/**
this one maps an entity to multiple others
in a parameter sized array
to a SINGLE FUNCTION!
*/
stock register_custom_touchable(const entity_name[], const func_name[], const tg_entities[][], tg_entities_length){

	for( new i; i < tg_entities_length; i++ ){
		register_touch( entity_name, tg_entities[ i ], func_name );
	}
}
stock attacker_dmg_hud_msg_sync, victim_dmg_hud_msg_sync, heal_hp_hud_msg_sync, superhero_hud_msg_sync

stock sh_get_player_cloak_pct(id){

	new Float:real_alpha,  render_mode

	real_alpha=entity_get_float(id, EV_FL_renderamt)
	render_mode=entity_get_int(id, EV_INT_rendermode)

	return ALPHA_PCT_CALC_FROM_RENDER_MODE_AND_AMT(render_mode,real_alpha)

}
stock ground_z(iOrigin[3], ent, skip = 0, iRecursion = 0) {

	iOrigin[2] += generate_int(5, 80);

	if (!pev_valid(ent)) {
		return iOrigin[2];
	}

	new Float:fOrigin[3];
	IVecFVec(iOrigin, fOrigin);
	set_pev(ent, pev_origin, fOrigin);
	engfunc(EngFunc_DropToFloor, ent);

	if (!skip && !engfunc(EngFunc_EntIsOnFloor, ent)) {
		if (iRecursion >= ANTI_LAGG) {
			skip = 1;
		}

		return ground_z(iOrigin, ent, skip, ++iRecursion);
	}

	pev(ent, pev_origin, fOrigin);

	return floatround(fOrigin[2]);
}

stock player_touching_entity_of_some_classname(id,the_entity_classname_to_search[],Float:touch_distance=50.0)
{
	
	if (!is_user_alive(id)||!sh_is_active()) return 0
	//Its an ""entlist""
	new entlist[1];
	new num_found = find_sphere_class(id,the_entity_classname_to_search, touch_distance ,entlist, 1);
	
	if(!num_found){
		
		return 0
	}
	
	return entlist[0]
}

stock Float:calculate_nuanced_projectile_damage(bull_et,
				Float:bullet_launch_pos[3],
				Float:base_damage,
				Float:falloff_distance,
				Float:peak_projectile_speed,
				&Float:distance = 0.0,
				&Float:falloff_coeff = 0.0){

	static Float:velocity[3],
		Float:hitter_origin[3],
		Float:speed_coeff,
		Float:speed,
		Float:normal_damage,
		Float:damage
				
	entity_get_vector(bull_et,EV_VEC_origin,hitter_origin)
	entity_get_vector(bull_et,EV_VEC_velocity,velocity);
	speed_coeff=(speed/peak_projectile_speed)
	speed=vector_length(velocity);
	distance=vector_distance(hitter_origin,bullet_launch_pos);
	falloff_coeff= floatmin(1.0,distance/falloff_distance);
	normal_damage=base_damage-(35.0*falloff_coeff);
	damage=normal_damage*speed_coeff;

	return damage
}

stock my_hitpoint_enum:get_projectile_hit_hitpoint(hitting_entity,
				Float:velocity[3],
				Float:threshold_distance_for_hit,
				Float:projectile_speed){

	static Float:trace_vector_direction[3],
		Float:trace_vector_end[3],
		Float:hitter_origin[3]

	entity_get_vector(hitting_entity,EV_VEC_origin,hitter_origin)
	new tr_handle=create_tr2()
	multiply_3d_vector_by_scalar(velocity,
					(threshold_distance_for_hit)/projectile_speed,
					trace_vector_direction)
	
	add_3d_vectors(hitter_origin,trace_vector_direction,trace_vector_end)
	
	engfunc(EngFunc_TraceLine,
		hitter_origin,
		trace_vector_end,
		0,
		hitting_entity,
		tr_handle
	)
	new my_hitpoint_enum:hitpoint =
				my_hitpoint_enum:get_tr2(tr_handle, TR_iHitgroup)
	
	free_tr2(tr_handle)

	return hitpoint;
}
stock orient_entity_with_move_vector(ent){


	static Float:fl_NewAngle[3],Float:fl_Velocity[3]
	entity_get_vector(ent,EV_VEC_velocity,fl_Velocity)
	vector_to_angle(fl_Velocity, fl_NewAngle)
	entity_set_vector(ent, EV_VEC_angles, fl_NewAngle)
	entity_set_vector(ent, EV_VEC_v_angle, fl_NewAngle)

}
stock do_fast_shot(Ent,Float:speed=1.0){
	
	static Float:N_Speed
	N_Speed =speed
	if(N_Speed != 1.0)
	{
		if(pev_valid(Ent)!=2){

			server_print("Hook faulty??!!! attempted to change firing speed of invalid weapon!^n")
			return HAM_IGNORED
		}
		ExecuteHam(Ham_Weapon_PrimaryAttack, Ent)
		if(get_pdata_int(Ent, m_iClip, XO_WEAPON)<=0){

			return HAM_SUPERCEDE
		}
		static Float:Delay,Float:M_Delay
		Delay =floatdiv(g_fPrimaryAttackDelay[get_pdata_int(Ent, m_iId, XO_WEAPON)] ,N_Speed)
		M_Delay =floatdiv(g_fSecondaryAttackDelay[get_pdata_int(Ent, m_iId, XO_WEAPON)]  ,N_Speed)

		if (Delay > 0.0)
		{
			set_pdata_float( Ent, m_flNextPrimaryAttack, Delay, XO_WEAPON)
		}
		if (M_Delay > 0.0)
		{
			set_pdata_float( Ent, m_flNextSecondaryAttack, M_Delay, XO_WEAPON)
		}
	}
	return HAM_SUPERCEDE

}

#if !defined _reapi_included 
stock do_fast_reload(id,iEnt,Float:speed=1.0){
	
	if(!is_user_alive(id)){
		return
	}
	if(get_pdata_int(iEnt, m_fInSpecialReload, XO_WEAPON) ){

		return

	}
	if( get_pdata_int(iEnt, m_fInReload, XO_WEAPON) )
	{
		new Float:fDelay = floatdiv(g_fReloadDelay[get_pdata_int(iEnt, m_iId, XO_WEAPON)], speed)
		set_pdata_float(id, m_flNextAttack, fDelay, OFFSET_LINUX_PLAYER)
		set_pdata_float(iEnt, m_flTimeWeaponIdle, fDelay + 0.5, XO_WEAPON)
	}
}
#else
stock do_fast_reload(id,iEnt,Float:speed=1.0){
	
	if(!is_user_alive(id)){
		return
	}
	if( get_pdata_int(iEnt, m_fInReload) )
	{
		new Float:fDelay = floatdiv(g_fReloadDelay[get_member(iEnt, m_iId)], speed)
		set_member(id, m_flNextAttack, fDelay)
		set_member(iEnt, m_flTimeWeaponIdle, fDelay + 0.5)
	}


}
#endif

//get weapon id entity of player
stock get_weapon_ent_of_player(id,wpnid=0)
{	
	new weap = wpnid;
	if (!weap && !(weap = get_user_weapon(id)))
		return 0;
	
	static class[32];
	get_weaponname(weap, class, sizeof class - 1);

	return find_ent_by_owner(-1,class,id);
} 
/**
exclude mode == 0 for include guns outside of the bitsum. 1 to include only those on the bitsum
*/
stock register_ham_for_weapon_bitsum(Ham:ham_constant,weapon_bitsum,const function_name[],is_it_post=0, bool:is_it_special_bot=true, bool:exclude_mode=false){
	
	new bit_sum_to_actually_do = exclude_mode ? (~(weapon_bitsum)): (weapon_bitsum)
	for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
	{	
		new bool:do_eht= bool:((bit_sum_to_actually_do & (1<<wpnId)))
		if ( do_eht && (strlen(weapon_names_stock_arr[wpnId])>0))
		{
				RegisterHam(ham_constant, weapon_names_stock_arr[wpnId], function_name, is_it_post,is_it_special_bot) 
		}
	}
}

stock init_hud_syncs(){

	attacker_dmg_hud_msg_sync=CreateHudSyncObj()
	victim_dmg_hud_msg_sync=CreateHudSyncObj()
	heal_hp_hud_msg_sync=CreateHudSyncObj()
	superhero_hud_msg_sync=CreateHudSyncObj()


}
stock init_explosion_defaults(){

	default_explode_knock_force_magnitude=sh_get_max_force_knockback_explosion()
	default_explode_owner_ignore_frac=sh_get_default_explode_owner_ignore_frac()
	default_stun_speed=sh_get_default_stun_speed()

}
stock bool:is_entity_brush(ent_id){
	if(!is_valid_ent(ent_id)){

		return false
	}

	if(!ent_id){

		return true
	}
	static model_name[48]

	entity_get_string(ent_id, EV_SZ_model, model_name, charsmax(model_name))
	if( contain(model_name, "*") != -1 ) {
		return true
	}

	return false
}
public orient_user(id,Float:angles[3],Float:v_angle[3])
{
	
	if(!is_user_alive(id)){
		return
	}
	entity_set_int( id, EV_INT_fixangle, 0 );
	entity_set_vector(id, EV_VEC_v_angle,v_angle)
	entity_set_vector(id, EV_VEC_angles,angles)
	entity_set_int( id, EV_INT_fixangle, 1 );

}
stock Float:get_entity_velocity(ent){
	if(pev_valid(ent)!=2){

		return -1.0
	}

	new Float:velocity_vector[3]
	pev(ent,pev_velocity,velocity_vector)
	return vector_length(velocity_vector)


}
stock kill_all_entity_beams(ent_id){
	if(pev_valid(ent_id)==2){

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin
		write_byte(TE_KILLBEAM)
		write_short(ent_id) // entity
		message_end()
	}
}
