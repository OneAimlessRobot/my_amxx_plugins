#define AUX_STUFF_GIVE_WEAPONS
#define I_WANT_CONSTANTS
#define I_WANT_FAKEMETA_UTIL
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_WEAPONS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "d_barrel_inc/sh_d_barrel.inc"


#define PLUGIN "Superhero Snoodle d_barrel funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new const WeaponModel[3][] =
{
	"models/shmod/supernoodle/dbarrel/v_dbarrel.mdl", // V
	"models/shmod/supernoodle/dbarrel/p_dbarrel.mdl", // P
	"models/shmod/supernoodle/dbarrel/w_dbarrel.mdl" // W
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


new g_Volcano, g_OldWeapon[33]
new g_Had_Volcano, Float:g_punchangles[33][3], g_gatling_event, g_smokepuff_id, m_iBlood[2]
new g_SpecialShot



new weapon_secret_code = CSW_GATLING_SECRET_CODE

new cached_ammo_id = -1
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cached_ammo_id = wlt_get_def_ammo_id(CSW_GATLING)

	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_World",_,true)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack",_,true)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Post", 1,true)
	
	RegisterHam(Ham_Item_Deploy, weapon_data_structs_array[CSW_GATLING][wpn_struct_weapon_name], "fw_Item_Deploy_Post", 1,true)
	RegisterHam(Ham_Weapon_Reload, weapon_data_structs_array[CSW_GATLING][wpn_struct_weapon_name], "fw_Weapon_Reload_Post", 1,true)
	RegisterHam(Ham_Item_PostFrame, weapon_data_structs_array[CSW_GATLING][wpn_struct_weapon_name], "fw_Item_PostFrame",_,true)
	RegisterHam(Ham_Item_AddToPlayer, weapon_data_structs_array[CSW_GATLING][wpn_struct_weapon_name], "fw_Item_AddToPlayer_Post", 1,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_structs_array[CSW_GATLING][wpn_struct_weapon_name], "fw_Weapon_PrimaryAttack",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_structs_array[CSW_GATLING][wpn_struct_weapon_name], "fw_Weapon_PrimaryAttack_Post", 1,true)


	weapon_secret_code = allocate_weapon_secret_code()

}
public plugin_natives(){
	
	

	register_native("d_barrel_set_d_barrel","_d_barrel_set_d_barrel");
	register_native("d_barrel_unset_d_barrel","_d_barrel_unset_d_barrel");
	
	
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

public Mileage_WeaponGet(id, ItemID)
{
	if(ItemID == g_Volcano) get_gatling(id)
}

public Mileage_WeaponRefillAmmo(id, ItemID)
{
	if(ItemID == g_Volcano) 
	{
		cs_set_user_bpammo(id, _:CSW_GATLING, D_BARREL_DEFAULT_BPAMMO)
	}
}

public Mileage_WeaponRemove(id, ItemID)
{
	if(ItemID == g_Volcano) remove_gatling(id)
}

public get_gatling(id)
{
	Set_BitVar(g_Had_Volcano, id)
	fm_give_item(id, weapon_data_structs_array[CSW_GATLING][wpn_struct_weapon_name])
	
	// Set Clip
	static ent; ent = fm_get_user_weapon_entity(id, _:CSW_GATLING)
	if(pev_valid(ent)) cs_set_weapon_ammo(ent, D_BARREL_DEFAULT_CLIP)
	
	// Set BpAmmo
	cs_set_user_bpammo(id, _:CSW_GATLING, D_BARREL_DEFAULT_BPAMMO)
	
}

public remove_gatling(id)
{
	UnSet_BitVar(g_Had_Volcano, id)
}


public Event_CurWeapon(id)
{
	
	static CSWID; CSWID = read_data(2)

	if((CSWID == _:CSW_GATLING && g_OldWeapon[id] == _:_:CSW_GATLING) && Get_BitVar(g_Had_Volcano, id)) 
	{
		static Ent; Ent = fm_get_user_weapon_entity(id, _:_:CSW_GATLING)
		if(pev_valid(Ent)==PDATA_SAFE) 
		{
			set_pdata_float(Ent, m_flNextPrimaryAttack,
						get_pdata_float(Ent, m_flNextPrimaryAttack, XO_WEAPON)  * D_BARREL_SPEED, XO_WEAPON)
	
			set_pdata_float(Ent, m_flNextSecondaryAttack,
						get_pdata_float(Ent, m_flNextSecondaryAttack, XO_WEAPON) * D_BARREL_SPEED, XO_WEAPON)
		}
	}
	
	g_OldWeapon[id] = CSWID
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)){
		return FMRES_IGNORED
	}
	if(get_user_weapon(id) != _:CSW_GATLING || !Get_BitVar(g_Had_Volcano, id)){
		return FMRES_IGNORED
	}

	static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)
	static Ent; Ent = fm_get_user_weapon_entity(id, _:CSW_GATLING)
	
	ent_check(Ent,FMRES_IGNORED)
	
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
	static Ammo; Ammo = cs_get_weapon_ammo(Ent)
	
	
	if(CurButton & IN_RELOAD)
	{
		CurButton &= ~IN_RELOAD
		set_uc(uc_handle, UC_Buttons, CurButton)
		
		static ent; ent = fm_get_user_weapon_entity(id, _:CSW_GATLING)
		
		ent_check(ent,FMRES_IGNORED)

		static fInReload; fInReload = get_pdata_int(ent, m_fInReload, XO_WEAPON)
		static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
		
		if (flNextAttack > 0.0){
			return FMRES_IGNORED
		}
			
		if (fInReload)
		{
			native_playanim(id, GATLING_ANIM_IDLE)
			return FMRES_IGNORED
		}
		
		if(cs_get_weapon_ammo(ent) >= D_BARREL_DEFAULT_CLIP)
		{
			native_playanim(id, GATLING_ANIM_IDLE)
			return FMRES_IGNORED
		}
			
		fw_Weapon_Reload_Post(ent)
	}
	if(CurButton & IN_ATTACK2)
	{
		if(flNextAttack > 0.0){
			return FMRES_IGNORED
		}
		for(new i = 0; i < Ammo; i++)
		{
			Set_BitVar(g_SpecialShot, id)
			ExecuteHamB(Ham_Weapon_PrimaryAttack, Ent)
			UnSet_BitVar(g_SpecialShot, id)
		}
	}
	return FMRES_IGNORED
}

public fw_SetModel(entity, model[])
{

	ent_check(entity,FMRES_IGNORED)

	static szClassName[33]
	pev(entity, pev_classname, szClassName, charsmax(szClassName))
	
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static id
	id = pev(entity, pev_owner)
	
	if(equal(model, DEFAULT_W_MODEL))
	{
		static weapon
		weapon = fm_find_ent_by_owner(-1, weapon_data_structs_array[CSW_GATLING][wpn_struct_weapon_name], entity)
		
		
		ent_check(weapon,FMRES_IGNORED)
		
		if(Get_BitVar(g_Had_Volcano, id))
		{
			set_pev(weapon, pev_impulse, weapon_secret_code)
			engfunc(EngFunc_SetModel, entity, WeaponModel[2])
			set_pev(entity, pev_body, D_BARREL_SUBMODEL)
			
			remove_gatling(id)
			
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED
}

public fw_TraceAttack(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{	
	if(Damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_alive(attacker))
		return HAM_IGNORED	
	if(get_user_weapon(attacker) != _:CSW_GATLING || !Get_BitVar(g_Had_Volcano, attacker))
		return HAM_IGNORED
		
	SetHamParamFloat(3, float(D_BARREL_DAMAGE) / generate_float(6.0, 7.0))	

	return HAM_HANDLED
}

public fw_TraceAttack_Post(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{	
	if(Damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != _:CSW_GATLING  || !Get_BitVar(g_Had_Volcano, Attacker))
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
	//Dir[2] = velocity[2]
	
	// Set the knockback'd victim's velocity
	set_pev(Ent, pev_velocity, Dir)
		
	return HAM_IGNORED
}
public fw_TraceAttack_World(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(attacker))
		return HAM_IGNORED	
	if(get_user_weapon(attacker) != _:CSW_GATLING || !Get_BitVar(g_Had_Volcano, attacker))
		return HAM_IGNORED
		
	static Float:flEnd[3], Float:vecPlane[3]

	get_tr2(ptr, TR_vecEndPos, flEnd)
	get_tr2(ptr, TR_vecPlaneNormal, vecPlane)		
	
	
	if(is_entity_brush(ent)){
		make_bullet(attacker, flEnd)
	}
	fake_smoke(attacker, ptr, g_smokepuff_id)

	return HAM_HANDLED
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id)){
		return FMRES_IGNORED
	}


	if((get_user_weapon(id) != _:CSW_GATLING)||!Get_BitVar(g_Had_Volcano, id)){

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
	if(!is_user_connected(invoker))
		return FMRES_IGNORED	
		
	if(get_user_weapon(invoker) == _:CSW_GATLING && Get_BitVar(g_Had_Volcano, invoker) && eventid == g_gatling_event)
	{
		engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
		native_playanim(invoker, generate_int(GATLING_ANIM_SHOOT1, GATLING_ANIM_SHOOT2))

		return FMRES_SUPERCEDE
	}
	
	return FMRES_HANDLED
}

public fw_Item_Deploy_Post(ent)
{	
	ent_check(ent,)

	static id; id = fm_cs_get_weapon_ent_owner(ent)
	if(!is_user_alive(id)){
		return
	}
	
	static weaponid
	weaponid = cs_get_weapon_id(ent)
	
	if(weaponid != _:CSW_GATLING)
		return
	if(!Get_BitVar(g_Had_Volcano, id))
		return
		
	static SubModel; SubModel = D_BARREL_SUBMODEL
	
	set_pev(id, pev_viewmodel2, WeaponModel[0])
	set_pev(id, pev_weaponmodel2, SubModel != -1 ? "" : WeaponModel[1])
	static SpecialReload; SpecialReload = get_pdata_int(ent, m_fInSpecialReload, XO_WEAPON)
	if(!SpecialReload && get_pdata_float(ent, m_flTimeWeaponIdle, XO_WEAPON) <= 0.25)
	{
		native_playanim(id, GATLING_ANIM_IDLE)
		set_pdata_float(ent, m_flTimeWeaponIdle, 20.0, XO_WEAPON)
	}	
	native_playanim(id, GATLING_ANIM_DRAW)
	set_pdata_string(id, m_szAnimExtention * 4, WEAPON_ANIMEXT, -1 , 20)
}

public fw_Weapon_Reload_Post(ent)
{
	if(pev_valid(ent)!=2){

		return HAM_IGNORED;
	}
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!is_user_alive(id)){
		return HAM_IGNORED
	}
	if(Get_BitVar(g_Had_Volcano, id))
	{
		static CurBpAmmo; CurBpAmmo = cs_get_user_bpammo(id, _:CSW_GATLING)
		
		if(CurBpAmmo  <= 0)
			return HAM_IGNORED

		set_pdata_int(ent, m_fInSpecialReload, 0, XO_WEAPON)
		set_pdata_float(id, m_flNextAttack, D_BARREL_RELOAD_TIME, OFFSET_LINUX_PLAYER)
		set_pdata_float(ent, m_flTimeWeaponIdle, D_BARREL_RELOAD_TIME + 0.5, XO_WEAPON)
		set_pdata_float(ent, m_flNextPrimaryAttack, D_BARREL_RELOAD_TIME + 0.25, XO_WEAPON)
		set_pdata_float(ent, m_flNextSecondaryAttack, D_BARREL_RELOAD_TIME + 0.25, XO_WEAPON)
		set_pdata_int(ent, m_fInReload, 1, XO_WEAPON)
		
		native_playanim(id, GATLING_ANIM_RELOAD1)			
		
		return HAM_HANDLED
	}
	
	return HAM_IGNORED	
}

public fw_Item_PostFrame(ent)
{
	if(pev_valid(ent)!=2){
		return HAM_IGNORED
	}
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	
	if(!is_user_alive(id)){
		
		return HAM_IGNORED
	}
	if(!Get_BitVar(g_Had_Volcano, id)) return HAM_IGNORED

	static iBpAmmo ; iBpAmmo = cs_get_user_bpammo(id, _:CSW_GATLING)
	static iClip ; iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
	static iMaxClip ; iMaxClip = D_BARREL_DEFAULT_CLIP

	if(get_pdata_int(ent, m_fInReload, XO_WEAPON) && get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER) <= 0.0)
	{
		static j; j = min(iMaxClip - iClip, iBpAmmo)
		set_pdata_int(ent, m_iClip, iClip + j, XO_WEAPON)
		cs_set_user_bpammo(id, _:CSW_GATLING, iBpAmmo-j)
		
		set_pdata_int(ent, m_fInReload, 0, XO_WEAPON)
		cs_set_weapon_ammo(ent, D_BARREL_DEFAULT_CLIP)
	
		update_ammo(id, _:CSW_GATLING, cs_get_weapon_ammo(ent), cs_get_user_bpammo(id, _:CSW_GATLING),cached_ammo_id)
	}
	return HAM_IGNORED
}

public fw_Item_AddToPlayer_Post(ent, id)
{
	ent_check(ent,HAM_IGNORED)
		
	if(pev(ent, pev_impulse) == weapon_secret_code)
	{
		Set_BitVar(g_Had_Volcano, id)
		set_pev(ent, pev_impulse, 0)
	}
		
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack(ent)
{
	ent_check(ent,)

	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!is_user_alive(id)){
		return
	}

	if(get_pdata_cbase(id, m_pActiveItem, OFFSET_LINUX_PLAYER) != ent){
		return
	}
	if(!Get_BitVar(g_Had_Volcano, id))
		return
		
	pev(id, pev_punchangle, g_punchangles[id])
}

public fw_Weapon_PrimaryAttack_Post(ent)
{
	ent_check(ent,)
	
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!is_user_alive(id)){
		return
	}
	if(!Get_BitVar(g_Had_Volcano, id))
		return
	

	static iClip;iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
	if(iClip<=0){

		return
	}

	static Float:push[3]
	pev(id, pev_punchangle, push)
	xs_vec_sub(push, g_punchangles[id], push)
	
	xs_vec_mul_scalar(push, D_BARREL_RECOIL, push)
	xs_vec_add(push, g_punchangles[id], push)
	set_pev(id, pev_punchangle, push)	
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	if (pev_valid(ent) != PDATA_SAFE)
		return -1
	
	return get_pdata_cbase(ent, m_pPlayer, XO_WEAPON)
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