#include <amxmodx>
#include <weaponmod>
#include <fakemeta>

#define PLUGIN	"Sven Co-Op .357"
    #define WPN_NAME "SC .357"
	#define WPN_SHORT "sc_357"
	
#define AUTHOR	"Darkness"
#define VERSION	"1.0"

#define wpn_reload_sec 3.0
#define wpn_attack_damage 10
#define wpn_screenshake 5.0
#define wpn_ammo_clip 6
#define wpn_ammo_clips 5
#define wpn_ammo_total wpn_ammo_clip * wpn_ammo_clips
#define wpn_recoil 2.0
#define wpn_firerate1 0.4
#define wpn_firerate2 0.3

new g_wpnid
new IN_ZOOM[33]
new V_MODEL[] = "models/svencoop/v_357.mdl"
new P_MODEL[] = "models/p_357.mdl"
new W_MODEL[] = "models/svencoop/w_357.mdl"

new REV_SOUND_R1[] = "weapons/357_chamberout.wav"
new REV_SOUND_R2[] = "weapons/357_chamberin.wav"
new REV_SOUND_R3[] = "weapons/357_cock1.wav"
new REV_SOUND_R4[] = "weapons/357_idle_fidgetpull.wav"
new REV_SOUND_R5[] = "weapons/357_idle_fidgetrelease.wav"
new REV_SOUND_R6[] = "weapons/357_idle_squeeze.wav"
new REV_SOUND_R7[] = "weapons/357_idle_unsqueeze.wav"
new REV_SOUND_R8[] = "weapons/357_quickloader.wav"
new REV_SOUND_R9[] = "weapons/357_reload1.wav"
new REV_SOUND_Ri[] = "weapons/357_shellsin.wav"
new REV_SOUND_Rii[] = "weapons/357_shellsout.wav"
new REV_SOUND_S[] = "nfh/357_shot1.wav"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	wpn_register()
}
public plugin_precache ( )
{
	precache_model(V_MODEL)
	precache_model(W_MODEL)
	precache_model(P_MODEL)
	
	precache_sound(REV_SOUND_R1)
	precache_sound(REV_SOUND_R2)
	precache_sound(REV_SOUND_R3)
	precache_sound(REV_SOUND_R4)
	precache_sound(REV_SOUND_R5)
	precache_sound(REV_SOUND_R6)
	precache_sound(REV_SOUND_R7)
	precache_sound(REV_SOUND_R8)
	precache_sound(REV_SOUND_R9)
	precache_sound(REV_SOUND_Ri)
	precache_sound(REV_SOUND_Rii)
	precache_sound(REV_SOUND_S)
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
	wpn_register_event(wpnid, event_attack1, "REV_attack")
	wpn_register_event(wpnid, event_attack2, "REV_attack2")
	wpn_register_event(wpnid, event_reload, "REV_reload")
	wpn_register_event(wpnid, event_draw, "REV_draw")
	
	// Floats
	wpn_set_float(wpnid, wpn_refire_rate1, wpn_firerate1)
	wpn_set_float(wpnid, wpn_refire_rate2, wpn_firerate2)
	wpn_set_float(wpnid, wpn_reload_time, wpn_reload_sec)
	wpn_set_float(wpnid, wpn_recoil1, wpn_screenshake)
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
	anim_idle1,
	anim_fidget1,
	anim_fire1,
	anim_reload,
	anim_holster,
	anim_draw,
	anim_idle2
	
}
public REV_attack (usr)
{
	wpn_bullet_shot(g_wpnid , usr , 0 , 35)
	
	emit_sound(usr, CHAN_WEAPON, REV_SOUND_S, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    
	wpn_playanim( usr , anim_fire1 )
	
	client_cmd( usr , "-attack" )
}
public REV_attack2(usr)
{
	if((IN_ZOOM[usr]))
	{
		client_cmd( usr , "fov 90" )
		IN_ZOOM[usr] = 0
	}else{
		client_cmd( usr , "fov 60" )
		IN_ZOOM[usr] = 1
	}
}
public REV_reload (usr)
{
	set_task(0.5 , "REV_reload_anim" , usr)
	client_cmd( usr , "fov 90" )
	IN_ZOOM[usr] = 0
}
public REV_reload_anim (usr)
{
	//Shall we play it eh?
	wpn_playanim(usr, anim_reload)
}
public REV_draw (usr)
{
	wpn_playanim(usr, anim_draw)
}
