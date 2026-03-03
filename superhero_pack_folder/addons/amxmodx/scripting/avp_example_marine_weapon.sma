/*================================================================================
	
	---------------------------------------------
	-*- [AvP] Example: Marine Weapon Register -*-
	---------------------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This is just an example on how to add additional marine weapons to AvP.

	Note: to prevent bugs, you need register a impulse to weapons no more than of 500000,
	(pev_* or entity_set_*) to allow only marines pickup this weapon, otherwise, only the
	predators will be allowed to pickup this weapon when he is on the ground.
	
================================================================================*/

//- Required includes
#include < amxmodx >
#include < fun >
#include < cstrike >
#include < aliens_vs_predator >

//- Defines for register_plugin()
#define PLUGIN	"[AvP] Example: Marine Weapon Register"
#define VERSION	"v1.0"
#define AUTHOR	"Example"

//- Primary Weapon Attributes (Sub-Machines, Machines, Shotguns, etc..)
new const primary_name[] = "Primary Name"; //- Name
new const primary_handler[] = "function_primary_handler"; //- Handler
const primary_type = AVP_PRIMARY_WEAPON; //- Type

//- Secondary Weapon Attributes (Pistol)
new const secondary_name[] = "Secondary Name"; //- Name
new const secondary_handler[] = "function_secondary_handler"; //- Handler
const secondary_type = AVP_SECONDARY_WEAPON; // - Type

public plugin_init()
{
	//- Register plugin
	register_plugin(PLUGIN, VERSION, AUTHOR);

	//- Register weapons
	avp_register_weapon(primary_name, primary_handler, primary_type);
	avp_register_weapon(secondary_name, secondary_handler, secondary_type);
}

//- Primary weapon handler
public function_primary_handler(index)
{
	//- Give weapon
	give_item(index, "weapon_ak47")

	//- Set user bpammo
	cs_set_user_bpammo(index, CSW_AK47, 90);
}

//- Secondary weapon handler
public function_secondary_handler(index)
{
	//- Give weapon
	give_item(index, "weapon_usp")

	//- Set user bpammo
	cs_set_user_bpammo(index, CSW_USP, 35);
}