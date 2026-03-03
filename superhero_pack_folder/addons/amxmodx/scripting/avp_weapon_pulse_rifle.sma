/*==========================================================================

		--------------------------------------
		-*- [AvP] Weapon: M4A1 Pulse Rifle -*-
		--------------------------------------

	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~

	This plugin add a weapon into weapons menu to AvP for marines only.
	This is the first external weapon that I've released to my mode :D.

	The view_model have little mistakes in shoot animation, then if you
	can, please fix it. Thanks!

	Now you're free to make your weapons, items and sub-plugins, and share
	with the counter-strike AvP gamers!

	Enjoy! :)

	~~~~~~~~~~~
	- Credits -
	~~~~~~~~~~~

	* jay-jay: he for the nice pulse rifle model.
	* Sound-Resource: he for the pulse rifle shoot sound.
	* Crazy (I): he for the plugin code.

============================================================================*/

//- Includes
#include <amxmodx>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <aliens_vs_predator>

//- Comment this line to disable damage support for csbots.
#define CSBOT_SUPPORT

#if defined CSBOT_SUPPORT
	#include <cs_ham_bots_api>
#endif

//- Models
new const V_PULSE_MDL[] = "models/avp_models/v_pulse_rifle.mdl";
new const P_PULSE_MDL[] = "models/avp_models/p_pulse_rifle.mdl";
new const W_PULSE_MDL[] = "models/avp_models/w_pulse_rifle.mdl";

//- Sounds
new const PULSE_SOUNDS[][] = {
	"avp_sounds/weapons/pulser_fire1.wav"
}

//- Gunshort Decals
new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 };

//- Pulse Rifle Key.

//- Note: To allow only marines pickup this weapon, you need set a impulse
//- on the world model of your weapon <= than 500000, else, only the predators
//- will be allowed to pickup this weapon. This is the system that I've created :D

const PULSE_KEY = 32120;

//- Constants
new g_has_pulse[33], cvar_pulser_damage, g_event_pulser, g_primary_attack, g_maxplayers;

//- Native give_item() - (from fun.inc)
native give_item(const id, const item[])

public plugin_init()
{
	//- Register plugin
	register_plugin("[AvP] Weapon: M4A1 Pulse Rifle", "v1.0", "Crazy");

	//- Register weapon
	avp_register_weapon("Pulse Rifle", "pulse_rifle_handler", AVP_PRIMARY_WEAPON);

	//- Cvars
	cvar_pulser_damage = register_cvar("avp_pulse_rifle_damage", "1.6");

	//- Forwards
	register_forward(FM_UpdateClientData, "fw_UpdateData_Post", 1);
	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent");

	//- HAM Forwards
	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "fw_Item_Deploy_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ak47", "fw_Item_AddToPlayer_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack_Post", 1);

	#if defined CSBOT_SUPPORT
		RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage");
	#endif

	// Max Players
	g_maxplayers = get_maxplayers()
}

public plugin_precache()
{
	precache_model(V_PULSE_MDL);
	precache_model(P_PULSE_MDL);
	precache_model(W_PULSE_MDL);

	for (new i = 0; i < sizeof PULSE_SOUNDS; i++)
		engfunc(EngFunc_PrecacheSound, PULSE_SOUNDS[i]);

	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1);
}

public client_putinserver(id)
	g_has_pulse[id] = false;

public avp_user_marinezed_pre(id)
	g_has_pulse[id] = false;

public avp_user_predatorized_post(id)
	g_has_pulse[id] = false;

public avp_user_alienized_post(id)
	g_has_pulse[id] = false;

public pulse_rifle_handler(id)
{
	g_has_pulse[id] = true;
	give_item(id, "weapon_ak47");
	cs_set_user_bpammo(id, CSW_AK47, 90);
}

public fw_UpdateData_Post(id, sendweapons, cd_handle)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED;

	if (!g_has_pulse[id])
		return FMRES_IGNORED;

	if (get_user_weapon(id) != CSW_AK47)
		return FMRES_IGNORED;

	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);

	return FMRES_IGNORED;
}

public fw_SetModel(entity, model[])
{
	if (!is_valid_ent(entity))
		return FMRES_IGNORED;

	if (!equal(model, "models/w_ak47.mdl"))
		return FMRES_IGNORED;

	new classname[32];
	entity_get_string(entity, EV_SZ_classname, classname, charsmax(classname));

	if (!equal(classname, "weaponbox"))
		return FMRES_IGNORED;

	static owner, weapon;
	owner = entity_get_edict(entity, EV_ENT_owner);
	weapon = find_ent_by_owner(-1, "weapon_ak47", entity);

	if (!g_has_pulse[owner] || !is_valid_ent(weapon))
		return FMRES_IGNORED;

	g_has_pulse[owner] = false;
	entity_set_int(weapon, EV_INT_impulse, PULSE_KEY);
	entity_set_model(entity, W_PULSE_MDL);

	return FMRES_SUPERCEDE;
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_event_pulser) || !g_primary_attack)
		return FMRES_IGNORED;

	if (!(1 <= invoker <= g_maxplayers))
		return FMRES_IGNORED;

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);

	return FMRES_SUPERCEDE;
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if (!equal("events/ak47.sc", name))
		return HAM_IGNORED;

	g_event_pulser = get_orig_retval()

	return FMRES_HANDLED;
}

public fw_Item_Deploy_Post(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, 41, 4);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_pulse[id])
		return HAM_IGNORED;

	entity_set_string(id, EV_SZ_viewmodel, V_PULSE_MDL);
	entity_set_string(id, EV_SZ_weaponmodel, P_PULSE_MDL);

	return HAM_IGNORED;
}

public fw_PrimaryAttack(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, 41, 4);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_pulse[id])
		return HAM_IGNORED;

	if (!cs_get_weapon_ammo(entity))
		return HAM_IGNORED;

	g_primary_attack = true;

	return HAM_IGNORED;
}

public fw_PrimaryAttack_Post(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, 41, 4);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_pulse[id])
		return HAM_IGNORED;

	if (!cs_get_weapon_ammo(entity))
		return HAM_IGNORED;

	g_primary_attack = false;
	set_weapon_frame(id, random_num(3, 5));
	emit_sound(id, CHAN_WEAPON, PULSE_SOUNDS[random_num(0, sizeof PULSE_SOUNDS - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return HAM_IGNORED;
}

public fw_Item_AddToPlayer_Post(entity, id)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (entity_get_int(entity, EV_INT_impulse) != PULSE_KEY)
		return HAM_IGNORED;

	g_has_pulse[id] = true;
	entity_set_int(entity, EV_INT_impulse, 0);

	return HAM_IGNORED;
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (get_user_weapon(attacker) != CSW_AK47)
		return HAM_IGNORED;

	SetHamParamFloat(4, damage * get_pcvar_float(cvar_pulser_damage));

	return HAM_IGNORED;
}

public fw_TraceAttack_Post(ent, attacker, Float:damage, Float:dir[3], ptr, dmg_bits)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (get_user_weapon(attacker) != CSW_AK47)
		return HAM_IGNORED;

	if (!g_has_pulse[attacker])
		return HAM_IGNORED;

	static Float:end[3];
	get_tr2(ptr, TR_vecEndPos, end);

	if(ent)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_DECAL)
		engfunc(EngFunc_WriteCoord, end[0])
		engfunc(EngFunc_WriteCoord, end[1])
		engfunc(EngFunc_WriteCoord, end[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		write_short(ent)
		message_end()
	}
	else
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, end[0])
		engfunc(EngFunc_WriteCoord, end[1])
		engfunc(EngFunc_WriteCoord, end[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		message_end()
	}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GUNSHOTDECAL)
	engfunc(EngFunc_WriteCoord, end[0])
	engfunc(EngFunc_WriteCoord, end[1])
	engfunc(EngFunc_WriteCoord, end[2])
	write_short(attacker)
	write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
	message_end()

	return HAM_IGNORED;
}

set_weapon_frame(id, frame)
{
	entity_set_int(id, EV_INT_weaponanim, frame);

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = id)
	write_byte(frame)
	write_byte(entity_get_int(id, EV_INT_body))
	message_end()
}