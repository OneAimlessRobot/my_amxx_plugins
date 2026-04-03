#if defined sh_aux_natives_pt3
  #endinput
#endif
#define sh_aux_natives_pt3


/////////////////////
//Thantik's he-conc functions
stock get_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
	new Float:fEntOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

	// Velocity = Distance / Time

	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];

	new Float:fTime = ( floatmax(1.0,vector_distance( fEntOrigin,fOrigin )) / fSpeed );
	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;

	return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}


// Sets velocity of an entity (ent) away from origin with speed (speed)

stock set_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
	new Float:fVelocity[3];
	get_velocity_from_origin( ent, fOrigin, fSpeed, fVelocity )

	entity_set_vector( ent, EV_VEC_velocity, fVelocity );

	return ( 1 );
}


native prepare_shero_aux_lib_pt3()
native explosion(hero_id,ent_id,Float:explosion_radius,Float:peak_power,Float:optional_force=0.0,ignore_owner=1,set_stun=0,Float:damage_frac_ignore_owner=SH_DEFAULT_DAMAGE_FRAC_EXPLOSION_IGNORE_OWNER);
native explosion_custom_entity(ent_id,Float:explosion_radius,Float:peak_power,ent_classname[]="player",Float:optional_force=0.0);
native track_user(id,attacker,do_damage=0,damage=40,Float:period,Float:time,track_color=LTBLUE);
native unradioactive_user(id)
native remove_glow_user(id,Float:delay)

native sh_damage_display_stock(hud_msg_sync_vic=-1,hud_msg_sync_att=-1,victim, attacker,bool:att_bool=true,bool:vic_bool=true,damage);

native bool:generic_heal(hud_msg_sync=-1,
					id,
					Float:added_hp,
					max_hp_to_clamp=-1,
					color_const=GREEN,
					user_will_glow=0,
					Float:glow_remove_timer=1.0,
					hud_alpha=-1,
					hud_will_glow=1,
					make_sound=1,
					const sound_sample_buff[128]=SPORE_HEAL_SFX)

native superhero_protected_hud_message(hud_msg_sync=-1,
				id,
				const message_text[SH_HUD_MSG_BUFF_SIZE],
				string[SH_HUD_MSG_BUFF_SIZE]="",
				r=50,
				g=205,
				b=50,
				Float:param1=-1.0,
				Float:param2=0.40,
				param3=2,
				Float:param4=0.02,
				Float:param5=4.0,
				Float:param6=0.01,
				Float:param7=0.1);
