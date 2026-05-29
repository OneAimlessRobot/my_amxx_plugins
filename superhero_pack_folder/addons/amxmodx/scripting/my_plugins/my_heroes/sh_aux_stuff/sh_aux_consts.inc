#if defined sh_aux_consts
  #endinput
#endif
#define sh_aux_consts

#define Struct enum


#define MAX_MAP_DIST_POSSIBLE (8192.0*floatsqroot(3.0))

/*
 first param is cube side length

*/
#define CENTER_CUBE_VEX_DISTANCE(%1) (%1*floatsqroot(3.0))

#define SH_HUD_MSG_BUFF_SIZE 128

#define STRLEN_FOR_FILES 128
#define STRLEN_FOR_NAMES 24


#define MINI_STRING_SIZE 32
#define STRING_SIZE 128
#define BIG_STRING_SIZE (STRING_SIZE*4)
/**

	Useful macro to shorten code!
	the first parameter is the user.
	We will first check if they are alive
	And then the next parameter is the hero id.
	We will they check if they have that hero!
	It can be a hero that obtains a hero id
	Or an actual hero id
	It does not matter as long as the result is anything
	previously returned by either
	shCreateHero
	Or sh_create_hero
 */
#define client_is_hero_user(%1,%2) (is_user_alive(%1)&&sh_get_user_has_hero(%1,%2))


#define cvar_val(%1,%2) get_pcvar_%1(%2)

#define ANTI_LAGG		7


#define PRIMARY_WEAPONS_BIT_SUM  ((1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90))

#define SECONDARY_WEAPONS_BIT_SUM  ((1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE))

#define NO_RECOIL_WEAPONS_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define GUNS_BIT_SUM ((1<<CSW_P228) | (1<<CSW_SCOUT) | (1<<CSW_XM1014) | (1<<CSW_MAC10) | (1<<CSW_AUG) | (1<<CSW_ELITE) | (1<<CSW_FIVESEVEN) | (1<<CSW_UMP45) | (1<<CSW_SG550) | (1<<CSW_GALIL) | (1<<CSW_FAMAS) | (1<<CSW_USP) | (1<<CSW_GLOCK18) | (1<<CSW_AWP) | (1<<CSW_MP5NAVY) | (1<<CSW_M249) | (1<<CSW_M3) | (1<<CSW_M4A1) | (1<<CSW_TMP) | (1<<CSW_G3SG1) | (1<<CSW_DEAGLE) | (1<<CSW_SG552) | (1<<CSW_AK47) | (1<<CSW_P90))

#define FAST_RELOAD_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define NOCLIP_WPN_BS	((1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))

#define BURSTGUNS_BIT_SUM ((1<<CSW_FAMAS) | (1<<CSW_GLOCK18))

#define SHOTGUNS_BS	((1<<CSW_M3)|(1<<CSW_XM1014))

#define SILENT_BS	((1<<CSW_USP)|(1<<CSW_M4A1))

#define RIFLES_BS	((1<<CSW_SCOUT)|(1<<CSW_AUG)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_M249)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47))

#define single_shot_wpns_bs (GUNS_BIT_SUM& (~(SHOTGUNS_BS)))

#define is_weaponid_valid(%1) ((%1>0)&&(%1<=CSW_LAST_WEAPON))


//player flags

#define TOUCHING_GROUND (1<<9)
#define FL_INGROUND2 TOUCHING_GROUND

#if !defined reapi_included 
	//player offsets

	#define XTRA_OFS_PLAYER	5 // linux offset to be used on pdatas with player entities
	#define OFFSET_LINUX_PLAYER 5 // linux offset to be used on pdatas with player entities

										//add these offsets in the correct parameter


	#define fPainShock 108					//player pain shock offset
	#define m_rgAmmo_player_Slot0  376			//how much ammo does player have in slot 0?
	/**
	Example in how to use this:

	if(iWeaponEntity > 0)
	{
		iAmmoType = m_rgAmmo_player_Slot0 + 
				get_pdata_int(iWeaponEntity, m_iPrimaryAmmoType, XTRA_OFS_WEAPON)
		
		iAmmo = get_pdata_int(iWeaponEntity, m_iClip, XTRA_OFS_WEAPON)
		
		iMagazine = get_pdata_int(iBotIdentity, iAmmoType, XTRA_OFS_PLAYER)
		
		give_item(iPlayer, szWeaponName)
		
		set_pdata_int(iPlayer, iAmmoType, iMagazine, XTRA_OFS_PLAYER)
		
		set_pdata_int(iWeaponEntity, m_iClip, iAmmo, XTRA_OFS_WEAPON)
	}

	*/

	#define m_flNextAttack 83					//when is next user attack allowed with any weapon?

	#define m_rgpPlayerItems_Slot0 367		//what item id does player have in slot 0?
	#define m_pActiveItem 373				//what item is user holding?

	#define m_bResumeZoom 440				//the linux offset should be multiplied by 4 
													//as well as this constant.
													//as it refers to a place in memory which is a single byte in size

	#define m_szAnimExtention 492             //its animation related, definitely
													//this is also multiplied by 4
													//as it is byte sized. (its a string)

	// weapons offsets

	#define XO_WEAPON  4 						//linux offset to be used on pdatas with weapon/item entities


	#define m_flNextPrimaryAttack    46		//when is the next weapon primary attack?

	#define m_fKnown 44 						//idk what this is
	#define m_iPrimaryAmmoType	49			//ammo type in current weapon.
													// 5.56 nato box in Colt m4a1 for example
	#define m_fSilent 74						//is weapon silenced?

	#define m_flNextSecondaryAttack    47		//when is the next weapon secondary attack?
	#define m_fInReload            54 		//is magazine weapon reloading? 
	#define m_iClip 51 						//number of ammo in clip
	#define m_fInSpecialReload 55 			//is shotgun reloading? (1 by 1)
	#define m_pNext 42
	#define m_flTimeWeaponIdle        48
	#define m_iId                43 			// pdata offset for item id (CSW_AWP, CSW_KNIFE, etc.)
	#define m_pPlayer            41 			// pdata offset for item owner
	#define m_iShellId			57 				// shell id for this weapon
	#define m_flEjectBrass     111              // eject brass delay for this weapon

	#define FlameAndSoundRate 10
#endif

enum cs_grenade_animation_sequences{

	cs_grenade_idle = 0,
	cs_grenade_pullpin,
	cs_grenade_throw,
	cs_grenade_deploy


}
#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)

#define FROZEN_SFX "shmod/frostnova.wav" 
#define PIERCE_WOUND_SFX "hornet/ag_hornethit1.wav"
#define THROWABLE_LAUNCH_SFX "shmod/lara/spear/spear_throw.wav"
#define CUSTOM_GRENADE_BOUNCE_SOUND "shmod/Teliko/chaff/bounce.wav"
#define SMOKE_EXPLODE_SOUND "shmod/yakui/rocket.wav"
#define GLASS_VIAL_BREAK "shmod/erica/molotov/molotov_crack.wav"
#define GLASS_BREAK_SFX "shmod/Teliko/counter.wav"
#define SLICERISTA_HIT_MEAT_SFX "shmod/Grimpt2/Stolen2.wav"
#define LASER_LINE_DEFAULT_SOUND "weapons/electro5.wav"
#define crush_stunned "shmod/Teliko/chaff/chaff_blow.wav"
#define SUCK_IN_SOUND_FILE_NAME "ambience/particle_suck2.wav"
#define NULL_SOUND "common/null.wav"
#define SPORE_HEAL_SFX "shmod/ration.wav"
#define EXPLOSION_TANK_SHOT_SOUND "shmod/a_exm2.wav"



#define SPHERE_MODEL "models/shmod/jaqueo/shield/shield.mdl"
/**

Explosion sfx masks!

*/

enum explosion_sfx_flags (<<= 1){
	sfx_show_nothing = 0,
	sfx_show_shockwave = 1,
	sfx_show_fireball,
	sfx_show_smoke,
	sfx_show_burn_decal,
	sfx_show_custom_sound

}



//Colors To Pick From
enum sh_custom_color{
		CUSTOM=0,
		RED,
		GREEN,
		BLUE,
		LTBLUE,
		YELLOW,
		PURPLE,
		ORANGE,
		WHITE,
		PINK,
		LTGREEN,
		INVIS,
		BLACK,
		MAGENTA,
		FROZEN_BLUE,
		FX_NONE,
		FX_KILL,
		FX_GLOW,
		FX_POISON,
		FX_STUN,
		FX_RADIOACTIVE,
		FX_MORPHINE,
		FX_WEED,
		FX_COCAINE,
		FX_BLIND,
		FX_METYLPHENIDATE,
		FX_BATH,
}



#define BLOOD_COLOR_RED		247
#define BLOOD_COLOR_YELLOW	195
#define BLOOD_STREAM_RED	70
#define BLOOD_STREAM_YELLOW	60
#define BLOOD_SM_NUM 8
#define BLOOD_LG_NUM 2

stock blood_large_red[BLOOD_LG_NUM] = {204,205},
	blood_small_red[BLOOD_SM_NUM] = {190,191,192,193,194,195,196,197}


stock const burn_decal[5] = {199,200,201,202,203}
stock const g_burnDecal[3] = {28, 29, 30}
stock const g_burnDecalBig[3] = {46, 47, 48}
stock const g_czero_burnDecal[5] = {53, 54, 55, 56, 57}
stock const g_cs_burnDecal[5] = {41, 42, 43, 44, 45}


stock Offset[8][3] = {{0,0,10},{0,0,30},{0,0,16},{0,0,10},{4,4,16},{-4,-4,16},{4,4,-12},{-4,-4,-12}}

//Color definitions
stock const LineColors[sh_custom_color][3] = {
	{150, 150, 150},	//Custom
	{255, 0, 0},		//Red
	{0, 255, 0},		//Green
	{0, 0, 255},		//Blue
	{0, 255, 255},		//Light Blue
	{255, 255, 0},		//Yellow
	{255, 0, 255},		//Purple
	{255, 128, 0},		//Orange
	{255, 255, 255},	//White
	{250, 92, 163},      //Pink
	{111,255,111},      //Light Green
	{10,10,10},      //invisible
	{1,1,1},      //Black
	{255,0,127},      //Magenta
	{5, 30, 125}, //Frozen Blue
	{0,0,0}, //fx_none
	{1, 255, 255}, //fx_cyanide
	{255, 255, 255}, //fx_glow
	{80, 240, 30},	//fx_poison
	{100, 100, 100}, //fx_stun
	{240, 80, 30}, //fx_radioactive
	{80, 240, 1}, //fx_morphine
	{80, 240, 90}, //fx_weed
	{250, 10, 30},  //fx_cocaine
	{255, 255, 255}, //fx_blind
	{50, 50, 50},  //fx_metylphenidate
	{179, 66, 5} //fx_bath
}


stock const Float:g_fPrimaryAttackDelay[CSW_LAST_WEAPON+1] = {
					
					0.000000,
					0.150000,
					0.000000,
					1.250000,
					0.000000,
					0.250000,
					0.000000,
					0.070000,
					0.082500,
					0.000000,
					0.122000,
					0.150000,
					0.100000,
					0.250000,
					0.087499,
					0.082500,
					0.149999,
					0.150000,
					1.450000,
					0.075000,
					0.100000,
					0.875000,
					0.087499,
					0.070000,
					0.250000,
					0.000000,
					0.225000,
					0.082500,
					0.095499,
					0.000000,
					0.065999
}
stock const Float:g_fSecondaryAttackDelay[CSW_LAST_WEAPON+1] = {
					
					0.000000,
					0.150000,
					0.000000,
					0.300000,
					0.000000,
					0.250000,
					0.000000,
					0.070000,
					0.300000,
					0.000000,
					0.122000,
					0.150000,
					0.100000,
					0.300000,
					0.087499,
					0.300000,
					3.130000,
					0.300000,
					0.300000,
					0.075000,
					0.100000,
					0.875000,
					2.000000,
					0.070000,
					0.300000,
					0.000000,
					0.225000,
					0.300000,
					0.095499,
					0.000000,
					0.065999
}
stock const g_ammo_ids_for_weapon_ids[CSW_LAST_WEAPON+1]={
					0,
					9,
					0,
					2,
					12,
					5,
					0,
					6,
					4,
					13,
					10,
					7,
					6,
					4,
					4,
					4,
					6,
					10,
					1,
					10,
					3,
					5,
					4,
					10,
					2,
					11,
					8,
					4,
					2,
					0,
					7

}
stock const Float:g_fReloadDelay[CSW_LAST_WEAPON+1] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50, 
	2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70, 
	0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}

new stock const g_iDftMaxClip[CSW_LAST_WEAPON+1] = {
	-1,  13, -1, 10,  1,  7,    1, 30, 30,  1,  30, 
		20, 25, 30, 35, 25,   12, 20, 10, 30, 100, 
		8 , 30, 30, 20,  2,    7, 30, 30, -1,  50
}

stock const g_iReloadAnims[CSW_LAST_WEAPON+1] = {
	-1,  5, -1, 3, -1,  6,   -1, 1, 1, -1, 14, 
		4,  2, 3,  1,  1,   13, 7, 4,  1,  3, 
		6, 11, 1,  3, -1,    4, 1, 1, -1,  1
}

stock const player_vector[][]={"player"},
			breakable_vector[][]={"func_breakable"},
			hostage_vector[][]={"hostage_entity"},
			hurtable_vector[][]={"func_breakable","hostage_entity"},
			szWallEntities[][] = {
					"worldspawn", "func_wall", "func_door",  "func_door_rotating",
					"func_wall_toggle", "func_breakable", "func_pushable", "func_train",
					"func_illusionary", "func_button", "func_rot_button", "func_rotating"
				},
			
			full_entity_array_for_trace_attack[][] = {
				
				"player",
				"worldspawn",
				"func_wall",
				"func_door",
				"func_door_rotating",
				"func_wall_toggle",
				"func_breakable",
				"func_pushable",
				"func_train",
				"func_illusionary",
				"func_button",
				"func_rot_button",
				"func_rotating",
				"func_breakable",
				"hostage_entity"



			},
			full_entity_array_except_player[][] = {
				
				"worldspawn",
				"func_wall",
				"func_door",
				"func_door_rotating",
				"func_wall_toggle",
				"func_breakable",
				"func_pushable",
				"func_train",
				"func_illusionary",
				"func_button",
				"func_rot_button",
				"func_rotating",
				"func_breakable",
				"hostage_entity"



			},

			player_worldspawn_array[][]={
				
				"worldspawn",
				"player"
			}
#define length_of_trace_attack_entity_array 15

stock Float:null_vector[3]={0.0,0.0,0.0}
stock null_iVector[3]={0,0,0}

stock Float:x_vector[3]={1.0,0.0,0.0}
stock x_iVector[3]={1,0,0}
stock Float:y_vector[3]={0.0,1.0,0.0}
stock y_iVector[3]={0,1,0}
stock Float:z_vector[3]={0.0,0.0,1.0}
stock z_iVector[3]={0,0,1}


