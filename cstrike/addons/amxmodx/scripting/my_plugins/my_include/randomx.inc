/* Number Generator
*
* (c) Copyright 2005 Rukia
*
* This file is provided as is (no warranties).
*/

#pragma library RandomX


#define CELL_MAX 2147483647
#define FLOAT_MAX 2147483647.0

native Bool:generate_bool();
native generate_int(lower = 0,upper = CELL_MAX,iten = 1)
native Float:generate_float(Float:lower = 0.0,Float:upper = FLOAT_MAX ,iten = 1)
native generate_vector(Float:vec[3],Float:lower = 0.0,Float:upper = FLOAT_MAX,iten = 1);

native generate_string(output[],len)
native generate_alpha_string(output[],len)
native generate_salt(salt_value[], len = 34)
native generate_array(output[],len)


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
