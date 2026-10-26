#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#include "../my_include/superheromod.inc"
#include "chaff_fx_inc/chaff_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"


#define PLUGIN "Superhero chaff fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new CHAFF_TASKID

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	CHAFF_TASKID=allocate_typed_task_id(player_task)

}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		unchaff_user(id)
		

	}
}

public plugin_natives(){
	
	register_native("sh_chaff_user","_sh_chaff_user");
	register_native("sh_unchaff_user","_sh_unchaff_user");
}
public _sh_chaff_user(iPlugin,iParams){
	
	new user=get_param(1)
	if(!sh_get_id_bit(user, SH_IS_CHAFFED)){
		chaff_user(user)
	}
	
	
	
}

public _sh_unchaff_user(iPlugin,iParams){
	
	new user=get_param(1)
	unchaff_user(user)
	
	
	
}
chaff_user(id){
	if(!sh_is_active()||!is_user_alive(id)||sh_get_id_bit(id, SH_IS_CHAFFED)) return



	sh_assign_id_bit(id, SH_IS_CHAFFED, true)
	
	
	new param[1]

	param[0] = floatround(CHAFF_TIMES) 
	
	
	chaff_task(param,id+CHAFF_TASKID)
	
	
	
}

public chaff_task(array[1], id){

	id-=CHAFF_TASKID


	if(!sh_is_active()||!is_user_alive(id)){
		
		return
	
	}
	else if(!sh_get_id_bit(id, SH_IS_CHAFFED)||!array[0]){

		unchaff_user(id)
	}
	else{
		
		array[0]--

		set_render_with_color_const(id,WHITE,1,CHAFF_ALPHA,15,1,_,CHAFF_PERIOD,_,_,_,PRIO_RENDER_DELETE_INVISIBILITY)
		
	
		set_damage_icon(id,2,DMG_ICON_BATTERY,LineColors[WHITE],CHAFF_PERIOD)
	
		set_task(CHAFF_PERIOD,"chaff_task",id+CHAFF_TASKID,array,1)

	}

}
unchaff_user(id){
	
	if(!sh_is_active()||!is_user_connected(id)) return

	if(sh_get_id_bit(id, SH_IS_CHAFFED)){
		sh_assign_id_bit(id, SH_IS_CHAFFED, false)
	}
	
	
}

public sh_client_death(id)
{

	unchaff_user(id)
	
}