#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt8: safeguard forward tools for shmod"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "maria_riveter_inc/maria_riveter_funcs.inc"
#include "shinobu_knife/shinobu_general.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt8.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt8.inc"
#include "../my_include/auxiliar_stuff.inc"

new gMessageId_curweapon,
	gMessageId_Armor

new gHeroID_Maria = -1,
	gHeroID_Shinobu = -1

#define MAX_INCOMPATIBILITY_PAIRS 32
const curr_num_of_pairs = 1
new filled_pair_count = 0
enum superhero_incompatibility_pair{

	pair_hero_a,
	pair_hero_b

}

new sh_incompatibility_pairs[curr_num_of_pairs][superhero_incompatibility_pair]

public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward(FM_CmdStart, "CmdStart")

	gMessageId_curweapon = get_user_msgid("CurWeapon")
	gMessageId_Armor = get_user_msgid("Battery")
	
	//fix negative ammo stuff
	register_message(gMessageId_curweapon, "on_CurWeapon_msg")
	// fix armor display for absurd values
	register_message(gMessageId_Armor, "on_Battery_msg")
	
}
public plugin_cfg(){

	gHeroID_Maria = maria_get_hero_id()
	gHeroID_Shinobu = shinobu_get_hero_id()

	push_incompatibility_pair(gHeroID_Maria,gHeroID_Shinobu)
}
public push_incompatibility_pair(hero_a,hero_b){

	if((hero_a<0)||(hero_a>SH_MAXHEROS)||(hero_b<0)||(hero_b>SH_MAXHEROS)||(hero_a==hero_b)){
		return
	}
	if(filled_pair_count>=curr_num_of_pairs){

		return
	}
	sh_incompatibility_pairs[filled_pair_count][pair_hero_a]= hero_a
	sh_incompatibility_pairs[filled_pair_count][pair_hero_b]= hero_b
	
	filled_pair_count++
}
public safeguard_pair_process(id,heroID,heroID_a,heroID_b,mode){


	if(mode==SH_HERO_DROP){
		return INIT_FWD_PASS
	}
	if(!is_user_connected(id)){
		return INIT_FWD_PASS
	}
	new bool:has_b=sh_user_has_hero(id,heroID_b),
			bool:has_a=sh_user_has_hero(id,heroID_a)
	static name_a[MAX_HERO_NAME_LENGTH],
			name_b[MAX_HERO_NAME_LENGTH]

	sh_get_hero_name_from_id(heroID_b,name_b)
	sh_get_hero_name_from_id(heroID_a,name_a)

	sh_chat_message(id,-1,"You cannot use the heroes %s and %s at once!",name_b,name_a)

	if((heroID==heroID_a)&&has_b){
		
		
		sh_strip_user_hero(id, heroID_a)
		return INIT_FWD_BLOCK
		
	}
	if((heroID==heroID_b)&&has_a){
		
		
		sh_strip_user_hero(id, heroID_b)
		return INIT_FWD_BLOCK
		
	}
	return INIT_FWD_PASS

	
}
public sh_hero_init_pre(id,heroID,mode){
	new true_return_result = INIT_FWD_PASS

	for(new i=0;i<filled_pair_count;i++){


		true_return_result = max(
			safeguard_pair_process(id,
					heroID,
					sh_incompatibility_pairs[i][pair_hero_a],
					sh_incompatibility_pairs[i][pair_hero_b],
					mode),
					true_return_result)
		
	}

	return true_return_result
}
//-------
public on_Battery_msg(msgid, dest, id){

	if ( !is_user_alive(id) ) return

	static the_armor_ammount
	the_armor_ammount = get_msg_arg_int(1)

	if ( the_armor_ammount > 999) {
		set_msg_arg_int(1, ARG_SHORT, 999)
	}
}
//-------
public on_CurWeapon_msg(msgid, dest, id){

	if ( !is_user_alive(id) ) return

	static the_clip_ammo_ammount
	the_clip_ammo_ammount = get_msg_arg_int(3)

	if ( the_clip_ammo_ammount > (nth_power_of_two(SIZE_OF_BYTE-1)-1)) {
		set_msg_arg_int(3, ARG_BYTE, (nth_power_of_two(SIZE_OF_BYTE-1)-1))
	}
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if(!sh_is_active()){
		return FMRES_IGNORED
	}

	/*
	freese time is freeze time.
	I dont want any "b- but veronika fire grenades in freeze t--"
	Shut your ASS up with that WEAK shit.
	Wait until freeze time is over you impatient goon
	Get actual adult issues
	*/

	if(!sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)){
			
		return FMRES_IGNORED
	}

	new button = get_uc(uc_handle, UC_Buttons);

	if((button& IN_ATTACK) ||(button& IN_ATTACK2)){
		button &= ~IN_ATTACK
		button &= ~IN_ATTACK2

		set_uc(uc_handle,UC_Buttons,button)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}
public sh_client_spawn(id){

	sh_give_weapon(id,CSW_KNIFE)
		
}