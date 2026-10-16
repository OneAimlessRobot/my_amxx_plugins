/*================================================================================
	
	----------------------------------
	-*- [AvP] Example: Extra Items -*-
	----------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This is just an example on how to add additional extra items to AvP.
	
================================================================================*/

//- Required includes
#include < amxmodx >
#include < fun >
#include < aliens_vs_predator >

//- Defines for register_plugin()
#define PLUGIN	"[AvP] Example: Extra Items"
#define VERSION	"v1.0"
#define AUTHOR	"Example"

//- Marine Item Attributes
new const marine_item_name[] = "+1000 Health" //- Name
new const marine_item_handler[] = "func_mrn_item_handler"; //- Handler
const marine_item_cost = 20; //- Cost
const marine_item_team = AVP_TEAM_MARINE; //- Team

//- Alien Item Attributes
new const alien_item_name[] = "+1000 Health" //- Name
new const alien_item_handler[] = "func_aln_item_handler"; //- Handler
const alien_item_cost = 20; //- Cost
const alien_item_team = AVP_TEAM_ALIEN; //- Team

//- Predator Item Attributes
new const predator_item_name[] = "+1000 Health" //- Name
new const predator_item_handler[] = "func_prd_item_handler"; //- Handler
const predator_item_cost = 20; //- Cost
const predator_item_team = AVP_TEAM_PREDATOR; //- Team

public plugin_init()
{
	//- Register plugin
	register_plugin(PLUGIN, VERSION, AUTHOR);

	//- Register Extra Items
	avp_register_extra_item(marine_item_name, marine_item_cost, marine_item_handler, marine_item_team);
	avp_register_extra_item(alien_item_name, alien_item_cost, alien_item_handler, alien_item_team);
	avp_register_extra_item(predator_item_name, predator_item_cost, predator_item_handler, predator_item_team);
}

//- Marine Extra Item handler
public func_mrn_item_handler(index)
{
	static health, newhealth;

	//- Get user health
	health = get_user_health(index);

	//- Set a new user health
	newhealth = set_user_health(index, health + 1000);

	//- Show a chat message
	client_print(index, print_chat, "[AvP] You now have %d!", newhealth);
}

//- Alien Extra Item handler
public func_aln_item_handler(index)
{
	static health, newhealth;

	//- Get user health
	health = get_user_health(index);

	//- Set a new user health
	newhealth = set_user_health(index, health + 1000);

	//- Show a chat message
	client_print(index, print_chat, "[AvP] You now have %d!", newhealth);
}

//- Predator Extra Item handler
public func_prd_item_handler(index)
{
	static health, newhealth;

	//- Get user health
	health = get_user_health(index);

	//- Set a new user health
	newhealth = set_user_health(index, health + 1000);

	//- Show a chat message
	client_print(index, print_chat, "[AvP] You now have %d!", newhealth);
}