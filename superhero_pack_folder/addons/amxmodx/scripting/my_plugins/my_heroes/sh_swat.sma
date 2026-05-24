#define I_WANT_MISC_FUNCS
#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS

#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "custom_grenades/custom_grenades.inc"


#define SWAT_M4_P_MODEL "models/shmod/swatm4/p_m4a1.mdl"
#define SWAT_M4_V_MODEL "models/shmod/swatm4/v_m4a1.mdl"


new M4Swat_weapon_id
new dmg_source_name_short_M4Swat[SAFE_BUFFER_SIZE+1]="M4Swat"
new dmg_source_name_log_M4Swat[SAFE_BUFFER_SIZE+1]="M4Swat"

new tactical_knife_weapon_id
new dmg_source_name_short_tactical_knife[SAFE_BUFFER_SIZE+1]="tactical_knife"
new dmg_source_name_log_tactical_knife[SAFE_BUFFER_SIZE+1]="tactical_knife"


new gHeroName[]="S.W.A.T."
new has_rocket[33]
new gHeroID

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Swat", "1.0", "SRGrty")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	register_cvar("Swat_level", "7")
	register_cvar("Swat_cooldown", "20.0")
	register_cvar("Swat_damage", "40")
	register_cvar("swat_armor", "200")
	register_cvar("swat_m4a1mult", "1.5")
	register_cvar("swat_knifemult", "4.0")
	register_cvar("Swat_velocity", "2000")
	register_cvar("Swat_force", "500.0")		//cannot get this to function properly.
	register_cvar("Swat_radius", "400")
	register_cvar("Swat_obeygravity", "1")	
	register_cvar("Swat_effects", "4")

	gHeroID=shCreateHero(gHeroName, "Nuke", "Fires a (most of the time) 1 hit-ko I.C.B.M", true, "Swat_level")
	sh_register_superheromod_model(gHeroID,
								"models/player/swat/swat.mdl",
								"models/player/swat/swat.mdl",
								"swat",
								"",
								"")
	sh_register_superheromod_weapon_model(gHeroID,CSW_M4A1,SWAT_M4_V_MODEL,SWAT_M4_P_MODEL)
	sh_register_superheromod_weapon_model(gHeroID,CSW_KNIFE,"models/shmod/swat_v_knife.mdl","models/shmod/swat_p_knife.mdl")
	
	register_event("CurWeapon", "weaponChange", "be", "1=1")
	register_event("Damage", "swat_damage", "b", "2!0")
	RegisterHam(Ham_TraceAttack,"player","swat_damage",_,true)

	shSetMaxHealth(gHeroName, "swat_health")
	shSetMaxArmor(gHeroName, "swat_armor")
	shSetShieldRestrict(gHeroName)
	
	M4Swat_weapon_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_M4Swat,
								dmg_source_name_log_M4Swat,
								0)

	tactical_knife_weapon_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_tactical_knife,
								dmg_source_name_log_tactical_knife,
								1)
								
	register_entity_as_wall_touchable("ICBM_missile","nuke_hit")
	register_custom_touchable("ICBM_missile","nuke_hit",player_vector,1)
	static const custom_vector[][]={"ICBM_missile"}
	register_custom_touchable("ICBM_missile","nuke_hit",custom_vector,1)


	init_explosion_defaults()
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	sh_unset_cooldown_flag(id)
	if ( sh_is_active() && sh_user_has_hero(id,gHeroID)  && is_user_alive(id) ) {
		swat_weapons(id)

	}
}
//-----------------------------------------------------------------------------------------------
public swat_weapons(id)
{
	if ( sh_is_active() && is_user_alive(id) ) {

		give_custom_grenades(id,GREN_SHOCK,10)
		sh_give_weapon(id,CSW_M4A1,true)
		sh_give_item(id,"item_thighpack")
	}
}
//----------------------------------------------------------------------------------------------
public weaponChange(id)
{
	if ( !sh_user_has_hero(id,gHeroID) || !sh_is_active() ) return

	new wpnid = read_data(2)
	new clip = read_data(3)

	if ( (wpnid != CSW_M4A1) && (wpnid != CSW_KNIFE)) return
	// Never Run Out of Ammo!
	if ( clip == 1 ) {
		sh_reload_ammo(id)
	}
}
//----------------------------------------------------------------------------------------------
public swat_damage(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{	

	if(Damage<=0.0){
		return HAM_IGNORED
	}

	if ( !sh_is_active() || !is_user_alive(Victim) ) return HAM_IGNORED


	new my_hitpoint_enum:the_hitpoint= my_hitpoint_enum:get_tr2(Ptr,TR_Hitgroup)

	static weapon;
	get_user_attacker(Victim, weapon)
	new bool:has_hero= bool:sh_user_has_hero(Attacker,gHeroID) 

	if ((Attacker==Victim)||!is_user_connected(Attacker)) return HAM_IGNORED


	if(Get_BitVar(hit_region_not_head,_:the_hitpoint)&&sh_user_has_hero(Victim,gHeroID) ){

		set_tr2(Ptr,TR_iHitgroup,_:MY_HIT_SHIELD)

		SetHamParamTraceResult(5,Ptr)

		Damage*=0.3		
		SetHamParamFloat(3,Damage)
		the_hitpoint=MY_HIT_SHIELD
	}

	if ( has_hero&& weapon == CSW_M4A1 && is_user_alive(Victim) ) {
		// do extra damage
		new Float:extraDamage = Damage * get_cvar_float("swat_m4a1mult") - Damage
		if (extraDamage > 0){
			
			sh_extra_damage(Victim, Attacker, floatround(extraDamage), dmg_source_name_log_M4Swat,
											the_hitpoint,
											_,_,_,_,
											SH_NEW_DMG_SUPER_BULLET,
											M4Swat_weapon_id)
		}
	}

	else if(has_hero && weapon == CSW_KNIFE && is_user_alive(Victim) ){
		new Float:extraDamage =  Damage *  get_cvar_float("swat_knifemult") - Damage
		if(extraDamage > 0){
			sh_extra_damage(Victim, Attacker, floatround(extraDamage), dmg_source_name_log_tactical_knife,
											the_hitpoint,
											_,_,_,_,
											SH_NEW_DMG_BLEED,
											tactical_knife_weapon_id)
		}
	}

	return HAM_IGNORED
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode){
	if(heroID!=gHeroID) return

	if(sh_user_has_hero(id, gHeroID)){

		swat_weapons(id)
	}
	else {
		sh_drop_weapon(id,CSW_M4A1,true)
	}
}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, key)
{
if ( gHeroID != heroID ||!sh_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		Swat_kd(id)
	}
}
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public Swat_kd(id)
{
	if ( !sh_is_inround() ) return

	if ( !is_user_alive(id) || !sh_user_has_hero(id,gHeroID)  ) return

	if ( sh_get_cooldown_flag(id)) {
		
		if(!is_user_bot(id)){
			client_print(id,print_chat,"[SH](S.W.A.T.) Your next I.C.B.M. is not ready yet.")
			playSoundDenySelect(id)
		}
		return
	}

	make_beam(id)
	ultimateTimer(id, get_cvar_float("Swat_cooldown") * 1.0 )
	return
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,"models/rpgrocket.mdl")
	engfunc(EngFunc_PrecacheSound,"weapons/rocketfire1.wav")
	engfunc(EngFunc_PrecacheSound,"weapons/rocket1.wav")
}
public nuke_hit(pToucher, pTouched) {

	if ( !is_valid_ent(pToucher) ) return

	new damradius = get_cvar_num("Swat_radius")
	new maxdamage = get_cvar_num("Swat_damage")

	if (damradius <= 0) {
		debugMessage("(S.W.A.T.) Damage Radius must be set higher than 0, defaulting to 240",0,0)
		damradius = 240
		set_cvar_num("Swat_radius",damradius)
	}
	if (maxdamage <= 0) {
		debugMessage("(S.W.A.T.) Max Damage must be set higher than 0, defaulting to 14",0,0)
		maxdamage = 14
		set_cvar_num("Swat_damage",maxdamage)
	}

	remove_task(pToucher)
	new Float:fl_vExplodeAt[3]
	entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
	new vExplodeAt[3]
	vExplodeAt[0] = floatround(fl_vExplodeAt[0])
	vExplodeAt[1] = floatround(fl_vExplodeAt[1])
	vExplodeAt[2] = floatround(fl_vExplodeAt[2])
	new id = entity_get_edict(pToucher, EV_ENT_owner)
	if(has_rocket[id] == pToucher)
	has_rocket[id] = 0

	explosion(gHeroID,pToucher,float(damradius),float(maxdamage), default_explode_knock_force_magnitude)
	

	emit_sound(pToucher, CHAN_WEAPON, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(pToucher, CHAN_VOICE, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	remove_entity(pToucher)
}
//----------------------------------------------------------------------------------------------
public make_beam(id)
{
	new args[2]
	new Float:vOrigin[3]
	new Float:vAngles[3]
	entity_get_vector(id, EV_VEC_origin, vOrigin)
	entity_get_vector(id, EV_VEC_v_angle, vAngles)
	new NewEnt
	NewEnt = create_entity("info_target")
	if(NewEnt == 0) {
		
		if(!is_user_bot(id)){
			client_print(id,print_chat,"[SH](S.W.A.T.) Rocket Failure")
		}
		return PLUGIN_HANDLED
	}

	entity_set_string(NewEnt, EV_SZ_classname, "ICBM_missile")
	entity_set_model(NewEnt, "models/rpgrocket.mdl")

	new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
	new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}

	entity_set_vector(NewEnt, EV_VEC_mins,fl_vecminsx)
	entity_set_vector(NewEnt, EV_VEC_maxs,fl_vecmaxsx)

	entity_set_origin(NewEnt, vOrigin)
	entity_set_vector(NewEnt, EV_VEC_angles, vAngles)	
	entity_set_int(NewEnt, EV_INT_solid, 2)
	entity_set_int(NewEnt, EV_INT_effects, 64)

	new effects = get_cvar_num("Swat_effects")	

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

	if(get_cvar_num("Swat_obeygravity")) {
		entity_set_int(NewEnt, EV_INT_movetype, 6)
	}
	else {
		entity_set_int(NewEnt, EV_INT_movetype, 5)
	}

	entity_set_edict(NewEnt, EV_ENT_owner, id)
	entity_set_float(NewEnt, EV_FL_health, 10000.0)
	entity_set_float(NewEnt, EV_FL_takedamage, 100.0)
	entity_set_float(NewEnt, EV_FL_dmg_take, 100.0)

	new MissileVel = get_cvar_num("Swat_velocity")
	new Float:fl_iNewVelocity[3]
	//new iNewVelocity[3]
	velocity_by_aim(id, MissileVel, fl_iNewVelocity)
	entity_set_vector(NewEnt, EV_VEC_velocity, fl_iNewVelocity)

	emit_sound(NewEnt, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(NewEnt, CHAN_VOICE, "weapons/rocket1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	args[0] = id
	args[1] = NewEnt

	trail(NewEnt,RED,10,10)
	entity_set_float(NewEnt, EV_FL_gravity, 0.25)
	
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public sh_round_end(){

	new iCurrent
	while ((iCurrent = find_ent_by_class(-1, "ICBM_missile")) > 0) {
		new id = entity_get_edict(iCurrent, EV_ENT_owner)
		remove_missile(id,iCurrent)
	}
}
public sh_client_death(victim){
	
	remove_task(victim)
}
//----------------------------------------------------------------------------------------------
remove_missile(id,missile){

	new Float:fl_origin[3]
	entity_get_vector(missile, EV_VEC_origin, fl_origin)

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(14)
	write_coord(floatround(fl_origin[0]))
	write_coord(floatround(fl_origin[1]))
	write_coord(floatround(fl_origin[2]))
	write_byte (200)
	write_byte (40)
	write_byte (45)
	message_end()

	emit_sound(missile, CHAN_WEAPON, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(missile, CHAN_VOICE, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	has_rocket[id] = 0;
	sh_unset_cooldown_flag(id)
	attach_view(id,id)
	remove_entity(missile)
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public sh_round_start(){

	new iCurrent
	while ((iCurrent = find_ent_by_class(-1, "ICBM_missile")) > 0) {
		new id = entity_get_edict(iCurrent, EV_ENT_owner)
		remove_missile(id,iCurrent)
	}
}
//----------------------------------------------------------------------------------------------

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &my_hitpoint_enum:bodypart,&dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if ( !sh_is_active() ||  !is_user_connected(victim)||!is_user_connected(attacker)||(victim==attacker)){
	
		return DMG_FWD_PASS
	}
	if(sh_user_has_hero(victim,gHeroID) ){
		if(sh_clients_are_same_team(victim,attacker)){
			return DMG_FWD_PASS
		
		}
		if(Get_BitVar(hit_region_not_head,_:bodypart)){
			new Float:damage_float=float(damage)
			damage_float *=0.3
			damage=floatround(damage_float)
			bodypart=MY_HIT_SHIELD
		}
	}
	return DMG_FWD_PASS
}
