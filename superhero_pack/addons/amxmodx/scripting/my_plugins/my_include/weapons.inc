#if defined _weapons_included
#endinput
#endif
#define _weapons_included

#define MSGID_WEAPONLIST 78

#define is_custom(%0,%1) (get_entvar(%0, var_impulse) == %1)
#define get_custom(%0) get_entvar(%0, var_impulse)
#define set_custom(%0,%1) set_entvar(%0, var_impulse, %1)

#define PlayEmptySoundPistol(%0) rh_emit_sound2(%0, 0, CHAN_WEAPON, "weapons/dryfire_pistol.wav", 0.8)
#define PlayEmptySoundRifle(%0) rh_emit_sound2(%0, 0, CHAN_WEAPON, "weapons/dryfire_rifle.wav", 0.8)

#define GUNSHOTDECALTRACE
#define CREATESMOKE
#define SENDWEAPONLIST
//#define MSGFUNCWEAPONLIST
#define SENDWEAPONANIM
//#define DEFAULTRELOADSHOTGUN
//#define DEFAULTWEAPONIDLESHOTGUN

#if defined CREATESMOKE
#define get_wind(%0) get_entvar(%0, var_iuser1)
#define set_wind(%0,%1) set_entvar(%0, var_iuser1, %1)

enum _:SMOKE_TYPE
{
	SMOKE_WALLPUFF,
	SMOKE_RIFLE,
	SMOKE_PISTOL
}

new g_Num[] = "1234"
new const g_SmokeType[SMOKE_TYPE][] = 
{
	"sprites/wall_puff1.spr",
	"sprites/rifle_smoke1.spr",
	"sprites/pistol_smoke1.spr"
}
#endif

#if defined GUNSHOTDECALTRACE
new Array:g_hDecals, g_FmDecalIndex
#endif

public plugin_precache()
{
	#if defined GUNSHOTDECALTRACE
	g_FmDecalIndex = register_forward(FM_DecalIndex, "fm_GunshotDecalIndexPost", 1)
	#endif
	#define plugin_precache() forward_precache()
	forward_precache()
}

public plugin_init()
{
	#if defined CREATESMOKE
	RegisterHam(Ham_Think, "env_sprite", "fw_CreateSmokeThinkPost", 1)
	#endif
	#if defined GUNSHOTDECALTRACE
	unregister_forward(FM_DecalIndex, g_FmDecalIndex, 1)
	#endif
	#define plugin_init() forward_init()
	forward_init()
}

#if defined GUNSHOTDECALTRACE
GunshotDecalTrace(iTrace, bool:bIsGunshot = false)
{
	static iMessage, iDecal, pHit, Float:vecEndPos[3]
	pHit = get_tr2(iTrace, TR_pHit); if(pHit < 0) pHit = 0
	if(pHit && !is_valid_ent(pHit) || (pev(pHit, pev_flags) & FL_KILLME)) return PLUGIN_CONTINUE
	if(!ExecuteHam(Ham_IsBSPModel, pHit)) return PLUGIN_CONTINUE
	
	iDecal = ExecuteHam(Ham_DamageDecal, pHit, 0)
	if(iDecal < 0 || iDecal >= ArraySize(g_hDecals)) return PLUGIN_CONTINUE
	
	iDecal = ArrayGetCell(g_hDecals, iDecal)
	get_tr2(iTrace, TR_flFraction, vecEndPos[0])
	if(iDecal < 0 || vecEndPos[0] >= 1.0) return PLUGIN_CONTINUE
	
	if(bIsGunshot) iMessage = TE_GUNSHOTDECAL
	else
	{
		iMessage = TE_DECAL
		if(pHit != 0)
		{
			if(iDecal > 255)
			{
				iMessage = TE_DECALHIGH
				iDecal -= 256
			}
		}
		else
		{
			iMessage = TE_WORLDDECAL
			if(iDecal > 255)
			{
				iMessage = TE_WORLDDECALHIGH
				iDecal -= 256
			}
		}
	}
	get_tr2(iTrace, TR_vecEndPos, vecEndPos)
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEndPos, 0)
	write_byte(iMessage)
	engfunc(EngFunc_WriteCoord, vecEndPos[0])
	engfunc(EngFunc_WriteCoord, vecEndPos[1])
	engfunc(EngFunc_WriteCoord, vecEndPos[2])
	if(bIsGunshot)
	{
		write_short(pHit)
		write_byte(iDecal)
	}
	else
	{
		write_byte(iDecal)
		if(pHit) write_short(pHit)
	}
	message_end()
	return PLUGIN_HANDLED
}

public fm_GunshotDecalIndexPost()
{
	if(!g_hDecals) g_hDecals = ArrayCreate(1, 1)
	ArrayPushCell(g_hDecals, get_orig_retval())
}
#endif

#if defined CREATESMOKE
CreateSmoke(type = SMOKE_WALLPUFF, Float:vecEndPos[3], Float:vecPlaneNormal[3], Float:scale = 0.5, Float:flColor[3], bool:wind = true, Float:framerate = 35.0)
{
	new entity = rg_create_entity("env_sprite")
	if(!is_valid_ent(entity)) return PLUGIN_CONTINUE
	switch(type)
	{
		case SMOKE_WALLPUFF: g_SmokeType[type][17] = g_Num[random_num(0, 3)]
		case SMOKE_RIFLE: g_SmokeType[type][19] = g_Num[random_num(0, 2)]
		case SMOKE_PISTOL: g_SmokeType[type][20] = g_Num[random_num(0, 1)]
	}
	vecEndPos[0] += vecPlaneNormal[0] * 3.0, vecEndPos[1] += vecPlaneNormal[1] * 3.0, vecEndPos[2] += vecPlaneNormal[2] * 3.0
	set_entvar(entity, var_origin, vecEndPos)
	engfunc(EngFunc_SetModel, entity, g_SmokeType[type])
	set_entvar(entity, var_framerate, framerate)
	set_entvar(entity, var_rendermode, kRenderTransAdd)
	set_entvar(entity, var_rendercolor, flColor)
	set_entvar(entity, var_renderamt, random_float(100.0, 180.0))
	set_entvar(entity, var_scale, scale)
	set_entvar(entity, var_spawnflags, SF_SPRITE_ONCE)
	dllfunc(DLLFunc_Spawn, entity)
	set_entvar(entity, var_movetype, MOVETYPE_NOCLIP)
	set_entvar(entity, var_classname, "create_smoke")
	vecPlaneNormal[0] *= random_float(25.0, 30.0), vecPlaneNormal[1] *= random_float(25.0, 30.0), vecPlaneNormal[2] *= random_float(25.0, 30.0)
	set_entvar(entity, var_velocity, vecPlaneNormal)
	set_wind(entity, wind)
	return PLUGIN_HANDLED
}

public fw_CreateSmokeThinkPost(entity)
{
	if(!FClassnameIs(entity, "create_smoke")) return
	static bool:bDirection[2], Float:flMagnitude[2], Float:vOrigin[3]
	
	set_entvar(entity, var_nextthink, get_gametime())
	get_entvar(entity, var_frame, vOrigin[0])
	if(vOrigin[0] > 7.0)
	{
		if(vOrigin[0] >= get_entvar(entity, var_framerate))
		{
			set_entvar(entity, var_flags, FL_KILLME)
			return
		}
		get_entvar(entity, var_velocity, vOrigin)
		vOrigin[0] *= 0.97, vOrigin[1] *= 0.97, vOrigin[2] = 0.97 * vOrigin[2] + 0.7
		if(vOrigin[2] > 70.0) vOrigin[2] = 70.0
		if(!get_wind(entity))
		{
			set_entvar(entity, var_velocity, vOrigin)
			return
		}
		for(new i; i < 2; i++)
		{
			flMagnitude[i] += 0.075
			if(flMagnitude[i] > 5.0) flMagnitude[i] = 5.0
			if(!bDirection[i]) vOrigin[i] += flMagnitude[i]
			else vOrigin[i] -= flMagnitude[i]
			if(!random(10) && flMagnitude[i] > 3.0)
			{
				flMagnitude[i] = 0.0
				bDirection[i] = !bDirection[i]
			}
		}
		set_entvar(entity, var_velocity, vOrigin)
	}
}
#endif

#if defined SENDWEAPONLIST
SendWeaponList(player, const szName[], ammoid, maxammo, slot, position, id, flag = FLAG_NONE)
{
	message_begin(MSG_ONE, MSGID_WEAPONLIST, _, player)
	write_string(szName)
	write_byte(ammoid)
	write_byte(maxammo)
	write_byte(-1)
	write_byte(-1)
	write_byte(slot)
	write_byte(position)
	write_byte(id)
	write_byte(flag)
	message_end()
}
#endif

#if defined SENDWEAPONANIM
SendWeaponAnim(player, weaponAnim)
{
	set_member(player, m_Activity, 0)
	set_entvar(player, var_weaponanim, weaponAnim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, _, player)
	write_byte(weaponAnim)
	write_byte(0)
	message_end()
}
#endif

#if defined MSGFUNCWEAPONLIST
MsgFunc_WeaponList(player, entity, szName[])
{
	message_begin(MSG_ONE, MSGID_WEAPONLIST, _, player)
	write_string(szName)
	write_byte(get_member(entity, m_Weapon_iPrimaryAmmoType))
	write_byte(rg_get_iteminfo(entity, ItemInfo_iMaxAmmo1))
	write_byte(-1)
	write_byte(-1)
	write_byte(rg_get_iteminfo(entity, ItemInfo_iSlot))
	write_byte(rg_get_iteminfo(entity, ItemInfo_iPosition))
	write_byte(get_member(entity, m_iId))
	write_byte(0)
	message_end()
}
#endif

#if defined DEFAULTRELOADSHOTGUN
DefaultReloadShotGun(entity, player, ammoid, iClip, iMaxClip, iStartAnim, iReloadAnim, Float:flStart = 0.55, Float:flReload = 0.3)
{
	new iBpammo = get_member(player, m_rgAmmo, ammoid)
	if(iBpammo <= 0 || iClip == iMaxClip || get_member(entity, m_Weapon_flNextPrimaryAttack) >= 0.0) return
	new m_fInSpecialReload = get_member(entity, m_Weapon_fInSpecialReload)
	if(m_fInSpecialReload == 0)
	{
		rg_set_animation(player, PLAYER_RELOAD)
		set_entvar(player, var_weaponanim, iStartAnim)
		set_member(player, m_flNextAttack, flStart)
		set_member(entity, m_Weapon_flTimeWeaponIdle, flStart)
		set_member(entity, m_Weapon_flNextPrimaryAttack, flStart)
		set_member(entity, m_Weapon_flNextSecondaryAttack, flStart)
		m_fInSpecialReload = 1
	}
	else if(m_fInSpecialReload == 1)
	{
		if(get_member(entity, m_Weapon_flTimeWeaponIdle) >= 0.0) return
		set_entvar(player, var_weaponanim, iReloadAnim)
		set_member(entity, m_Weapon_flTimeWeaponIdle, flReload)
		set_member(entity, m_Weapon_flNextReload, flReload)
		m_fInSpecialReload = 2
	}
	else
	{
		set_member(entity, m_Weapon_iClip, iClip + 1)
		set_member(player, m_rgAmmo, iBpammo - 1, ammoid)
		m_fInSpecialReload = 1
	}
	set_member(entity, m_Weapon_fInSpecialReload, m_fInSpecialReload)
}
#endif

#if defined DEFAULTWEAPONIDLESHOTGUN
DefaultWeaponIdleShotGun(entity, player, ammoid, iMaxClip, iEndAnim, iIdleAnim, Float:flEnd = 1.5, Float:flIdle = 99.0)
{
	set_member(entity, m_Weapon_iPlayEmptySound, 1)
	if(get_member(entity, m_Weapon_flTimeWeaponIdle) < 0.0)
	{
		new m_fInSpecialReload = get_member(entity, m_Weapon_fInSpecialReload)
		new iBpammo = get_member(player, m_rgAmmo, ammoid)
		new iClip = get_member(entity, m_Weapon_iClip)
		if(iClip == 0 && m_fInSpecialReload == 0 && iBpammo) ForwardReload(entity)
		else if(m_fInSpecialReload != 0)
		{
			if(iClip != iMaxClip && iBpammo) ForwardReload(entity)
			else
			{
				set_entvar(player, var_weaponanim, iEndAnim)
				set_member(entity, m_Weapon_fInSpecialReload, 0)
				set_member(entity, m_Weapon_flTimeWeaponIdle, flEnd)
			}
		}
		else
		{
			set_entvar(player, var_weaponanim, iIdleAnim)
			set_member(entity, m_Weapon_flTimeWeaponIdle, flIdle)
		}
	}
}
#endif
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
