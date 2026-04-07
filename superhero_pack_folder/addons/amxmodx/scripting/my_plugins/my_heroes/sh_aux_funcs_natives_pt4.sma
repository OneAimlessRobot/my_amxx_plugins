#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include <fakemeta_util>
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define PLUGIN "Superhero aux natives pt4: generic damage source registering"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
/*



enum sh_thrash_brat_dmg_type{
	SH_NEW_DMG_NONE=0,
	SH_NEW_DMG_ENERGY_BLAST,
	SH_NEW_DMG_DRAIN,
	SH_NEW_DMG_SUPER_BULLET,
	SH_NEW_DMG_BLEED,
	SH_NEW_DMG_DRUG_POISON,
	SH_NEW_DMG_SQUASHED,
	SH_NEW_DMG_SHOCK,
	SH_NEW_DMG_FRAG_BLAST,
	SH_NEW_DMG_IVE_STUDIED_THE_BLADE,
	SH_NEW_DMG_MAX_DAMAGES

}
stock const new_dmg_type_names[_:SH_NEW_DMG_MAX_DAMAGES][32]={
	"SH_Unnamed_Damage",
	"SH_Energy_Blast",
	"SH_Drain",
	"SH_Super_Bullet",
	"SH_Bleed",
	"SH_Drug_Poison",
	"SH_Squashed",
	"SH_Shock",
	"SH_Frag_Blast",
	"xXxSH_DarkShadowBladexXX"
}
 */
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
	server_print("Shero lib pt4 innited!^n")
}
