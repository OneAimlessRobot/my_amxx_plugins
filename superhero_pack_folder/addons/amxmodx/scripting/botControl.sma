#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <fun>

#if !defined MAX_PLAYERS
#define MAX_PLAYERS				32
#endif

#define fm_user_has_shield(%1)			(get_pdata_int(%1, OFFSET_SHIELD) & HAS_SHIELD)
#define fm_get_user_team(%1)			get_pdata_int(%1, OFFSET_TEAM)
#define fm_set_user_team(%1,%2)			set_pdata_int(%1, OFFSET_TEAM, %2)  

#define OFFSET_SHIELD				510
#define HAS_SHIELD				(1<<24)

#define m_rgAmmo_player_Slot0			376
#define OFFSET_TEAM				114
#define OFFSET_ARMOR_TYPE    			112
#define m_iClip					51
#define m_iPrimaryAmmoType			49
#define XTRA_OFS_PLAYER  			5
#define XTRA_OFS_WEAPON				4
#define OBS_IN_EYE 				4

#define TERRORISTS				1
#define CTS					2

#define MAX_GLOCK18_BPAMMO			40
#define MAX_USP_BPAMMO				24

new const Float:g_fSizes[][3] =
{ 
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}

const INVALID_WEAPONS =				(1 << CSW_KNIFE)|(1 << CSW_C4)|(1 << CSW_HEGRENADE)|(1 << CSW_FLASHBANG)|(1 << CSW_SMOKEGRENADE)

new const g_szDefaultTag[] =			"*BOT*"
new const g_szNameChange[] = 			"#Cstrike_Name_Change"

new bool:g_bRoundEnded
new g_forForwardHandlePre, g_forForwardHandlePost, g_iReturn

new pCvarMaxControls, pCvarControlSettings, pCvarControlFlags

new g_iUserControlledBots[MAX_PLAYERS + 1]
new g_iPlayerDefaultTeam[MAX_PLAYERS + 1]
new g_iPlayerDefaultMoney[MAX_PLAYERS + 1]
new g_szDefaultName[MAX_PLAYERS + 1][MAX_PLAYERS]

public plugin_init()
{
	static const Version[] = "1.1"
	register_plugin("Bot Control", Version, "SPiNX/EFFEX little touch") 

	register_cvar("botcontrol_version", Version, FCVAR_SERVER|FCVAR_SPONLY)
	
	pCvarMaxControls =		register_cvar("bcontrol_limit", "1")
	pCvarControlSettings =		register_cvar("bcontrol_settings", "1") 
	// 0 = no control | 1 = teammates only | 2 = only specified flags | 3 = control every bot
	pCvarControlFlags =		register_cvar("bcontrol_flags", "b")
	
	g_forForwardHandlePre = CreateMultiForward("client_controlled_pre", ET_CONTINUE, FP_CELL, FP_CELL)
	g_forForwardHandlePost = CreateMultiForward("client_controlled_post", ET_IGNORE, FP_CELL, FP_CELL)
	
	register_forward(FM_CmdStart, "CmdStart", ._post=true)
	register_forward(FM_ClientUserInfoChanged, "forward_client_userinfochanged")
	
	register_logevent("joinTeam", 3, "1=joined team")
	register_logevent("roundEnd", 2, "1=Round_End")
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("TextMsg", "event_round_restart", "a", "2&#Game_C", "2&#Game_w")
	register_event("DeathMsg", "event_death", "a")
	register_message(get_user_msgid("SayText"), "message_SayText")
}

public message_SayText(iMsg, MSG_DEST, id)
{
	static id;id = get_msg_arg_int(1)
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE
		
	static sBuffer[MAX_PLAYERS]
	get_msg_arg_string(2, sBuffer, charsmax(sBuffer))
	
	static szName[MAX_PLAYERS]
	get_user_name(id, szName, charsmax(szName))
	if(equal(sBuffer, g_szNameChange) && (containi(szName, g_szDefaultTag) != -1))
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public forward_client_userinfochanged(id, buffer) 
{
	static szOldName[MAX_PLAYERS], szNewName[MAX_PLAYERS]
	get_user_name(id, szOldName, charsmax(szOldName))
	engfunc(EngFunc_InfoKeyValue, buffer, "name", szNewName, charsmax(szNewName))
	if(is_user_alive(id) && (containi(szNewName, g_szDefaultTag) == -1) && (g_iUserControlledBots[id] > 0))
	{
		format(szNewName, charsmax(szNewName), "%s %s", g_szDefaultTag, szNewName)
		set_user_info(id, "name", szNewName)
		return FMRES_SUPERCEDE
	}
	
	if(!is_user_alive(id) && containi(szOldName, g_szDefaultTag) != -1)
		return FMRES_SUPERCEDE

	return FMRES_IGNORED
}

public client_putinserver(id)
{
	g_iPlayerDefaultMoney[id] = 0
	g_iUserControlledBots[id] = 0
	g_iPlayerDefaultTeam[id] = 0
	
	arrayset(g_szDefaultName[id], 0, sizeof g_szDefaultName[])
}

public event_death()
{
	new iVictim = read_data(2)
	if(is_user_connected(iVictim) && (g_iUserControlledBots[iVictim] > 0))
	{
		set_user_info(iVictim, "name", g_szDefaultName[iVictim])
		
		if(g_iPlayerDefaultMoney[iVictim] > 0)
		{
			cs_set_user_money(iVictim, g_iPlayerDefaultMoney[iVictim])
			g_iPlayerDefaultMoney[iVictim] = 0
		}
		fm_set_user_team(iVictim, g_iPlayerDefaultTeam[iVictim])
		updateTeamInfo(iVictim, (g_iPlayerDefaultTeam[iVictim] == TERRORISTS) ? "TERRORIST" : "CT")
	}
}

public joinTeam() 
{
	new szLogUser[80], szName[MAX_PLAYERS]
	read_logargv(0, szLogUser, charsmax(szLogUser))
	parse_loguser(szLogUser, szName, charsmax(szName))

	new szTeam[2], iPlayer = get_user_index(szName)
	read_logargv(2, szTeam, charsmax(szTeam))
	switch(szTeam[0])
	{
		case 'T' :	g_iPlayerDefaultTeam[iPlayer] = TERRORISTS
		case 'C' :	g_iPlayerDefaultTeam[iPlayer] = CTS
		case 'S' :	g_iPlayerDefaultTeam[iPlayer] = 0
	}
} 

public event_round_restart()
{
	static iPlayers[MAX_PLAYERS]
	new iNum
	get_players(iPlayers, iNum)
	for(new i, iPlayer;i < iNum;i++)
	{
		g_iPlayerDefaultMoney[(iPlayer = iPlayers[i])] = 0
		g_iUserControlledBots[iPlayer] = 0
	}
}
	
public event_round_start()
{
	g_bRoundEnded = false
	
	static iPlayers[MAX_PLAYERS]
	new iNum
	get_players(iPlayers, iNum)
	for(new i, iPlayer, iTeam;i < iNum;i++)
	{
		iPlayer = iPlayers[i]
		if(g_iUserControlledBots[iPlayer] > 0)
		{
			iTeam = g_iPlayerDefaultTeam[iPlayer]
			
			set_user_info(iPlayer, "name", g_szDefaultName[iPlayer])
			ExecuteForward(g_forForwardHandlePre, g_iReturn, iPlayer, 0)	
			if((g_iReturn != PLUGIN_HANDLED) && is_user_alive(iPlayer))
			{
				set_user_armor(iPlayer, 0)
				set_user_default_weapons(iPlayer, (iTeam == TERRORISTS))
				cs_set_user_defuse(iPlayer, 0)
				
				if(g_iPlayerDefaultMoney[iPlayer] > 0)
				{
					cs_set_user_money(iPlayer, g_iPlayerDefaultMoney[iPlayer])
				}
				
				fm_set_user_team(iPlayer, iTeam)
				updateTeamInfo(iPlayer)
				cs_reset_user_model(iPlayer)
			}

			g_iUserControlledBots[iPlayer] = 0
			g_iPlayerDefaultMoney[iPlayer] = 0
			arrayset(g_szDefaultName[iPlayer], 0, sizeof g_szDefaultName[])
		}
	}
}

public roundEnd()
{
	g_bRoundEnded = true
}

public CmdStart(iPlayer, userCmdHandle, randomSeed) 
{
	if(is_user_alive(iPlayer) || !(TERRORISTS <= get_user_team(iPlayer) <= CTS))
		return FMRES_IGNORED

	if(g_bRoundEnded)
		return FMRES_IGNORED
			
	static iButton;iButton = get_uc(userCmdHandle, UC_Buttons)
	if((iButton & IN_USE) && (pev(iPlayer, pev_iuser1) == OBS_IN_EYE))
	{
		if(g_iUserControlledBots[iPlayer] >= get_pcvar_num(pCvarMaxControls))
			return FMRES_IGNORED
		
		manageControl(iPlayer)
		set_uc(userCmdHandle, UC_Buttons, (iButton & ~IN_USE) & ~IN_USE)
		return FMRES_IGNORED
	}
	return FMRES_IGNORED
}

manageControl(iPlayer)
{
	static iBotIdentity;iBotIdentity = entity_get_int(iPlayer, EV_INT_iuser2)
	if(is_user_bot(iBotIdentity))
	{
		static pCvarControlSett;pCvarControlSett = get_pcvar_num(pCvarControlSettings)
		if(!pCvarControlSett)
			return PLUGIN_HANDLED
			
		if((pCvarControlSett == 1) && (g_iPlayerDefaultTeam[iPlayer] != get_user_team(iBotIdentity)))
			return PLUGIN_HANDLED
		
		static szFlags[2]
		get_pcvar_string(pCvarControlFlags, szFlags, charsmax(szFlags))
		if((pCvarControlSett == 2) && !(get_user_flags(iPlayer) & read_flags(szFlags)))
			return PLUGIN_HANDLED
		
		static Float:fPlane[3], Float:fOrigin[3], Float:fVelocity[3]
		entity_get_vector(iBotIdentity, EV_VEC_angles, fPlane)
		entity_get_vector(iBotIdentity, EV_VEC_origin, fOrigin)
		entity_get_vector(iBotIdentity, EV_VEC_velocity, fVelocity)
		
		if(!g_iPlayerDefaultMoney[iPlayer])
		{
			g_iPlayerDefaultMoney[iPlayer] = cs_get_user_money(iPlayer)
		}
	
		fm_set_user_team(iPlayer, get_user_team(iBotIdentity))
		updateTeamInfo(iPlayer)

		ExecuteHamB(Ham_CS_RoundRespawn, iPlayer)
		attach_view(iPlayer, iBotIdentity)
		
		entity_set_vector(iPlayer, EV_VEC_origin, fOrigin)
		entity_set_vector(iPlayer, EV_VEC_angles, fPlane)
		entity_set_vector(iPlayer, EV_VEC_velocity, fVelocity)
		entity_set_vector(iBotIdentity, EV_VEC_origin, Float:{9999.0, 9999.0, 9999.0})
		
		checkPlayerInvalidOrigin(iPlayer)
		
		static szPlayerModel[64]
		cs_get_user_model(iBotIdentity, szPlayerModel, charsmax(szPlayerModel))
		cs_set_user_model(iPlayer, szPlayerModel)

		ExecuteForward(g_forForwardHandlePre, g_iReturn, iPlayer, iBotIdentity)	
		if(g_iReturn != PLUGIN_HANDLED)
		{
			strip_user_weapons(iPlayer)
			give_item(iPlayer, "weapon_knife")
		
			static szWeaponName[20]
			for(new iWeapon = CSW_P228, iAmmoType, iAmmo, iMagazine;iWeapon <= CSW_P90; iWeapon++)
			{
				if(INVALID_WEAPONS & (1 << iWeapon))
					continue
			
				if(user_has_weapon(iBotIdentity, iWeapon))
				{
					get_weaponname(iWeapon, szWeaponName, charsmax(szWeaponName))
					
					new iWeaponEntity = find_ent_by_owner(-1, szWeaponName, iBotIdentity)
					if(iWeaponEntity > 0)
					{
						iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(iWeaponEntity, m_iPrimaryAmmoType, XTRA_OFS_WEAPON)
						iAmmo = get_pdata_int(iWeaponEntity, m_iClip, XTRA_OFS_WEAPON)
						iMagazine = get_pdata_int(iBotIdentity, iAmmoType, XTRA_OFS_PLAYER)
						
						give_item(iPlayer, szWeaponName)
						set_pdata_int(iPlayer, iAmmoType, iMagazine, XTRA_OFS_PLAYER)
						set_pdata_int(iWeaponEntity, m_iClip, iAmmo, XTRA_OFS_WEAPON)
					}
				}
			}
			
			if(fm_user_has_shield(iBotIdentity))
			{
				give_item(iPlayer, "weapon_shield")
			}
			
			if(cs_get_user_defuse(iBotIdentity))
			{
				cs_set_user_defuse(iPlayer, 1)
			}
			
			if(user_has_weapon(iBotIdentity, CSW_C4))
			{
				fm_transfer_user_gun(iBotIdentity, iPlayer, CSW_C4)
			}
			
			static iArmorType;iArmorType = get_pdata_int(iBotIdentity, OFFSET_ARMOR_TYPE)
			cs_set_user_armor(iPlayer, get_user_armor(iBotIdentity), CsArmorType:iArmorType)
			set_user_health(iPlayer, get_user_health(iBotIdentity))
			cs_set_user_money(iPlayer, cs_get_user_money(iBotIdentity))
		}
		ExecuteForward(g_forForwardHandlePost, g_iReturn, iPlayer, iBotIdentity)	
		attach_view(iPlayer, iPlayer)
		user_silentkill(iBotIdentity, 1)
		
		g_iUserControlledBots[iPlayer]++
		
		static szName[MAX_PLAYERS], szBotName[MAX_PLAYERS]
		get_user_name(iPlayer, szName, charsmax(szName))
		get_user_name(iBotIdentity, szBotName, charsmax(szBotName))
		ColorChat(iPlayer, "^x04[Bot Control]^x01: You successfully took ^x04%s^x01's place.", szBotName)
		
		if(containi(szName, g_szDefaultTag) == -1)
		{
			g_szDefaultName[iPlayer] = szName
			format(szName, charsmax(szName), "%s %s", g_szDefaultTag, szName)
			set_user_info(iPlayer, "name", szName)
		}
	}	
	return PLUGIN_CONTINUE
}

ColorChat(const id, const input[], any:...) 
{
	new iNum = 1, iPlayers[MAX_PLAYERS]
	
	static szMsg[192]
	vformat(szMsg, charsmax(szMsg), input, 3)
	
	replace_all(szMsg, charsmax(szMsg), "!g", "^4" )
	replace_all(szMsg, charsmax(szMsg), "!n", "^1" )
	replace_all(szMsg, charsmax(szMsg), "!t", "^3" )
   
	if(id) 	iPlayers[0] = id
	else 	get_players(iPlayers, iNum, "ch" )
		
	for(new i, iPlayer; i < iNum;i++)
	{
		iPlayer = iPlayers[i]
		
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, iPlayer)  
		write_byte(iPlayer)
		write_string(szMsg)
		message_end()
	}
}

updateTeamInfo(iPlayer, szTeam[10] = "")
{
	if(!szTeam[0]) szTeam = (g_iPlayerDefaultTeam[iPlayer] == TERRORISTS) ? "CT" : "TERRORIST"
	
	static iMsgTeamInfo
	if(iMsgTeamInfo || (iMsgTeamInfo = get_user_msgid("TeamInfo")))
	{
		emessage_begin(MSG_ALL, iMsgTeamInfo)
		ewrite_byte(iPlayer)
		ewrite_string(szTeam)
		emessage_end()
	}
}

set_user_default_weapons(iPlayer, bIsTerrorist)
{
	strip_user_weapons(iPlayer)
	give_item(iPlayer, "weapon_knife")
	give_item(iPlayer, bIsTerrorist ? "weapon_glock18" : "weapon_usp")
	cs_set_user_bpammo(iPlayer, bIsTerrorist ? CSW_GLOCK18 : CSW_USP, bIsTerrorist ? MAX_GLOCK18_BPAMMO : MAX_USP_BPAMMO)
}

checkPlayerInvalidOrigin(playerid)
{
	new Float:fOrigin[3], Float:fMins[3], Float:fVec[3]
	pev(playerid, pev_origin, fOrigin)
	
	new hull = (pev(playerid, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	if(is_hull_vacant(fOrigin, hull)) 
	{
		engfunc(EngFunc_SetOrigin, playerid, fOrigin)
		return
	}
	else
	{
		pev(playerid, pev_mins, fMins)
		fVec[2] = fOrigin[2]
		
		for(new i; i < sizeof g_fSizes; i++)
		{
			fVec[0] = fOrigin[0] - fMins[0] * g_fSizes[i][0]
			fVec[1] = fOrigin[1] - fMins[1] * g_fSizes[i][1]
			fVec[2] = fOrigin[2] - fMins[2] * g_fSizes[i][2]
			if(is_hull_vacant(fVec, hull))
			{
				engfunc(EngFunc_SetOrigin, playerid, fVec)
				set_pev(playerid, pev_velocity, Float:{0.0, 0.0, 0.0})
				break
			}
		}
	}
}

is_hull_vacant(const Float:origin[3], hull)
{
	new tr = 0
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, tr)
	if(!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen))
		return true
	
	return false
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
