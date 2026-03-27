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
stock const m_pppPlayer            = 41
stock const m_iiId                = 43
stock const m_fflNextPrimaryAttack    = 46
stock const m_fflNextSecondaryAttack    = 47
stock const m_fflTimeWeaponIdle        = 48
stock const m_ffInReload            = 54
stock const m_fflNextAttack = 83

#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)
#define LASER_LINE_DEFAULT_SOUND "weapons/electro5.wav"
#define crush_stunned "shmod/Teliko/chaff/chaff_blow.wav"
#define SUCK_IN_SOUND_FILE_NAME "ambience/particle_suck2.wav"
#define NULL_SOUND "common/null.wav"

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
		COLORS_NUM
}
#define NULL_SOUND_FILENAME "common/null.wav"

#define BLOOD_COLOR_RED		247
#define BLOOD_COLOR_YELLOW	195
#define BLOOD_STREAM_RED	70
#define BLOOD_STREAM_YELLOW	60
#define BLOOD_SM_NUM 8
#define BLOOD_LG_NUM 2
stock blood_large_red[BLOOD_LG_NUM] = {204,205},
	blood_small_red[BLOOD_SM_NUM] = {190,191,192,193,194,195,196,197}


stock const burn_decal[5] = {199,200,201,202,203}
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
	{111,255,111}      //Light Green
}
stock const LineColorsWithAlpha[_:COLORS_NUM][4] = {
	{150, 150, 150,255},	//Custom
	{255, 0, 0,255},		//Red
	{0, 255, 0,100},		//Green
	{0, 0, 255,255},		//Blue
	{0, 255, 255,255},		//Light Blue
	{255, 255, 0,255},		//Yellow
	{255, 0, 255,255},		//Purple
	{255, 128, 0,255},		//Orange
	{255, 255, 255,255},	//White
	{250, 92, 163,255},      //Pink
	{111,255,111,40}      //Light Green
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


