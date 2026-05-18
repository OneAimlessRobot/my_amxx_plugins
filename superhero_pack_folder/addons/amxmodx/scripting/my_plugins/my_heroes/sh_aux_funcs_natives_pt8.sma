#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt8: safeguard forward tools for shmod"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt8.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt8.inc"
#include "../my_include/auxiliar_stuff.inc"

new gMessageId_curweapon,
	gMessageId_Armor
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