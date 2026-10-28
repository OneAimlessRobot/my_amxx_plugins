#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "SH_AuxFun13: DMG gating"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt13.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "../my_include/auxiliar_stuff.inc"


#define THE_BITSUM_TO_EXCLUDE ( single_wpn_bs( CSW_KNIFE ) | single_wpn_bs (CSW_C4 ) )
#define ETHEREALS_CAN_USE_WPN(%1) (wpn_id_in_bs( (%1) , THE_BITSUM_TO_EXCLUDE ))


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);


	RegisterHam(Ham_TakeDamage,"player","ham_sh_damage_gating",_, true)
	
	RegisterHam( Ham_Touch, "armoury_entity", "fw_HamPlayerTouchPre", _,true);
	RegisterHam( Ham_Touch, "weaponbox", "fw_HamPlayerTouchPre" ,_,true);
	register_forward(FM_CmdStart,"fw_Ethereal_unnarmed")
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)

}

public plugin_cfg(){


	server_print("%s innited!^n",PLUGIN)
	
}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	
	if(!is_user_alive(player)){
		return FMRES_IGNORED
	}

	if(!sh_get_player_has_hero_prop(player,SH_ETHEREAL_HERO)){

		return FMRES_IGNORED
	}
	new weapon = get_user_weapon(player);
	if(ETHEREALS_CAN_USE_WPN(weapon)){
		return FMRES_IGNORED
	}
	set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
		
	return FMRES_HANDLED

}


//----------------------------------------------------------------------------------------------
public ham_sh_damage_gating(this, inflictor, attacker, Float:damage, damagebits)
{
	if(!sh_is_active()||sh_is_freezetime() ||!is_user_alive(this)) return HAM_IGNORED
	if ( damagebits & DMG_FALL && sh_get_player_has_hero_prop(this,SH_ANTI_FALL_DAMAGE_HERO) ){
		SetHamParamFloat(4,0.0)
		return HAM_SUPERCEDE
	}
	if(!is_valid_ent(inflictor)){

		return HAM_IGNORED
	}
	static inflictor_classname[64];

	entity_get_string(inflictor,EV_SZ_classname,inflictor_classname,63)
	static bool:it_was_a_grenade; it_was_a_grenade = bool:equal(inflictor_classname,"grenade")
	if( it_was_a_grenade &&
				sh_get_player_has_hero_prop(this,SH_ANTI_GRENADES_HERO) ){
		
		SetHamParamFloat(4,0.0)
		
		return HAM_SUPERCEDE
	}

	//ethereal players can ONLY be damaged by a very sparse selection of SH_NEW_DMG types
	//AND hand grenades, unless they have the ANTI_GRENADES_HERO property active

	if(sh_get_player_has_hero_prop(this,SH_ETHEREAL_HERO)){

		if(!it_was_a_grenade){


			SetHamParamFloat(4,0.0)
			
			return HAM_SUPERCEDE
		
		}
	}
	
	return HAM_IGNORED
}

public fw_HamPlayerTouchPre( iEntity, iPlayer ) {
	if( !is_user_alive( iPlayer ) ){
		return HAM_IGNORED;
	}
	
	
	static szModel[ 23 ];
	entity_get_string( iEntity, EV_SZ_model, szModel, charsmax( szModel ) );
	
	//ethereal players cannot pick up weapons from the ground!

	if(containi( szModel, "w_backpack" ) != -1 || !sh_get_player_has_hero_prop(iPlayer,SH_ETHEREAL_HERO)){
		return HAM_IGNORED;
	}
	
	return HAM_SUPERCEDE;
}


public dmg_fwd_ret_id:sh_extra_damage_fwd_pre(&victim, &attacker, &damage, &my_hitpoint_enum:bodypart,&sh_damage_mode:dmgMode, &sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type, custom_weapon_id){
	if ( !sh_is_active() || !is_user_alive(victim) || !is_user_alive(attacker)){
	
		return DMG_FWD_PASS
	}

	//ethereal players can ONLY be damaged by a very sparse selection of SH_NEW_DMG types
	//AND hand grenades, unless they have the ANTI_GRENADES_HERO property active


	if(!sh_get_player_has_hero_prop(victim,SH_ETHEREAL_HERO)){
		return DMG_FWD_PASS
	}
	new dmg_fwd_ret_id:the_return_value=DMG_FWD_PASS
	switch(new_dmg_type){


		case SH_NEW_DMG_BLEED,
					SH_NEW_DMG_DRAIN:{

				the_return_value = ((victim==attacker) ? DMG_FWD_PASS:  DMG_FWD_BLOCK)


		}
		case SH_NEW_DMG_SUPER_BULLET,
					SH_NEW_DMG_TR45H_GUN,
					SH_NEW_DMG_SUFFOCATION,
					SH_NEW_DMG_CLEANSE:{


				the_return_value = DMG_FWD_BLOCK
		}
		default:{

			the_return_value=DMG_FWD_PASS
		}



	}
	
	return the_return_value
}

public sh_round_start(){
	static the_players[SH_MAXSLOTS],
			pnum,
			id,
			the_weapons[32],
			wpn_num,
			wpn_item_id,
			bool:dropped_this_person_weapons
	
	get_players(the_players, pnum, "a")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]

		//ethereal heroes do NOT get weapons
		if(!sh_get_player_has_hero_prop(id,SH_ETHEREAL_HERO)){

			continue;
		}
		dropped_this_person_weapons = false;

		get_user_weapons(id,the_weapons,wpn_num);


		for (new j = 0; j < wpn_num; j++) {
			
			wpn_item_id = the_weapons[j]
			
			if(!ETHEREALS_CAN_USE_WPN(wpn_item_id)){

				sh_drop_weapon(id,wpn_item_id,true)
				dropped_this_person_weapons = true;
			}

		}
		if(dropped_this_person_weapons){
			sh_chat_message(id,-1,"The round has ended. ethereal heroes cannot use any firearms. They get destroyed")
		}
	}
}


public fw_Ethereal_unnarmed(id, uc_handle)
{
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if (!is_user_alive(id)){
		return FMRES_IGNORED
	}
	
	if(!sh_get_player_has_hero_prop(id,SH_ETHEREAL_HERO)){

		return FMRES_IGNORED
	}
	new bool:removed_attack = false;
	new button = get_uc(uc_handle, UC_Buttons);
	if(button & IN_ATTACK)
	{
		new weapon_id = get_user_weapon(id)
		if(!ETHEREALS_CAN_USE_WPN(weapon_id)){
			
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			removed_attack = true
		}
		
	}
	return (removed_attack?FMRES_SUPERCEDE:FMRES_IGNORED)
}