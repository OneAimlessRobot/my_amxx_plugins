/*
(c) Copyright 2026, ThrashBrat
  */
#include <cstddef>
#include <cstring>
#include <stdint.h>
#include <cstdio>
#include "./metamod_stuff_and_other_includes/colors_lookup_table.h"
#include "./metamod_stuff_and_other_includes/amxxmodule.h"


static cell AMX_NATIVE_CALL clt_init_lib(AMX *amx,cell *params)
{	(void)amx;
	(void)params;
	printf("Color lookup table test init!\nClamp of %d between %d and %d is %d\n",5,19,6, clamp(5,19,6));
	return 1;
}
static cell AMX_NATIVE_CALL sh_fetch_std_color(AMX *amx,cell *params)
{
	int* array = MF_GetAmxAddr( amx, params[1] );
	int len = MF_GetAmxStringLen( array );
	if(params[2] > len) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Incorrect Length Specified");
		return -1;
	}
	array = generator.RandomArray(params[2]);
	return 1;
}
static cell AMX_NATIVE_CALL sh_fetch_fx_color(AMX *amx,cell *params)
{
	int* array = MF_GetAmxAddr( amx, params[1] );
	int len = MF_GetAmxStringLen( array );
	if(params[2] > len) 
	{
		MF_LogError(amx,AMX_ERR_NATIVE,"Incorrect Length Specified");
		return -1;
	}
	array = generator.RandomArray(params[2]);
	return 1;
}
static cell AMX_NATIVE_CALL sh_fetch_color(AMX *amx,cell *params)
{	(void)amx;
	sh_custom_color the_color_num = 
	printf("Color lookup table test init!\nClamp of %d between %d and %d is %d\n",5,19,6, clamp(5,19,6));
	return 1;
}
AMX_NATIVE_INFO color_lookup_table_exports[] = 
{
	{ "clt_init_lib", clt_init_lib },
	{ "sh_fetch_std_color", sh_fetch_std_color},
	{ "sh_fetch_fx_color", sh_fetch_fx_color},
	{ NULL, NULL }
};

void OnAmxxAttach()
{	
	clt_init_lib(NULL,NULL);
	MF_AddNatives(color_lookup_table_exports);
}
