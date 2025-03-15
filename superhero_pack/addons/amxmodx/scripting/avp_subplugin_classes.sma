/*================================================================================

		-----------------------------------------
		-*- [AvP] Sub-Plugin: Default Classes -*-
		-----------------------------------------

	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This plugin adds the default classes to Aliens vs Predator.
	Feel free to modify their attributes to your liking.

================================================================================*/

//- Required includes
#include < amxmodx >
#include < aliens_vs_predator >

//- Plugin precache
public plugin_precache()
{
	//- Register Plugin
	register_plugin("[AvP] Sub-Plugin: Default Classes", "Public Evolution v1.0b", "Crazy");

	//- Register classes
	avp_register_marine_class("Soldier", "Balanced", 300, 0.85, 250.0, "avp_marine");
	avp_register_alien_class("Classic Alien", "Balanced", 3500, 0.72, 100, 330.0, "avp_alien", "models/avp_models/alien_claw.mdl");
	avp_register_predator_class("Classic Predator", "Balanced", 1300, 0.77, 275.0, "avp_predator");
}