#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "freeze_fx/freeze_fx.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"


#define PLUGIN "Superhero freeze fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new is_frozen_mask = 0
new Float:g_fMaxSpeed[SH_MAXSLOTS+1]
new FREEZE_TASK_ID

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	FREEZE_TASK_ID=allocate_typed_task_id(player_task)
	register_event("Damage", "frozen_damage", "b", "2!0")
	register_event("DeathMsg","on_death_freeze","a")
	register_event("ResetHUD","freeze_new_round","b")
    
	
}
//----------------------------------------------------------------------------------------------
public freeze_new_round(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		g_fMaxSpeed[id] = get_user_maxspeed(id)
	}
	
}
public plugin_precache(){
	engfunc(EngFunc_PrecacheSound,  FROZEN_SFX)

}


public frozen_damage(id)
{
	if ( !sh_is_active() || !client_hittable(id)) return
	
	new  Float:damage= float(read_data(2))
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	if ( !is_user_connected(attacker)) return
	
	if(Get_BitVar(is_frozen_mask,id)){

		new Float:extraDamage = damage * FREEZE_DAMAGE_MULTIPLIER - damage
		if (floatround(extraDamage)>0){
			sh_extra_damage(id, attacker, floatround(extraDamage),new_dmg_type_names[_:SH_NEW_DMG_BLUNT_TRAUMA],
										headshot,
										_,_,_,_,_,
										SH_NEW_DMG_BLUNT_TRAUMA,
										get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_BLUNT_TRAUMA))
		}
	}
	
}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &headshot,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if (!sh_is_active() || !client_hittable(victim) || !client_hittable(attacker)) return DMG_FWD_PASS

	if(Get_BitVar(is_frozen_mask,victim)){
		new Float:extraDamage = damage * FREEZE_DAMAGE_MULTIPLIER + damage
		if (floatround(extraDamage)>0){
			new_dmg_type=SH_NEW_DMG_BLUNT_TRAUMA
			damage=floatround(extraDamage)
		}	
	}

	return DMG_FWD_PASS
}


public plugin_natives(){


	register_native("sh_freeze_user","_sh_freeze_user",0)
	register_native("sh_unfreeze_user","_sh_unfreeze_user",0)
	register_native("sh_is_user_frozen","_sh_is_user_frozen",0)
}


public _sh_freeze_user(iPlugins,iParams){
	

    new id=get_param(1)

    if(!is_user_alive(id)){

        return
    }
    if(sh_get_user_is_asleep(id)){
        sh_unsleep_user(id)
    }
    if(sh_get_user_is_bleeding(id)){
        sh_unbleed_user(id)
    }
    new Float:the_time=get_param_f(2)

    new Float:speed=get_param_f(3)


    new Float:fMaxSpeed
    pev(id, pev_maxspeed, fMaxSpeed)

    if(fMaxSpeed != g_fMaxSpeed[id] && fMaxSpeed != speed)
    {
        g_fMaxSpeed[id] = fMaxSpeed
    }

    if(task_exists(id+FREEZE_TASK_ID)){
        remove_task(id+FREEZE_TASK_ID)
    }

    new origin[3]
    get_user_origin(id, origin)

    set_pev(id, pev_maxspeed, 130.0)
    sh_set_rendering(id, 30, 125, 255, 0, kRenderFxGlowShell, kRenderNormal)

    emit_sound(id, CHAN_WEAPON, FROZEN_SFX, 1.0, ATTN_NORM, 0, PITCH_NORM)

    //Make the screen blue
    message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
    write_short(~0)
    write_short(~0)
    write_short(0x0004)
    write_byte(30)
    write_byte(125)
    write_byte(255)
    write_byte(100)
    message_end()

    make_shockwave(origin, 225.0, LineColors[FROZEN_BLUE], 0,2,20,0,255)

    Set_BitVar(is_frozen_mask,id)

    set_task(the_time, "remove_frozen", id+FREEZE_TASK_ID)
}
public _sh_is_user_frozen(iPlugin,iParams){

	new id=get_param(1)

	return Get_BitVar(is_frozen_mask,id)

}
unfreeze_user(id){

	if(!is_user_alive(id)){
		return
	}
	if(Get_BitVar(is_frozen_mask,id))
	{
		set_pev(id, pev_maxspeed, g_fMaxSpeed[id])
		UnSet_BitVar(is_frozen_mask,id)
	}
}
public _sh_unfreeze_user(iPlugin,iParams){

	new id=get_param(1)
	unfreeze_user(id)
	
}
public remove_frozen(id)
{	
	id-=FREEZE_TASK_ID

	if(Get_BitVar(is_frozen_mask,id))
	{
		set_pev(id, pev_maxspeed, g_fMaxSpeed[id])

		UnSet_BitVar(is_frozen_mask,id)
		sh_set_rendering(id,0, 0, 0, 0,kRenderFxGlowShell, kRenderNormal)

		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(30)
		write_byte(125)
		write_byte(255)
		write_byte(100)
		message_end()

		UnSet_BitVar(is_frozen_mask,id)
	}
}

public on_death_freeze()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		sh_unfreeze_user(id)
	
	}
	
}