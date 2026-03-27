#if defined sh_aux_funcs_pt2
  #endinput
#endif
#define sh_aux_funcs_pt2
#define MAX_MAP_DIST_POSSIBLE (8192.0*floatsqroot(3.0))


stock ground_z(iOrigin[3], ent, skip = 0, iRecursion = 0) {

	iOrigin[2] += random_num(5, 80);

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
stock superhero_protected_hud_message(id,const message_text[],string[]="",r=50,g=205,b=50,Float:param1=-1.0,Float:param2=0.40, param3=2, Float:param4=0.02, Float:param5=4.0, Float:param6=0.01, Float:param7=0.1){
	if(is_user_connected(id)&&!is_user_bot(id)){
		
		set_hudmessage(r,g,b,param1,param2,param3,param4,param5,param6,param7)
		show_hudmessage(id, message_text,string)
	}

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
stock do_fast_reload(id,iEnt,Float:speed=1.0){
	
	if(!client_hittable(id)){
		return
	}
/*
	static m_pppPlayer            = 41,
			m_iiId                = 43,
			m_fflTimeWeaponIdle        = 48,
			m_ffInReload            = 54,
			m_fflNextAttack = 83*/
	
	if( get_pdata_int(iEnt, m_ffInReload, 4) )
	{
		new Float:fDelay = floatdiv(g_fReloadDelay[get_pdata_int(iEnt, m_iiId, 4)], speed)
		set_pdata_float(get_pdata_cbase(iEnt, m_pppPlayer, 4), m_fflNextAttack, fDelay, 5)
		set_pdata_float(iEnt, m_fflTimeWeaponIdle, fDelay + 0.5, 4)
	}

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
