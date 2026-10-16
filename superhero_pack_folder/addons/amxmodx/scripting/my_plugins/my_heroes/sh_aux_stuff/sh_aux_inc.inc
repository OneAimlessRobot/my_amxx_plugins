#if defined sh_aux_funcs
  #endinput
#endif
#define sh_aux_funcs
/**
DEFINES FOR COMPILE TIME OPTIMIZATION:

(#define I_WANT_FAKEMETA_UTIL) -> enables fakemeta util header

(#define I_WANT_CONSTANTS) -> enables constants

(#define I_WANT_QUICK_CHECKS) -> enables quick check stocks

(#define I_WANT_MATH_FUNCS) -> enables math stocks

(#define I_WANT_MISC_FUNCS) -> enables misc stocks

*/
#if defined I_WANT_FAKEMETA_UTIL
#include <fakemeta_util>
#endif

#if defined I_WANT_CONSTANTS
#include "sh_aux_consts.inc"
#endif

#if defined I_WANT_QUICK_CHECKS
#include "sh_aux_quick_checks.inc"
#endif

#if defined I_WANT_MATH_FUNCS
#include "sh_aux_math_funcs_pt1.inc"
#endif

#if defined I_WANT_CUSTOM_WEAPONS
#include "sh_custom_weapons_logic.inc"
#endif

#if defined I_WANT_MISC_FUNCS
#include "sh_aux_funcs_misc.inc"
#endif



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
