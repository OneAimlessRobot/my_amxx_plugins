/*
(c) Copyright 2026, ThrashBrat
  */
#include <cstddef>
#include <cstring>
#include <stdint.h>
#include <cstdio>
#include "./metamod_stuff_and_other_includes/the_hero_array_include.h"
#include "./metamod_stuff_and_other_includes/amxxmodule.h"

HeroArrays the_hero_array;
//Hero properties

//The second parameter is the bit to retrieve
static cell AMX_NATIVE_CALL sh_get_hero_bit(AMX *amx,cell *params)
{
	return the_hero_array.get_hero_bit(params[1], params[2]);
}

//the third parameter assigns the polarity of the bit
static cell AMX_NATIVE_CALL sh_assign_hero_bit(AMX *amx,cell *params)
{
	the_hero_array.assign_hero_bit(params[1], params[2], params[3]);
	return 0;
}


//hero ownership
static cell AMX_NATIVE_CALL sh_get_user_has_hero(AMX *amx,cell *params)
{
	return the_hero_array.get_id_has_hero(params[1], params[2]);
}

static cell AMX_NATIVE_CALL sh_set_user_has_hero(AMX *amx,cell *params)
{
	the_hero_array.set_id_has_hero(params[1], params[2], params[3]);
	return 0;
}


//The second parameter is the bit to retrieve
static cell AMX_NATIVE_CALL sh_get_id_bit(AMX *amx,cell *params)
{
	return the_hero_array.get_id_bit(params[1], params[2]);
}

//the third parameter assigns the polarity of the bit
static cell AMX_NATIVE_CALL sh_assign_id_bit(AMX *amx,cell *params)
{
	the_hero_array.assign_id_bit(params[1], params[2], params[3]);
	return 0;
}




//lib initialization

static cell AMX_NATIVE_CALL sh_init_hero_array(AMX *amx,cell *params)
{	
	the_hero_array.zero_it_out();
	return 0;
}

//player flags reset

static cell AMX_NATIVE_CALL sh_init_id_masks_array(AMX *amx,cell *params)
{	
	the_hero_array.zero_out_player_masks();
	return 0;
}


//lib limits

static cell AMX_NATIVE_CALL sh_max_hero_props(AMX *amx,cell *params)
{	
	return the_hero_array.get_max_hero_props();
	
}
static cell AMX_NATIVE_CALL sh_max_client_states(AMX *amx,cell *params)
{	
	return the_hero_array.get_max_client_states();
	
}

AMX_NATIVE_INFO sh_array_exports[] = 
{
	{ "sh_assign_hero_bit", sh_assign_hero_bit },
	{ "sh_get_hero_bit", sh_get_hero_bit },
	{ "sh_max_hero_props", sh_max_hero_props },
	
	
	{ "sh_assign_id_bit", sh_assign_id_bit },
	{ "sh_get_id_bit", sh_get_id_bit },
	{ "sh_init_id_masks_array", sh_init_id_masks_array },
	{ "sh_max_client_states", sh_max_client_states },
	
	{ "sh_set_user_has_hero", sh_set_user_has_hero },
	{ "sh_get_user_has_hero", sh_get_user_has_hero },
	{ "sh_init_hero_array", sh_init_hero_array },
	{ NULL, NULL }
};

void OnAmxxAttach()
{	
	MF_AddNatives(sh_array_exports);
}