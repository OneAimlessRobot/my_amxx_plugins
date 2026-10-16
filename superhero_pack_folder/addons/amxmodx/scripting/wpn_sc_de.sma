#include <amxmodx>
#include <weaponmod>
#include <fakemeta>

#define PLUGIN	"Sven Co-Op .9mm Desert Eagle"
#define WPN_NAME "SC Desert Eagle"
#define WPN_SHORT "sc_de"

#define AUTHOR	"Ddekness"
#define VERSION	"1.0"

#define wpn_reload_sec 2.2
#define wpn_attack_damage 10
#define wpn_screenshake 5.0
#define wpn_ammo_clip 7
#define wpn_ammo_clips 5
#define wpn_ammo_total wpn_ammo_clip * wpn_ammo_clips
#define wpn_recoil 2.0
#define wpn_firerate1 0.3
#define wpn_firerate2 2.5

new g_wpnid
new V_MODEL[] = "models/svencoop/v_desert_eagle.mdl"
new P_MODEL[] = "models/svencoop/p_desert_eagle.mdl"
new W_MODEL[] = "models/svencoop/w_desert_eagle.mdl"

new de_laserdot
new HAS_LASER[33]

new de_SOUND_S[] = "nfh/de_shot1.wav"
new de_SOUND_R1[] = "weapons/desert_eagle_sight.wav"
new de_SOUND_R2[] = "weapons/desert_eagle_sight2.wav"
new de_SOUND_R3[] = "weapons/desert_eagle_slidepush.wav"
new de_SOUND_R4[] = "weapons/desert_eagle_reload.wav"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_PlayerPostThink , "usr_PostThink")
	
	wpn_register()
}
public usr_PostThink (usr)
{
	if((HAS_LASER[usr]))
	{
			new gunOrigin[3] , aimOrigin[3]
			get_user_origin(usr,gunOrigin,1)
			get_user_origin(usr,aimOrigin,3)
			
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_SPRITE)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_short(de_laserdot) 
			write_byte(5) 
			write_byte(400)
			message_end()
	}
}

public plugin_precache ( )
{
	precache_model(V_MODEL)
	precache_model(W_MODEL)
	precache_model(P_MODEL)
	
	precache_sound(de_SOUND_S)
	precache_sound(de_SOUND_R1)
	precache_sound(de_SOUND_R2)
	precache_sound(de_SOUND_R3)
	precache_sound(de_SOUND_R4)
	
	de_laserdot = precache_model("sprites/laserdot.spr")
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
	wpn_register_event(wpnid, event_attack1, "de_attack")
	wpn_register_event(wpnid, event_attack2, "de_attack2")
	wpn_register_event(wpnid, event_reload, "de_reload")
	wpn_register_event(wpnid, event_draw, "de_draw")
	
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
	anim_idle1,
	anim_idle2,
	anim_idle3,
	anim_idle4,
	anim_idle5,
	anim_shoot,
	anim_shoot_empty,
	anim_reload,
	anim_reload_noshot,
	anim_draw,
	anim_holster
	
}
public de_attack (usr)
{	
	wpn_bullet_shot(g_wpnid,usr,0,25)
	
	emit_sound(usr, CHAN_WEAPON, de_SOUND_S, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	wpn_playanim( usr , anim_shoot )
	
	return PLUGIN_CONTINUE
}
public de_attack2(usr)
{
	wpn_playanim( usr , anim_idle2)
	
	set_task(2.0 , "de_laser_toggle", usr)
}
public de_laser_toggle ( usr )
{
	if((HAS_LASER[usr]))
	{
		HAS_LASER[usr] = 0
		emit_sound(usr, CHAN_WEAPON, de_SOUND_R2, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}else{
		HAS_LASER[usr] = 1
		emit_sound(usr, CHAN_WEAPON, de_SOUND_R1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
}
public de_reload (usr)
{
	HAS_LASER[usr] = 0
	//This is great for pdeenting the user seeing the last animation before reload :)
	set_task(0.5 , "de_reload_anim" , usr)
}
public de_reload_anim (usr)
{
	//Shall we play it eh?
	wpn_playanim(usr, anim_reload)
}
public de_draw (usr)
	wpn_playanim(usr, anim_draw)

