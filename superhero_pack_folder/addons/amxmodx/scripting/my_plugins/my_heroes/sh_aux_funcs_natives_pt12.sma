#define I_WANT_CONSTANTS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt12: superhero property enforcing pt1: health caps"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt12.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt11.inc"
#include "../my_include/auxiliar_stuff.inc"

static bool:lib_initted = false;

/*
	false == min health mode
	true == max health mode

*/
static bool:lib_mode = false;

static Float:sh_player_healthcap_table[SH_MAXSLOTS+1]
enum sh_healthcap_hero_struct{

	hero_id_to_use,
	Float:hp_in_the_struct


}
#define TRUE_MAX_HEALTHCAPS 40


new curr_num_healthcaps = 0

new sh_hero_healthcaps[TRUE_MAX_HEALTHCAPS][sh_healthcap_hero_struct]

new gMessageID_Health = -1

public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	sh_init_healthcap_lib(false)


	gMessageID_Health = get_user_msgid("Health")

	register_message(gMessageID_Health, "SH_Limit_player_Hp")

}


//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	if(!is_user_alive(id)||!sh_is_active()){
		
		return
	}

	if ( sh_get_player_has_hero_prop(id,SH_HEALTH_CAP_HERO) ) {
		
		force_hp_refresh(id)
		
	}
}
public plugin_cfg(){


	server_print("%s innited!^n",LIBRARY_NAME)
	
}

public plugin_natives(){

	register_native("sh_get_player_healthcap","_sh_get_player_healthcap")
	register_native("generic_heal","_generic_heal")
	register_native("sh_register_hero_healthcap","_sh_register_hero_healthcap")
}
/*
	false == min health mode
	true == max health mode

*/
sh_init_healthcap_lib(bool:mode){

	if(lib_initted){
		return
	}

	lib_mode = mode

	lib_initted = true

	lib_mode?
	(arrayset(sh_player_healthcap_table,-1.0,sizeof(sh_player_healthcap_table))):
	(arrayset(sh_player_healthcap_table,99999999.0,sizeof(sh_player_healthcap_table)))
	
}

public Float:_sh_get_player_healthcap(iPlugin,iParams){

	new id = get_param(1)

	return sh_player_healthcap_table[id]
}

public bool:_generic_heal(iPlugins, iParms){
	new hud_msg_sync=get_param(1),
		id= get_param(2),
		Float:added_hp=get_param_f(3),
		max_hp_to_clamp=get_param(4),
		sh_custom_color:color_const=sh_custom_color:get_param(5),
		user_will_glow=get_param(6),
		Float:glow_remove_timer=get_param_f(7),
		hud_alpha=get_param(8),
		hud_will_glow=get_param(9),
		make_sound=get_param(10),
		Float: mate_health=float(get_user_health(id))

	
	max_hp_to_clamp = (max_hp_to_clamp > 0) ?(min(max_hp_to_clamp,
				sh_get_player_has_hero_prop(id,SH_HEALTH_CAP_HERO)
						?
				floatround(sh_player_healthcap_table[id])
						:
					sh_get_max_hp(id)))
						:
					sh_get_max_hp(id)

	if(((max_hp_to_clamp)<=mate_health)){
		
		return false
	
	}
	if(make_sound){

		static sound_sample_string[128]

		get_string(11,sound_sample_string,127)
		emit_sound(id, CHAN_STATIC, sound_sample_string, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	new Float: true_hp_to_add = floatmax(0.0, floatmin(added_hp, float(max_hp_to_clamp) - mate_health))
	new Float: new_health=floatadd(mate_health,true_hp_to_add)
	
	entity_set_float(id,EV_FL_health,new_health)

	if(user_will_glow>0){
		set_render_with_color_const(id,color_const,user_will_glow,_,hud_alpha,hud_will_glow,_,glow_remove_timer)
	}
	if(hud_msg_sync>0){
		
		set_hudmessage(LineColors[color_const][0], LineColors[color_const][1], LineColors[color_const][2], -1.0, 0.48, 2, 0.1, 2.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(id, hud_msg_sync, "%0.2f", true_hp_to_add)
	
	}
	return true

}

public bool:_sh_register_hero_healthcap(iPlugin, iParams){

	new heroID = get_param(1),
		Float:healthcap = get_param_f(2)

	if(curr_num_healthcaps >= TRUE_MAX_HEALTHCAPS){

		return false
	}

	if((heroID <0) || (heroID >= SH_MAXHEROS)){

		return false
	}

	if(healthcap < 1.0){

		return false
	}
	if(!sh_get_hero_bit(heroID,SH_HEALTH_CAP_HERO)){

		sh_assign_hero_bit(heroID,SH_HEALTH_CAP_HERO, true)
	}

	sh_hero_healthcaps[curr_num_healthcaps][hero_id_to_use] = heroID


	sh_hero_healthcaps[curr_num_healthcaps][hp_in_the_struct] = healthcap

	curr_num_healthcaps++

	return true

}

public SH_Limit_player_Hp(msgid, dest, id)
{
	if(!sh_is_active()) return

	if(!is_user_alive(id)) return

	if(!sh_get_player_has_hero_prop(id,SH_HEALTH_CAP_HERO)) return

	new the_health_to_be_set = get_msg_arg_int(1)

	new the_resulting_health =
					 min(floatround(sh_player_healthcap_table[id]),the_health_to_be_set)
	
	set_user_health(id,the_resulting_health)
	
	if ( the_resulting_health <= 255 ) {
		set_msg_arg_int(1, ARG_BYTE, the_resulting_health)
	}

}
stock print_player_hero_prop_flags(id){
	server_print("The state of hero healthcap for this player is:^n^n")
	

}
recalculate_hp_cap_for_player(id){

	new Float:tmp_value= (lib_mode?-1.0:99999999.0)
	for(new i=0; i<curr_num_healthcaps; i++){

		if(sh_get_user_has_hero(id,sh_hero_healthcaps[i][hero_id_to_use])){

			tmp_value = (lib_mode?
						floatmax(tmp_value,sh_hero_healthcaps[i][hp_in_the_struct]):
						floatmin(tmp_value,sh_hero_healthcaps[i][hp_in_the_struct]))


		}

	}
	sh_player_healthcap_table[id]= tmp_value

}

force_hp_refresh(id){

	new Float:curr_user_hp = 1.0
		
	pev(id,pev_health,curr_user_hp)

	if(curr_user_hp<=sh_player_healthcap_table[id]){
		return
	}

	new Float:the_health_to_send = floatmin(curr_user_hp, sh_player_healthcap_table[id])
	

	new i_health_to_send = floatround(the_health_to_send)

	set_user_health(id, i_health_to_send)

	message_begin(MSG_ONE_UNRELIABLE, gMessageID_Health, {0,0,0}, id);		
	write_byte(i_health_to_send);
	message_end();
	
}
public sh_hero_init(id,heroID, sh_init_mode:mode){
	
	if(!client_is_within_range(id)){

		return
	}

	if((heroID<0)||(heroID >= SH_MAXHEROS)){
		return
	}
	if(sh_get_hero_bit(heroID,SH_HEALTH_CAP_HERO)){

		recalculate_hp_cap_for_player(id)
		force_hp_refresh(id)
	}
	

}