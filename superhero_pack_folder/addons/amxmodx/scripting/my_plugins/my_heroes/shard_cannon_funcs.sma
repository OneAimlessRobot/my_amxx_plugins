#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_FAKEMETA_UTIL
#define I_WANT_CUSTOM_WEAPONS
#include "../my_include/superheromod.inc"
#include "colt_inc/sh_shard_cannon.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero adriano shard_cannon"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

// Main Vars
new g_Had_SHARD_CANNON, g_Old_Weapon[33], Float:g_ShootDelay[33], Float:g_Recoil[33]
new g_HamBot, g_Event_MS, g_SmokePuff_Id
new g_MsgCurWeapon

// Safety
new g_IsConnected, g_IsAlive, g_PlayerWeapon[33]

new weapon_secret_code = SHARD_CANNON_SECRETCODE

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	Register_SafetyFunc()
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	
	
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack",_,true)
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack",_,true)	
	
	RegisterHam(Ham_Item_Deploy, weapon_names_stock_arr[CSW_SHARD_CANNON], "fw_Item_Deploy_Post", 1,true)
	RegisterHam(Ham_Item_AddToPlayer,  weapon_names_stock_arr[CSW_SHARD_CANNON], "fw_Item_AddToPlayer_Post", 1,true)
	RegisterHam(Ham_Weapon_Reload,  weapon_names_stock_arr[CSW_SHARD_CANNON], "fw_Weapon_Reload",_,true)
	RegisterHam(Ham_Item_PostFrame,  weapon_names_stock_arr[CSW_SHARD_CANNON], "fw_Item_PostFrame",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack,  weapon_names_stock_arr[CSW_SHARD_CANNON], "fw_Weapon_PrimaryAttack",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack,  weapon_names_stock_arr[CSW_SHARD_CANNON], "fw_Weapon_PrimaryAttack_Post", 1,true)
	
	weapon_secret_code = allocate_weapon_secret_code()

	g_MsgCurWeapon = get_user_msgid("CurWeapon")
	
}


public plugin_natives(){
	
	

	register_native("shard_cannon_set_shard_cannon","_shard_cannon_set_shard_cannon",0);
	register_native("shard_cannon_unset_shard_cannon","_shard_cannon_unset_shard_cannon",0);
	
	
}
public plugin_precache()
{
	precache_model(SHARD_CANNON_MODEL_V)
	precache_model(SHARD_CANNON_MODEL_P)
	precache_model(SHARD_CANNON_MODEL_W)
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)	
	
	g_SmokePuff_Id = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")	
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal(OLD_EVENT, name))
		g_Event_MS = get_orig_retval()
}

public client_putinserver(id)
{
	Safety_Connected(id)
	
	if(!g_HamBot && is_user_bot(id))
	{
		g_HamBot = 1
		set_task(0.1, "Do_Register_HamBot", id)
	}
}

public Do_Register_HamBot(id) 
{
	Register_SafetyFuncBot(id)
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack")
}

public client_disconnected(id)
{
	Safety_Disconnected(id)
}

public _shard_cannon_set_shard_cannon(iPlugins,iParams){
	new id=get_param(1);
	Get_Shard_Cannon(id)
}
public _shard_cannon_unset_shard_cannon(iPlugins,iParams){
	new id=get_param(1);

	Remove_Shard_Cannon(id)
}

public Get_Shard_Cannon(id)
{
	Remove_Shard_Cannon(id)
	
	Set_BitVar(g_Had_SHARD_CANNON, id)
	
	give_item(id,  weapon_names_stock_arr[CSW_SHARD_CANNON])
	cs_set_user_bpammo(id, CSW_SHARD_CANNON, SHARD_CANNON_BPAMMO)
	
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_SHARD_CANNON)
	if(pev_valid(Ent)) cs_set_weapon_ammo(Ent, SHARD_CANNON_CLIP)
	
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, g_MsgCurWeapon, {0, 0, 0}, id)
	write_byte(1)
	write_byte(CSW_SHARD_CANNON)
	write_byte(SHARD_CANNON_CLIP)
	message_end()
}

public Remove_Shard_Cannon(id)
{
	UnSet_BitVar(g_Had_SHARD_CANNON, id)
}

public Event_CurWeapon(id)
{
	
	static CSWID; CSWID = read_data(2)
	
	if((CSWID == CSW_SHARD_CANNON && g_Old_Weapon[id] == CSW_SHARD_CANNON) && Get_BitVar(g_Had_SHARD_CANNON, id)) 
	{
		static Ent; Ent = fm_get_user_weapon_entity(id, CSW_SHARD_CANNON)
		if(!pev_valid(Ent))
		{
			g_Old_Weapon[id] = get_user_weapon(id)
			return
		}
		
		if(cs_get_user_zoom(id) == 1)
		{
			set_pev(id, pev_viewmodel2, SHARD_CANNON_MODEL_V)
		} else if(cs_get_user_zoom(id) == 2 || cs_get_user_zoom(id) == 3) {
			set_pev(id, pev_viewmodel2, "")
		}
		
		//static Float:TargetTime; TargetTime = get_pdata_float(Ent, 46, 4) * SPEED
		
		//set_pdata_float(Ent, 46, TargetTime, 4)
		//set_pdata_float(id, 83, TargetTime, 5)
	}
	
	g_Old_Weapon[id] = get_user_weapon(id)
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED
	
	static Classname[64]
	pev(entity, pev_classname, Classname, sizeof(Classname))
	
	if(!equal(Classname, "weaponbox"))
		return FMRES_IGNORED
	
	static id
	id = pev(entity, pev_owner)
	
	if(equal(model, OLD_W_MODEL))
	{
		static weapon
		weapon = fm_get_user_weapon_entity(entity, CSW_SHARD_CANNON)
		
		if(!pev_valid(weapon))
			return FMRES_IGNORED
		
		if(Get_BitVar(g_Had_SHARD_CANNON, id))
		{
			set_pev(weapon, pev_impulse, weapon_secret_code)
			engfunc(EngFunc_SetModel, entity, SHARD_CANNON_MODEL_W)
			
			Remove_Shard_Cannon(id)
			
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
	if(!is_alive(id)){
		return FMRES_IGNORED
	}
	if((get_player_weapon(id) != CSW_SHARD_CANNON) || !Get_BitVar(g_Had_SHARD_CANNON, id)){
		return FMRES_IGNORED
	}
	static iEnt; iEnt = fm_get_user_weapon_entity(id, get_user_weapon(id))
	static PressButton; PressButton = get_uc(uc_handle, UC_Buttons)
	
	if(PressButton & IN_ATTACK)
	{
		PressButton &= ~IN_ATTACK
		set_uc(uc_handle, UC_Buttons, PressButton)
		
		if(cs_get_weapon_ammo(iEnt) <= 0)
			return FMRES_IGNORED
		
		if(get_gametime() - SHARD_CANNON_SPEED > g_ShootDelay[id])
		{
			cs_set_weapon_ammo(iEnt, cs_get_weapon_ammo(iEnt) + 6)
			
			for(new i = 0; i < 7; i++)
				ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt)
				
			/*
			static Float:Push[3]
			Push[0] = random_float(-0.5, -2.0)
			set_pev(id, pev_punchangle, Push)*/
			
			g_ShootDelay[id] = get_gametime()
		}
	}
	
	if((PressButton & IN_RELOAD) && cs_get_weapon_ammo(iEnt) < SHARD_CANNON_CLIP && cs_get_user_bpammo(id, CSW_SHARD_CANNON) > 0 && !get_pdata_int(iEnt, m_fInSpecialReload, XO_WEAPON))
	{
		set_uc(uc_handle, UC_Buttons, PressButton & ~IN_RELOAD)
		
		cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
		
		set_pdata_int(iEnt, m_fInReload, 0, XO_WEAPON)
		set_pdata_int(iEnt, m_fInSpecialReload, 1, XO_WEAPON)
	}
	
	return FMRES_IGNORED
}
    
public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_alive(id)){
		return FMRES_IGNORED
	}	
	if(get_player_weapon(id) == CSW_SHARD_CANNON && Get_BitVar(g_Had_SHARD_CANNON, id)){
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 9999.0)
	}
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_connected(invoker))
		return FMRES_IGNORED		
	if(get_player_weapon(invoker) == CSW_SHARD_CANNON && Get_BitVar(g_Had_SHARD_CANNON, invoker) && eventid == g_Event_MS)
	{
		engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)	

		Set_WeaponAnim(invoker, ANIME_SHOOT)

		set_pdata_float(invoker, m_flEjectBrass, get_gametime() + 0.75, XTRA_OFS_PLAYER)
		
		static Ent; Ent = fm_get_user_weapon_entity(invoker, CSW_SHARD_CANNON)
		set_pdata_int(Ent, m_fInSpecialReload, 0, XO_WEAPON)
		
		return FMRES_SUPERCEDE
	}
	
	return FMRES_HANDLED
}

public fw_TraceAttack(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{	

	if(pev_valid(Ent) != 2){
		return HAM_IGNORED
	}

	if(Damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_connected(Attacker))
		return HAM_IGNORED	
	if(get_player_weapon(Attacker) != CSW_SHARD_CANNON || !Get_BitVar(g_Had_SHARD_CANNON, Attacker))
		return HAM_IGNORED
		
	static Float:flEnd[3], Float:vecPlane[3]
		
	get_tr2(ptr, TR_vecEndPos, flEnd)
	get_tr2(ptr, TR_vecPlaneNormal, vecPlane)		
			
	make_bullet(Attacker, flEnd)
	fake_smoke(Attacker, ptr)
		
	SetHamParamFloat(3, float(SHARD_CANNON_DAMAGE))
		
	return HAM_HANDLED	
}

public fw_Item_Deploy_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)
	if(get_pdata_cbase(Id, m_pActiveItem, XTRA_OFS_PLAYER) != Ent)
		return
	if(!Get_BitVar(g_Had_SHARD_CANNON, Id))
		return

	set_pev(Id, pev_viewmodel2, SHARD_CANNON_MODEL_V)
	set_pev(Id, pev_weaponmodel2, SHARD_CANNON_MODEL_P)
	
	Set_WeaponAnim(Id, ANIM_DRAW)
	set_pdata_int(Ent, m_fInSpecialReload, 0, XO_WEAPON)
}

public fw_Weapon_PrimaryAttack(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)
	if(get_pdata_cbase(Id,  m_pActiveItem, XTRA_OFS_PLAYER) != Ent)
		return
	if(!Get_BitVar(g_Had_SHARD_CANNON, Id))
		return
		
	pev(Id, pev_punchangle, g_Recoil[Id])
	
	set_pdata_int(Ent, 64, -1, 4)
	//set_pdata_float(Ent, 62, 0.0, 4)
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)
	if(get_pdata_cbase(Id, 373) != Ent)
		return
	if(!Get_BitVar(g_Had_SHARD_CANNON, Id))
		return
	

	static iClip;iClip = get_pdata_int(Ent, m_iClip, XO_WEAPON)
	if(iClip<=0){

		return
	}
	
	static Float:Push[3]
	
	pev(Id, pev_punchangle, Push)
	xs_vec_sub(Push, g_Recoil[Id], Push)
	
	Push[1] = random_float(-2.0, 2.0)
	
	xs_vec_mul_scalar(Push, 0.25, Push)
	xs_vec_add(Push, g_Recoil[Id], Push)
	
	set_pev(Id, pev_punchangle, Push)
}

public fw_Item_AddToPlayer_Post(ent, id)
{	
	if(pev_valid(ent) != 2){
		return
	}

	if(pev(ent, pev_impulse) == weapon_secret_code)
	{
		Set_BitVar(g_Had_SHARD_CANNON, id)
		set_pev(ent, pev_impulse, 0)
	}			
}

public fw_Weapon_Reload(iEnt)
{
	if(pev_valid(iEnt) != 2){
		return HAM_IGNORED
	}
	static id ; id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)
	if(!is_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_SHARD_CANNON, id))
		return HAM_IGNORED	
	if(get_pdata_int(iEnt, m_fInSpecialReload, XO_WEAPON))
		return HAM_SUPERCEDE
	
	set_pdata_int(iEnt, m_fInReload, 0, 4)
	set_pdata_int(iEnt, m_fInSpecialReload, 1, XO_WEAPON)
	
	return HAM_SUPERCEDE
}

public fw_Item_PostFrame( iEnt )
{
	if(pev_valid(iEnt) != 2){
		return 
	}
	static id; id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)	

	static iBpAmmo ; iBpAmmo = cs_get_user_bpammo(id,CSW_SHARD_CANNON)
	static iClip ; iClip = get_pdata_int(iEnt, m_iClip, XO_WEAPON)

	if(get_pdata_int(id, m_flNextAttack, XTRA_OFS_PLAYER) > 0.0)
		return

	switch(get_pdata_int(iEnt, m_fInSpecialReload, XO_WEAPON) )
	{
		case 1: // Check, Start
		{
			if(cs_get_weapon_ammo(iEnt) >= SHARD_CANNON_CLIP || cs_get_user_bpammo(id, CSW_SHARD_CANNON) <= 0)
			{
				set_pdata_int(iEnt, m_fInSpecialReload, 0, XO_WEAPON)
				return
			}
			
			Set_WeaponAnim(id, ANIM_START_RELOAD)
			
			set_pdata_float(id, m_flNextAttack, 0.75, XTRA_OFS_PLAYER)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.75, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.75, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.75, XO_WEAPON)
			
			set_pdata_int(iEnt, m_fInSpecialReload, 2, XO_WEAPON)
		}
		case 2: // Insert 
		{
			if(cs_get_weapon_ammo(iEnt) >= SHARD_CANNON_CLIP || cs_get_user_bpammo(id, CSW_SHARD_CANNON) <= 0)
			{
				set_pdata_int(iEnt, m_fInSpecialReload, 4, XO_WEAPON)
				return
			} else {
				set_pdata_int(iEnt, m_fInSpecialReload, 3, XO_WEAPON)
			}
			
			Set_WeaponAnim(id, ANIM_INSERT)

			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.25, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.25, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.25, XO_WEAPON)
			set_pdata_float(id, m_flNextAttack, 0.25, 5)
		}
		case 3: // Done Insert
		{
			set_pdata_int(iEnt, m_iClip, iClip + 1, XO_WEAPON)
			set_pdata_int(id, 381, iBpAmmo-1, XTRA_OFS_PLAYER)
			cs_set_user_bpammo(id, CSW_SHARD_CANNON, cs_get_user_bpammo(id, CSW_SHARD_CANNON) - 1)
			
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.1, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.1, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.1, XO_WEAPON)
			set_pdata_float(id, m_flNextAttack, 0.1, 5)
			
			set_pdata_int(iEnt, m_fInSpecialReload, 2, XO_WEAPON)
		}
		case 4: // Stop Reload
		{
			Set_WeaponAnim(id, ANIM_AFTER_RELOAD)

			set_pdata_int(iEnt, m_fInSpecialReload, 0, XO_WEAPON)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.5, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.5, XO_WEAPON)
			set_pdata_float(id, m_flNextAttack, 1.5, XTRA_OFS_PLAYER)
		}
	}
}

stock Set_WeaponAnim(id, anim)
{
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock Set_Weapon_Idle(id, WeaponId ,Float:TimeIdle)
{
	static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId)
	if(!pev_valid(entwpn)) 
		return
		
	set_pdata_float(entwpn, 46, TimeIdle, 4)
	set_pdata_float(entwpn, 47, TimeIdle, 4)
	set_pdata_float(entwpn, 48, TimeIdle + 0.5, 4)
}

stock Set_Player_NextAttack(id, Float:NextTime) set_pdata_float(id, 83, NextTime, 5)
stock make_bullet(id, Float:Origin[3])
{
	// Find target
	new decal = random_num(41, 45)
	const loop_time = 2
	
	static Body, Target
	get_user_aiming(id, Target, Body, 999999)
	
	if(is_user_connected(Target))
		return
	
	for(new i = 0; i < loop_time; i++)
	{
		// Put decal on "world" (a wall)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_byte(decal)
		message_end()
		
		// Show sparcles
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_short(id)
		write_byte(decal)
		message_end()
	}
}

stock fake_smoke(id, trace_result)
{
	static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG
	
	get_weapon_attachment(id, vecSrc)
	global_get(glb_v_forward, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)

	get_tr2(trace_result, TR_vecEndPos, vecSrc)
	get_tr2(trace_result, TR_vecPlaneNormal, vecEnd)
    
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
	write_short(g_SmokePuff_Id)
	write_byte(2)
	write_byte(50)
	write_byte(TE_FLAG)
	message_end()
}

stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	new Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	new Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	new Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	new Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}

stock get_position(ent, Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(ent, pev_origin, vOrigin)
	pev(ent, pev_view_ofs,vUp) //for player
	xs_vec_add(vOrigin,vUp,vOrigin)
	pev(ent, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD,vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT,vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP,vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock PlaySound(id, const sound[])
{
	if(equal(sound[strlen(sound)-4], ".mp3")) client_cmd(id, "mp3 play ^"sound/%s^"", sound)
	else client_cmd(id, "spk ^"%s^"", sound)
}

/* ===============================
------------- SAFETY -------------
=================================*/
public Register_SafetyFunc()
{
	register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")
	
	RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1, true)
	RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1, true)
}

public Register_SafetyFuncBot(id)
{
	RegisterHamFromEntity(Ham_Spawn, id, "fw_Safety_Spawn_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_Safety_Killed_Post", 1)
}

public Safety_Connected(id)
{
	Set_BitVar(g_IsConnected, id);
	UnSet_BitVar(g_IsAlive, id);
	
	g_PlayerWeapon[id] = 0
}

public Safety_Disconnected(id)
{
	UnSet_BitVar(g_IsConnected, id);
	UnSet_BitVar(g_IsAlive, id);
	
	g_PlayerWeapon[id] = 0
}

public Safety_CurWeapon(id)
{
	static CSW; CSW = read_data(2)
	if(g_PlayerWeapon[id] != CSW) g_PlayerWeapon[id] = CSW
}

public fw_Safety_Spawn_Post(id)
{
	if(!is_user_alive(id))
		return
		
	Set_BitVar(g_IsAlive, id)
}

public fw_Safety_Killed_Post(id)
{
	UnSet_BitVar(g_IsAlive, id)
}

public is_alive(id)
{
	if(!(1 <= id <= 32))
		return 0
	if(!Get_BitVar(g_IsConnected, id))
		return 0
	if(!Get_BitVar(g_IsAlive, id)) 
		return 0
		
	return 1
}

public is_connected(id)
{
	if(!(1 <= id <= 32))
		return 0
	if(!Get_BitVar(g_IsConnected, id))
		return 0
	
	return 1
}

public get_player_weapon(id)
{
	if(!is_alive(id))
		return 0
	
	return g_PlayerWeapon[id]
}

/* ===============================
--------- End of SAFETY ----------
=================================*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3076\\ f0\\ fs16 \n\\ par }
*/
