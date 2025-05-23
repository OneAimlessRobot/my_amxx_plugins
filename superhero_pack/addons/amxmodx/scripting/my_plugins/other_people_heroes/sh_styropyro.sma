/* CVARS - copy and paste to shconfig.cfg

//styropyro
styropyro_level 0
styropyro_laser_ammo 1000		//total # of shots given each round, -1 is unlimited (Default 1000)
styropyro_laser_burndecals 1		//Show the burn decals on the walls
styropyro_cooldown 0.0			//Cooldown timer between laser use
styropyro_multishot 0.1			//Delay for multishots on holding key down, set to -1 for only 1 shot per keydown (Default 0.1)

*/

#include <amxmod>
#include <superheromod>

// Damage Variables
#define h1_dam 1500	// head
#define h2_dam 600	// body
#define h3_dam 600	// stomach
#define h4_dam 400	// arm
#define h6_dam 400	// leg

//Colors To Pick From ***DO NOT MODIFY***
#define CUSTOM		0
#define RED		1
#define GREEN		2
#define BLUE		3
#define LTBLUE		4
#define YELLOW		5
#define PURPLE		6
#define ORANGE		7

//Color Settings ***CHANGE COLOR HERE***
#define BEAM_COLOR CUSTOM		// Set beam color here, use color names from above (Default GREEN)
#define BEAM_ALPHA 255		// alpha value, visibility from 0-255 (Default 200)

//Color definitions
new BeamColors[8][3] = {
	{255, 0, 43},	// Custom, edit this one for a custom rgb value
	{255, 0, 0},		// Red
	{0, 255, 0},		// Green
	{0, 0, 255},		// Blue
	{0, 255, 255},		// Light Blue
	{255, 255, 0},		// Yellow
	{255, 0, 255},		// Purple
	{255, 128, 0}		// Orange
}

// GLOBAL VARIABLES
new gHeroName[]="styropyro"
new bool:gHasstyropyroPower[SH_MAXSLOTS+1]
new bool:gLaserFired[SH_MAXSLOTS+1]
new gLaserShots[SH_MAXSLOTS+1]
new smoke, laser
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO styropyro", "1.0", "TastyMedula")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("styropyro_level", "0")
	register_cvar("styropyro_laser_ammo", "-1")
	register_cvar("styropyro_laser_burndecals", "1")
	register_cvar("styropyro_cooldown", "0.0")
	register_cvar("styropyro_multishot", "0.1")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(gHeroName, "Stay safe n' happy lazing", "Press the +power key to fire your your 10 kJ C.R.L.C (crazy ruby laser cannon)", true, "styropyro_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("styropyro_init", "styropyro_init")
	shRegHeroInit(gHeroName, "styropyro_init")

	// KEY DOWN
	register_srvcmd("styropyro_kd", "styropyro_kd")
	shRegKeyDown(gHeroName, "styropyro_kd")

	// KEY UP
	register_srvcmd("styropyro_ku", "styropyro_ku")
	shRegKeyUp(gHeroName, "styropyro_ku")

	// NEW SPAWN
	register_event("ResetHUD", "newSpawn", "b")

	// DEATH
	register_event("DeathMsg", "styropyro_death", "a")

	// Let Server know about styropyro's Variables
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_sound("weapons/gauss2.wav")
	precache_sound("weapons/xbow_hitbod2.wav")
	smoke = precache_model("sprites/steam1.spr")
	laser = precache_model("sprites/laserbeam.spr")
}
//----------------------------------------------------------------------------------------------
public styropyro_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has the hero
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)

	// This gets run if they had the power but don't anymore
	if ( hasPowers && is_user_connected(id) ) {
		gPlayerUltimateUsed[id] = false
		gLaserShots[id] = get_cvar_num("styropyro_laser_ammo")
	}

	// Sets this variable to the current status
	gHasstyropyroPower[id] = (hasPowers != 0)
}
//----------------------------------------------------------------------------------------------
public newSpawn(id)
{
	if ( shModActive() && gHasstyropyroPower[id] && is_user_alive(id) ) {
		remove_task(id)
		gPlayerUltimateUsed[id] = false
		gLaserShots[id] = get_cvar_num("styropyro_laser_ammo")
		gLaserFired[id] = false
	}
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public styropyro_kd()
{
	if ( !hasRoundStarted() ) return

	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	if ( !is_user_alive(id) ) return

	if ( gLaserShots[id] == 0 ) {
		client_print(id, print_center, "Ran out'a microwaves, back to the shop")
		playSoundDenySelect(id)
		return
	}

	if ( gPlayerUltimateUsed[id] ) {
		playSoundDenySelect(id)
		return
	}

	fire_laser(id)  // 1 immediate shot
	if ( get_cvar_float("styropyro_multishot") >= 0.0 ) {
		set_task(get_cvar_float("styropyro_multishot"), "fire_laser", id, "", 0, "b")  //delayed shots
	}

	gLaserFired[id] = true
}
//----------------------------------------------------------------------------------------------
public styropyro_ku()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)
	
	remove_task(id)

	if ( !hasRoundStarted() || gPlayerUltimateUsed[id] || !gLaserFired[id] ) return

	// Use the ultimate
	if ( get_cvar_float("styropyro_cooldown") > 0.0 ) ultimateTimer(id, get_cvar_float("styropyro_cooldown"))

	gLaserFired[id] = false
}
//----------------------------------------------------------------------------------------------
public fire_laser(id)
{
	new aimvec[3]
	new tid, tbody
	new FFOn = get_cvar_num("mp_friendlyfire")

	if ( !is_user_alive(id) ) return

	sh_screenShake(id, 100, 25, 100)
	sh_setScreenFlash(id, 255, 255, 255, 10, 200)
	
	if ( gLaserShots[id] == 0 ) {
		client_print(id, print_center, "Ran out'a microwaves, back to the shop")
		playSoundDenySelect(id)
		return
	}

	if ( gLaserShots[id] > -1 ) gLaserShots[id]--

	// Warn How many Blasts Left...
	if ( gLaserShots[id] <= 10 && gLaserShots[id] >= 0 ) {
		client_print(id, print_center, "Warning: %d0.0 kJoules of stored energy left!", gLaserShots[id])
	}

	get_user_origin(id, aimvec, 3)

	laserEffects(id, aimvec)

	get_user_aiming(id, tid, tbody)

	if ( is_user_alive(tid) && ( FFOn || get_user_team(id) != get_user_team(tid) ) ) {
		emit_sound(tid, CHAN_BODY, "weapons/xbow_hitbod2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

		// Determine the damage
		new damage
		switch(tbody) {
			case 1: damage = h1_dam
			case 2: damage = h2_dam
			case 3: damage = h3_dam
			case 4: damage = h4_dam
			case 5: damage = h4_dam
			case 6: damage = h6_dam
			case 7: damage = h6_dam
		}

		// Deal the damage...
		shExtraDamage(tid, id, damage, "styropyro C.R.L.C")
	}
}
//----------------------------------------------------------------------------------------------
public laserEffects(id, aimvec[3])
{
	new origin[3]

	emit_sound(id, CHAN_ITEM, "weapons/gauss2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	get_user_origin(id, origin, 1)

	new colornum = BEAM_COLOR
	new colors[3]

	if (colornum < 0 || colornum >= 8) {
		//If invalid value set it to default green
		colornum = 2
	}
	colors = BeamColors[colornum]

	// DELIGHT
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(10)
	write_byte(255)			// r, g, b
	write_byte(0)		// r, g, b
	write_byte(0)			// r, g, b
	write_byte(9)			// life
	write_byte(1)			// decay
	message_end()

	//BEAMENTPOINTS
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte (0)			//TE_BEAMENTPOINTS
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(aimvec[0])
	write_coord(aimvec[1])
	write_coord(aimvec[2])
	write_short(laser)
	write_byte(1)			// framestart
	write_byte(5)			// framerate
	write_byte(10)			// life
	write_byte(45)			// width
	write_byte(0)			// noise
	write_byte(colors[0])	// Red
	write_byte(colors[1])	// Green
	write_byte(colors[2])	// Blue
	write_byte(BEAM_ALPHA)	// brightness
	write_byte(200)		// speed
	message_end()

	//Sparks
	message_begin(MSG_PVS, SVC_TEMPENTITY)
	write_byte(9)
	write_coord(aimvec[0])
	write_coord(aimvec[1])
	write_coord(aimvec[2])
	message_end()

	//Smoke
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(5)
	write_coord(aimvec[0])
	write_coord(aimvec[1])
	write_coord(aimvec[2])
	write_short(smoke)
	write_byte(22)		// 10
	write_byte(10)		// 10
	message_end()

	if ( get_cvar_num("styropyro_laser_burndecals") == 1 ) {
		//TE_GUNSHOTDECAL
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(109)		// decal and ricochet sound
		write_coord(aimvec[0])	// pos
		write_coord(aimvec[1])
		write_coord(aimvec[2])
		write_short(0)			// I have no idea what thats supposed to be
		write_byte(28)			// decal
		message_end()
	}

}
//----------------------------------------------------------------------------------------------
public styropyro_death()
{
	new id = read_data(2)

	if ( id <= 0 || id > SH_MAXSLOTS ) return

	remove_task(id)
}
//----------------------------------------------------------------------------------------------
public client_disconnected(id)
{
	// stupid check but lets see
	if ( id <= 0 || id > SH_MAXSLOTS ) return

	// Yeah don't want any left over residuals
	remove_task(id)

	gHasstyropyroPower[id] = false
}
//----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
