#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_CUSTOM_COLORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_QUICK_CHECKS
#define I_WANT_BASIC_MACROS
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "co2_fx_inc/co2_fx.inc"
#include "tomie_yu_inc/tomie_yu.inc"
#include "freeze_fx/freeze_fx.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define PLUGIN "Superhero molotov fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


stock MOLLY_FX_TASKID, BURN_TASKID_MAIN

#define BURN_PERIOD 0.33
#define BURN_DAMAGE_VULNERABILITY_COEFF 1.8
#define BURN_TIMES floatround(floatdiv(the_time,BURN_PERIOD))
#define MOLLY_FX_TASK_PERIOD 0.33


enum burn_struct{

	burn_attacker,
	burn_og_burner,
	burn_times_left,
	burn_is_tomie_user,
	bool:burn_should_spread,
	Float:dmg_per_tick,
	Float:spread_dist,
	burn_custom_wpn_id


}

new burn_structs[SH_MAXSLOTS+1][burn_struct]



new dmg_source_name_short_fire_vuln[SAFE_BUFFER_SIZE+1]="fire_vuln"
new dmg_source_name_log_fire_vuln[SAFE_BUFFER_SIZE+1]="fire_vuln"
new custom_dmg_id_fire_vuln
new generic_dmg_source_fire = -1


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	RegisterHam(Ham_TakeDamage, "player", "molotov_damage_vulnerability",1,true)
	BURN_TASKID_MAIN=allocate_typed_task_id(player_task)
	MOLLY_FX_TASKID= allocate_typed_task_id(generic_task)
	set_task(MOLLY_FX_TASK_PERIOD,"global_molly_fx_task",MOLLY_FX_TASKID,_,_,"b")



}
public global_molly_fx_task(task_id){

		
	if ( !sh_is_active() ) return
	
	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]
		if(!is_user_connected(burn_structs[id][burn_attacker])){

			unburn_user(id)
			continue
		}

		if( !sh_get_id_bit(id, SH_IS_BURNING)) continue
			
		if(!sh_get_id_bit(id, SH_IS_BURNING)||(burn_structs[id][burn_times_left]<=0)){
			
			unburn_user(id)

		}
	
		burn_structs[id][burn_times_left]--
		if(burn_structs[id][burn_should_spread]&&!burn_structs[id][burn_is_tomie_user]){
			static players[33];

			new num_players=find_sphere_class(id,"player",burn_structs[id][spread_dist],players,sizeof(players)-1)
			for ( new j = 0; j < num_players; j++) {
				new pid=players[j]

				if(sh_get_id_bit(pid, SH_IS_BURNING)) continue
				if(sh_clients_are_same_team(pid,burn_structs[id][burn_og_burner])&&(!sh_friendlyfire_on())) continue

				sh_molly_user_fast(pid,burn_structs[id][burn_og_burner],
								burn_structs[id][burn_og_burner],
								burn_structs[id][burn_times_left],
								burn_structs[id][burn_is_tomie_user],
								burn_structs[id][dmg_per_tick],
								burn_structs[id][spread_dist],
								burn_structs[id][burn_should_spread],
								burn_structs[id][burn_custom_wpn_id])
				
			}
		}

		set_render_with_color_const(id,PINK,1,16,50,1,1,MOLLY_FX_TASK_PERIOD,_,_,kRenderNormal,PRIO_RENDER_EFFECT_ACTIVE)

		make_fire(id,30.0)

		emit_sound(id, CHAN_AUTO, MOLLY_FIRE_SFX , VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

		set_damage_icon(id,2,DMG_ICON_HEAT,LineColors[RED],MOLLY_FX_TASK_PERIOD)

		if ( pev(id, pev_waterlevel) == 3 ) {
			unburn_user(id)
			continue
		}
		new dmg_to_do = floatround(burn_structs[id][dmg_per_tick])

		if(dmg_to_do > 0){
			sh_extra_damage(id,burn_structs[id][burn_og_burner], dmg_to_do,
					_,_,_,_,_,
					SH_NEW_DMG_FIRE,
					burn_structs[id][burn_custom_wpn_id] )
		}

	}


}
public plugin_cfg(){
	
	custom_dmg_id_fire_vuln=sh_log_custom_damage_source(-1,
				dmg_source_name_short_fire_vuln,
				dmg_source_name_log_fire_vuln,
				0)
	generic_dmg_source_fire = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_FIRE)
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		unburn_user(id)
	}
	
}
public plugin_precache(){
	
	engfunc(EngFunc_PrecacheSound,gSoundBurning)
	engfunc(EngFunc_PrecacheSound,gSoundScream)
	engfunc(EngFunc_PrecacheSound,MOLLY_FIRE_SFX)

}
public plugin_natives(){
	
	register_native("sh_molly_user","_sh_molly_user");
	register_native("sh_unmolly_user","_sh_unmolly_user");
}

public molotov_damage_vulnerability(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(damage <= 0.0){

		return HAM_IGNORED
	}
	if ( !sh_is_active() || !is_user_alive(id) || !is_user_alive(attacker)) return HAM_IGNORED


	new return_result= HAM_IGNORED

		
	new my_hitpoint_enum:the_hitpoint = my_hitpoint_enum:get_pdata_int(id, m_iLastHitGroup, XO_PLAYER)


	pev(id, pev_dmg_take, damage)

	if ( !is_user_connected(attacker)) return return_result
	
	if(sh_get_id_bit(id, SH_IS_BURNING)){
		new Float:extraDamage = damage * BURN_DAMAGE_VULNERABILITY_COEFF + damage
		if (floatround(extraDamage)>0){
			if (floatround(extraDamage)>0){
				sh_extra_damage(id, attacker, floatround(extraDamage),
							the_hitpoint,
							_,_,_,_,
							SH_NEW_DMG_SUPER_BULLET,
							custom_dmg_id_fire_vuln)
			}
		}
	}
	return return_result

	
}
public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart ,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,const sh_thrash_brat_dmg_type:new_dmg_type,const custom_weapon_id){
	if (!sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)) return DMG_FWD_PASS

	if(sh_get_id_bit(victim, SH_IS_BURNING) && CUSTOM_DMG_TYPE_IS_PHYSICAL(new_dmg_type)){
		
		new Float:extraDamage = float(damage) * BURN_DAMAGE_VULNERABILITY_COEFF - float(damage)
		if (floatround(extraDamage)>0){
			
			damage+=floatround(extraDamage)
		}
	}
	

	
	return DMG_FWD_HANDLED
}
public _sh_molly_user(iPlugin,iParams){
	
	new user=get_param(1)
	new attacker=get_param(2)
	new Float:the_time = get_param_f(3)
	new Float:damage_per_tick = get_param_f(4)
	new Float:spread_radius = get_param_f(5)
	new bool:should_spread = bool:get_param(6)
	new custom_wpn_id = get_param(7)

	custom_wpn_id = ((custom_wpn_id<0)?generic_dmg_source_fire:custom_wpn_id)

	new bool:is_tomie_user = sh_get_player_has_hero_prop(user, SH_FIRE_RETARDANT_HERO)
	new times_to_count=floatround(float(BURN_TIMES) * (is_tomie_user?0.5:1.0),floatround_floor)
	
	
	sh_molly_user_fast(user,attacker,attacker, times_to_count,is_tomie_user, damage_per_tick, spread_radius, should_spread, custom_wpn_id)
	
	
}
sh_molly_user_fast(user,attacker,og_burner, times,is_tomie_user, Float:damage_per_tick, Float:spread_radius, bool:should_spread, custom_wpn_id){

	if(!sh_get_id_bit(user, SH_IS_CO2)&&!sh_get_id_bit(user, SH_IS_BURNING)){
		if((user==attacker)){
			if(CAN_SELF_MOLLY&&user){
					burn_user(user,attacker,og_burner, times,is_tomie_user, damage_per_tick, spread_radius, should_spread, custom_wpn_id)
			}
		}
		else {
			burn_user(user,attacker,og_burner, times,is_tomie_user, damage_per_tick, spread_radius, should_spread, custom_wpn_id)
		}
	}
}

public _sh_unmolly_user(iPlugin,iParams){
	
	new user=get_param(1)
	
	if(sh_get_id_bit(user, SH_IS_BURNING)){
		unburn_user(user)
	}
	
	
	
}

burn_user(id,attacker,og_burner, times, is_tomie_user, Float:damage_per_tick, Float:spread_radius, bool:should_spread, custom_wpn_id){

	if(sh_get_id_bit(id, SH_IS_BURNING)) return

	if(!is_user_connected(attacker)) return

	if(!is_user_connected(og_burner)) return

	if(times<=0) return
	
	
	if(sh_get_id_bit(id, SH_IS_FROZEN)){
		sh_unfreeze_user(id)
		return
	}

	if(!is_tomie_user){
		emit_sound(id, CHAN_VOICE, gSoundScream, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}

	burn_structs[id][burn_attacker] = attacker
	burn_structs[id][burn_og_burner] = og_burner
	burn_structs[id][burn_times_left] = times
	burn_structs[id][burn_is_tomie_user] = is_tomie_user
	burn_structs[id][dmg_per_tick] = damage_per_tick
	burn_structs[id][spread_dist] = spread_radius
	burn_structs[id][burn_should_spread] = should_spread
	burn_structs[id][burn_custom_wpn_id] = custom_wpn_id

	sh_assign_id_bit(id, SH_IS_BURNING, true)
	
}


unburn_user(id){
	if ( !sh_is_active() ||!is_user_connected(id)) return

	sh_assign_id_bit(id, SH_IS_BURNING, false)

	if(!sh_get_id_bit(id, SH_IS_BURNING)) return

	unfade_screen_user(id)
	
	
	
}

public sh_client_death(id)
{
	unburn_user(id)
	
}