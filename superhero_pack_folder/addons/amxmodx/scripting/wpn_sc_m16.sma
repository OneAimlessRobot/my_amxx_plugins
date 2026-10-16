#include <amxmodx>
#include <weaponmod>
#include <fakemeta>

// vector_to_angle port
stock vec_to_angle(Float:vector[3], Float:output[3])
{
	new Float:angles[3]
	engfunc(EngFunc_VecToAngles, vector, angles)
	output[0] = angles[0]
	output[1] = angles[1]
	output[2] = angles[2] 
} 

#define PLUGIN	"Sven Co-Op .M16"
#define WPN_NAME "SC M16"
#define WPN_SHORT "sc_m16"

#define AUTHOR	"Darkness"
#define VERSION	"1.0"

#define wpn_reload_sec 3.0
#define wpn_attack_damage 10
#define wpn_screenshake 5.0
#define wpn_ammo_clip 30
#define wpn_ammo_clips 5
#define wpn_ammo_total wpn_ammo_clip * wpn_ammo_clips
#define wpn_recoil 2.0
#define wpn_firerate1 0.15
#define wpn_firerate2 3.0

new g_wpnid,g_explosion
new usr_nades[33]
new m16_NADE_MDL[] = "models/bleachbones.mdl"
new V_MODEL[] = "models/svencoop/v_m16a2.mdl"
new P_MODEL[] = "models/svencoop/p_m16.mdl"
new W_MODEL[] = "models/svencoop/w_m16.mdl"

new m16_SOUND_S[] = "nfh/m16_single.wav"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_Touch , "fwd_Touch",1)
	register_forward(FM_PlayerPreThink , "fwd_usr_prethink",1)
	register_event("ResetHUD","usr_Spawn","b")
	
	wpn_register()
}
public fwd_usr_prethink(usr)
{
	set_hudmessage(42, 255, 127, 0.0, 0.81, 0, 6.0, 12.0)
	show_hudmessage(usr, "M16 Grenades  :  %i",usr_nades[usr])
}
public client_connect(usr)
{
	usr_nades[usr] = 3;
}
public usr_Spawn (usr)
{
	usr_nades[usr] = 3;
}
public plugin_precache ( )
{
	precache_model(m16_NADE_MDL)
	
	precache_model(V_MODEL)
	precache_model(W_MODEL)
	precache_model(P_MODEL)
	
	g_explosion = precache_model("sprites/eexplo.spr")
	
	
	precache_sound(m16_SOUND_S)
}

wpn_register ( ) 
{
	new wpnid = wpn_register_weapon(WPN_NAME, WPN_SHORT)
	if(wpnid == -1) return PLUGIN_CONTINUE
	// Strings
	wpn_set_string(wpnid, wpn_viewmodel, V_MODEL)
	wpn_set_string(wpnid, wpn_weaponmodel, P_MODEL)
	wpn_set_string(wpnid, wpn_worldmodel, W_MODEL)
	
	// Event handlers
	wpn_register_event(wpnid, event_attack1, "m16_attack")
	wpn_register_event(wpnid, event_attack2, "m16_attack2")
	wpn_register_event(wpnid, event_reload, "m16_reload")
	wpn_register_event(wpnid, event_draw, "m16_draw")
	
	// Floats
	wpn_set_float(wpnid, wpn_refire_rate1, wpn_firerate1)
	wpn_set_float(wpnid, wpn_refire_rate2, wpn_firerate2)
	wpn_set_float(wpnid, wpn_reload_time, wpn_reload_sec)
	wpn_set_float(wpnid, wpn_recoil1, 1.0)
	wpn_set_float(wpnid, wpn_run_speed, 300.0)
	
	// Integers
	wpn_set_integer(wpnid, wpn_ammo1, wpn_ammo_clip)
	wpn_set_integer(wpnid, wpn_ammo2, wpn_ammo_total)
	wpn_set_integer(wpnid, wpn_bullets_per_shot1, 1)
	wpn_set_integer(wpnid, wpn_bullets_per_shot2, 0)
	wpn_set_integer(wpnid, wpn_cost, 4000)
	
	g_wpnid = wpnid
	return PLUGIN_CONTINUE
}

enum
{
	anim_draw,
	anim_holster,
	anim_idle,
	anim_fidget,
	anim_shoot_1,
	anim_shoot_2,
	anim_reload_m16,
	anim_launch,
	anim_reload_m203
	
}

public m16_attack (usr)
{	
	wpn_bullet_shot(g_wpnid,usr,0,30)
	
	emit_sound(usr, CHAN_WEAPON, m16_SOUND_S, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	wpn_playanim( usr , anim_shoot_1 )
	
	return PLUGIN_CONTINUE
}
public m16_attack2(usr)
{
	client_cmd(usr, "-attack2")
	switch(usr_nades[usr])
	{
		case 1..10 :
		{
			wpn_playanim(usr, anim_launch)
			set_task(1.0 , "reload_m203" , usr)
			launch_nade(usr)
			usr_nades[usr] = usr_nades[usr]-1
			return PLUGIN_CONTINUE;
		}
		case 0 :
		{
			client_print(usr,print_chat,"You have no more grenades,you'll get some when you respawn.")
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}
public reload_m203 (usr)
{
	wpn_playanim(usr ,anim_reload_m203)
}
public launch_nade (usr)
{
	new nade = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!nade) return PLUGIN_CONTINUE
	
	// Strings
	set_pev(nade, pev_classname, "m16_nade")
	engfunc(EngFunc_SetModel, nade, m16_NADE_MDL)
	
	set_pev(nade, pev_owner, usr)
	set_pev(nade, pev_movetype, MOVETYPE_TOSS)
	set_pev(nade, pev_solid, SOLID_BBOX)
	set_pev(nade, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(nade, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	new Float:fStart[3],Float:fVel[3],Float:fAngles[3]
	
	wpn_projectile_startpos(usr, 24, 12, 13, fStart)
	set_pev(nade, pev_origin, fStart)
	
	velocity_by_aim(usr, 2000, fVel)		
	set_pev(nade, pev_velocity, fVel)
	
	vec_to_angle(fVel, fAngles)
	set_pev(nade, pev_angles, fAngles)
	
	return PLUGIN_CONTINUE;
}


public m16_reload (usr)
{
	set_task(0.5 , "m16_reload_anim" , usr)
}
public m16_reload_anim (usr)
{
	//Shall we play it eh?
	wpn_playanim(usr, anim_reload_m16)
}
public m16_draw (usr)
{
	wpn_playanim(usr, anim_draw)
}

new const EXPLOSION_DECAL[] = {50,51,52} 

public fwd_Touch(projectile,victim)
{
	new explo_decal = get_explo_decal()
	if(pev_valid(projectile))
	{
		new classname[32]
		pev(projectile, pev_classname, classname, 31)
		
		if(equal(classname, "m16_nade"))
		{
			new Float:fOrigin[3], iOrigin[3]
			pev(projectile, pev_origin, fOrigin)
			
			// Transform float origin into an integer kind of origin
			iOrigin[0] = floatround(fOrigin[0])
			iOrigin[1] = floatround(fOrigin[1])
			iOrigin[2] = floatround(fOrigin[2])
			
			// Add explosion
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin)
			write_byte(TE_EXPLOSION)
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_short(g_explosion)
			write_byte(45)
			write_byte(25)
			write_byte(0)
			message_end()
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_WORLDDECAL)
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_byte(explo_decal)
			message_end()
			
			new attacker = pev(projectile, pev_owner)
			wpn_radius_damage(g_wpnid, attacker, projectile, 250.0,200.0, DMG_BLAST)
			
			if(pev_valid(victim))
			{
				pev(victim, pev_classname, classname, 31)
				if(equal(classname, "func_breakable"))
					dllfunc(DLLFunc_Use, victim, projectile)
			}
			
			// Kill the nade
			set_pev(projectile, pev_flags, FL_KILLME)
		}
	}
}
public get_explo_decal() 
{
	return EXPLOSION_DECAL[random_num(0, sizeof(EXPLOSION_DECAL) - 1)]
}


