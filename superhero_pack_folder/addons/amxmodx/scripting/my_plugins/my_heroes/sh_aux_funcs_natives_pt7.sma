#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt7: sh player custom sound effects tools"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt7.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt7.inc"

#define is_valid_sound(%1) ((%1)>=0)

#define is_player_playing_sound(%1,%2) (is_valid_sound( g_last_played_sound[%1][%2])) 

#define SH_MAX_CUSTOM_SOUNDS 90
#define MAX_CHANNELS 8
/**

#define CHAN_AUTO       0
#define CHAN_WEAPON     1
#define CHAN_VOICE      2
#define CHAN_ITEM       3
#define CHAN_BODY       4
#define CHAN_STREAM     5   // allocate stream channel from the static or dynamic area
#define CHAN_STATIC     6   // allocate channel from the static area 
#define CHAN_NETWORKVOICE_BASE  7   // voice data coming across the network

*/
// emit_sound:

/**
	returns nothing!
	void engfunc(EngFunc_EmitSound, 
					entity,
					int channel,
					const char *sample,
					float volume,
					float attenuation,
					int fFlags,
					int pitch)
 */
// precache_sound:

/**
	returns sound id!

	int engfunc(EngFunc_PrecacheSound, const char *sample);

 */
enum sh_custom_sound_struct{

	sound_precache_id,
	sound_file_name[STRING_SIZE]

}
new curr_sound_count = 0

new g_sound_structs_arr[SH_MAX_CUSTOM_SOUNDS][sh_custom_sound_struct]

new g_last_played_sound[SH_MAXSLOTS+1][MAX_CHANNELS]

public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);


}
public plugin_cfg(){


prepare_shero_aux_lib_pt7()


}
public plugin_natives(){


	register_native("prepare_shero_aux_lib_pt7","_prepare_shero_aux_lib_pt7",0);
	register_native("sh_play_custom_sound","_sh_play_custom_sound",0);
	register_native("sh_register_custom_sound","_sh_register_custom_sound",0);
	register_native("sh_stop_custom_sound","_sh_stop_custom_sound",0);
}

public _prepare_shero_aux_lib_pt7(iPlugins, iParams){
	

	server_print("%s innited!^n",LIBRARY_NAME)
}
/**

native sh_play_custom_sound(id,sound_id,channel,
            Float:volume=VOL_NORM,
            Float:attenuation=ATTN_NONE,
            flags=0,
            pitch=PITCH_NORM)

native sh_stop_custom_sound(id,sound_id,channel)

 */

play_custom_sound_primitive(id,sound_id,channel,
            Float:volume=VOL_NORM,
            Float:attenuation=ATTN_NONE,
            flags=0,
            pitch=PITCH_NORM){

	if(!is_user_alive(id)) return

	if(!is_valid_sound(sound_id)) return

	if(is_player_playing_sound(id,channel)) return
	
	engfunc(EngFunc_EmitSound, 
					id,
					channel,
					g_sound_structs_arr[sound_id][sound_file_name],
					volume,
					attenuation,
					flags,
					pitch)

	g_last_played_sound[id][channel] = sound_id
	

}
public plugin_precache(){

	engfunc(EngFunc_PrecacheSound,NULL_SOUND)

}
stop_curr_sound_on_player_channel(id,channel){


	if(!is_player_playing_sound(id,channel)) return
		
	new the_curr_channel_sound=g_last_played_sound[id][channel]
	engfunc(EngFunc_EmitSound, 
				id,
				channel,
				g_sound_structs_arr[the_curr_channel_sound][sound_file_name],
				VOL_NORM,
				ATTN_NORM,
				SND_STOP,
				PITCH_NORM)
	engfunc(EngFunc_EmitSound, 
				id,
				channel,
				NULL_SOUND,
				VOL_NORM,
				ATTN_NORM,
				0,
				PITCH_NORM)


	g_last_played_sound[id][channel] = -1
}
stop_all_player_sounds_primitive(id){

	for(new i=0;i<MAX_CHANNELS;i++){
		if(!is_player_playing_sound(id,i)) continue
		
		stop_curr_sound_on_player_channel(id,i)

	}
	
	

	

}
public _sh_play_custom_sound(iPlugins, iParams){
	new id = get_param(1),
		channel = get_param(2),
		sound_id = get_param(3),
		Float:volume = get_param_f(4),
		Float:attenuation = get_param_f(5),
		flags = get_param(6),
		pitch = get_param(7)

	play_custom_sound_primitive(id,sound_id,channel,
					volume,
					attenuation,
					flags,
					pitch)


		

}

public _sh_stop_custom_sound(iPlugins, iParams){

	new id = get_param(1),
		channel = get_param(2)

	stop_curr_sound_on_player_channel(id,channel)

}
public _sh_register_custom_sound(iPlugins, iParams){


	if(curr_sound_count>=SH_MAX_CUSTOM_SOUNDS){

		return -1
	}
	get_string(1,
			g_sound_structs_arr[curr_sound_count][sound_file_name],
			STRING_SIZE)

	g_sound_structs_arr[curr_sound_count][sound_precache_id] = engfunc(EngFunc_PrecacheSound,
					g_sound_structs_arr[curr_sound_count][sound_file_name]);
	
	new returned_value=curr_sound_count
	
	curr_sound_count++

	return returned_value
	
}

public sh_round_end(){
	stop_all_player_sounds_primitive(0)
	
	for(new i=1;i<sh_maxplayers()+1;i++){

		stop_all_player_sounds_primitive(i)

	}
	
}
public sh_client_death(victim,attacker,headshot,const wpnDescription[]){

	
	stop_all_player_sounds_primitive(victim)

	
}