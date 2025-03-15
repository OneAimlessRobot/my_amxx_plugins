/*================================================================================
 
			-----------------------------
			[ZP] Extra Item: Magnum Drill
			-----------------------------

		Magnum Drill
		Copyright (C) 2017 by Crazy

		-------------------
		-*- Description -*-
		-------------------

		This plugin add a new weapon into your zombie plague mod with
		the name of Magnum Drill. The bullet of that weapon explode when
		hit a zombie!

		----------------
		-*- Commands -*-
		----------------

		* zp_give_magnum_drill <target> - Give the item to target.

		-------------
		-*- Cvars -*-
		-------------

		* zp_magnum_drill_ammo <number> - Ammo amout.
		* zp_magnum_drill_clip <number> - Clip amout. (Max: 100)
		* zp_magnum_drill_one_round <0/1> - Only one round.
		* zp_magnum_drill_damage <number> - Damage multiplier.
		* zp_magnum_drill_unlimited <0/1> - Unlimited ammunition.

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
#define ITEM_NAME "Magnum Drill"

// Item Cost
#define ITEM_COST 100

/*================================================================================
 Customization ends here! Yes, that's it. Editing anything beyond
 here is not officially supported. Proceed at your own risk...
=================================================================================*/

new const PLUGIN_VERSION[] = "v0.1";

new const V_MAGNUM_MDL[64] = "models/zombie_plague/v_magnum_drill.mdl";

new const MAGNUM_SOUNDS[][] = { "weapons/sgdrill_1.wav", "weapons/sgdrill_2.wav", "weapons/sgdrill_clipin.wav", "weapons/sgdrill_clipout.wav", "weapons/sgdrill_draw.wav", "weapons/sgdrill_pslash.wav", "weapons/sgdrill_idle.wav", "weapons/sgdrill_slash.wav" };

new g_has_magnum[33], g_explosion, g_magnum, g_event_minigun, g_playername[33][32], g_maxplayers, g_primary_attack, g_magnum_clip[33], g_magnum_rldclip[33], cvar_magnum_clip, cvar_magnum_ammo, cvar_magnum_damage, cvar_magnum_oneround, cvar_magnum_infinit, cvar_magnum_shootspd;

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 };

const m_iClip = 51;
const m_flNextAttack = 83;
const m_fInReload = 54;
const m_flTimeWeaponIdle = 48;
const m_flNextPrimaryAttack = 46;
const m_flNextSecondaryAttack = 47;

const OFFSET_WEAPON_OWNER = 41;
const OFFSET_LINUX_WEAPONS = 4;
const OFFSET_LINUX = 5;
const OFFSET_ACTIVE_ITEM = 373;

const MAGNUM_KEY = 017857;

enum
{
	idle = 0,
	reload,
	draw,
	shoot1,
	shoot2,
	shoot3
}

native give_item(index, const item[]);

public plugin_init()
{
	/* Plugin register */
	register_plugin("[ZP] Extra Item: Magnum Drill", PLUGIN_VERSION, "Crazy");

	/* Item register */
	g_magnum = zp_register_extra_item(ITEM_NAME, ITEM_COST, ZP_TEAM_HUMAN);

	/* Events */
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");

	/* Messages */
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon");

	/* Admin command */
	register_concmd("zp_give_magnum_drill", "cmd_give_magnum_drill", 0);

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
	RegisterHam(Ham_Item_Deploy, "weapon_galil", "fw_Item_Deploy_Post", 1);
	RegisterHam(Ham_Item_AddToPlayer, "weapon_galil", "fw_Item_AddToPlayer_Post", 1);
	RegisterHam(Ham_Item_PostFrame, "weapon_galil", "fw_Item_PostFrame");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Weapon_Reload, "weapon_galil", "fw_Reload");
	RegisterHam(Ham_Weapon_Reload, "weapon_galil", "fw_Reload_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage");

	/* Cvars */
	cvar_magnum_clip = register_cvar("zp_magnum_drill_clip", "10");
	cvar_magnum_ammo = register_cvar("zp_magnum_drill_ammo", "100");
	cvar_magnum_damage = register_cvar("zp_magnum_drill_damage", "1000.0");
	cvar_magnum_oneround = register_cvar("zp_magnum_drill_one_round", "0");
	cvar_magnum_infinit = register_cvar("zp_magnum_drill_unlimited", "0");
	cvar_magnum_shootspd = register_cvar("zp_magnum_drill_shootspd", "1.0");

	/* Max Players */
	g_maxplayers = get_maxplayers()
}

public plugin_precache()
{
	precache_model(V_MAGNUM_MDL);

	g_explosion = precache_model("sprites/mgnum_explo.spr");

	for (new i = 0; i < sizeof MAGNUM_SOUNDS; i++)
	precache_sound(MAGNUM_SOUNDS[i]);

	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1);
}

public zp_user_infected_post(id)
{
	g_has_magnum[id] = false;
}

public zp_user_humanized_post(id)
{
	g_has_magnum[id] = false;
}

public client_putinserver(id)
{
	g_has_magnum[id] = false;

	get_user_name(id, g_playername[id], charsmax(g_playername[]));
}

public event_round_start()
{
	for (new id = 0; id <= g_maxplayers; id++)
	{
		if (get_pcvar_num(cvar_magnum_oneround))
		g_has_magnum[id] = false;
	}
}

public cmd_give_magnum_drill(id, level, cid)
{
	if ((get_user_flags(id) & level) != level)
		return PLUGIN_HANDLED;

	static arg[32], player;
	read_argv(1, arg, charsmax(arg));
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));
	
	if (!player)
		return PLUGIN_HANDLED;

	if (g_has_magnum[player])
	{
		client_print(id, print_chat, "[ZP] The %s already have the %s.", g_playername[player], ITEM_NAME);
		return PLUGIN_HANDLED;
	}

	give_magnum_drill(player);
	
	client_print(player, print_chat, "[ZP] You won a %s from %s!", ITEM_NAME, g_playername[id]);

	return PLUGIN_HANDLED;
}

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	if (!is_user_alive(msg_entity))
		return;

	if (!g_has_magnum[msg_entity])
		return;

	if (get_user_weapon(msg_entity) != CSW_GALIL)
		return;

	if (get_msg_arg_int(1) != 1)
		return;

	if (get_pcvar_num(cvar_magnum_infinit))
	{
		static ent;
		ent = fm_cs_get_current_weapon_ent(msg_entity);

		if (!is_valid_ent(ent))
			return;

		cs_set_weapon_ammo(ent, get_pcvar_num(cvar_magnum_clip));
		set_msg_arg_int(3, get_msg_argtype(3), get_pcvar_num(cvar_magnum_clip));
	}
}

public zp_extra_item_selected(id, itemid)
{
	if (itemid != g_magnum)
		return;

	if (g_has_magnum[id])
	{
		client_print(id, print_chat, "[ZP] You already have the %s.", ITEM_NAME);
		return;
	}

	give_magnum_drill(id);

	client_print(id, print_chat, "[ZP] You bought the %s.", ITEM_NAME);
}

public fw_UpdateData_Post(id, sendweapons, cd_handle)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED;

	if (!g_has_magnum[id])
		return FMRES_IGNORED;

	if (get_user_weapon(id) != CSW_GALIL)
		return FMRES_IGNORED;

	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);

	return FMRES_IGNORED;
}

public fw_SetModel(ent, const model[])
{
	if (!is_valid_ent(ent))
		return FMRES_IGNORED;

	if (!equal(model, "models/w_galil.mdl"))
		return HAM_IGNORED;

	static class_name[33];
	pev(ent, pev_classname, class_name, charsmax(class_name));

	if (!equal(class_name, "weaponbox"))
		return FMRES_IGNORED;

	static owner, weapon;
	owner = pev(ent, pev_owner);
	weapon = find_ent_by_owner(-1, "weapon_galil", ent);

	if (!g_has_magnum[owner] || !is_valid_ent(weapon))
		return FMRES_IGNORED;

	g_has_magnum[owner] = false;

	set_pev(weapon, pev_impulse, MAGNUM_KEY);

	engfunc(EngFunc_SetModel, ent, "models/w_galil.mdl");

	return FMRES_SUPERCEDE;
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_event_minigun) || !g_primary_attack)
		return FMRES_IGNORED;

	if (!(1 <= invoker <= g_maxplayers))
		return FMRES_IGNORED;

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);

	return FMRES_SUPERCEDE;
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if (!equal("events/galil.sc", name))
		return HAM_IGNORED;

	g_event_minigun = get_orig_retval()

	return FMRES_HANDLED;
}

public fw_Item_Deploy_Post(ent)
{
	if (!is_valid_ent(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_magnum[id])
		return HAM_IGNORED;

	set_pev(id, pev_viewmodel2, V_MAGNUM_MDL);

	play_weapon_anim(id, draw);

	return HAM_IGNORED;
}

public fw_Item_AddToPlayer_Post(ent, id)
{
	if (!is_valid_ent(ent))
		return HAM_IGNORED;

	if (!is_user_connected(id))
		return HAM_IGNORED;

	if (pev(ent, pev_impulse) == MAGNUM_KEY)
	{
		g_has_magnum[id] = true;
		set_pev(ent, pev_impulse, 0);
	}

	return HAM_IGNORED;
}

public fw_Item_PostFrame(ent)
{
	if (!is_valid_ent(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_magnum[id])
		return HAM_IGNORED;

	static cvar_clip; cvar_clip = get_pcvar_num(cvar_magnum_clip);

	new clip = get_pdata_int(ent, m_iClip, OFFSET_LINUX_WEAPONS);
	new bpammo = cs_get_user_bpammo(id, CSW_GALIL);

	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX);
	new fInReload = get_pdata_int(ent, m_fInReload, OFFSET_LINUX_WEAPONS);

	if (fInReload && flNextAttack <= 0.0)
	{
		new temp_clip = min(cvar_clip - clip, bpammo);

		set_pdata_int(ent, m_iClip, clip + temp_clip, OFFSET_LINUX_WEAPONS);

		cs_set_user_bpammo(id, CSW_GALIL, bpammo-temp_clip);

		set_pdata_int(ent, m_fInReload, 0, OFFSET_LINUX_WEAPONS);

		fInReload = 0;
	}

	return HAM_IGNORED;
}

public fw_PrimaryAttack(ent)
{
	if (!is_valid_ent(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_magnum[id])
		return HAM_IGNORED;

	g_primary_attack = true;
	g_magnum_clip[id] = cs_get_weapon_ammo(ent);

	return HAM_IGNORED;
}

public fw_PrimaryAttack_Post(ent)
{
	if (!is_valid_ent(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_magnum[id])
		return HAM_IGNORED;

	if (!g_magnum_clip[id])
		return HAM_IGNORED;

	g_primary_attack = false;

	play_weapon_anim(id, random_num(shoot1, shoot3));

	set_pdata_float(ent, m_flNextPrimaryAttack, get_pcvar_float(cvar_magnum_shootspd), OFFSET_LINUX_WEAPONS);
	set_pdata_float(ent, m_flNextSecondaryAttack, get_pcvar_float(cvar_magnum_shootspd), OFFSET_LINUX_WEAPONS);
	set_pdata_float(ent, m_flTimeWeaponIdle, get_pcvar_float(cvar_magnum_shootspd), OFFSET_LINUX_WEAPONS);

	emit_sound(id, CHAN_WEAPON, MAGNUM_SOUNDS[random_num(0, 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return HAM_HANDLED;
}

public fw_Reload(ent)
{
	if (!is_valid_ent(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_magnum[id])
		return HAM_IGNORED;

	g_magnum_rldclip[id] = -1;

	static cvar_clip; cvar_clip = get_pcvar_num(cvar_magnum_clip);

	new clip = get_pdata_int(ent, m_iClip, OFFSET_LINUX_WEAPONS);
	new bpammo = cs_get_user_bpammo(id, CSW_GALIL);

	if (bpammo <= 0)
		return HAM_SUPERCEDE;

	if (clip >= cvar_clip)
		return HAM_SUPERCEDE;
	
	g_magnum_rldclip[id] = clip;

	return HAM_IGNORED;
}

public fw_Reload_Post(ent)
{
	if (!is_valid_ent(ent))
		return HAM_IGNORED;

	new id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, OFFSET_LINUX_WEAPONS);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (!g_has_magnum[id])
		return HAM_IGNORED;

	if (g_magnum_rldclip[id] == -1)
		return HAM_IGNORED;

	set_pdata_int(ent, m_iClip, g_magnum_rldclip[id], OFFSET_LINUX_WEAPONS);
	set_pdata_int(ent, m_fInReload, 1, OFFSET_LINUX_WEAPONS);

	play_weapon_anim(id, reload);

	return HAM_IGNORED;
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, dmg_bits)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (!g_has_magnum[attacker])
		return HAM_IGNORED;

	if (get_user_weapon(attacker) != CSW_GALIL)
		return HAM_IGNORED;

	SetHamParamFloat(OFFSET_LINUX_WEAPONS, get_pcvar_float(cvar_magnum_damage));

	create_explosion(victim);

	return HAM_IGNORED;
}

public fw_TraceAttack_Post(ent, attacker, Float:damage, Float:dir[3], ptr, dmg_bits)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (get_user_weapon(attacker) != CSW_GALIL)
		return HAM_IGNORED;

	if (!g_has_magnum[attacker])
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

give_magnum_drill(id)
{
	g_has_magnum[id] = true;

	new weapon = give_item(id, "weapon_galil");

	cs_set_weapon_ammo(weapon, get_pcvar_num(cvar_magnum_clip));
	cs_set_user_bpammo(id, CSW_GALIL, get_pcvar_num(cvar_magnum_ammo));
}

play_weapon_anim(id, frame)
{
	set_pev(id, pev_weaponanim, frame);

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = id)
	write_byte(frame)
	write_byte(pev(id, pev_body))
	message_end()
}

create_explosion(id)
{
	static origin[3];
	get_user_origin(id, origin);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(g_explosion)
	write_byte(10)
	write_byte(20)
	write_byte(0)
	message_end()
}

stock fm_cs_get_current_weapon_ent(id)
{
	if (is_valid_ent(id) != 2)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}