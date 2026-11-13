#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "co2_fx_inc/co2_fx.inc"
#include "tomie_yu_inc/tomie_yu.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"


#define PLUGIN "Superhero co2 fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new UNCO2_TASKID

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	UNCO2_TASKID=allocate_typed_task_id(player_task)

}
public plugin_cfg(){


	gHeroID = tomie_yu_hero_id()
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		unco2_user(id)
		

	}
}

public plugin_natives(){
	
	register_native("sh_co2_user","_sh_co2_user");
	register_native("sh_unco2_user","_sh_unco2_user");
}
public _sh_co2_user(iPlugin,iParams){
	
	new user=get_param(1)
	new Float:the_time = get_param_f(2)
	if(!sh_get_id_bit(user,SH_IS_CO2)){
		co2_user(user,the_time)
	}
	
	
	
}

public _sh_unco2_user(iPlugin,iParams){
	
	new user=get_param(1)
	unco2_user(user)
	
	
	
}
public unco2_task(id){
	id-=UNCO2_TASKID

	unco2_user(id)

}

public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart ,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,custom_weapon_id){
	if (!sh_is_active() || !is_user_alive(victim)) return DMG_FWD_PASS


	if((new_dmg_type!=SH_NEW_DMG_FIRE)){
		return DMG_FWD_PASS
	}

	if(sh_get_id_bit(victim, SH_IS_CO2)){
		damage = 0
		return DMG_FWD_BLOCK
	}

	return DMG_FWD_PASS
}


co2_user(id, Float:the_time){
	if(!sh_is_active()||!is_user_alive(id)||sh_get_id_bit(id,SH_IS_CO2)) return
	
	if(sh_get_id_bit(id,SH_IS_BURNING)){
		sh_unmolly_user(id)
	}

	sh_assign_id_bit(id,SH_IS_CO2,true)

	new bool:is_tomie_user=bool:sh_get_user_has_hero(id,gHeroID)

	new Float:time_to_apply_mult= (is_tomie_user?2.0:1.0)
	
	set_render_with_color_const(id,LTGREEN,1,50,50,1,_,
							the_time*time_to_apply_mult,_,_,kRenderNormal,PRIO_RENDER_EFFECT_ACTIVE)
	
	set_damage_icon(id,2,DMG_ICON_GAS,LineColors[LTGREEN],
							the_time*time_to_apply_mult)
	
	
	set_task(the_time*time_to_apply_mult,"unco2_task",id+UNCO2_TASKID)
	
	
	
}
unco2_user(id){
	
	if(!sh_is_active()||!is_user_connected(id)) return

	remove_task(id+UNCO2_TASKID)
	if(sh_get_id_bit(id,SH_IS_CO2)){
		remove_glow_user(id,PRIO_RENDER_EFFECT_ACTIVE,_,kRenderNormal)
		set_damage_icon(id,0,DMG_ICON_GAS)
		sh_assign_id_bit(id,SH_IS_CO2,false)
	}
	
	
}

public sh_client_death(id)
{
	unco2_user(id)
	
}