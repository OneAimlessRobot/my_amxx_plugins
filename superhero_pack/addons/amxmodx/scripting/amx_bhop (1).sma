#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN	"Bhop Abilities"
#define VERSION "0.5.2"
#define AUTHOR	"ConnorMcLeod"

#define MAX_PLAYERS	32

#define OFFSET_CAN_LONGJUMP    356 // VEN
#define BUNNYJUMP_MAX_SPEED_FACTOR 1.7

#define PLAYER_JUMP		6

new g_iCdWaterJumpTime[MAX_PLAYERS+1]
new bool:g_bAlive[MAX_PLAYERS+1]
new bool:g_bAutoBhop[MAX_PLAYERS+1]

new g_pcvarBhopStyle, g_pcvarAutoBhop, g_pcvarFallDamage
new g_pcvarGravity

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_cvar("bhop_abilities", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)
	g_pcvarBhopStyle = register_cvar("bhop_style", "0")  // (1 : no slowdown, 2 : no speed limit)
	g_pcvarAutoBhop = register_cvar("bhop_auto", "0")
	g_pcvarFallDamage = register_cvar("mp_falldamage", "1.0")

	RegisterHam(Ham_Player_Jump, "player", "Player_Jump")
	register_forward(FM_UpdateClientData, "UpdateClientData")
	register_forward(FM_CmdStart, "CmdStart")
	RegisterHam(Ham_Spawn, "player", "Check_Alive", 1)
	RegisterHam(Ham_Killed, "player", "Check_Alive", 1)
	RegisterHam(Ham_TakeDamage, "player", "Ham_TakeDamage_player")

	register_concmd("amx_autobhop", "AdminCmd_Bhop", ADMIN_LEVEL_A, "<nick|#userid> <0|1>")

	g_pcvarGravity = get_cvar_pointer("sv_gravity")
}

public Check_Alive(id)
{
	g_bAlive[id] = bool:is_user_alive(id)
}

public Ham_TakeDamage_player(id, ent, idattacker, Float:damage, damagebits)
{
	if( damagebits != DMG_FALL )
		return HAM_IGNORED

	damage *= get_pcvar_float(g_pcvarFallDamage)
	SetHamParamFloat(4, damage)

	return HAM_HANDLED
}

public CmdStart(id, uc_handle, seed)
{
	if(	g_bAlive[id]
	&&	get_pcvar_num(g_pcvarBhopStyle)
	&&	get_uc(uc_handle, UC_Buttons) & IN_USE
	&&	pev(id, pev_flags) & FL_ONGROUND	)
	{
		static Float:fVelocity[3]
		pev(id, pev_velocity, fVelocity)
		fVelocity[0] *= 0.3
		fVelocity[1] *= 0.3
		fVelocity[2] *= 0.3
		set_pev(id, pev_velocity, fVelocity)
	}
}

public Player_Jump(id)
{
	if( !g_bAlive[id] )
	{
		return
	}
	
	static iBhopStyle ; iBhopStyle = get_pcvar_num(g_pcvarBhopStyle)
	if(!iBhopStyle)
	{
		static iOldButtons ; iOldButtons = pev(id, pev_oldbuttons)
		if( (get_pcvar_num(g_pcvarAutoBhop) || g_bAutoBhop[id]) && iOldButtons & IN_JUMP && pev(id, pev_flags) & FL_ONGROUND)
		{
			iOldButtons &= ~IN_JUMP
			set_pev(id, pev_oldbuttons, iOldButtons)
			set_pev(id, pev_gaitsequence, PLAYER_JUMP)
			set_pev(id, pev_frame, 0.0)
			return
		}
		return
	}

	if( g_iCdWaterJumpTime[id] )
	{
		//client_print(id, print_center, "Water Jump !!!")
		return
	}

	if( pev(id, pev_waterlevel) >= 2 )
	{
		return
	}

	static iFlags ; iFlags = pev(id, pev_flags)
	if( !(iFlags & FL_ONGROUND) )
	{
		return
	}

	static iOldButtons ; iOldButtons = pev(id, pev_oldbuttons)
	if( !get_pcvar_num(g_pcvarAutoBhop) && !g_bAutoBhop[id] && iOldButtons & IN_JUMP )
	{
		return
	}

	// prevent the game from making the player jump
	// as supercede this forward just fails
	set_pev(id, pev_oldbuttons, iOldButtons | IN_JUMP)

	static Float:fVelocity[3]
	pev(id, pev_velocity, fVelocity)

	if(iBhopStyle == 1)
	{
		static Float:fMaxScaledSpeed
		pev(id, pev_maxspeed, fMaxScaledSpeed)
		if(fMaxScaledSpeed > 0.0)
		{
			fMaxScaledSpeed *= BUNNYJUMP_MAX_SPEED_FACTOR
			static Float:fSpeed
			fSpeed = floatsqroot(fVelocity[0]*fVelocity[0] + fVelocity[1]*fVelocity[1] + fVelocity[2]*fVelocity[2])
			if(fSpeed > fMaxScaledSpeed)
			{
				static Float:fFraction
				fFraction = ( fMaxScaledSpeed / fSpeed ) * 0.65
				fVelocity[0] *= fFraction
				fVelocity[1] *= fFraction
				fVelocity[2] *= fFraction
			}
		}
	}

	static Float:fFrameTime, Float:fPlayerGravity
	global_get(glb_frametime, fFrameTime)
	pev(id, pev_gravity, fPlayerGravity)

	new iLJ
	if(	(pev(id, pev_bInDuck) || iFlags & FL_DUCKING)
	&&	get_pdata_int(id, OFFSET_CAN_LONGJUMP)
	&&	pev(id, pev_button) & IN_DUCK
	&&	pev(id, pev_flDuckTime)	)
	{
		static Float:fPunchAngle[3], Float:fForward[3]
		pev(id, pev_punchangle, fPunchAngle)
		fPunchAngle[0] = -5.0
		set_pev(id, pev_punchangle, fPunchAngle)
		global_get(glb_v_forward, fForward)

		fVelocity[0] = fForward[0] * 560
		fVelocity[1] = fForward[1] * 560
		fVelocity[2] = 299.33259094191531084669989858532
		iLJ = 1
	}
	else
	{
		fVelocity[2] = 268.32815729997476356910084024775
	}

	fVelocity[2] -= fPlayerGravity * fFrameTime * 0.5 * get_pcvar_num(g_pcvarGravity)

	set_pev(id, pev_velocity, fVelocity)

	set_pev(id, pev_gaitsequence, PLAYER_JUMP+iLJ)
	set_pev(id, pev_frame, 0.0)
}

public UpdateClientData(id, sendweapons, cd_handle)
{
	g_iCdWaterJumpTime[id] = get_cd(cd_handle, CD_WaterJumpTime)
}

public AdminCmd_Bhop(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2) )
	{
		return PLUGIN_HANDLED
	}

	new szPlayer[32]
	read_argv(1, szPlayer, 31)
	new iPlayer = cmd_target(id, szPlayer, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS)

	if( !iPlayer )
	{
		return PLUGIN_HANDLED
	}

	if( read_argc() < 3 )
	{
		g_bAutoBhop[iPlayer] = !g_bAutoBhop[iPlayer]
	}
	else
	{
		new arg2[2]
		read_argv(2, arg2, 1)
		if(arg2[0] == '1' && !g_bAutoBhop[iPlayer])
		{
			g_bAutoBhop[iPlayer] = true
		}
		else if(arg2[0] == '0' && g_bAutoBhop[iPlayer])
		{
			g_bAutoBhop[iPlayer] = false
		}
	}

	client_print(id, print_console, "Player %s autobhop is currently : %s", szPlayer, g_bAutoBhop[iPlayer] ? "On" : "Off")
	return PLUGIN_HANDLED
}