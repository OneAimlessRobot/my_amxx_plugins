#include <amxmodx> 
#include <weaponmod> 

#define PLUGIN "LightSaber" 
#define VERSION "0.2.0" 
#define AUTHOR "Darkness" 

// Weapon information 
new WPN_NAME[] = "Lightsaber" 
new WPN_SHORT[] = "lsaber" 

// Model information 
new P_MODEL[] = "models/p_crowbar.mdl" 
new V_MODEL[] = "models/v_lightsaber.mdl" 
new W_MODEL[] = "models/w_crowbar.mdl" 

// Sound information 
new SOUND[][] = {"weapons/lsaber_miss1.wav", "weapons/lsaber_hit2.wav"} 

// Sequences 
enum 
{ 
    anim_idle1, 
    anim_draw, 
    anim_holster, 
    anim_attack1, 
    anim_attack1miss, 
    anim_attack2, 
    anim_attack2hit, 
    anim_attack3, 
    anim_attack3hit, 
    anim_idle2, 
    anim_idle3 
} 

// Variables 
new g_wpnid 

public plugin_precache() { 
    precache_model(P_MODEL) 
    precache_model(V_MODEL) 
    precache_model(W_MODEL) 
     
    precache_sound(SOUND[0]) 
    precache_sound(SOUND[1]) 
} 

public plugin_init() { 
    register_plugin(PLUGIN, VERSION, AUTHOR) 
    create_weapon() 
} 

create_weapon() { 
    new wpnid = wpn_register_weapon(WPN_NAME,WPN_SHORT) 
    if(wpnid == -1)    return PLUGIN_CONTINUE 
     
    wpn_set_string(wpnid, wpn_viewmodel, V_MODEL) 
    wpn_set_string(wpnid, wpn_weaponmodel, P_MODEL) 
    wpn_set_string(wpnid, wpn_worldmodel, W_MODEL) 
     
    wpn_register_event(wpnid, event_attack1, "ev_attack1") 
    wpn_register_event(wpnid, event_draw, "ev_draw") 
     
    wpn_set_float(wpnid, wpn_recoil1, 0.0) 
    wpn_set_float(wpnid, wpn_run_speed, 300.0) 
     
    wpn_set_integer(wpnid, wpn_ammo1, 1) 
    wpn_set_integer(wpnid, wpn_ammo2, 0) 
    wpn_set_integer(wpnid, wpn_bullets_per_shot1, 0) 
    wpn_set_integer(wpnid, wpn_cost, 50) 
     
    g_wpnid = wpnid 
    return PLUGIN_CONTINUE 
} 

public ev_attack1(id) { 
     new body,hitbox 
     get_user_aiming(id,body,hitbox,99999) 

     if(is_user_connected(body)) { 
        new user_origin[3], target_origin[3] 
        get_user_origin(id,user_origin) 
        get_user_origin(body,target_origin) 
         
        if(get_distance(user_origin,target_origin) <= 70) { 
            wpn_damage_user(g_wpnid,body,id,25,random_num(10,15),DMG_GENERIC, 1) 
            wpn_playanim(id,anim_attack1) 
            emit_sound(id, CHAN_WEAPON, SOUND[1], 1.0, ATTN_NORM, 0, PITCH_NORM) 
        } else { 
            wpn_playanim(id,anim_attack1miss) 
            emit_sound(id, CHAN_WEAPON, SOUND[0], 1.0, ATTN_NORM, 0, PITCH_NORM) 
        } 
    } else { 
        wpn_playanim(id,anim_attack1miss) 
        emit_sound(id, CHAN_WEAPON, SOUND[0], 1.0, ATTN_NORM, 0, PITCH_NORM) 
    } 
    client_cmd(id,"-attack") 
} 

public ev_draw(id)    wpn_playanim(id, anim_draw) 