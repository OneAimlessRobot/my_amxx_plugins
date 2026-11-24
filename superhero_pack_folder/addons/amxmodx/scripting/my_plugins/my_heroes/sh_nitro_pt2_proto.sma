

/*


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

#define NITRO_TIMER_UPDATE_PERIOD 0.1
#define NITRO_CAR_CLASSNAME "nitro_car"

// GLOBAL VARIABLES
#define gHeroName "Nitro"
new g_is_running[SH_MAXSLOTS+1]


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
	pcvar_mass = create_cvar("nitro_mass", "1.0")
	pcvar_car = create_cvar("nitro_car", "0.2")
	pcvar_friction = create_cvar("nitro_friction", "0.1")
	pcvar_height = create_cvar("nitro_height", "1.0")
	pcvar_nitro_air_drag = create_cvar("nitro_air_drag_coeff", "0.5")
	pcvar_nitro_force = create_cvar("nitro_thrust_force_persec", "50.0")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Accelerate like a car!", "Accelerate on keydown! Wait to recharge...", true, "escapist_level" )

	register_think(NITRO_CAR_CLASSNAME, "nitro_car_think")


}

spawn_car(id){


	
}
public nitro_car_think(car_id){

	static Float:final_velocity_player[3],
			Float:velocity_player[3],
			Float:here_gametime,
			Float:propel_force

	if(!is_valid_ent(car_id)){

		return PLUGIN_CONTINUE
	}

	static owner; owner= entity_get_edict(car_id, EV_ENT_owner)

	if(!is_user_alive(owner)){

		remove_entity(car_id)
		return PLUGIN_CONTINUE
	}

	if(sh_get_id_bit(owner, SH_CONTROLLING_VEHICLE)||sh_get_id_bit(owner,SH_USER_IS_FLYING)){

		remove_entity(car_id)
		return HAM_IGNORED
	}
	if(!g_is_running[owner]){

		remove_entity(car_id)
		return HAM_IGNORED
	}


	propel_force = cvar_val(float, pcvar_nitro_force)*NITRO_TIMER_UPDATE_PERIOD

	
	entity_set_float(owner, EV_FL_friction,cvar_val(float, pcvar_friction))
	
	entity_get_vector(owner,EV_VEC_velocity,velocity_player)

	new Float:speed = vector_length(velocity_player)

	my_velocity_by_aim(owner,propel_force+speed,final_velocity_player,dummy_vector)

	if(DEBUG){
		sh_chat_message(owner,gHeroID,"Initial speed: %0.2f",speed)

		sh_chat_message(owner,gHeroID,"Employed thrust force: %0.2f",cvar_val(float, pcvar_nitro_force)*NITRO_TIMER_UPDATE_PERIOD)
	}

	final_velocity_player[2] = 0.0

	entity_set_vector(owner,EV_VEC_velocity,final_velocity_player)

	
	speed = vector_length(final_velocity_player)


	if(DEBUG){
		sh_chat_message(id,gHeroID,"After thrust speed: %0.2f",speed)
	}
	

	new Float:the_force = player_air_drag_update_speed(id,PLAYER_DRAG_CONST*cvar_val(float, pcvar_nitro_air_drag),NITRO_TIMER_UPDATE_PERIOD)


	if(DEBUG){
		sh_chat_message(owner,gHeroID,"Obtained drag force: %0.2f",the_force)
	}

	entity_get_vector(owner,EV_VEC_velocity,velocity_player)

	speed = vector_length(velocity_player)


	if(DEBUG){
		sh_chat_message(owner,gHeroID,"After drag speed: %0.2f",speed)
	}


	entity_set_float(car_id, EV_FL_nextthink, get_gametime()+ NITRO_TIMER_UPDATE_PERIOD)

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

	if(!g_is_running[id]){

		spawn_car(id)

	}
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
*/