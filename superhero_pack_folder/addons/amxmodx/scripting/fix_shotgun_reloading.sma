
// Include
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>

#define PDATA_SAFE 2

#define m_Item							4
#define m_flNextPrimaryAttack			46
#define m_iClip							51
#define m_iInSpecialReload				55

new g_pDelayReloadShoot;

public plugin_init()
{
	register_plugin( "Fix CS Shotgun Bugs", "1.0", "Nani" )

	new const sz_WeaponEnt[][] =
	{
		"weapon_xm1014",
		"weapon_m3"
	}

	for ( new i = 0; i < sizeof sz_WeaponEnt; i++ )
	{
		RegisterHam( Ham_Weapon_PrimaryAttack, sz_WeaponEnt[ i ], "fwHamWeaponPrimaryAttackPre", false )
		RegisterHam( Ham_Item_Deploy, sz_WeaponEnt[ i ], "fwHamItemDeployPre", false )
	}

	g_pDelayReloadShoot = register_cvar( "shotgun_reload_shoot_delay", "0.20" );
}

public fwHamWeaponPrimaryAttackPre( i_Ent )
{
	if ( pev_valid( i_Ent ) != PDATA_SAFE )
	{
		return HAM_IGNORED;
	}
	
	new i_Clip = get_pdata_int( i_Ent, m_iClip, m_Item );

	if ( i_Clip <= 0 )
	{
		ExecuteHam( Ham_Weapon_Reload, i_Ent )

		set_pdata_float( i_Ent, m_flNextPrimaryAttack, get_pcvar_float( g_pDelayReloadShoot ), m_Item )

		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public fwHamItemDeployPre( i_Ent )
{
	if ( pev_valid( i_Ent ) != PDATA_SAFE )
	{
		return HAM_IGNORED;
	}

	set_pdata_int( i_Ent, m_iInSpecialReload, 0, m_Item )

	return HAM_IGNORED;
}