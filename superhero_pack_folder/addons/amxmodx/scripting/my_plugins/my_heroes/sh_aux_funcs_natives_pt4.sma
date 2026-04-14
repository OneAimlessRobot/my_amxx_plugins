#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt4.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define PLUGIN "Superhero aux natives pt4: generic damage source registering"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

stock dmg_source_array[_:SH_NEW_DMG_MAX_DAMAGES]

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	prepare_shero_aux_lib_pt4()

    
	
}			
public plugin_natives(){


	register_native("prepare_shero_aux_lib_pt4","_prepare_shero_aux_lib_pt4",0);
	register_native("get_weapon_id_for_generic_dmg_source","_get_weapon_id_for_generic_dmg_source",0);

}

public _get_weapon_id_for_generic_dmg_source(iPlugins, iParams){

	new sh_thrash_brat_dmg_type:dmg_source=sh_thrash_brat_dmg_type:get_param(1)	
	
	if(dmg_source>=SH_NEW_DMG_MAX_DAMAGES || dmg_source < sh_thrash_brat_dmg_type:0){

		return sh_get_generic_dmg_source_wpn_id()
	}
	return dmg_source_array[_:dmg_source]
	
}

public _prepare_shero_aux_lib_pt4(iPlugins, iParams){
	
	for( new i=0;i<_:SH_NEW_DMG_MAX_DAMAGES;i++){
		dmg_source_array[i]=sh_log_custom_damage_source(
								-1,
								new_dmg_type_names[i],
								new_dmg_type_names[i],
								0)
	}
	server_print("%s innited!^n",LIBRARY_NAME)
}
