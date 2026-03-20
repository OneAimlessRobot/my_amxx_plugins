#if defined sh_aux_natives_pt3
  #endinput
#endif
#define sh_aux_natives_pt3



//----------------------------------------------------------------------------------------------
stock move_enemy(parm[])
{
	new victim = parm[3]
	
	new Float:origin[3]
	
	pev(victim,pev_origin,origin)
	
	origin[2]+=float(parm[4])
	
	set_pev(victim,pev_origin,origin)
	
	new Float:fl_velocity[3]
	fl_velocity[0] = float(parm[0])
	fl_velocity[1] = float(parm[1])
	fl_velocity[2] = float(parm[2])
	
	set_pev(victim, pev_velocity, fl_velocity)
	
}
stock move_entity(parm[])
{
	new victim = parm[3]
	
	new Float:origin[3]
	
	if(!is_valid_ent(victim)){
		
		return;
	}
	if((pev_valid(victim)!=2)){
	
		return 
	
	}
	pev(victim,pev_origin,origin)
	
	origin[2]+=float(parm[4])
	
	set_pev(victim,pev_origin,origin)
	
	new Float:fl_velocity[3]
	fl_velocity[0] = float(parm[0])
	fl_velocity[1] = float(parm[1])
	fl_velocity[2] = float(parm[2])
	
	set_pev(victim, pev_velocity, fl_velocity)
	
}


native prepare_shero_aux_lib_pt3()
native explosion_player(hero_id,ent_id,Float:explosion_radius,Float:peak_power,Float:optional_force=0.0,ignore_owner=0,set_stun=0,Float:upward_shift=1.0,Float:damage_frac_ignore_owner=SH_DEFAULT_DAMAGE_FRAC_EXPLOSION_IGNORE_OWNER);
native explosion(hero_id,ent_id,Float:explosion_radius,Float:peak_power,Float:optional_force=0.0,ignore_owner=1,set_stun=0,Float:upward_shift=1.0,Float:damage_frac_ignore_owner=SH_DEFAULT_DAMAGE_FRAC_EXPLOSION_IGNORE_OWNER);
native explosion_custom_entity(ent_id,Float:explosion_radius,Float:peak_power,ent_classname[]="player",Float:optional_force=0.0,Float:upward_shift=1.0);
native track_user(id,attacker,do_damage=0,damage=40,Float:period,Float:time,track_color=LTBLUE);
native unradioactive_user(id)

native sh_damage_display_stock(victim, attacker,bool:att_bool=true,bool:vic_bool=true,damage);
