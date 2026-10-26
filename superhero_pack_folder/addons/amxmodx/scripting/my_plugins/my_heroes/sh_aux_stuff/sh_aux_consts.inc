#if defined sh_aux_consts
  #endinput
#endif
#define sh_aux_consts

/*

even further header file segregation for "optiomization" (UGhrrnn... lame...)


#define I_WANT_MATH_VECTOR_CONSTS //this is for when you want the "0,0,1" "0,1,0" "1,0,0" shennadigans
//it gives you a bunch of macros it shouldnt increase binary size

#define I_WANT_PDATA_ALIASES //this is for when you want the names for the pdata numbers and offsets
//it also gives you a bunch of macros. it shouldnt increase binary size

#define I_WANT_ENTITY_VECTORS //this is a bunch of vectors with entity names inside. they are used
//on the stocks where you register thinks for a bunch of entities at once
//instead of doing it with a loop each time
//I think its cleaner
//they are all stocks and wont increase binary size unless you explicitly include any of them
//but remember: including one member of an array will bring out the entire array along with it

#define I_WANT_CUSTOM_COLORS //this is where a vector of colors along with 
//an enum to index them is defined. it is annoying to mess with
//because it often requires recompiling everything
//hence why I am doing this.
//I want to be absolutely sure
//that I am only including what I need
//In every hero
//i want to figure out if I can make my compile times smaller
//much smaller

#define I_WANT_RESOURCE_ALIASES //Its a bunch of macros
//for resource names.
//it should not increase binary size in any way

#define I_WANT_BASIC_MACROS // you will find yourself including this often
//it ALSO shouldnt increase binary size


*/

#if defined I_WANT_MATH_VECTORS //this is for when you want the "0,0,1" "0,1,0" "1,0,0" shennadigans
//it gives you a bunch of macros it shouldnt increase binary size
	#include "sh_aux_consts_math_vectors.inc"
#endif


#if defined I_WANT_PDATA_ALIASES //this is for when you want the names for the pdata numbers and offsets
//it also gives you a bunch of macros. it shouldnt increase binary size
	#include "sh_aux_consts_pdata_aliases.inc"
#endif


#if defined I_WANT_ENTITY_VECTORS //this is a bunch of vectors with entity names inside. they are used
//on the stocks where you register thinks for a bunch of entities at once
//instead of doing it with a loop each time
//I think its cleaner
//they are all stocks and wont increase binary size unless you explicitly include any of them
//but remember: including one member of an array will bring out the entire array along with it
	#include "sh_aux_consts_entity_vectors.inc"
#endif


#if defined I_WANT_CUSTOM_COLORS //this is where a vector of colors along with 
//an enum to index them is defined. it is annoying to mess with
//because it often requires recompiling everything
//hence why I am doing this.
//I want to be absolutely sure
//that I am only including what I need
//In every hero
//i want to figure out if I can make my compile times smaller
//much smaller
	#include "sh_aux_consts_colors_enum.inc"
#endif


#if defined I_WANT_RESOURCE_ALIASES
	#include "sh_aux_consts_resource_aliases.inc"
#endif


#if defined I_WANT_BASIC_MACROS // you will find yourself including this often
//it ALSO shouldnt increase binary size
	#include "sh_aux_consts_basic_macros.inc"
#endif