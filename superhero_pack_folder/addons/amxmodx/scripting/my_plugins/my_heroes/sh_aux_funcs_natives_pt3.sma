#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_BASIC_MACROS
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_damage_sources_inc/sh_damage_sources_aux_code.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define SH_DEFAULT_EXPLODE_FORCE 4.0
stock Float:default_explode_knock_force_magnitude=SH_DEFAULT_EXPLODE_FORCE;


#define SH_DEFAULT_DAMAGE_FRAC_EXPLOSION_IGNORE_OWNER 0.5
stock Float:default_explode_owner_ignore_frac=SH_DEFAULT_DAMAGE_FRAC_EXPLOSION_IGNORE_OWNER;

stock sh_default_explode_knock_force_magnitude_cvar,
	sh_default_explode_owner_ignore_frac_cvar,
	generic_frag_blast_wpn_id = -1

#define PLUGIN "SH_AuxFun3: explosion mngr"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new white, smoke;

new precached_explosion_sprite1,precached_explosion_sprite2

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	sh_default_explode_knock_force_magnitude_cvar = create_cvar("sh_default_explode_knock_force_magnitude","3.0")
	sh_default_explode_owner_ignore_frac_cvar = create_cvar("sh_default_explode_owner_ignore_frac","0.5")
	prepare_shero_aux_lib_pt3()

    
	
}

public plugin_cfg(){

	generic_frag_blast_wpn_id = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_FRAG_BLAST)
}
public plugin_precache(){


	smoke = engfunc(EngFunc_PrecacheModel,"sprites/steam1.spr")
	white = engfunc(EngFunc_PrecacheModel,"sprites/shockwave.spr")
	precached_explosion_sprite1 = engfunc(EngFunc_PrecacheModel,"sprites/explode1.spr")
	precached_explosion_sprite2 = engfunc(EngFunc_PrecacheModel,"sprites/shmod/zerogxplode2.spr")
	
	engfunc(EngFunc_PrecacheSound, crush_stunned)
	engfunc(EngFunc_PrecacheSound, EXPLOSION_TANK_SHOT_SOUND)
}


				
public plugin_natives(){

	register_native("explosion","_explosion");
	register_native("explosion_custom_entity","_explosion_custom_entity");
	register_native("tank_impact_shot_fx","_tank_impact_shot_fx");
}
prepare_shero_aux_lib_pt3(){

	server_print("%s innited!^n",PLUGIN)
}

public _tank_impact_shot_fx(iPlugin,iParms){

		new ent=get_param(1)
		if(!is_valid_ent(ent)) return 
		
		new Float:origin[3]

		get_array_f(2,origin,3)
		new radius=get_param(3)
		
		new brightness= get_param(4)

		new Float:rel_height= get_param_f(5)

		new bool:show_burndecal = bool:get_param(6)

		new bool:make_custom_sound = bool:get_param(7)
		

		new custom_sound_sample[128]

		

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_SPRITE)
		write_coord_f(origin[0])
		write_coord_f(origin[1])
		write_coord_f(origin[2] + rel_height)
		write_short(precached_explosion_sprite2)
		write_byte(radius)
		write_byte(brightness)
		message_end()
		if(make_custom_sound){
			get_string(8,custom_sound_sample,(sizeof custom_sound_sample)-1)


		}
		emit_sound(ent, CHAN_WEAPON,make_custom_sound?custom_sound_sample:EXPLOSION_TANK_SHOT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		if(!show_burndecal){

			return
		}
		new decal_id
		if ( radius <= 18 ) {
			
			decal_id = g_burnDecal[generate_int(0,sizeof(g_burnDecal)-1)]
		}
		else {
			decal_id = g_burnDecalBig[generate_int(0,sizeof(g_burnDecalBig)-1)]
		}

		// Create the burn decal
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)		//TE_GUNSHOTDECAL
		write_coord_f(origin[0])
		write_coord_f(origin[1])
		write_coord_f(origin[2])
		write_short(0)			//?
		write_byte(decal_id)	//decal
		message_end()

}
/*

native explode_fx( vec1[3] ,radius, sh_custom_color:fx_color=WHITE,alpha=255,
            explosion_sfx_flags:sfx_mask=(explosion_sfx_show_shockwave|
                                            explosion_sfx_show_fireball|
                                            explosion_sfx_show_smoke|
                                            explosion_sfx_show_burn_decal))
											*/
//-----------------------------------------------------------------------------------------------

explode_fx( vec1[3] ,radius, sh_custom_color:fx_color=WHITE,alpha=255,
            explosion_sfx_flags:sfx_mask=(explosion_sfx_show_shockwave|
                                            explosion_sfx_show_fireball|
                                            explosion_sfx_show_smoke|
                                            explosion_sfx_show_burn_decal)){


	if((sfx_mask&explosion_sfx_show_shockwave)){
		// blast circles
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
		write_byte( TE_BEAMCYLINDER )
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2] + 16)
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2] + radius*3)
		write_short( white )
		write_byte( 0 ) // startframe
		write_byte( 0 ) // framerate
		write_byte( 2 ) // life 2
		write_byte( 60 ) // width 16
		write_byte( 0 ) // noise
		write_byte( LineColors[fx_color][0] ) // r
		write_byte( LineColors[fx_color][1] ) // g
		write_byte( LineColors[fx_color][2]  ) // b
		write_byte( alpha ) //brightness
		write_byte( 0 ) // speed
		message_end()
	}

	if((sfx_mask&explosion_sfx_show_fireball)){
		static TE_FLAG = 0

		TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
		TE_FLAG |= ((sfx_mask&explosion_sfx_show_custom_sound)?TE_EXPLFLAG_NOSOUND:0)
		TE_FLAG |= TE_EXPLFLAG_NOPARTICLES

		//TE_Explosion
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
		write_byte( TE_EXPLOSION )
		write_coord(vec1[0] + generate_int( -100, 100 ))
		write_coord(vec1[1] + generate_int( -100, 100 ))
		write_coord(vec1[2]+ generate_int( -50, 50 ))
		write_short( precached_explosion_sprite1 )
		write_byte(  radius/9  ) // byte (scale in 0.1's) 188
		write_byte( 12 ) // byte (framerate)
		write_byte( TE_FLAG ) // byte flags
		message_end()
	}
	if((sfx_mask&explosion_sfx_show_smoke)){
		//Smoke
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
		write_byte( TE_SMOKE  ) // 5
		write_coord(vec1[0] + generate_int( -100, 100 ))
		write_coord(vec1[1] + generate_int( -100, 100 ))
		write_coord(vec1[2] + generate_int( -50, 50 ))
		write_short( smoke )
		write_byte( radius/14 )  // 2
		write_byte( 10 )  // 10
		message_end()
	}
	if((sfx_mask&explosion_sfx_show_burn_decal)){
	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)		// decal and ricochet sound
		write_coord(vec1[0])	// pos
		write_coord(vec1[1])
		write_coord(vec1[2])
		write_short(0)			// I have no idea what thats supposed to be
		write_byte(g_burnDecalBig[0])			// decal
		message_end()
	}
}
public _explosion(iPlugins,iParams){


	new hero_id=get_param(1),
		ent_id=get_param(2),
		Float:explosion_radius=get_param_f(3),
		Float:peak_power=get_param_f(4),
		Float:optional_force=get_param_f(5),
		ignore_owner=get_param(6),
		set_stun=get_param(7),
		Float:damage_frac_ignore_owner=get_param_f(8),
		explosion_sfx_flags:sfx_mask=explosion_sfx_flags:get_param(9),
		sh_custom_color:fx_color=sh_custom_color:get_param(10)

	if(optional_force < 0.0){

		optional_force = get_pcvar_float(sh_default_explode_knock_force_magnitude_cvar);
	}
	if(damage_frac_ignore_owner < 0.0){

		damage_frac_ignore_owner = get_pcvar_float(sh_default_explode_owner_ignore_frac_cvar)
	}
	new custom_sound_sample[128]

	get_string(11,custom_sound_sample,(sizeof custom_sound_sample)-1)

	new custom_weapon_id = get_param(12)

	if((pev_valid(ent_id)!=2)){

		return 

	}
	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);

	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);

	if(sfx_mask>explosion_sfx_show_nothing){
		explode_fx(iOrigin,floatround(explosion_radius),fx_color,_,sfx_mask)
		if((sfx_mask & explosion_sfx_show_custom_sound)){
			emit_sound(ent_id, CHAN_VOICE, custom_sound_sample, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	new entlist[33];
	new numfound = find_sphere_class(ent_id,"player", explosion_radius ,entlist, 32);
	new owner_id=((is_user_connected(ent_id))?ent_id:entity_get_edict(ent_id,EV_ENT_owner))

	if(!is_user_connected(owner_id)){
		return
	}
	new CsTeams:idTeam = cs_get_user_team(owner_id)
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		if(!is_user_alive(pid)){
			continue
		
		}
		if(pid!=owner_id){
			if(cs_get_user_team(pid)==idTeam){
				continue
			}
			sh_screen_shake(pid,10.0,3.0,10.0)
		}
		else if(ignore_owner){
			continue
		}
		damage_player(hero_id,ent_id,owner_id,pid,explosion_radius,peak_power,optional_force,set_stun,damage_frac_ignore_owner,custom_weapon_id)

	}
}
public _explosion_custom_entity(iPlugins,iParams){

	new ent_classname[128]

	get_string(4,ent_classname,128)

	new ent_id=get_param(1),
		Float:explosion_radius=get_param_f(2),
		Float:peak_power=get_param_f(3),
		Float:optional_force=get_param_f(5),
		explosion_sfx_flags:sfx_mask= explosion_sfx_flags:get_param(6),
		sh_custom_color:fx_color=sh_custom_color:get_param(7)

	new custom_sound_sample[128]

	get_string(8,custom_sound_sample,(sizeof custom_sound_sample)-1)

	if((pev_valid(ent_id)!=2)){

		return 

	}

	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);

	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);

	if(sfx_mask>explosion_sfx_show_nothing){
		explode_fx(iOrigin,floatround(explosion_radius),fx_color,_,sfx_mask)
		if((sfx_mask & explosion_sfx_show_custom_sound)){
			emit_sound(ent_id, CHAN_VOICE, custom_sound_sample, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}

	new entlist[33];
	new numfound = find_sphere_class(ent_id,ent_classname, explosion_radius ,entlist, 32);

	new owner_id=entity_get_edict(ent_id,EV_ENT_owner)
	for (new i=0; i < numfound; i++)
	{		
		new eid = entlist[i];
		
		if(!is_valid_ent(eid)){
			
			continue;
		}
		if(pev_valid(eid)!=2){
			continue
		
		}
		damage_entity(ent_id,owner_id,eid,explosion_radius,peak_power,_,optional_force)
	}
}
damage_player(hero_id,ent_id,owner_id,pid,Float:radius,Float:peak_power,Float:optional_force=0.0,set_stun=0,Float:damage_frac_ignore_owner=SH_DEFAULT_DAMAGE_FRAC_EXPLOSION_IGNORE_OWNER,custom_weapon_id=-1){
	
	
	if((pev_valid(ent_id)!=2)){
	
		return 
	
	}
	if(!is_user_connected(owner_id)){
	
		return 
	
	}
	if(!is_user_connected(pid)){
	
		return 
	
	}
	if(is_user_connected(pid)&&(pid==owner_id)){
		

		peak_power=peak_power*damage_frac_ignore_owner
		
		
	
	}
	static client_name[128];
	static attacker_name[128];
	get_user_name(pid,client_name,127);
	get_user_name(owner_id,attacker_name,127);
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(pid,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	new Float:distance=vector_distance(vic_origin,mine_origin);
	new Float:falloff_coeff= min_macro(1.0,distance/radius);
	new Float:force,Float:damage,idamage
	damage=peak_power-(peak_power/2.0)*falloff_coeff
	idamage=floatround(damage)
	if(optional_force!=(0.0*float(hero_id))){ 
		//im a perfectionist.
		//Im not using this variable.
		//and warnings annoy me. 
		//So it gets converted into a float
		//and multiplied by zero
		force=optional_force-(optional_force/2.0)*falloff_coeff
	}
	else{
		force=damage
	}

	if(!is_valid_custom_dmg_source(custom_weapon_id)){
	
		custom_weapon_id=generic_frag_blast_wpn_id
	
	}
	
	sh_extra_damage(pid,owner_id,idamage,
			_,_,_,_,_,
			SH_NEW_DMG_FRAG_BLAST,
			custom_weapon_id)
	
	set_velocity_from_origin(pid,mine_origin,force)

	if(set_stun){
		sh_set_stun(pid,3.0)
		sh_screen_shake(pid,10.0,3.0,10.0)
	}
	
	unfade_screen_user(pid)
}
damage_entity(ent_id,owner_id,tg_id,Float:radius,Float:peak_power,ignore_owner=1,Float:optional_force=0.0){


	if((pev_valid(ent_id)!=2)||(pev_valid(tg_id)!=2)){
	
		return 
	
	}
	
	if(is_user_connected(tg_id)&&(tg_id==owner_id)){
		
		if(ignore_owner){
			
			return
			
		}
		
		
	
	}
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(tg_id,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	new Float:distance=vector_distance(vic_origin,mine_origin);
	new Float:falloff_coeff= min_macro(1.0,distance/radius);
	new Float:force,Float:damage
	damage=peak_power-(peak_power/2.0)*falloff_coeff
	if(optional_force!=0.0){
		force=optional_force-(optional_force/2.0)*falloff_coeff
	}
	else{
		force=damage
	}
	if(is_user_alive(owner_id)||(is_user_alive(ent_id))){

		ExecuteHam(Ham_TakeDamage, tg_id, ent_id, owner_id, damage, 0);
	}
	if(entity_get_float(tg_id,EV_FL_health)<=0.0){
		return
	}
	if(!is_valid_ent(tg_id)){
		
		return;
	}
	if(pev_valid(tg_id)!=2){
		
		return
	
	}
	set_velocity_from_origin(tg_id,mine_origin,force)
	
}

