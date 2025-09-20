/*
 * VexdUM (Vexd's Utility Module), v2013-TFP5.
 *
 * Functions (forwards, natives).
 *
 * Copyright (C) - Vexd, AMX Mod Team, AMX Mod Dev
 * This file is provided as is (no warranties).
 *
 */

#if defined _vexdum_included
  #endinput
#endif
#define _vexdum_included

#include <VexdUM_const>

/* Called when a model file is precached (pre/post). */
forward precachemodel(const szModel[]);
forward precachemodel_post(const szModel[]);

/* Called when a sound file is precached (pre/post). */
forward precachesound(const szSound[]);
forward precachesound_post(const szSound[]);

/* Called when a generic file is precached (pre/post). */
forward precachegeneric(const szFile[]);
forward precachegeneric_post(const szFile[]);

/* Called when an event is precached (pre/post). */
forward precacheevent(iType, const szName[]);
forward precacheevent_post(iType, const szName[]);

/* Called when a client types "kill" in console. */
forward client_kill(id);

/* Called when a client is attaching to a view (as a camera at "cs_assault" map). */
forward client_setview(id, iEntityID, const szEntityClassName[]);

/* Called when two clients can listen themselves.
 * Note: Called only when both clients are connected. */
forward client_setlistening(iReceiverID, iSenderID, bool:bListen, const iReceiverStatusFlags, const iSenderStatusFlags);

/* Called when a client is sending an impulse command. */
forward client_impulse(id, iImpulse);

/* Called on each data update of the client (pre/post). */
forward client_updatedata(id, iCDHandle, iSendWeapons, const iClientStatusFlags);
forward client_updatedata_post(id, iCDHandle, iSendWeapons, const iClientStatusFlags);

/* Called when a client start a command (pre/post). */
forward client_cmdstart(id, iUCHandle, iRandomSeed, const iClientStatusFlags);
forward client_cmdstart_post(id, iUCHandle, iRandomSeed, const iClientStatusFlags);

/* Called before the engine calculates player movement.
 * Evolution (*_evo): Passes alive/bot status, flags, buttons, oldbuttons. */
forward client_prethink(id);
forward client_prethink_evo(id, const iClientStatusFlags, iFlags, iButtons, iOldButtons);

/* Called after the engine has calculated player movement.
 * Evolution (*_evo): Passes alive/bot status, flags, buttons, oldbuttons. */
forward client_postthink(id);
forward client_postthink_evo(id, const iClientStatusFlags, iFlags, iButtons, iOldButtons);

/* Called when an entity is spawned.
 * Evolution (*_evo): Passes classname of the entity. */
forward entity_spawn(iEntityID);
forward entity_spawn_evo(iEntityID, const szClassName[]);

/* Called on an entity's DispatchThink.
 * Evolution (*_evo): Passes classname of the entity. */
forward entity_think(iEntityID);
forward entity_think_evo(iEntityID, const szClassName[]);

/* Called when 2 entities touch.
 * Evolution (*_evo): Passes classname of the entities. */
forward entity_touch(iEntity1ID, iEntity2ID);
forward entity_touch_evo(iEntity1ID, iEntity2ID, const szEntity1ClassName[], const szEntity2ClassName[]);

/* Called once every server frame. */
forward server_frame();

/* Called when the map light is initialized/changed. */
forward lightstyle(iStyle, const szLight[]);

/* Called when an entity is created (pre/post). */
forward createnamedentity(const szClassName[]);
forward createnamedentity_post(const szClassName[]);

/* Called when an emitting sound is played server-side. */
forward emitsound(entity, const sample[]);

/* Called when an emitting ambient sound is played server-side. */
forward emitambientsound(entity, const sample[]);

/* Called when a model spawns. */
forward set_model(entity, const model[]);

/* Called whatever an entity looks at. */
forward traceline(entity);
forward traceline_post(const Float:vStart[3], const Float:vEnd[3], iIgnoredFlags, iIgnoredEntityID, pTraceResultHandle);

/* Called when a monster is hurt by VexdUM damage natives. */
forward monster_hurt(monster, attacker, damage);

/* Called when an entity gets a keyvalue set on it from the engine.
 * Use copy_keyvalue to get the keyvalue information. */
forward keyvalue(entity);

/* Called when a keyvalue is set on a player. */
forward setclientkeyvalue(id, key[], value[]);

/* Called when an alert message is sent. */
forward alertmessage(atype, message[]);

/* Called when gamedescription is called. */
forward gamedescription();

/* Called when an entity searches others entities in a sphere, as grenades, etc. (pre/post). */
forward findentityinsphere(iEntityID, const Float:vOrigin[3], Float:flRadius);
forward findentityinsphere_post(iEntityID, const Float:vOrigin[3], Float:flRadius);

/* Called when an entity searches a client in its PVS field. */
forward findclientinpvs(iEntityID);
forward findclientinpvs_post(iEntityID);

/* Called when an entity is visible in the PVS (pre/post). */
forward checkvisibility(iEntityID, pSet);
forward checkvisibility_post(iEntityID, pSet);

/* Called when an event is played (pre/post). */
forward playbackevent(iFlags, iEntityID, iEventID, Float:flDelay, Float:vOrigin[3], Float:vAngles[3], Float:flParam1, Float:flParam2, iParam1, iParam2, iBParam1, iBParam2);
forward playbackevent_post(iFlags, iEntityID, iEventID, Float:flDelay, Float:vOrigin[3], Float:vAngles[3], Float:flParam1, Float:flParam2, iParam1, iParam2, iBParam1, iBParam2);

/* Forward AddToFullPack (pre/post).
 * See HLSDK for more informations about this forward.
 * Careful: Called many times (more than 1000 times per second). */
forward addtofullpack(es, e, iEnt, id, hostflags, player, pSet, iCCRV);
forward addtofullpack_post(es, e, iEnt, id, hostflags, player, pSet, iORV);
forward addtofullpack_post_orv(pEntityStateHandle, iIntEntityID, iEntityID, iHostID, iHostFlags, iPlayer, pSet, iORV);

/* Sets a user model, model would be "vip" for the vip model...
 * By default it clears the model if there is no defined model (just set_user_model(id)). */
native set_user_model(id, const Model[] = "");

/* Sets model (TFC). */
native TFC_SetModel(id, const Model[], const Skin[]);

/* Clears model (TFC). */
native TFC_ClearModel(id);

/* Sets player's view to entity index. */
native attach_view(id, ent);

/* Gets player's speak flags. */
native get_speak(id, target = 0);

/* Sets player's speak flags.
 * Speak flags:
 *  SPEAK_NORMAL
 *  SPEAK_MUTED
 *  SPEAK_ALL
 *  SPEAK_LISTENALL */
native set_speak(id, iSpeakFlags, target = 0);

/* Sets map lightning, #OFF to disable. */
native set_lights(const Lightning[]);

/* Get/Set an entity ID (edict pointer for the engine) from the "entvars" structure of an entity.
 * The "get" native returns -1 on failure (invalid entity ID) or entity ID.
 * The "iType" parameter is a EV_ENT_* from "vexdum_const.inc". */
native entity_get_edict(iEntityID, iType);
native entity_set_edict(iEntityID, iType, iTargetID);

/* Get/Set a byte array from the "entvars" structure of an entity.
 * The "iType" parameter is a EV_BYTE_* from "vexdum_const.inc".
 *
 * Note: The third parameter must be a byte array to get/set the datas (stored inside it). */
native entity_get_byte(iEntityID, iType);
native entity_set_byte(iEntityID, iType, iValue);

/* Get/Set an integer from the "entvars" structure of an entity.
 * The "iType" parameter is a EV_INT_* from "vexdum_const.inc". */
native entity_get_int(iEntityID, iType);
native entity_set_int(iEntityID, iType, iValue);

/* Get/Set a float from the "entvars" structure of an entity.
 * The "iType" parameter is a EV_FL_* from "vexdum_const.inc". */
native Float:entity_get_float(iEntityID, iType);
native entity_set_float(iEntityID, iType, Float:flValue);

/* Get/Set a vector from the "entvars" structure of an entity.
 * The "iType" parameter is a EV_VEC_* from "vexdum_const.inc".
 * For the "get" native, the value is returned in the "vValue" array. */
native entity_get_vector(iEntityID, iType, Float:vValue[3]);
native entity_set_vector(iEntityID, iType, const Float:vValue[3]);

/* Get/Set a string from the "entvars" structure of an entity.
 * The "iType" parameter is a EV_SZ_* from "vexdum_const.inc".
 * For the "get" natives, the value is returned as string integer/offset format (isz*) for the "isz" one, and in the "szValue" array for the "sz" one.
 * For the "set" natives, the "isz" one is designed to be used with a static string previously allocated at an integer format (isz*, which is more for an upcoming "thing" I'm gonna release),
 * and the "sz" one is the classic "string" version (less efficient but enough in "one shot" usage as on map start). */
native entity_get_string_isz(iEntityID, iType);
native entity_get_string(iEntityID, iType, szValue[], iLength);
native entity_set_string_isz(iEntityID, iType, iszValue);
native entity_set_string(iEntityID, iType, const szValue[]);

/* Check if an entity has/starts/contains the string from the "entvars" structure of an entity.
 * The "iType" parameter is a EV_SZ_* from "vexdum_const.inc".
 * The "iCompareType" parameter is a CT_* from "amxconst.inc". */
native has_entvars_string(iEntityID, iType = EV_SZ_classname, const szValue[], CompareType:iCompareType = CT_EqualCS);

/* Sets the model of an entity. */
native entity_set_model(ent, const szModel[]);

/* Get/Set the origin of an entity.
 * The "get" version is the "best" native to get that (it uses ABS mins/maxs for a non-player).
 * The "bAddViewOffset" is to add the view offset origin to the initial origin.
 * The "set" version makes a proper update with the engine (calls the "SetOrigin" engine API function).
 * But, in some situations it's better (or not) to use the "entity_set_vector" native with the "EV_VEC_origin" enumeration type (avoid potential crashes...). */
native get_entity_origin(iEntityID, bool:bAddViewOffset = false, Float:vOrigin[3]);
native entity_set_origin(iEntityID, const Float:vOrigin[3]);

/* Sets the bounding box size of an entity. */
native entity_set_size(ent, const Float:vecMin[3], const Float:vecMax[3]);

/* Gets things in Globalvars Struct. See HLSDK or look at examples to determine what different variables do.
 * iVar is a GV_* from VexdUM_const.inc. */
native global_get_int(iVar);
native Float:global_get_float(iVar);
native global_get_vector(iVar, Float:vVal[3]);
native global_get_edict(iVar);
native global_get_string(iVar, szVal[], iLen);

/* Gets/Sets things in a players TraceLine Struct. See HLSDK or look at examples to determine what different variables do.
 * Can only be called in traceline(entity) forward function.
 * iVar is a TR_* from VexdUM_const.inc. */
native traceline_get_int(iVar);
native traceline_set_int(iVar, iVal);
native Float:traceline_get_float(iVar);
native traceline_set_float(iVar, Float:fVal);
native traceline_get_vector(iVar, Float:vVal[3]);
native traceline_set_vector(iVar, Float:vVal[3]);
native traceline_get_edict(iVar);
native traceline_set_edict(iVar, iEnt);

/* Creates a "TraceResult" handle you can use with the "<get|set>_trace_result" natives.
 * Returns a "TraceResult" handle pointer. */
native create_trace_result();

/* Removes a "TraceResult" handle previously created. */
native remove_trace_result(pTraceResultHandle);

/* Gets/Sets a trace result data type from the "TraceResult" structure.
 * The "iType" parameter is a TR_* from "VexdUM_const.inc".
 *
 * Informations/Usage ("get" native):
 *   Entity/Integer type (TR_<ENT|INT>_*): The native returns the value, so don't pass a third parameter (not used).
 *   Float/Vector type (TR_<FL|VEC>_*): Pass a third parameter (a float variable or a vector array) to store the result in it.
 *
 * Informations/Usage ("set" native):
 *   Entity/Integer/Float/Vector type (TR_<ENT|INT|FL|VEC>_*): Specify this kind of value in the third parameter.
 *
 * Note: Specify "0" as handle to use the global one used by any trace native if handle used was 0. */
native get_trace_result(pTraceResultHandle, TraceResult:iType, {Float,_}:...);
native set_trace_result(pTraceResultHandle, TraceResult:iType, {Float,_}:...);

/* Some damage functions. */
native radius_damage(inflictor, Float:dmg, Float:orig[3], Float:rad, bit = DMG_BULLET, wpnName[] = "", hs = 0);
native take_damage(victim, attacker, Float:orig[3], Float:dmg, bit = DMG_BULLET, wpnName[] = "", hs = 0);
native client_death(victim, attacker, wpnName[] = "", hs = 0);

/* Will return the contents of a point (inside map? in sky? outside map? etc.).
 * Result is a CONTENTS_* from VexdUM_const.inc. */
native PointContents(const Float:fCheckAt[3]);

/* Dispatch a KeyValuePair, used for initalizing entities when a map spawns them.
 * Format: DispatchKeyValue("KeyName", "Value") - Sets keyvalue for the entity specified in the keyvalue() forward.
 * Format: DispatchKeyValue(ent, "KeyName", "Value") - Sets keyvalue for entity not specified in keyvalue() forward. */
native DispatchKeyValue(...);

/* Runs the GameDLL's DispatchSpawn for an entity, I think it's used with DispatchKeyValue. */
native DispatchSpawn(ent);

/* Creates an entity, will return the index of the created entity. ClassName must be valid. */
native create_entity(const szClassname[]);

/* Finds an entity in the world, will return -1 if nothing is found.
 * Type (optionnal):
 *   0 - "classname" (default)
 *   1 - "globalname"
 *   2 - "model"
 *   3 - "target"
 *   4 - "targetname"
 *   5 - "netname"
 *   6 - "message"
 *   7 - "noise"
 *   8 - "noise1"
 *   9 - "noise2"
 *  10 - "noise3"
 *  11 - "viewmodel"
 *  12 - "weaponmodel" */
native find_entity(ent, const szValue[], type = 0);

/* Finds an entity within a given origin and radius. */
native find_entity_sphere(ent, const Float:Orig[3], Float:Rad);

/* Removes an entity from the world. */
native remove_entity(ent);

/* Traces a line from Start(X, Y, Z) to End(X, Y, Z), will return the point hit in vReturn[3].
 * Will return an entindex if an entity is hit. */
native trace_line(ent, const Float:fStart[3], const Float:fEnd[3], Float:vRtn[3]);

/* Traces a line between two points. Engine version.
 * Returns 0 or entity ID if hit.
 *
 * Note: Use the "<get|set>_trace_result" natives to deal with the "TraceResult" structure. */
native trace_line_normal(const Float:vStart[3], const Float:vEnd[3], iIgnoredFlags, iIgnoredEntityID, pTraceResultHandle = 0);

/* Traces a hull. */
native trace_hull(const Float:fOrigin[3], hull, ignoredent = 0, ignoremonsters = 0);

/* Traces a hull between two points. Engine version.
 *
 * Return values (sum of bits):
 *   0 - null result
 *   1 - initial origin in a solid area
 *   2 - invalid plane (can detect if "blocked")
 *   4 - start point is in the world (not inside something else)
 *
 * Note: Use the "<get|set>_trace_result" natives to deal with the "TraceResult" structure. */
native trace_hull_normal(const Float:vStart[3], const Float:vEnd[3], iIgnoredFlags, iHullNumber, iIgnoredEntityID, pTraceResultHandle = 0);

/* Traces a line, and returns the normal to the plane hit in vReturn.
 * Returns 0 if theres no normal. */
native trace_normal(ent, const Float:fStart[3], const Float:fEnd[3], Float:vRtn[3]);

/* Traces what texture an entity is looking at or standing on.
 * Setting type:
 *  0 - Trace Forward
 *  1 - Trace Below */
native trace_texture(ent, szBuf[], iLen, set = 0);

/* Traces a texture check for an entity between two origins. Engine version (format).
 * The "iTextureEntityID" is the texture entity to check between the two points (can be a null one).
 * Returns 0 or texture type ID (calls the "pfnPM_FindTextureType" DLL API function on the texture name).
 * Returns the texture name in the "szTextureName" array if the "iLength" parameter is higher than 0. */
native trace_texture_normal(iTextureEntityID, const Float:vStart[3], const Float:vEnd[3], szTextureName[] = "", iLength = 0);

/* Traces result. */
native trace_result(type, {Float,_}:...);

/* Precache event. */
native precache_event(type, const szEvent[]);

/* Playback a precached event. */
native playback_event(flags, invoker, eventindex, Float:delay, const Float:origin[3], const Float:angles[3], Float:fparam1, Float:fparam2, iparam1, iparam2, bparam1, bparam2);

/* Gets a integer from index's pvPrivateData at offset. */
native get_offset_int(ent, offset, linos = 5);

/* Sets a integer value in index's pvPrivateData at offset. */
native set_offset_int(ent, offset, value, linos = 5);

/* Gets a float from index's pvPrivateData at offset. */
native Float:get_offset_float(ent, offset, linos = 5);

/* Sets a float value in index's pvPrivateData at offset. */
native set_offset_float(ent, offset, Float:value, linos = 5);

/* Checks if index is an existing ent. */
native is_entity(ent);

/* Gets number of ents in a map. */
native get_num_ents();

/* Returns maxentities setting. */
native get_maxentities();

/* Gets whole buffer containing keys and their data. */
native get_info_keybuffer(id, szBuffer[], length);

/* Gets keyvalue from the entity. */
native get_keyvalue(ent, const szKey[], szValue[], length);

/* Copy keyvalue when keyvalue forward is called. */
native copy_keyvalue(szClassName[], iLen1, szKeyName[], iLen2, szValue[], iLen3);

/* Sets keyvalue on a player. */
native set_client_keyvalue(id, szKey[], szValue[]);

/* Gets decal index. */
native get_decal_index(const szDecalName[]);

/* Fake one entity touching another. */
native fake_touch(ent1, ent2);

/* CBaseEntity::Think() from the entity. */
native call_think(entity);

/* Calls a Half-Life engine DLL function.
 * type is a DLLFunc_* from VexdUM_const.inc. */
native dllfunc(type, {Float,_}:...);

/* Sets game description. Can only be called in gamedescription() forward function. */
native set_gamedescription(desc[]);

/* These functions are used with the entity_state data structure (AddToFullPack forward).
 * Get:
 *  0 - extra params - return integer
 *  1 - extra param - by ref float or vector or array
 * Set: Use anything
 * Use 0 for es_handle to specify the global entity_state handle. 
 * member is an ES_* from VexdUM_const.inc. */
native get_es(es_handle, EntityState:member, {Float,_}:...);
native get_entity_state(pEntityStateHandle, EntityState:iType, {Float,_}:...);
native set_es(es_handle, EntityState:member, {Float,_}:...);
native set_entity_state(pEntityStateHandle, EntityState:iType, {Float,_}:...);

/* Returns data for Metamod. */
native forward_return(type, {Float,_}:...);

/* Bot natives. */
native create_bot(name[]);
native remove_bot(id);
native control_bot(id, Float:vAngles[3], Float:fMove, Float:sMove, Float:uMove, Buttons, Impulse, mSec);

/* Some misc. natives. */
native dot_points(Float:vSrc[3], Float:vCheck[3], Float:vDir[3]);
native Float:dot_product(Float:vecA[3], Float:vecB[3]);
native normalize(Float:vVec[3], Float:vRet[3]);
native can_see(ent1, ent2);
native in_view_cone(ent, const Float:Orig[3]);
native drop_to_floor(ent);
native entity_use(eUsed, eOther);
native index_to_pointer(index);
native pointer_to_index(pointer);
native make_vectors(Float:vVec[3]);

/* Checks if an entity can view an origin (nothing between). */
native is_origin_visible(iEntityID, const Float:vOrigin[3]);

/* Function checks 4 points on a plane made on an entity based on its bounding box (it is like 4 trace lines made to 4 different points calculated by the bounding box!).
 * Returns 1 if one point from the borderplane is visible.
 *
 * Paramaters informations:
 *   vStartOrigin: Start point (this is the point where the trace starts!).
 *   vEndOrigin: End origin, from this origin the plane will be created in right,left,up and down.
 *   vMins and vMaxs: Bounding box of the target entity, use customs if you like.
 *   iIgnoredFlags: Ignore property (see trace line tutorial).
 *   iIgnoredEntityID: Ignored entity.
 *   flMultiplierValue:
 *     Multiplication constant, normally the plane has the size of the cube that surronds the entity.
 *     If this constant for example 0.5 then the plane is 1/2 times smaller */
native is_borderplane_visible(Float:vStartOrigin[3], Float:vEndOrigin[3], Float:vMins[3], Float:vMaxs[3], iIgnoredFlags = DONT_IGNORE_MONSTERS, iIgnoredEntityID, Float:flMultiplierValue = 1.0);

/* Sets an impulse. Can only be used in "client_impulse" forward. */
native set_impulse(iImpulse);

/* Gets physics keyvalue from a client. */
native get_client_physicskeyvalue(id, const szKey[], szValue[], iLength);

/* Sets physics keyvalue on a client. */
native set_client_physicskeyvalue(id, const szKey[], const szValue[]);

/* Gets the model index from a model. */
native entity_get_modelindex(const szModel[]);

/* Gets the bone position and angles from a player, via a bone ID. */
native entity_get_boneposition(id, iBoneID, const Float:vOrigin[3], const Float:vAngles[3]);

/* Checks if an entity is in your PVS. Can only be used in "addtofullpack[_post]" forward. */
native entity_check_visibility(iEntityID, pSet);

/* Checks the first entity in your PVS. Then, use it yourself as a loop with entity_get_edict(iEntityID, EV_ENT_chain) to get next entities. */
native find_entity_pvs(iEntityID);

/* Gets a private id from index's pvPrivateData at offset. */
native get_offset_cbase_heavy(iEntityID, iOffset, iLinuxDiff = 5);
native get_offset_cbase(iEntityID, iOffset, iLinuxDiff = 5);

/* These functions are used with the client data structure (client_updatedata[_post] forward).
 * Get: Specify a third parameter only for a vector or a string.
 * Set: Use anything.
 * Use 0 for iCDHandle to specify the global client data handle (but not used). 
 * iType is a CD_*_* from VexdUM_const.inc. */
native get_client_data(iCDHandle, eClientData:iType, {Float,_}:...);
native set_client_data(iCDHandle, eClientData:iType, {Float,_}:...);

/* These functions are used with the user command structure (client_cmdstart[_post] forward).
 * Get: Specify a third parameter only for a vector.
 * Set: Use anything.
 * Use 0 for iUCHandle to specify the global user command handle (but not used). 
 * iType is a UC_*_* from VexdUM_const.inc. */
native get_user_command(iUCHandle, eUserCommand:iType, {Float,_}:...);
native set_user_command(iUCHandle, eUserCommand:iType, {Float,_}:...);

/* Gets the original value from an engine function. Can only be used in forwards declared as "post".
 * Number of parameters:
 *   none - returns integer value
 *   one  - returns float value (no forward uses it)
 *   two  - returns a string (no forward uses it) */
native get_original_returnvalue({Float,_}:...);

/* Registers/Unregisters a "VexdUM" forward.
 * The "szForward" parameter is the name of the VexdUM" forward above (sensitive).
 *
 * Return values:
 *   0 - failed (forward is invalid or not present inside the plugin or already [un]registered, plugin not running)
 *   1 - registered with success
 *   2 - registered with success and engine function table enabled */
native register_VexdUM_forward(const szForward[]);
native unregister_VexdUM_forward(const szForward[]);

/* Registers/Unregisters a "OnFreeEntPrivateData", "Think", "Touch", "ShouldCollide", "SetModel", "EmitSound", "EmitAmbientSound", "AddToFullPack" (engine/DLL API) forward with a custom class/model/sample, a custom compare type, and a custom function.
 * The "bPost" boolean (or "iHookType" for the "AddToFullPack") is to declare the function as POST (after the execution of the original function, however it's before).
 * The "i*CompareType" parameters are a CT_* from "VexdUM_const.inc". Specify "NULL_STRING" (or anything) as class/model parameter(s) and "CT_None" as compare type(s) to do not use the filters (the forward will be called for any class/model).
 * The "szPublicFunction" parameter is the name of your public function.
 * The "p<OnFreeEntPrivateData|Think|Touch|ShouldCollide|SetModel|EmitSound|EmitAmbientSound|AddToFullPack>Handle" variables return the pointer of the forward you can use with the "light" natives (more efficient, always use it in your plugin's forward(s)).
 *
 * Specific "OnFreeEntPrivateData" information:
 *   The format of a public function must be (example name): "public OnFreeEntPrivateData_Example(iEntityID)".
 *
 * Specific "Think" information:
 *   The format of a public function must be (example name): "public Think_Example(iEntityID)".
 *
 * Specific "Touch" informations:
 *   The format of a public function must be (example name): "public Touch_Example(iTouchedID, iOtherID)".
 *
 * Specific "ShouldCollide" informations:
 *   The format of a public function must be (example name): "public ShouldCollide_Example(iTouchedID, iOtherID)".
 *
 * Specific "SetModel" information:
 *   The format of a public function must be (example name): "public SetModel_Example(iEntityID, const szModelPath[])".
 *
 * Specific "EmitSound" information:
 *   The format of a public function must be (example name): "public EmitSound_Example(iEntityID, iChannel, const szSample[], Float:flVolume, Float:flAttenuation, iFlags, iPitch)".
 *
 * Specific "EmitAmbientSound" information:
 *   The format of a public function must be (example name): "public EmitAmbientSound_Example(iEntityID, const Float:vOrigin[3], const szSample[], Float:flVolume, Float:flAttenuation, iFlags, iPitch)".
 *
 * Specific "AddToFullPack" informations:
 *   The format of a public function as PRE must be (example name): "public AddToFullPack_Example(pEntityStateHandle, iIntEntityID, iEntityID, iHostID, iHostFlags, iPlayer, pSet, iCCRV)".
 *   The format of a public function as POST or POST + ORV must be (example name): "public AddToFullPack_Example(pEntityStateHandle, iIntEntityID, iEntityID, iHostID, iHostFlags, iPlayer, pSet, iORV)".
 *
 *   Hook types (iHookType): See ATFPT_* from "vexdum_const.inc" for the list and informations.
 *   About the class parameter after the "iHookType" one, it's related to the entity ID the host receives informations (iIntEntityID/iEntityID).
 *   Also, the validity of this entity is checked before the forward execution (because this forward can be called on invalid/removed entities).
 *
 * Global informations:
 *   If you only change the compare type (CT_*) of an existing forward hook, this will not create a new forward but simply changes its compare type.
 *   Unlike the classic/global forwards (above), the validity of the entity is checked for all of these custom forwards (with a safe mode as including private data check), and even for the second entity (other) in the "Touch" and "ShouldCollide" forwards.
 *   So according to this, it can happen a call as PRE is done for an entity, but not as POST if in case you removed it in the PRE by using the "RemoveEntity" engine API function (removed instantly instead of in the next server frame).
 *   These natives are optimized for players. That means if you specify "player" as class name and "CT_EqualCS" as compare type, no string comparison is performed, the module only checks if the entity is in the 1<->maxplayers range.
 *
 * Return values:
 *   0 - failed (incorrect parameters, invalid public function or specified plugin, forward already [un]registered with the same parameters)
 *   1 - registered/unregistered with success
 *   2 - registered/unregistered with success and engine/DLL API function table enabled/disabled
 *
 * Notes:
 *   Do not forget to set the "p<OnFreeEntPrivateData|Think|Touch|ShouldCollide|SetModel|EmitSound|EmitAmbientSound|AddToFullPack>Handle" variable to 0 on success (when unregistered with the "light" versions).
 *
 *   What's the purpose of these natives and why they have been made?
 *     Mainly two reasons:
 *       #1: Make the AMX Mod plugins coders life easy (especially mine!), so they can register a forward already filtered. Then, the forward will only be called if the condition(s) they specified match(es).
 *       #2: Huge performance/optimization gain (about server ressources used).
 *           The module internally filters the classes/models/samples by comparing the string(s), then, it only calls the "AMX execution system" (transfert/conversion of C++ data to pawn/plugins, which uses some ressources) when the condition(s) match(es).
 *           The engine/DLL API functions I've chosen to add with these natives are frequently used or/and called (especially for "Think", "Touch" and "AddToFullPack"!).
 *           You can request for others ones but I'm not sure I'll do it because it may not be necessary.
 *
 *     These natives have no specific restriction, but they are designed to be used intelligently.
 *     I mean, for example, register a custom forward for all the available classes/entities (except if an unique one with "CT_None" where no comparison is performed) on the map is stupid and will be even less efficient than using the classic forwards,
 *     because the module will check and compare the data for almost "nothing" since this will be called anyway... */
/* Natives for custom "OnFreeEntPrivateData" forward. */
native register_ofepd_forward(bool:bPost, const szClass[], CompareType:iCompareType = CT_EqualCS, const szPublicFunction[], &pOnFreeEntPrivateDataHandle = 0);
native unregister_ofepd_forward_light(pOnFreeEntPrivateDataHandle);
native unregister_ofepd_forward(bool:bPost, const szClass[], CompareType:iCompareType = CT_EqualCS, const szPublicFunction[]);
/* Natives for custom "Think" forwards. */
native register_think_forward(bool:bPost, const szClass[], CompareType:iCompareType = CT_EqualCS, const szPublicFunction[], &pThinkHandle = 0);
native unregister_think_forward_light(pThinkHandle);
native unregister_think_forward(bool:bPost, const szClass[], CompareType:iCompareType = CT_EqualCS, const szPublicFunction[]);
/* Natives for custom "Touch" forwards. */
native register_touch_forward(bool:bPost, const szTouchedClass[], CompareType:iTouchedCompareType = CT_EqualCS, const szOtherClass[], CompareType:iOtherCompareType = CT_EqualCS, const szPublicFunction[], &pTouchHandle = 0);
native unregister_touch_forward_light(pTouchHandle);
native unregister_touch_forward(bool:bPost, const szTouchedClass[], CompareType:iTouchedCompareType = CT_EqualCS, const szOtherClass[], CompareType:iOtherCompareType = CT_EqualCS, const szPublicFunction[]);
/* Natives for custom "ShouldCollide" forwards. */
native register_scoll_forward(bool:bPost, const szTouchedClass[], CompareType:iTouchedCompareType = CT_EqualCS, const szOtherClass[], CompareType:iOtherCompareType = CT_EqualCS, const szPublicFunction[], &pShouldCollideHandle = 0);
native unregister_scoll_forward_light(pShouldCollideHandle);
native unregister_scoll_forward(bool:bPost, const szTouchedClass[], CompareType:iTouchedCompareType = CT_EqualCS, const szOtherClass[], CompareType:iOtherCompareType = CT_EqualCS, const szPublicFunction[]);
/* Natives for custom "SetModel" forwards. */
native register_setmdl_forward(bool:bPost, const szClass[], CompareType:iClassCompareType = CT_EqualCS, const szModelPath[], CompareType:iModelPathCompareType = CT_EqualCS, const szPublicFunction[], &pSetModelHandle = 0);
native unregister_setmdl_forward_light(pSetModelHandle);
native unregister_setmdl_forward(bool:bPost, const szClass[], CompareType:iClassCompareType = CT_EqualCS, const szModelPath[], CompareType:iModelPathCompareType = CT_EqualCS, const szPublicFunction[]);
/* Natives for custom "EmitSound" forwards. */
native register_emits_forward(bool:bPost, const szClass[], CompareType:iClassCompareType = CT_EqualCS, const szSample[], CompareType:iSampleCompareType = CT_EqualCS, const szPublicFunction[], &pEmitSoundHandle = 0);
native unregister_emits_forward_light(pEmitSoundHandle);
native unregister_emits_forward(bool:bPost, const szClass[], CompareType:iClassCompareType = CT_EqualCS, const szSample[], CompareType:iSampleCompareType = CT_EqualCS, const szPublicFunction[]);
/* Natives for custom "EmitAmbientSound" forwards. */
native register_emitas_forward(bool:bPost, const szClass[], CompareType:iClassCompareType = CT_EqualCS, const szSample[], CompareType:iSampleCompareType = CT_EqualCS, const szPublicFunction[], &pEmitAmbientSoundHandle = 0);
native unregister_emitas_forward_light(pEmitAmbientSoundHandle);
native unregister_emitas_forward(bool:bPost, const szClass[], CompareType:iClassCompareType = CT_EqualCS, const szSample[], CompareType:iSampleCompareType = CT_EqualCS, const szPublicFunction[]);
/* Natives for custom "AddToFullPack" forwards. */
native register_atfp_forward(ATFPType:iHookType, const szClass[], CompareType:iCompareType = CT_EqualCS, const szPublicFunction[], &pAddToFullPackHandle = 0);
native unregister_atfp_forward_light(pAddToFullPackHandle);
native unregister_atfp_forward(ATFPType:iHookType, const szClass[], CompareType:iCompareType = CT_EqualCS, const szPublicFunction[]);

/* Include the stock functions. */
#include <VexdUM_stock>
