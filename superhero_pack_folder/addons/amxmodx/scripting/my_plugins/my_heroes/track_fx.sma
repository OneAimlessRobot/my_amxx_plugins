#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "chaff_fx_inc/chaff_fx.inc"
#include "track_fx_inc/track_fx.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define PLUGIN "Superhero track radiactive fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new RADIOACTIVE_TASK_ID

new generic_dmg_id_radiation_poison = -1


enum{
	
	TRACK_TASK_ATTACKER=0,
	TRACK_TASK_PLAYER_COUNT,
	TRACK_TASK_DO_DAMAGE,
	TRACK_TASK_DAMAGE_HEALTH_PCT,
	TRACK_TASK_TRACK_COLOR,
	TRACK_TASK_PERIOD,
	TRACK_TASK_CURR_IT,
	TRACK_TASK_NUM_ITS,
	NUM_INIT_TRACK_PARAMS


	
}

new dmg_source_name_short_tracked_vuln[SAFE_BUFFER_SIZE+1]="tracked_vuln"
new dmg_source_name_log_tracked_vuln[SAFE_BUFFER_SIZE+1]="tracked_vuln"
new custom_dmg_id_tracked_vuln

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	RADIOACTIVE_TASK_ID=allocate_typed_task_id(player_task)
	register_event("Damage", "tracked_damage", "b", "2!0")


	custom_dmg_id_tracked_vuln=sh_log_custom_damage_source(-1,
				dmg_source_name_short_tracked_vuln,
				dmg_source_name_log_tracked_vuln,
				0)
}

public plugin_cfg(){

	generic_dmg_id_radiation_poison = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_RADIATION_POISON)
}
public plugin_natives(){

	register_native("track_user","_track_user",0);
}

public tracked_damage(id)
{
	if ( !sh_is_active() || !is_user_alive(id)) return
	
	new  Float:damage= float(read_data(2))
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	if ( !is_user_connected(attacker)) return
	
	new fx_num_vic=(gatling_get_fx_num(id));
	switch(fx_num_vic){

		case RADIOACTIVE:{
			new Float:extraDamage = damage * RADIOACTIVE_DAMAGE_VULNERABILITY_COEFF - damage
			if (floatround(extraDamage)>0){
				sh_extra_damage(id, attacker, floatround(extraDamage),
											my_hitpoint_enum:bodypart,
											_,_,_,_,
											SH_NEW_DMG_RADIATION_POISON,
											custom_dmg_id_tracked_vuln)
			}
		}
	
	}
	
}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type, custom_weapon_id){
	if (!sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)) return DMG_FWD_PASS

	new fx_num_vic=(gatling_get_fx_num(victim));
	switch(fx_num_vic){

		case RADIOACTIVE:{
			new Float:extraDamage = damage * RADIOACTIVE_DAMAGE_VULNERABILITY_COEFF - damage
			if (floatround(extraDamage)>0){
				new_dmg_type=SH_NEW_DMG_RADIATION_POISON
				damage=floatround(extraDamage)
			}
		}
	}

	return DMG_FWD_PASS
}

public track_task(any:array[NUM_INIT_TRACK_PARAMS+SH_MAXSLOTS+1],id){
	id-=RADIOACTIVE_TASK_ID
	if(!is_user_alive(id)){
		
		sh_uneffect_user(id);
		return
	}
	if(gatling_get_fx_num(id)!=RADIOACTIVE){

		return
	}
	if(is_user_alive(array[TRACK_TASK_ATTACKER])){
		if(!sh_get_user_is_chaffed(id)){
			static client_name[128]
			static origin[3], eorigin[3],att_origin[3]
			static Float:Pos[3],Float:vEnd[3]
			new sh_custom_color:color_const=sh_custom_color:array[TRACK_TASK_TRACK_COLOR]
			get_user_name(id,client_name,127)
			
			get_user_origin(id, eorigin)
			get_user_origin(array[TRACK_TASK_ATTACKER], origin)
			get_user_origin(array[TRACK_TASK_ATTACKER], att_origin)			
			
			detect_user(array[TRACK_TASK_ATTACKER],id,vEnd);
			IVecFVec(origin,Pos)
			IVecFVec(eorigin,vEnd)
			new sh_custom_color:color_const_arr[3];
			arrayset(color_const_arr,color_const,sizeof color_const_arr)
			
			laser_line(array[TRACK_TASK_ATTACKER],Pos,vEnd,true,color_const_arr,true)
			for(new i=0;i<array[1];i++){
				if(!is_user_alive(array[i+NUM_INIT_TRACK_PARAMS])){
				
					continue
				}
				get_user_origin(array[i+NUM_INIT_TRACK_PARAMS], origin)
				
				detect_user(array[i+NUM_INIT_TRACK_PARAMS],id,vEnd);
				IVecFVec(origin,Pos)
				laser_line(array[i+NUM_INIT_TRACK_PARAMS],Pos,vEnd,true,color_const_arr,true)
				
			}
			sh_set_rendering(id, LineColors[color_const][0],  LineColors[color_const][1], LineColors[color_const][2], 255,kRenderFxGlowShell, kRenderTransColor)
			sh_screen_fade(id, 0.1, 0.9, LineColors[color_const][0], LineColors[color_const][1], LineColors[color_const][2],  50)
			aura(id,LineColors[color_const])
		}
		if(array[TRACK_TASK_DO_DAMAGE]){
			sh_extra_damage(id,array[TRACK_TASK_ATTACKER],floatround(
									float(get_user_health(id))*
									Float:array[TRACK_TASK_DAMAGE_HEALTH_PCT]),
							_,_,_,_,_,
							SH_NEW_DMG_RADIATION_POISON,
							generic_dmg_id_radiation_poison)
		}
		if(array[TRACK_TASK_CURR_IT]<array[TRACK_TASK_NUM_ITS]){
			
			array[TRACK_TASK_CURR_IT]++
			set_task(Float:array[TRACK_TASK_PERIOD],"track_task",id+RADIOACTIVE_TASK_ID,array, sizeof(array))
		}
		else{
			sh_uneffect_user(id);

		}
	}
	else{

		sh_uneffect_user(id);
	}
}


public _track_user(iPlugins, iParams){

	new id=get_param(1),
		attacker=get_param(2),
		do_damage=get_param(3),
		Float:damage_health_pct=get_param_f(4),
		Float:period=get_param_f(5),
		Float:time=get_param_f(6),
		sh_custom_color:track_color=sh_custom_color:get_param(7)

	
	if(!is_user_connected(id)||!is_user_connected(attacker)) return 

	new  radioactive_times=floatround(time/period)
	new players[SH_MAXSLOTS]
	new team_name[32]
	new player_count;
	gatling_set_fx_num(id, RADIOACTIVE)
	
	set_damage_icon(id,2,DMG_ICON_RADIATION,LineColors[track_color])

	get_user_team(attacker,team_name,32)
	get_players(players,player_count,"eah",team_name)

	new any:array[NUM_INIT_TRACK_PARAMS+SH_MAXSLOTS+1]
	array[TRACK_TASK_ATTACKER] = attacker
	array[TRACK_TASK_PLAYER_COUNT] = player_count
	array[TRACK_TASK_DO_DAMAGE] = do_damage
	array[TRACK_TASK_DAMAGE_HEALTH_PCT] = damage_health_pct
	array[TRACK_TASK_TRACK_COLOR] = track_color
	array[TRACK_TASK_CURR_IT] = 0
	array[TRACK_TASK_NUM_ITS] = radioactive_times
	array[TRACK_TASK_PERIOD] = period
	for(new i=0;i<player_count;i++){
		
		if(is_user_alive(players[i])){
			array[NUM_INIT_TRACK_PARAMS+i]=players[i]
		}
	}
	set_task(period,"track_task",id+RADIOACTIVE_TASK_ID,array, sizeof(array))



}