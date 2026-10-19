/*
(c) Copyright 2026, ThrashBrat
  */
#include <cstddef>
#include <cstring>
#include <stdint.h>
#include <cstdio>
#include "./metamod_stuff_and_other_includes/the_hero_array_include.h"
#include "./metamod_stuff_and_other_includes/amxxmodule.h"

/*
 * 
	this stuff rids me of annoying ass warnings in the compiler
	return_type function(AMX* amx, cell* params)
	{
		(void)amx;
		(void)params;
		....
		
	}
	to suppress unused parameter warnings

*/

HeroArrays the_hero_array;
//Hero properties

//The second parameter is the bit to retrieve
static cell AMX_NATIVE_CALL sh_get_hero_bit(AMX *amx,cell *params)
{	
	(void)amx;
	return the_hero_array.get_hero_bit((state_cell_type_t)params[1], (state_cell_type_t)params[2]);
}

//the third parameter assigns the polarity of the bit
static cell AMX_NATIVE_CALL sh_assign_hero_bit(AMX *amx,cell *params)
{
	(void)amx;
	the_hero_array.assign_hero_bit((state_cell_type_t)params[1], (state_cell_type_t)params[2], (state_cell_type_t)params[3]);
	return 0;
}



//hero ownership
static cell AMX_NATIVE_CALL sh_get_user_has_hero(AMX *amx,cell *params)
{
	(void)amx;
	return the_hero_array.get_id_has_hero((state_cell_type_t)params[1], (state_cell_type_t)params[2]);
}

static cell AMX_NATIVE_CALL sh_set_user_has_hero(AMX *amx,cell *params)
{
	(void)amx;
	the_hero_array.set_id_has_hero((state_cell_type_t)params[1],(state_cell_type_t) params[2], (state_cell_type_t)params[3]);
	return 0;
}

//hero cooldown
static cell AMX_NATIVE_CALL sh_get_id_hero_cooldown_bit(AMX *amx,cell *params)
{
	(void)amx;
	return the_hero_array.get_id_hero_cooldown_bit((state_cell_type_t)params[2], (state_cell_type_t)params[1]);
}

static cell AMX_NATIVE_CALL sh_set_id_hero_cooldown_bit(AMX *amx,cell *params)
{
	(void)amx;
	the_hero_array.set_id_hero_cooldown_bit((state_cell_type_t)params[2],(state_cell_type_t) params[1], (state_cell_type_t)params[3]);
	return 0;
}



//hero projectile weapon bits
static cell AMX_NATIVE_CALL sh_get_hero_projectile_weapon_bit(AMX *amx,cell *params)
{
	(void)amx;
	return the_hero_array.get_hero_projectile_weapon_bit((state_cell_type_t)params[1], (state_cell_type_t)params[2]);
}

static cell AMX_NATIVE_CALL sh_assign_hero_projectile_weapon_bit(AMX *amx,cell *params)
{
	(void)amx;
	the_hero_array.assign_hero_projectile_weapon_bit((state_cell_type_t)params[1],(state_cell_type_t) params[2], (state_cell_type_t)params[3]);
	return 0;
}


//The second parameter is the bit to retrieve
static cell AMX_NATIVE_CALL sh_get_id_bit(AMX *amx,cell *params)
{
	(void)amx;
	return the_hero_array.get_id_bit((state_cell_type_t)params[1], (state_cell_type_t)params[2]);
}

//the third parameter assigns the polarity of the bit
static cell AMX_NATIVE_CALL sh_assign_id_bit(AMX *amx,cell *params)
{
	(void)amx;
	the_hero_array.assign_id_bit((state_cell_type_t)params[1], (state_cell_type_t)params[2], (state_cell_type_t)params[3]);
	return 0;
}




//lib initialization

/*

	first parameter is num of heroes,

	second parameter is number of hero properties

	third parameter is number of client states

*/

static cell AMX_NATIVE_CALL sh_init_hero_array_lib(AMX *amx,cell *params)
{	
	(void)amx;
	the_hero_array.zero_it_out();
	
	the_hero_array.init_hero_array_sizes((state_cell_type_t)params[1],
											(state_cell_type_t)params[2],
											(state_cell_type_t)params[3]);
	return 0;
}

static cell AMX_NATIVE_CALL sh_zero_out_cooldown_memory(AMX *amx,cell *params)
{	
	(void)amx;
	the_hero_array.zero_out_id_hero_cooldown_masks();
	return 0;
}


//lib limits

static cell AMX_NATIVE_CALL sh_max_hero_props(AMX *amx,cell *params)
{	
	(void)amx;
	(void)params;
	return (int)the_hero_array.get_max_hero_props();
	
}
static cell AMX_NATIVE_CALL sh_max_client_states(AMX *amx,cell *params)
{	
	(void)amx;
	(void)params;
	return (int)the_hero_array.get_max_client_states();
	
}
static cell AMX_NATIVE_CALL sh_maxhero_capacity(AMX *amx,cell *params)
{	
	(void)amx;
	(void)params;
	return (int)the_hero_array.get_max_heroes();
	
}

AMX_NATIVE_INFO sh_array_exports[] = 
{
	{ "sh_assign_hero_bit", sh_assign_hero_bit },
	{ "sh_get_hero_bit", sh_get_hero_bit },
	{ "sh_max_hero_props", sh_max_hero_props },
	{ "sh_maxhero_capacity", sh_maxhero_capacity },

	
	
	{ "sh_assign_id_bit", sh_assign_id_bit },
	{ "sh_get_id_bit", sh_get_id_bit },

	{ "sh_max_client_states", sh_max_client_states },
	
	{ "sh_set_user_has_hero", sh_set_user_has_hero },
	{ "sh_get_user_has_hero", sh_get_user_has_hero },
	
	{ "sh_set_id_hero_cooldown_bit", sh_set_id_hero_cooldown_bit },
	{ "sh_get_id_hero_cooldown_bit", sh_get_id_hero_cooldown_bit },
	
	
	{ "sh_zero_out_cooldown_memory", sh_zero_out_cooldown_memory },
	
	
	
	{ "sh_get_hero_projectile_weapon_bit", sh_get_hero_projectile_weapon_bit },
	{ "sh_assign_hero_projectile_weapon_bit", sh_assign_hero_projectile_weapon_bit },
	
	{ "sh_init_hero_array_lib", sh_init_hero_array_lib },
	{ NULL, NULL }
};

void OnAmxxAttach()
{	
	MF_AddNatives(sh_array_exports);
}
