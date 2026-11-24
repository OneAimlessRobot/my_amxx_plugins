#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_MISC_FUNCS
#define I_WANT_RESOURCE_ALIASES
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "freeze_fx/freeze_fx.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"

#define FREEZE_DAMAGE_MULTIPLIER 2.0

#define PLUGIN "Superhero freeze fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new FREEZE_TASK_ID

new custom_dmg_source_blunt_trauma = -1

enum frozen_struct{

	Float:damage_mult,
	Float:the_maxspeed
}

new player_frozen_structs[SH_MAXSLOTS+1][frozen_struct]


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	FREEZE_TASK_ID=allocate_typed_task_id(player_task)
	RegisterHam(Ham_TakeDamage, "player", "frozen_damage",1,true)
	register_event("CurWeapon", "weaponChange", "be", "1=1")	
    
	
}


public weaponChange(id)
{
	if ( !is_user_alive(id)||!sh_is_active()) return
	
	if(sh_get_id_bit(id, SH_IS_FROZEN)){
		
		set_user_maxspeed_controlled(id,player_frozen_structs[id][the_maxspeed],true,false)
	}
	
}

public plugin_cfg(){
	custom_dmg_source_blunt_trauma = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_BLUNT_FORCE_TRAUMA)
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		if(sh_get_id_bit(id,SH_IS_FROZEN)){
			unfreeze_user(id)
		}

	}
	
}
public plugin_precache(){
	engfunc(EngFunc_PrecacheSound,  FROZEN_SFX)

}


public frozen_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(damage <= 0.0){

		return HAM_IGNORED
	}
	if ( !sh_is_active() || !is_user_alive(id) || !is_user_alive(attacker)) return HAM_IGNORED

	new return_result= HAM_IGNORED

	new my_hitpoint_enum:the_hitpoint = my_hitpoint_enum:get_pdata_int(id, m_iLastHitGroup, XO_PLAYER)
	
	
	pev(id, pev_dmg_take, damage)
	

	if ( !is_user_connected(attacker)) return return_result
	
	if(sh_get_id_bit(id, SH_IS_FROZEN)){

		new Float:extraDamage =( damage * player_frozen_structs[id][damage_mult] ) - damage
		if (floatround(extraDamage)>0){
			sh_extra_damage(id, attacker, floatround(extraDamage),
										the_hitpoint ,
										_,_,_,_,
										SH_NEW_DMG_BLUNT_FORCE_TRAUMA,
										custom_dmg_source_blunt_trauma)
		}
	}
	return return_result
}

public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart ,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,const sh_thrash_brat_dmg_type:new_dmg_type,const custom_weapon_id){
	
	if(damage <= 0){
            
		return DMG_FWD_PASS
	}
	
	if (!sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
		return DMG_FWD_PASS
	}

	if(!CUSTOM_DMG_TYPE_IS_PHYSICAL(new_dmg_type)){
		return DMG_FWD_PASS
	}
	
	if(sh_get_id_bit(victim, SH_IS_FROZEN)){
		new Float:extraDamage = (float(damage) * player_frozen_structs[victim][damage_mult]) - float(damage)
		if (floatround(extraDamage)>0){
			
			damage+=floatround(extraDamage)
		}	
	}

	return DMG_FWD_HANDLED
}


public plugin_natives(){


	register_native("sh_freeze_user","_sh_freeze_user")
	register_native("sh_unfreeze_user","_sh_unfreeze_user")
}


public _sh_freeze_user(iPlugins,iParams){
	

	new id=get_param(1)

	if ( !sh_is_active() ||!is_user_alive(id)){

		return
	}


	if(!sh_is_active()||!is_user_alive(id)||
				sh_get_id_bit(id, SH_IS_FROZEN)||
				sh_get_id_bit(id, SH_IS_BURNING)){
					
			return
	}

	if(sh_get_id_bit(id,SH_IS_SLEEPING)){
		sh_unsleep_user(id)
	}
	if(sh_get_id_bit(id,SH_IS_BLEEDING)){
		sh_unbleed_user(id)
	}
	new Float:the_time=get_param_f(2)

	new Float:speed=get_param_f(3)

	new Float:damage_vuln_mult=get_param_f(4)


	if(task_exists(id+FREEZE_TASK_ID)){
		remove_task(id+FREEZE_TASK_ID)
	}

	new Float:origin[3]
	entity_get_vector(id,EV_VEC_origin, origin)

	player_frozen_structs[id][damage_mult] = damage_vuln_mult

	player_frozen_structs[id][the_maxspeed] = speed
	
	set_user_maxspeed_controlled(id,speed,false,false)

	set_render_with_color_const(id,FROZEN_BLUE,1,50,50,1,_,
							the_time,_,_,kRenderNormal,PRIO_RENDER_EFFECT_ACTIVE)

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

	sh_assign_id_bit(id,SH_IS_FROZEN, true)
	set_task(the_time, "remove_frozen", id+FREEZE_TASK_ID)
}
unfreeze_user(id){

	if(!is_user_alive(id)){
		return
	}
	if(sh_get_id_bit(id, SH_IS_FROZEN))
	{
		sh_reset_max_speed(id)
		
		remove_glow_user(id,PRIO_RENDER_EFFECT_ACTIVE,_,kRenderNormal);

		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(30)
		write_byte(125)
		write_byte(255)
		write_byte(100)
		message_end()
		sh_assign_id_bit(id,SH_IS_FROZEN, false)
	
	}
}
public _sh_unfreeze_user(iPlugin,iParams){

	new id=get_param(1)
	unfreeze_user(id)
	
}
public remove_frozen(id)
{	
	id-=FREEZE_TASK_ID

	unfreeze_user(id)
	
}

public sh_client_death(id)
{
	if(is_user_connected(id)&&sh_is_active()){
		unfreeze_user(id)
	
	}
	
}
public client_disconnected(id){

	task_safeguard_macro_for_player_task(id,FREEZE_TASK_ID,SH_MAXSLOTS)
	
}
public client_connect(id){


	task_safeguard_macro_for_player_task(id,FREEZE_TASK_ID,SH_MAXSLOTS)
	
}