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

	set_pev( ent, pev_velocity, fVelocity );

	return ( 1 );
}


/**

Explosion sfx masks!

*/

enum explosion_sfx_flags (<<= 1){
	explosion_sfx_show_nothing = 0,
	explosion_sfx_show_shockwave = 1,
	explosion_sfx_show_fireball,
	explosion_sfx_show_smoke,
	explosion_sfx_show_burn_decal,
	explosion_sfx_show_custom_sound

}


/** 

Explosion sfx masks!


enum explosion_sfx_flags (<<= 1){
	explosion_sfx_show_nothing = 0,
	explosion_sfx_show_shockwave = 1,
	explosion_sfx_show_fireball,
	explosion_sfx_show_smoke,
	explosion_sfx_show_burn_decal,
	explosion_sfx_show_custom_sound

}

*/
native explosion(hero_id,ent_id,Float:explosion_radius,
					Float:peak_power,
					Float:optional_force=-1.0,
					ignore_owner=1,
					set_stun=0,
					Float:damage_frac_ignore_owner=-1.0,
					explosion_sfx_flags:sfx_mask=(explosion_sfx_show_shockwave|
											explosion_sfx_show_fireball|
											explosion_sfx_show_smoke|
											explosion_sfx_show_burn_decal),
					sh_custom_color:color_const=WHITE,
					const custom_sound_sample[128]=crush_stunned,
					custom_weapon_id=-1);

/*

Explosion sfx masks!


enum explosion_sfx_flags (<<= 1){
	explosion_sfx_show_nothing = 0,
	explosion_sfx_show_shockwave = 1,
	explosion_sfx_show_fireball,
	explosion_sfx_show_smoke,
	explosion_sfx_show_burn_decal,
	explosion_sfx_show_custom_sound

}


*/
/**
Explosion sfx masks!


enum explosion_sfx_flags (<<= 1){
	explosion_sfx_show_nothing = 0,
	explosion_sfx_show_shockwave = 1,
	explosion_sfx_show_fireball,
	explosion_sfx_show_smoke,
  explosion_sfx_show_burn_decal,
	explosion_sfx_show_custom_sound

}

*/
native tank_impact_shot_fx(ent_id, Float:origin[3],radius=18, brightness=200, Float:rel_height= 0.0, bool:show_burndecal = true, bool:show_custom_sound=false, const custom_sound_sample[128] = EXPLOSION_TANK_SHOT_SOUND)


native explosion_custom_entity(ent_id,Float:explosion_radius,
					Float:peak_power,
					ent_classname[]="player",
					Float:optional_force=-1.0,
					explosion_sfx_flags:sfx_mask=(explosion_sfx_show_shockwave|
							explosion_sfx_show_fireball|
							explosion_sfx_show_smoke|
							explosion_sfx_show_burn_decal),

					sh_custom_color:color_const=WHITE,
					const custom_sound_sample[128]=crush_stunned);
