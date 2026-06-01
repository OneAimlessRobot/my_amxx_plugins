//Forge - 	1.x update by heliumdream
//				recode based on Missiles Launcher 3.8.2 (amx_ejl_missiles.sma)
//				by Eric Lidman & jtp10181

/*
//Forge
Forge_cooldown 6 		//How long it takes Forge to reload
Forge_damage 80			//How much damage will be dealt (According to how far away missile is)
Forge_velocity 2000		//Speed of Forge's missile
Forge_force 500.0		//How much player hit by missile will fly up into the air with
Forge_radius 400		//The radius from where missile hit people will be damaged
Forge_obeygravity 0		//Makes missile obey server gravity rules 1 -yes, 0 - no
Forge_effects 2			//1 Regualy missile, no effects
						//2 Yellow sprites around missile - laggy
						//3 Light given off around missile
						//4 2 & 3 combined								
*/


#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS

#include "../my_include/superheromod.inc"
#include "../my_heroes/sh_aux_stuff/sh_aux_inc.inc"

new gHeroName[]="Forge"
new gHeroID

new beam, sprite1, sprite2, sprite3
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Forge", "1.0", "SRGrty")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	create_cvar("Forge_level", "7")
	create_cvar("Forge_cooldown", "20.0")
	create_cvar("Forge_damage", "40")
	create_cvar("Forge_velocity", "2000")
	create_cvar("Forge_force", "500.0")		//cannot get this to function properly.
	create_cvar("Forge_radius", "400")
	create_cvar("Forge_obeygravity", "1")	
	create_cvar("Forge_effects", "4")

	gHeroID=shCreateHero(gHeroName, "Missiles", "Fires Concussion Missiles to blow people up!", true, "Forge_level")

	register_entity_as_wall_touchable("concussion_missile","missile_touch")
	register_custom_touchable("concussion_missile","missile_touch",player_vector,1)


}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		Forge_kd(id)
	}
}
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public Forge_kd(id)
{
	if ( !hasRoundStarted() ) return PLUGIN_HANDLED

	if ( !is_user_alive(id) || !sh_get_user_has_hero(id,gHeroID) ) return PLUGIN_HANDLED
	if ( sh_get_cooldown_flag(id)) {
		sh_sound_deny(id)
		return PLUGIN_HANDLED
	}

	make_beam(id)
	sh_set_cooldown(id, get_cvar_float("Forge_cooldown") * 1.0 )

	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	beam = engfunc(EngFunc_PrecacheModel,"sprites/smoke.spr")
	sprite1 = engfunc(EngFunc_PrecacheModel,"sprites/fire.spr")
	sprite2 = engfunc(EngFunc_PrecacheModel,"sprites/explode1.spr")
	sprite3 = engfunc(EngFunc_PrecacheModel,"sprites/steam1.spr")

	engfunc(EngFunc_PrecacheModel,"models/rpgrocket.mdl")

	engfunc(EngFunc_PrecacheSound,"weapons/rocketfire1.wav")
	engfunc(EngFunc_PrecacheSound,"weapons/rocket1.wav")	
}
public missile_touch(pToucher, pTouched) {

	if ( !is_valid_ent(pToucher) ) return

	new damradius = get_cvar_num("Forge_radius")
	new maxdamage = get_cvar_num("Forge_damage")

	if (damradius <= 0) {
		debugMessage("(Forge) Damage Radius must be set higher than 0, defaulting to 240",0,0)
		damradius = 240
		set_cvar_num("Forge_radius",damradius)
	}
	if (maxdamage <= 0) {
		debugMessage("(Forge) Max Damage must be set higher than 0, defaulting to 14",0,0)
		maxdamage = 14
		set_cvar_num("Forge_damage",maxdamage)
	}

	remove_task(pToucher)
	new Float:fl_vExplodeAt[3]
	entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
	new vExplodeAt[3]
	vExplodeAt[0] = floatround(fl_vExplodeAt[0])
	vExplodeAt[1] = floatround(fl_vExplodeAt[1])
	vExplodeAt[2] = floatround(fl_vExplodeAt[2])
	new id = entity_get_edict(pToucher, EV_ENT_owner)
	new origin[3],dist,i,Float:dRatio,damage

	for ( i = 1; i < sh_maxplayers()+1; i++) {

		if( !is_user_alive(i) ) continue
		get_user_origin(i,origin)
		dist = get_distance(origin,vExplodeAt)
		if (dist <= damradius) {

			dRatio = floatdiv(float(dist),float(damradius))
			damage = maxdamage - floatround( maxdamage * dRatio)

			sh_extra_damage(i, id, damage)

			new Float: force = get_cvar_float("Forge_force")
								
			new Float:fl_vicVelocity[3]

			fl_vicVelocity[0] = 0.0 
			fl_vicVelocity[1] = 0.0
			fl_vicVelocity[2] = force - (force * dRatio)

			set_pev(i, pev_velocity, fl_vicVelocity)

		}
	}
	emit_sound(pToucher, CHAN_WEAPON, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(pToucher, CHAN_VOICE, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	forge_boom(vExplodeAt)

	remove_entity(pToucher)

	if ( is_valid_ent(pTouched) ) {
		new szClassName2[32]
		entity_get_string(pTouched, EV_SZ_classname, szClassName2, 31)

		if(equal(szClassName2, "concussion_missile")) {
			remove_task(pTouched)
			emit_sound(pTouched, CHAN_WEAPON, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(pTouched, CHAN_VOICE, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			remove_entity(pTouched)
		}
	}
}
//----------------------------------------------------------------------------------------------
public forge_boom(Explorigin[])
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 21 )
	write_coord(Explorigin[0])
	write_coord(Explorigin[1])
	write_coord(Explorigin[2] + 16)
	write_coord(Explorigin[0])
	write_coord(Explorigin[1])
	write_coord(Explorigin[2] + 1936)
	write_short( sprite1 )
	write_byte( 0 )
	write_byte( 0 )
	write_byte( 2 )
	write_byte( 128 )
	write_byte( 0 )
	write_byte( 188 )
	write_byte( 220 )
	write_byte( 255 )
	write_byte( 255 )
	write_byte( 0 )
	message_end()

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 3 )
	write_coord(Explorigin[0])
	write_coord(Explorigin[1])
	write_coord(Explorigin[2])
	write_short( sprite2 )
	write_byte( 60 )
	write_byte( 10 )
	write_byte( 0 )
	message_end()

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 5 )
	write_coord(Explorigin[0])
	write_coord(Explorigin[1])
	write_coord(Explorigin[2])
	write_short( sprite3 )
	write_byte( 10 )
	write_byte( 10 )
	message_end()
}
//----------------------------------------------------------------------------------------------
public make_beam(id)
{
	new args[2]
	new Float:vOrigin[3]
	new Float:vAngles[3]
	entity_get_vector(id, EV_VEC_origin, vOrigin)
	entity_get_vector(id, EV_VEC_v_angle, vAngles)
	//new notFloat_vOrigin[3]
	//notFloat_vOrigin[0] = floatround(vOrigin[0])
	//notFloat_vOrigin[1] = floatround(vOrigin[1])
	//notFloat_vOrigin[2] = floatround(vOrigin[2])

	new NewEnt
	NewEnt = create_entity("info_target")
	if(NewEnt == 0) {
		client_print(id,print_chat,"[SH](Forge) Rocket Failure")
		return PLUGIN_HANDLED
	}

	entity_set_string(NewEnt, EV_SZ_classname, "concussion_missile")
	entity_set_model(NewEnt, "models/rpgrocket.mdl")

	new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
	new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}

	entity_set_vector(NewEnt, EV_VEC_mins,fl_vecminsx)
	entity_set_vector(NewEnt, EV_VEC_maxs,fl_vecmaxsx)

	entity_set_origin(NewEnt, vOrigin)
	entity_set_vector(NewEnt, EV_VEC_angles, vAngles)	
	entity_set_int(NewEnt, EV_INT_solid, 2)
	//entity_set_int(NewEnt, EV_INT_effects, 64)

	new effects = get_cvar_num("Forge_effects")	

	if ( effects == 1 ){ // normal
		entity_set_int(NewEnt, EV_INT_effects, 2)
	}
	else if ( effects == 2 ){ // sprites (yellow) arround missile
		entity_set_int(NewEnt, EV_INT_effects, 4)
	}
	else if ( effects == 3 ){ // light around missile
		entity_set_int(NewEnt, EV_INT_effects, 1)
	}
	else if ( effects == 4 ){ // both light and sprites around missle (default)
		entity_set_int(NewEnt, EV_INT_effects, 7)
	}
	else {
		entity_set_int(NewEnt, EV_INT_effects, 64)
	}

	if(get_cvar_num("Forge_obeygravity")) {
		entity_set_int(NewEnt, EV_INT_movetype, 6)
	}
	else {
		entity_set_int(NewEnt, EV_INT_movetype, 5)
	}

	entity_set_edict(NewEnt, EV_ENT_owner, id)
	entity_set_float(NewEnt, EV_FL_health, 10000.0)
	entity_set_float(NewEnt, EV_FL_takedamage, 100.0)
	entity_set_float(NewEnt, EV_FL_dmg_take, 100.0)

	new MissileVel = get_cvar_num("Forge_velocity")
	new Float:fl_iNewVelocity[3]
	//new iNewVelocity[3]
	velocity_by_aim(id, MissileVel, fl_iNewVelocity)
	entity_set_vector(NewEnt, EV_VEC_velocity, fl_iNewVelocity)
	//iNewVelocity[0] = floatround(fl_iNewVelocity[0])
	//iNewVelocity[1] = floatround(fl_iNewVelocity[1])
	//iNewVelocity[2] = floatround(fl_iNewVelocity[2])

	emit_sound(NewEnt, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(NewEnt, CHAN_VOICE, "weapons/rocket1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	args[0] = id
	args[1] = NewEnt

	make_trail(NewEnt)
	entity_set_float(NewEnt, EV_FL_gravity, 0.25)
	set_task(0.1,"guide_rocket_comm",NewEnt,args,2,"b")
	//set_task(get_cvar_float("bazooka_fuel"),"rocket_fuel_timer",NewEnt,args,16)

	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
make_trail(NewEnt)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)
	write_short(NewEnt)
	write_short(beam)
	write_byte(45)
	write_byte(4)
	write_byte(254)
	write_byte(254)
	write_byte(254)
	write_byte(100)
	message_end()
}
//----------------------------------------------------------------------------------------------
public guide_rocket_comm(args[])
{
	new ent = args[1]
	if (!is_valid_ent(ent)) return
	new Float:missile_health = entity_get_float(ent, EV_FL_health)
	if(missile_health < 10000.0)
		missile_touch(ent,0)
}
//----------------------------------------------------------------------------------------------
public client_disconnected(id)
{
	remove_task(id)
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	sh_unset_cooldown_flag(id)
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public sh_round_end()
{

	new missiles = -1
	while((missiles = find_ent_by_class(missiles, "concussion_missile"))){
		remove_entity(missiles)
	}
}
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
public sh_client_death(victim){
	remove_task(victim)
}
