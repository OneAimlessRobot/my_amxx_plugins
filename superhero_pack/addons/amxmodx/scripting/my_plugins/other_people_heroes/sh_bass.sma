// BASS! ?

/* CVARS - copy and paste to shconfig.cfg

//Bass
bass_level 10
bass_health 200			//Default 200
bass_armor 200				//Default 200
bass_speed 200				//Default 200
bass_gravity 0.40			//Default 0.40
bass_laser_ammo 1000		//total # of shots given each round, -1 is unlimited (Default 1000)
bass_laser_burndecals 1		//Show the burn decals on the walls
bass_cooldown 0.0			//Cooldown timer between laser use
bass_multishot 0.1			//Delay for multishots on holding key down, set to -1 for only 1 shot per keydown (Default 0.1)

*/

/*
* v1.3 - vittu - 7/29/05
*      - Fixed bug with cooldown, if one is set.
*
* v1.2 - MTS Steel DrAgoN - 6/23/05
*      - Cleaned up code.
*
*      - vittu - 6/23/05
*      - Made further changes.
*      - Added defines for easy Beam color changes.
*      - Added code for unlimited laser shots as an option.
*
*   Hero is a rip of Cyclops with added HP/AP/Speed/Gravity.
*   From original code "Based on dr.doom Hero but added gravity.."
*/

#include <amxmod>
#include <superheromod>

// Damage Variables
#define h1_dam 500	// head
#define h2_dam 250	// body
#define h3_dam 250	// stomach
#define h4_dam 100	// arm
#define h6_dam 100	// leg

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
#define BEAM_COLOR GREEN		// Set beam color here, use color names from above (Default GREEN)
#define BEAM_ALPHA 200		// alpha value, visibility from 0-255 (Default 200)

//Color definitions
new BeamColors[8][3] = {
	{150, 150, 150},	// Custom, edit this one for a custom rgb value
	{255, 0, 0},		// Red
	{0, 255, 0},		// Green
	{0, 0, 255},		// Blue
	{0, 255, 255},		// Light Blue
	{255, 255, 0},		// Yellow
	{255, 0, 255},		// Purple
	{255, 128, 0}		// Orange
}

// GLOBAL VARIABLES
new gHeroName[]="Bass"
new bool:gHasBassPower[SH_MAXSLOTS+1]
new bool:gLaserFired[SH_MAXSLOTS+1]
new gLaserShots[SH_MAXSLOTS+1]
new smoke, laser
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Bass", "1.3", "Op")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("bass_level", "10")
	register_cvar("bass_health", "200")
	register_cvar("bass_armor", "200")
	register_cvar("bass_speed", "200")
	register_cvar("bass_gravity", "0.40")
	register_cvar("bass_laser_ammo", "1000")
	register_cvar("bass_laser_burndecals", "1")
	register_cvar("bass_cooldown", "0.0")
	register_cvar("bass_multishot", "0.1")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(gHeroName, "Uber Energy Beam", "Press the +power key to fire your your beam cannon", true, "bass_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("bass_init", "bass_init")
	shRegHeroInit(gHeroName, "bass_init")

	// KEY DOWN
	register_srvcmd("bass_kd", "bass_kd")
	shRegKeyDown(gHeroName, "bass_kd")

	// KEY UP
	register_srvcmd("bass_ku", "bass_ku")
	shRegKeyUp(gHeroName, "bass_ku")

	// NEW SPAWN
	register_event("ResetHUD", "newSpawn", "b")

	// DEATH
	register_event("DeathMsg", "bass_death", "a")

	// Let Server know about Bass's Variables
	shSetMaxHealth(gHeroName, "bass_health")
	shSetMaxArmor(gHeroName, "bass_armor")
	shSetMinGravity(gHeroName, "bass_gravity")
	shSetMaxSpeed(gHeroName, "bass_speed", "[0]")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_sound("weapons/electro5.wav")
	precache_sound("weapons/xbow_hitbod2.wav")
	smoke = precache_model("sprites/steam1.spr")
	laser = precache_model("sprites/laserbeam.spr")
}
//----------------------------------------------------------------------------------------------
public bass_init()
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
		gLaserShots[id] = get_cvar_num("bass_laser_ammo")
	}
	else if( !hasPowers && gHasBassPower[id] && is_user_alive(id) ) {
		shRemHealthPower(id)
		shRemGravityPower(id)
		shRemArmorPower(id)
		shRemSpeedPower(id)
	}

	// Sets this variable to the current status
	gHasBassPower[id] = (hasPowers != 0)
}
//----------------------------------------------------------------------------------------------
public newSpawn(id)
{
	if ( shModActive() && gHasBassPower[id] && is_user_alive(id) ) {
		remove_task(id)
		gPlayerUltimateUsed[id] = false
		gLaserShots[id] = get_cvar_num("bass_laser_ammo")
		gLaserFired[id] = false
	}
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public bass_kd()
{
	if ( !hasRoundStarted() ) return

	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	if ( !is_user_alive(id) ) return

	if ( gLaserShots[id] == 0 ) {
		client_print(id, print_center, "No Bass Shots Left")
		playSoundDenySelect(id)
		return
	}

	if ( gPlayerUltimateUsed[id] ) {
		playSoundDenySelect(id)
		return
	}

	fire_laser(id)  // 1 immediate shot
	if ( get_cvar_float("bass_multishot") >= 0.0 ) {
		set_task(get_cvar_float("bass_multishot"), "fire_laser", id, "", 0, "b")  //delayed shots
	}

	gLaserFired[id] = true
}
//----------------------------------------------------------------------------------------------
public bass_ku()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	remove_task(id)

	if ( !hasRoundStarted() || gPlayerUltimateUsed[id] || !gLaserFired[id] ) return

	// Use the ultimate
	if ( get_cvar_float("bass_cooldown") > 0.0 ) ultimateTimer(id, get_cvar_float("bass_cooldown"))

	gLaserFired[id] = false
}
//----------------------------------------------------------------------------------------------
public fire_laser(id)
{
	new aimvec[3]
	new tid, tbody
	new FFOn = get_cvar_num("mp_friendlyfire")

	if ( !is_user_alive(id) ) return

	if ( gLaserShots[id] == 0 ) {
		client_print(id, print_center, "No Bass Shots Left")
		playSoundDenySelect(id)
		return
	}

	if ( gLaserShots[id] > -1 ) gLaserShots[id]--

	// Warn How many Blasts Left...
	if ( gLaserShots[id] <= 10 && gLaserShots[id] >= 0 ) {
		client_print(id, print_center, "Warning: %d Bass Shots Left", gLaserShots[id])
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
		shExtraDamage(tid, id, damage, "Bass Energy Beam")
	}
}
//----------------------------------------------------------------------------------------------
public laserEffects(id, aimvec[3])
{
	new origin[3]

	emit_sound(id, CHAN_ITEM, "weapons/electro5.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

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
	write_byte(0)			// r, g, b
	write_byte(255)		// r, g, b
	write_byte(0)			// r, g, b
	write_byte(2)			// life
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
	write_byte(2)			// life
	write_byte(60)			// width
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

	if ( get_cvar_num("bass_laser_burndecals") == 1 ) {
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
public bass_death()
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

	gHasBassPower[id] = false
}
//----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
