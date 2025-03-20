/*
 * ReAPI functions (natives).
 * Version: 1.11.0 (AMX API v9 [AMX Mod v2010.1+]).
 *
 * Copyright (C) - AMX Mod Dev.
 * This file is provided as is (no warranties).
 *
 *
 ******************************** INFORMATIONS *********************************
 * This current version is compatible with the modules API of AMX Mod v2010.1, *
 * and is, in consequence, adapted for that AMX Mod version.                   *
 * But keep in mind the version of this module that will be provided with the  *
 * future AMX Mod version will be different, despite the global design will    *
 * remain the same, but various functions will be either removed from there    *
 * (moved elsewhere as for my powerful parameters/return system), or modified. *
 *                                                                             *
 * Also, each function call or hook chain requires a specific version of the   *
 * Re* DLLs, but the module requires you run at least one of those versions:   *
 *   ReHLDS: v1.0 or higher (from comit #2 [2015-05-04]).                      *
 *   ReGameDLL_CS: v5.21 or higher (from comit #534 [2021-09-02]).             *
 *   Reunion: v1.1 or higher.                                                  *
 *   ReChecker: v2.1 or higher.                                                *
 *   VTC: v3.0 or higher.                                                      *
 *                                                                             *
 * As specified above, ReHLDS only requires an old version as base, but not    *
 * for ReGameDLL_CS which requires a v5.21, because there had changes in the   *
 * functions listing (some swapping + IDs) which will break the compatibility  *
 * if I attempt to support an older version of that game binary.               *
 *                                                                             *
 * To finish, I have compiled this module using "my own" ReAPI public files    *
 * where some functions names have been renamed (very minor) and I am also     *
 * using different upper case naming style for various structs/classes, etc..  *
 * Like "IRehldsHookchains" into "IReHLDSHookChains", etc..                    *
 *                                                                             *
 ******************************************************************************/

#if defined _reapi_included
	#endinput
#endif
#define _reapi_included

#include <reapi_const>


/* Macros to fix the annoying "truncated to 31 characters" warning.
 * DO NOT MODIFY THIS! */
#define ReAPI_HM_SwitchHookStatusByHandle ReAPI_HM_SwitchHookStatusByH
#define ReAPI_HM_ResetFunctionParameters  ReAPI_HM_ResetFunctionParams


/************************* NATIVES -> Base functions **************************/

/* Get the informations of a binary related to a "Re" project.
 * The "iBinaryType" parameter is a ReAPI_BT_* from "reapi_const.inc".
 *
 * Usage formats:
 *   For ReHLDS:       (ReAPI_BT_ReHLDS, &iMajorVersion = -1, &iMinorVersion = -1, &g_pReHLDSFunctions = 0, &g_pReHLDSHookChains = 0, &g_pReHLDSServerStatic = 0, &g_pReHLDSServerData = 0)
 *   For ReGameDLL_CS: (ReAPI_BT_ReGameDLL_CS, &iMajorVersion = -1, &iMinorVersion = -1, &g_pReGameDLLCSFunctions = 0, &g_pReGameDLLCSHookChains = 0)
 *   For Reunion:      (ReAPI_BT_Reunion, &iMajorVersion = -1, &iMinorVersion = -1)
 *   For ReChecker:    (ReAPI_BT_ReChecker, &iMajorVersion = -1, &iMinorVersion = -1, &g_pReCheckerFunctions = 0, &g_pReCheckerHookChains = 0)
 *   For VTC:          (ReAPI_BT_VTC, &iMajorVersion = -1, &iMinorVersion = -1)
 *
 *   Note: All the extras parameters are via reference, but you do not have to provide the "next" if in case you do not need it in your plugins.
 *
 * Return values:
 *   0 - Invalid binary type provided, or, the related binary is not installed/running (no ReHLDS engine, no ReGameDLL_CS game, etc.).
 *   1 - The related binary is installed/running, but the version check failed, so the "functions" address is unavailable (only for a binary which has such address).
 *       Note: That means the main (the hardcoded one internally required to make work the module) major/minor version check on module initialization has failed, so you need to update the Re* binary.
 *   2 - The related binary is installed/running, and the version check succeed, so the "functions" address is available (only for a binary which has such address).
 *       Note: That means the main (the hardcoded one internally required to make work the module) major/minor version check on module initialization has succeed. */
native ReAPI_BF_GetBinaryInformations(ReAPI_BT:iBinaryType, {Float, _}:...);

/* Check if the server has a "Re" binary installed/running, and with some extras conditions.
 * The "iBinaryType" parameter is a ReAPI_BT_* from "reapi_const.inc".
 * The "bCheckVersion" parameter is to check the version via the "i<Major|Minor>VersionRequired" parameters, and require it.
 * The "bCheckFunctions" and "bCheckHookChains" parameters are to check the availability of the "functions" and "hook chains" addresses (g_p*) related to the binary, it is recommended to always set them to true as they deal with the internal requirements by the module.
 * Returns a ReAPI_HBRRT_* from "reapi_const.inc".
 *
 * Notes:
 *   You must use this function in your plugins and in an AMX hook called soon (as "server_changelevel", "plugin_precache" or "plugin_init").
 *   This is destined to make your plugin "inactive" (AMX log and pause of the plugin), with an error message, when it needs a specific version of a "Re" binary in order to make work some functions or hooks.
 *   Despite the fact the other functions (as the natives related to the hook manager) will throw errors (when CVar "amx_debug" enabled) when trying to use a function/hook that is unavailable in the current used version of a "Re" binary.
 *   This native should always be present in your plugins. */
native ReAPI_HBRRT:ReAPI_BF_HasBinaryRunning(ReAPI_BT:iBinaryType, bool:bCheckVersion, iMajorVersionRequired, iMinorVersionRequired, bool:bCheckFunctions = true, bool:bCheckHookChains = true);


/************************** NATIVES -> Function call **************************/

/* Get the type ID of a call function, based on its name.
 * The "iCallFunctionGroupTypeID" parameter is a ReAPI_CFGT_* from "reapi_const.inc".
 * The "szCallFunctionTypeName" parameter is the call function name as string format from "reapi_const.inc" (the part after each "Function name (API)"),
 * but take care, it is case-sensitive (more for "performance"), since you are supposed to grab with your mouse's cursor the content with quotes, so do not try writting manually something like "sv_emitsound2" instead of "SV_EmitSound2", this will not find the function ID.
 * The "bCheckAvailability" parameter (I recommend to always set it to true) is to control the availability of the function type, that means it will check if the related "Re" binary is running, and also if the API version required to use it is available.
 *
 * Return values (from "reapi_const.inc"):
 *   "ReAPI_CFT_Invalid"     - The binary type is invalid, or, the function is invalid/unknown (that means either you provided an "unknown function", either you did not write the name by respecting case-sensitivity).
 *   "ReAPI_CFT_Unavailable" - The function is valid/known (implemented in the module), but the related "Re" binary is not running, or the API version of it is lower than the one required to use that function.
 *                             Note: This return value can only be present when the "bCheckAvailability" parameter is set to true, however, you will get an internal ID >= 0 as specified below.
 *   ID >= 0                 - An internal ID related to a call function.
 *                             Note: Please never try to "hardcode" the ID of a function returned by this native, mainly because the order will change on module update (if new functions to call are added).
 *
 * Notes:
 *   The return value of this native has to be used with the "ReAPI_FC_CallFunctionByTypeID" native.
 *   It has mainly been made for "short performance optimization", if you frequently use the "ReAPI_FC_CallFunctionByTypeID" native, so you can store the ID of a function in a cell variable and use it instead or using the "ReAPI_FC_CallFunctionByTypeName" native which will search for the name everytime you will use it (despite the search method is efficient).
 *   But this can also be used to check for the availability of a call function (in a similar usage way of the "ReAPI_BF_HasBinaryRunning" native). */
native ReAPI_CFT:ReAPI_FC_GetCallFunctionTypeID(ReAPI_CFGT:iCallFunctionGroupTypeID, const szCallFunctionTypeName[], bool:bCheckAvailability);

/* Call a function (by type ID or type name).
 * The "iStringPoolFlags" is the flags of the parameters where you want to use the internal string pool (using engine's "pfnAllocString" function code, but pointing to the same existing one as fix for non-ReHLDS engine).
 * It is recommended for a lot of functions, as the ones dealing with entities's original classes names and engine's resource paths.
 * You must use a format like "(1<<iParamNum)", so as example, if you want to use it for a function having a string in the parameter #4, specify "(1<<4)" as "iStringPoolFlags".
 * Feel free to cumulate flags by using the "|" operator, if a function has multiple strings in the format and if you wish to use that string pool for all of them.
 * The possible extra parameter(s) must be specified and used properly, it is highly important you respect the usage format specified in the "reapi_const.inc" file (related to the call function type).
 *
 * Return values:
 *   0 - Failure, the function has not been called (the function type ID/name is invalid or unavailable [see the description of the "ReAPI_FC_GetCallFunctionTypeID" native for the reasons]; not enough parameters; an internal data/variable/array is needed and missing; a safety check in a parameter has failed).
 *   1 - Success, the function has been called.
 *
 *   Notes:
 *     The function originally had more return values (negatives values from -3 to -1), but I decided to remove them in order to start from 0 as base and match a bit with the hook natives.
 *     This is mainly because, at worse, if you need to know more informations about a function type being invalid or unavailable, you can use the previous "ReAPI_FC_GetCallFunctionTypeID" native for this.
 *     And for the rest that's up to you to properly respect the usage format, etc..
 *
 * Usage examples:
 *   First (by type ID):
 *     new ReAPI_CFT:iFuncTypeID_RHSVS_GetClient_t = ReAPI_FC_GetCallFunctionTypeID(ReAPI_CFGT_RH_IReHLDSServerStatic, "GetClient_t", true)
 *     if(iFuncTypeID_RHSVS_GetClient_t <= ReAPI_CFT_Unavailable)
 *       // Possible error logging here...
 *       return
 *
 *     new pEngineClientHandle
 *     if(!ReAPI_FC_CallFunctionByTypeID(iFuncTypeID_RHSVS_GetClient_t, 0, iClientID, pEngineClientHandle) || pEngineClientHandle == 0) // Something goes wrong, maybe invalid client ID passed (like 54).
 *       return
 *
 *   Second (by type name):
 *     new iInventoryItemEntityID = -1
 *     if(!ReAPI_FC_CallFunctionByTypeName(ReAPI_CFGT_RGCS_CCSPlayer, "GetItemById", 0, iClientID, CSW_HEGRENADE, iInventoryItemEntityID) || iInventoryItemEntityID <= -1)
 *       return
 *
 *   Third (by type name):
 *     new szAuthData[64], iSize
 *     if(!ReAPI_FC_CallFunctionByTypeName(ReAPI_CFGT_REU_IReunionAPI, "GetClientAuthData", 0, szAuthData, charsmax(szAuthData), iSize))
 *       return
 *
 * Notes:
 *   Both natives internally check for the "availability" of a call function type.
 *
 *   I always recommend to use those natives like that (or in the reverse way like in the above examples):
 *     new bool:bSecure
 *     if(ReAPI_FC_CallFunctionByTypeName(ReAPI_CFGT_RH_ReHLDSFuncs, "GSBSecure", 0, bSecure) && bSecure) {
 *       // Your code here...
 *     }
 *
 *   So in other terms, always check that the native has a success return value, so you are sure the internal function has been called. */
native ReAPI_FC_CallFunctionByTypeID(ReAPI_CFT:iCallFunctionTypeID, iStringPoolFlags, {Float, _}:...);
native ReAPI_FC_CallFunctionByTypeName(ReAPI_CFGT:iCallFunctionGroupTypeID, const szCallFunctionTypeName[], iStringPoolFlags, {Float, _}:...);


/*********************** NATIVES -> Extra function call ***********************/

/******************************** INFORMATIONS *********************************
 * Those "extras function call" are natives that can call functions being      *
 * "outside from the public ReAPI the developers expose to users", or,         *
 * or group a multiple ReAPI's functions (as for the "TakeDamage" native).     *
 *                                                                             *
 * I have thinked about adding two more powerful natives allowing the call of  *
 * most of the functions from the "CBaseEntity" and "CGameRules" classes,      *
 * but I think this goes too much "out of scope" and do not match to that my   *
 * "ReAPI" module version should contain. So for now this is not implemented.  *
 * Meantime, if you like my module and have plans to use it and support more   *
 * AMX Mod and all of that I am doing on it, you could beg me to add this,     *
 * then maybe I will! Hehehehehe!                                              *
 *                                                                             *
 ******************************************************************************/

/* Call the "CBaseEntity::TakeDamage" function via different methods.
 * The "iMethodType" parameter allows you to choose the calling method (function(s) type used for affecting damage to an entity (see below)).
 * The "bExport" parameter is available in the format, but not used internally.
 * Returns in the "iReturnValue" variable the result of the function call, but only if the "CBaseEntity::TakeDamage" function is used, since the multi-damage functions do not have a return value.
 *
 * Method types:
 *   0 - Call the virtual function "CBase*::TakeDamage".
 *       Note: The function can be called on any CS version, I mean, you do not need to have the ReGameDLL_CS binary to call it, this is also compatible with Retro CS, CS v1.5, CS v1.6 (old/new) and CZ (old/new).
 *   1 - Use the "ClearMultiDamage", "AddMultiDamage", "ApplyMultiDamage" together (at the suite and in this order).
 *       Note: This method requires you run the ReGameDLL_CS v5.0 or higher in order to work.
 *   2 - Use the "ClearMultiDamage", "AddMultiDamage", "ApplyMultiDamage" together (at the suite and in this order), but skip the "ClearMultiDamage" to be called when the current entity ID is already the one set by multi-damage functions (was done to allow cumulating damage).
 *       Note: This method is only available when the address of the "gMultiDamage" global variable is too (only the case under Linux for now), however, the system will redirect to the method #1.
 *   3 - Automatic: Use the method #0, then, if in case some members are unavailable, redirect to the method #1.
 *       Note: The method #0 will always be available for any CS version since the related members are available, so there will not be any redirection to the method #1. */
native ReAPI_EFC_TakeDamage(iMethodType = 3, bool:bExport, iEntityID, iInflictorID, iAttackerID, Float:flDamage, iDamageBits, &iReturnValue = -1);


/********************** NATIVES -> Hooks manager -> Main **********************/

/* Get the type ID of a hook function, based on its name.
 * The "iBinaryType" parameter is a ReAPI_BT_* from "reapi_const.inc".
 * The "szHookFunctionTypeName" parameter is the hook function name as string format from "reapi_const.inc" (the part after each "Function name (API)"),
 * but take care, it is case-sensitive (more for "performance"), since you are supposed to grab with your mouse's cursor the content with quotes, so do not try writting manually something like "cbaseplayer::TakeDamage" instead of "CBasePlayer::TakeDamage", this will not find the function ID.
 * The "bCheckAvailability" parameter (I recommend to always set it to true) is to control the availability of the function type, that means it will check if the related "Re" binary is running, and also if the API version required to use it is available.
 *
 * Return values (from "reapi_const.inc"):
 *   "ReAPI_HFT_Invalid"     - The binary type is invalid, or, the function is invalid/unknown (that means either you provided an "unknown function", either you did not write the name by respecting case-sensitivity).
 *   "ReAPI_HFT_Unavailable" - The function is valid/known (implemented in the module), but the related "Re" binary is not running, or the API version of it is lower than the one required to use that function.
 *                             Note: This return value can only be present when the "bCheckAvailability" parameter is set to true, however, you will get an internal ID >= 0 as specified below.
 *   ID >= 0                 - An internal ID related to a hook chain function.
 *                             Notes:
 *                               Please never try to "hardcode" the ID of a function returned by this native, mainly because the order will change on module update (if new hook chains are added).
 *                               You "may" only do that with the ReHLDS's hook chains (and only till the "SV_Frame" hook chain, which is the latest hook chain added on the first release of that ReAPI module, but not for the ones after), due to the fact it is the first binary listed internally in my datas and since the internal listing has the same order than the real API's one.
 *                               But I strongly do not recommend to do that.
 *
 * Notes:
 *   The return value of this native has to be used with the "ReAPI_HM_AddHookByTypeID" native.
 *   It has mainly been made for "short performance optimization", if you frequently use the "ReAPI_HM_AddHookByTypeID" native, so you can store the ID of a function in a cell variable and use it instead or using the "ReAPI_HM_AddHookByTypeName" native which will search for the name everytime you will use it (despite the search method is efficient).
 *   But since hooks are normally not be added/removed frequently, you may not need to bother yourself at using this native which usually needs you use a global variable to store the hook function ID, so directly use the following "ReAPI_HM_AddHookByTypeName" native should be quite enough most of the time.
 *   However, this can also be used to check for the availability of a hook (in a similar usage way of the "ReAPI_BF_HasBinaryRunning" native). */
native ReAPI_HFT:ReAPI_HM_GetHookFunctionTypeID(ReAPI_BT:iBinaryType, const szHookFunctionTypeName[], bool:bCheckAvailability);

/* Add an AMX hook (by type ID or type name). An "AMX hook" is the "new name" I give to an "AMX forward".
 * The "iAMXHookCallType" parameter is a ReAPI_AHCT_* from "reapi_const.inc" (more informations in this file).
 * The "iAMXHookPriorityType" parameter is a ReAPI_AHPT_* from "reapi_const.inc" (more informations in this file).
 * The "szCallback" parameter is the name of the public function in the plugin, where the function will be called. It is highly important you respect the usage format specified in the "reapi_const.inc" file (related to the hook function type).
 * The "pAMXHookHandle" variable is the address of the AMX hook, something you can use with the other hooks natives (to switch its status or remove it).
 * The value of this variable will always be provided with the right address once the native has a positive return value (new AMX hook created or already existing).
 *
 * Return values (sum of bits):
 *   0 - Failure (invalid hook function type/name; unavailable hook function type/name; callback not found in the current plugin; internal hook chain callback related to the hook not implemented in the module; unknown error while creating the AMX hook).
 *   1 - AMX hook created with success.
 *   2 - AMX hook already available with the same parameters (function type, call type, plugin, callback).
 *   4 - The internal hook chain of the "ReAPI" module has been enabled/registered ("registerHook" function called).
 *       Note: That means this is the first AMX hook which uses/enables the hook function type.
 *
 * Notes:
 *   Both natives internally check for the "availability" of a hook function type.
 *
 *   All the hook chains of that module use the "high" hook chain priority type (HC_PRIORITY_HIGH), so I recommend the usage of the "HC_PRIORITY_DEFAULT", "HC_PRIORITY_MEDIUM" or "HC_PRIORITY_LOW" for other possible hook chains in other Metamod/AMX Mod modules, mainly in order to have the hooks of this module have priority over the others (for parameters, etc.).
 *   However, I might change the "HC_PRIORITY_HIGH" to "HC_PRIORITY_DEFAULT" in the future (despite the fact most of the Metamod's modules using ReAPI hook chains will not set a priority, and so use the "HC_PRIORITY_DEFAULT" one, so this might not worth to be changed, because I want this module has some priority, but not ultra-high as "HC_PRIORITY_UNINTERRUPTABLE"). */
native ReAPI_HM_AddHookByTypeID(ReAPI_HFT:iHookFunctionTypeID, ReAPI_AHCT:iAMXHookCallType, ReAPI_AHPT:iAMXHookPriorityType = ReAPI_AHPT_Middle, const szCallback[], &pAMXHookHandle = 0);
native ReAPI_HM_AddHookByTypeName(ReAPI_BT:iBinaryType, const szHookFunctionTypeName[], ReAPI_AHCT:iAMXHookCallType, ReAPI_AHPT:iAMXHookPriorityType = ReAPI_AHPT_Middle, const szCallback[], &pAMXHookHandle = 0);

/* Switch the status of an AMX hook (by handle). This basically disable/enable the AMX plugin's callback from being called.
 * The "pAMXHookHandle" parameter is the address of an AMX hook created via the previous "ReAPI_HM_AddHookByType<ID|Name>" natives.
 * The "bStatus" parameter is to change the status of the hook (disable/enable it).
 *
 * Return values:
 *   0 - No available hook created or invalid AMX hook address (0).
 *   1 - The "bStatus" parameter is the same as the current status of the AMX hook (you set the "bStatus" parameter to false and the AMX hook is already disabled, or vice-versa).
 *   2 - The status of the AMX hook has been changed.
 *
 * Notes:
 *   This native must be used instead of the following one (ReAPI_HM_RemoveHookByHandle) when you frequently turn off/on an AMX hook.
 *   However, in the other case, it is better to use the "ReAPI_HM_RemoveHookByHandle" native since it is capable of fully remove the AMX hook, then also disable/unregister the internal hook chain (via "unregisterHook" function) when there is no more AMX hooks linked to it. */
native ReAPI_HM_SwitchHookStatusByHandle(pAMXHookHandle, bool:bStatus);

/* Remove an AMX hook (by handle).
 * The "pAMXHookHandle" parameter/variable is the address of an AMX hook created via the previous "ReAPI_HM_AddHookByType<ID|Name>" natives.
 * This variable works via "reference", that means it will be automatically cleaned up to 0 on success, but also cleaned up in case of you provided a "shitty non-zero value".
 *
 * Return values (sum of bits):
 *   0 - Invalid AMX hook address provided.
 *   1 - AMX hook removed with success.
 *   2 - The internal hook chain of the "ReAPI" module has been disabled/unregistered ("unregisterHook" function called).
 *       Note: That means there is no more AMX hook using the hook function type. */
native ReAPI_HM_RemoveHookByHandle(&pAMXHookHandle);


/* NATIVES -> Hooks manager -> Function parameters/return and AMX hook return */

/******************************** INFORMATIONS *********************************
 * This functions's parameters/return and AMX hooks's return is an unique,     *
 * user-friendly, complete and powerful system which takes me hours of         *
 * reflexion and coding in order to be properly achieved and be capable of     *
 * handle a bunch of things any other kind of system just does not support.    *
 * Meantime, and for some reasons, I will not explain here all the features    *
 * it can handles, and I have also not provided three natives that allow more  *
 * control over the datas the system keeps in memory temporarily.              *
 * So I've only provided the standard natives from the powerful future version *
 * (with some modifications and enhancements since the next release is not     *
 * finished yet), but this should be quite enough to retrieve/change the       *
 * functions's parameters/return in a goal to maximize programming power       *
 * offered by this module.                                                     *
 * Keep in mind I have made it available to you here, mainly due to the fact   *
 * that altering functions's parameters/return is highly useful, and also      *
 * more in order to show you a few things I have done (as a short preview),    *
 * and also keep in mind in the future AMX Mod version,                        *
 * the system will be in the core binary (it already is by the way),           *
 * and all the modules (including module API hooks) will deal with it.         *
 * So you see, the things I do are complete, powerful, but also "simple" at    *
 * the same time, because there are only "those" natives to have control over  *
 * the functions's parameters/return and AMX hooks's return, no need to bother *
 * yourself at using different natives implemented elsewhere, per each module  *
 * (unlike on the other addon... AMX Mod X, where a bunch of things are just   *
 * "too much" and far to be simple from my opinion, one of the reasons I'm     *
 * developping AMX Mod, to have an addon better well-made and higher quality). *
 *                                                                             *
 * The future AMX Mod version is destined to be powerful but also simple to    *
 * use at the same time, and I will do my best to achieve this goal, no matter *
 * what the idiots people are thinking, and no matter how many retards who     *
 * know "shit" about that I do, I face off... as the stupid "edon1337 kid"!    *
 *                                                                             *
 * Informations about the original/custom return values of the functions:      *
 *   Any original/custom return value is, inside a hook, always initialized    *
 *   to a NULL/0 value, so the original return value might change when the     *
 *   function is called, or might not.                                         *
 *   And when you block (supercede) a function, or override it,                *
 *   do not forget to set a correct return value matching with your needs      *
 *   (with the "ReAPI_HM_SetFunctionReturn" native), since this one will be    *
 *   used for the function instead of the original value.                      *
 *                                                                             *
 * Final notes:                                                                *
 *   For functions that have entities as parameters or return values, you just *
 *   have to use the entities IDs (like for the other entities natives).       *
 *   And if in case an entity is removed while it is stored in the parameters  *
 *   or returns, the system will update the data in order to set the value to  *
 *   NULL ("-1" for AMX), more in order to prevent possible crashes and also   *
 *   avoid the system to provide weird values in the hooks or in the natives,  *
 *   since the hooks use the "light entities conversion" for performance.      *
 *   Also, do not use those natives outside from they should be, as you might  *
 *   get incorrect and useless results, or change the data of other functions. *
 *   Please read carefuly the description of each native (below), since each   *
 *   of them contains important informations regarding the usage, etc..        *
 *                                                                             *
 ******************************************************************************/

/* Get/Set a parameter in a function passed at through an AMX hook of the ReAPI module.
 * The "bCurrent" boolean is to get/set the current parameter used by the function hook (the original when unchanged, or, the current/custom/new one), however, when false, it is the original one (the default data provided by the function).
 * The "iNumber" parameter is the number of the parameter, which starts from 1. But 0 as "iNumber" can be used to retrieve/alter the function address (only when supported by the current hook, which is currently not by the ReAPI hooks).
 *
 * Informations about the "get" native:
 *   Usage formats:
 *     For the function address (native's parameter #0): (bool:bCurrent, iNumber, &pFunctionAddress) // Useless here (ReAPI module has no address provided in hooks).
 *     For a variable: (bool:bCurrent, iNumber, &anyVariableValue, iMaxSize = 1, &iParameterSize = 0) // Integer/Float supported.
 *     For an array:   (bool:bCurrent, iNumber, anyArrayValue[], iMaxSize = 1, &iParameterSize = 0) // Integer/Float supported.
 *     For a string:   (bool:bCurrent, iNumber, szStringValue[], iMaxSize, &iStringLength = 0)
 *
 *   Usage examples with a function having a C++ format like "(int iParam1, float flParam2, Vector vecParam3, Vector vecParam4[5], const char *szParam5)":
 *     new pFunctionAddress, iParam1, Float:flParam2, Float:vParam3[3], Float:vParam4[15], szParam5[32], iParam5Length
 *     new iCurrentParam4Size
 *     ReAPI_HM_GetFunctionParameter(false, 0, pFunctionAddress)
 *     ReAPI_HM_GetFunctionParameter(true, 1, iParam1)
 *     ReAPI_HM_GetFunctionParameter(true, 2, flParam2)
 *     ReAPI_HM_GetFunctionParameter(true, 3, vParam3, sizeof(vParam3))
 *     ReAPI_HM_GetFunctionParameter(true, 4, vParam4, sizeof(vParam4), iCurrentParam4Size)
 *     ReAPI_HM_GetFunctionParameter(true, 5, szParam5, charsmax(szParam5), iParam5Length)
 *
 *   Extras informations:
 *     About the "iParameterSize" variable (native's parameter #5 by reference), this one will always output 1 for the variable type parameters, however, it may output the original parameters size (like 5 for the function parameter #4 here),
 *     or, if in case a new (and higher) parameter size has been defined by using the "set" native, it will return more than that (only when the "bCurrent" boolean is set to true, of course!).
 *     Keep in mind this output the size of the original C++ type, not the cell size (which is for a vector, multiplied per 3).
 *     For the string type parameters, the length of the string will be passed instead of the parameter's size, since this system does not support arrays with strings.
 *     For the structure/class type parameters, the system returns the address stored, so you have to deal with memory value natives in order to retrieve/alter the data.
 *     Before triggering something (the internal code), the native basically clean up to 0 the address of the variable/array regarding to the size specified (iMaxSize), in order to always keep your variable/array cleaned up in case of the data could not be retrieved.
 *
 *   Return values (sum of bits):
 *     0 - Failure (not in a stack; not in an AMX hook; invalid parameter number; no address for the parameter; unknown error).
 *     1 - Success (data of the parameter properly retrieved).
 *     2 - The value of the parameter differs from the original (value based, not address based).
 *         Note: This flag will be specified whatever the "bCurrent" boolean is false or true.
 *     4 - The value of the parameter is a string, and its value is a C++ null pointer.
 *
 * Informations about the "set" native:
 *   Usage formats:
 *     For the function address (native's parameter #0): (bool:bCurrent, iNumber, pFunctionAddress) // Useless here (ReAPI module has no address provided in hooks, besides it is locked).
 *     For a variable: (bool:bCurrent, iNumber, anyVariableValue, iMaxSize = 1) // Integer/Float supported.
 *     For an array:   (bool:bCurrent, iNumber, anyArrayValue[], iMaxSize = 1) // Integer/Float supported.
 *     For a string:   (bool:bCurrent, iNumber, StringAlterationMethodType:iMethodType, szStringValue[], {Float, _}:...)
 *
 *   Usage examples with a function having a C++ format like "(int iParam1, float flParam2, Vector vecParam3, Vector vecParam4[5], const char *szParam5)":
 *     ReAPI_HM_SetFunctionParameter(true, 1, 45)
 *     ReAPI_HM_SetFunctionParameter(true, 2, 92.694)
 *     ReAPI_HM_SetFunctionParameter(true, 3, Float:{354.32, 124.87, 173.54})
 *     new Float:vNewParam4[8][3] // Increase the size from 5 to 8 for testing (passing a bigger vector used as replacement of the existing one. "Oups! I showed a feature!").
 *     for(new a = 0; a < sizeof(vNewParam4); a++) {
 *          vNewParam4[a][0] = random_float(-214.2, 654.4)
 *          vNewParam4[a][1] = random_float(-175.6, 742.8)
 *          vNewParam4[a][2] = random_float(-50.0, 220.0)
 *     }
 *     ReAPI_HM_SetFunctionParameter(true, 4, vNewParam4, sizeof(vNewParam4) * sizeof(vNewParam4[]))
 *     ReAPI_HM_SetFunctionParameter(true, 5, SAMT_DYNAMIC_NeverRemove, "This is my new string!")
 *
 *   Extras informations:
 *     This native can only be used in the Pre1 hooks (except for reference parameters where you can use them in the Post1 too).
 *     You can not alter an original parameter.
 *     For the string parameters, I recommend the usage of the following "string alteration methods types" (a SAMT_* from "reapi_const.inc"):
 *       SAMT_Basic               -> Only with some functions that provide an "hardcoded string", like the "pfnClientConnect" and "pfnInconsistentFile" DLL API functions (and please, respect the maximum buffer length).
 *       SAMT_Address             -> When you have a string address to provide.
 *       SAMT_DYNAMIC_NeverRemove -> The most recommended for any kind of strings, this will create a new string that will be removed after the POST hook.
 *       SAMT_SP_Engine           -> The most recommended one when you deal with engine/game functions and related strings as files paths (as the "pfnSetModel" engine API function, "CBasePlayer::GiveAmmo", etc.).
 *     For the string parameters, if you specify "NULL_STRING" as value, this will pass/set a real null string (like a C++ null pointer).
 *
 *   Return values (sum of bits):
 *     0 - Failure (not in a stack; not in an AMX hook; tried on original parameter; invalid parameter number; no address for the parameter; structure/class parameter; parameter locked; unalterable hook (<Pre|Post>2); POST hook with a non-reference parameter or array parameter size bigger than original one; unknown error).
 *     1 - Success (data of the parameter properly altered).
 *     2 - The value of the parameter differs from the original (value based, not address based).
 *         Note: This flag will be specified whatever the "bCurrent" boolean is false or true.
 *     4 - The value of the parameter differs from the previous current (value based, not address based).
 *
 * Extras informations (common to both "get/set" natives):
 *   About the "iMaxSize" parameter (native's parameter #4), 1 is the default value used when not provided (for variables), so you do not need to specify it, except for array parameters (unless you do not want to retrieve/alter full data of an array).
 *   For vector parameters, it is important you provide a size being a multiple of 3 (as for the example function's parameter #4), in case you do not, the system will force "3" as size when lower (when not provided or when you set it to 2).
 *   For the structure/class parameters, the system can not alter them, so you have to deal with memory value natives in order to retrieve/alter the data.
 *
 * Note: Do not forget to read the main (but shorted) introduction/documentation in the top (before this whole description). */
native ReAPI_HM_GetFunctionParameter(bool:bCurrent, iNumber, {Float, _}:...);
native ReAPI_HM_SetFunctionParameter(bool:bCurrent, iNumber, {Float, _}:...);

/* Reset the parameters of a function passed at through an AMX hook of the ReAPI module (this restores the current values to the original values).
 * This native is "all-in-one" and can work for the function address itself (but this is not supported by this module), and for the parameters, mainly due to the fact it works via sum of bits.
 * Returns the sum of bits of the parameters that have been restored.
 *
 * Note: This native can only be used in the Pre1 hooks (except for reference parameters where they are resettable in the Post1 hooks).
 *
 * Usage examples:
 *   Restore the parameters #2 and #4 of a function: ReAPI_HM_ResetFunctionParameters((1<<2) | (1<<4)).
 *   Restore the function itself and all the parameters: ReAPI_HM_ResetFunctionParameters(-1). */
native ReAPI_HM_ResetFunctionParameters(iParamsBits);

/* Get/Set the return value of a function passed at through an AMX hook of the ReAPI module.
 * The "iMethodType" parameter ("get" native) is a ReAPI_FRMT_* from "reapi_const.inc" (more informations in this file).
 * The "bCustom" boolean ("set" native) is to set the custom return value used by the function hook (which is only used instead of the original return value, when the function has been "overridden" or blocked [supercede]).
 * This boolean should always be set to true, because altering the original return value is not possible/allowed (that parameter is just here "in case of", if someday I decide to allow this functionality).
 *
 * Informations about the "get" native:
 *   Usage formats:
 *     For a variable: (ReAPI_FRMT:iMethodType, &anyVariableValue, iMaxSize = 1) // Integer/Float supported.
 *     For a vector:   (ReAPI_FRMT:iMethodType, Float:vVectorValue[], iMaxSize = 3)
 *     For a string:   (ReAPI_FRMT:iMethodType, szStringValue[], iMaxSize, &iStringLength = 0)
 *
 *   Usage examples with a function having a C++ format like "int (int iParam1, float flParam2)":
 *     new iOriginalReturnValue, iCustomReturnValue, iCurrentReturnValue
 *     ReAPI_HM_GetFunctionReturn(ReAPI_FRMT_Original, iOriginalReturnValue)
 *     ReAPI_HM_GetFunctionReturn(ReAPI_FRMT_Custom, iCustomReturnValue)
 *     ReAPI_HM_GetFunctionReturn(ReAPI_FRMT_UsableByGlobal, iCurrentReturnValue)
 *
 *   Usage example with a function having a C++ format like "const char* (int iParam1, Vector vecParam1)":
 *     new szCurrentReturnValue[32]
 *     ReAPI_HM_GetFunctionReturn(ReAPI_FRMT_UsableByGlobal, szCurrentReturnValue, charsmax(szCurrentReturnValue))
 *
 *   Extras informations:
 *     The "ReAPI_FRMT_UsableBy<Local|Global>" are specific methods that make the system uses the actual return value that is "gonna be" used according to the current return value of the hook (more informations in the "reapi_const.inc" file).
 *     For the structure/class type return values, the system returns the address stored, so you have to deal with the memory value natives in order to retrieve/alter the data.
 *     Before triggering something (the internal code), the native basically clean up to 0 the address of the variable/array regarding to the size specified (iMaxSize), in order to always keep your variable/array cleaned up in case of the data could not be retrieved.
 *
 *   Return values (sum of bits):
 *     0 - Failure (not in a stack; not in an AMX hook; invalid method type parameter, no address for the return; unknown error).
 *     1 - Success (data of the return properly retrieved).
 *     2 - The values of the original and custom returns are different (value based, not address based).
 *         Notes:
 *           This flag will be specified whatever the method type specified.
 *           Also, unlike the parameters values (native "ReAPI_HM_GetFunctionParameter"), here when the values are different that does not mean this has been manually modified via the "set" native, no, this simply compares again the both values everytime you use that native.
 *     4 - The value of the return is a string, and its value is a C++ null pointer.
 *
 * Informations about the "set" native:
 *   Usage formats:
 *     For a variable: (bool:bCustom, anyVariableValue, iMaxSize = 1) // Integer/Float supported.
 *     For a vector:   (bool:bCustom, const Float:vVectorValue[], iMaxSize = 3)
 *     For a string:   (bool:bCustom, StringAlterationMethodType:iMethodType, szStringValue[], {Float, _}:...)
 *
 *   Usage example with a function having a C++ format like "edict_t* (float flParam1, const char *szParam2)":
 *     ReAPI_HM_SetFunctionReturn(true, iNewEntityID)
 *
 *   Usage example with a function having a C++ format like "int (int iParam1, float flParam2)":
 *     ReAPI_HM_SetFunctionReturn(true, 24)
 *
 *   Usage example with a function having a C++ format like "Vector (const char *szParam1)":
 *     ReAPI_HM_SetFunctionReturn(true, Float:{54.2, 43.4, 235.9})
 *
 *   Usage example with a function having a C++ format like "const char* (int iParam1, Vector vecParam1)":
 *     ReAPI_HM_SetFunctionReturn(true, SAMT_TSP, "My mother is a %s good %s.", "very", "cooker")
 *
 *   Extras informations:
 *     You can not alter an original return value.
 *     For the string return values, I recommend the usage of the following "string alteration methods types" (a SAMT_* from "reapi_const.inc"):
 *       SAMT_Address   -> When you have a string address to provide (and only when the string matching to it will still be available after the whole function call).
 *       SAMT_SP_Engine -> The most recommended one when you deal with engine/game functions and related strings as files paths (as the "pfnSetModel" engine API function, "CBasePlayer::GiveAmmo", etc.).
 *                         And also when you are not using a bunch of different strings on each call.
 *       SAMT_TSP       -> The most recommended one when you use a bunch of different strings on each call.
 *                         Note: Using this will create (or point to) a string then it will be removed 0.05 second later.
 *     For the string return values, if you specify "NULL_STRING" as value, this will pass/set a real null string (like a C++ null pointer).
 *
 *   Return values (sum of bits):
 *     0 - Failure (not in a stack; not in an AMX hook; tried on original return value; no address for the parameter; structure/class return; return value locked; unalterable hook (<Pre|Post>2); unknown error).
 *     1 - Success (data of the return properly altered).
 *     2 - The value of the return differs from the original (value based, not address based).
 *         Note: This flag will be specified whatever the "bCustom" boolean is false or true.
 *     4 - The value of the return differs from the previous current (value based, not address based).
 *
 * Extra information (common to both "get/set" natives):
 *   About the "iMaxSize" parameter (native's parameter #3), you do not need to provide it (except for strings), since arrays are not supported with the return values.
 *   For the structure/class return values, the system can not alter them, so you have to deal with the memory value natives in order to retrieve/alter the data.
 *
 * Note: Do not forget to read the main introduction/documentation in the top (before this whole description). */
native ReAPI_HM_GetFunctionReturn(ReAPI_FRMT:iMethodType, {Float, _}:...);
native ReAPI_HM_SetFunctionReturn(bool:bCustom, {Float, _}:...);

/* Get the return value (status) of an AMX hook of the ReAPI module.
 * Returns a ReAPI_AHRVF_* from "reapi_const.inc".
 *
 * Informations about the "bGlobal" boolean parameter:
 *   When set to false, the native will return the current value from the local hooks calls.
 *   The "local" represents all the calls of a single hook, for example, all the "Pre1" hooks in the plugins.
 *   The "global" represents the final result associated to the function in which one a single or a multiple different hooks can be implemented and called.
 *   In other terms, the "global" is the most useful mode due to the fact it deals with the function itself.
 *
 *   Let's make an example with a call for a hook chain function in the ReAPI.
 *   In the module, there is a C++ hook/callback of that function, and inside those hooks are called (in such order):
 *     #1: Local/Single call -> All the "ReAPI_AHCT_Pre1_Alterable" hooks are called.
 *     #2: Local/Single call -> If not "ReAPI_AHRVF_CANCEL_AllPre", all the "ReAPI_AHCT_Pre2_Unalterable" hooks are called.
 *     #3: Local/Single call -> If not "ReAPI_AHRVF_CANCEL_AllPost", all the "ReAPI_AHCT_Post1_Alterable" hooks are called.
 *     #4: Local/Single call -> If not "ReAPI_AHRVF_CANCEL_AllPost", all the "ReAPI_AHCT_Post2_Unalterable" hooks are called.
 *     Total #1 + #2 + #3 + #4 = Global/Multiple call.
 *
 *   Also, unlike the local, the global is not altered for the function call in a hook on POST, but it can be for the function return (for non-void return functions).
 *   That means it is possible to get the "ReAPI_AHRVF_Supercede" return value flag in a "ReAPI_AHCT_Post1_Alterable" by setting the "bGlobal" boolean to false (if such return value has been specified inside this hook),
 *   while with the "bGlobal" to true you might get "ReAPI_AHRVF_Ignored" if the "ReAPI_AHCT_Pre1_Alterable" hook has not been blocked.
 *
 * Informations about the "bForFunctionReturn" boolean parameter:
 *   It allows to retrieve the AMX hook return value flag specific for the function call itself, and the one for the function return (for non-void return functions).
 *   This parameter is "mandatory" in order to retrieve proper result according to your needs.
 *   Because, if I take an example with the "CSGameRules::CanHavePlayerItem" function, you can let the function from being called in the "Pre1" call type,
 *   but in a "Post1" call type you may wish to force the return value and use the "ReAPI_AHRVF_Override" or "ReAPI_AHRVF_Supercede" return value flag (but only the "override" should be used in a "Post1" call type).
 *   So from that point, if there is a next call type (hook), you have to be able (from that point) to differentiate the return value used for the function call, and the one used for its return value, however, you could not just know that!
 *
 * Notes:
 *   Most of the time, you'll only need to use one of this natives in the "Pre2" or "Post<1|2>" call types, in order to check if the function call has been blocked (supercede), and ignore your code from being called in such case (when needed).
 *   So, you'll use it like this:
 *     if(ReAPI_HM_GetHookReturn(true, false) & ReAPI_AHRVF_Supercede)
 *       return ReAPI_AHRVF_Ignored
 *
 *     // Here is the rest of your plugin's code which will only take effect when the function has not been blocked (supercede).
 *     ...
 *     return ReAPI_AHRVF_Ignored
 *
 *   Also keep in mind, since the previous "ReAPI_HM_GetFunctionReturn" native has different method types, including an automatic one (ReAPI_FRMT_UsableByGlobal), you do not need to use this native in order to know which return value (original or custom) will be used for the current function call.
 *
 *   Do not forget to read the main introduction/documentation in the top (before this whole description). */
native ReAPI_HM_GetHookReturn(bool:bGlobal, bool:bForFunctionReturn);


/********************** NATIVES -> Extra stuff -> Various *********************/

/* Set a key value on an info buffer.
 * When the "pszInfoBuffer" parameter is set to 0, the system will automatically retrieve and use the current info buffer pointer from the following functions:
 *   Engine (ReHLDS): "SV_WriteFullClientUpdate", "SV_CheckUserInfo" (from parameter #2).
 *   Game (ReGameDLL_CS): "CBasePlayer::SetClientUserInfoName", "CBasePlayer::SetClientUserInfoModel", "CSGameRules::ClientUserInfoChanged" (from parameter #2).
 * So you must specify "0" when used in those functions, not elsewhere!
 *
 * Notes:
 *   This native has been added in order to be used in the callbacks of some functions not passing this buffer as pointer, since I pass the "readable string" on the callbacks.
 *   But it is also because I have not provided my other natives to retrieve advanced informations about my parameters and return system. */
native ReAPI_ES_SetKeyValue(pszInfoBuffer, const szKey[], const szValue[]);

