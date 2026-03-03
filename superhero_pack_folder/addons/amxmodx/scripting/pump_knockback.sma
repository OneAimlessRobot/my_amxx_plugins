#include <amxmodx>
#include <engine>

#define PLUGIN	"Pump Knockback (when shot by one)"
#define VERSION	"1.0"
#define AUTHOR	"v3x & Chronic"

new cvar_pump_active , cvar_pump_force;

public plugin_init()
{
	register_plugin(PLUGIN , VERSION , AUTHOR);

	register_event("Damage" , "event_Damage" , "b" , "2>0");

	cvar_pump_active   = register_cvar("pump_knockback" , "1");
	cvar_pump_force	   = register_cvar("pump_force"     , "10");
}

public event_Damage(id)
{
	if(!get_pcvar_num(cvar_pump_active))
		return PLUGIN_CONTINUE;

	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;

	new weapon , attacker = get_user_attacker(id , weapon);

	if(!is_user_alive(attacker))
		return PLUGIN_CONTINUE;

	if(weapon == CSW_M3)
	{
		new Float:vec[3];
		new Float:oldvelo[3];
		get_user_velocity(id, oldvelo);
		create_velocity_vector(id , attacker , vec);
		vec[0] += oldvelo[0];
		vec[1] += oldvelo[1];
		set_user_velocity(id , vec);
	}

	return PLUGIN_CONTINUE;
}

// Stock by the one and only, Chronic :P
stock create_velocity_vector(victim,attacker,Float:velocity[3])
{
	if(!is_user_alive(victim) || !is_user_alive(attacker))
		return 0;

	new Float:vicorigin[3];
	new Float:attorigin[3];
	entity_get_vector(victim   , EV_VEC_origin , vicorigin);
	entity_get_vector(attacker , EV_VEC_origin , attorigin);

	new Float:origin2[3]
	origin2[0] = vicorigin[0] - attorigin[0];
	origin2[1] = vicorigin[1] - attorigin[1];

	new Float:largestnum = 0.0;

	if(floatabs(origin2[0])>largestnum) largestnum = floatabs(origin2[0]);
	if(floatabs(origin2[1])>largestnum) largestnum = floatabs(origin2[1]);

	origin2[0] /= largestnum;
	origin2[1] /= largestnum;

	velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_pump_force) * 3000) ) / get_entity_distance(victim , attacker);
	velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_pump_force) * 3000) ) / get_entity_distance(victim , attacker);
	if(velocity[0] <= 20.0 || velocity[1] <= 20.0)
		velocity[2] = random_float(200.0 , 275.0);

	return 1;
}