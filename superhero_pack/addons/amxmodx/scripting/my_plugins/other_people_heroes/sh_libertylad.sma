//--------------------------------------------------------------------------------------------------
// HERO DESCRIPTIONS
//--------------------------------------------------------------------------------------------------
/*

LIBERTY LAD IS A CHARACTER FROM FREEDOM FORCE (PC GAME)
FULL BIOGRAPHY: HTTP://TINYURL.COM/4NEP7F

*/
//--------------------------------------------------------------------------------------------------
// UPDATES
//--------------------------------------------------------------------------------------------------
/*

VERSION 1.0
- RELEASE OF HERO

*/
//--------------------------------------------------------------------------------------------------
// CVARS
//--------------------------------------------------------------------------------------------------
/*

//Liberty Lad
libertylad_level 2				//Level acquired to use this hero
libertylad_throwspeed 600		//The speed of the flare when being thrown
libertylad_duration 20.0		//Time in seconds for the flare to live (Min: 2.0)(Max: 60.0)
libertylad_radius 30			//Size of the light from the flare
libertylad_life 6				//Best to leave this cvar to default
libertylad_decay 3				//Best to leave this cvar to default
libertylad_red 255				//Red color of the flare light (0: None)(255: Brightest)
libertylad_green 255			//Green color of the flare light (0: None)(255: Brightest)
libertylad_blue 255				//Blue color of the flare light (0: None)(255: Brightest)

*/
//--------------------------------------------------------------------------------------------------
// INCLUDED HEADERS
//--------------------------------------------------------------------------------------------------
	#include <amxmodx>
	#include <superheromod>
	#include <engine>
//--------------------------------------------------------------------------------------------------
// GLOBAL VARIABLES
//--------------------------------------------------------------------------------------------------
	new gHeroName[] = "Liberty Lad"
	new bool: gHasLibertyLadPower[SH_MAXSLOTS+1]
	new Float: LibertyLadFlareOrigin[3]
	new flareentity
//--------------------------------------------------------------------------------------------------
// PLUGIN INITIALS
//--------------------------------------------------------------------------------------------------
	public plugin_init()
	{
	register_plugin("SUPERHERO Liberty Lad", "1.0", "Zul Rivers")
	register_cvar("libertylad_level", "2")
	register_cvar("libertylad_throwspeed", "600")
	register_cvar("libertylad_duration", "20.0")
	register_cvar("libertylad_radius", "30")
	register_cvar("libertylad_life", "6")
	register_cvar("libertylad_decay", "3")
	register_cvar("libertylad_red", "255")
	register_cvar("libertylad_green", "255")
	register_cvar("libertylad_blue", "255")
	shCreateHero(gHeroName, "Flares", "Shoot Flares on Keydown", true, "libertylad_level")
	register_srvcmd("libertylad_init", "libertylad_init")
	shRegHeroInit(gHeroName, "libertylad_init")
	register_event("ResetHUD", "libertylad_newround", "b")
	register_srvcmd("libertylad_kd", "libertylad_kd")
	shRegKeyDown(gHeroName, "libertylad_kd")
	}
//--------------------------------------------------------------------------------------------------
// HERO INITIALS
//--------------------------------------------------------------------------------------------------
	public libertylad_init()
	{
	new temp[6]
	read_argv(1, temp, 5)
	new id = str_to_num(temp)
	read_argv(2, temp, 5)
	new hasPowers = str_to_num(temp)
	gHasLibertyLadPower[id] = (hasPowers != 0)
	}
//--------------------------------------------------------------------------------------------------
// PLUGIN PRECACHES
//--------------------------------------------------------------------------------------------------
	public plugin_precache()
	{
	precache_sound("weapons/rocketfire1.wav")
	precache_model("models/w_flare.mdl")
	precache_model("models/w_flaret.mdl")
	}
//--------------------------------------------------------------------------------------------------
// NEW ROUND
//--------------------------------------------------------------------------------------------------
	public libertylad_newround(id)
	{
	libertylad_removeflare(flareentity)
	gPlayerUltimateUsed[id] = false
	}
//--------------------------------------------------------------------------------------------------
// KEYDOWN
//--------------------------------------------------------------------------------------------------
	public libertylad_kd()
	{
	new temp[6]
	read_argv(1, temp, 5)
	new id = str_to_num(temp)
	if (hasRoundStarted())
	{
	if (is_user_alive(id) && gHasLibertyLadPower[id])
	{
	if (get_cvar_float("libertylad_duration") > 60.0)
	{
	debugMessage("[SH](Liberty Lad) libertylad_duration must not be set higher than 60.0, cvar defaulted to 60.0", 0, 0)
	set_cvar_float("libertylad_duration", 60.0)
	}
	else if (get_cvar_float("libertylad_duration") < 2.0)
	{
	debugMessage("[SH](Liberty Lad) libertylad_duration must not be set below than 2.0, cvar defaulted to 2.0", 0, 0)
	set_cvar_float("libertylad_duration", 2.0)
	}
	if (!gPlayerUltimateUsed[id])
	{
	if (get_cvar_float("libertylad_duration") > 0.0)
	{
	ultimateTimer(id, get_cvar_float("libertylad_duration"))
	}
	emit_sound(id, CHAN_BODY, "weapons/rocketfire1.wav", 1.0, ATTN_NORM,0,PITCH_NORM)
	libertylad_createflare(id)
	gPlayerUltimateUsed[id] = true
	}
	else if (gPlayerUltimateUsed[id])
	{
	playSoundDenySelect(id)
	client_print(id, print_chat, "[SH](Liberty Lad) Please Wait Until Previous Flare Goes Off")
	}
	}
	}
	}
//--------------------------------------------------------------------------------------------------
// FLARE CREATION
//--------------------------------------------------------------------------------------------------
	public libertylad_createflare(id)
	{
	new Float: FlareRendering[3]
	new Float: LibertyLadFlareVelocity[3]
	flareentity = create_entity("info_target")
	entity_get_vector(id, EV_VEC_origin, LibertyLadFlareOrigin)
	entity_set_string(flareentity, EV_SZ_classname, "libertylad_flare")
	entity_set_model(flareentity, "models/w_flare.mdl")
	entity_set_origin(flareentity, LibertyLadFlareOrigin)
	entity_set_int(flareentity, EV_INT_solid, 2)
	entity_set_edict(flareentity, EV_ENT_owner, id)
	entity_set_int(flareentity, EV_INT_movetype, 6)
	entity_set_float(flareentity, EV_FL_gravity, 0.6)
	FlareRendering[0] = 115.0
	FlareRendering[1] = 115.0
	FlareRendering[2] = 115.0
	entity_set_int(flareentity, EV_INT_rendermode, kRenderNormal)
	entity_set_int(flareentity, EV_INT_renderfx, kRenderFxGlowShell)
	entity_set_float(flareentity, EV_FL_renderamt, 11.0)
	entity_set_vector(flareentity, EV_VEC_rendercolor, FlareRendering)
	VelocityByAim(id, get_cvar_num("libertylad_throwspeed"), LibertyLadFlareVelocity)
	entity_set_vector(flareentity, EV_VEC_velocity, LibertyLadFlareVelocity)
	set_task(0.1, "libertylad_flarelight", flareentity, "", 0, "b")
	set_task(get_cvar_float("libertylad_duration"), "libertylad_removeflare", flareentity)
	}
//--------------------------------------------------------------------------------------------------
// LIGHT ON FLARE
//--------------------------------------------------------------------------------------------------
	public libertylad_flarelight(id)
	{
	entity_get_vector(id, EV_VEC_origin, LibertyLadFlareOrigin)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(27)
	write_coord(floatround(LibertyLadFlareOrigin[0]))
	write_coord(floatround(LibertyLadFlareOrigin[1]))
	write_coord(floatround(LibertyLadFlareOrigin[2]))
	write_byte(get_cvar_num("libertylad_radius"))
	write_byte(get_cvar_num("libertylad_red"))
	write_byte(get_cvar_num("libertylad_green"))
	write_byte(get_cvar_num("libertylad_blue"))
	write_byte(get_cvar_num("libertylad_life"))
	write_byte(get_cvar_num("libertylad_decay"))
	message_end()
	}
//--------------------------------------------------------------------------------------------------
// REMOVE FLARE AND LIGHT
//--------------------------------------------------------------------------------------------------
	public libertylad_removeflare(flareentity)
	{
	remove_task(flareentity)
	remove_entity(flareentity)
	}
//--------------------------------------------------------------------------------------------------