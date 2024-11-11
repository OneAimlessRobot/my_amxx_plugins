#include <amxmodx>
#include <customshop>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_VERSION "1.0"

const m_pPlayer = 41;
const m_flPrimaryAttack = 46;
const m_fInReload = 54;
const m_flNextAttack = 83;

additem ITEM_ATTACKRATE;
new Float:g_fMultiplier;
new bool:g_bHasItem[33];

public plugin_init()
{
	register_plugin("CSHOP: Primary Attack Rate", PLUGIN_VERSION, "OciXCrom");

	for(new szWeapon[20], i = CSW_P228; i <= CSW_P90; i++)
	{
		if(get_weaponname(i, szWeapon, charsmax(szWeapon)))
		{
			RegisterHam(Ham_Weapon_Reload, szWeapon, "OnReload", 1);
			RegisterHam(Ham_Weapon_PrimaryAttack, szWeapon, "OnPrimaryAttack", 1);
		}
	}

	g_fMultiplier = cshop_get_float(ITEM_ATTACKRATE, "Multiplier");
}

public plugin_precache()
{
	ITEM_ATTACKRATE = cshop_register_item("attackrate", "Faster Attack Rate", 6000);
	cshop_set_float(ITEM_ATTACKRATE, "Multiplier", 1.5);
}

public client_putinserver(id)
	g_bHasItem[id] = false;

public cshop_item_selected(id, iItem)
{
	if(iItem == ITEM_ATTACKRATE)
		g_bHasItem[id] = true;
}

public cshop_item_removed(id, iItem)
{
	if(iItem == ITEM_ATTACKRATE)
		g_bHasItem[id] = false;
}

public OnReload(iEnt)
{
	if(get_pdata_int(iEnt, m_fInReload, 4))
	{
		static id; id = get_pdata_cbase(iEnt, m_pPlayer, 4);

		if(g_bHasItem[id])
			set_pdata_float(id, m_flNextAttack, get_pdata_float(id, m_flNextAttack, 5) / g_fMultiplier, 5);
	}
}

public OnPrimaryAttack(iEnt)
{
	if(!pev_valid(iEnt))
		return;

	if(g_bHasItem[get_pdata_cbase(iEnt, m_pPlayer, 4)])
		set_pdata_float(iEnt, m_flPrimaryAttack, get_pdata_float(iEnt, m_flPrimaryAttack, 4) / g_fMultiplier);
}
