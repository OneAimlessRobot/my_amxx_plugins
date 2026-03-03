
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "colt_inc/sh_colt.inc"
#include <reapi>
#include "../my_include/weapons_const.inc"
#include "../my_include/weapons.inc"

#define PLUGIN "Superhero adriano colt funcs"
#define VERSION "1.0.0"
#define AUTHOR "ThrashBrat"
#define Struct				enum


new pPlayer, pEntity, HookChain:TakeDamage
new is_rehlds_avail
public plugin_precache()
{
	precache_sound(SHOOTSOUND);
	engfunc(EngFunc_PrecacheGeneric, "sound/weapons/406/coltm1911a1_clipin.wav")
	engfunc(EngFunc_PrecacheGeneric, "sound/weapons/406/coltm1911a1_clipout.wav")
	engfunc(EngFunc_PrecacheGeneric, "sound/weapons/406/coltm1911a1_slideback.wav")
	engfunc(EngFunc_PrecacheModel, VIEWMODEL)
	engfunc(EngFunc_PrecacheModel, WEAPONMODEL)
	engfunc(EngFunc_PrecacheModel, WORLDMODEL)
	engfunc(EngFunc_PrecacheGeneric, "sprites/406/640hud7.spr")
	engfunc(EngFunc_PrecacheGeneric, "sprites/406/640hud114.spr")
	engfunc(EngFunc_PrecacheGeneric, "sprites/weapon_m1911a1.txt")
	is_rehlds_avail=is_rehlds()
}
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_Item_Deploy, STRN_FIVESEVEN, "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, STRN_FIVESEVEN, "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_Reload, STRN_FIVESEVEN, "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Item_AddToPlayer, STRN_FIVESEVEN, "fw_ItemAddToPlayerPost", 1,true)
	RegisterHam(Ham_Weapon_WeaponIdle, STRN_FIVESEVEN, "fw_WeaponWeaponIdlePost", 1,true)
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHookChain(RG_CWeaponBox_SetModel, "rg_CWeaponBoxSetModelPre")
	TakeDamage = RegisterHookChain(RG_CBasePlayer_TakeDamage, "rg_CBasePlayerTakeDamagePre")
	DisableHookChain(TakeDamage)
	register_clcmd("give_m1911a1", "give_m1911a1")
	register_clcmd(STRN_M1911A1, "lastinv_m1911a1")
}
public plugin_natives(){


	register_native("colt_set_colt","_colt_set_colt",0);
	register_native("colt_unset_colt","_colt_unset_colt",0);
}
public _colt_set_colt(iPlugin,iParams){
	new id= get_param(1)
	give_m1911a1(id)
}
public _colt_unset_colt(iPlugin,iParams){
	
	new id= get_param(1)
	lastinv_m1911a1(id)
}


public give_m1911a1(player)
{
	if(!is_user_alive(player)) return
	
	lastinv_m1911a1(player)
	pEntity = rg_give_custom_item(player, STRN_FIVESEVEN, GT_REPLACE, ID_M1911A1)
	set_member(pEntity, m_Weapon_iClip, CLIP_M1911A1)
	rg_set_iteminfo(pEntity, ItemInfo_iMaxClip, CLIP_M1911A1)
	if(get_member(player, m_rgAmmo, AMMOID_FIVESEVEN) < MAXAMMO_M1911A1)
	set_member(player, m_rgAmmo, MAXAMMO_M1911A1, AMMOID_FIVESEVEN)
}

public rg_CWeaponBoxSetModelPre(entity, const szModelName[])
{
	pEntity = get_member(entity, m_WeaponBox_rgpPlayerItems, PISTOL_SLOT)
	if(is_valid_ent(pEntity) && get_entvar(pEntity, var_impulse) == ID_M1911A1)
	SetHookChainArg(2, ATYPE_STRING, WORLDMODEL)
}

public fw_WeaponWeaponIdlePost(entity)
{
	if(get_entvar(entity, var_impulse) != ID_M1911A1 || get_member(entity, m_Weapon_flTimeWeaponIdle) > 0.0) return
	set_entvar(get_member(entity, m_pPlayer), var_weaponanim, ANIM_IDLE_EMPTY)
	set_member(entity, m_Weapon_flTimeWeaponIdle, 99999.0)
}

public fw_ItemAddToPlayerPost(entity, player)
{
	new iCustom = get_entvar(entity, var_impulse)
	if(iCustom && (iCustom != ID_M1911A1)) return
	SendWeaponList(player, (iCustom != ID_M1911A1) ? STRN_FIVESEVEN : STRN_M1911A1, AMMOID_FIVESEVEN, MAXAMMO_FIVESEVEN, SLOT_SECONDARY, POSITION_FIVESEVEN, ID_FIVESEVEN)
}

public fw_ItemDeployPre(entity)
{
	pPlayer = get_member(entity, m_pPlayer)
	if(get_member(pPlayer, m_pLastItem) == entity)
	{
		set_entvar(pPlayer, var_viewmodel, VIEWMODEL)
		set_entvar(pPlayer, var_weaponmodel, WEAPONMODEL)
		return HAM_SUPERCEDE
	}
	if(get_entvar(entity, var_impulse) != ID_M1911A1) return HAM_IGNORED
	ExecuteHam(Ham_Item_Deploy, entity)
	set_entvar(pPlayer, var_viewmodel, VIEWMODEL)
	set_entvar(pPlayer, var_weaponmodel, WEAPONMODEL)
	SendWeaponAnim(pPlayer, get_member(entity, m_Weapon_iClip) ? ANIM_DRAW : ANIM_DRAW_EMPTY)
	set_member(pPlayer, m_flNextAttack, 0.9)
	set_member(entity, m_Weapon_flTimeWeaponIdle, 0.9)
	return HAM_SUPERCEDE
}

public fw_WeaponReloadPre(entity)
{
	if(get_entvar(entity, var_impulse) != ID_M1911A1) return HAM_IGNORED
	new iClip = get_member(entity, m_Weapon_iClip)
	pPlayer = get_member(entity, m_pPlayer)
	if(iClip >= CLIP_M1911A1 || !get_member(pPlayer, m_rgAmmo, AMMOID_FIVESEVEN)) return HAM_SUPERCEDE
	ExecuteHam(Ham_Weapon_Reload, entity)
	set_member(pPlayer, m_flNextAttack, 2.23)
	set_member(entity, m_Weapon_flTimeWeaponIdle, 2.23)
	set_entvar(pPlayer, var_weaponanim, iClip ? ANIM_RELOAD : ANIM_RELOAD_EMPTY)
	return HAM_SUPERCEDE
}

public fw_WeaponPrimaryAttackPre(entity)
{
	if(pev_valid(entity)!=2){

		return HAM_IGNORED;
	}
	if(get_entvar(entity, var_impulse) != ID_M1911A1) return HAM_IGNORED
	if(get_member(entity, m_Weapon_iShotsFired)) return HAM_SUPERCEDE
	static iClip, iTraceLine, iPlaybackEvent
	iClip = get_member(entity, m_Weapon_iClip)
	if(iClip)
	{
		iTraceLine = register_forward(FM_TraceLine, "fm_TraceLinePost", 1)
		iPlaybackEvent = register_forward(FM_PlaybackEvent, "fm_PlaybackEventPre")
		EnableHookChain(TakeDamage)
	}
	ExecuteHam(Ham_Weapon_PrimaryAttack, entity)
	if(!iClip) return HAM_SUPERCEDE
	unregister_forward(FM_TraceLine, iTraceLine, 1)
	unregister_forward(FM_PlaybackEvent, iPlaybackEvent)
	DisableHookChain(TakeDamage)
	
	set_member(entity, m_Weapon_flTimeWeaponIdle, 1.033)
	set_member(entity, m_Weapon_flNextSecondaryAttack, 99999.0)
	pPlayer = get_member(entity, m_pPlayer)
	if(is_rehlds_avail){
		rg_send_audio(pPlayer, SHOOTSOUND);
	}
	else{
		emit_sound(pPlayer, CHAN_WEAPON, SHOOTSOUND, 1.0, 0.0, 0, PITCH_NORM)
	}
	set_entvar(pPlayer, var_weaponanim, iClip == 1 ? ANIM_SHOOT_EMPTY : iClip & 1 ? ANIM_SHOOT1 : ANIM_SHOOT2)
	return HAM_SUPERCEDE
}

public fm_TraceLinePost(Float:vecStart[3], Float:vecEnd[3], noMonsters, pentToSkip, iTrace)
{
	if(noMonsters) return
	if(!GunshotDecalTrace(iTrace, true)) return
	get_tr2(iTrace, TR_vecEndPos, vecEnd)
	get_tr2(iTrace, TR_vecPlaneNormal, vecStart)
	CreateSmoke(SMOKE_WALLPUFF, vecEnd, vecStart, 0.5, Float:{40.0, 40.0, 40.0})
}

public fm_PlaybackEventPre() return FMRES_SUPERCEDE
public lastinv_m1911a1(player) engclient_cmd(player, STRN_FIVESEVEN)
public rg_CBasePlayerTakeDamagePre(victim, inflictor, attacker, Float:flDamage) SetHookChainArg(4, ATYPE_FLOAT, flDamage * 2.0)

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(!is_user_alive(player)) return
	pEntity = get_member(player, m_pActiveItem)
	if(is_valid_ent(pEntity) && get_entvar(pEntity, var_impulse) == ID_M1911A1)
	set_cd(cd, CD_flNextAttack, 99999.0)
}
