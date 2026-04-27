#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "co2_fx_inc/co2_fx.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


#define PLUGIN "Superhero co2 fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new UNCO2_TASKID
new is_cO2_mask=0

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	UNCO2_TASKID=allocate_typed_task_id(player_task)
	register_event("DeathMsg","on_death_co2","a")
	register_event("ResetHUD","co2_newround","b")

}

//----------------------------------------------------------------------------------------------
public co2_newround(id)
{	
	if(sh_is_active()&&client_hittable(id)){
		if(Get_BitVar(is_cO2_mask,id)){
			sh_unco2_user(id)
		}

	}
	
}

public plugin_natives(){
	
	register_native("sh_co2_user","_sh_co2_user",0);
	register_native("sh_unco2_user","_sh_unco2_user",0);
	register_native("sh_get_user_is_co2","_sh_get_user_is_co2",0);
}
public _sh_get_user_is_co2(iPlugin,iParams){
	new id= get_param(1);
	return Get_BitVar(is_cO2_mask,id)

}
public _sh_co2_user(iPlugin,iParams){
	
	new user=get_param(1)
	if(!Get_BitVar(is_cO2_mask,user)){
		co2_user(user)
	}
	
	
	
}
public plugin_precache(){
	
}

public _sh_unco2_user(iPlugin,iParams){
	
	new user=get_param(1)
	unco2_user(user)
	
	
	
	
}
public unco2_task(id){
	id-=UNCO2_TASKID
	
	if(!sh_is_active()||!is_user_connected(id)){
		
		return
	}
	unco2_user(id)
	
}
co2_user(id){
	if(!sh_is_active()||!client_hittable(id)) return
	sh_unmolly_user(id)
	set_render_with_color_const(id,LTGREEN,1,50,50,1,1)
	remove_glow_user(id,CO2_TIME)
	Set_BitVar(is_cO2_mask,id)
	set_damage_icon(id,2,DMG_ICON_GAS,LineColors[LTGREEN])
	set_task(CO2_TIME,"unco2_task",id+UNCO2_TASKID)
	
	
	
}
public unco2_user(id){
	
	sh_set_rendering(id)
	UnSet_BitVar(is_cO2_mask,id)
	set_damage_icon(id,0,DMG_ICON_GAS)
	
	
	
}

public on_death_co2()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		sh_unco2_user(id)
	
	}
	
}