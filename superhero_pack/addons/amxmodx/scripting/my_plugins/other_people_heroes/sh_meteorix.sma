// Meteorix! - Throw blue lightnings

/* CVARS - copy and paste to shconfig.cfg

// Meteorix
meteorix_level 9
meteorix_ammo -1			// How many lightnings do you have? (-1 to unlimited)
meteorix_burndecals 1		// Show the burn decals? (0 = no, 1 = yes)
meteorix_shotmult 0.5		// Delay for multishots on holding key down.

*/

#include <amxmodx>
#include <superheromod>

#define h1_dam 500 // head
#define h2_dam 250  // body
#define h3_dam 130  // stomach
#define h4_dam 100  // arm
#define h6_dam 90  // leg

new gHeroName[]="Meteorix"
new bool:gHasMeteorixPower[SH_MAXSLOTS+1]
new bool:MeteorixPowerUsed[SH_MAXSLOTS+1]
new lightnings_shots[SH_MAXSLOTS+1]
new gLastWeapon[SH_MAXSLOTS+1]
// Sprites
new gSpriteSmoke, gSpriteFire, gSpriteBurning
// Cvars
new max_shots, burndecals, Float:shot_mult

// ----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Meteorix", "1.0", "NOmeR1")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("meteorix_level", "9")
	register_cvar("meteorix_ammo", "-1")
	register_cvar("meteorix_burndecals", "1")
	register_cvar("meteorix_shotmult", "0.5")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(gHeroName, "Blue lightnings", "You can throw blue lightnings on key down", true, "meteorix_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	register_event("ResetHUD", "newSpawn", "b")

	// KEY DOWN
	register_srvcmd("meteorix_kd", "meteorix_kd")
	shRegKeyDown(gHeroName, "meteorix_kd")

	// KEY UP
	register_srvcmd("meteorix_ku", "meteorix_ku")
	shRegKeyUp(gHeroName, "meteorix_ku")

	// INIT
	register_srvcmd("meteorix_init", "meteorix_init")
	shRegHeroInit(gHeroName, "meteorix_init")

	// DEATH
	register_event("DeathMsg", "meteorix_death", "a")

}
// ----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	// Cvars
	max_shots = get_cvar_num("meteorix_ammo")
	burndecals = get_cvar_num("meteorix_burndecals")
	shot_mult = get_cvar_float("meteorix_shotmult")
}
// ----------------------------------------------------------------------------------------------
public plugin_precache()
{
	// Sprites
	gSpriteSmoke = precache_model("sprites/steam1.spr")
	gSpriteFire = precache_model("sprites/lgtning.spr")
	gSpriteBurning = precache_model("sprites/shmod/blue_flame.spr")
	// Sound
	precache_sound("shmod/lightnin.wav")
	precache_sound("weapons/xbow_hitbod2.wav")
}
// ----------------------------------------------------------------------------------------------
public meteorix_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)

	gHasMeteorixPower[id] = (hasPowers!=0)

	// Set max shots
	if(gHasMeteorixPower[id]) {
		lightnings_shots[id] = max_shots
	}
}
// ----------------------------------------------------------------------------------------------
public meteorix_death()
{
	new id = read_data(2)

	if(!gHasMeteorixPower[id]) return

	remove_task(id)
	MeteorixPowerUsed[id] = false
}
// ----------------------------------------------------------------------------------------------
public newSpawn(id)
{
	if(!gHasMeteorixPower[id]) return
	remove_task(id)
	MeteorixPowerUsed[id] = false
	lightnings_shots[id] = max_shots
}
// ----------------------------------------------------------------------------------------------
public meteorix_kd()
{

	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// Get weapon to saving
	new clip, ammo, weaponID = get_user_weapon(id, clip, ammo)
	gLastWeapon[id] = weaponID

	MeteorixPowerUsed[id] = true
	// Get weapon to saving
	lightnings_shot(id)
	// Shoot a blue lightnings
	if(shot_mult > 0.0) {
		set_task(shot_mult, "lightnings_shot", id, "", 0, "b")
	}

	return PLUGIN_HANDLED
}
// ----------------------------------------------------------------------------------------------
public meteorix_ku()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// Stop using lightnings
	remove_task(id)

	if(MeteorixPowerUsed[id]) {
		// Resolve use Meteorix power again
		MeteorixPowerUsed[id] = false
		// Change knife to previously weapon
		if(gLastWeapon[id] != CSW_KNIFE) {
			shSwitchWeaponID(id, gLastWeapon[id])
		}
	}
}
// ----------------------------------------------------------------------------------------------
public lightningEffects(id, aimvec[3])
{
	emit_sound(id, CHAN_ITEM, "shmod/lightnin.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	new origin[3]
	get_user_origin(id, origin)
	// Height + 10 (From a stomach on hands)
	origin[2] = origin[2] + 10

	// DELIGHT
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(10)
	write_byte(19) // r, g, b
	write_byte(97) // r, g, b
	write_byte(255) // r, g, b
	write_byte(3) // life
	write_byte(1) // decay
	message_end()

	for(new i = 1; i <= 5; i++)
	{
		// BEAMENTPOINTS
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(0) // TE_BEAMENTPOINTS 0
		if(i == 1) {
			write_coord(origin[0])
		} else if(i == 2 || i == 4) {
			write_coord(origin[0] + (i * 2))
		} else {
			write_coord(origin[0] - (i * 2))
		}
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(aimvec[0])
		write_coord(aimvec[1])
		write_coord(aimvec[2])
		write_short(gSpriteFire)
		write_byte(1) // framestart
		write_byte(10) // framerate
		write_byte(3) // life
		write_byte(50) // width
		write_byte(50) // noise
		write_byte(19) // r, g, b
		write_byte(97) // r, g, b
		write_byte(255) // r, g, b
		write_byte(200) // brightness
		write_byte(200) // speed
		message_end()
	}

	// Sparks
	message_begin(MSG_PVS, SVC_TEMPENTITY)
	write_byte(9)
	write_coord(aimvec[0])
	write_coord(aimvec[1])
	write_coord(aimvec[2])
	message_end()

	// Fire
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(3)
	write_coord(aimvec[0])
	write_coord(aimvec[1])
	write_coord(aimvec[2])
	write_short(gSpriteBurning)
	write_byte(22)
	write_byte(10)
	write_byte(0)
	message_end()

	// Smoke
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(5)
	write_coord(aimvec[0])
	write_coord(aimvec[1])
	write_coord(aimvec[2])
	write_short(gSpriteSmoke)// short (sprite index)
	write_byte(60) // byte (scale in 0.1's)
	write_byte(15) // byte (framerate)
	message_end()

	if(burndecals != 0) {
		// TE_GUNSHOTDECAL
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(109) // decal and ricochet sound
		write_coord(aimvec[0]) // pos
		write_coord(aimvec[1])
		write_coord(aimvec[2])
		write_short(0) // I have no idea what thats supposed to be
		write_byte(random_num(28, 30)) // decal
		message_end()
	}

}
// ----------------------------------------------------------------------------------------------
public lightnings_shot(id)
{
	new aimvec[3]
	new tid, tbody
	new FFOn = get_cvar_num("mp_friendlyfire")

	if(!is_user_alive(id) || !gHasMeteorixPower[id]) return PLUGIN_HANDLED

	// If you have no lightnings
	if(lightnings_shots[id] == 0) {
		client_print(id, print_center, "You have no lightnings")
		playSoundDenySelect(id)
		return PLUGIN_HANDLED
	}

	// Get weapon to saving
	new clip, ammo, weaponID = get_user_weapon(id, clip, ammo)

	if(weaponID != CSW_KNIFE) {
		// Switch weapon on knife
		shSwitchWeaponID(id, CSW_KNIFE)
	}

	if(lightnings_shots[id] != -1) {
		lightnings_shots[id]--
	}

	// Get position from eyes
	get_user_origin(id, aimvec, 3)
	// Throw blue lightnings
	lightningEffects(id, aimvec)

	// Get targeted player
	get_user_aiming(id, tid, tbody)

	if(is_user_alive(tid) && (FFOn || get_user_team(id) != get_user_team(tid))) {
		emit_sound(tid,CHAN_BODY, "weapons/xbow_hitbod2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

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

		// Make damage to target
		shExtraDamage(tid, id, damage, "Blue lightnings from Meteorix")
	}
	return PLUGIN_CONTINUE
}
// ----------------------------------------------------------------------------------------------
public client_disconnected(id)
{
	// stupid check but lets see
	if(id <= 0 || id > SH_MAXSLOTS) return

	// Yeah don't want any left over residuals
	remove_task(id)
	gHasMeteorixPower[id] = false
}
// ----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
