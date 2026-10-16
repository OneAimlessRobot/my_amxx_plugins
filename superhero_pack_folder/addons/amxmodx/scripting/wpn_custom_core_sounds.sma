#include <amxmodx>
#include <weaponmod>

// Plugin informations
new const PLUGIN[] = "WPN Custom Core Sounds"
new const VERSION[] = "0.1"
new const AUTHOR[] = "DevconeS"
new const PREFIX[] = "[WeaponMod]"

// Core sound list
#define MAX_CORE_SOUNDS		4
new const wpn_core_sound:CORE_SOUND_TYPE[MAX_CORE_SOUNDS] =
{
	/* Weapon sounds */
	wpn_core_sound_weapon_empty,	/* Played when a weapon is empty */
	wpn_core_sound_weapon_drop,	/* Played when a weapon has been picked dropped */
	wpn_core_sound_weapon_pickup,	/* Played when a weapon has been picked up */
	
	/* Ammo sounds */
	wpn_core_sound_ammo_pickup,	/* Played when a ammo has been picked up */
}

new const CORE_SOUND_FILE[MAX_CORE_SOUNDS][] =
{
	"wpnmod/wpnempty.wav",
	"wpnmod/wpndrop.wav",
	"wpnmod/wpnpickup.wav",
	"wpnmod/wpnammo.wav"
}

// Initializes the plugin
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	wpn_register_addon()
}

// Precaches sound files
public plugin_precache()
{
	// Cycle through all files, precache and register them
	new tempFile[128]
	for(new i = 0; i < MAX_CORE_SOUNDS; i++)
	{
		formatex(tempFile, 127, "sound/%s", CORE_SOUND_FILE[i])
		if(file_exists(tempFile))
		{
			// File exists
			precache_sound(CORE_SOUND_FILE[i])
			wpn_set_core_sound(CORE_SOUND_TYPE[i], CORE_SOUND_FILE[i])
		} else {
			server_print("%s Custom sound %s does not exist and is not activated", PREFIX, CORE_SOUND_FILE[i])
		}
	}
}
