#if defined sh_aux_funcs_misc
  #endinput
#endif
#define sh_aux_funcs_misc
#define MAX_MAP_DIST_POSSIBLE (8192.0*floatsqroot(3.0))

#define SH_HUD_MSG_BUFF_SIZE 128

#define ALPHA_PCT_CALC_FROM_RENDER_MODE_AND_AMT(%1,%2) ((%1==kRenderTransAlpha)?floatround(100.0*(1.0-(%2/255.0))):0)

stock sh_get_player_cloak_pct(id){

	new Float:real_alpha,  render_mode

	real_alpha=entity_get_float(id, EV_FL_renderamt)
	render_mode=entity_get_int(id, EV_INT_rendermode)

	return ALPHA_PCT_CALC_FROM_RENDER_MODE_AND_AMT(render_mode,real_alpha)

}
stock attacker_dmg_hud_msg_sync, victim_dmg_hud_msg_sync, heal_hp_hud_msg_sync, superhero_hud_msg_sync

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
	
	if (!client_hittable(id)||!sh_is_active()) return 0
	//Its an ""entlist""
	new entlist[1];
	new num_found = find_sphere_class(id,the_entity_classname_to_search, touch_distance ,entlist, 1);
	
	if(!num_found){
		
		return 0
	}
	
	return entlist[0]
}
stock do_fast_shot(id,wpnid,Float:speed=1.0){
	
	if(!client_hittable(id)){
		return
	}
	static Float:N_Speed
	N_Speed =speed
	if(N_Speed != 1.0)
	{
		static weapon[32],Ent
		get_weaponname(wpnid,weapon,31)
		Ent = fm_find_ent_by_owner(-1,weapon,id)
		if(Ent)
		{
			if(pev_valid(Ent)!=2){

				server_print("Hook faulty??!!! attempted to change firing speed of invalid weapon!^n")

			}
			static Float:Delay,Float:M_Delay
			Delay =floatdiv(get_pdata_float( Ent, 46, 4) ,N_Speed)
			M_Delay =floatdiv(get_pdata_float( Ent, 47, 4) ,N_Speed)
			if (Delay > 0.0)
			{
				set_pdata_float( Ent, 46, Delay, 4)
				set_pdata_float( Ent, 47, M_Delay, 4)
			}
		}
	}

}

#if !defined _reapi_included 
stock do_fast_reload(id,iEnt,Float:speed=1.0){
	
	if(!client_hittable(id)){
		return
	}
	if( get_pdata_int(iEnt, m_fInReload, 4) )
	{
		new Float:fDelay = floatdiv(g_fReloadDelay[get_pdata_int(iEnt, m_iId, 4)], speed)
		set_pdata_float(get_pdata_cbase(iEnt, m_pPlayer, 4), m_flNextAttack, fDelay, 5)
		set_pdata_float(iEnt, m_flTimeWeaponIdle, fDelay + 0.5, 4)
	}

}
#else
stock do_fast_reload(id,iEnt,Float:speed=1.0){
	
	if(!client_hittable(id)){
		return
	}
	if( get_pdata_int(iEnt, m_fInReload, 4) )
	{
		new Float:fDelay = floatdiv(g_fReloadDelay[get_pdata_int(iEnt, _:m_iId, 4)], speed)
		set_pdata_float(get_pdata_cbase(iEnt, _:m_pPlayer, 4), _:m_flNextAttack, fDelay, 5)
		set_pdata_float(iEnt, _:m_flTimeWeaponIdle, fDelay + 0.5, 4)
	}

}
#endif
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

public orient_user(id,Float:angles[3],Float:v_angle[3])
{
	
	if(!client_hittable(id)){
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
