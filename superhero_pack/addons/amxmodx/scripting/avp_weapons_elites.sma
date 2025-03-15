#include <amxmodx>
#include <fun>
#include <cstrike>
#include <aliens_vs_predator>

new const PLUGIN_VERSION[] = "1.0";

enum _:WeaponData
{
	WeaponName[32],
	WeaponEnt[32],
	WeaponType,
};

/*
new const AVPWEAPONS[][WeaponData] = {
	{ "P228 Compact", "weapon_p228", AVP_SECONDARY_WEAPON },
	{ "Schmidt Scout", "weapon_scout", AVP_PRIMARY_WEAPON },
	{ "XM1014 M4", "weapon_xm1014", AVP_PRIMARY_WEAPON },
	{ "Ingram MAC-10", "weapon_mac10", AVP_PRIMARY_WEAPON },
	{ "Steyr AUG A1", "weapon_aug", AVP_PRIMARY_WEAPON },
	{ "Dual Elite Berettas", "weapon_elite", AVP_SECONDARY_WEAPON },
	{ "FiveseveN", "weapon_fiveseven", AVP_SECONDARY_WEAPON },
	{ "UMP 45", "weapon_ump45", AVP_PRIMARY_WEAPON },
	{ "SG-550 Auto-Sniper", "weapon_sg550", AVP_PRIMARY_WEAPON },
	{ "IMI Galil", "weapon_galil", AVP_PRIMARY_WEAPON },
	{ "Famas", "weapon_famas", AVP_PRIMARY_WEAPON },
	{ "USP .45 ACP Tactical", "weapon_usp", AVP_SECONDARY_WEAPON },
	{ "Glock 18C", "weapon_glock18", AVP_SECONDARY_WEAPON },
	{ "AWP Magnum Sniper", "weapon_awp", AVP_PRIMARY_WEAPON },
	{ "MP5 Navy", "weapon_mp5navy", AVP_PRIMARY_WEAPON },
	{ "M249 Para Machinegun", "weapon_m249", AVP_PRIMARY_WEAPON },
	{ "M3 Super 90", "weapon_m3", AVP_PRIMARY_WEAPON },
	{ "M4A1 Carbine", "weapon_m4a1", AVP_PRIMARY_WEAPON },
	{ "Schmidt TMP", "weapon_tmp", AVP_PRIMARY_WEAPON },
	{ "G3SG1 Auto-Sniper", "weapon_g3sg1", AVP_PRIMARY_WEAPON },
	{ "Desert Eagle .50 AE", "weapon_deagle", AVP_SECONDARY_WEAPON },
	{ "SG-552 Commando", "weapon_sg552", AVP_PRIMARY_WEAPON },
	{ "AK-47 Kalashnikov", "weapon_ak47", AVP_PRIMARY_WEAPON },
	{ "ES P90", "weapon_p90", AVP_PRIMARY_WEAPON }
};
*/

public plugin_init()
{
	register_plugin("[AvP] Default CS Weapons", PLUGIN_VERSION, "Crazy");

//	for (new i = 0; i < sizeof AVPWEAPONS; i++)
//		avp_register_weapon(AVPWEAPONS[i][WeaponName], AVPWEAPONS[i][WeaponEnt], AVPWEAPONS[i][WeaponType]);
		avp_register_weapon("Dual Elite Berettas", "weapon_elite", AVP_SECONDARY_WEAPON)
}

public weapon_p228(id)
{
	give_item(id, "weapon_p228");
	cs_set_user_bpammo(id, CSW_P228, 52);
}

public weapon_scout(id)
{
	give_item(id, "weapon_scout");
	cs_set_user_bpammo(id, CSW_SCOUT, 90);
}

public weapon_xm1014(id)
{
	give_item(id, "weapon_xm1014");
	cs_set_user_bpammo(id, CSW_XM1014, 32);
}

public weapon_mac10(id)
{
	give_item(id, "weapon_mac10");
	cs_set_user_bpammo(id, CSW_MAC10, 100);
}

public weapon_aug(id)
{
	give_item(id, "weapon_aug");
	cs_set_user_bpammo(id, CSW_AUG, 90);
}

public weapon_elite(id)
{
	give_item(id, "weapon_elite");
	cs_set_user_bpammo(id, CSW_ELITE, 120);
}

public weapon_fiveseven(id)
{
	give_item(id, "weapon_fiveseven");
	cs_set_user_bpammo(id, CSW_FIVESEVEN, 100);
}

public weapon_ump45(id)
{
	give_item(id, "weapon_ump45");
	cs_set_user_bpammo(id, CSW_UMP45, 100);
}

public weapon_sg550(id)
{
	give_item(id, "weapon_sg550");
	cs_set_user_bpammo(id, CSW_SG550, 90);
}

public weapon_galil(id)
{
	give_item(id, "weapon_galil");
	cs_set_user_bpammo(id, CSW_GALIL, 90);
}

public weapon_famas(id)
{
	give_item(id, "weapon_famas");
	cs_set_user_bpammo(id, CSW_FAMAS, 90);
}

public weapon_usp(id)
{
	give_item(id, "weapon_usp");
	cs_set_user_bpammo(id, CSW_USP, 100);
}

public weapon_glock18(id)
{
	give_item(id, "weapon_glock18");
	cs_set_user_bpammo(id, CSW_GLOCK18, 120);
}

public weapon_awp(id)
{
	give_item(id, "weapon_awp");
	cs_set_user_bpammo(id, CSW_AWP, 30);
}

public weapon_mp5navy(id)
{
	give_item(id, "weapon_mp5navy");
	cs_set_user_bpammo(id, CSW_MP5NAVY, 120);
}

public weapon_m249(id)
{
	give_item(id, "weapon_m249");
	cs_set_user_bpammo(id, CSW_M249, 200);
}

public weapon_m3(id)
{
	give_item(id, "weapon_m3");
	cs_set_user_bpammo(id, CSW_M3, 32);
}

public weapon_m4a1(id)
{
	give_item(id, "weapon_m4a1");
	cs_set_user_bpammo(id, CSW_M4A1, 90);
}

public weapon_tmp(id)
{
	give_item(id, "weapon_tmp");
	cs_set_user_bpammo(id, CSW_TMP, 120);
}

public weapon_g3sg1(id)
{
	give_item(id, "weapon_g3sg1");
	cs_set_user_bpammo(id, CSW_G3SG1, 90);
}

public weapon_deagle(id)
{
	give_item(id, "weapon_deagle");
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
}

public weapon_sg552(id)
{
	give_item(id, "weapon_sg552");
	cs_set_user_bpammo(id, CSW_SG552, 90);
}

public weapon_ak47(id)
{
	give_item(id, "weapon_ak47");
	cs_set_user_bpammo(id, CSW_AK47, 90);
}

public weapon_p90(id)
{
	give_item(id, "weapon_p90");
	cs_set_user_bpammo(id, CSW_P90, 100);
}
