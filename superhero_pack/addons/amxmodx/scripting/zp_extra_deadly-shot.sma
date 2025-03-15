#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>

#define TASK_HUD 5345634
#define TASK_REMOVE 2423423

new bool:has_item[33]
new bool:using_item[33]

new sync_hud1
new cvar_deadlyshot_cost
new cvar_deadlyshot_time

new g_deadlyshot

public plugin_init()
{
	register_plugin("[ZP] Extra Item: Deadly Shot (Human)", "1.0", "Dias")
	
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	RegisterHam(Ham_TraceAttack, "player", "fw_traceattack")
	
	cvar_deadlyshot_cost = register_cvar("ds_cost", "25")
	cvar_deadlyshot_time = register_cvar("ds_time", "10.0")
	
	sync_hud1 = CreateHudSyncObj(random_num(1, 10))
	g_deadlyshot = zp_register_extra_item("Deadly Shot", get_pcvar_num(cvar_deadlyshot_cost), ZP_TEAM_HUMAN)
}

public event_newround(id)
{
	remove_ds(id)
}

public zp_extra_item_selected(id, itemid)
{
	if(itemid != g_deadlyshot)
		return PLUGIN_HANDLED
		
	if(!has_item[id] || using_item[id])
	{
		client_print(id, print_chat, "[ZP] You bought Deadly Shot !!!")
		
		has_item[id] = true
		using_item[id] = false
		
		set_task(0.1, "show_hud", id+TASK_HUD, _, _, "b")
	} else {
		client_print(id, print_chat, "[ZP] You can't buy Deadly Shot at this time...")
		zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + get_pcvar_num(cvar_deadlyshot_cost))
	}
	
	return PLUGIN_CONTINUE
}

public zp_user_infected_post(id)
{
	remove_ds(id)
}

public show_hud(id)
{
	id -= TASK_HUD

	set_hudmessage(0, 255, 0, -1.0, 0.88, 0, 2.0, 1.0)	
	
	if(has_item[id])
	{
		ShowSyncHudMsg(id, sync_hud1, "[E] -> Active Deadly Shot")
	} else if(using_item[id]) {
		ShowSyncHudMsg(id, sync_hud1, "Deadly Shot - Actived")		
	} else {
		set_hudmessage(0, 255, 0, -1.0, 0.88, 0, 2.0, 5.0)
		ShowSyncHudMsg(id, sync_hud1, "Deadly Shot - Disable")
		if(task_exists(id+TASK_HUD)) remove_task(id+TASK_HUD)
	}
}

public client_PostThink(id)
{
	static Button
	Button = get_user_button(id)
	
	if(Button & IN_USE)
	{
		if(has_item[id] && !using_item[id])
		{
			has_item[id] = false
			using_item[id] = true
			
			set_task(get_pcvar_float(cvar_deadlyshot_time), "remove_headshot_mode", id+TASK_REMOVE)
		}
	}
}

public fw_traceattack(victim, attacker, Float:damage, direction[3], traceresult, dmgbits)
{
	if(using_item[attacker])
	{
		set_tr2(traceresult, TR_iHitgroup, HIT_HEAD)
	}
}

public remove_ds(id)
{
	if(has_item[id] || using_item[id])
	{
		has_item[id] = false
		using_item[id] = false		
		
		if(task_exists(id+TASK_HUD)) remove_task(id+TASK_HUD)
		if(task_exists(id+TASK_REMOVE)) remove_task(id+TASK_REMOVE)
	}	
}

public remove_headshot_mode(id)
{
	id -= TASK_REMOVE
	
	has_item[id] = false
	using_item[id] = false
	
	if(task_exists(id+TASK_HUD)) remove_task(id+TASK_HUD)
}
