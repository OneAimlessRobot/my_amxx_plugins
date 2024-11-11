/*================================================================================
	
	-----------------------------------
	-*- [ZP] Zombie Classes Predator -*-
	-----------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This is just an example on how to add additional zombie classes in ZP.
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <zombieplague>

// Predator Attributes
new const zclass_name[] = { "Predator" } // name
new const zclass_info[] = { "=Balanced=" } // description
new const zclass_model[] = { "depredador2" } // model
new const zclass_clawmodel[] = { "claws.mdl" } // claw model
const zclass_health = 1800 // health
const zclass_speed = 200 // speed
const Float:zclass_gravity = 1.0 // gravity
const Float:zclass_knockback = 1.0 // knockback

// Class IDs
new g_zclassid1

// Zombie Classes MUST be registered on plugin_precache
public plugin_precache()
{
	register_plugin("[ZP] Additional Zombie Classes", "0.1", "Predator")
	
	// Register the new class and store ID for reference
	g_zclassid1 = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)	
}

// User Infected forward
public zp_user_infected_post(id, infector)
{
	// Check if the infected player is using our custom zombie class
	if (zp_get_user_zombie_class(id) == g_zclassid1)
		client_print(id, print_chat, "[ZP]Izpolzvash Predator clas!")
}
