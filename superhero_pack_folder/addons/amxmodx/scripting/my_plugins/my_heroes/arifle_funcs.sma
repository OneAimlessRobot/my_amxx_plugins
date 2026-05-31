#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_FAKEMETA_UTIL
#define I_WANT_CUSTOM_WEAPONS
#include "../my_include/superheromod.inc"
#include "arifle_inc/sh_arifle.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero super noodle m60"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new const Arifle_Sound[] = "weapons/m60-1.wav"


new g_Had_Arifle, g_Arifle_Clip[33], Float:g_Recoil[33][3]
new g_Event_Arifle, g_SmokePuff_SprId
new g_Muzzleflash_Ent, g_Muzzleflash

new weapon_secret_code = ARIFLE_SECRET_CODE

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_forward(FM_UpdateClientData,"fw_UpdateClientData_Post", 1)
	register_forward(FM_SetModel, "fw_SetModel")	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_post", 1)
	register_forward(FM_CheckVisibility, "fw_CheckVisibility")
	
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_names_stock_arr[CSW_ARIFLE], "fw_Weapon_WeaponIdle_Post", 1,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_names_stock_arr[CSW_ARIFLE], "fw_Weapon_PrimaryAttack",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_names_stock_arr[CSW_ARIFLE], "fw_Weapon_PrimaryAttack_Post", 1,true)
	RegisterHam(Ham_Item_Deploy, weapon_names_stock_arr[CSW_ARIFLE], "fw_Item_Deploy_Post", 1, true)	
	RegisterHam(Ham_Item_AddToPlayer, weapon_names_stock_arr[CSW_ARIFLE], "fw_Item_AddToPlayer_Post", 1,true)
	RegisterHam(Ham_Item_PostFrame, weapon_names_stock_arr[CSW_ARIFLE], "fw_Item_PostFrame",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_names_stock_arr[CSW_ARIFLE], "fw_Weapon_Reload",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_names_stock_arr[CSW_ARIFLE], "fw_Weapon_Reload_Post", 1,true)	
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_World",_,true)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player",_,true)
	
	
	weapon_secret_code = allocate_weapon_secret_code()
}

public plugin_natives(){
	
	

	register_native("arifle_set_arifle","_arifle_set_arifle");
	register_native("arifle_unset_arifle","_arifle_unset_arifle");
	
	
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, ARIFLE_V_MODEL)
	engfunc(EngFunc_PrecacheModel, ARIFLE_P_MODEL)
	engfunc(EngFunc_PrecacheModel, ARIFLE_W_MODEL)
	

	engfunc(EngFunc_PrecacheSound, Arifle_Sound)
	
	g_SmokePuff_SprId = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")
	
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)
	
	// Muzzleflash
	g_Muzzleflash_Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	engfunc(EngFunc_PrecacheModel,MUZZLE_FLASH)
	engfunc(EngFunc_SetModel, g_Muzzleflash_Ent, MUZZLE_FLASH)
	set_pev(g_Muzzleflash_Ent, pev_scale, 0.2)
	
	set_pev(g_Muzzleflash_Ent, pev_rendermode, kRenderTransTexture)
	set_pev(g_Muzzleflash_Ent, pev_renderamt, 0.0)
}
public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal("events/m249.sc", name)) g_Event_Arifle = get_orig_retval()		
}


public _arifle_set_arifle(iPlugins,iParams){
	new id=get_param(1);
	Get_Arifle(id)
}
public _arifle_unset_arifle(iPlugins,iParams){
	new id=get_param(1);

	Remove_Arifle(id)
}


public Get_Arifle(id)
{
	Set_BitVar(g_Had_Arifle, id)
	fm_give_item(id, weapon_names_stock_arr[CSW_ARIFLE])
	
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_ARIFLE)
	if(pev_valid(Ent)) cs_set_weapon_ammo(Ent, A_RIFLE_CLIP)

	// Set BpAmmo
	cs_set_user_bpammo(id, CSW_ARIFLE, A_RIFLE_RESERVE)
	
	// Update Ammo
	update_ammo(id, CSW_ARIFLE, A_RIFLE_CLIP, A_RIFLE_RESERVE)

	
}

public Remove_Arifle(id)
{
	UnSet_BitVar(g_Had_Arifle, id)
}


public Event_CurWeapon(id)
{
	if(!Get_BitVar(g_Had_Arifle, id))	
		return

	static Float:Delay, Float:Delay2
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_ARIFLE)
	ent_check(Ent,)

	Delay = get_pdata_float(Ent, m_flNextPrimaryAttack, XO_WEAPON) * A_RIFLE_SPEED
	Delay2 = get_pdata_float(Ent, m_flNextSecondaryAttack, XO_WEAPON) * A_RIFLE_SPEED
	
	if(Delay > 0.0)
	{
		set_pdata_float(Ent, m_flNextPrimaryAttack, Delay, XO_WEAPON)
		set_pdata_float(Ent, m_flNextSecondaryAttack, Delay2, XO_WEAPON)
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return FMRES_IGNORED	
	if(get_user_weapon(id) == CSW_ARIFLE && Get_BitVar(g_Had_Arifle, id)){
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 9999.0)
	}
	
	return FMRES_HANDLED
}


public fw_SetModel(entity, model[])
{
	
	ent_check(entity,FMRES_IGNORED)

	static Classname[32]
	pev(entity, pev_classname, Classname, sizeof(Classname))
	
	if(!equal(Classname, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, ARIFLE_OLDMODEL))
	{
		static weapon; weapon = fm_find_ent_by_owner(-1, weapon_names_stock_arr[CSW_ARIFLE], entity)
		
		
		ent_check(weapon,FMRES_IGNORED)
		
		if(Get_BitVar(g_Had_Arifle, iOwner))
		{
			Remove_Arifle(iOwner)
			
			set_pev(weapon, pev_impulse, weapon_secret_code)
			engfunc(EngFunc_SetModel, entity,ARIFLE_W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED;
}


public fw_Weapon_PrimaryAttack(Ent)
{
	ent_check(Ent,HAM_IGNORED)

	static id; id = get_pdata_cbase(Ent,  m_pPlayer, XO_WEAPON)
	
	if(!is_user_alive(id)){
		
		return HAM_IGNORED
	}

	if(get_user_weapon(id) != CSW_ARIFLE || !Get_BitVar(g_Had_Arifle, id)){
		return HAM_IGNORED
	}
	
	entity_get_vector(id, EV_VEC_punchangle,  g_Recoil[id])
	
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	ent_check(Ent,)

	static id; id = get_pdata_cbase(Ent,  m_pPlayer, XO_WEAPON)
	
	if(!is_user_alive(id)){
		return
	}

	if(Get_BitVar(g_Had_Arifle, id))
	{

		static iClip;iClip = get_pdata_int(Ent, m_iClip, XO_WEAPON)
		if(iClip<=0){

			return
		}
		static Float:Push[3]
		entity_get_vector(id, EV_VEC_punchangle,  Push)
		xs_vec_sub(Push, g_Recoil[id], Push)
		
		xs_vec_mul_scalar(Push, A_RIFLE_RECOIL, Push)
		xs_vec_add(Push, g_Recoil[id], Push)
		set_pev(id, pev_punchangle, Push)
		
		Event_CurWeapon(id)
	}
}

public fw_Weapon_WeaponIdle_Post(Ent)
{
	ent_check(Ent,)


	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)

	if(!is_user_alive(Id)){
		return
	}
	if(get_pdata_cbase(Id, m_pActiveItem, XTRA_OFS_PLAYER) != Ent)
		return
	if(!Get_BitVar(g_Had_Arifle, Id))
		return

	if(get_pdata_float(Ent, m_flTimeWeaponIdle, XO_WEAPON) <= 0.1) 
	{
		native_playanim(Id, anim_idle)
		
		set_pdata_float(Ent, m_flTimeWeaponIdle, 20.0, XO_WEAPON)
		set_pdata_string(Id, (m_szAnimExtention) * 4, ARIFLE_PLAYER_ANIMEXT, -1 , XTRA_OFS_PLAYER * 4)
	}
}

public fw_Item_Deploy_Post(Ent)
{
	ent_check(Ent,)

	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)
	
	if(!is_user_alive(Id)){
		
		return
	}
	if(get_pdata_cbase(Id, m_pActiveItem, XTRA_OFS_PLAYER) != Ent)
		return
	

	if(!Get_BitVar(g_Had_Arifle, Id))
		return
	
	set_pev(Id, pev_viewmodel2, ARIFLE_V_MODEL)
	set_pev(Id, pev_weaponmodel2, ARIFLE_P_MODEL)
	
	native_playanim(Id, anim_draw)
}

public fw_AddToFullPack_post(esState, iE, iEnt, iHost, iHostFlags, iPlayer, pSet)
{
	if(iEnt != g_Muzzleflash_Ent)
		return
		
	if(Get_BitVar(g_Muzzleflash, iHost))
	{
		set_es(esState, ES_Frame, float(generate_int(0, 2)))
			
		set_es(esState, ES_RenderMode, kRenderTransAdd)
		set_es(esState, ES_RenderAmt, 255.0)
		
		UnSet_BitVar(g_Muzzleflash, iHost)
	}
		
	set_es(esState, ES_Skin, iHost)
	set_es(esState, ES_Body, 1)
	set_es(esState, ES_AimEnt, iHost)
	set_es(esState, ES_MoveType, MOVETYPE_FOLLOW)
}

public fw_CheckVisibility(iEntity, pSet)
{
	if (iEntity != g_Muzzleflash_Ent)
		return FMRES_IGNORED
	
	forward_return(FMV_CELL, 1)
	
	return FMRES_SUPERCEDE
}

public fw_Item_AddToPlayer_Post(Ent, id)
{
	ent_check(Ent,)
		
	if(pev(Ent, pev_impulse) == weapon_secret_code)
	{
		Set_BitVar(g_Had_Arifle, id)
		set_pev(Ent, pev_impulse, 0)
	}
}

public fw_Item_PostFrame(ent)
{
	ent_check(ent,HAM_IGNORED)

	static id ; id = get_pdata_cbase(ent, m_pPlayer, XO_WEAPON)
	
	if(!is_user_alive(id)){
		
		return HAM_IGNORED
	}
	if(!Get_BitVar(g_Had_Arifle, id))
		return HAM_IGNORED	
	

	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
	static bpammo; bpammo = cs_get_user_bpammo(id, CSW_ARIFLE)
	
	static iClip; iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
	static fInReload; fInReload = get_pdata_int(ent, m_fInReload, XO_WEAPON)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(A_RIFLE_CLIP - iClip, bpammo)

		set_pdata_int(ent, m_iClip, iClip + temp1, XO_WEAPON)
		cs_set_user_bpammo(id, CSW_ARIFLE, bpammo - temp1)		
		
		set_pdata_int(ent, m_fInReload, 0, XO_WEAPON)
		
		fInReload = 0
	}		
	
	return HAM_IGNORED
}

public fw_Weapon_Reload(ent)
{
	ent_check(ent,HAM_IGNORED)

	static id; id = get_pdata_cbase(ent,  m_pPlayer, XO_WEAPON)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Arifle, id))
		return HAM_IGNORED	

	g_Arifle_Clip[id] = -1
	
	
	static BPAmmo; BPAmmo = cs_get_user_bpammo(id, CSW_ARIFLE)
	static iClip; iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
		
	if(BPAmmo <= 0)
		return HAM_SUPERCEDE
	if(iClip >= A_RIFLE_CLIP)
		return HAM_SUPERCEDE		
			
	g_Arifle_Clip[id] = iClip	
	
	return HAM_HANDLED
}

public fw_Weapon_Reload_Post(ent)
{
	ent_check(ent,HAM_IGNORED)

	static id; id = get_pdata_cbase(ent,  m_pPlayer, XO_WEAPON)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Arifle, id))
		return HAM_IGNORED	
		
	if((get_pdata_int(ent, m_fInReload, XO_WEAPON) == 1))
	{ // Reload
		if(g_Arifle_Clip[id] == -1)
			return HAM_IGNORED
		
		set_pdata_int(ent, m_iClip, g_Arifle_Clip[id], XO_WEAPON)
		native_playanim(id, anim_reload)
	}
	
	return HAM_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(get_user_weapon(invoker) != CSW_ARIFLE || !Get_BitVar(g_Had_Arifle, invoker))
		return FMRES_IGNORED
	if(eventid != g_Event_Arifle)
		return FMRES_IGNORED
	
	native_playanim(invoker, anim_shoot1)
	
	emit_sound(invoker, CHAN_WEAPON, Arifle_Sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	
	return FMRES_SUPERCEDE
}
public fw_TraceAttack_World(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != CSW_ARIFLE || !Get_BitVar(g_Had_Arifle, Attacker))
		return HAM_IGNORED
		
	static Float:flEnd[3], Float:vecPlane[3]
		
	get_tr2(Ptr, TR_vecEndPos, flEnd)
	get_tr2(Ptr, TR_vecPlaneNormal, vecPlane)		
	
	Make_BulletHole(Attacker, flEnd, Damage)
	Make_BulletSmoke(Attacker, Ptr)

	SetHamParamFloat(3, float(A_RIFLE_DAMAGE))
	
	return HAM_IGNORED
}

public fw_TraceAttack_Player(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{	
	if(Damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != CSW_ARIFLE || !Get_BitVar(g_Had_Arifle, Attacker))
		return HAM_IGNORED
		
	SetHamParamFloat(3, float(A_RIFLE_DAMAGE))
	
	return HAM_IGNORED
}




stock Make_BulletHole(id, Float:Origin[3], Float:Damage)
{
	// Find target
	static Decal; Decal = generate_int(41, 45)
	static LoopTime; 
	
	if(Damage > 100.0) LoopTime = 2
	else LoopTime = 1
	
	for(new i = 0; i < LoopTime; i++)
	{
		// Put decal on "world" (a wall)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_byte(Decal)
		message_end()
		
		// Show sparcles
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_short(id)
		write_byte(Decal)
		message_end()
	}
}

stock Make_BulletSmoke(id, TrResult)
{
	static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG
	
	get_weapon_attachment(id, vecSrc)
	global_get(glb_v_forward, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)

	get_tr2(TrResult, TR_vecEndPos, vecSrc)
	get_tr2(TrResult, TR_vecPlaneNormal, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 2.5, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)
    
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vecEnd[0])
	engfunc(EngFunc_WriteCoord, vecEnd[1])
	engfunc(EngFunc_WriteCoord, vecEnd[2] - 10.0)
	write_short(g_SmokePuff_SprId)
	write_byte(2)
	write_byte(50)
	write_byte(TE_FLAG)
	message_end()
}

stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	static Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	static Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	static Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	static Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}
