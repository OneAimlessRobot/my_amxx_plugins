/*================================================================================
	
	---------------------------------------
	-*- [AvP] Example: Classes Register -*-
	---------------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This is just an example on how to add additional classes to AvP.
	
================================================================================*/

//- Required includes
#include < amxmodx >
#include < aliens_vs_predator >

//- Defines for register_plugin()
#define PLUGIN	"[AvP] Example: Classes Register"
#define VERSION	"v1.0"
#define AUTHOR	"Example"

//- Marine Attributes
new const marine_name[] = "My Marine"; //- Name
new const marine_info[] = "My Information"; //- Information
new const marine_model[] = "marine_model_name"; //- Model
const marine_health = 300; //- Health
const Float:marine_gravity = 1.0; //- Gravity
const Float:marine_speed = 240.0; //- Speed

//- Predator Attributes
new const predator_name[] = "My Predator"; //- Name
new const predator_info[] = "My Information"; //- Information
new const predator_model[] = "predator_model_name"; //- Model
const predator_health = 300; //- Health
const Float:predator_gravity = 1.0; //- Gravity
const Float:predator_speed = 240.0; //- Speed

//- Alien Attributes
new const alien_name[] = "My Alien"; //- Name
new const alien_info[] = "My Information"; //- Information
new const alien_model[] = "alien_model_name"; //- Model
new const alien_claw[] = "models/alien_claw.mdl"; //- Claw Model
const alien_health = 300; //- Health
const alien_damage = 70; //- Damage
const Float:alien_gravity = 1.0; //- Gravity
const Float:alien_speed = 240.0; //- Speed

public plugin_init()
{
	//- Register plugin
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

//- All classes MUST be registered on plugin_precache()
public plugin_precache()
{
	//- Register Marine class
	avp_register_marine_class(marine_name, marine_info, marine_health, marine_gravity, marine_speed, marine_model);

	//- Register Predator class
	avp_register_predator_class(predator_name, predator_info, predator_health, predator_gravity, predator_speed, predator_model);

	//- Register Alien class
	avp_register_alien_class(alien_name, alien_info, alien_health, alien_gravity, alien_damage, alien_speed, alien_model, alien_claw);
}