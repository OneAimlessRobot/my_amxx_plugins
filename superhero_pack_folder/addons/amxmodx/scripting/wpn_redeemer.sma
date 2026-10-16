/* WeaponMod Weapon
 * 
 * (c) Copyright 2006, DevconeS
 * This file is provided as is (no warranties).
 * 
 */

#include <amxmodx>
#include <fakemeta>
#include <weaponmod>

new PLUGIN[] = "WPN Redeemer"
new VERSION[] = "5.1"
new AUTHOR[] = "Tigerrrflame"
new WPN_NAME[] = "N10 Redeemer"
new WPN_SHORT[] = "redeemer"

new P_MODEL[] = "models/wpnmod/p_dis.mdl"
new V_MODEL[] = "models/wpnmod/v_dis.mdl"
new W_MODEL[] = "models/wpnmod/w_dis.mdl"

new BULLETS_PER_SHOT[] = {1, 30}
new ROCKET_MDL[][] = {"sprites/gargeye1.spr", "sprites/3dmflared.spr"}
new ROCKET_SOUND[][] = {"wpnmod/dis_fire_8b44k_v2.wav", "wpnmod/dis_nuke_8b44k.wav"}

new ROCKET_CLASSNAME[][] = {"wpn_disrupor_1", "wpn_disruptor_2"}
new ROCKET_SPEED[] = {2200, 450}
new ROCKET_EXPLOSION[][] = {"sprites/wpnmod/dis.spr", "sprites/wpnmod/dis_nuke.spr"}
new ROCKET_TRAIL_COLOR[][3] = {{255, 255, 255}, {255, 255, 0}}
new Float:ROCKET_RADIUS[] = {175.0, 1500.0}
new Float:ROCKET_DAMAGE[] = {250.0, 5000.0}

// Sequences
enum
{
	anim_idle1,
	anim_idle2,
	anim_spinup,
	anim_spindown,
	anim_spin,
	anim_fire,
	anim_draw,
	anim_holster1
}

new g_wpnid
new g_trail,g_explosion[2]

public plugin_precache() {
	precache_model(P_MODEL)
	precache_model(V_MODEL)
	precache_model(W_MODEL)

	precache_model(ROCKET_MDL[0])
	precache_model(ROCKET_MDL[1])
	precache_sound(ROCKET_SOUND[0])
	precache_sound(ROCKET_SOUND[1])

	g_trail= precache_model("sprites/gwave1.spr")
	g_explosion[0] = precache_model(ROCKET_EXPLOSION[0])
	g_explosion[1] = precache_model(ROCKET_EXPLOSION[1])
}

public plugin_init() {
	register_plugin(PLUGIN,VERSION,AUTHOR)

	register_forward(FM_Touch,"fwd_Touch")

	create_weapon()
} 

create_weapon() {
	new wpnid = wpn_register_weapon(WPN_NAME,WPN_SHORT)
	if(wpnid == -1) return PLUGIN_CONTINUE

	wpn_set_string(wpnid,wpn_viewmodel,V_MODEL)
	wpn_set_string(wpnid,wpn_weaponmodel,P_MODEL)
	wpn_set_string(wpnid,wpn_worldmodel,W_MODEL)
	
	wpn_register_event(wpnid,event_attack1,"ev_attack2")
	wpn_register_event(wpnid,event_draw,"ev_draw")
	wpn_register_event(wpnid,event_reload,"ev_reload")

	wpn_set_float(wpnid,wpn_refire_rate1,0.35)
	wpn_set_float(wpnid,wpn_refire_rate2,2.0)
	wpn_set_float(wpnid,wpn_reload_time,6.0)
	wpn_set_float(wpnid,wpn_recoil1,4.0)
	wpn_set_float(wpnid,wpn_run_speed,84.0)

	wpn_set_integer(wpnid,wpn_ammo1,1)
	wpn_set_integer(wpnid,wpn_ammo2,3)
	wpn_set_integer(wpnid,wpn_bullets_per_shot1,BULLETS_PER_SHOT[0])
	wpn_set_integer(wpnid,wpn_bullets_per_shot2,BULLETS_PER_SHOT[0])
	wpn_set_integer(wpnid,wpn_cost,20000)

	g_wpnid = wpnid
	return PLUGIN_CONTINUE
} 

// vector_to_angle port 
stock vec_to_angle(Float:vector[3],Float:output[3]) {
	new Float:angles[3]
	engfunc(EngFunc_VecToAngles, vector, angles) 
	output[0] = angles[0] 
	output[1] = angles[1] 
	output[2] = angles[2] 
} 

public ev_attack1(id) {
	return fire_rocket(id, 0);
}

public ev_attack2(id) {
	return fire_rocket(id, 1);
}

fire_rocket(id, type)
{
	wpn_playanim(id,random_num(anim_fire,anim_idle1))
	
	new rocket = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	if(!rocket) return PLUGIN_CONTINUE
	
	// Strings
	set_pev(rocket,pev_classname,ROCKET_CLASSNAME[type])
	engfunc(EngFunc_SetModel,rocket,ROCKET_MDL[type])
	
	// Integer
	set_pev(rocket,pev_owner,id)
	set_pev(rocket,pev_movetype,MOVETYPE_FLY)
	set_pev(rocket,pev_solid,SOLID_BBOX)
	set_pev(rocket,pev_rendermode,kRenderTransAdd)
	set_pev(rocket,pev_renderamt,255.0)
		
	// Floats
	set_pev(rocket,pev_mins,Float:{-1.0,-1.0,-1.0})
	set_pev(rocket,pev_maxs,Float:{1.0,1.0,1.0})
	
	new Float:fStart[3]
	wpn_projectile_startpos(id,40,0,0,fStart)
	set_pev(rocket,pev_origin,fStart)
	
	new Float:fVel[3]
	velocity_by_aim(id,ROCKET_SPEED[type],fVel)
	set_pev(rocket,pev_velocity,fVel)
	
	new Float:fAngles[3]
	vec_to_angle(fVel,fAngles)
	set_pev(rocket,pev_angles,fAngles)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)	// Temp entity type
	write_short(rocket)		// entity
	write_short(g_trail)	// sprite index
	write_byte(1)	// life time in 0.1's
	write_byte(5)	// line width in 0.1's
	write_byte(ROCKET_TRAIL_COLOR[type][0])	// red (RGB)
	write_byte(ROCKET_TRAIL_COLOR[type][1])	// green (RGB)
	write_byte(ROCKET_TRAIL_COLOR[type][2])	// blue (RGB)
	write_byte(255)	// brightness 0 invisible, 255 visible
	message_end()
	
	emit_sound(rocket, CHAN_WEAPON, ROCKET_SOUND[type], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return PLUGIN_CONTINUE
}

public ev_reload(id)
	wpn_playanim(id, anim_spindown)

public ev_draw(id)
	wpn_playanim(id,anim_draw) 

public fwd_Touch(ptr, ptd) {
	if(pev_valid(ptr)) {
		static classname[32]
		pev(ptr,pev_classname,classname,31)

		if(equal(classname,ROCKET_CLASSNAME[0])) {
			create_explosion(ptr, ptd, 0)
		} else if(equal(classname,ROCKET_CLASSNAME[1])) {
			create_explosion(ptr, ptd, 1)
		}
	}
}

create_explosion(ptr, ptd, type)
{
	new Float:fOrigin[3]
	pev(ptr,pev_origin,fOrigin)
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, fOrigin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, fOrigin[0])
	engfunc(EngFunc_WriteCoord, fOrigin[1])
	engfunc(EngFunc_WriteCoord, fOrigin[2])
	write_short(g_explosion[type])
	write_byte(30)
	write_byte(15)
	write_byte(0)
	message_end()

	new attacker = pev(ptr,pev_owner)
	wpn_radius_damage(g_wpnid,attacker,ptr,ROCKET_RADIUS[type],ROCKET_DAMAGE[type],DMG_BLAST)
	if(pev_valid(ptd)) {
		new classname[32]
		pev(ptd,pev_classname,classname,31)

		if(equal(classname,"func_breakable"))
			dllfunc(DLLFunc_Use,ptd,ptr)
	}
	set_pev(ptr,pev_flags,FL_KILLME)
}
