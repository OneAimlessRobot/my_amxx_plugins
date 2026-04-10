#if defined sh_aux_consts
  #endinput
#endif
#define sh_aux_consts


/*new g_msgFade,victim_dmg_hud_msg_sync, attacker_dmg_hud_msg_sync
new white, fire,gSpriteLaser,blood1,blood2,g_iFireSprite, g_iSmokeSprite[2];*/



#define ANTI_LAGG		7

#define MATH_PI  3.1415926535897932384626433832795028841971


#define NO_RECOIL_WEAPONS_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))
#define FAST_RELOAD_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

// weapons offsets

#define TOUCHING_GROUND (1<<9)
stock const PDATA_SAFE = 2
stock const XO_WEAPON = 4
stock const OFFSET_LINUX_PLAYER = 5
stock const FL_INGROUND2=TOUCHING_GROUND
stock const fPainShock = 108
stock const m_flNextPrimaryAttack    = 46
stock const m_flNextSecondaryAttack    = 47
stock const m_fInReload            = 54
stock const m_pNext = 42
stock const m_rgpPlayerItems_Slot0 = 367

#if !defined _reapi_included 
	stock const m_pActiveItem = 373;
	stock const m_flTimeWeaponIdle        = 48
	stock const m_flNextAttack = 83
	stock const m_szAnimExtention = 492
	stock const m_iId                = 43
	stock const m_pPlayer            = 41
#endif

#define FlameAndSoundRate 10

#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)
#define SLICERISTA_HIT_MEAT_SFX "shmod/Grimpt2/Stolen2.wav"
#define LASER_LINE_DEFAULT_SOUND "weapons/electro5.wav"
#define crush_stunned "shmod/Teliko/chaff/chaff_blow.wav"
#define SUCK_IN_SOUND_FILE_NAME "ambience/particle_suck2.wav"
#define NULL_SOUND "common/null.wav"
#define SPORE_HEAL_SFX "shmod/ration.wav"
#define EXPLOSION_TANK_SHOT_SOUND "shmod/a_exm2.wav"
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
		COLORS_NUM
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

stock Offset[8][3] = {{0,0,10},{0,0,30},{0,0,16},{0,0,10},{4,4,16},{-4,-4,16},{4,4,-12},{-4,-4,-12}}

//Color definitions
stock const LineColors[_:COLORS_NUM][3] = {
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
	{10, 10, 10},  //fx_metylphenidate
	{179, 66, 5} //fx_bath
}
stock const Float:g_fReloadDelay[CSW_P90+1] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50, 
	2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70, 
	0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}
stock Float:null_vector[3]={0.0,0.0,0.0}
stock null_iVector[3]={0,0,0}

stock Float:x_vector[3]={1.0,0.0,0.0}
stock x_iVector[3]={1,0,0}
stock Float:y_vector[3]={0.0,1.0,0.0}
stock y_iVector[3]={0,1,0}
stock Float:z_vector[3]={0.0,0.0,1.0}
stock z_iVector[3]={0,0,1}


