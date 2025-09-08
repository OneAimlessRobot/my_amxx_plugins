
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "d_barrel_inc/sh_d_barrel.inc"


#define PLUGIN "Superhero Snoodle d_barrel funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new const WeaponModel[3][] =
{
	"models/shmod/supernoodle/dbarrel/v_dbarrel.mdl", // V
	"models/shmod/supernoodle/dbarrel/p_dbarrel.mdl", // P
	"models/shmod/supernoodle/dbarrel/w_dbarrel.mdl" // W
}

new const WeaponSounds[6][] = 
{
	"weapons/dbarrel1.wav",
	"weapons/dbarrel_draw.wav",
	"weapons/dbarrel_foley1.wav",
	"weapons/dbarrel_foley2.wav",
	"weapons/dbarrel_foley3.wav",
	"weapons/dbarrel_foley4.wav"
}

enum
{
	GATLING_ANIM_IDLE = 0,
	GATLING_ANIM_SHOOT1,
	GATLING_ANIM_SHOOT2,
	GATLING_ANIM_RELOAD1,
	GATLING_ANIM_RELOAD2,
	GATLING_ANIM_RELOAD3,
	GATLING_ANIM_DRAW
}

const PDATA_SAFE = 2
const OFFSET_LINUX_WEAPONS = 4
const OFFSET_LINUX_PLAYER = 5
const OFFSET_WEAPONOWNER = 41
const m_iClip = 51
const m_fInReload = 54
const m_flNextAttack = 83
const m_szAnimExtention = 492

new g_Volcano, g_OldWeapon[33]
new g_Had_Volcano, Float:g_punchangles[33][3], g_gatling_event, g_smokepuff_id, m_iBlood[2], g_ham_bot

// Safety
new g_IsConnected, g_IsAlive, g_PlayerWeapon[33]



public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	
	// Safety
	Register_SafetyFunc()
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_World",_,true)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack",_,true)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Post", 1,true)
	
	RegisterHam(Ham_Item_Deploy, weapon_gatling, "fw_Item_Deploy_Post", 1,true)
	RegisterHam(Ham_Weapon_Reload, weapon_gatling, "fw_Weapon_Reload_Post", 1,true)
	RegisterHam(Ham_Item_PostFrame, weapon_gatling, "fw_Item_PostFrame",_,true)
	RegisterHam(Ham_Item_AddToPlayer, weapon_gatling, "fw_Item_AddToPlayer_Post", 1,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_gatling, "fw_Weapon_PrimaryAttack",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_gatling, "fw_Weapon_PrimaryAttack_Post", 1,true)
	
	register_clcmd("weapon_gatling", "hook_weapon")
}
public plugin_natives(){
	
	

	register_native("d_barrel_set_d_barrel","_d_barrel_set_d_barrel",0);
	register_native("d_barrel_unset_d_barrel","_d_barrel_unset_d_barrel",0);
	
	
}
public _d_barrel_set_d_barrel(iPlugins,iParams){
	new id=get_param(1);
	get_gatling(id)
}
public _d_barrel_unset_d_barrel(iPlugins,iParams){
	new id=get_param(1);

	remove_gatling(id)
}
public plugin_precache()
{
	new i
	
	for(i = 0; i < sizeof(WeaponModel); i++)
		engfunc(EngFunc_PrecacheModel, WeaponModel[i])
	for(i = 0; i < sizeof(WeaponSounds); i++)
		engfunc(EngFunc_PrecacheSound, WeaponSounds[i])
	/*
	for(new i = 0; i < sizeof(WeaponResource); i++)
	{
		if(i == 0) engfunc(EngFunc_PrecacheGeneric, WeaponResource[i])
		else engfunc(EngFunc_PrecacheModel, WeaponResource[i])
	}*/
	
	g_smokepuff_id = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")
	m_iBlood[0] = engfunc(EngFunc_PrecacheModel, "sprites/blood.spr")
	m_iBlood[1] = engfunc(EngFunc_PrecacheModel, "sprites/bloodspray.spr")		
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)	
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal(old_event, name))
		g_gatling_event = get_orig_retval()
}

public client_putinserver(id)
{
	Safety_Connected(id)
	if(is_user_bot(id) && !g_ham_bot)
	{
		g_ham_bot = 1
		set_task(0.1, "Do_Register_Ham", id)
	}
}

public client_disconnected(id)
{
	Safety_Disconnected(id)
}

public Do_Register_Ham(id)
{
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack")	
	Register_SafetyFuncBot(id)
}

public Mileage_WeaponGet(id, ItemID)
{
	if(ItemID == g_Volcano) get_gatling(id)
}

public Mileage_WeaponRefillAmmo(id, ItemID)
{
	if(ItemID == g_Volcano) 
	{
		cs_set_user_bpammo(id, CSW_GATLING, D_BARREL_DEFAULT_BPAMMO)
	}
}

public Mileage_WeaponRemove(id, ItemID)
{
	if(ItemID == g_Volcano) remove_gatling(id)
}

public get_gatling(id)
{
	Set_BitVar(g_Had_Volcano, id)
	fm_give_item(id, weapon_gatling)
	
	// Set Clip
	static ent; ent = fm_get_user_weapon_entity(id, CSW_GATLING)
	if(pev_valid(ent)) cs_set_weapon_ammo(ent, D_BARREL_DEFAULT_CLIP)
	
	// Set BpAmmo
	cs_set_user_bpammo(id, CSW_GATLING, D_BARREL_DEFAULT_BPAMMO)
	
	// Update Ammo
	update_ammo(id, CSW_GATLING, D_BARREL_DEFAULT_CLIP, D_BARREL_DEFAULT_BPAMMO)
}

public remove_gatling(id)
{
	UnSet_BitVar(g_Had_Volcano, id)
}

public hook_weapon(id)
{
	client_cmd(id, weapon_gatling)
	return PLUGIN_HANDLED
}

public Event_CurWeapon(id)
{
	static CSWID; CSWID = read_data(2)
	static SubModel; SubModel = SUBMODEL

	if((CSWID == CSW_GATLING && g_OldWeapon[id] != CSW_GATLING) && Get_BitVar(g_Had_Volcano, id))
	{
		if(SubModel != -1) Draw_NewWeapon(id, CSWID)
	} else if((CSWID == CSW_GATLING && g_OldWeapon[id] == CSW_GATLING) && Get_BitVar(g_Had_Volcano, id)) {
		static Ent; Ent = fm_get_user_weapon_entity(id, CSW_GATLING)
		if(!pev_valid(Ent))
		{
			g_OldWeapon[id] = get_user_weapon(id)
			return
		}
		
		static Float:Delay, Float:Delay2
		
		Delay = get_pdata_float(Ent, 46, 4) * D_BARREL_SPEED
		Delay2 = get_pdata_float(Ent, 47, 4) * D_BARREL_SPEED
		
		if(Delay > 0.0)
		{
		set_pdata_float(Ent, 46, Delay, 4)
		set_pdata_float(Ent, 47, Delay2, 4)
		}
	} else if(CSWID != CSW_GATLING && g_OldWeapon[id] == CSW_GATLING) {
		if(SubModel != -1) Draw_NewWeapon(id, CSWID)
	}
	
	g_OldWeapon[id] = get_user_weapon(id)
}

public Draw_NewWeapon(id, CSW_ID)
{
	if(CSW_ID == CSW_GATLING)
	{
		static ent
		ent = fm_get_user_weapon_entity(id, CSW_GATLING)
		
		if(pev_valid(ent) && Get_BitVar(g_Had_Volcano, id))
		{
			set_pev(ent, pev_effects, pev(ent, pev_effects) &~ EF_NODRAW) 
			engfunc(EngFunc_SetModel, ent, WeaponModel[1])	
			set_pev(ent, pev_body, SUBMODEL)
		}
	} else {
		static ent
		ent = fm_get_user_weapon_entity(id, CSW_GATLING)
		
		if(pev_valid(ent)) set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW) 			
	}
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_alive(id))
		return
	if(get_player_weapon(id) != CSW_GATLING || !Get_BitVar(g_Had_Volcano, id))
		return 

	static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)

	if(CurButton & IN_RELOAD)
	{
		CurButton &= ~IN_RELOAD
		set_uc(uc_handle, UC_Buttons, CurButton)
		
		static ent; ent = fm_get_user_weapon_entity(id, CSW_GATLING)
		if(!pev_valid(ent)) return
		
		static fInReload; fInReload = get_pdata_int(ent, m_fInReload, OFFSET_LINUX_WEAPONS)
		static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
		
		if (flNextAttack > 0.0)
			return
			
		if (fInReload)
		{
			set_weapon_anim(id, GATLING_ANIM_IDLE)
			return
		}
		
		if(cs_get_weapon_ammo(ent) >= D_BARREL_DEFAULT_CLIP)
		{
			set_weapon_anim(id, GATLING_ANIM_IDLE)
			return
		}
			
		fw_Weapon_Reload_Post(ent)
	}
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED
	
	static szClassName[33]
	pev(entity, pev_classname, szClassName, charsmax(szClassName))
	
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static id
	id = pev(entity, pev_owner)
	
	if(equal(model, DEFAULT_W_MODEL))
	{
		static weapon
		weapon = fm_find_ent_by_owner(-1, weapon_gatling, entity)
		
		if(!pev_valid(weapon))
			return FMRES_IGNORED
		
		if(Get_BitVar(g_Had_Volcano, id))
		{
			set_pev(weapon, pev_impulse, WEAPON_SECRET_CODE)
			engfunc(EngFunc_SetModel, entity, WeaponModel[2])
			set_pev(entity, pev_body, SUBMODEL)
			
			remove_gatling(id)
			
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED
}

public fw_TraceAttack(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_alive(attacker))
		return HAM_IGNORED	
	if(get_player_weapon(attacker) != CSW_GATLING || !Get_BitVar(g_Had_Volcano, attacker))
		return HAM_IGNORED
		
	SetHamParamFloat(3, float(D_BARREL_DAMAGE) / random_float(6.0, 7.0))	

	return HAM_HANDLED
}

public fw_TraceAttack_Post(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{
	if(!is_connected(Attacker))
		return HAM_IGNORED	
	if(get_player_weapon(Attacker) != CSW_GATLING  || !Get_BitVar(g_Had_Volcano, Attacker))
		return HAM_IGNORED
	if(cs_get_user_team(Ent) == cs_get_user_team(Attacker))
		return HAM_IGNORED
		
	if (!(DamageType & DMG_BULLET))
		return HAM_IGNORED
	if (Damage <= 0.0 || GetHamReturnStatus() == HAM_SUPERCEDE || get_tr2(ptr, TR_pHit) != Ent)
		return HAM_IGNORED
	
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(Ent, origin1)
	get_user_origin(Attacker, origin2)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > 1024)
		return HAM_IGNORED
		
	// Get victim's velocity
	static Float:velocity[3]
	pev(Ent, pev_velocity, velocity)
	
	// Use damage on knockback calculation
	xs_vec_mul_scalar(Dir, Damage, Dir)
	
	// Use weapon power on knockback calculation
	xs_vec_mul_scalar(Dir, float(D_BARREL_KNOCKPOWER), Dir)
	
	// Apply ducking knockback multiplier
	new ducking = pev(Ent, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	if (ducking) xs_vec_mul_scalar(Dir, 0.5, Dir)
	
	// Add up the new vector
	xs_vec_add(velocity, Dir, Dir)
	
	// Should knockback also affect vertical velocity?
	Dir[2] = velocity[2]
	
	// Set the knockback'd victim's velocity
	set_pev(Ent, pev_velocity, Dir)
		
	return HAM_IGNORED
}
public fw_TraceAttack_World(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_alive(attacker))
		return HAM_IGNORED	
	if(get_player_weapon(attacker) != CSW_GATLING || !Get_BitVar(g_Had_Volcano, attacker))
		return HAM_IGNORED
		
	static Float:flEnd[3], Float:vecPlane[3]

	get_tr2(ptr, TR_vecEndPos, flEnd)
	get_tr2(ptr, TR_vecPlaneNormal, vecPlane)		
	
	make_bullet(attacker, flEnd)
	//fake_smoke(attacker, ptr)
		
	SetHamParamFloat(3, float(D_BARREL_DAMAGE) / random_float(6.5, 7.0))	

	return HAM_HANDLED
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_alive(id))
		return FMRES_IGNORED
	if(get_player_weapon(id) != CSW_GATLING || !Get_BitVar(g_Had_Volcano, id))
		return FMRES_IGNORED
		
	set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if(!is_connected(invoker))
		return FMRES_IGNORED	
		
	if(get_player_weapon(invoker) == CSW_GATLING && Get_BitVar(g_Had_Volcano, invoker) && eventid == g_gatling_event)
	{
		engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
		Event_Gatling_Shoot(invoker)	

		return FMRES_SUPERCEDE
	}
	
	return FMRES_HANDLED
}

public fw_Item_Deploy_Post(ent)
{
	static id; id = fm_cs_get_weapon_ent_owner(ent)
	if (!pev_valid(id))
		return
	
	static weaponid
	weaponid = cs_get_weapon_id(ent)
	
	if(weaponid != CSW_GATLING)
		return
	if(!Get_BitVar(g_Had_Volcano, id))
		return
		
	static SubModel; SubModel = SUBMODEL
	
	set_pev(id, pev_viewmodel2, WeaponModel[0])
	set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : WeaponModel[1])
		
	set_weapon_anim(id, GATLING_ANIM_DRAW)
	set_pdata_string(id, m_szAnimExtention * 4, WEAPON_ANIMEXT, -1 , 20)
}

public fw_Weapon_Reload_Post(ent)
{
	static id; id = pev(ent, pev_owner)

	if(Get_BitVar(g_Had_Volcano, id))
	{
		static CurBpAmmo; CurBpAmmo = cs_get_user_bpammo(id, CSW_GATLING)
		
		if(CurBpAmmo  <= 0)
			return HAM_IGNORED

		set_pdata_int(ent, 55, 0, OFFSET_LINUX_WEAPONS)
		set_pdata_float(id, 83, D_BARREL_RELOAD_TIME, OFFSET_LINUX_PLAYER)
		set_pdata_float(ent, 48, D_BARREL_RELOAD_TIME + 0.5, OFFSET_LINUX_WEAPONS)
		set_pdata_float(ent, 46, D_BARREL_RELOAD_TIME + 0.25, OFFSET_LINUX_WEAPONS)
		set_pdata_float(ent, 47, D_BARREL_RELOAD_TIME + 0.25, OFFSET_LINUX_WEAPONS)
		set_pdata_int(ent, m_fInReload, 1, OFFSET_LINUX_WEAPONS)
		
		set_weapon_anim(id, GATLING_ANIM_RELOAD1)			
		
		return HAM_HANDLED
	}
	
	return HAM_IGNORED	
}

public fw_Item_PostFrame(ent)
{
	static id; id = pev(ent, pev_owner)
	if(!Get_BitVar(g_Had_Volcano, id)) return

	static iBpAmmo ; iBpAmmo = get_pdata_int(id, 381, OFFSET_LINUX_PLAYER)
	static iClip ; iClip = get_pdata_int(ent, m_iClip, OFFSET_LINUX_WEAPONS)
	static iMaxClip ; iMaxClip = D_BARREL_DEFAULT_CLIP

	if(get_pdata_int(ent, m_fInReload, OFFSET_LINUX_WEAPONS) && get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER) <= 0.0)
	{
		static j; j = min(iMaxClip - iClip, iBpAmmo)
		set_pdata_int(ent, m_iClip, iClip + j, OFFSET_LINUX_WEAPONS)
		set_pdata_int(id, 381, iBpAmmo-j, OFFSET_LINUX_PLAYER)
		
		set_pdata_int(ent, m_fInReload, 0, OFFSET_LINUX_WEAPONS)
		cs_set_weapon_ammo(ent, D_BARREL_DEFAULT_CLIP)
	
		update_ammo(id, CSW_GATLING, cs_get_weapon_ammo(ent), cs_get_user_bpammo(id, CSW_GATLING))
	
		return
	}
}

public fw_Item_AddToPlayer_Post(ent, id)
{
	if(!pev_valid(ent))
		return HAM_IGNORED
		
	if(pev(ent, pev_impulse) == WEAPON_SECRET_CODE)
	{
		Set_BitVar(g_Had_Volcano, id)
		update_ammo(id, CSW_GATLING, cs_get_weapon_ammo(ent), cs_get_user_bpammo(id, CSW_GATLING))
	}
	
	/*
	if(Get_BitVar(g_Had_Volcano, id))
	{
		static MSG; if(!MSG) MSG = get_user_msgid("WeaponList")
		message_begin(MSG_ONE_UNRELIABLE, MSG, _, id)
		write_string("weapon_gatling")
		write_byte(5)
		write_byte(200)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(5)
		write_byte(CSW_GATLING)
		write_byte(0)
		message_end()	
	}*/
		
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack(ent)
{
	static id; id = pev(ent, pev_owner)
	if(!Get_BitVar(g_Had_Volcano, id))
		return
		
	pev(id, pev_punchangle, g_punchangles[id])
}

public fw_Weapon_PrimaryAttack_Post(ent)
{
	static id; id = pev(ent, pev_owner)
	if(!Get_BitVar(g_Had_Volcano, id))
		return
		
	static Float:push[3]
	pev(id, pev_punchangle, push)
	xs_vec_sub(push, g_punchangles[id], push)
	
	xs_vec_mul_scalar(push, D_BARREL_RECOIL, push)
	xs_vec_add(push, g_punchangles[id], push)
	set_pev(id, pev_punchangle, push)	
}

public update_ammo(id, csw_id, clip, bpammo)
{
	if(!is_user_alive(id))
		return
		
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
	write_byte(1)
	write_byte(csw_id)
	write_byte(clip)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, id)
	write_byte(3)
	write_byte(bpammo)
	message_end()
}

public Event_Gatling_Shoot(id)
{
	set_weapon_anim(id, random_num(GATLING_ANIM_SHOOT1, GATLING_ANIM_SHOOT2))
	emit_sound(id, CHAN_WEAPON, WeaponSounds[0], 1.0, 0.4, 0, 94 + random_num(0, 15))
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	if (pev_valid(ent) != PDATA_SAFE)
		return -1
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

stock set_weapon_anim(id, anim)
{
	if(!is_user_alive(id))
		return
		
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(anim)
	write_byte(0)
	message_end()	
}

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)
	
	const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_MAC10)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_MAC10)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
	
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

public fake_smoke(id, trace_result)
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
	write_short(g_smokepuff_id)
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

stock create_blood(const Float:origin[3])
{
	// Show some blood :)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(m_iBlood[1])
	write_short(m_iBlood[0])
	write_byte(75)
	write_byte(5)
	message_end()
}


/* ===============================
------------- SAFETY -------------
=================================*/
public Register_SafetyFunc()
{
	register_event("CurWeapon", "Safety_CurWeapon", "be", "1=1")
	
	RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

public Register_SafetyFuncBot(id)
{
	RegisterHamFromEntity(Ham_Spawn, id, "fw_Safety_Spawn_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_Safety_Killed_Post", 1)
}

public Safety_Connected(id)
{
	Set_BitVar(g_IsConnected, id)
	UnSet_BitVar(g_IsAlive, id)
	
	g_PlayerWeapon[id] = 0
}

public Safety_Disconnected(id)
{
	UnSet_BitVar(g_IsConnected, id)
	UnSet_BitVar(g_IsAlive, id)
	
	g_PlayerWeapon[id] = 0
}

public Safety_CurWeapon(id)
{
	if(!is_alive(id))
		return
		
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
