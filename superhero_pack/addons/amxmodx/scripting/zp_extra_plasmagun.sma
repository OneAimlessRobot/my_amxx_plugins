/*================================================================================
 
			---------------------------
			[ZP] Extra Item: Plasma Gun
			---------------------------

		Plasma Gun
		Copyright (C) 2017 by Crazy

		-------------------
		-*- Description -*-
		-------------------

		This plugin add a new weapon into your zombie plague mod with
		the name of Plasma Gun. That weapon launch powerfull green lasers!
		When the bullet of this weapon hit any object, a nice effect appers!

		----------------
		-*- Commands -*-
		----------------

		* zp_give_plasma_gun <target> - Give the item to target.

		-------------
		-*- Cvars -*-
		-------------

		* zp_plasma_gun_ammo <number> - Ammo amout.
		* zp_plasma_gun_clip <number> - Clip amout. (Max: 100)
		* zp_plasma_gun_one_round <0/1> - Only one round.
		* zp_plasma_gun_damage <number> - Damage multiplier.
		* zp_plasma_gun_unlimited <0/1> - Unlimited ammunition.

		------------------
		-*- Change Log -*-
		------------------

		* v0.1: (Mar 2017)
			- First release;

		---------------
		-*- Credits -*-
		---------------

		* MeRcyLeZZ: for the nice zombie plague mod.
		* Crazy: created the extra item code.
		* deanamx: for the nice weapon model.
		* And all zombie-mod players that use this weapon.


=================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>
#include <cs_ham_bots_api>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

// Item Name
#define ITEM_NAME "Plasma Gun"

// Item Cost
#define ITEM_COST 70

/*================================================================================
 Customization ends here! Yes, that's it. Editing anything beyond
 here is not officially supported. Proceed at your own risk...
=================================================================================*/

new const PLUGIN_VERSION[] = "v0.1";

new const V_PLASMAGUN_MDL[64] = "models/zombie_plague/v_plasma_gun.mdl";
new const P_PLASMAGUN_MDL[64] = "models/zombie_plague/p_plasma_gun.mdl";
new const W_PLASMAGUN_MDL[64] = "models/zombie_plague/w_plasma_gun.mdl";

new const PLASMAGUN_SOUNDS[][] = { "weapons/plasmagun_aug-1.wav", "weapons/plasmagun_aug-2.wav", "weapons/plasmagun_clipin1.wav",  "weapons/plasmagun_clipin2.wav", "weapons/plasmagun_clipout.wav", "weapons/plasmagun_draw.wav", "weapons/plasmagun_exp.wav", "weapons/plasmagun_idle.wav" };

new g_has_plasmagun[33], g_plasmagun, g_msgWeaponList, g_plasmabomb, g_xenobeam, g_event_plasmagun, g_playername[33][32], g_maxplayers, g_primary_attack, g_plasmagun_reload_clip[33], cvar_plasmagun_clip, cvar_plasmagun_ammo, cvar_plasmagun_damage, cvar_plasmagun_oneround, cvar_plasgun_infinit;

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 };

const m_iClip = 51;
const m_flNextAttack = 83;
const m_fInReload = 54;

const OFFSET_WEAPON_OWNER = 41;
const OFFSET_LINUX_WEAPONS = 4;
const OFFSET_LINUX = 5;
const OFFSET_ACTIVE_ITEM = 373;

const PLASMAGUN_KEY = 054687;

const WEAPON_BITSUM = ((1<<CSW_SCOUT) | (1<<CSW_XM1014) | (1<<CSW_MAC10) | (1<<CSW_AUG) | (1<<CSW_UMP45) | (1<<CSW_SG550) | (1<<CSW_P90) | (1<<CSW_FAMAS) | (1<<CSW_AWP) | (1<<CSW_MP5NAVY) | (1<<CSW_M249) | (1<<CSW_M3) | (1<<CSW_M4A1) | (1<<CSW_TMP) | (1<<CSW_G3SG1) | (1<<CSW_SG552) | (1<<CSW_AK47) | (1<<CSW_GALIL));

enum
{
	idle = 0,
	reload,
	draw,
	shoot1,
	shoot2,
	shoot3
}

public plugin_init()
{
	/* Plugin register */
	register_plugin("[ZP] Extra Item: Plasma Gun", PLUGIN_VERSION, "Crazy");

	/* Item register */
	g_plasmagun = zp_register_extra_item(ITEM_NAME, ITEM_COST, ZP_TEAM_HUMAN);

	/* Events */
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");

	/* Messages */
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon");

	/* Admin command */
	register_concmd("zp_give_plasmagun", "cmd_give_plasmagun", 0);

	/* Forwards */
	register_forward(FM_UpdateClientData, "fw_UpdateData_Post", 1);
	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent");

	/* Ham Forwards */
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_aug", "fw_Item_Deploy_Post", 1);
	RegisterHam(Ham_Item_AddToPlayer, "weapon_aug", "fw_Item_AddToPlayer_Post", 1);
	RegisterHam(Ham_Item_PostFrame, "weapon_aug", "fw_Item_PostFrame");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Weapon_Reload, "weapon_aug", "fw_Reload");
	RegisterHam(Ham_Weapon_Reload, "weapon_aug", "fw_Reload_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage");

	/* Cvars */
	cvar_plasmagun_clip = register_cvar("zp_plasma_gun_clip", "30");
	cvar_plasmagun_ammo = register_cvar("zp_plasma_gun_ammo", "200");
	cvar_plasmagun_damage = register_cvar("zp_plasma_gun_damage", "2.5");
	cvar_plasmagun_oneround = register_cvar("zp_plasma_gun_one_round", "0");
	cvar_plasgun_infinit = register_cvar("zp_plasma_gun_unlimited", "0");

	/* Max Players */
	g_maxplayers = get_maxplayers()

	/* Message hook */
	g_msgWeaponList = get_user_msgid("WeaponList");
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, V_PLASMAGUN_MDL);
	engfunc(EngFunc_PrecacheModel, P_PLASMAGUN_MDL);
	engfunc(EngFunc_PrecacheModel, W_PLASMAGUN_MDL);

	engfunc(EngFunc_PrecacheGeneric, "sprites/weapon_plasmagun.txt");
	engfunc(EngFunc_PrecacheGeneric, "sprites/640hud3_plasma.spr");
	engfunc(EngFunc_PrecacheGeneric, "sprites/640hud91_plasma.spr");

	g_plasmabomb = engfunc(EngFunc_PrecacheModel, "sprites/plasmabomb.spr");
	g_xenobeam = engfunc(EngFunc_PrecacheModel, "sprites/xenobeam.spr");

	for (new i = 0; i < sizeof PLASMAGUN_SOUNDS; i++)
	engfunc(EngFunc_PrecacheSound, PLASMAGUN_SOUNDS[i]);

	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1);
	register_clcmd("weapon_plasmagun", "cmd_plasma_selected");
}

public zp_user_infected_post(id)
{
	g_has_plasmagun[id] = false;
}

public zp_user_humanized_post(id)
{
	g_has_plasmagun[id] = false;
}

public client_putinserver(id)
{
	g_has_plasmagun[id] = false;

	get_user_name(id, g_playername[id], charsmax(g_playername[]));
}

public event_round_start()
{
	for (new id = 0; id <= g_maxplayers; id++)
	{
		if (get_pcvar_num(cvar_plasmagun_oneround))
		g_has_plasmagun[id] = false;
	}
}

public cmd_give_plasmagun(id, level, cid)
{
	if ((get_user_flags(id) & level) != level)
		return PLUGIN_HANDLED;

	static arg[32], player;
	read_argv(1, arg, charsmax(arg));
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));
	
	if (!player)
		return PLUGIN_HANDLED;

	if (g_has_plasmagun[player])
	{
		client_print(id, print_chat, "[ZP] The %s already have the %s.", g_playername[player], ITEM_NAME);
		return PLUGIN_HANDLED;
	}

	give_plasmagun(player);
	
	client_print(player, print_chat, "[ZP] You won a %s from %s!", ITEM_NAME, g_playername[id]);

	return PLUGIN_HANDLED;
}

public cmd_plasma_selected(client)
{
	engclient_cmd(client, "weapon_aug");
	return PLUGIN_HANDLED;
}

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	if (!is_user_alive(msg_entity))
		return;

	if (!g_has_plasmagun[msg_entity])
		return;

	if (get_user_weapon(msg_entity) != CSW_AUG)
		return;

	if (get_msg_arg_int(1) != 1)
		return;

	if (get_pcvar_num(cvar_plasgun_infinit))
	{
		static ent;
		ent = fm_cs_get_current_weapon_ent(msg_entity);

		if (!pev_valid(ent))
			return;

		cs_set_weapon_ammo(ent, get_pcvar_num(cvar_plasmagun_clip));
		set_msg_arg_int(3, get_msg_argtype(3), get_pcvar_num(cvar_plasmagun_clip));
	}
}

public zp_extra_item_selected(id, itemid)
{
	if (itemid != g_plasmagun)
		return;

	if (g_has_plasmagun[id])
	{
		client_print(id, print_chat, "[ZP] You already have the %s.", ITEM_NAME);
		return;
	}

	give_plasmagun(id);

	client_print(id, print_chat, "[ZP] You bought the %s.", ITEM_NAME);
}

public fw_UpdateData_Post(id, sendweapons, cd_handle)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED;

	if (!g_has_plasmagun[id])
		return FMRES_IGNORED;

	if (get_user_weapon(id) != CSW_AUG)
		return FMRES_IGNORED;

	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);

	return FMRES_IGNORED;
}

public fw_SetModel(ent, const model[])
{
	if (!pev_valid(ent))
		return FMRES_IGNORED;

	if (!equal(model, "models/w_aug.mdl"))
		return HAM_IGNORED;

	static class_name[33];
	pev(ent, pev_classname, class_name, charsmax(class_name));

	if (!equal(class_name, "weaponbox"))
		return FMRES_IGNORED;

	static owner, weapon;
	owner = pev(ent, pev_owner);
	weapon = find_ent_by_owner(-1, "weapon_aug", ent);

	if (!g_has_plasmagun[owner] || !pev_valid(weapon))
		return FMRES_IGNORED;

	g_has_plasmagun[owner] = false;

	set_pev(weapon, pev_impulse, PLASMAGUN_KEY);

	engfunc(EngFunc_SetModel, ent, W_PLASMAGUN_MDL);

	return FMRES_SUPERCEDE;
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_event_plasmagun) || !g_primary_attack)
		return FMRES_IGNORED;

	if (!(1 <= invoker <= g_maxplayers))
		return FMRES_IGNORED;

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);

	return FMRES_SUPERCEDE;
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if (!equal("events/aug.sc", name))
		return HAM_IGNORED;

	g_event_plasmagun = get_orig_retval()

	return FMRES_HANDLED;
}

public fw_Item_Deploy_Post(ent)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_plasmagun[id])
		return HAM_IGNORED;

	set_pev(id, pev_viewmodel2, V_PLASMAGUN_MDL);
	set_pev(id, pev_weaponmodel2, P_PLASMAGUN_MDL);

	play_weapon_anim(id, draw);

	return HAM_IGNORED;
}

public fw_Item_AddToPlayer_Post(ent, id)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	if (!is_user_connected(id))
		return HAM_IGNORED;

	if (pev(ent, pev_impulse) == PLASMAGUN_KEY)
	{
		g_has_plasmagun[id] = true;
		set_pev(ent, pev_impulse, 0);
	}

	message_begin(MSG_ONE, g_msgWeaponList, _, id)
	write_string((g_has_plasmagun[id] ? "weapon_plasmagun" : "weapon_aug"))
	write_byte(4)
	write_byte(90)
	write_byte(-1)
	write_byte(-1)
	write_byte(0)
	write_byte(14)
	write_byte(CSW_AUG)
	write_byte(0)
	message_end()

	return HAM_IGNORED;
}

public fw_Item_PostFrame(ent)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_plasmagun[id])
		return HAM_IGNORED;

	static cvar_clip; cvar_clip = get_pcvar_num(cvar_plasmagun_clip);

	new clip = get_pdata_int(ent, m_iClip, OFFSET_LINUX_WEAPONS);
	new bpammo = cs_get_user_bpammo(id, CSW_AUG);

	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX);
	new fInReload = get_pdata_int(ent, m_fInReload, OFFSET_LINUX_WEAPONS);

	if (fInReload && flNextAttack <= 0.0)
	{
		new temp_clip = min(cvar_clip - clip, bpammo);

		set_pdata_int(ent, m_iClip, clip + temp_clip, OFFSET_LINUX_WEAPONS);

		cs_set_user_bpammo(id, CSW_AUG, bpammo-temp_clip);

		set_pdata_int(ent, m_fInReload, 0, OFFSET_LINUX_WEAPONS);

		fInReload = 0;
	}

	return HAM_IGNORED;
}

public fw_PrimaryAttack(ent)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_plasmagun[id])
		return HAM_IGNORED;

	if (!cs_get_weapon_ammo(ent))
		return HAM_IGNORED;

	g_primary_attack = true;

	return HAM_IGNORED;
}

public fw_PrimaryAttack_Post(ent)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_plasmagun[id])
		return HAM_IGNORED;

	if (!cs_get_weapon_ammo(ent))
		return HAM_IGNORED;

	g_primary_attack = false;

	play_weapon_anim(id, random_num(shoot1, shoot2));

	emit_sound(id, CHAN_WEAPON, PLASMAGUN_SOUNDS[random_num(0, 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	make_xenobeam(id);

	return HAM_IGNORED;
}

public fw_Reload(ent)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_plasmagun[id])
		return HAM_IGNORED;

	g_plasmagun_reload_clip[id] = -1;

	static cvar_clip; cvar_clip = get_pcvar_num(cvar_plasmagun_clip);

	new clip = get_pdata_int(ent, m_iClip, OFFSET_LINUX_WEAPONS);
	new bpammo = cs_get_user_bpammo(id, CSW_AUG);

	if (bpammo <= 0)
		return HAM_SUPERCEDE;

	if (clip >= cvar_clip)
		return HAM_SUPERCEDE;
	
	g_plasmagun_reload_clip[id] = clip;

	return HAM_IGNORED;
}

public fw_Reload_Post(ent)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_plasmagun[id])
		return HAM_IGNORED;

	if (g_plasmagun_reload_clip[id] == -1)
		return HAM_IGNORED;

	set_pdata_int(ent, m_iClip, g_plasmagun_reload_clip[id], OFFSET_LINUX_WEAPONS);
	set_pdata_int(ent, m_fInReload, 1, OFFSET_LINUX_WEAPONS);

	play_weapon_anim(id, reload);

	return HAM_IGNORED;
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, dmg_bits)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (!g_has_plasmagun[attacker])
		return HAM_IGNORED;

	if (get_user_weapon(attacker) != CSW_AUG)
		return HAM_IGNORED;

	SetHamParamFloat(OFFSET_LINUX_WEAPONS, damage * get_pcvar_float(cvar_plasmagun_damage));

	return HAM_IGNORED;
}

public fw_TraceAttack_Post(ent, attacker, Float:damage, Float:dir[3], ptr, dmg_bits)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (get_user_weapon(attacker) != CSW_AUG)
		return HAM_IGNORED;

	if (!g_has_plasmagun[attacker])
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
		write_byte(TE_SPRITE)
		engfunc(EngFunc_WriteCoord, end[0])
		engfunc(EngFunc_WriteCoord, end[1])
		engfunc(EngFunc_WriteCoord, end[2])
		write_short(g_plasmabomb)
		write_byte(10)
		write_byte(200)
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

give_plasmagun(id)
{
	drop_primary(id);

	g_has_plasmagun[id] = true;

	new weapon = fm_give_item(id, "weapon_aug");

	cs_set_weapon_ammo(weapon, get_pcvar_num(cvar_plasmagun_clip));
	cs_set_user_bpammo(id, CSW_AUG, get_pcvar_num(cvar_plasmagun_ammo));
}

play_weapon_anim(id, frame)
{
	set_pev(id, pev_weaponanim, frame);

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = id)
	write_byte(frame)
	write_byte(pev(id, pev_body))
	message_end()
}

drop_primary(id)
{
	static weapons[32], num;
	get_user_weapons(id, weapons, num);

	for (new i = 0; i < num; i++)
	{
		if (WEAPON_BITSUM & (1<<weapons[i]))
		{
			static wname[32];
			get_weaponname(weapons[i], wname, sizeof wname - 1);

			engclient_cmd(id, "drop", wname);
		}
	}
}

make_xenobeam(id)
{
	static originF[3];
	get_user_origin(id, originF, 3);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTPOINT)
	write_short(id | 0x1000)
	write_coord(originF[0])
	write_coord(originF[1])
	write_coord(originF[2])
	write_short(g_xenobeam)
	write_byte(0)
	write_byte(0)
	write_byte(1)
	write_byte(20)
	write_byte(0)
	write_byte(110)
	write_byte(251)
	write_byte(110)
	write_byte(200)
	write_byte(5)
	message_end()
}

stock fm_give_item(index, const item[])
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}

stock fm_cs_get_current_weapon_ent(id)
{
	if (pev_valid(id) != 2)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}