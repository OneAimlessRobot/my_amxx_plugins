
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_ENTITY_VECTORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_CUSTOM_COLORS
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../my_include/my_author_header.inc"

#define NITRO_TIMER_UPDATE_PERIOD 0.001

/*

	standing -> ducking factor
*/
#define NITRO_DUCKING_STANDING_HEIGHT_RATIO 0.5

// GLOBAL VARIABLES
new gHeroName[]="Nitro"
new g_is_running[SH_MAXSLOTS+1]
new Float:g_last_user_gametime[SH_MAXSLOTS+1],
		Float:g_curr_user_diff[SH_MAXSLOTS+1]


//cvar floats!

new pcvar_nitro_force,
	pcvar_nitro_air_drag,
	pcvar_mass,
	pcvar_car,
	pcvar_friction,
	pcvar_height


/*
		nitro_mass 1.0
		nitro_car 0.2
		nitro_friction 0.1
		nitro_height 1.0
*/

new const DEBUG = 0

#define PLAYER_AREA ((cvar_val(float,pcvar_height)*cvar_val(float,pcvar_height))*M_PI)
#define PLAYER_DRAG_CONST (PLAYER_AREA*cvar_val(float,pcvar_car))

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Nitro","1.0",AUTHOR)

	create_cvar("nitro_level", "20" )
	pcvar_mass = create_cvar("nitro_mass", "1.0",_,"Mass cannot be lower than zero",true, 0.1,false)
	pcvar_car = create_cvar("nitro_car", "0.2")
	pcvar_friction = create_cvar("nitro_friction", "0.1")
	pcvar_height = create_cvar("nitro_height", "1.0")
	pcvar_nitro_air_drag = create_cvar("nitro_air_drag_coeff", "0.5")
	pcvar_nitro_force = create_cvar("nitro_thrust_force_persec", "50.0")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Accelerate like a car!", "Accelerate on keydown! Wait to recharge...", true, "nitro_level" )

	RegisterHam(Ham_Player_PreThink,"player","Ham_Think_Pre",_,true)


}

public Ham_Think_Pre(id) {
	
	static Float:final_velocity_player[3],
			Float:velocity_player[3],
			Float:here_gametime,
			Float:propel_force,
			bool:ducking = false

	ducking = false
	here_gametime = my_get_gametime()

	if ( !sh_is_active() || sh_is_freezetime() ) return HAM_IGNORED
	
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)) return HAM_IGNORED

	if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(id,SH_USER_IS_FLYING)){

		g_last_user_gametime[id] = my_get_gametime()
		return HAM_IGNORED
	}
	if(!(entity_get_int(id, EV_INT_flags)&FL_INGROUND2)){

		g_last_user_gametime[id] = my_get_gametime()
		return HAM_IGNORED
	
	}
	if(!g_is_running[id]){

		g_last_user_gametime[id] = my_get_gametime()
		return HAM_IGNORED
	}
	if((entity_get_int(id, EV_INT_flags)&FL_DUCKING)){

		sh_chat_message(id,gHeroID,"We are ducking!")
		ducking = true
	}

	g_curr_user_diff[id] = here_gametime - g_last_user_gametime[id]

	if(g_curr_user_diff[id]<NITRO_TIMER_UPDATE_PERIOD){

		if(DEBUG){
			sh_chat_message(id,gHeroID,"Did we run this? Obtained gametime diff: %0.7f",g_curr_user_diff[id])
		}
		return HAM_IGNORED

	}

	propel_force = (cvar_val(float, pcvar_nitro_force)*g_curr_user_diff[id])/cvar_val(float, pcvar_mass)
	
	entity_set_float(id, EV_FL_friction,cvar_val(float, pcvar_friction))
	
	entity_get_vector(id,EV_VEC_velocity,velocity_player)

	new Float:speed = vector_length(velocity_player)

	my_velocity_by_aim(id,propel_force+speed,final_velocity_player,dummy_vector)

	if(DEBUG){
		sh_chat_message(id,gHeroID,"Initial speed: %0.7f",speed)

		sh_chat_message(id,gHeroID,"Employed thrust force: %0.7f",cvar_val(float, pcvar_nitro_force)*g_curr_user_diff[id])
	}

	final_velocity_player[2] = 0.0

	entity_set_vector(id,EV_VEC_velocity,final_velocity_player)

	
	speed = vector_length(final_velocity_player)


	if(DEBUG){
		sh_chat_message(id,gHeroID,"After thrust speed: %0.7f",speed)
	}
	
	
	new Float:the_force = player_air_drag_update_speed(id,(ducking?(NITRO_DUCKING_STANDING_HEIGHT_RATIO*NITRO_DUCKING_STANDING_HEIGHT_RATIO):1.0)*PLAYER_DRAG_CONST*cvar_val(float, pcvar_nitro_air_drag),g_curr_user_diff[id])


	if(DEBUG){
		sh_chat_message(id,gHeroID,"Obtained drag force: %0.7f",the_force)
	}

	entity_get_vector(id,EV_VEC_velocity,velocity_player)

	speed = vector_length(velocity_player)


	if(DEBUG){
		sh_chat_message(id,gHeroID,"After drag speed: %0.7f",speed)
	}

	g_last_user_gametime[id] = my_get_gametime()

	return HAM_IGNORED
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
	if(heroID!=gHeroID) return

	if(sh_get_user_has_hero(id, gHeroID)){
		g_is_running[id] = 0
	}
}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		nitro_kd(id)
	}
	
	case SH_KEYUP: {
		
		nitro_ku(id)
	}
}
}

//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public nitro_kd(id)
{

	if ( sh_is_freezetime() || !is_user_alive(id)||!is_user_connected(id))
	{
		sh_sound_deny(id)
		return
	}

	g_last_user_gametime[id] = my_get_gametime()
	
	g_is_running[id] = 1

	return
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYUP
public nitro_ku(id)
{
	g_is_running[id] = 0

}
public client_connect(id){
	g_is_running[id] = 0
	
}
public client_disconnected(id){
	g_is_running[id] = 0
	
}
//---------------------------------------------------------------------------------------------- 
public sh_client_spawn(id)
{
	g_is_running[id] = 0
}
//---------------------------------------------------------------------------------------------- 
