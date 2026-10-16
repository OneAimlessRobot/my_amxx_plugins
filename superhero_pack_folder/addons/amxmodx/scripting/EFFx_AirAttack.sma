#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <xs>

#define PLUGIN 					"Air Attack"
#define VERSION 				"1.0"
#define AUTHOR 					"EFFx"

#define EXPLOSION_MULTIPLIER			2.0
#define IMPULSE_EXPLOSION_RADIUS		500.0
#define EXPLOSION_RADIUS			900.0

#define PLANE_ID				3312317732018

#define fixedUnsigned16(%1,%2) 			clamp(floatround(%1 * %2), 0, 0xFFFF)
#define message_begin_fl(%1,%2) 		engfunc(EngFunc_MessageBegin, %1, SVC_TEMPENTITY, %2, 0)
#define write_coord_fl(%1) 			engfunc(EngFunc_WriteCoord, %1)

new const g_szPlaneModel[] =			"models/airattack/airattack_plane.mdl"
new const g_szStrikesModel[] =			"models/airattack/airattack_nuke.mdl"

new const g_szNukeExplosionClose[] =		"airattack/nuke_explode_close.wav"
new const g_szNukeExplosionFar[] =		"airattack/nuke_explode_far.wav"
new const g_szNukeDoppler[] =			"airattack/nuke_doppler.wav"
new const g_szAirAttackBegin[] =			"airattack/airattack_begin.wav"
new const g_szAirAttackCoordinatesLasers[] = 	"airattack/airattack_coordinates_lasers.wav"
new const g_szAirAttackCoordinatesBeep[] = 	"airattack/airattack_coordinates_beeps.wav"
new const g_szAirAttackDialogue[] = 		"airattack/airattack_dialogue.wav"
new const g_szAirAttackPlaneRemove[] =		"airattack/airattack_planeremove.wav"
new const g_szAirAttackPlaneTakeoff[] =		"airattack/airattack_planetakeoff.wav"

new const g_szStrikesClassName[] =		"airattack_nuke"
new const g_szPlaneClassName[] = 		"airattack_plane"
	
new g_mMessageScreenFade, g_mMessageScreenShake

new Float:g_fMaxZ, Float:g_fStartOrigin[3], Float:g_fPlaneVelocity[3], bool:g_bStarted
new g_iAttackLevel, g_iPlaneEntityID, g_iNukeEntityID
new g_iExplosionSprite, g_iParticlesSprite, g_iSprite, g_iTrailSprite

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_fMaxZ = getMaxZ()
	
	g_mMessageScreenFade = get_user_msgid("ScreenFade")
	g_mMessageScreenShake = get_user_msgid("ScreenShake")
	
	register_forward(FM_Touch, "planeTouch")
	register_forward(FM_AddToFullPack, "forward_AddToFullPack", 1)
	
	register_clcmd("amx_start_event", "cmdStartEvent", ADMIN_KICK)
}

public plugin_precache()
{
	precache_model(g_szPlaneModel)
	precache_model(g_szStrikesModel)
	
	precache_sound(g_szNukeExplosionClose)
	precache_sound(g_szNukeExplosionFar)
	precache_sound(g_szNukeDoppler)
	precache_sound(g_szAirAttackBegin)
	precache_sound(g_szAirAttackCoordinatesLasers)
	precache_sound(g_szAirAttackCoordinatesBeep)
	precache_sound(g_szAirAttackDialogue)
	precache_sound(g_szAirAttackPlaneRemove)
	precache_sound(g_szAirAttackPlaneTakeoff)
	
	g_iTrailSprite = 	precache_model("sprites/smoke.spr")
	g_iParticlesSprite =	precache_model("sprites/explode1.spr")
	g_iSprite = 		precache_model("sprites/laserbeam.spr")
	g_iExplosionSprite = 	precache_model("sprites/shockwave.spr")
}

public planeTouch(iTouched, iToucher)
{
	static szNukeClass[32]
	pev(iToucher, pev_classname, szNukeClass, charsmax(szNukeClass))
	if(equal(szNukeClass, g_szStrikesClassName) && pev(iTouched, pev_solid) >= SOLID_BBOX)
	{
		static Float:fOrigin[3], Float:fUserOrigin[3]
		pev(iToucher, pev_origin, fOrigin)
		createBlast(fOrigin, 1000.0, {92, 64, 51})
		screenShake()
		
		new iPlayers[MAX_PLAYERS], iNum
		get_players(iPlayers, iNum, "ch")
		for(new i, iPlayer;i < iNum;i++)
		{
			iPlayer = iPlayers[i]
					
			pev(iPlayer, pev_origin, fUserOrigin)
			if(get_distance_f(fOrigin, fUserOrigin) < EXPLOSION_RADIUS)
			{
				client_cmd(iPlayer, "spk ^"%s^"", g_szNukeExplosionClose)
			}
			client_cmd(iPlayer, "spk ^"%s^"", g_szNukeExplosionFar)
		}
		
		new iVictim = -1
		while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, fOrigin, IMPULSE_EXPLOSION_RADIUS)) != 0)
		{
			if(!is_user_alive(iVictim))
				continue
				
			pev(iVictim, pev_origin, fUserOrigin)
			screenFade(iVictim, {0, 0, 0})
			impulsePlayer(iVictim, iToucher, (IMPULSE_EXPLOSION_RADIUS - (get_distance_f(fOrigin, fUserOrigin) * 0.0254)))
		}
		
		remove_entity(iToucher)
	}
}

public forward_AddToFullPack(es_handle, e, iEnt, iHost, hostflags, iPlayer, pSet)
{
	if(pev_valid(iEnt) && pev(iEnt, pev_iuser1) == PLANE_ID)
	{	
		set_es(es_handle, ES_RenderFx, kRenderFxDistort)
		set_es(es_handle, ES_RenderMode, kRenderTransAdd)
	}
}


public cmdStartEvent(id, iLevel, iCid)
{
	if(!cmd_access(id, iLevel, iCid, 1))
		return
		
	if(g_bStarted)
		return
		
	new iEnt = create_entity("info_target")
	if(!pev_valid(iEnt))
		return
	
	new Float:fOrigin[3]
	pev(id, pev_origin, fOrigin)
	
	g_fStartOrigin = fOrigin
	fOrigin[2] = (g_fMaxZ - 100.0)
	
	if(!isValidOrigin(fOrigin))
	{
		console_print(id, "[AMXX]: Invalid point!")
		return
	}

	g_iPlaneEntityID = iEnt
	g_bStarted = true
	
	new Float:fPlayerAngle[3]
	pev(id, pev_angles, fPlayerAngle)
	velocity_by_aim(id, 1000, g_fPlaneVelocity)
	
	set_pev(iEnt, pev_origin, fOrigin)
	engfunc(EngFunc_SetModel, iEnt, g_szPlaneModel)
	set_pev(iEnt, pev_angles, fPlayerAngle)
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY)
	set_pev(iEnt, pev_solid, SOLID_BBOX)
	set_pev(iEnt, pev_classname, g_szPlaneClassName)
	
	set_task(1.0, "speakSounds")
}

public speakSounds()
{
	client_cmd(0, "stopsound")
	
	new Float:fOrigin[3], Float:fRefreshTime
	pev(g_iPlaneEntityID, pev_origin, fOrigin)
	switch(g_iAttackLevel)
	{
		case 0:
		{
			client_cmd(0, "spk ^"%s^"", g_szAirAttackBegin)
			screenFade(0, {255, 0, 0}, 75)
			
			set_task(4.5, "anotherScreenFade")
			
			fRefreshTime = 10.0
			g_iAttackLevel += 1
		}
		case 1:
		{
			client_cmd(0, "spk ^"%s^"", g_szAirAttackDialogue)
	
			fRefreshTime = 20.0
			g_iAttackLevel += 1
		}
		case 2:
		{
			client_cmd(0, "spk ^"%s^"", g_szAirAttackCoordinatesBeep)
			createLine(g_fStartOrigin, fOrigin)
			
			fRefreshTime = 10.0
			g_iAttackLevel += 1
		}
		case 3:
		{
			client_cmd(0, "spk ^"%s^"", g_szAirAttackCoordinatesLasers)
			set_task(5.0, "releaseNukes")
			
			createBlast(fOrigin, 1000.0, .TE_TYPE = TE_BEAMDISK, .TE_LIFETIME = 50)
			
			g_iAttackLevel = 0
			return
		}
	}
	set_task(fRefreshTime, "speakSounds")
}

public anotherScreenFade() screenFade(0, {255, 0, 0}, 75)

public releaseNukes()
{
	createStrikes()
	set_task(16.0, "speakTakeOffSound")
}

public speakTakeOffSound()
{
	set_pev(g_iPlaneEntityID, pev_iuser1, PLANE_ID)
	
	client_cmd(0, "spk ^"%s^"", g_szAirAttackPlaneTakeoff)
	set_task(4.7, "anotherBlast")
}

public anotherBlast()
{
	new Float:fOrigin[3]
	pev(g_iPlaneEntityID, pev_origin, fOrigin)
	createBlast(fOrigin, 700.0)
	
	set_task(13.0, "speakLastSound")
}

public speakLastSound()
{	
	set_pev(g_iPlaneEntityID, pev_iuser1, 0)
	set_rendering(g_iPlaneEntityID, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
	
	client_cmd(0, "spk ^"%s^"", g_szAirAttackPlaneRemove)
	set_task(2.0, "removePlaneGravity")
}

public removePlaneGravity()
{
	set_rendering(g_iPlaneEntityID, kRenderFxGlowShell, 200, 255, 255, kRenderNormal, 100)
	
	set_pev(g_iPlaneEntityID, pev_velocity, g_fPlaneVelocity)
	set_pev(g_iPlaneEntityID, pev_gravity, 1.0)
	set_pev(g_iPlaneEntityID, pev_movetype, MOVETYPE_TOSS)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(g_iPlaneEntityID)
	write_short(g_iTrailSprite)
	write_byte(80)
	write_byte(30)
	write_byte(220)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	message_end()
		
	new Float:fPlaneOrigin[3]
	pev(g_iPlaneEntityID, pev_origin, fPlaneOrigin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(3)
	write_coord(floatround(fPlaneOrigin[0]))
	write_coord(floatround(fPlaneOrigin[1]))
	write_coord(floatround(fPlaneOrigin[2]))
	write_short(g_iParticlesSprite)
	write_byte(80)
	write_byte(10)
	write_byte(0)
	message_end()
	
	set_task(2.3, "removePlane")
}

public removePlane()
{
	new Float:fOrigin[3]
	pev(g_iPlaneEntityID, pev_origin, fOrigin)
	createBlast(fOrigin, 1000.0)

	screenShake()
	remove_entity(g_iPlaneEntityID)
	
	g_bStarted = false
	g_iPlaneEntityID = 0
}

createStrikes()
{
	new iBombs = create_entity("info_target")
	if(!pev_valid(iBombs))
		return
		
	new Float:fOrigin[3]
	pev(g_iPlaneEntityID, pev_origin, fOrigin)
	fOrigin[2] -= 40.0
	set_pev(iBombs, pev_origin, fOrigin)
	engfunc(EngFunc_SetModel, iBombs, g_szStrikesModel)
	
	new Float:fAngle[3]
	pev(g_iPlaneEntityID, pev_angles, fAngle)
	set_pev(iBombs, pev_angles, fAngle)
	
	screenFade(0, {255, 255, 255})
	g_iNukeEntityID = iBombs
	
	set_pev(iBombs, pev_gravity, 0.1)
	set_pev(iBombs, pev_movetype, MOVETYPE_TOSS)
	set_pev(iBombs, pev_solid, SOLID_BBOX)
	set_pev(iBombs, pev_classname, g_szStrikesClassName)
	
	set_task(0.1, "checkDistanceToGround")
}

public checkDistanceToGround()
{
	if(distanceToGroundInMetersIsEnough(g_iNukeEntityID))
	{
		client_cmd(0, "spk ^"%s^"", g_szNukeDoppler)
		return
	}
	set_task(0.1, "checkDistanceToGround")
}

screenShake()
{
	message_begin(MSG_ALL, g_mMessageScreenShake)
	write_short(fixedUnsigned16(20.0, (1 << 12)))
	write_short(fixedUnsigned16(3.0, (1 << 12)))
	write_short(fixedUnsigned16(5.7, (1 << 8)))
	message_end()
}

screenFade(id, iRGB[3], iAmmount = 255)
{
	message_begin(id ? MSG_ONE_UNRELIABLE : MSG_ALL, g_mMessageScreenFade, .player = id)
	write_short(1<<12)
	write_short(fixedUnsigned16(1.0, (1 << 12)))
	write_short(0)
	write_byte(iRGB[0])
	write_byte(iRGB[1]) 
	write_byte(iRGB[2]) 
	write_byte(iAmmount) 
	message_end()
}

impulsePlayer(iVictim, iAttacker, Float:fDamage)
{
	static Float:fPlayerVelocity[3], Float:fAttackerOrigin[3], Float:fPlayerOrigin[3], Float:fTemp[3]
	pev(iVictim, pev_velocity, fPlayerVelocity)
	pev(iVictim, pev_origin, fPlayerOrigin)
	pev(iAttacker, pev_origin, fAttackerOrigin)
	xs_vec_sub(fPlayerOrigin, fAttackerOrigin, fTemp)
	xs_vec_normalize(fTemp, fTemp)
	xs_vec_mul_scalar(fTemp, fDamage, fTemp)
	xs_vec_mul_scalar(fTemp, EXPLOSION_MULTIPLIER, fTemp)
	xs_vec_add(fPlayerVelocity, fTemp, fPlayerVelocity)
	set_pev(iVictim, pev_velocity, Float:fPlayerVelocity)

	static Float:fAVelocity[3]
	fAVelocity[1] = random_float(-1000.0, 1000.0)
	set_pev(iVictim, pev_avelocity, fAVelocity)
	
	ExecuteHam(Ham_TakeDamage, iVictim, iAttacker, iAttacker, (fDamage / 15.5), (1 << 24))
}

createBlast(Float:fStartOrigin[3], Float:fValue, iRGB[3] = {255, 255, 255}, TE_TYPE = TE_BEAMCYLINDER, TE_LIFETIME = 10)
{
	message_begin_fl(MSG_PVS, fStartOrigin)
	write_byte(TE_TYPE)
	write_coord_fl(fStartOrigin[0])
	write_coord_fl(fStartOrigin[1])
	write_coord_fl(fStartOrigin[2])
	write_coord_fl(fStartOrigin[0])
	write_coord_fl(fStartOrigin[1])
	write_coord_fl(fStartOrigin[2] + fValue)
	write_short(g_iExplosionSprite)
	write_byte(0)
	write_byte(3)
	write_byte(TE_LIFETIME)
	write_byte(80)
	write_byte(0)
	write_byte(iRGB[0])
	write_byte(iRGB[1])
	write_byte(iRGB[2])
	write_byte(100)
	write_byte(0)
	message_end()
}

createLine(Float:fStart[3], Float:fEnd[3])
{
	message_begin_fl(MSG_BROADCAST, fStart)
	write_byte(TE_BEAMPOINTS)
	write_coord_fl(fStart[0])
	write_coord_fl(fStart[1])
	write_coord_fl(fStart[2])
	write_coord_fl(fEnd[0])
	write_coord_fl(fEnd[1])
	write_coord_fl(fEnd[2])
	write_short(g_iSprite)
	write_byte(2)
	write_byte(9)
	write_byte(300)
	write_byte(50)
	write_byte(0)
	write_byte(255)
	write_byte(0)
	write_byte(0)
	write_byte(150)
	write_byte(50)
	message_end()
}

Float:getMaxZ()
{  
	new pcCurrent, Float:fStartPoint[3]
	while((engfunc(EngFunc_PointContents, fStartPoint) == CONTENTS_EMPTY) || (engfunc(EngFunc_PointContents, fStartPoint) == CONTENTS_SOLID)) 
	{ 
		fStartPoint[2] += 5.0 
	} 
	
	pcCurrent = engfunc(EngFunc_PointContents, fStartPoint)
	if(pcCurrent == CONTENTS_SKY) 
	{ 
		return fStartPoint[2] -= 20.0
	} 
	return 0.0 
} 

bool:isValidOrigin(const Float:fOrigin[3]) 
{
	if(PointContents(fOrigin) == CONTENTS_EMPTY)
	{
		new HandleTraceHull 
		engfunc(EngFunc_TraceHull, fOrigin, fOrigin, DONT_IGNORE_MONSTERS, HULL_HUMAN, 0, HandleTraceHull)    
		if(get_tr2(HandleTraceHull, TR_InOpen) && !(get_tr2(HandleTraceHull, TR_StartSolid) || get_tr2(HandleTraceHull, TR_AllSolid))) 
		{
			return true
		}    
	}
	return false
}

distanceToGroundInMetersIsEnough(id) 
{ 
	new Float:fStart[3], Float:fEnd[3]
	entity_get_vector(id, EV_VEC_origin, fStart)

	fEnd[0] = fStart[0] 
	fEnd[1] = fStart[1]
	fEnd[2] = fStart[2] - 9999.0

	new iPtr = create_tr2(), Float:fFraction
	engfunc(EngFunc_TraceHull, fStart, fEnd, IGNORE_MONSTERS, HULL_HUMAN, id, iPtr)
	get_tr2(iPtr, TR_flFraction, fFraction)
	free_tr2(iPtr)

	return bool:(((fFraction * 9999.0) * 0.0254) <= 50.0)
} 