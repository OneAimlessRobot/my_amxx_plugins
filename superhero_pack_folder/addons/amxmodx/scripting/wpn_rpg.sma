/* WeaponMod Weapon
* 
* (c) Copyright 2006, DevconeS 
* This file is provided as is (no warranties). 
* 
*/ 

#include <amxmodx>
#include <fakemeta>
#include <weaponmod>

new PLUGIN[] = "WPN RPG"
new VERSION[] = "1.0"
new AUTHOR[] = "DevconeS(Edited by Humming Bird)"
new WPN_NAME[] = "Bazooka 10-Cartridge TNT-Core"
new WPN_SHORT[] = "rpg"

new P_MODEL[] = "models/p_rpg.mdl"
new V_MODEL[] = "models/v_rpg.mdl"
new W_MODEL[] = "models/w_rpg.mdl"

new ROCKET_MDL[] = "models/rpgrocket.mdl"
new ROCKET_SOUND[] = "weapons/rocketfire1.wav"

#define ROCKET_SPEED	1400
#define ROCKET_RADIUS	270.0
#define ROCKET_DAMAGE	200.0

// Sequences
enum
{
	anim_idle1,
	anim_fidget1,
	anim_altfireon,
	anim_altfirecycle,
	anim_altfireoff,
	anim_fire1,
	anim_fire2,
	anim_fire3,
	anim_fire4,
	anim_draw,
	anim_holster
}

new g_wpnid
new g_trail,g_explosion

public plugin_precache() {
	precache_model(P_MODEL)
	precache_model(V_MODEL)
	precache_model(W_MODEL)
	
	precache_model(ROCKET_MDL)
	precache_sound(ROCKET_SOUND)
	
	g_trail = precache_model("sprites/smoke.spr")
	g_explosion = precache_model("sprites/xflare2.spr")
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
	
	wpn_register_event(wpnid,event_attack1,"ev_attack1")
	wpn_register_event(wpnid,event_draw,"ev_draw")
	
	wpn_set_float(wpnid,wpn_refire_rate1,1.0)
	wpn_set_float(wpnid,wpn_reload_time,2.0)
	wpn_set_float(wpnid,wpn_recoil1,4.0)
	wpn_set_float(wpnid,wpn_run_speed,210.0)
	
	wpn_set_integer(wpnid,wpn_ammo1,5)
	wpn_set_integer(wpnid,wpn_ammo2,5)
	wpn_set_integer(wpnid,wpn_bullets_per_shot1,1)
	wpn_set_integer(wpnid,wpn_cost,40000)
	
	g_wpnid = wpnid
	return PLUGIN_CONTINUE
}

public ev_attack1(id) {
	wpn_playanim(id,random_num(anim_fire3,anim_fire4))
	
	new rocket = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	if(!rocket) return PLUGIN_CONTINUE
	
	// Strings
	set_pev(rocket,pev_classname,"wpn_rpg")
	engfunc(EngFunc_SetModel,rocket,ROCKET_MDL)
	
	// Integer
	set_pev(rocket,pev_owner,id)
	set_pev(rocket,pev_movetype,MOVETYPE_FLY)
	set_pev(rocket,pev_solid,SOLID_BBOX)
	
	// Floats
	set_pev(rocket,pev_mins,Float:{-1.0,-1.0,-1.0})
	set_pev(rocket,pev_maxs,Float:{1.0,1.0,1.0})
	
	new Float:fStart[3]
	wpn_projectile_startpos(id,40,0,0,fStart)
	set_pev(rocket,pev_origin,fStart)
	
	new Float:fVel[3]
	velocity_by_aim(id,ROCKET_SPEED,fVel)		
	set_pev(rocket,pev_velocity,fVel)
	
	new Float:fAngles[3]
	engfunc(EngFunc_VecToAngles, fVel, fAngles)
	set_pev(rocket,pev_angles,fAngles)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(rocket)
	write_short(g_trail)
	write_byte(25)
	write_byte(5)
	write_byte(224)
	write_byte(224)
	write_byte(255)
	write_byte(255)
	message_end()
	
	emit_sound(rocket, CHAN_WEAPON, ROCKET_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return PLUGIN_CONTINUE
}

public ev_draw(id)
	wpn_playanim(id,anim_draw)

public fwd_Touch(ptr, ptd) {
	if(pev_valid(ptr)) {
		static classname[32]
		pev(ptr,pev_classname,classname,31)
		
		if(equal(classname,"wpn_rpg")) {
			new Float:fOrigin[3]
			pev(ptr,pev_origin,fOrigin)
			
			engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, fOrigin, 0)
			write_byte(TE_EXPLOSION)
			engfunc(EngFunc_WriteCoord, fOrigin[0])
			engfunc(EngFunc_WriteCoord, fOrigin[1])
			engfunc(EngFunc_WriteCoord, fOrigin[2])
			write_short(g_explosion)
			write_byte(30)
			write_byte(15)
			write_byte(0)
			message_end()
			
			new attacker = pev(ptr,pev_owner)
			wpn_radius_damage(g_wpnid,attacker,ptr,ROCKET_RADIUS,ROCKET_DAMAGE,DMG_BLAST)
			if(pev_valid(ptd)) {
				pev(ptd,pev_classname,classname,31)
				
				if(equal(classname,"func_breakable"))
					dllfunc(DLLFunc_Use,ptd,ptr)
			}
			set_pev(ptr,pev_flags,FL_KILLME)
		}
	}
}
