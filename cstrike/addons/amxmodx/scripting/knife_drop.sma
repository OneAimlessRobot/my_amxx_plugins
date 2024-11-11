///////////////////////////////////
//                               //
//  Credits:		             //
//  ConnorMcLeod, XxAvalanchexX  //
//                               //
///////////////////////////////////

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN	"Knife Drop"
#define AUTHOR	"Alucard"
#define VERSION	"1.2"

// --------------------START EDIT------------------------ //

#define MODEL_ON

#define is_user_admin2(%1)  (get_user_flags(%1) & ADMIN_KICK)

#if defined MODEL_ON
new const V_HAND_MODEL[]	= "models/v_hands.mdl"
#endif

// --------------------END EDIT------------------------- //

new p_Type, p_OnlyAdmins, p_ShowMsg, p_MsgCantDrop, 
p_KnifeCost, p_MenuEnable, p_KnifeUsage, p_KnifeKills,
p_ShowMenu

new Kills, Menu, Text[48]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("knife_drop", VERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	/* ----------- Events & Forwards ----------- */
	
	RegisterHam(Ham_CS_Item_CanDrop, "weapon_knife", "KnifeDrop")
	
	register_event("DeathMsg", "DeathMsg", "a", "1>0")
	
	/* ----------- Cvars & Commands ----------- */
	
	register_clcmd("drop", "HookCmdDrop")
	register_clcmd("say /knife", "HookGiveKnife")
	
	p_Type = register_cvar("kd_type", "2")
	p_OnlyAdmins = register_cvar("kd_onlyadmins", "0")
	p_ShowMsg = register_cvar("kd_showmsg", "1")
	p_MsgCantDrop = register_cvar("kd_msg_cantdrop", "1")
	
	p_KnifeUsage = register_cvar("kd_usage", "1")
	p_ShowMenu = register_cvar("kd_showmenu", "1")
	p_KnifeKills = register_cvar("kd_kills", "2")
	
	p_MenuEnable = register_cvar("kd_menu_enable", "1")
	p_KnifeCost = register_cvar("kd_knife_cost", "800")
	
	/* ----------- Menu ----------- */
	
	Menu = menu_create("\yDo you want to buy a knife?", "KnifeBuy")
	
	menu_additem(Menu, "\wYes", "1")
	menu_additem(Menu, "\wNo", "2")
	
	menu_addblank(Menu)
	menu_addblank(Menu)
	menu_addblank(Menu)
	
	formatex(Text, charsmax(Text), "The price of the knife is \r$%i", get_pcvar_num(p_KnifeCost) )
	menu_addtext(Menu, Text)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
}

#if defined MODEL_ON
public plugin_precache()
	precache_model(V_HAND_MODEL)

public SetModel(id)
{
	if(get_pcvar_num(p_Type) == 1 || get_pcvar_num(p_Type) == 2)
	{
		new Weapons[32], num, weapon	
		get_user_weapons(id, Weapons, num)
		
		for(new i = 0; i < num; i++)
			weapon = Weapons[i]
		
		if(!weapon)	
			set_pev(id, pev_viewmodel2, V_HAND_MODEL)
	}
}

public SetModel2(iKiller)
{
	if(get_pcvar_num(p_Type) == 1 || get_pcvar_num(p_Type) == 2)
	{
		new Weapons[32], num, weapon	
		get_user_weapons(iKiller, Weapons, num)
		
		for(new i = 0; i < num; i++)
			weapon = Weapons[i]
		
		if(!weapon)	
			set_pev(iKiller, pev_viewmodel2, V_HAND_MODEL)
	}
}
#endif

public HookGiveKnife(id)
{
	if(!is_user_alive(id) )
	{
		client_print(id, print_chat, "[Knife-Menu] Only alive players can buy knife")
		return PLUGIN_HANDLED
	}	
	
	if(user_has_weapon(id, CSW_KNIFE) )
	{
		client_print(id, print_chat, "[Knife-Menu] You can't buy a knife becouse you have one")
		return PLUGIN_HANDLED
	}	
	
	if(!get_pcvar_num(p_MenuEnable) )
	{
		client_print(id, print_chat, "[Knife-Menu] Knife Menu is disabled right now")
		return PLUGIN_HANDLED
	}
	
	menu_display(id, Menu)
	return PLUGIN_HANDLED
}

public DeathMsg()
{
	new iKiller = read_data(1)
	new iVictim = read_data(2)
	
	new Weapon[32]
	read_data(4, Weapon, 31)
	
	if(iKiller && (iKiller != iVictim) && equal(Weapon, "knife") )
	{
		new num = get_pcvar_num(p_KnifeKills)
		
		if(get_pcvar_num(p_KnifeUsage) )
		{	
			if( (++Kills == num) || (num == 0) )
			{		
				ham_strip_weapon(iKiller, "weapon_knife")
				
				Kills = 0
				
				if(get_pcvar_num(p_ShowMenu) )
					menu_display(iKiller, Menu)
				
				#if defined MODEL_ON
				set_task(0.3, "SetModel2", iKiller)
				#endif
				
				return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE
}

public KnifeBuy(id, Menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu)
		return PLUGIN_HANDLED
	}
	
	new iData[6]
	new iAccess
	new iCallback
	new iName[64]
	
	menu_item_getinfo(Menu, item, iAccess, iData, 5, iName, 63, iCallback)
	
	switch(str_to_num(iData))
	{
		case 1:
		{
			if(!is_user_alive(id) ) // ppl can't bug with this!!
				return PLUGIN_HANDLED
			if(user_has_weapon(id, CSW_KNIFE) ) // ppl can't bug with this!!
				return PLUGIN_HANDLED
			if(!get_pcvar_num(p_MenuEnable) )
				return PLUGIN_HANDLED
			
			new cash = cs_get_user_money(id) - get_pcvar_num(p_KnifeCost)
			
			if(cash < 0)
			{
				client_print(id, print_chat, "[Knife-Menu] You don't have enough money to buy a knife")
				return PLUGIN_HANDLED
			}
			
			cs_set_user_money(id, cash, 1)
			
			ham_give_weapon(id, "weapon_knife")
			
			client_print(id, print_chat, "[Knife-Menu] You recived a Knife")
		}
		case 2:
		client_print(id, print_chat, "[Knife-Menu] Ok, no problem. Come back later.")
	}
	return PLUGIN_HANDLED
}

public KnifeDrop(ent)
{
	if(get_pcvar_num(p_Type) == 2)	
		SetHamReturnInteger(1)
	
	return HAM_SUPERCEDE
}

public HookCmdDrop(id)
{
	if(!is_user_alive(id) )
		return PLUGIN_CONTINUE
	
	if(get_user_weapon(id) == CSW_KNIFE)
	{
		if(!get_pcvar_num(p_Type) )
			return get_pcvar_num(p_MsgCantDrop) ? PLUGIN_CONTINUE : PLUGIN_HANDLED
		
		if(get_pcvar_num(p_OnlyAdmins) && !is_user_admin2(id) )
		{
			client_print(id, print_center, "[Knife Drop] Only Admins can drop their knifes")
			return PLUGIN_HANDLED
		}
		
		if(get_pcvar_num(p_ShowMsg) )
			client_print(id, print_center, "[Knife Drop] You dropped your knife")
		
		if(get_pcvar_num(p_Type) == 1)
		{			
			ham_strip_weapon(id, "weapon_knife")
			return PLUGIN_HANDLED
		}
	}
	
	#if defined MODEL_ON
	set_task(0.3, "SetModel", id)
	#endif
	
	return PLUGIN_CONTINUE
}

stock ham_strip_weapon(id,weapon[])
{
	if(!equal(weapon, "weapon_", 7) ) return 0
	
	new wId = get_weaponid(weapon)
	if(!wId) return 0
	
	new wEnt
	while( (wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname", weapon) ) && pev(wEnt, pev_owner) != id) {}
	if(!wEnt) return 0
	
	if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon, wEnt)
	
	if(!ExecuteHamB(Ham_RemovePlayerItem, id, wEnt) ) return 0
	ExecuteHamB(Ham_Item_Kill ,wEnt)
	
	set_pev(id, pev_weapons, pev(id, pev_weapons) & ~(1<<wId) )
	
	return 1
}

stock ham_give_weapon(id,weapon[])
{
	if(!equal(weapon, "weapon_", 7) ) return 0
	
	new wEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,weapon) )
	if(!pev_valid(wEnt) ) return 0
	
	set_pev(wEnt, pev_spawnflags,SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, wEnt)
	
	if(!ExecuteHamB(Ham_AddPlayerItem, id, wEnt) )
	{
		if(pev_valid(wEnt) ) set_pev(wEnt, pev_flags, pev(wEnt, pev_flags) | FL_KILLME)
		return 0
	}
	
	ExecuteHamB(Ham_Item_AttachToPlayer, wEnt, id)
	return 1
}  