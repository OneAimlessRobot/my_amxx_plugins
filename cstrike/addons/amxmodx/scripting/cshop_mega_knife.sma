#include <amxmodx>
#include <cstrike>
#include <customshop>
#include <fakemeta>
#include <hamsandwich>

#if !defined m_pPlayer
	#define m_pPlayer 41
#endif

#define PLUGIN_VERSION "1.0.2"
#define V_MODEL "models/custom_shop/v_dagger.mdl"
#define P_MODEL "models/custom_shop/p_dagger.mdl"

additem ITEM_MEGA_KNIFE
new g_bHasItem[33], g_szDamage[16]

public plugin_init()
{
	register_plugin("CSHOP: Mega Knife", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CSHOPMegaKnife", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "OnSelectKnife", 1)
	RegisterHam(Ham_TakeDamage, "player", "PreTakeDamage", 0)
	cshop_get_string(ITEM_MEGA_KNIFE, "Amount", g_szDamage, charsmax(g_szDamage))
}

public plugin_precache()
{
	ITEM_MEGA_KNIFE = cshop_register_item("megaknife", "Mega Knife", 8000)
	cshop_set_string(ITEM_MEGA_KNIFE, "Amount", "+100%")
	
	#if defined V_MODEL
	precache_model(V_MODEL)
	#endif
	
	#if defined P_MODEL
	precache_model(P_MODEL)
	#endif
}

public cshop_item_selected(id, iItem)
{
	if(iItem == ITEM_MEGA_KNIFE)
	{
		g_bHasItem[id] = true
		
		if(get_user_weapon(id) == CSW_KNIFE)
			RefreshKnifeModel(id)
	}
}

public cshop_item_removed(id, iItem)
{
   if(iItem == ITEM_MEGA_KNIFE)
	  g_bHasItem[id] = false
}

public client_putinserver(id)
	g_bHasItem[id] = false
	
public OnSelectKnife(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	
	if(g_bHasItem[id] && is_user_connected(id))
		RefreshKnifeModel(id)
}
   
public PreTakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
	if(is_user_alive(iAttacker) && iAttacker != iVictim && g_bHasItem[iAttacker])
		SetHamParamFloat(4, math_add_f(fDamage, g_szDamage))
}

RefreshKnifeModel(const id)
{
	set_pev(id, pev_viewmodel2, V_MODEL)
	set_pev(id, pev_weaponmodel2, P_MODEL)
}

Float:math_add_f(Float:fNum, const szMath[])
{
	static szNewMath[16], Float:fMath, bool:bPercent, cOperator
   
	copy(szNewMath, charsmax(szNewMath), szMath)
	bPercent = szNewMath[strlen(szNewMath) - 1] == '%'
	cOperator = szNewMath[0]
   
	if(!isdigit(szNewMath[0]))
		szNewMath[0] = ' '
   
	if(bPercent)
		replace(szNewMath, charsmax(szNewMath), "%", "")
	   
	trim(szNewMath)
	fMath = str_to_float(szNewMath)
   
	if(bPercent)
		fMath *= fNum / 100
	   
	switch(cOperator)
	{
		case '+': fNum += fMath
		case '-': fNum -= fMath
		case '/': fNum /= fMath
		case '*': fNum *= fMath
		default: fNum = fMath
	}
   
	return fNum
}  
