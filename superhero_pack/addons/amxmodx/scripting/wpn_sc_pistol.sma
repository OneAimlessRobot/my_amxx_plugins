#include <amxmodx>
#include <weaponmod>
#define PLUGIN	"Sven Co-Op Pistol"
    #define WPN_NAME "SC PIstol"
	#define WPN_SHORT "sc_pist"
	
#define AUTHOR	"Darkness"
#define VERSION	"1.0"

#define wpn_reload_sec 2.0
#define wpn_attack_damage 10
#define wpn_screenshake 1
#define wpn_ammo_clip 17
#define wpn_ammo_total wpn_ammo_clip * 5 //Basically five clips
#define wpn_recoil 2.0
#define wpn_firerate1 0.10
#define wpn_firerate2 0.15

new g_wpnid
new V_MODEL[] = "models/svencoop/v_9mmhandgun.mdl"
new P_MODEL[] = "models/p_9mmhandgun.mdl"
new W_MODEL[] = "models/svencoop/w_9mmhandgun.mdl"

new PISTOL_SOUND_R1[] = "items/9mmclip1.wav"
new PISTOL_SOUND_R2[] = "items/9mmclip2.wav"
new PISTOL_SOUND_S[] = "nfh/pl_gun3.wav"

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
	
	precache_sound(PISTOL_SOUND_R1)
	precache_sound(PISTOL_SOUND_R2)
	precache_sound(PISTOL_SOUND_S)
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
	wpn_register_event(wpnid, event_attack1, "pistol_attack")
	wpn_register_event(wpnid, event_attack2, "pistol_attack2")
	wpn_register_event(wpnid, event_reload, "pistol_reload")
	wpn_register_event(wpnid, event_draw, "pistol_draw")
	
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
	wpn_set_integer(wpnid, wpn_bullets_per_shot2, 1)
	wpn_set_integer(wpnid, wpn_cost, 4000)
	
	g_wpnid = wpnid
	return PLUGIN_CONTINUE
}

enum
{
	anim_idle1,
	anim_idle2,
	anim_idle3,
	anim_shoot,
	anim_shoot_empty,
	anim_reload,
	anim_reload_empty,
	anim_draw,
	anim_holster
	
}
public pistol_attack (usr)
{
	wpn_bullet_shot(g_wpnid , usr , 0 , 5)
	
	emit_sound(usr, CHAN_WEAPON, PISTOL_SOUND_S, VOL_NORM, ATTN_NORM, 0, 250)
    
	wpn_playanim( usr , anim_shoot )
	
	client_cmd( usr , "-attack" )
	set_task(0.05,"pistol_stoprecoil",usr)
}
public pistol_attack2(usr)
{
	wpn_bullet_shot(g_wpnid , usr , 0 , 5)	
	
	emit_sound(usr, CHAN_WEAPON, PISTOL_SOUND_S, 1.0, ATTN_NORM, 0, PITCH_NORM)
    
	wpn_playanim( usr , anim_shoot )
	
	client_cmd( usr , "+lookup" )
	set_task(0.04,"pistol_stoprecoil",usr)
}
public pistol_stoprecoil(usr)
{
	client_cmd( usr , "-lookup" )
}
public pistol_reload (usr)
{
	//This is great for preventing the user seeing the last animation before reload :)
	set_task(0.5 , "pistol_reload_anim" , usr)
}
public pistol_reload_anim (usr)
{
	//Shall we play it eh?
	wpn_playanim(usr, anim_reload)
}
public pistol_draw (usr)
{
	wpn_playanim(usr, anim_draw)
}
