/*
(c) Copyright 2026, ThrashBrat
  */
#include <cstddef>
#include <cstring>
#include <stdint.h>
#include <cstdio>
#include "./metamod_stuff_and_other_includes/entities_lookup_table.h"
#include "./metamod_stuff_and_other_includes/amxxmodule.h"


static cell AMX_NATIVE_CALL ecnlt_init_lib(AMX *amx,cell *params)
{	(void)amx;
	(void)params;
	printf("Entity Claass name lookup table test init!\nClamp of %d between %d and %d is %d\n",5,19,6, clamp(5,19,6));
	return 1;
}
static cell AMX_NATIVE_CALL ecnlt_get_name(AMX *amx,cell *params)
{
	return MF_SetAmxString( amx , params[2] , full_entity_name_array[params[1]],
						(int32_t)min(sizeof(full_entity_name_array[params[1]]),(state_cell_type_t)params[3]) -1 );
}
AMX_NATIVE_INFO entity_lookup_table_exports[] = 
{
	{ "ecnlt_init_lib", ecnlt_init_lib },
	{ "ecnlt_get_name", ecnlt_get_name},
	{ NULL, NULL }
};

void OnAmxxAttach()
{	
	ecnlt_init_lib(NULL,NULL);
	MF_AddNatives(entity_lookup_table_exports);
}
