#include "../my_include/superheromod.inc"
#include <amxmisc>
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt4.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"


#define PLUGIN "SH_AuxFun4: generic DMG REG"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

enum extra_dmg_description_struct{

	new_dmg_type_name[32],
	new_dmg_type_description[100],
	
	bool:dmg_type_is_melee

}

stock const new_dmg_type_descriptions_arr[sh_thrash_brat_dmg_type][extra_dmg_description_struct] = {
	
	
	{"SH_Unnamed_Damage", "Typeless damage", false},
	{"SH_Energy_Blast", "Energy blast damage", false},
	{"SH_Drain", "Poison ivy is an infamous example. She isnt poison!", false},

	{"SH_Super_Bullet", "Powerful firearms", false},
	{"SH_Bleed", "Self explanatory", false},
	{"SH_Drug_Poison", "Chemical poison (Shinobu is an example of its usage)", false},

	{"SH_Squashed", "Typically when the user gets struck with overwhelming damage", true},
	{"SH_Shock", "Electrical shock. May come with getting sh stunned", false},
	{"SH_Frag_Blast", "Comventional explosions, big or small", false},

	{"xXx_SH_DarkShadowBlade_xXx", "Heroes that watch too much anime use this", true},
	{"SH_Dark_Arts", "Dirty tactics, employed by heroes that should not be trusted", false},
	{"SH_Fire", "Self explanatory. Some heroes may have a resistance", false},

	{"SH_Radiation_Poison", "Radiation sickness", false},
	{"SH_Blunt_Trauma", "Blunt force trauma. Like getting bashed in the head", false},
	{"SH_Freeze", "Frozen. Frostbite might make the user fragile", false},

	{"SH_Super_Melee", "Incisive melee attacks", true},
	{"SH_Suffocation", "Some heroes can self suffocate!", true},
	{"SH_Cleanse", "Heroes that commit plenty of sin are most susceptible", false},
	
	{"SH_Tr45H_Gun", "Damage from recycled weapons. Only a few heroes use this", false}
	

}

stock dmg_source_array[sh_thrash_brat_dmg_type]

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_concmd(check_what_damage_types_exist,check_what_damage_types_exist,ADMIN_ALL)
	prepare_shero_aux_lib_pt4()

    
	
}

stock sh_check_existing_damage_types_aux(id){


	console_print(id,"The hero damage types in this server are:^n")
	static var = sh_thrash_brat_dmg_type;
	if(var<=0){


		console_print(id,"None are registered!^n")
		return
	}
	for(new sh_thrash_brat_dmg_type:i=enum_zero;i<sh_thrash_brat_dmg_type;i++){

		console_print(id,"Name: %s^n",
								new_dmg_type_descriptions_arr[i][new_dmg_type_name])

		console_print(id,"Description: %s^n",
								new_dmg_type_descriptions_arr[i][new_dmg_type_description])

		console_print(id,"Is this considered melee?: %s^n",
								new_dmg_type_descriptions_arr[i][dmg_type_is_melee]?"Yes!":"No...")
		
		
	}

}
public sh_check_existing_damage_types(id,level,cid){

	if (!cmd_access(id,level,cid,0))
		return PLUGIN_HANDLED

	
	sh_check_existing_damage_types_aux(id)

	return PLUGIN_HANDLED
}
public plugin_natives(){


	register_native("prepare_shero_aux_lib_pt4","_prepare_shero_aux_lib_pt4");
	register_native("get_weapon_id_for_generic_dmg_source","_get_weapon_id_for_generic_dmg_source");
	register_native("get_name_of_generic_dmg_source","_get_name_of_generic_dmg_source");

}

public _get_name_of_generic_dmg_source(iPlugins, iParams){

	new sh_thrash_brat_dmg_type:dmg_source=sh_thrash_brat_dmg_type:get_param(1)


	dmg_source=(((dmg_source>=sh_thrash_brat_dmg_type || dmg_source < enum_zero))?enum_zero:dmg_source)

	set_string(2,new_dmg_type_descriptions_arr[dmg_source][new_dmg_type_name],31)

	
}

public _get_weapon_id_for_generic_dmg_source(iPlugins, iParams){

	new sh_thrash_brat_dmg_type:dmg_source=sh_thrash_brat_dmg_type:get_param(1)	
	
	if(dmg_source>=sh_thrash_brat_dmg_type || dmg_source < enum_zero){

		return sh_get_generic_dmg_source_wpn_id()
	}
	return dmg_source_array[dmg_source]
	
}

public _prepare_shero_aux_lib_pt4(iPlugins, iParams){
	
	for( new sh_thrash_brat_dmg_type:i=enum_zero;i<sh_thrash_brat_dmg_type;i++){
		dmg_source_array[i]=sh_log_custom_damage_source(
								-1,
								new_dmg_type_descriptions_arr[i][new_dmg_type_name],
								new_dmg_type_descriptions_arr[i][new_dmg_type_name],
								new_dmg_type_descriptions_arr[i][dmg_type_is_melee])
	}
	server_print("%s innited!^n",PLUGIN)
}
