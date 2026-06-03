#define AUX_STUFF_GIVE_WEAPONS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include <reapi>

#include "sh_aux_stuff/sh_aux_inc.inc"
#include "colt_inc/sh_colt.inc"

#define PLUGIN "Superhero adriano colt funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new pPlayer, HookChain:TakeDamage, g_Msg_WeaponList = -1
new is_rehlds_avail
public plugin_precache()
{	


	engfunc(EngFunc_PrecacheSound,SHOOTSOUND);
	engfunc(EngFunc_PrecacheSound, "weapons/406/coltm1911a1_clipin.wav")
	engfunc(EngFunc_PrecacheSound, "weapons/406/coltm1911a1_clipout.wav")
	engfunc(EngFunc_PrecacheSound, "weapons/406/coltm1911a1_slideback.wav")
	engfunc(EngFunc_PrecacheModel, VIEWMODEL)
	engfunc(EngFunc_PrecacheModel, WEAPONMODEL)
	engfunc(EngFunc_PrecacheModel, WORLDMODEL)
	engfunc(EngFunc_PrecacheGeneric, "sprites/406/640hud7.spr")
	engfunc(EngFunc_PrecacheGeneric, "sprites/406/640hud114.spr")
	engfunc(EngFunc_PrecacheGeneric, "sprites/weapon_m1911a1.txt")


	is_rehlds_avail=is_rehlds()

}
new cached_ammo_id_colt = -1,
	cached_max_bp_ammo = -1 ,
	cached_def_pos = -1 
	
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cached_ammo_id_colt = wlt_get_def_ammo_id(CSW_FIVESEVEN)

	cached_max_bp_ammo = wlt_get_def_bp_ammo(CSW_FIVESEVEN)

	cached_def_pos = wlt_get_def_pos(CSW_FIVESEVEN)

	RegisterHam(Ham_Item_Deploy, weapon_data_strings_array[CSW_FIVESEVEN][wpn_struct_weapon_name], "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_strings_array[CSW_FIVESEVEN][wpn_struct_weapon_name], "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_data_strings_array[CSW_FIVESEVEN][wpn_struct_weapon_name], "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_data_strings_array[CSW_FIVESEVEN][wpn_struct_weapon_name], "fw_WeaponWeaponIdlePost", 1,true)
	RegisterHam(Ham_Item_AddToPlayer, weapon_data_strings_array[CSW_FIVESEVEN][wpn_struct_weapon_name], "fw_ItemAddToPlayerPost", 1,true)
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHookChain(RG_CWeaponBox_SetModel, "rg_CWeaponBoxSetModelPre")
	TakeDamage = RegisterHookChain(RG_CBasePlayer_TakeDamage, "rg_CBasePlayerTakeDamagePre")
	DisableHookChain(TakeDamage)
	register_clcmd("give_m1911a1", "give_m1911a1")
	register_clcmd(STRN_M1911A1, "lastinv_m1911a1")

	g_Msg_WeaponList = get_user_msgid("WeaponList")
}
public plugin_natives(){


	register_native("colt_set_colt","_colt_set_colt");
	register_native("colt_unset_colt","_colt_unset_colt");
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

	new pEntity=rg_give_custom_item(player,weapon_data_strings_array[CSW_FIVESEVEN][wpn_struct_weapon_name],GT_APPEND,ID_M1911A1)
	ent_check(pEntity,)
	
	set_member_s(pEntity, m_Weapon_iClip, CLIP_M1911A1)
	rg_set_iteminfo(pEntity, ItemInfo_iMaxClip, CLIP_M1911A1)
	if(get_member(player, m_rgAmmo, cached_ammo_id_colt) < MAXAMMO_M1911A1)
	set_member_s(player, m_rgAmmo, cached_max_bp_ammo, cached_ammo_id_colt)
}

public rg_CWeaponBoxSetModelPre(entity, const szModelName[])
{
	new pEntity = get_member(entity, m_WeaponBox_rgpPlayerItems, PISTOL_SLOT)
	if(is_valid_ent(pEntity) && get_entvar(pEntity, var_impulse) == ID_M1911A1)
	SetHookChainArg(2, ATYPE_STRING, WORLDMODEL)
}

public fw_WeaponWeaponIdlePost(entity)
{

	ent_check(entity,HAM_IGNORED)

	if(get_entvar(entity, var_impulse) != ID_M1911A1 || get_member(entity, m_Weapon_flTimeWeaponIdle) > 0.0) return HAM_IGNORED
	set_entvar(get_member(entity, m_pPlayer), var_weaponanim, ANIM_IDLE_EMPTY)
	set_member(entity, m_Weapon_flTimeWeaponIdle, 99999.0)

	return HAM_IGNORED
}	
/*

stock send_weapon_list_stock(player,
			const szName[],
			ammoid,
			maxammo,
			slot,
			position,
			id,
			flag = 0,
			destination= MSG_ONE,
			msgid=-1)
*/
public fw_ItemAddToPlayerPost(entity, id)
{
	
	ent_check(entity,HAM_IGNORED)

	new iCustom = get_entvar(entity, var_impulse)
	new is_custom= (iCustom == ID_M1911A1)
	
	
	
	is_custom?  (send_weapon_list_stock(id,
					STRN_M1911A1 ,
					cached_ammo_id_colt,
					cached_max_bp_ammo,
					_:MY_SLOT_SECONDARY,
					cached_def_pos,
					CSW_FIVESEVEN,
					0,
					MSG_ONE,
					g_Msg_WeaponList))
		
				:
		
		
		(send_weapon_list_stock(id,
				weapon_data_strings_array[CSW_FIVESEVEN][wpn_struct_weapon_name],
				cached_ammo_id_colt,
				cached_max_bp_ammo,
				_:MY_SLOT_SECONDARY,
				cached_def_pos,
				CSW_FIVESEVEN,
				0,
				MSG_ONE,
				g_Msg_WeaponList))


	return HAM_HANDLED
}

public fw_ItemDeployPre(entity)
{
	ent_check(entity,HAM_IGNORED)

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
	native_playanim(pPlayer, get_member(entity, m_Weapon_iClip) ? ANIM_DRAW : ANIM_DRAW_EMPTY)
	set_member(pPlayer, m_flNextAttack, 0.9)
	set_member(entity, m_Weapon_flTimeWeaponIdle, 0.9)
	return HAM_SUPERCEDE
}

public fw_WeaponReloadPre(entity)
{
	
	ent_check(entity,HAM_IGNORED)


	if(get_entvar(entity, var_impulse) != ID_M1911A1) return HAM_IGNORED
	new iClip = get_member(entity, m_Weapon_iClip)
	pPlayer = get_member(entity, m_pPlayer)
	
	if(iClip >= CLIP_M1911A1 || !get_member(pPlayer, m_rgAmmo,
				cached_ammo_id_colt)){

			return HAM_SUPERCEDE
	}
	
	ExecuteHam(Ham_Weapon_Reload, entity)
	set_member(pPlayer, m_flNextAttack, 2.23)
	set_member(entity, m_Weapon_flTimeWeaponIdle, 2.23)
	set_entvar(pPlayer, var_weaponanim, iClip ? ANIM_RELOAD : ANIM_RELOAD_EMPTY)
	return HAM_SUPERCEDE
}

public fw_WeaponPrimaryAttackPre(entity)
{
	ent_check(entity,HAM_IGNORED)

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


public fm_PlaybackEventPre(){
	
	return FMRES_SUPERCEDE
}

public lastinv_m1911a1(player){

	engclient_cmd(player, weapon_data_strings_array[CSW_FIVESEVEN][wpn_struct_weapon_name])

}

public rg_CBasePlayerTakeDamagePre(victim, inflictor, attacker, Float:flDamage){

	SetHookChainArg(4, ATYPE_FLOAT, flDamage * 2.0)

}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(!is_user_alive(player)) return FMRES_IGNORED
	
	new pEntity = get_member(player, m_pActiveItem)

	if(is_valid_ent(pEntity) && get_entvar(pEntity, var_impulse) == ID_M1911A1){
		set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
	}
	return FMRES_HANDLED
}
