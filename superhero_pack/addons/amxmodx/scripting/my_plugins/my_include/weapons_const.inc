#if defined _weapons_const_included
#endinput
#endif
#define _weapons_const_included

#define WEAPON_IS_ONTARGET 0x40

#define WEAPON_NOCLIP -1

#define LOUD_GUN_VOLUME 1000
#define NORMAL_GUN_VOLUME 600
#define QUIET_GUN_VOLUME 200

#define BRIGHT_GUN_FLASH 512
#define NORMAL_GUN_FLASH 256
#define DIM_GUN_FLASH 128

#define BIG_EXPLOSION_VOLUME 2048
#define NORMAL_EXPLOSION_VOLUME 1024
#define SMALL_EXPLOSION_VOLUME 512

#define WEAPON_ACTIVITY_VOLUME 64

#define STRN_P228 "weapon_p228"
#define STRN_SCOUT "weapon_scout"
#define STRN_HEGRENADE "weapon_hegrenade"
#define STRN_XM1014 "weapon_xm1014"
#define STRN_C4 "weapon_c4"
#define STRN_MAC10 "weapon_mac10"
#define STRN_AUG "weapon_aug"
#define STRN_SMOKEGRENADE "weapon_smokegrenade"
#define STRN_ELITE "weapon_elite"
#define STRN_FIVESEVEN "weapon_fiveseven"
#define STRN_UMP45 "weapon_ump45"
#define STRN_SG550 "weapon_sg550"
#define STRN_GALIL "weapon_galil"
#define STRN_FAMAS "weapon_famas"
#define STRN_USP "weapon_usp"
#define STRN_GLOCK18 "weapon_glock18"
#define STRN_AWP "weapon_awp"
#define STRN_MP5N "weapon_mp5navy"
#define STRN_M249 "weapon_m249"
#define STRN_M3 "weapon_m3"
#define STRN_M4A1 "weapon_m4a1"
#define STRN_TMP "weapon_tmp"
#define STRN_G3SG1 "weapon_g3sg1"
#define STRN_FLASHBANG "weapon_flashbang"
#define STRN_DEAGLE "weapon_deagle"
#define STRN_SG552 "weapon_sg552"
#define STRN_AK47 "weapon_ak47"
#define STRN_KNIFE "weapon_knife"
#define STRN_P90 "weapon_p90"

#define AMMOID_P228 9
#define AMMOID_SCOUT 2
#define AMMOID_HEGRENADE 12
#define AMMOID_XM1014 5
#define AMMOID_C4 14
#define AMMOID_MAC10 6
#define AMMOID_AUG 4
#define AMMOID_SMOKEGRENADE 13
#define AMMOID_ELITE 10
#define AMMOID_FIVESEVEN 7
#define AMMOID_UMP45 6
#define AMMOID_SG550 4
#define AMMOID_GALIL 4
#define AMMOID_FAMAS 4
#define AMMOID_USP 6
#define AMMOID_GLOCK18 10
#define AMMOID_AWP 1
#define AMMOID_MP5N 10
#define AMMOID_M249 3
#define AMMOID_M3 5
#define AMMOID_M4A1 4
#define AMMOID_TMP 10
#define AMMOID_G3SG1 2
#define AMMOID_FLASHBANG 11
#define AMMOID_DEAGLE 8
#define AMMOID_SG552 4
#define AMMOID_AK47 2
#define AMMOID_KNIFE -1
#define AMMOID_P90 7

#define MAXAMMO_P228 52
#define MAXAMMO_SCOUT 90
#define MAXAMMO_HEGRENADE 1
#define MAXAMMO_XM1014 32
#define MAXAMMO_C4 1
#define MAXAMMO_MAC10 100
#define MAXAMMO_AUG 90
#define MAXAMMO_SMOKEGRENADE 1
#define MAXAMMO_ELITE 120
#define MAXAMMO_FIVESEVEN 100
#define MAXAMMO_UMP45 100
#define MAXAMMO_SG550 90
#define MAXAMMO_GALIL 90
#define MAXAMMO_FAMAS 90
#define MAXAMMO_USP 100
#define MAXAMMO_GLOCK18 120
#define MAXAMMO_AWP 30
#define MAXAMMO_MP5N 120
#define MAXAMMO_M249 200
#define MAXAMMO_M3 32
#define MAXAMMO_M4A1 90
#define MAXAMMO_TMP 120
#define MAXAMMO_G3SG1 90
#define MAXAMMO_FLASHBANG 2
#define MAXAMMO_DEAGLE 35
#define MAXAMMO_SG552 90
#define MAXAMMO_AK47 90
#define MAXAMMO_KNIFE -1
#define MAXAMMO_P90 100

#define SLOT_PRIMARY 0
#define SLOT_SECONDARY 1
#define SLOT_KNIFE 2
#define SLOT_GRENADE 3
#define SLOT_C4 4

#define FLAG_SELECTONEMPTY (1<<0)
#define FLAG_NOAUTORELOAD (1<<1)
#define FLAG_NOAUTOSWITCHEMPTY (1<<2)
#define FLAG_LIMITINWORLD (1<<3)
#define FLAG_EXHAUSTIBLE (1<<4)

#define FLAG_NONE 0
#define FLAG_GRENADEANDC4 (FLAG_LIMITINWORLD|FLAG_EXHAUSTIBLE)

#define ID_P228 1
#define ID_SCOUT 3
#define ID_HEGRENADE 4
#define ID_XM1014 5
#define ID_C4 6
#define ID_MAC10 7
#define ID_AUG 8
#define ID_SMOKEGRENADE 9
#define ID_ELITE 10
#define ID_FIVESEVEN 11
#define ID_UMP45 12
#define ID_SG550 13
#define ID_GALIL 14
#define ID_FAMAS 15
#define ID_USP 16
#define ID_GLOCK18 17
#define ID_AWP 18
#define ID_MP5N 19
#define ID_M249 20
#define ID_M3 21
#define ID_M4A1 22
#define ID_TMP 23
#define ID_G3SG1 24
#define ID_FLASHBANG 25
#define ID_DEAGLE 26
#define ID_SG552 27
#define ID_AK47 28
#define ID_KNIFE 29
#define ID_P90 30

#define POSITION_P228 3
#define POSITION_SCOUT 9
#define POSITION_HEGRENADE 1
#define POSITION_XM1014 12
#define POSITION_C4 3
#define POSITION_MAC10 13
#define POSITION_AUG 14
#define POSITION_SMOKEGRENADE 3
#define POSITION_ELITE 5
#define POSITION_FIVESEVEN 6
#define POSITION_UMP45 15
#define POSITION_SG550 16
#define POSITION_GALIL 17
#define POSITION_FAMAS 18
#define POSITION_USP 4
#define POSITION_GLOCK18 2
#define POSITION_AWP 2
#define POSITION_MP5N 7
#define POSITION_M249 4
#define POSITION_M3 5
#define POSITION_M4A1 6
#define POSITION_TMP 11
#define POSITION_G3SG1 3
#define POSITION_FLASHBANG 2
#define POSITION_DEAGLE 1
#define POSITION_SG552 10
#define POSITION_AK47 1
#define POSITION_KNIFE 1
#define POSITION_P90 8