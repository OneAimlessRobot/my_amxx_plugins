#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_molotov_fx.inc"
#include "chaff_fx_inc/chaff_fx.inc"
#include "tomie_yu_inc/tomie_yu.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


#define PLUGIN "Superhero chaff fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new UNCHAFF_TASKID
new is_chaff_mask=0

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	UNCHAFF_TASKID=allocate_typed_task_id(player_task)

}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		unchaff_user(id)
		

	}
}

public plugin_natives(){
	
	register_native("sh_chaff_user","_sh_chaff_user",0);
	register_native("sh_unchaff_user","_sh_unchaff_user",0);
	register_native("sh_get_user_is_chaffed","_sh_get_user_is_chaffed",0);
}
public _sh_get_user_is_chaffed(iPlugin,iParams){
	new id= get_param(1);
	return Get_BitVar(is_chaff_mask,id)

}
public _sh_chaff_user(iPlugin,iParams){
	
	new user=get_param(1)
	if(!Get_BitVar(is_chaff_mask,user)){
		chaff_user(user)
	}
	
	
	
}

public _sh_unchaff_user(iPlugin,iParams){
	
	new user=get_param(1)
	unchaff_user(user)
	
	
	
}
public unchaff_task(id){
	id-=UNCHAFF_TASKID

	unchaff_user(id)

}
chaff_user(id){
	if(!sh_is_active()||!is_user_alive(id)||Get_BitVar(is_chaff_mask,id)) return

	set_render_with_color_const(id,WHITE,1,50,50,1,_,CHAFF_TIME)
	Set_BitVar(is_chaff_mask,id)
	set_damage_icon(id,2,DMG_ICON_SHOCK,LineColors[WHITE],CHAFF_TIME)
	
	
	set_task(CHAFF_TIME,"unchaff_task",id+UNCHAFF_TASKID)
	
	
	
}
public unchaff_user(id){
	
	if(!sh_is_active()||!is_user_connected(id)) return

	if(Get_BitVar(is_chaff_mask,id)){
		sh_set_rendering(id)
		UnSet_BitVar(is_chaff_mask,id)
		set_damage_icon(id,0,DMG_ICON_GAS)
	}
	
	
}

public sh_client_death(id)
{

	unchaff_user(id)
	
}