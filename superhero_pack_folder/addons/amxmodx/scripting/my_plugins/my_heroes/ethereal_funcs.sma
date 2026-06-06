#define AUX_STUFF_GIVE_WEAPONS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_FAKEMETA_UTIL
#define I_WANT_CUSTOM_WEAPONS
#include "../my_include/superheromod.inc"
#include "colt_inc/sh_ethereal.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero adriano etheral"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new g_Had_Ethereal, g_Ethereal_Clip[33], Float:g_Recoil[33][3]
new g_Event_Ethereal, g_SmokePuff_SprId, g_Beam_SprID
new g_Muzzleflash_Ent, g_Muzzleflash, g_Msg_WeaponList = -1

new weapon_secret_code = ETHEREAL_SECRET_CODE

new cached_ammo_id = -1,
	cached_max_bp_ammo = -1 ,
	cached_def_pos = -1 
	
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cached_ammo_id = wlt_get_def_ammo_id(CSW_ETHEREAL)

	cached_max_bp_ammo = wlt_get_def_bp_ammo(CSW_ETHEREAL)

	cached_def_pos = wlt_get_def_pos(CSW_ETHEREAL)

	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_forward(FM_UpdateClientData,"fw_UpdateClientData_Post", 1)	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	register_forward(FM_SetModel, "fw_SetModel")	
	register_forward(FM_CmdStart, "fw_CmdStart")
	
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_post", 1)
	register_forward(FM_CheckVisibility, "fw_CheckVisibility")
	
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], "fw_Weapon_WeaponIdle_Post", 1,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], "fw_Weapon_PrimaryAttack",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], "fw_Weapon_PrimaryAttack_Post", 1,true)	
	RegisterHam(Ham_Item_Deploy, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], "fw_Item_Deploy_Post", 1,true)
	RegisterHam(Ham_Item_AddToPlayer, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], "fw_Item_AddToPlayer_Post", 1,true)
	RegisterHam(Ham_Item_PostFrame, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], "fw_Item_PostFrame",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], "fw_Weapon_Reload",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], "fw_Weapon_Reload_Post", 1,true)	
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_World",_,true)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player",_,true)

	weapon_secret_code = allocate_weapon_secret_code()

	g_Msg_WeaponList = get_user_msgid("WeaponList")

	register_clcmd(ETHEREAL_HUD_SPRITES_NAME, "Hook_Weapon")
}

public plugin_natives(){
	
	

	register_native("ethereal_set_ethereal","_ethereal_set_ethereal");
	register_native("ethereal_unset_ethereal","_ethereal_unset_ethereal");
	
	
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, ETHEREAL_V_MODEL)
	engfunc(EngFunc_PrecacheModel, ETHEREAL_P_MODEL)
	engfunc(EngFunc_PrecacheModel, ETHEREAL_W_MODEL)
	
	new i
	for(i = 0; i < sizeof(Ethereal_Sounds); i++)
		engfunc(EngFunc_PrecacheSound, Ethereal_Sounds[i])
	for(i = 0; i < sizeof(Ethereal_Resources); i++)
	{
		if(i == 0) engfunc(EngFunc_PrecacheGeneric, Ethereal_Resources[i])
		else engfunc(EngFunc_PrecacheModel, Ethereal_Resources[i])
	}
	
	g_SmokePuff_SprId = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")
	g_Beam_SprID = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
	
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)
	
	// Muzzleflash
	g_Muzzleflash_Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	engfunc(EngFunc_PrecacheModel,MUZZLE_FLASH)
	engfunc(EngFunc_SetModel, g_Muzzleflash_Ent, MUZZLE_FLASH)
	set_pev(g_Muzzleflash_Ent, pev_scale, 0.2)
	
	set_pev(g_Muzzleflash_Ent, pev_rendermode, kRenderTransTexture)
	set_pev(g_Muzzleflash_Ent, pev_renderamt, 0.0)
}

public _ethereal_set_ethereal(iPlugins,iParams){
	new id=get_param(1);
	Get_Ethereal(id)
}
public _ethereal_unset_ethereal(iPlugins,iParams){
	new id=get_param(1);

	Remove_Ethereal(id)
}
public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal("events/m4a1.sc", name)) g_Event_Ethereal = get_orig_retval()		
}

public Hook_Weapon(id)
{
	engclient_cmd(id, ETHEREAL_HUD_SPRITES_NAME)
	return PLUGIN_HANDLED
}

public Get_Ethereal(id)
{
	Set_BitVar(g_Had_Ethereal, id)
	fm_give_item(id, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name])
	
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_ETHEREAL)
	if(pev_valid(Ent)) cs_set_weapon_ammo(Ent, ETHEREAL_CLIP)
	
	// Set BpAmmo
	cs_set_user_bpammo(id, CSW_ETHEREAL, ETHEREAL_RESERVE)
	// Update Ammo
	update_ammo(id, CSW_ETHEREAL, ETHEREAL_CLIP, ETHEREAL_RESERVE, cached_ammo_id)
	
}

public Remove_Ethereal(id)
{
	UnSet_BitVar(g_Had_Ethereal, id)
}

public Event_CurWeapon(id)
{
	if(!Get_BitVar(g_Had_Ethereal, id))	
		return

	static Float:Delay, Float:Delay2
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_ETHEREAL)
	ent_check(Ent,)
	
	Delay = get_pdata_float(Ent, m_flNextPrimaryAttack, XO_WEAPON) * ETHEREAL_SPEED
	Delay2 = get_pdata_float(Ent, m_flNextSecondaryAttack, XO_WEAPON) * ETHEREAL_SPEED
	
	if(Delay > 0.0)
	{
		set_pdata_float(Ent, m_flNextPrimaryAttack, Delay, XO_WEAPON)
		set_pdata_float(Ent, m_flNextSecondaryAttack, Delay2, XO_WEAPON)
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id)){
		return FMRES_IGNORED
	}

	if((get_user_weapon(id) != _:CSW_ETHEREAL)||!Get_BitVar(g_Had_Ethereal, id)){

		return FMRES_IGNORED

	}
	new pEntity = get_pdata_cbase(id, m_pActiveItem,OFFSET_LINUX_PLAYER)
	if(pev_valid(pEntity)==PDATA_SAFE){
		set_cd(cd_handle, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(get_user_weapon(invoker) != _:CSW_ETHEREAL || !Get_BitVar(g_Had_Ethereal, invoker))
		return FMRES_IGNORED
	if(eventid != g_Event_Ethereal)
		return FMRES_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
		
	native_playanim(invoker, E_ANIM_SHOOT1)
	
	emit_sound(invoker, CHAN_WEAPON, Ethereal_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	
	return FMRES_SUPERCEDE
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
	
	if(equal(model, ETHEREAL_OLDMODEL))
	{
		static weapon; weapon = fm_find_ent_by_owner(-1, weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name], entity)
		
		
		ent_check(weapon,FMRES_IGNORED)

		
		if(Get_BitVar(g_Had_Ethereal, iOwner))
		{
			Remove_Ethereal(iOwner)
			
			set_pev(weapon, pev_impulse, weapon_secret_code)
			engfunc(EngFunc_SetModel, entity, ETHEREAL_W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED;
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	
	if(!is_user_alive(id)){
		return FMRES_IGNORED
	}	
	if(!Get_BitVar(g_Had_Ethereal, id) || (get_user_weapon(id) != _:CSW_ETHEREAL)){
		return FMRES_IGNORED
	}
		
	new PressButton = get_uc(uc_handle, UC_Buttons)

	if((PressButton & IN_ATTACK2))
	{
		PressButton &= ~IN_ATTACK2
		set_uc(uc_handle, UC_Buttons, PressButton)
	}
	
	return FMRES_IGNORED
}


public fw_AddToFullPack_post(esState, iE, iEnt, iHost, iHostFlags, iPlayer, pSet)
{
	if(iEnt != g_Muzzleflash_Ent)
		return
		
	if(Get_BitVar(g_Muzzleflash, iHost))
	{
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

public fw_Weapon_PrimaryAttack(Ent)
{
	if(pev_valid(Ent)!=2){

		return HAM_IGNORED;
	}
	static id; id = get_pdata_cbase(Ent, m_pPlayer,XO_WEAPON)
	
	if (!is_user_alive(id)){
		return HAM_IGNORED
	}
	if(get_user_weapon(id) != _:CSW_ETHEREAL || !Get_BitVar(g_Had_Ethereal, id)){
		return HAM_IGNORED
	}
	
	entity_get_vector(id, EV_VEC_punchangle, g_Recoil[id])
	
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	if(pev_valid(Ent)!=2){

		return;
	}
	static id; id = get_pdata_cbase(Ent, m_pPlayer,XO_WEAPON)
	if (!is_user_alive(id)){
		return
	}

	if(Get_BitVar(g_Had_Ethereal, id))
	{

		static iClip;iClip = get_pdata_int(Ent, m_iClip, XO_WEAPON)
		if(iClip<=0){

			return
		}
		static Float:Push[3]
		entity_get_vector(id, EV_VEC_punchangle, Push)
		xs_vec_sub(Push, g_Recoil[id], Push)
		
		xs_vec_mul_scalar(Push, ETHEREAL_RECOIL, Push)
		xs_vec_add(Push, g_Recoil[id], Push)
		
		entity_set_vector(id, EV_VEC_punchangle,Push)
		
		Event_CurWeapon(id)
		Set_BitVar(g_Muzzleflash, id)
	}
}

public fw_Weapon_WeaponIdle_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return HAM_IGNORED	
	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)

	if (!is_user_alive(Id)){
		return HAM_IGNORED
	}
	if(get_pdata_cbase(Id, m_pActiveItem,OFFSET_LINUX_PLAYER) != Ent)
		return HAM_IGNORED	
	if(!Get_BitVar(g_Had_Ethereal, Id))
		return HAM_IGNORED	
		
	if(get_pdata_float(Ent, m_flTimeWeaponIdle, XO_WEAPON) <= 0.1) 
	{
		native_playanim(Id, E_ANIM_IDLE)
		
		set_pdata_float(Ent, m_flTimeWeaponIdle, 20.0, XO_WEAPON)
		set_pdata_string(Id, (m_szAnimExtention) * 4, ETHEREAL_PLAYER_ANIMEXT, -1 , XTRA_OFS_PLAYER* 4)
	}
	
	return HAM_IGNORED	
}

public fw_Item_Deploy_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)

	if (!is_user_alive(Id)){
		return
	}
	if(get_pdata_cbase(Id, m_pActiveItem,OFFSET_LINUX_PLAYER) != Ent){
		return
	}
	if(!Get_BitVar(g_Had_Ethereal, Id))
		return
	
	set_pev(Id, pev_viewmodel2, ETHEREAL_V_MODEL)
	set_pev(Id, pev_weaponmodel2, ETHEREAL_P_MODEL)
	
	native_playanim(Id, E_ANIM_DRAW)
}

public fw_Item_AddToPlayer_Post(Ent, id)
{
	ent_check(Ent,HAM_IGNORED)
	
	if(pev(Ent, pev_impulse) == weapon_secret_code)
	{
		Set_BitVar(g_Had_Ethereal, id)
		set_pev(Ent, pev_impulse, 0)
	
	}
	(Get_BitVar(g_Had_Ethereal, id)) ?
		
		(send_weapon_list_stock(id,
				ETHEREAL_HUD_SPRITES_NAME,
				cached_ammo_id,
				ETHEREAL_RESERVE,
				_:MY_SLOT_PRIMARY,
				cached_def_pos,
				CSW_ETHEREAL,
				0,
				MSG_ONE,
				g_Msg_WeaponList))
		
				:
		
		
		(send_weapon_list_stock(id,
				weapon_data_structs_array[CSW_ETHEREAL][wpn_struct_weapon_name],
				cached_ammo_id,
				cached_max_bp_ammo,
				_:MY_SLOT_PRIMARY,
				cached_def_pos,
				CSW_M4A1,
				0,
				MSG_ONE,
				g_Msg_WeaponList))


	return HAM_HANDLED	
}

public fw_Item_PostFrame(ent)
{
	if(pev_valid(ent)!=2){
		return HAM_IGNORED
	}
		
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Ethereal, id))
		return HAM_IGNORED	
	
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
	static bpammo; bpammo = cs_get_user_bpammo(id, CSW_ETHEREAL)
	
	static iClip; iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
	static fInReload; fInReload = get_pdata_int(ent, m_fInReload, XO_WEAPON)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(ETHEREAL_CLIP - iClip, bpammo)

		set_pdata_int(ent, m_iClip, iClip + temp1, XO_WEAPON)
		cs_set_user_bpammo(id, CSW_ETHEREAL, bpammo - temp1)		
		
		set_pdata_int(ent, m_fInReload, 0, XO_WEAPON)
		
		fInReload = 0
	}		
	
	return HAM_IGNORED
}

public fw_Weapon_Reload(ent)
{
	if(pev_valid(ent)!=2)
		return HAM_IGNORED
		
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Ethereal, id))
		return HAM_IGNORED	

	g_Ethereal_Clip[id] = -1
		
	static BPAmmo; BPAmmo = cs_get_user_bpammo(id, CSW_ETHEREAL)
	static iClip; iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
		
	if(BPAmmo <= 0)
		return HAM_SUPERCEDE
	if(iClip >= ETHEREAL_CLIP)
		return HAM_SUPERCEDE		
			
	g_Ethereal_Clip[id] = iClip	
	
	return HAM_IGNORED
}

public fw_Weapon_Reload_Post(ent)
{
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Ethereal, id))
		return HAM_IGNORED	
	

	if(g_Ethereal_Clip[id] == -1)
		return HAM_IGNORED

	
	set_pdata_int(ent, m_iClip, g_Ethereal_Clip[id], XO_WEAPON)
	set_pdata_int(ent, m_fInReload, 1, XO_WEAPON);

	native_playanim(id, E_ANIM_RELOAD)
	return HAM_IGNORED
}

public fw_TraceAttack_World(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != _:CSW_ETHEREAL || !Get_BitVar(g_Had_Ethereal, Attacker))
		return HAM_IGNORED
		
	static Float:flEnd[3], Float:vecPlane[3]
		
	get_tr2(Ptr, TR_vecEndPos, flEnd)
	get_tr2(Ptr, TR_vecPlaneNormal, vecPlane)		
			
	//Make_BulletHole(Attacker, flEnd, Damage)
	Make_LaserLine(Attacker, flEnd)
	Make_BulletSmoke(Attacker, Ptr)

	SetHamParamFloat(3, float(ETHEREAL_DAMAGE))
	
	return HAM_IGNORED
}

public fw_TraceAttack_Player(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{	
	if(Damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != _:CSW_ETHEREAL || !Get_BitVar(g_Had_Ethereal, Attacker))
		return HAM_IGNORED
		
	SetHamParamFloat(3, float(ETHEREAL_DAMAGE))
	
	return HAM_IGNORED
}

public Make_LaserLine(id, Float:Origin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte (TE_BEAMENTPOINT)
	write_short(id | 0x1000)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_Beam_SprID)
	write_byte(1)
	write_byte(5)
	write_byte(1)
	write_byte(2)
	write_byte(0)
	write_byte(0)
	write_byte(125)
	write_byte(255)
	write_byte(200)
	write_byte(200)
	message_end()
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