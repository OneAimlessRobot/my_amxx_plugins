/*
	*EDITED BY: yas17sin for alien vs predator mod.
*/
#include <amxmodx>
#include <aliens_vs_predator>

public plugin_init()
{
    register_plugin("AVP: Show Victim HP On Damage", "1.0", "<VeCo>")
	
    register_event("Damage","event_damage","b","2!0","3=0","4!0")
}

public event_damage(id)
{
    new killer = get_user_attacker(id)
	
    if(avp_get_user_alien(id)) client_print(killer, print_center, "HP: %i",get_user_health(id))
}