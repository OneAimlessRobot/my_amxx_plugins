#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <aliens_vs_predator>

//- Comment this line to disable damage support for csbots.
#define CSBOT_SUPPORT

#if defined CSBOT_SUPPORT
	#include <cs_ham_bots_api>
#endif

enum
{
	anim_idle,
	anim_reload,
	anim_draw,
	anim_shoot1,
	anim_shoot2,
	anim_shoot3
}

#define ENG_NULLENT		-1
#define EV_INT_WEAPONKEY	EV_INT_impulse
#define WEAPONKEY 500001
#define MAX_PLAYERS  			  32
#define IsValidUser(%1) (1 <= %1 <= g_MaxPlayers)

const USE_STOPPED = 0
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4

#define WEAP_LINUX_XTRA_OFF			4
#define m_fKnown				44
#define m_flNextPrimaryAttack 			46
#define m_flTimeWeaponIdle			48
#define m_iClip					51
#define m_fInReload				54
#define PLAYER_LINUX_XTRA_OFF			5
#define m_flNextAttack				83
#define RELOAD_TIME 0.5
#define wId CSW_AWP

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

new const Fire_snd[2][] =
{
	"avp_sounds/weapons/plasmacaster_fire.wav",
	"avp_sounds/weapons/plasmacaster_draw.wav"
}

new const went[] ={"weapon_awp"}

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new caster_V_MODEL[64] = "models/avp_models/v_plasmacaster.mdl"
/*new caster_P_MODEL[64] = ""
new caster_W_MODEL[64] = ""*/
new cvar_dmg_caster, cvar_clip_caster, cvar_caster_ammo
new g_has_caster[33]
new g_MaxPlayers, g_orig_event_caster, g_clip_ammo[33]
new Float:cl_pushangle[MAX_PLAYERS + 1][3], m_iBlood[2]
new g_plasma_caster[33]

public plugin_init()
{
	register_plugin("[AVP] Plasma Caster", "1.0", "yas17sin")
	
	avp_register_extra_item("Plasma Caster", 18, "func_prd_item_handler", AVP_TEAM_PREDATOR);
	
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	
	RegisterHam(Ham_Item_AddToPlayer, went, "fw_caster_AddToPlayer")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Item_Deploy, went, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, went, "fw_caster_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, went, "fw_caster_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Item_PostFrame, went, "caster__ItemPostFrame");
	RegisterHam(Ham_Weapon_Reload, went, "caster__Reload");
	RegisterHam(Ham_Weapon_Reload, went, "caster__Reload_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	
	#if defined CSBOT_SUPPORT
		RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage");
	#endif
	
	cvar_dmg_caster = register_cvar("Plasma_Caster_dmg", "90")
	cvar_clip_caster = register_cvar("Plasma_Caster_clip", "1")
	cvar_caster_ammo = register_cvar("Plasma_Caster_ammo", "30")
	
	g_MaxPlayers = get_maxplayers()
}
public plugin_precache()
{
	precache_model(caster_V_MODEL)
	/*precache_model(caster_P_MODEL)
	precache_model(caster_W_MODEL)*/
	
	for (new i = 0; i < sizeof Fire_snd; i++)
		engfunc(EngFunc_PrecacheSound, Fire_snd[i]);
	
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	
	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)
}
public fwPrecacheEvent_Post(type, const name[])
{
	if (equal("events/awp.sc", name))
	{
		g_orig_event_caster = get_orig_retval()
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public client_connect(id)
{
	g_has_caster[id] = false
}
public client_disconnect(id)
{
	g_has_caster[id] = false
}

public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED;
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED;
	static iOwner
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	if(equal(model, "models/w_awp.mdl"))
	{
		static iStoredSVDID
		iStoredSVDID = find_ent_by_owner(ENG_NULLENT, went, entity)
		if(!is_valid_ent(iStoredSVDID))
			return FMRES_IGNORED;
		if(g_has_caster[iOwner])
		{
			entity_set_int(iStoredSVDID, EV_INT_WEAPONKEY, WEAPONKEY)
			g_has_caster[iOwner] = false
			/*entity_set_model(entity, caster_W_MODEL)*/
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}
public give_caster(id)
{
	drop_weapons(id, 1);
	new iWep2 = give_item(id,went)
	if( iWep2 > 0 )
	{
		cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_caster))
		cs_set_user_bpammo (id, wId, get_pcvar_num(cvar_caster_ammo))
	}
	g_has_caster[id] = true;
	
	emit_sound(id, CHAN_WEAPON, Fire_snd[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}
public func_prd_item_handler(index)
{
	give_caster(index)
	
	client_print(index, print_chat, "[AvP] You now have the Plasma Caster!");
}
public fw_caster_AddToPlayer(caster, id)
{
	if(!is_valid_ent(caster) || !is_user_connected(id))
		return HAM_IGNORED;
	if(entity_get_int(caster, EV_INT_WEAPONKEY) == WEAPONKEY)
	{
		g_has_caster[id] = true
		entity_set_int(caster, EV_INT_WEAPONKEY, 0)
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}
public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	if (use_type == USE_STOPPED && is_user_connected(caller))
		replace_weapon_models(caller, get_user_weapon(caller))
}
public fw_Item_Deploy_Post(weapon_ent)
{
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	replace_weapon_models(owner, weaponid)
}
public CurrentWeapon(id)
{
	replace_weapon_models(id, read_data(2))
}
replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case wId:
		{

			if(g_has_caster[id])
			{
				set_pev(id, pev_viewmodel2, caster_V_MODEL)
				/*set_pev(id, pev_weaponmodel2, caster_P_MODEL)*/
			}
		}
	}
}
public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
  if(!is_user_alive(Player) || (get_user_weapon(Player) != wId) || !g_has_caster[Player])
  return FMRES_IGNORED
  set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)
  return FMRES_HANDLED
}
public fw_caster_PrimaryAttack(Weapon)
{
	new Player = get_pdata_cbase(Weapon, 41, 4)
	if (!g_has_caster[Player])
		return;
	pev(Player,pev_punchangle,cl_pushangle[Player])
	g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon)
}
public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_caster))
		return FMRES_IGNORED
	if (!(1 <= invoker <= g_MaxPlayers))
		return FMRES_IGNORED
	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}
public fw_caster_PrimaryAttack_Post(Weapon)
{	new Player = get_pdata_cbase(Weapon, 41, 4)
	new szClip, szAmmo
	get_user_weapon(Player, szClip, szAmmo)
	if(Player > 0 && Player < 33)
	{
		if(g_has_caster[Player])
		{
			if(szClip > 0)emit_sound(Player, CHAN_WEAPON, Fire_snd[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	
		if(g_has_caster[Player])
		{
			new Float:push[3]
			pev(Player,pev_punchangle,push)
			xs_vec_sub(push,cl_pushangle[Player],push)
			xs_vec_mul_scalar(push,0.6,push)
			xs_vec_add(push,cl_pushangle[Player],push)
			set_pev(Player,pev_punchangle,push)
			if (!g_clip_ammo[Player])
				return
				
			UTIL_PlayWeaponAnimation(Player, random_num(1,3))
			make_blood_and_bulletholes(Player)
		}
	}
}
public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == wId)
		{
			if(g_has_caster[attacker])
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_caster))
		}
	}
}
stock fm_cs_get_current_weapon_ent(id)
{
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}
stock fm_cs_get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}
stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}
stock make_blood_and_bulletholes(id)
{
	new aimOrigin[3], target, body
	get_user_origin(id, aimOrigin, 3)
	get_user_aiming(id, target, body)
	if(target > 0 && target <= g_MaxPlayers )
	{
		new Float:fStart[3], Float:fEnd[3], Float:fRes[3], Float:fVel[3]
		pev(id, pev_origin, fStart)
		velocity_by_aim(id, 64, fVel)
		fStart[0] = float(aimOrigin[0])
		fStart[1] = float(aimOrigin[1])
		fStart[2] = float(aimOrigin[2])
		fEnd[0] = fStart[0]+fVel[0]
		fEnd[1] = fStart[1]+fVel[1]
		fEnd[2] = fStart[2]+fVel[2]
		new res
		engfunc(EngFunc_TraceLine, fStart, fEnd, 0, target, res)
		get_tr2(res, TR_vecEndPos, fRes)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BLOODSPRITE)
		write_coord(floatround(fStart[0]))
		write_coord(floatround(fStart[1]))
		write_coord(floatround(fStart[2]))
		write_short( m_iBlood [ 1 ])
		write_short( m_iBlood [ 0 ] )
		write_byte(70)
		write_byte(random_num(1,2))
		message_end()
	}
	else if(!is_user_connected(target))
	{
		if(target)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DECAL)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
			write_short(target)
			message_end()
		}
		else
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_WORLDDECAL)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
			message_end()
		}
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		write_coord(aimOrigin[0])
		write_coord(aimOrigin[1])
		write_coord(aimOrigin[2])
		write_short(id)
		write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
		message_end()
	}
}
public caster__ItemPostFrame(weapon_entity) {
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED;
	if (!g_has_caster[id])
		return HAM_IGNORED;
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)
	new iBpAmmo = cs_get_user_bpammo(id, wId);
	new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)
	new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF)
	if( fInReload && flNextAttack <= 0.0 )
	{
		new j = min(get_pcvar_num(cvar_clip_caster) - iClip, iBpAmmo)
		set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
		cs_set_user_bpammo(id, wId, iBpAmmo-j);
		set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
		fInReload = 0
	}
	return HAM_IGNORED;
}
public caster__Reload(weapon_entity) {
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED;
	if (!g_has_caster[id])
		return HAM_IGNORED;
	g_plasma_caster[id] = -1;
	new iBpAmmo = cs_get_user_bpammo(id, wId);
	new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)
	if (iBpAmmo <= 0)
		return HAM_SUPERCEDE;
	if (iClip >= get_pcvar_num(cvar_clip_caster))
		return HAM_SUPERCEDE;
	g_plasma_caster[id] = iClip;
	return HAM_IGNORED;
}
public caster__Reload_Post(weapon_entity) {
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED;
	if (!g_has_caster[id])
		return HAM_IGNORED;
	if (g_plasma_caster[id] == -1)
		return HAM_IGNORED;
	set_pdata_int(weapon_entity, m_iClip, g_plasma_caster[id], WEAP_LINUX_XTRA_OFF)
	set_pdata_float(weapon_entity, m_flTimeWeaponIdle, RELOAD_TIME, WEAP_LINUX_XTRA_OFF)
	set_pdata_float(id, m_flNextAttack, RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)
	set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)
	UTIL_PlayWeaponAnimation(id, 3)
	return HAM_IGNORED;
}
stock drop_weapons(id, dropwhat)
{
     static weapons[32], num, i, weaponid
     num = 0
     get_user_weapons(id, weapons, num)
     for (i = 0; i < num; i++)
     {
          weaponid = weapons[i]
          if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
          {
               static wname[32]
               get_weaponname(weaponid, wname, sizeof wname - 1)
               engclient_cmd(id, "drop", wname)
          }
     }
}
stock set_player_light(id, const LightStyle[])
{
	message_begin( MSG_ONE, SVC_LIGHTSTYLE, .player = id)
	write_byte(0)
	write_string(LightStyle)
	message_end()
}

stock set_player_screenfade( pPlayer, sDuration = 0, sHoldTime = 0, sFlags = 0, r = 0, g = 0, b = 0, a = 0 )
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, pPlayer)
	write_short(sDuration)
	write_short(sHoldTime)
	write_short(sFlags)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(a)
	message_end()
}