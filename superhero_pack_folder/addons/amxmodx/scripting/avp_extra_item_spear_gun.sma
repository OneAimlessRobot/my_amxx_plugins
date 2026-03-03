/*================================================================================
 
			-----------------------------------
			-*- [AvP] Extra Item: Spear Gun -*-
			-----------------------------------

	Spear Gun
	Copyright (C) 2017 by Crazy

	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~

	This plugin add a new extra item in your aliens vs predator mod with
	the name of Spear Gun. This weapon is for Predators.

	~~~~~~~~~
	- Cvars -
	~~~~~~~~~

	* avp_spear_gun_damage <float number> - Damage multiplier.

	~~~~~~~~~~~~~~
	- Change Log -
	~~~~~~~~~~~~~~

	* v1.0: (May 2017)
		- First release;

	~~~~~~~~~~~
	- Credits -
	~~~~~~~~~~~

	* Crazy: I, for plugin code and Aliens vs Predator MOD.
	* Unknown author: spear gun models v_ /p_ /w_ .
	* sound-resource.com: shoot/draw weapon sounds.

================================================================================*/

#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <aliens_vs_predator>

new const PLUGIN_VERSION[] = "v1.0";

//- Configuration
#define SPEAR_COST 17
#define CSBOT_SUPPORT

#if defined CSBOT_SUPPORT
	#include <cs_ham_bots_api>
#endif

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

new const V_SPEAR_MDL[] = "models/avp_models/v_spear_gun.mdl";
new const P_SPEAR_MDL[] = "models/avp_models/p_spear_gun.mdl";
new const W_SPEAR_MDL[] = "models/avp_models/w_spear_gun.mdl";

new const SPEAR_SOUNDS[][] = { 
	"avp_sounds/weapons/spear_gun_shoot.wav",
	"avp_sounds/weapons/spear_gun_draw.wav"
}

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 };

new const weapon_spear_gun[] = "weapon_scout";
const CSW_SPEAR = CSW_SCOUT;

const SPEAR_GUN_KEY = 500451;

new g_has_speargun[33], g_speargun_clip[33], g_event_speargun, g_primary_attack, g_maxplayers, cvar_spear_gun_damage;

native give_item(const id, const item[])

public plugin_init()
{
	register_plugin("[AvP] Extra Item: Spear Gun", PLUGIN_VERSION, "Crazy");

	avp_register_extra_item("Spear Gun", SPEAR_COST, "spear_gun_handler", AVP_TEAM_PREDATOR);

	cvar_spear_gun_damage = register_cvar("avp_spear_gun_damage", "6.0");

	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_spear_gun, "fw_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_spear_gun, "fw_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Item_Deploy, weapon_spear_gun, "fw_Item_Deploy_Post", 1);
	RegisterHam(Ham_Item_AddToPlayer, weapon_spear_gun, "fw_Item_AddToPlayer_Post", 1);
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

	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_UpdateClientData, "fw_UpdateData_Post", 1);
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent");

	g_maxplayers = get_maxplayers()
}

public plugin_precache()
{
	precache_model(V_SPEAR_MDL);
	precache_model(P_SPEAR_MDL);
	precache_model(W_SPEAR_MDL);

	for (new i = 0; i < sizeof SPEAR_SOUNDS; i++)
		precache_sound(SPEAR_SOUNDS[i]);

	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1);
}

public client_putinserver(id)
{
	g_has_speargun[id] = false;
}

public client_disconnected(id)
{
	g_has_speargun[id] = false;
}

public avp_user_predatorized_post(id)
{
	g_has_speargun[id] = false;
}

public avp_user_marined_post(id)
{
	g_has_speargun[id] = false;
}

public avp_user_alienized_post(id)
{
	g_has_speargun[id] = false;
}

public spear_gun_handler(id)
{
	drop_primary_weapons(id);

	g_has_speargun[id] = true;

	give_item(id, weapon_spear_gun);
	cs_set_user_bpammo(id, CSW_SPEAR, 90);
}

public fw_SetModel(entity, const model[])
{
	if (!is_valid_ent(entity))
		return FMRES_IGNORED;

	if (!equal(model, "models/w_scout.mdl"))
		return FMRES_IGNORED;

	static classname[32];
	entity_get_string(entity, EV_SZ_classname, classname, charsmax(classname));

	if (!equal(classname, "weaponbox"))
		return FMRES_IGNORED;

	static owner, weapon;
	owner = entity_get_edict(entity, EV_ENT_owner);
	weapon = find_ent_by_owner(-1, weapon_spear_gun, entity);

	if (!g_has_speargun[owner] || !is_valid_ent(weapon))
		return FMRES_IGNORED;

	g_has_speargun[owner] = false;

	entity_set_int(weapon, EV_INT_impulse, SPEAR_GUN_KEY);
	entity_set_int(entity, EV_INT_impulse, SPEAR_GUN_KEY);
	entity_set_model(entity, W_SPEAR_MDL);

	return FMRES_SUPERCEDE;
}

public fw_UpdateData_Post(id, sendweapons, cd_handle)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED;

	if (get_user_weapon(id) != CSW_SPEAR)
		return FMRES_IGNORED;

	if (!g_has_speargun[id])
		return FMRES_IGNORED;

	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);

	return FMRES_IGNORED;
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if (!equal("events/scout.sc", name))
		return FMRES_IGNORED;

	g_event_speargun = get_orig_retval()

	return FMRES_HANDLED;
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_event_speargun) || !g_primary_attack)
		return FMRES_IGNORED;

	if (!(1 <= invoker <= g_maxplayers))
		return FMRES_IGNORED;

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);

	return FMRES_SUPERCEDE;
}

public fw_PrimaryAttack(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, 41, 4);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_speargun[id])
		return HAM_IGNORED;

	g_primary_attack = true;
	g_speargun_clip[id] = cs_get_weapon_ammo(entity);

	return HAM_IGNORED;
}

public fw_PrimaryAttack_Post(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, 41, 4);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_speargun[id])
		return HAM_IGNORED;

	if (!g_speargun_clip[id])
		return HAM_IGNORED;

	g_primary_attack = false;

	UTIL_PlayWeaponAnim(id, random_num(1, 2));

	emit_sound(id, CHAN_WEAPON, SPEAR_SOUNDS[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return HAM_IGNORED;
}

public fw_Item_Deploy_Post(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, 41, 4);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_speargun[id])
		return HAM_IGNORED;

	entity_set_string(id, EV_SZ_viewmodel, V_SPEAR_MDL);
	entity_set_string(id, EV_SZ_weaponmodel, P_SPEAR_MDL);

	emit_sound(id, CHAN_WEAPON, SPEAR_SOUNDS[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return HAM_IGNORED;
}

public fw_Item_AddToPlayer_Post(entity, id)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (entity_get_int(entity, EV_INT_impulse) != SPEAR_GUN_KEY)
		return HAM_IGNORED;

	g_has_speargun[id] = true;
	entity_set_int(entity, EV_INT_impulse, 0);

	return HAM_IGNORED;
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (get_user_weapon(attacker) != CSW_SPEAR)
		return HAM_IGNORED;

	if (!g_has_speargun[attacker])
		return HAM_IGNORED;

	SetHamParamFloat(4, damage * get_pcvar_float(cvar_spear_gun_damage));

	return HAM_IGNORED;
}

public fw_TraceAttack_Post(ent, attacker, Float:damage, Float:dir[3], ptr, dmg_bits)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (get_user_weapon(attacker) != CSW_SPEAR)
		return HAM_IGNORED;

	if (!g_has_speargun[attacker])
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

stock drop_primary_weapons(id)
{
	static weapons[32], num, i, weaponid;
	num = 0
	get_user_weapons(id, weapons, num)
	
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i];
		
		if ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)
		{
			static wname[32];
			get_weaponname(weaponid, wname, charsmax(wname));
			
			engclient_cmd(id, "drop", wname);
			cs_set_user_bpammo(id, weaponid, 0);
		}
	}
}

stock UTIL_PlayWeaponAnim(id, frame)
{
	entity_set_int(id, EV_INT_weaponanim, frame);

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = id)
	write_byte(frame)
	write_byte(entity_get_int(id, EV_INT_body))
	message_end()
}