#include <amxmodx>
#include <weaponmod>
#include <FastTask>
#include <fakemeta>

#define PLUGIN	"Sven Co-Op .9mm Assault Rifle"
#define WPN_NAME "SC Assault Rifle"
#define WPN_SHORT "sc_ar"

#define AUTHOR	"Darkness"
#define VERSION	"1.0"

#define VOL_FLAG 0

#define wpn_reload_sec 3.0
#define wpn_attack_damage 10
#define wpn_screenshake 5.0
#define wpn_ammo_clip 30
#define wpn_ammo_clips 5
#define wpn_ammo_total wpn_ammo_clip * wpn_ammo_clips
#define wpn_recoil 2.0
#define wpn_firerate1 0.08
#define wpn_firerate2 0.3

new g_wpnid
new IN_ZOOM[33]
new V_MODEL[] = "models/svencoop/v_9mmar.mdl"
new P_MODEL[] = "models/svencoop/p_9mmar.mdl"
new W_MODEL[] = "models/svencoop/w_9mmar.mdl"

new ar_SOUND_S[] = "nfh/hks1.wav"

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
	
	precache_sound(ar_SOUND_S)
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
	wpn_register_event(wpnid, event_attack1, "ar_attack")
	wpn_register_event(wpnid, event_attack2, "ar_attack2")
	wpn_register_event(wpnid, event_reload, "ar_reload")
	wpn_register_event(wpnid, event_draw, "ar_draw")
	
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
	anim_longidle,
	anim_idle,
	anim_launch,
	anim_reload,
	anim_deploy,
	anim_fire1,
	anim_fire2,
	anim_fire3
	
}

public ar_attack (usr)
{	
	wpn_bullet_shot(g_wpnid,usr,0,20)

	wpn_playanim(usr , random_num(anim_fire1,anim_fire3))
	
	emit_sound(usr,CHAN_WEAPON,ar_SOUND_S,VOL_NORM,ATTN_NORM,VOL_FLAG,PITCH_NORM)
	
	return PLUGIN_CONTINUE;
}
public ar_attack2(usr)
{
	if((IN_ZOOM[usr]))
	{
		client_cmd( usr , "fov 90" )
		IN_ZOOM[usr] = 0
	}else{
		client_cmd( usr , "fov 40" )
		IN_ZOOM[usr] = 1
	}
}
public ar_reload (usr)
{
	//We don't need to zoom when we reload, luuuuuulz
	IN_ZOOM[usr] = 0
	client_cmd( usr , "fov 90" )
	
	//This is great for making sure he sees the last shoot animation.)
	set_task(0.5 , "ar_reload_anim" , usr)
}
public ar_reload_anim (usr)
	//Shall we play it eh?
	wpn_playanim(usr, anim_reload)

public ar_draw (usr)

	wpn_playanim(usr, anim_deploy)
