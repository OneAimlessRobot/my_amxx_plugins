#define AUX_STUFF_GIVE_WEAPONS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_CUSTOM_WEAPONS
#include "../my_include/superheromod.inc"
#include "h_rifle_inc/sh_h_rifle.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero: Supernoodle hunting rifle"
#define VERSION "1.0"
#include "../my_include/my_author_header.inc"

new const WeaponSounds[4][] = 
{
	"weapons/mosin-1.wav",
	"weapons/mosin_start_reload.wav",
	"weapons/mosin_insert.wav",
	"weapons/mosin_after_reload.wav"
}

enum
{
	ANIM_IDLE = 0,
	ANIM_SHOOT,
	ANIM_INSERT,
	ANIM_AFTER_RELOAD,
	ANIM_START_RELOAD,
	ANIM_DRAW
}

enum
{
	EVENT_NONE = 0,
	EVENT_ATTACK1,
	EVENT_ATTACK2,
	EVENT_RELOAD
}

// Main Vars
new g_Had_Mosin, g_Old_Weapon[33]
new g_Event_MS
new g_MsgCurWeapon


new weapon_secret_code = H_RIFLE_SECRET_CODE


public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	
	
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack",_,true)
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack",_,true)		
	
	RegisterHam(Ham_Item_Deploy, weapon_data_strings_array[CSW_MOSIN][wpn_struct_weapon_name], "fw_Item_Deploy_Post", 1,true)	
	RegisterHam(Ham_Item_AddToPlayer, weapon_data_strings_array[CSW_MOSIN][wpn_struct_weapon_name], "fw_Item_AddToPlayer_Post", 1,true)
	RegisterHam(Ham_Weapon_Reload, weapon_data_strings_array[CSW_MOSIN][wpn_struct_weapon_name], "fw_Weapon_Reload",_,true)
	RegisterHam(Ham_Item_PostFrame, weapon_data_strings_array[CSW_MOSIN][wpn_struct_weapon_name], "fw_Item_PostFrame",_,true)
	
	weapon_secret_code = allocate_weapon_secret_code()

	g_MsgCurWeapon = get_user_msgid("CurWeapon")

}

public plugin_natives(){
	
	

	register_native("h_rifle_set_h_rifle","_h_rifle_set_h_rifle");
	register_native("h_rifle_unset_h_rifle","_h_rifle_unset_h_rifle");
	
	
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,H_RIFLE_MODEL_V)
	engfunc(EngFunc_PrecacheModel,H_RIFLE_MODEL_P)
	engfunc(EngFunc_PrecacheModel,H_RIFLE_MODEL_W)
	
	for(new i = 0; i < sizeof(WeaponSounds); i++)
		engfunc(EngFunc_PrecacheSound,WeaponSounds[i])
		
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal(OLD_EVENT_H_RIFLE, name))
		g_Event_MS = get_orig_retval()
}

public _h_rifle_set_h_rifle(iPlugins,iParams){
	new id=get_param(1);
	Get_Mosin(id)
}
public _h_rifle_unset_h_rifle(iPlugins,iParams){
	new id=get_param(1);

	Remove_Mosin(id)
}
public Get_Mosin(id)
{
	Remove_Mosin(id)
	
	Set_BitVar(g_Had_Mosin, id)
	
	give_item(id, weapon_data_strings_array[CSW_MOSIN][wpn_struct_weapon_name])
	cs_set_user_bpammo(id, CSW_MOSIN, H_RIFLE_BPAMMO)
	
	static Ent; Ent = get_weapon_ent_of_player(id, CSW_MOSIN)
	if(pev_valid(Ent)) cs_set_weapon_ammo(Ent, H_RIFLE_CLIP)
	
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, g_MsgCurWeapon, {0, 0, 0}, id)
	write_byte(1)
	write_byte(CSW_MOSIN)
	write_byte(H_RIFLE_CLIP)
	message_end()
}

public Remove_Mosin(id)
{
	UnSet_BitVar(g_Had_Mosin, id)
}

public Event_CurWeapon(id)
{
	
	static CSWID; CSWID = read_data(2)
	
	if((CSWID == CSW_MOSIN && g_Old_Weapon[id] == CSW_MOSIN) && Get_BitVar(g_Had_Mosin, id)) 
	{
		static Ent; Ent = get_weapon_ent_of_player(id, CSW_MOSIN)
		if(pev_valid(Ent)!=PDATA_SAFE)
		{
			g_Old_Weapon[id] = get_user_weapon(id)
			return
		}
		
		if(cs_get_user_zoom(id) == 1)
		{
			set_pev(id, pev_viewmodel2, H_RIFLE_MODEL_V)
		} else if(cs_get_user_zoom(id) == 2 || cs_get_user_zoom(id) == 3) {
			set_pev(id, pev_viewmodel2, "")
		}
		
		static Float:TargetTime; TargetTime = get_pdata_float(Ent, m_flNextPrimaryAttack, XO_WEAPON) * H_RIFLE_SPEED
		
		set_pdata_float(Ent, m_flNextPrimaryAttack, TargetTime, XO_WEAPON)
		set_pdata_float(id, m_flNextAttack, TargetTime, OFFSET_LINUX_PLAYER)
	}
	
	g_Old_Weapon[id] = get_user_weapon(id)
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
	
	if(equal(model, OLD_W_MODEL_H_RIFLE))
	{
		static weapon
		weapon = get_weapon_ent_of_player(entity, CSW_MOSIN)
		
		ent_check(weapon,FMRES_IGNORED)
		
		if(Get_BitVar(g_Had_Mosin, id))
		{
			set_pev(weapon, pev_impulse, weapon_secret_code)
			engfunc(EngFunc_SetModel, entity, H_RIFLE_MODEL_W)
			
			Remove_Mosin(id)
			
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
	if(!is_user_alive(id))
		return FMRES_IGNORED
		
	static iEnt; iEnt = get_weapon_ent_of_player(id, get_user_weapon(id))
	static PressButton; PressButton = get_uc(uc_handle, UC_Buttons)
	if(!is_valid_ent(iEnt)||(iEnt<=0)){
	
		return FMRES_IGNORED
	
	}
	if((PressButton & IN_RELOAD) && cs_get_weapon_ammo(iEnt) < H_RIFLE_CLIP && cs_get_user_bpammo(id, CSW_MOSIN) > 0 && !get_pdata_int(iEnt, m_fInSpecialReload, XO_WEAPON))
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
	if(!is_user_alive(id)){
		return FMRES_IGNORED
	}
	
	if((get_user_weapon(id) != CSW_MOSIN)||!Get_BitVar(g_Had_Mosin, id)){

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
	if(get_user_weapon(invoker) == CSW_MOSIN && Get_BitVar(g_Had_Mosin, invoker) && eventid == g_Event_MS)
	{
		engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)	

		native_playanim(invoker, ANIM_SHOOT)
		emit_sound(invoker, CHAN_WEAPON, WeaponSounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)	

		set_pdata_float(invoker, m_flEjectBrass, get_gametime() + 0.75, XO_WEAPON)
		
		static Ent; Ent = get_weapon_ent_of_player(invoker, CSW_MOSIN)
		set_pdata_int(Ent, m_fInSpecialReload, 0, XO_WEAPON)
		
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
	if(get_user_weapon(Attacker) != CSW_MOSIN || !Get_BitVar(g_Had_Mosin, Attacker))
		return HAM_IGNORED
		
	static Float:flEnd[3], Float:vecPlane[3]
		
	get_tr2(ptr, TR_vecEndPos, flEnd)
	get_tr2(ptr, TR_vecPlaneNormal, vecPlane)		
			
	make_bullet(Attacker, flEnd)
		
	SetHamParamFloat(3, float(H_RIFLE_DAMAGE))
		
	return HAM_HANDLED	
}

public fw_Item_Deploy_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)

	if (!is_user_alive(Id)){
		return
	}
	if(get_pdata_cbase(Id, m_pActiveItem, OFFSET_LINUX_PLAYER) != Ent)
		return
	if(!Get_BitVar(g_Had_Mosin, Id))
		return

	set_pev(Id, pev_viewmodel2, H_RIFLE_MODEL_V)
	set_pev(Id, pev_weaponmodel2, H_RIFLE_MODEL_P)
	
	native_playanim(Id, ANIM_DRAW)
	set_pdata_int(Ent, m_fInSpecialReload, 0, XO_WEAPON)
}

public fw_Item_AddToPlayer_Post(ent, id)
{
	if(pev(ent, pev_impulse) == weapon_secret_code)
	{
		Set_BitVar(g_Had_Mosin, id)
		set_pev(ent, pev_impulse, 0)
	}			
}

public fw_Weapon_Reload(iEnt)
{
	if(pev_valid(iEnt)!=2){

		return HAM_IGNORED;
	}
	static id ; id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Mosin, id))
		return HAM_IGNORED	
	
	set_pdata_int(iEnt, m_fInReload, 0, XO_WEAPON)
	set_pdata_int(iEnt, m_fInSpecialReload, 1, XO_WEAPON)
	
	return HAM_SUPERCEDE
}

public fw_Item_PostFrame( iEnt )
{
	if(pev_valid(iEnt) != 2){
		return
	}
	static id ; id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)

	if (!is_user_alive(id)){
		return
	}

	static iBpAmmo ; iBpAmmo = cs_get_user_bpammo(id, CSW_MOSIN)
	static iClip ; iClip = get_pdata_int(iEnt, m_iClip, XO_WEAPON)

	if(get_pdata_int(id, m_flNextAttack, XTRA_OFS_PLAYER) > 0.0)
		return

	switch(get_pdata_int(iEnt, m_fInSpecialReload, XO_WEAPON) )
	{
		case 1: // Check, Start
		{
			if(cs_get_weapon_ammo(iEnt) >= H_RIFLE_CLIP || cs_get_user_bpammo(id, CSW_MOSIN) <= 0)
			{
				set_pdata_int(iEnt, m_fInSpecialReload, 0, XO_WEAPON)
				return
			}
			
			native_playanim(id, ANIM_START_RELOAD)
			
			set_pdata_float(id, m_flNextAttack, 0.75, XTRA_OFS_PLAYER)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.75, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.75, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.75, XO_WEAPON)
			
			set_pdata_int(iEnt, m_fInSpecialReload, 2, XO_WEAPON)
		}
		case 2: // Insert 
		{
			if(cs_get_weapon_ammo(iEnt) >= H_RIFLE_CLIP || cs_get_user_bpammo(id, CSW_MOSIN) <= 0)
			{
				set_pdata_int(iEnt, m_fInSpecialReload, 4, XO_WEAPON)
				return
			} else {
				set_pdata_int(iEnt, m_fInSpecialReload, 3, XO_WEAPON)
			}
			
			emit_sound(id, CHAN_ITEM, WeaponSounds[2], 1.0, ATTN_NORM, 0, 85 + generate_int(0,0x1f))
			native_playanim(id, ANIM_INSERT)

			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.45, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.45, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.45, XO_WEAPON)
			set_pdata_float(id, m_flNextAttack, 0.45, XTRA_OFS_PLAYER)
		}
		case 3: // Done Insert
		{
			set_pdata_int(iEnt, m_iClip, iClip + 1, XO_WEAPON)
			cs_set_user_bpammo(id, CSW_MOSIN, iBpAmmo-1)
			cs_set_user_bpammo(id, CSW_MOSIN, cs_get_user_bpammo(id, CSW_MOSIN) - 1)
			
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.1, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.1, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.1, XO_WEAPON)
			set_pdata_float(id, m_flNextAttack, 0.1, XTRA_OFS_PLAYER)
			
			set_pdata_int(iEnt, m_fInSpecialReload, 2, XO_WEAPON)
		}
		case 4: // Stop Reload
		{
			native_playanim(id, ANIM_AFTER_RELOAD)

			set_pdata_int(iEnt, m_fInSpecialReload, 0, XO_WEAPON)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.5, XO_WEAPON)
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.5, XO_WEAPON)
			set_pdata_float(id, m_flNextAttack, 1.5, XTRA_OFS_PLAYER)
		}
	}
}
