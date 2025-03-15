#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <zombieplague>

#define PLUGIN "Tactical Knife"
#define VERSION "1.0"
#define AUTHOR "m4m3ts"

#define CSW_TACT CSW_P228
#define weapon_tact "weapon_p228"
#define old_event "events/p228.sc"
#define old_w_model "models/w_p228.mdl"
#define WEAPON_SECRETCODE 4234234


#define RELOAD_TIME 0.435
#define STAB_TIME 1.1
#define ATTACK_TIME 1.0
#define SYSTEM_CLASSNAME "tact_knife"
#define SYSTEM_CLASSNAME2 "tact_knife2"
#define WEAPON_ANIMEXT "grenade"

const PDATA_SAFE = 2
const OFFSET_LINUX_WEAPONS = 4
const OFFSET_WEAPONOWNER = 41
const m_flNextAttack = 83
const m_szAnimExtention = 492

new const v_model[] = "models/v_tknifeex2.mdl"
new const p_model[] = "models/p_tknifeex2.mdl"
new const w_model[] = "models/w_tknifeex2.mdl"
new const ARROW_MODEL[] = "models/tknifeb.mdl"
new const tact_wall[][] = {"weapons/tknife_stone1.wav", "weapons/tknife_stone2.wav"}
new const weapon_sound[4][] = 
{
	"weapons/tknife_shoot1.wav",
	"weapons/tknifeex2_shoot1.wav",
	"weapons/tknifeex2_draw.wav",
	"weapons/tact_hit.wav"
}


new const WeaponResource[4][] = 
{
	"sprites/weapon_tknifeex2.txt",
	"sprites/640hud12.spr",
	"sprites/640hud96.spr",
	"sprites/640hud97.spr"
}

enum
{
	ANIM_IDLE = 0,
	ANIM_SHOOT,
	ANIM_DRAW,
	ANIM_SHOOT2
}

new g_MsgDeathMsg, g_endround

new g_had_tact[33], g_tact_ammo[33], g_Shoot_Count[33]
new g_old_weapon[33], m_iBlood[2]
new sTrail, item_tact, cvar_dmg_slash_tact, cvar_dmg_stab_tact, cvar_ammo_tactical

const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("tact_version", "m4m3ts", FCVAR_SERVER|FCVAR_SPONLY)
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_SetModel, "fw_SetModel")
	register_think(SYSTEM_CLASSNAME, "fw_Think")
	register_think(SYSTEM_CLASSNAME2, "fw_Think")
	register_touch(SYSTEM_CLASSNAME, "*", "fw_touch")
	register_touch(SYSTEM_CLASSNAME2, "*", "fw_touch2")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)	
	RegisterHam(Ham_Spawn, "player", "Player_Spawn", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Item_AddToPlayer, weapon_tact, "fw_AddToPlayer_Post", 1)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	register_clcmd("weapon_tknifeex2", "hook_weapon")
	
	cvar_dmg_slash_tact = register_cvar("zp_tactical_dmg_slash", "61.0")
	cvar_dmg_stab_tact = register_cvar("zp_tactical_dmg_stab", "140.0")
	cvar_ammo_tactical = register_cvar("zp_tactical_ammo", "30")
	
	item_tact = zp_register_extra_item("Triple Tactical Knife", 14, ZP_TEAM_HUMAN)
	
	g_MsgDeathMsg = get_user_msgid("DeathMsg")
	
	g_endround = 1
}


public plugin_precache()
{
	precache_model(v_model)
	precache_model(p_model)
	precache_model(w_model)
	precache_model(ARROW_MODEL)
	
	for(new i = 0; i < sizeof(weapon_sound); i++) 
		precache_sound(weapon_sound[i])
	
	for(new i = 0; i < sizeof(tact_wall); i++)
		precache_sound(tact_wall[i])
	
	precache_generic(WeaponResource[0])
	for(new i = 1; i < sizeof(WeaponResource); i++)
		precache_model(WeaponResource[i])
	
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	sTrail = precache_model("sprites/laserbeam.spr")
}

public zp_user_infected_post(id)
{
	remove_tact(id)
}

public zp_round_started() g_endround = 0
public zp_round_ended() g_endround = 1

public Player_Spawn(id)
{
	remove_tact(id)
}

public fw_PlayerKilled(id)
{
	remove_tact(id)
}

public hook_weapon(id)
{
	engclient_cmd(id, weapon_tact)
	return
}

public zp_extra_item_selected(id, itemid)
{
	if(itemid == item_tact) get_tact(id)
}

public get_tact(id)
{
	if(!is_user_alive(id))
		return
	drop_weapons(id, 1)
	g_had_tact[id] = 1
	g_tact_ammo[id] = get_pcvar_num(cvar_ammo_tactical)
	
	give_item(id, weapon_tact)
	
	static weapon_ent; weapon_ent = fm_find_ent_by_owner(-1, weapon_tact, id)
	if(pev_valid(weapon_ent)) cs_set_weapon_ammo(weapon_ent, 1)
}

public remove_tact(id)
{
	g_had_tact[id] = 0
	g_tact_ammo[id] = 0
}

public refill_tact(id)
{
	g_tact_ammo[id] = get_pcvar_num(cvar_ammo_tactical)
	update_ammo(id)
}
	
public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return FMRES_IGNORED	
	if(get_user_weapon(id) == CSW_TACT && g_had_tact[id])
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public Event_CurWeapon(id)
{
	if(!is_user_alive(id))
		return
		
	if(get_user_weapon(id) == CSW_TACT && g_had_tact[id])
	{
		set_pev(id, pev_viewmodel2, v_model)
		set_pev(id, pev_weaponmodel2, p_model)
		set_pdata_string(id, m_szAnimExtention * 4, WEAPON_ANIMEXT, -1 , 20)
		set_weapon_anim(id, ANIM_DRAW)
		update_ammo(id)
	}
	
	g_old_weapon[id] = get_user_weapon(id)
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return
	if(get_user_weapon(id) != CSW_TACT || !g_had_tact[id])
		return
	
	static ent; ent = fm_get_user_weapon_entity(id, CSW_TACT)
	if(!pev_valid(ent))
		return
	if(get_pdata_float(ent, 46, OFFSET_LINUX_WEAPONS) > 0.0 || get_pdata_float(ent, 47, OFFSET_LINUX_WEAPONS) > 0.0) 
		return
	
	static CurButton
	CurButton = get_uc(uc_handle, UC_Buttons)
	
	if(CurButton & IN_ATTACK)
	{
		CurButton &= ~IN_ATTACK
		set_uc(uc_handle, UC_Buttons, CurButton)
		
		if(g_tact_ammo[id] == 0)
			return
		if(get_pdata_float(id, 83, 5) <= 0.0)
		{
			g_tact_ammo[id]--
			g_Shoot_Count[id] = 0
			update_ammo(id)
			set_task(0.2, "throw_knife", id)
			set_weapon_anim(id, ANIM_SHOOT)
			set_weapons_timeidle(id, CSW_TACT, ATTACK_TIME)
			set_player_nextattackx(id, ATTACK_TIME)
		}
	}
	else if(CurButton & IN_ATTACK2)
	{
		if(get_pdata_float(id, 83, 5) <= 0.0)
		{
			set_weapon_anim(id, ANIM_SHOOT2)
			FireArrow_Charge(id)
			emit_sound(id, CHAN_VOICE, weapon_sound[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_weapons_timeidle(id, CSW_TACT, STAB_TIME)
			set_player_nextattackx(id, STAB_TIME)
		}
	}
}

public throw_knife(id)
{
	FireArrow1(id)
	FireArrow2(id)
	FireArrow3(id)
}

public FireArrow1(id)
{
	static Float:StartOrigin[3], Float:TargetOrigin[3], Float:angles[3], Float:anglestrue[3]
	get_position(id, 2.0, 4.0, -3.0, StartOrigin)

	pev(id,pev_v_angle,angles)
	static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(Ent)) return
	anglestrue[0] = 180.0 - angles[0]
	anglestrue[1] = angles[1]
	anglestrue[2] = angles[2]
	
	// Set info for ent
	set_pev(Ent, pev_movetype, MOVETYPE_TOSS)
	set_pev(Ent, pev_owner, id) // Better than pev_owner
	set_pev(Ent, pev_fuser1, get_gametime() + 4.0)
	set_pev(Ent, pev_nextthink, halflife_time() + 0.1)
	
	entity_set_string(Ent, EV_SZ_classname, SYSTEM_CLASSNAME)
	engfunc(EngFunc_SetModel, Ent, ARROW_MODEL)
	set_pev(Ent, pev_mins, Float:{-0.1, -0.1, -0.1})
	set_pev(Ent, pev_maxs, Float:{0.1, 0.1, 0.1})
	set_pev(Ent, pev_origin, StartOrigin)
	set_pev(Ent, pev_angles, anglestrue)
	set_pev(Ent, pev_gravity, 0.5)
	set_pev(Ent, pev_solid, SOLID_BBOX)
	set_pev(Ent, pev_frame, 0.0)
	
	static Float:Velocity[3]
	get_position(id, 1024.0, 12.0, -12.0, TargetOrigin)
	get_speed_vector(StartOrigin, TargetOrigin, 2300.0, Velocity)
	set_pev(Ent, pev_velocity, Velocity)

	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // Temporary entity ID
	write_short(Ent) // Entity
	write_short(sTrail) // Sprite index
	write_byte(7) // Life
	write_byte(1) // Line width
	write_byte(255) // Red
	write_byte(255) // Green
	write_byte(255) // Blue
	write_byte(65) // Alpha
	message_end() 
}

public FireArrow2(id)
{
	static Float:StartOrigin[3], Float:TargetOrigin[3], Float:angles[3], Float:anglestrue[3]
	get_position(id, 2.0, -4.0, -2.0, StartOrigin)

	pev(id,pev_v_angle,angles)
	static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(Ent)) return
	anglestrue[0] = 180.0 - angles[0]
	anglestrue[1] = angles[1]
	anglestrue[2] = angles[2]
	
	// Set info for ent
	set_pev(Ent, pev_movetype, MOVETYPE_TOSS)
	set_pev(Ent, pev_owner, id) // Better than pev_owner
	set_pev(Ent, pev_fuser1, get_gametime() + 4.0)
	set_pev(Ent, pev_nextthink, halflife_time() + 0.1)
	
	entity_set_string(Ent, EV_SZ_classname, SYSTEM_CLASSNAME)
	engfunc(EngFunc_SetModel, Ent, ARROW_MODEL)
	set_pev(Ent, pev_mins, Float:{-0.1, -0.1, -0.1})
	set_pev(Ent, pev_maxs, Float:{0.1, 0.1, 0.1})
	set_pev(Ent, pev_origin, StartOrigin)
	set_pev(Ent, pev_angles, anglestrue)
	set_pev(Ent, pev_gravity, 0.5)
	set_pev(Ent, pev_solid, SOLID_BBOX)
	set_pev(Ent, pev_frame, 0.0)
	
	static Float:Velocity[3]
	get_position(id, 1024.0, -12.0, -12.0, TargetOrigin)
	get_speed_vector(StartOrigin, TargetOrigin, 2300.0, Velocity)
	set_pev(Ent, pev_velocity, Velocity)

	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // Temporary entity ID
	write_short(Ent) // Entity
	write_short(sTrail) // Sprite index
	write_byte(7) // Life
	write_byte(1) // Line width
	write_byte(255) // Red
	write_byte(255) // Green
	write_byte(255) // Blue
	write_byte(65) // Alpha
	message_end() 
}

public FireArrow3(id)
{
	static Float:StartOrigin[3], Float:TargetOrigin[3], Float:angles[3], Float:anglestrue[3]
	get_position(id, 2.0, 2.0, 4.0, StartOrigin)

	pev(id,pev_v_angle,angles)
	static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(Ent)) return
	anglestrue[0] = 180.0 - angles[0]
	anglestrue[1] = angles[1]
	anglestrue[2] = angles[2]
	
	// Set info for ent
	set_pev(Ent, pev_movetype, MOVETYPE_TOSS)
	set_pev(Ent, pev_owner, id) // Better than pev_owner
	set_pev(Ent, pev_fuser1, get_gametime() + 4.0)
	set_pev(Ent, pev_nextthink, halflife_time() + 0.1)
	
	entity_set_string(Ent, EV_SZ_classname, SYSTEM_CLASSNAME)
	engfunc(EngFunc_SetModel, Ent, ARROW_MODEL)
	set_pev(Ent, pev_mins, Float:{-0.1, -0.1, -0.1})
	set_pev(Ent, pev_maxs, Float:{0.1, 0.1, 0.1})
	set_pev(Ent, pev_origin, StartOrigin)
	set_pev(Ent, pev_angles, anglestrue)
	set_pev(Ent, pev_gravity, 0.5)
	set_pev(Ent, pev_solid, SOLID_BBOX)
	set_pev(Ent, pev_frame, 0.0)
	
	static Float:Velocity[3]
	get_position(id, 1024.0, 12.0, 12.0, TargetOrigin)
	get_speed_vector(StartOrigin, TargetOrigin, 2300.0, Velocity)
	set_pev(Ent, pev_velocity, Velocity)

	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // Temporary entity ID
	write_short(Ent) // Entity
	write_short(sTrail) // Sprite index
	write_byte(7) // Life
	write_byte(1) // Line width
	write_byte(255) // Red
	write_byte(255) // Green
	write_byte(255) // Blue
	write_byte(65) // Alpha
	message_end() 
}

public FireArrow_Charge(id)
{
	static Float:StartOrigin[3], Float:TargetOrigin[3], Float:angles[3]
	get_position(id, 2.0, 0.0, 0.0, StartOrigin)

	pev(id,pev_angles,angles)
	static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(Ent)) return
	
	// Set info for ent
	set_pev(Ent, pev_movetype, MOVETYPE_FLY)
	set_pev(Ent, pev_owner, id) // Better than pev_owner
	set_pev(Ent, pev_rendermode, kRenderTransAdd)
	set_pev(Ent, pev_renderamt, 1.0)
	set_pev(Ent, pev_fuser1, get_gametime() + 0.1)
	set_pev(Ent, pev_nextthink, halflife_time() + 0.1)
	
	entity_set_string(Ent, EV_SZ_classname, SYSTEM_CLASSNAME2)
	engfunc(EngFunc_SetModel, Ent, ARROW_MODEL)
	set_pev(Ent, pev_mins, Float:{-0.1, -0.1, -0.1})
	set_pev(Ent, pev_maxs, Float:{0.1, 0.1, 0.1})
	set_pev(Ent, pev_origin, StartOrigin)
	set_pev(Ent, pev_angles, angles)
	set_pev(Ent, pev_gravity, 0.01)
	set_pev(Ent, pev_solid, SOLID_BBOX)
	set_pev(Ent, pev_frame, 0.0)
	
	static Float:Velocity[3]
	fm_get_aim_origin(id, TargetOrigin)
	get_speed_vector(StartOrigin, TargetOrigin, 800.0, Velocity)
	set_pev(Ent, pev_velocity, Velocity)
}

public fw_Think(ent)
{
	if(!pev_valid(ent)) 
		return
	
	static Float:fFrame; pev(ent, pev_frame, fFrame)
	
	fFrame += 1.5
	fFrame = floatmin(21.0, fFrame)
	
	set_pev(ent, pev_frame, fFrame)
	set_pev(ent, pev_nextthink, get_gametime() + 0.05)
	
	// time remove
	static Float:fTimeRemove, Float:Amount
	pev(ent, pev_fuser1, fTimeRemove)
	pev(ent, pev_renderamt, Amount)
	
	if(get_gametime() >= fTimeRemove) 
	{
		remove_entity(ent)
	}
}



public fw_touch(Ent, Id)
{
	// If ent is valid
	if(!pev_valid(Ent))
		return
	static Owner; Owner = pev(Ent, pev_owner)
	if(pev(Ent, pev_movetype) == MOVETYPE_NONE)
		return
	static classnameptd[32]
	pev(Id, pev_classname, classnameptd, 31)
	if (equali(classnameptd, "func_breakable")) ExecuteHamB( Ham_TakeDamage, Id, 0, 0, 60.0, DMG_GENERIC )
	Damage_tact(Ent, Id)
	
	// Get it's origin
	new Float:originF[3]
	pev(Ent, pev_origin, originF)
	// Alive...
	
	if(is_user_alive(Id) && zp_get_user_zombie(Id))
	{
		remove_entity(Ent)
		create_blood(originF)
		create_blood(originF)
		emit_sound(Id, CHAN_BODY, weapon_sound[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	else if(is_user_alive(Id) && !zp_get_user_zombie(Id))
	{
		remove_entity(Ent)
		emit_sound(Id, CHAN_VOICE, weapon_sound[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	else
	{
		set_pev(Ent, pev_fuser1, get_gametime() + 1.0)
		make_bullet(Owner, originF)
		engfunc(EngFunc_EmitSound, Ent, CHAN_WEAPON, tact_wall[random( sizeof(tact_wall))], 1.0, ATTN_STATIC, 0, PITCH_NORM)
		set_pev(Ent, pev_movetype, MOVETYPE_NONE)
		set_pev(Ent, pev_solid, SOLID_NOT)
	}
}

public fw_touch2(Ent, Id)
{
	// If ent is valid
	if(!pev_valid(Ent))
		return
	if(pev(Ent, pev_movetype) == MOVETYPE_NONE)
		return
	
	static classnameptd[32]
	pev(Id, pev_classname, classnameptd, 31)
	if (equali(classnameptd, "func_breakable")) ExecuteHamB( Ham_TakeDamage, Id, 0, 0, 200.0, DMG_GENERIC )
	Damage_tact2(Ent, Id)
	
	// Get it's origin
	new Float:originF[3]
	pev(Ent, pev_origin, originF)
	// Alive...
	
	if(is_user_alive(Id) && zp_get_user_zombie(Id))
	{
		remove_entity(Ent)
		create_blood(originF)
		create_blood(originF)
		emit_sound(Id, CHAN_BODY, weapon_sound[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	else if(is_user_alive(Id) && !zp_get_user_zombie(Id))
	{
		remove_entity(Ent)
		emit_sound(Id, CHAN_VOICE, weapon_sound[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	else
	{
		engfunc(EngFunc_EmitSound, Ent, CHAN_WEAPON, tact_wall[random( sizeof(tact_wall))], 1.0, ATTN_STATIC, 0, PITCH_NORM)
		set_pev(Ent, pev_movetype, MOVETYPE_NONE)
		set_pev(Ent, pev_solid, SOLID_NOT)
	}
}
		
public Remove_tactBall(Ent)
{
	if(!pev_valid(Ent)) return
	engfunc(EngFunc_RemoveEntity, Ent)
}

public Damage_tact(Ent, Id)
{
	static Owner; Owner = pev(Ent, pev_owner)
	static Attacker; 
	if(!is_user_alive(Owner)) 
	{
		Attacker = 0
		return
	} else Attacker = Owner
	
	if(g_endround)
		return

	new bool:bIsHeadShot; // never make that one static
	new Float:flAdjustedDamage, bool:death

	switch( Get_MissileWeaponHitGroup(Ent) ) 
	{
		case HIT_GENERIC: flAdjustedDamage = get_pcvar_float(cvar_dmg_slash_tact) * 1.5
		case HIT_CHEST: flAdjustedDamage = get_pcvar_float(cvar_dmg_slash_tact) * 1.0 
		case HIT_STOMACH: flAdjustedDamage = get_pcvar_float(cvar_dmg_slash_tact) * 1.0 
		case HIT_LEFTLEG, HIT_RIGHTLEG: flAdjustedDamage = get_pcvar_float(cvar_dmg_slash_tact) * 0.75 
		case HIT_LEFTARM, HIT_RIGHTARM: flAdjustedDamage = get_pcvar_float(cvar_dmg_slash_tact) * 0.35 
		case HIT_HEAD:
		{
			flAdjustedDamage = get_pcvar_float(cvar_dmg_slash_tact) * 2.50
			bIsHeadShot = true;
		}
	}
	if(pev(Id, pev_health) <= flAdjustedDamage) death = true 
	
	if(is_user_alive(Id))
	{
		if( bIsHeadShot && death)
		{
			emessage_begin(MSG_BROADCAST, g_MsgDeathMsg)
			ewrite_byte(Attacker)
			ewrite_byte(Id)
			ewrite_byte(1)
			ewrite_string("Triple Tactical Knife")
			emessage_end()
			
			set_msg_block(g_MsgDeathMsg, BLOCK_SET)
			user_silentkill(Id)
			set_msg_block(g_MsgDeathMsg, BLOCK_NOT)

			death = false
		}
		else ExecuteHamB(Ham_TakeDamage, Id, Ent, Attacker, flAdjustedDamage, DMG_BULLET)
	}
}

public Damage_tact2(Ent, Id)
{
	static Owner; Owner = pev(Ent, pev_owner)
	static Attacker; 
	if(!is_user_alive(Owner)) 
	{
		Attacker = 0
		return
	} else Attacker = Owner
	
	if(g_endround)
		return
	
	new bool:bIsHeadShot; // never make that one static
	new Float:flAdjustedDamage, bool:death

	switch( Get_MissileWeaponHitGroup(Ent) ) 
	{
		case HIT_GENERIC: flAdjustedDamage = get_pcvar_float(cvar_dmg_stab_tact) * 1.5 
		case HIT_CHEST: flAdjustedDamage = get_pcvar_float(cvar_dmg_stab_tact) * 1.0 
		case HIT_STOMACH: flAdjustedDamage = get_pcvar_float(cvar_dmg_stab_tact) * 1.0 
		case HIT_LEFTLEG, HIT_RIGHTLEG: flAdjustedDamage = get_pcvar_float(cvar_dmg_stab_tact) * 0.75 
		case HIT_LEFTARM, HIT_RIGHTARM: flAdjustedDamage = get_pcvar_float(cvar_dmg_stab_tact) * 0.35 
		case HIT_HEAD:
		{
			flAdjustedDamage = get_pcvar_float(cvar_dmg_stab_tact) * 2.50
			bIsHeadShot = true;
		}
	}
	if(pev(Id, pev_health) <= flAdjustedDamage) death = true 
	
	if(is_user_alive(Id))
	{
		if( bIsHeadShot && death)
		{
			emessage_begin(MSG_BROADCAST, g_MsgDeathMsg)
			ewrite_byte(Attacker)
			ewrite_byte(Id)
			ewrite_byte(1)
			ewrite_string("Triple Tactical Knife")
			emessage_end()
			
			set_msg_block(g_MsgDeathMsg, BLOCK_SET)
			user_silentkill(Id)
			set_msg_block(g_MsgDeathMsg, BLOCK_NOT)

			death = false
		}
		else ExecuteHamB(Ham_TakeDamage, Id, Ent, Attacker, flAdjustedDamage, DMG_BULLET)
	}
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
	
	if(equal(model, old_w_model))
	{
		static weapon
		weapon = fm_get_user_weapon_entity(entity, CSW_TACT)
		
		if(!pev_valid(weapon))
			return FMRES_IGNORED
		
		if(g_had_tact[id])
		{
			set_pev(weapon, pev_impulse, WEAPON_SECRETCODE)
			set_pev(weapon, pev_iuser4, g_tact_ammo[id])
			engfunc(EngFunc_SetModel, entity, w_model)
			
			g_had_tact[id] = 0
			g_tact_ammo[id] = 0
			
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED;
}

public fw_AddToPlayer_Post(ent, id)
{
	if(pev(ent, pev_impulse) == WEAPON_SECRETCODE)
	{
		g_had_tact[id] = 1
		g_tact_ammo[id] = pev(ent, pev_iuser4)
		
		set_pev(ent, pev_impulse, 0)
	}			
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("WeaponList"), _, id)
	write_string((g_had_tact[id] == 1 ? "weapon_tknifeex2" : "weapon_p228"))
	write_byte(1)
	write_byte(52)
	write_byte(-1)
	write_byte(-1)
	write_byte(1)
	write_byte(3)
	write_byte(CSW_TACT)
	write_byte(0)
	message_end()
}

public update_ammo(id)
{
	if(!is_user_alive(id))
		return
	
	static weapon_ent; weapon_ent = fm_find_ent_by_owner(-1, weapon_tact, id)
	if(pev_valid(weapon_ent)) cs_set_weapon_ammo(weapon_ent, 1)	
	
	cs_set_user_bpammo(id, CSW_P228, 0)
	
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), {0, 0, 0}, id)
	write_byte(1)
	write_byte(CSW_TACT)
	write_byte(-1)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, id)
	write_byte(1)
	write_byte(g_tact_ammo[id])
	message_end()
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

stock set_weapon_anim(id, anim)
{
	if(!is_user_alive(id))
		return
	
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
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
	write_byte(8)
	message_end()
}

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)
	 
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
		  
		if (dropwhat == 1 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM))
		{
			static wname[32]
			get_weaponname(weaponid, wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	static Float:num; num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock Get_MissileWeaponHitGroup( iEnt )
{
	new Float:flStart[ 3 ], Float:flEnd[ 3 ];
	
	pev( iEnt, pev_origin, flStart );
	pev( iEnt, pev_velocity, flEnd );
	xs_vec_add( flStart, flEnd, flEnd );
	
	new ptr = create_tr2();
	engfunc( EngFunc_TraceLine, flStart, flEnd, 0, iEnt, ptr );
	
	new iHitGroup
	iHitGroup = get_tr2( ptr, TR_iHitgroup )
	free_tr2( ptr );
	
	return iHitGroup;
}

stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs, vUp) //for player
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle, ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock set_weapons_timeidle(id, WeaponId ,Float:TimeIdle)
{
	if(!is_user_alive(id))
		return
		
	static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId)
	if(!pev_valid(entwpn)) 
		return
		
	set_pdata_float(entwpn, 46, TimeIdle, OFFSET_LINUX_WEAPONS)
	set_pdata_float(entwpn, 47, TimeIdle, OFFSET_LINUX_WEAPONS)
	set_pdata_float(entwpn, 48, TimeIdle + 0.5, OFFSET_LINUX_WEAPONS)
}

stock set_player_nextattackx(id, Float:nexttime)
{
	if(!is_user_alive(id))
		return
		
	set_pdata_float(id, m_flNextAttack, nexttime, 5)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
