/*
(c) Copyright 2026, ThrashBrat
  */
#include <cstddef>
#include <cstring>
#include <stdint.h>
#include <cstdio>
#include "./metamod_stuff_and_other_includes/the_hero_array_include.h"
#include "./metamod_stuff_and_other_includes/amxxmodule.h"

HeroArray the_hero_array;

static cell AMX_NATIVE_CALL sh_get_user_has_hero(AMX *amx,cell *params)
{
	return the_hero_array.get_id_has_hero(params[1], params[2]);
}

static cell AMX_NATIVE_CALL sh_set_user_has_hero(AMX *amx,cell *params)
{
	the_hero_array.set_id_has_hero(params[1], params[2], params[3]);
	return 0;
}

static cell AMX_NATIVE_CALL sh_init_hero_array(AMX *amx,cell *params)
{	
	the_hero_array.zero_it_out();
	return 0;
}

AMX_NATIVE_INFO sh_array_exports[] = 
{
	{ "sh_set_user_has_hero", sh_set_user_has_hero },
	{ "sh_get_user_has_hero", sh_get_user_has_hero },
	{ "sh_init_hero_array", sh_init_hero_array },
	{ NULL, NULL }
};

void OnAmxxAttach()
{	
	MF_AddNatives(sh_array_exports);
}