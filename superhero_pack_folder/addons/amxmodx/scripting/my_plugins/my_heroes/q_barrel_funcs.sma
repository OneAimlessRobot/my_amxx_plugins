#define I_WANT_QUICK_CHECKS
#define I_WANT_FAKEMETA_UTIL
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_WEAPONS

#include "../my_include/superheromod.inc"
#include "q_barrel_inc/sh_q_barrel.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero graciete shotty funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new g_Had_QB, g_OldWeapon[33], g_SpecialShot, Float:Recoil[33][3]
new g_MsgCurWeapon, g_MsgAmmoX, g_Event_QB, g_SmokePuff_Id

new weapon_secret_code = QUAD_BARREL_WEAPON_SECRETCODE

new cached_ammo_id = -1

new const WeaponSounds[5][] = 
{
	"weapons/qbarrel_shoot.wav",
	"weapons/qbarrel_draw.wav",
	"weapons/qbarrel_clipin1.wav",
	"weapons/qbarrel_clipin2.wav",
	"weapons/qbarrel_clipout1.wav"
}

enum
{
	ANIM_IDLE = 0,
	ANIM_SHOOT1,
	ANIM_SHOOT2,
	ANIM_RELOAD,
	ANIM_DRAW
}

public plugin_natives(){
	
	

	register_native("q_barrel_set_q_barrel","_q_barrel_set_q_barrel");
	register_native("q_barrel_unset_q_barrel","_q_barrel_unset_q_barrel");
	
	
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cached_ammo_id = wlt_get_def_ammo_id(CSW_QUADBARREL)
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack",_,true)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Post", 1,true)
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack",_,true)		
	
	RegisterHam(Ham_Item_Deploy, weapon_data_structs_array[CSW_QUADBARREL][wpn_struct_weapon_name], "fw_Item_Deploy_Post", 1,true)
	RegisterHam(Ham_Item_AddToPlayer, weapon_data_structs_array[CSW_QUADBARREL][wpn_struct_weapon_name], "fw_Item_AddToPlayer_Post", 1,true)
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_data_structs_array[CSW_QUADBARREL][wpn_struct_weapon_name], "fw_Weapon_WeaponIdle_Post", 1,true)
	RegisterHam(Ham_Item_PostFrame, weapon_data_structs_array[CSW_QUADBARREL][wpn_struct_weapon_name], "fw_Item_PostFrame",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_data_structs_array[CSW_QUADBARREL][wpn_struct_weapon_name], "fw_Weapon_Reload_Post", 1, true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_structs_array[CSW_QUADBARREL][wpn_struct_weapon_name], "fw_Weapon_PrimaryAttack",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_structs_array[CSW_QUADBARREL][wpn_struct_weapon_name], "fw_Weapon_PrimaryAttack_Post", 1,true)
	
	weapon_secret_code = allocate_weapon_secret_code()
	// Cache
	g_MsgCurWeapon = get_user_msgid("CurWeapon")
	g_MsgAmmoX = get_user_msgid("AmmoX")
}
public _q_barrel_set_q_barrel(iPlugins,iParams){
	new id=get_param(1);
	Get_QuadBarrel(id)
}
public _q_barrel_unset_q_barrel(iPlugins,iParams){
	new id=get_param(1);

	Remove_QuadBarrel(id)
}
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,Q_BARREL_MODEL_V)
	engfunc(EngFunc_PrecacheModel,Q_BARREL_MODEL_P)
	engfunc(EngFunc_PrecacheModel,Q_BARREL_MODEL_W)
	
	for(new i = 0; i < sizeof(WeaponSounds); i++)
		engfunc(EngFunc_PrecacheSound,WeaponSounds[i])
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)	
	g_SmokePuff_Id = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")	
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal(OLD_EVENT_Q_BARREL, name))
		g_Event_QB = get_orig_retval()
}

public Get_QuadBarrel(id)
{
	Remove_QuadBarrel(id)
	
	UnSet_BitVar(g_SpecialShot, id);
	Set_BitVar(g_Had_QB, id);
	
	give_item(id, weapon_data_structs_array[CSW_QUADBARREL][wpn_struct_weapon_name])
	cs_set_user_bpammo(id, CSW_QUADBARREL, Q_BARREL_BPAMMO)
	
	static Ent; Ent = fm_get_user_weapon_entity(id, CSW_QUADBARREL)
	if(pev_valid(Ent)) cs_set_weapon_ammo(Ent, Q_BARREL_CLIP)
	
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, g_MsgCurWeapon, {0, 0, 0}, id)
	write_byte(1)
	write_byte(CSW_QUADBARREL)
	write_byte(Q_BARREL_CLIP)
	message_end()
}

public Remove_QuadBarrel(id)
{
	UnSet_BitVar(g_Had_QB, id)
}


public Event_CurWeapon(id)
{
	static CSWID; CSWID = read_data(2)

	if((CSWID == _:CSW_QUADBARREL && g_OldWeapon[id] == _:CSW_QUADBARREL) && Get_BitVar(g_Had_QB, id)) 
	{
		static Ent; Ent = fm_get_user_weapon_entity(id, _:CSW_QUADBARREL)
		if(pev_valid(Ent)==PDATA_SAFE)
		{
			set_pdata_float(Ent, m_flNextPrimaryAttack,
						get_pdata_float(Ent, m_flNextPrimaryAttack, XO_WEAPON)  * Q_BARREL_SPEED, XO_WEAPON)
	
			set_pdata_float(Ent, m_flNextSecondaryAttack,
						get_pdata_float(Ent, m_flNextSecondaryAttack, XO_WEAPON) * Q_BARREL_SPEED, XO_WEAPON)
		}
	}
	
	g_OldWeapon[id] = CSWID
}


public fw_SetModel(entity, model[])
{	

	ent_check(entity,FMRES_IGNORED)

	static Classname[64]
	pev(entity, pev_classname, Classname, sizeof(Classname))
	
	if(!equal(Classname, "weaponbox"))
		return FMRES_IGNORED
	
	static id
	id = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, OLD_W_MODEL_Q_BARREL))
	{
		static weapon
		weapon = fm_get_user_weapon_entity(entity, CSW_QUADBARREL)
		
		ent_check(weapon,FMRES_IGNORED)
		
		if(Get_BitVar(g_Had_QB, id))
		{
			set_pev(weapon, pev_impulse, weapon_secret_code)
			engfunc(EngFunc_SetModel, entity, Q_BARREL_MODEL_W)
			
			Remove_QuadBarrel(id)
			
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
	if(get_user_weapon(id) != _:CSW_QUADBARREL || !Get_BitVar(g_Had_QB, id)){
		return FMRES_IGNORED
	}
		
	static NewButton; NewButton = get_uc(uc_handle, UC_Buttons)
	
	static Ent; Ent = fm_get_user_weapon_entity(id, _:CSW_QUADBARREL)
	ent_check(Ent,FMRES_IGNORED)
	
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
	static Ammo; Ammo = cs_get_weapon_ammo(Ent)
	
	if(NewButton & IN_ATTACK2)
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

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id)){
		return FMRES_IGNORED
	}
	
	if((get_user_weapon(id) != _:CSW_QUADBARREL)||!Get_BitVar(g_Had_QB, id)){

		return FMRES_IGNORED

	}
	new pEntity = get_pdata_cbase(id, m_pActiveItem,OFFSET_LINUX_PLAYER)
	if(is_valid_ent(pEntity)){
		set_cd(cd_handle, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED		
	if(get_user_weapon(invoker) == _:CSW_QUADBARREL && Get_BitVar(g_Had_QB, invoker) && eventid == g_Event_QB)
	{
		engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)	

		native_playanim(invoker, ANIM_SHOOT1)
		emit_sound(invoker, CHAN_WEAPON, WeaponSounds[0], 1.0, ATTN_NORM, 0, PITCH_LOW)	

		return FMRES_SUPERCEDE
	}
	
	return FMRES_HANDLED
}

public fw_TraceAttack(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{
	if(Damage<=0.0){
		return HAM_IGNORED
	}
	
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != _:CSW_QUADBARREL || !Get_BitVar(g_Had_QB, Attacker))
		return HAM_IGNORED
		
	static Float:flEnd[3], Float:vecPlane[3]

	get_tr2(ptr, TR_vecEndPos, flEnd)
	get_tr2(ptr, TR_vecPlaneNormal, vecPlane)		
	

	if(is_entity_brush(Ent)){
		make_bullet(Attacker, flEnd)
	}
	fake_smoke(Attacker, ptr, g_SmokePuff_Id)
	
	SetHamParamFloat(3, float(Q_BARREL_DAMAGE) / 6.0)

	return HAM_HANDLED
}

public fw_TraceAttack_Post(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{	
	if(Damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != _:CSW_QUADBARREL || !Get_BitVar(g_Had_QB, Attacker))
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
	xs_vec_mul_scalar(Dir, float(Q_BARREL_KNOCKPOWER), Dir)
	
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

public fw_Item_Deploy_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)

	if (!is_user_alive(Id)){
		return
	}
	if(get_pdata_cbase(Id, m_pActiveItem) != Ent)
		return
	if(!Get_BitVar(g_Had_QB, Id))
		return

	set_pev(Id, pev_viewmodel2, Q_BARREL_MODEL_V)
	set_pev(Id, pev_weaponmodel2, Q_BARREL_MODEL_P)
	
	native_playanim(Id, ANIM_DRAW)
	set_pdata_string(Id, (m_szAnimExtention) * 4,  ANIM_EXT, -1 ,  XTRA_OFS_PLAYER * 4)
}

public fw_Item_AddToPlayer_Post(ent, id)
{

	ent_check(ent,)
	
	if(pev(ent, pev_impulse) == weapon_secret_code)
	{
		Set_BitVar(g_Had_QB, id)
		set_pev(ent, pev_impulse, 0)
	}	
}

public fw_Weapon_WeaponIdle_Post(iEnt)
{
	if(pev_valid(iEnt) != 2){
		return 
	}
	static id; id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)

	if (!is_user_alive(id)){
		return
	}
	if(get_pdata_cbase(id, m_pActiveItem, OFFSET_LINUX_PLAYER) != iEnt)
		return
	if(!Get_BitVar(g_Had_QB, id))
		return
	
	static SpecialReload; SpecialReload = get_pdata_int(iEnt, m_fInSpecialReload, XO_WEAPON)
	if(!SpecialReload && get_pdata_float(iEnt, m_flTimeWeaponIdle, XO_WEAPON) <= 0.25)
	{
		native_playanim(id, ANIM_IDLE)
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 20.0, XO_WEAPON)
	}	
}

public fw_Item_PostFrame(iEnt)
{
	if(pev_valid(iEnt) != 2){
		return HAM_IGNORED
	}
	static id; id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)
	
	if(!is_user_alive(id)){
		
		return HAM_IGNORED
	}
	if(get_pdata_cbase(id, m_pActiveItem, OFFSET_LINUX_PLAYER) != iEnt){
		return HAM_IGNORED
	}
	if(!Get_BitVar(g_Had_QB, id)){
		return HAM_IGNORED
	}

	static iBpAmmo ; iBpAmmo = cs_get_user_bpammo(id, CSW_QUADBARREL)
	static iClip ; iClip = get_pdata_int(iEnt, m_iClip, XO_WEAPON)
	static iMaxClip ; iMaxClip = Q_BARREL_CLIP

	if(get_pdata_int(iEnt, m_fInReload, XO_WEAPON) && get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER) <= 0.0)
	{
		static j; j = min(iMaxClip - iClip, iBpAmmo)
		set_pdata_int(iEnt, m_iClip, iClip + j, XO_WEAPON)

		cs_set_user_bpammo(id, CSW_QUADBARREL, iBpAmmo-j)
		
		set_pdata_int(iEnt, m_fInReload, 0, XO_WEAPON)
		if(iBpAmmo > Q_BARREL_CLIP){
			cs_set_weapon_ammo(iEnt, min(iBpAmmo, Q_BARREL_CLIP))
		}
		else{
			cs_set_weapon_ammo(iEnt, iClip + iBpAmmo)
		}

		// Update the fucking ammo hud
		message_begin(MSG_ONE_UNRELIABLE, g_MsgCurWeapon, _, id)
		write_byte(1)
		write_byte(CSW_QUADBARREL)
		write_byte(Q_BARREL_CLIP)
		message_end()
		
		message_begin(MSG_ONE_UNRELIABLE, g_MsgAmmoX, _, id)
		write_byte(cached_ammo_id)
		write_byte(cs_get_user_bpammo(id, CSW_QUADBARREL))
		message_end()
	
		return HAM_IGNORED
	}
	return HAM_IGNORED
}

public fw_Weapon_Reload_Post(iEnt)
{
	if(pev_valid(iEnt) != 2)
		return 
	static id; id = get_pdata_cbase(iEnt,m_pPlayer, XO_WEAPON)

	if (!is_user_alive(id)){
		return
	}
	if(get_pdata_cbase(id, m_pActiveItem, OFFSET_LINUX_PLAYER) != iEnt)
		return
	if(!Get_BitVar(g_Had_QB, id))
		return

	static CurBpAmmo; CurBpAmmo = cs_get_user_bpammo(id, CSW_QUADBARREL)
	if(CurBpAmmo  <= 0)
		return

	set_pdata_int(iEnt, m_fInSpecialReload, 0, XO_WEAPON)
	set_pdata_float(id, m_flNextAttack, Q_BARREL_RELOAD_TIME, OFFSET_LINUX_PLAYER)
	set_pdata_float(iEnt, m_flTimeWeaponIdle, Q_BARREL_RELOAD_TIME + 0.5, XO_WEAPON)
	set_pdata_float(iEnt, m_flNextPrimaryAttack, Q_BARREL_RELOAD_TIME + 0.25, XO_WEAPON)
	set_pdata_float(iEnt, m_flNextSecondaryAttack, Q_BARREL_RELOAD_TIME + 0.25, XO_WEAPON)
	set_pdata_int(iEnt, m_fInReload, 1, XO_WEAPON)
	
	native_playanim(id, ANIM_RELOAD)
}


public fw_Weapon_PrimaryAttack(iEnt)
{
	if(pev_valid(iEnt) != 2){
		return HAM_IGNORED
	}
	static id; id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)
	if(!is_user_alive(id)){
		return HAM_IGNORED
	}
	if(get_pdata_cbase(id, m_pActiveItem, OFFSET_LINUX_PLAYER) != iEnt){
		return HAM_IGNORED
	}
	if(!Get_BitVar(g_Had_QB, id)){
		return HAM_IGNORED
	}
		
	pev(id, pev_punchangle, Recoil[id])
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack_Post(iEnt)
{
	if(pev_valid(iEnt) != 2)
		return 
	static id; id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)
	if(!is_user_alive(id)){
		return
	}
	if(get_pdata_cbase(id, m_pActiveItem, OFFSET_LINUX_PLAYER) != iEnt){
		return
	}
	if(!Get_BitVar(g_Had_QB, id)){
		return
	}
	if(!Get_BitVar(g_SpecialShot, id)){
		return
	}

	static iClip;iClip = get_pdata_int(iEnt, m_iClip, XO_WEAPON)
	if(iClip<=0){

		return
	}
	static Float:Push[3]
	pev(id, pev_punchangle, Push)
	xs_vec_sub(Push, Recoil[id], Push)
	
	xs_vec_mul_scalar(Push, Q_BARREL_RECOIL, Push)
	xs_vec_add(Push, Recoil[id], Push)
	
	set_pev(id, pev_punchangle, Push)
}

public Get_EndOrigin(Float:Start[3], Float:End[3], Float:Result[3], IgnoreEnt)
{
	static TraceID
	engfunc(EngFunc_TraceLine, Start, End, DONT_IGNORE_MONSTERS, IgnoreEnt, TraceID)
	
	get_tr2(TraceID, TR_vecEndPos, Result)
}

