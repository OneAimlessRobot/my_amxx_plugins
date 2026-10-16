#include <amxmodx>
#include <zp50_class_zombie>
#include <zp50_grenade_fire>

new const PLUGIN_VERSION[] = "1.0.0"

new const zombieclass1_name[] = "Anti-Fire Zombie"
new const zombieclass1_info[] = "- Immune to fire"
new const zombieclass1_models[][] = { "zombie_source" }
new const zombieclass1_clawmodels[][] = { "models/zombie_plague/v_knife_zombie.mdl" }
const zombieclass1_health = 1800
const Float:zombieclass1_speed = 1.0
const Float:zombieclass1_gravity = 1.0
const Float:zombieclass1_knockback = 1.0

new g_ZombieClassID

public plugin_precache()
{
	register_plugin("[ZP] Class: Zombie: Anti-Fire", PLUGIN_VERSION, "Excalibur.007")
	
	new index
	
	g_ZombieClassID = zp_class_zombie_register(zombieclass1_name, zombieclass1_info, zombieclass1_health, zombieclass1_speed, zombieclass1_gravity)
	zp_class_zombie_register_kb(g_ZombieClassID, zombieclass1_knockback)
	
	for(index = 0; index < sizeof zombieclass1_models; index++)
		zp_class_zombie_register_model(g_ZombieClassID, zombieclass1_models[index])
		
	for(index = 0; index < sizeof zombieclass1_clawmodels; index++)
		zp_class_zombie_register_claw(g_ZombieClassID, zombieclass1_clawmodels[index])
}

public zp_fw_grenade_fire_pre(player)
{
	if(is_user_alive(player) && zp_class_zombie_get_current(player) == g_ZombieClassID)
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
