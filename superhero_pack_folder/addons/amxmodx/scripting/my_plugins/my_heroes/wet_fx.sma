#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "wet_fx_inc/wet_fx.inc"
#include "shock_fx_inc/shock_fx.inc"
#include "ksun_inc/ksun_global.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define PLUGIN "Superhero wet fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new UNWET_TASKID = -1
new gHeroID_ksun = -1
new generic_dmg_source_cleanse = -1
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	UNWET_TASKID=allocate_typed_task_id(player_task)

}
public plugin_cfg(){

	gHeroID_ksun = spores_ksun_hero_id()
	generic_dmg_source_cleanse = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_CLEANSE)
	
	
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		unwet_user(id)
		

	}
}

public plugin_natives(){
	
	register_native("sh_wet_user","_sh_wet_user");
	register_native("sh_unwet_user","_sh_unwet_user");
}
public _sh_wet_user(iPlugin,iParams){
	
	new user=get_param(1),
		attacker= get_param(2)

	if(!sh_get_id_bit(user, SH_IS_WET)){
		wet_user(user,attacker)
	}
	
	
	
}

public _sh_unwet_user(iPlugin,iParams){
	
	new user=get_param(1)
	unwet_user(user)
	
	
	
}
public unwet_task(id){
	id-=UNWET_TASKID

	unwet_user(id)

}
wet_user(id,attacker){
	if(!sh_is_active()||!is_user_alive(id)||!is_user_connected(attacker)||sh_get_id_bit(id, SH_IS_WET)) return

	
	
	if(sh_get_user_has_hero(id, gHeroID_ksun)){

		sh_extra_damage(id,attacker,
						floatround(CLEAN_THE_WITCH_BLEACH_HER_MELT_THE_SLUG_WITH_CLOROX),
						_,
						SH_DMG_MULT,
						_,_,_,
						SH_NEW_DMG_CLEANSE,
						generic_dmg_source_cleanse)
		
		if(!sh_get_id_bit(id,SH_IS_SHOCKED)){
			sh_shock_user(id,attacker)
		}

	}
	else if(sh_get_id_bit(id,SH_IS_BURNING)){

		sh_unmolly_user(id)
	
	}


	set_render_with_color_const(id,BABY_BLUE,1,50,50,1,_,WET_TIME)
	sh_assign_id_bit(id, SH_IS_WET, true)
	set_damage_icon(id,2,DMG_ICON_BATTERY,LineColors[BABY_BLUE],WET_TIME)
	
	
	set_task(WET_TIME,"unwet_task",id+UNWET_TASKID)
	
	
	
}
unwet_user(id){
	
	if(!sh_is_active()||!is_user_connected(id)) return

	remove_task(id+UNWET_TASKID)
	if(sh_get_id_bit(id, SH_IS_WET)){
		
		sh_set_rendering(id)
		sh_assign_id_bit(id, SH_IS_WET, false)
	}
	
	if(sh_get_id_bit(id,SH_IS_SHOCKED)){
		sh_unshock_user(id)
	}
	
}

public sh_client_death(id)
{

	unwet_user(id)
	
}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart ,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,custom_weapon_id){
	if (!sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)|| (new_dmg_type!=SH_NEW_DMG_SHOCK)) return DMG_FWD_PASS

	if(sh_get_id_bit(victim, SH_IS_WET)){
		new Float:extraDamage = (damage * WET_SHOCK_DMG_MULTIPLIER) + damage+ WET_SHOCK_DMG_ADD
		if (floatround(extraDamage)>0){
			damage=floatround(extraDamage)
		}	
	}

	return DMG_FWD_PASS
}