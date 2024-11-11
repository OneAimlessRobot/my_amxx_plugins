/*==================================================================================================================================================================================================================================================
											[Plugin Edited/Made By]

||||||||             |||||||							||||||||             |||||||	     ||||||||		|||||||			     ||||||||		|||||||            ||||||||	     ||||||||
||	||||||||||| 	  ||		     	     ||||			||	||||||||||||	  ||	     ||	     ||||||||||	     ||			     ||	    ||||||||||||     ||		   ||	   ||	   ||	   ||
||	||	  ||	  ||			     ||				||           ||		  ||	     ||	    ||		     ||			     ||	    ||	      ||     ||            ||	   ||	   ||	   ||
||	||	   || 	  ||			     ||				||           ||		  ||	     ||	    ||		     ||  		     ||	    || |||||  ||     ||            ||	   ||	   ||	   ||
||	||	   || 	  ||	||||||||  |||||||| ||||||| ||||||||  ||||||||	||           ||		  ||	     ||      ||||||||||	     ||  ||||||||  ||||||||  ||     || || ||  ||     ||  |||||||   ||	   ||||||||||	   ||
||	||||||||||||  	  ||	||    ||  ||	     ||    ||    ||  ||		||           ||		  ||	     ||		      ||     ||	 ||	   ||	     ||	    || |||||| ||     || ||         ||	   ||	   ||	   ||
||	||	      	  ||	||||||||  ||	     ||    ||||||||  ||		||           ||		  ||	     ||		      ||     ||	 ||	   ||	     ||     ||	      ||     || ||||||||   ||	   ||	   ||	   ||
||	||	      	  ||	||        ||	     ||    ||        ||		||           ||		  ||	     ||	     ||||||||||	     ||	 ||        ||        ||     ||||||||||||     ||        ||  ||	   ||	   ||	   ||
||	||	      	  ||	||||||||  ||	     ||    ||||||||  ||||||||	||||||||	     |||||||	     ||||||||		|||||||  ||||||||  ||        ||||||||		||||||| ||||||||   ||||||||	     ||||||||
||||||||	     |||||||
	
		=|-----------------------------------------------------------------------------------------------------------------------------------------------------|=
				
											----------[Change Logs]----------
								* 1.0:
									- First Version.
								* 1.1:
									- Fixed bug that Lasermine Dont Works.
									- Show Lasermine Owner Name.
									- Make Random Color Of Glow/Line in raibom style (When Enable).
								* 1.2:
									- Fixed Bug: When Player Die and Lasermine dont removed
									- Fixed Bug: Cant Plant If your Lasermine destroyed one time
								* 1.3:
									- Added: Solid Mode
								* 1.4:
									- Fixed Some Bugs
									- Added Natives and Forwards
								* 2.0:
									- Fixed Some Error Logs.
								* 2.1:
									- Fixed Some Bugs.
									- Added More Cvars for Easily Config.
								* 2.2:
									- Fixed More Error Logs
									- Added Lasermine Main Menu for Personal Configuration
								* 2.3:
									- Fixed bug when R,G,B are equal to 0 for make line invisible
									- Fixed bug when some time radius crashes the server
									- New Main Menu Options (Choose Sprites/Models)
								* 3.0:
									- Added More Models
									- Added Lang Support
								* 3.1:
									- Added More Sprites
								* 3.2/3.3:
									- Fixed More Error Logs
									- Added More Cvars for Easily Config.
								* 3.4:
									- Fixed More Error Logs
									- Added Model "Perfect Lasermine"
								* 4.0:
									- Fixed Some error logs
									- Fixed Small bug when plant lasermine and lasermine does not stay in the wall
									- Added one Cvar for define the max distance for remove the Lasermine
									- Adicionado um esquema para matar o Boss Na Lasermine
									- Added mode for lasermine can kill entities (Like Oberon Boss and Others)
								* 4.1:
									- Improved Code
									- Fixed Lang
								* 4.2:
									- Added more Models/Sprites for Lasermine
									- Added Realistic Detail of Lasermine (Cut the laser mine when it passes over)
									- End of Style "Rainbow" for Reduce Lag
									- Fixed Native/Cvar Error Logs
									- Improved Code
									- Fixed Forward "zp_fw_lm_planted_pre"
									- Removed CZ Tutor Print (Because some steam players have bug when show tutor in screen)

											----------[Credits]----------
								- [P]erfec[T] [S]cr[@]s[H]: For Editing and Posting this Plugin
								- SandStriker: For Original Version

		=|---------------------------------------------------------------------------------------------------------------------------------------------------------|=					
										      -------------||-------------
====================================================================================================================================================================================================================================================*/

/*===========================================================================================================================================================================================
											[Includes]
===========================================================================================================================================================================================*/
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <xs>
#include <hamsandwich>
#include <zombieplague>

/*===========================================================================================================================================================================================
										[Defines, Cvars e Consts]
===========================================================================================================================================================================================*/
#define PLUGIN "[ZP] Addon: Perfect Lasermine"
#define VERSION "4.2"
#define AUTHOR "[P]erfec[T] [S]cr[@]s[H] | SandStriker"

#define RemoveEntity(%1)	engfunc(EngFunc_RemoveEntity,%1)
#define LASERMINE_TEAM		pev_iuser1
#define LASERMINE_OWNER		pev_iuser2
#define LASERMINE_STEP		pev_iuser3
#define LASERMINE_HITING	pev_iuser4
#define LASERMINE_COUNT		pev_fuser1
#define LASERMINE_POWERUP	pev_fuser2
#define LASERMINE_BEAMTHINK	pev_fuser3
#define LASERMINE_BEAMENDPOINT	pev_vuser1

#define LM_HANDLED 91

// Lasermine Think Action
enum { 
	POWERUP_THINK = 0, 
	BEAMBREAK_THINK, 
	EXPLOSE_THINK
};

// If you want to add/remove more models/sprites/sounds you need to edit here first
// PS: If you dont know edit, please, DONT NOT CHANGE
#define MAX_MODELS 9
#define MAX_SPRITES 8
#define MAX_SOUNDS 7

#define TASK_HUD 33092

// Color
enum {
	RED = 0,
	GREEN,
	BLUE,
	CUSTOM_R,
	CUSTOM_G,
	CUSTOM_B,
	MAX_COLOR
}

// Mode
enum {
	GLOW = 0,
	LINE,
	MODEL,
	SPRITE,
	MAX_MODES
}

// Lasermine Action Sounds
enum { 
	POWERUP_SOUND = 0, 
	ACTIVATE_SOUND, 
	STOP_SOUND 
}

// Forward
enum {
	PLANTED_PRE = 0,
	PLANTED_POST,
	REMOVED_PRE,
	REMOVED_POST,
	DESTROYED_POST,
	DAMAGED_PRE,
	DAMAGED_POST,
	MAX_FORWARDS
}

// Menu Keys
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

// CS Player PData Offsets
const PDATA_SAFE = 2
const OFFSET_CSMENUCODE = 205
const OFFSET_LINUX = 5

// Models
new const model_langs[MAX_MODELS][] = { 
	"CHOOSE_LM_HL", // Classic
	"CHOOSE_LM1", // Normal
	"CHOOSE_LM2", // Gauss
	"CHOOSE_LM3", // Red Eye
	"CHOOSE_LM4", // Alien 1
	"CHOOSE_LM5", // Alien 2
	"CHOOSE_LM6", // Perfect
	"CHOOSE_LM7", // End of Day
	"CHOOSE_LM8" // Kraken Eye
}
new const Models[MAX_MODELS][] =  { 
	"models/v_tripmine.mdl",					// Classic
	"models/zombie_plague/lasermine_perfect/v_lasermine_1.mdl",	// Normal
	"models/zombie_plague/lasermine_perfect/v_lasermine_2.mdl",	// Gauss
	"models/zombie_plague/lasermine_perfect/v_lasermine_3.mdl",	// Red Eye
	"models/zombie_plague/lasermine_perfect/v_lasermine_4.mdl",	// Alien 1
	"models/zombie_plague/lasermine_perfect/v_lasermine_5.mdl",	// Alien 2
	"models/zombie_plague/lasermine_perfect/v_lasermine_6.mdl",	// Perfect
	"models/zombie_plague/lasermine_perfect/v_lasermine_7.mdl",	// End of Day
	"models/zombie_plague/lasermine_perfect/v_lasermine_8.mdl"	// Kraken Eye
};

// Sprites
new const spr_langs[MAX_SPRITES][] = { 
	"CHOOSE_SPR1", 
	"CHOOSE_SPR2", 
	"CHOOSE_SPR3", 
	"CHOOSE_SPR4", 
	"CHOOSE_SPR5", 
	"CHOOSE_SPR6",
	"CHOOSE_SPR7",
	"CHOOSE_SPR8"
}
new const Sprites[MAX_SPRITES][] = { 
	"sprites/laserbeam.spr", // Normal
	"sprites/lgtning.spr",  // Shock
	"sprites/xenobeam.spr", // Neon
	"sprites/bm1.spr", // Dotted
	"sprites/lasermine_perfect/4i20.spr", // 4i20
	"sprites/lasermine_perfect/triangle.spr", // Triangle
	"sprites/lasermine_perfect/double_beam.spr", // Double Ray
	"sprites/lasermine_perfect/espiral.spr" // Spiral
}
new beam[MAX_SPRITES]
new const Spr_Explode[] = "sprites/zerogxplode.spr"

// Menu Sounds
new const Menu_Sounds[][] = {
	"lasermine_perfect/ok.wav",
	"lasermine_perfect/error.wav"
}

// Lasermine Sounds
new const Lasermine_Sounds[MAX_SOUNDS][] = { 
	"weapons/grenade_hit3.wav", 
	"weapons/gren_cock1.wav", 
	"weapons/hks3.wav",	
	"debris/beamstart9.wav",	
	"items/gunpickup2.wav", 
	"debris/bustglass1.wav", 
	"debris/bustglass2.wav"
}

// Color Lang
new const color_lang[][] = { 
	"COLOR_WHITE", 
	"COLOR_YELLOW", 
	"COLOR_RED", 
	"COLOR_GREEN", 
	"COLOR_BLUE",
	"COLOR_CUSTOM", 
	"COLOR_DEFAULT" 
}

// Entity Properties
new const Lasermine_Classname[] = "zp_lasermine"
new const Breakable_classname[] = "func_breakable";

// Variables
new cvar_lm[28], g_deployed[33], g_lasermine_imune[33], lm_flag_access, boom, allow_plant, g_maxplayers,
g_lasermine_id[MAX_MODES][33], glow_color_RGB[MAX_COLOR][33], line_color_RGB[MAX_COLOR][33], g_invisible_effect[33], g_Burn_SprId

// Forwards
new g_fwDummyResult, g_forward[MAX_FORWARDS]

/*===========================================================================================================================================================================================
											[Plugin Register]
===========================================================================================================================================================================================*/
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR); // Plugin Register
	register_cvar("zp_lasermine_perfect", VERSION, FCVAR_SERVER|FCVAR_UNLOGGED|FCVAR_SPONLY); // Dont Remove
	register_dictionary("lasermine_perfect.txt") // Lang Register

	// Command Register
	register_clcmd("+setlaser", "Create_Lasermine");
	register_clcmd("+dellaser", "Remove_Lasermine");
	register_clcmd("[LM]Change_color_glow_R", "change_color_glow_red")
	register_clcmd("[LM]Change_color_glow_G", "change_color_glow_green")
	register_clcmd("[LM]Change_color_glow_B", "change_color_glow_blue")
	register_clcmd("[LM]Change_color_line_R", "change_color_line_red")
	register_clcmd("[LM]Change_color_line_G", "change_color_line_green")
	register_clcmd("[LM]Change_color_line_B", "change_color_line_blue")
	register_clcmd("lasermine_menu", "lm_configs_menu")
	register_clcmd("say /lm", "lm_configs_menu")
	register_clcmd("say_team /lm", "lm_configs_menu")
	register_clcmd("say lm", "lm_configs_menu")
	register_clcmd("say_team lm", "lm_configs_menu")
	
	register_cvars()
	
	// Forward Register
	g_forward[PLANTED_PRE] = CreateMultiForward("zp_fw_lm_planted_pre", ET_CONTINUE, FP_CELL)
	g_forward[PLANTED_POST] = CreateMultiForward("zp_fw_lm_planted_post", ET_IGNORE, FP_CELL, FP_CELL)
	g_forward[REMOVED_PRE] = CreateMultiForward("zp_fw_lm_removed_pre", ET_CONTINUE, FP_CELL, FP_CELL)
	g_forward[REMOVED_POST] = CreateMultiForward("zp_fw_lm_removed_post", ET_IGNORE, FP_CELL, FP_CELL)
	g_forward[DESTROYED_POST] = CreateMultiForward("zp_fw_lm_destroyed_post", ET_IGNORE, FP_CELL, FP_CELL)
	g_forward[DAMAGED_PRE] = CreateMultiForward("zp_fw_lm_user_damaged_pre", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_forward[DAMAGED_POST] = CreateMultiForward("zp_fw_lm_user_damaged_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)

	// Events
	register_event("DeathMsg", "DeathEvent", "a");
	register_event("ResetHUD", "Spawn_Event", "b");
	RegisterHam(Ham_TakeDamage, Breakable_classname, "Lasermine_TakeDamagePre")

	// Fakemeta Forwards.
	register_forward(FM_Think, "Lasermine_Think");
	register_forward(FM_Touch, "Lasermine_Touch")

	// Register Main Menu
	register_menu("LM Main Menu", KEYSMENU, "lm_configs_menu_handler")

	// Cache Maxplayers
	g_maxplayers = get_maxplayers()
}

// Cache Cvars
register_cvars() { 
	cvar_lm[0] = register_cvar("zp_ltm_max_deploy", "1");
	cvar_lm[1] = register_cvar("zp_ltm_dmg", "60");	
	cvar_lm[2] = register_cvar("zp_ltm_health", "500");
	cvar_lm[3] = register_cvar("zp_ltm_radius", "320.0");
	cvar_lm[4] = register_cvar("zp_ltm_rdmg", "100"); 
	cvar_lm[5] = register_cvar("zp_ltm_line", "1");
	cvar_lm[6] = register_cvar("zp_ltm_glow_color", "255 255 255");
	cvar_lm[7] = register_cvar("zp_ltm_line_color", "255 255 255");
	cvar_lm[8] = register_cvar("zp_ltm_show_status", "1");
	cvar_lm[9] = register_cvar("zp_ltm_ap_for_kill_allow", "1");
	cvar_lm[10] = register_cvar("zp_ltm_glow_color_aleatory", "1");
	cvar_lm[11] = register_cvar("zp_ltm_line_color_aleatory", "1");
	cvar_lm[12] = register_cvar("zp_ltm_admin_only", "0");
	cvar_lm[13] = register_cvar("zp_ltm_glow", "1");
	cvar_lm[14] = register_cvar("zp_ltm_ldmgmode", "2"); 
	cvar_lm[15] = register_cvar("zp_ltm_bright", "255");	
	cvar_lm[16] = register_cvar("zp_ltm_ldmgseconds", "1");
	cvar_lm[17] = register_cvar("zp_ltm_autobind_enable", "1");
	cvar_lm[18] = register_cvar("zp_ltm_ignore_frags", "1");
	cvar_lm[19] = register_cvar("zp_ltm_ap_for_kill_quantity", "2");
	cvar_lm[20] = register_cvar("zp_ltm_flag_acess", "b");
	cvar_lm[21] = register_cvar("zp_ltm_default_model", "1");
	cvar_lm[22] = register_cvar("zp_ltm_menu_enable", "1");
	cvar_lm[23] = register_cvar("zp_ltm_default_sprite", "0");
	cvar_lm[24] = register_cvar("zp_ltm_solid", "0");
	cvar_lm[25] = register_cvar("zp_ltm_breakable_block", "1");
	cvar_lm[26] = register_cvar("zp_ltm_remove_distance", "200.0");
	cvar_lm[27] = register_cvar("zp_ltm_realistic_detail", "1");
}

/*------------------------------------------------------------------------------------
				[Native Register]
-------------------------------------------------------------------------------------*/
public plugin_natives() {
	register_library("zp_lasermine_perfect")
	register_native("zp_get_user_lm_imunne", "native_get_user_lm_imunne", 1)
	register_native("zp_set_user_lm_imunne", "native_set_user_lm_imunne", 1)
	register_native("zp_get_user_lm_deployed_num", "native_get_user_lm_deployed_num", 1)
	register_native("zp_remove_lasermine", "native_remove_lasermine", 1)
	
	register_native("zp_is_valid_lasermine", "native_is_valid_lasermine", 1)
	register_native("zp_lasermine_get_owner", "native_lasermine_get_owner", 1)
	register_native("zp_set_lasermine_health", "native_set_lasermine_health", 1)
	register_native("zp_get_lasermine_health", "native_get_lasermine_health", 1)
	
	register_native("zp_set_user_ltm_model", "native_set_user_ltm_model", 1)
	register_native("zp_get_user_ltm_model", "native_get_user_ltm_model", 1)
	register_native("zp_set_user_ltm_sprite", "native_set_user_ltm_sprite", 1)
	register_native("zp_get_user_ltm_sprite", "native_get_user_ltm_sprite", 1)
	
	register_native("zp_set_ltm_line_color", "native_set_ltm_line_color", 1)
	register_native("zp_get_ltm_line_color_id", "native_get_ltm_line_color_id", 1)
	register_native("zp_set_ltm_glow_color", "native_set_ltm_glow_color", 1)
	register_native("zp_get_ltm_glow_color_id", "native_get_ltm_glow_color_id", 1)
}

/*------------------------------------------------------------------------------------
				[Plugin Precache]
-------------------------------------------------------------------------------------*/
public plugin_precache() {
	new i
	for(i = 0; i < sizeof Lasermine_Sounds; i++) 
		precache_sound(Lasermine_Sounds[i]);

	for(i = 0; i < sizeof Menu_Sounds; i++)
		precache_sound(Menu_Sounds[i]);

	for(i = 0; i < sizeof Models; i++) 
		precache_model(Models[i]);
	
	for(i = 0; i < MAX_SPRITES; i++) 
		beam[i] = precache_model(Sprites[i]);

	boom = precache_model(Spr_Explode);
	g_Burn_SprId = precache_model("sprites/muzzleflash1.spr")
}

/*------------------------------------------------------------------------------------
			   [Load Configs]
-------------------------------------------------------------------------------------*/
public plugin_cfg() {
	arrayset(g_deployed, 0, sizeof(g_deployed));

	new file[64]; get_localinfo("amxx_configsdir",file,63);
	format(file, 63, "%s/ltm_cvars.cfg", file);
	
	if(file_exists(file)) server_cmd("exec %s", file), server_exec();
	else log_amx("[Lasermine Perfect %s] ltm_cvars.cfg Not Found", VERSION)
	
	new lm_access[32]; get_pcvar_string(cvar_lm[20], lm_access, sizeof(lm_access)-1)
	lm_flag_access = read_flags(lm_access)
}

/*===========================================================================================================================================================================================
										     [Command Action]
===========================================================================================================================================================================================*/
// Remove Lasermine
public Remove_Lasermine(id) {
	if(!Allow_Remove(id)) 
		return PLUGIN_HANDLED;
	
	static tgt,body, Float:vo[3],Float:to[3]; get_user_aiming(id,tgt,body);

	if(!pev_valid(tgt)) 
		return PLUGIN_HANDLED;

	ExecuteForward(g_forward[REMOVED_PRE], g_fwDummyResult, id, tgt)

	if (g_fwDummyResult >= LM_HANDLED)
		return PLUGIN_HANDLED;
	
	pev(id,pev_origin,vo); pev(tgt,pev_origin,to);
	
	if(get_distance_f(vo,to) > get_pcvar_float(cvar_lm[26])) 
		return PLUGIN_HANDLED;
		
	static EntityName[32]; pev(tgt, pev_classname, EntityName, 31);
	if(equal(EntityName, Lasermine_Classname) && pev(tgt,LASERMINE_OWNER) == id) {
		RemoveEntity(tgt); 
		g_deployed[id]--;
		emit_sound(id, CHAN_ITEM, Lasermine_Sounds[4], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		ExecuteForward(g_forward[REMOVED_POST], g_fwDummyResult, id, tgt)
	}
	return PLUGIN_CONTINUE;
}

// Create Lasermine
public Create_Lasermine(id) {
	ExecuteForward(g_forward[PLANTED_PRE], g_fwDummyResult, id)
	
	if (g_fwDummyResult >= LM_HANDLED || !Allow_Plant(id)) 
		return PLUGIN_HANDLED;

	// motor
	new i_Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, Breakable_classname));
	if(!i_Ent) {
		client_printcolor(id, "%L Nao Foi Possivel Cria a Entidade", id, "CHATTAG");
		return PLUGIN_HANDLED_MAIN;
	}

	set_pev(i_Ent,pev_classname,Lasermine_Classname);
	engfunc(EngFunc_SetModel,i_Ent, Models[g_lasermine_id[MODEL][id]]);
	set_pev(i_Ent,pev_solid,SOLID_NOT);
	set_pev(i_Ent,pev_movetype,MOVETYPE_FLY);
	set_pev(i_Ent,pev_frame,0);
	
	if(g_lasermine_id[MODEL][id] >= 4 && g_lasermine_id[MODEL][id] <= 6) set_pev(i_Ent,pev_sequence,0);
	else set_pev(i_Ent,pev_sequence,7), set_pev(i_Ent,pev_body,3);
	
	set_pev(i_Ent, pev_framerate,0);
	set_pev(i_Ent, pev_takedamage, DAMAGE_YES);
	set_pev(i_Ent, pev_dmg, 100.0);
	
	set_user_health(i_Ent,get_pcvar_num(cvar_lm[2]));
	
	static Float:vOrigin[3];
	static Float:vNewOrigin[3],Float:vNormal[3],Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vEntAngles[3];
	pev(id, pev_origin, vOrigin);
	velocity_by_aim(id, 500, vTraceDirection);
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd);
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0);
	
	static Float:fFraction;
	get_tr2(0, TR_flFraction, fFraction);
	
	// -- We hit something!
	if (fFraction < 1.0) {
		// -- Save results to be used later.
		get_tr2(0, TR_vecEndPos, vTraceEnd);
		get_tr2(0, TR_vecPlaneNormal, vNormal);
	}

	xs_vec_mul_scalar(vNormal, 8.0, vNormal);
	xs_vec_add(vTraceEnd, vNormal, vNewOrigin);

	engfunc(EngFunc_SetSize, i_Ent, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 });
	engfunc(EngFunc_SetOrigin, i_Ent, vNewOrigin);

	// -- Rotate tripmine.
	vector_to_angle(vNormal,vEntAngles);
	set_pev(i_Ent,pev_angles,vEntAngles);

	// -- Calculate laser end origin.
	static Float:vBeamEnd[3], Float:vTracedBeamEnd[3];
        
	xs_vec_mul_scalar(vNormal, 8192.0, vNormal);
	xs_vec_add(vNewOrigin, vNormal, vBeamEnd);

	engfunc(EngFunc_TraceLine, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, -1, 0);

	get_tr2(0, TR_vecPlaneNormal, vNormal);
	get_tr2(0, TR_vecEndPos, vTracedBeamEnd);

	// -- Save results to be used later.
	set_pev(i_Ent, LASERMINE_OWNER, id);
	set_pev(i_Ent,LASERMINE_BEAMENDPOINT, vTracedBeamEnd);
	static Float:fCurrTime
	fCurrTime = get_gametime();

	set_pev(i_Ent,LASERMINE_POWERUP, fCurrTime + 0.1);
   
	set_pev(i_Ent,LASERMINE_STEP,POWERUP_THINK);
	set_pev(i_Ent,pev_nextthink, fCurrTime + 0.1);

	if(g_lasermine_id[LINE][id] == 0 && !g_deployed[id]) {
		static szColors_line[16]
		if(!get_pcvar_num(cvar_lm[11])) {
			get_pcvar_string(cvar_lm[7], szColors_line, 15)
									
			static gRed2[4], gGreen2[4], gBlue2[4], iRed2, iGreen2, iBlue2
			parse(szColors_line, gRed2, 3, gGreen2, 3, gBlue2, 3)
										
			iRed2 = clamp(str_to_num(gRed2), 0, 255)
			iGreen2 = clamp(str_to_num(gGreen2), 0, 255)
			iBlue2 = clamp(str_to_num(gBlue2), 0, 255)
						
			line_color_RGB[RED][id] = iRed2;
			line_color_RGB[GREEN][id] = iGreen2;
			line_color_RGB[BLUE][id] = iBlue2;
		}
		if(get_pcvar_num(cvar_lm[11])) {
			line_color_RGB[RED][id] = random_num(0,255);
			line_color_RGB[GREEN][id] = random_num(0,255);
			line_color_RGB[BLUE][id] = random_num(0,255);
		}
	}
	
	if(get_pcvar_num(cvar_lm[13]))
		Lasermine_Set_Glow(i_Ent)

	PlaySound(i_Ent,POWERUP_SOUND);
	g_deployed[id]++;
	
	ExecuteForward(g_forward[PLANTED_POST], g_fwDummyResult, id, i_Ent)
	
	return 1;
}

/*===========================================================================================================================================================================================
											 [LM Action]
===========================================================================================================================================================================================*/
public Lasermine_Think(i_Ent) {
	if(!pev_valid(i_Ent)) return FMRES_IGNORED;
	
	new EntityName[32]; pev(i_Ent, pev_classname, EntityName, 31);
	
	if(!equal(EntityName, Lasermine_Classname)) return FMRES_IGNORED;
		
	static Float:fCurrTime; fCurrTime = get_gametime();
	
	switch(pev(i_Ent, LASERMINE_STEP)) {
		case POWERUP_THINK : {
			static Float:fPowerupTime;
			pev(i_Ent, LASERMINE_POWERUP, fPowerupTime);

			if(fCurrTime > fPowerupTime) {
				set_pev(i_Ent, pev_solid, SOLID_SLIDEBOX);
				set_pev(i_Ent, LASERMINE_STEP, BEAMBREAK_THINK);

				PlaySound(i_Ent, ACTIVATE_SOUND);
			}

			set_pev(i_Ent, pev_nextthink, fCurrTime + 0.1);
		}
		case BEAMBREAK_THINK : {
			if(!pev_valid(i_Ent)) return FMRES_IGNORED;
			
			static Float:vEnd[3],Float:vOrigin[3];
			pev(i_Ent, pev_origin, vOrigin);
			pev(i_Ent, LASERMINE_BEAMENDPOINT, vEnd);

			static iHit, Float:fFraction, Trace_Result;
			engfunc(EngFunc_TraceLine, vOrigin, vEnd, DONT_IGNORE_MONSTERS, i_Ent, Trace_Result);

			get_tr2(Trace_Result, TR_flFraction, fFraction); iHit = get_tr2(Trace_Result, TR_pHit);

			if(is_user_alive(iHit) || pev_valid(iHit)) {
				// -- Something has passed the laser.
				if (fFraction < 1.0 && pev_valid(i_Ent)) {
					
					// Cut the lasermine when it passes over
					if(get_pcvar_num(cvar_lm[27])) 
						get_tr2(Trace_Result, TR_vecEndPos, vEnd)

					pev(iHit, pev_classname, EntityName, 31);
	
					if(!equal(EntityName, Lasermine_Classname)) {
						Lasermine_Damage(i_Ent, iHit);
						set_pev(i_Ent, pev_nextthink, fCurrTime + random_float(0.1, 0.3));
					}
				}
				if(get_pcvar_num(cvar_lm[14])!=0 && pev(i_Ent,LASERMINE_HITING) != iHit) {
					if(is_user_alive(iHit) && zp_get_user_zombie(iHit) || pev_valid(iHit) && !is_user_alive(iHit))  // Quero ver Pula laser pra mata rapido agora
						set_pev(i_Ent,LASERMINE_HITING, iHit);
				}
			}
 
			// -- Tripmine is still there.
			if (pev_valid(i_Ent)) {
				static Float:fHealth; pev(i_Ent, pev_health, fHealth);

				if(fHealth <= 0.0 || (pev(i_Ent,pev_flags) & FL_KILLME)) {
					set_pev(i_Ent, LASERMINE_STEP, EXPLOSE_THINK);
					set_pev(i_Ent, pev_nextthink, fCurrTime + random_float(0.1, 0.3));
				}
                    
				static Float:fBeamthink; pev(i_Ent, LASERMINE_BEAMTHINK, fBeamthink);
                    
				if(fBeamthink < fCurrTime && get_pcvar_num(cvar_lm[5])) {
					Show_Lasermine_Line(i_Ent, vOrigin, vEnd);
					set_pev(i_Ent, LASERMINE_BEAMTHINK, fCurrTime + 0.1);
				}
				set_pev(i_Ent, pev_nextthink, fCurrTime + 0.01);
			}
		}
		case EXPLOSE_THINK : {
			static id
			id = pev(i_Ent,LASERMINE_OWNER)

			// -- Stopping entity to think
			set_pev(i_Ent, pev_nextthink, 0.0);
			PlaySound(i_Ent, STOP_SOUND);
			g_deployed[id]--;
			Lasermine_Explosion(i_Ent); Lasermine_Radius_Damage(i_Ent); RemoveEntity(i_Ent);
			
			ExecuteForward(g_forward[DESTROYED_POST], g_fwDummyResult, id, i_Ent)
		}
	}

	return FMRES_IGNORED;
}

/*------------------------------------------------------------------------------------
			   [Lasermine Take Damage Pre]
-------------------------------------------------------------------------------------*/
public Lasermine_TakeDamagePre(victim, inflictor, attacker, Float:f_Damage, bit_Damage) { 
	if(!pev_valid(victim)) 
		return HAM_IGNORED;

	static EntityName[32], i_Owner; 

	pev(victim, pev_classname, EntityName, 31);
	if(!equal(EntityName, Lasermine_Classname)) 
		return HAM_IGNORED;
	
	i_Owner = pev(victim, LASERMINE_OWNER) 
	if(i_Owner != attacker && (!zp_get_user_zombie(attacker) && get_pcvar_num(cvar_lm[25]) == 1 || get_pcvar_num(cvar_lm[25]) == 2)) 
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED 
} 

/*------------------------------------------------------------------------------------
			   [Lasermine Sounds]
-------------------------------------------------------------------------------------*/
PlaySound(i_Ent, i_SoundType) {
	if(!pev_valid(i_Ent)) return FMRES_IGNORED;
	
	static EntityName[32]; pev(i_Ent, pev_classname, EntityName, 31);
	if(!equal(EntityName, Lasermine_Classname)) return FMRES_IGNORED;
	
	switch (i_SoundType) {
		case POWERUP_SOUND : {
			emit_sound(i_Ent, CHAN_VOICE, Lasermine_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			emit_sound(i_Ent, CHAN_BODY , Lasermine_Sounds[1], 0.2, ATTN_NORM, 0, PITCH_NORM);
		}
		case ACTIVATE_SOUND: emit_sound(i_Ent, CHAN_VOICE, Lasermine_Sounds[2], 0.5, ATTN_NORM, 1, 75);
		case STOP_SOUND : {
			emit_sound(i_Ent, CHAN_BODY , Lasermine_Sounds[1], 0.2, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(i_Ent, CHAN_VOICE, Lasermine_Sounds[2], 0.5, ATTN_NORM, SND_STOP, 75);
		}
	}
	
	return FMRES_IGNORED;
}

/*------------------------------------------------------------------------------------
			   [Show Lasermine Line]
-------------------------------------------------------------------------------------*/
Show_Lasermine_Line(i_Ent,const Float:v_Origin[3], const Float:v_EndOrigin[3]) {
	if(!pev_valid(i_Ent)) return FMRES_IGNORED;
	
	static classname[32], tcolor[3], id, sprid, sprwave, sprlife, sprwidth; 
	pev(i_Ent, pev_classname, classname, 31) 
	if(!equal(classname, Lasermine_Classname)) return FMRES_IGNORED;
	 
	id = pev(i_Ent,LASERMINE_OWNER)
		
	tcolor[0] = line_color_RGB[RED][id];
	tcolor[1] = line_color_RGB[GREEN][id];
	tcolor[2] = line_color_RGB[BLUE][id];

	sprwave = 0; sprlife = 1; sprwidth = 5
	
	switch(g_lasermine_id[SPRITE][id]) {
		case 0:	sprid = beam[0]					// Default
		case 1:	sprid = beam[1], sprwave = 5	// Shock
		case 2:	sprid = beam[2], sprwidth = 25	// Neon
		case 3:	sprid = beam[3], sprwidth = 15	// Dotted
		case 4:	sprid = beam[4], sprwidth = 40	// 4i20
		case 5:	sprid = beam[5], sprwidth = 8	// Triangle
		case 6:	sprid = beam[6]					// Double Ray
		case 7:	sprid = beam[7], sprwidth = 15	// Spiral 
	}
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord,v_EndOrigin[0]);
	engfunc(EngFunc_WriteCoord,v_EndOrigin[1]);
	engfunc(EngFunc_WriteCoord,v_EndOrigin[2]);
	engfunc(EngFunc_WriteCoord,v_Origin[0]);
	engfunc(EngFunc_WriteCoord,v_Origin[1]);
	engfunc(EngFunc_WriteCoord,v_Origin[2]);
	write_short(sprid);
	write_byte(0);
	write_byte(0);
	write_byte(sprlife);	//Life
	write_byte(sprwidth);	//Width
	write_byte(sprwave);	//wave
	write_byte(tcolor[0]); // r
	write_byte(tcolor[1]); // g
	write_byte(tcolor[2]); // b
	write_byte(get_pcvar_num(cvar_lm[15]));
	write_byte(255);
	message_end();

	// Effects when cut
	if(get_pcvar_num(cvar_lm[27])) {
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
		write_byte(TE_EXPLOSION)
		engfunc(EngFunc_WriteCoord, v_EndOrigin[0])
		engfunc(EngFunc_WriteCoord, v_EndOrigin[1])
		engfunc(EngFunc_WriteCoord, v_EndOrigin[2]-10.0)
		write_short(g_Burn_SprId)	// sprite index
		write_byte(1)	// scale in 0.1's
		write_byte(30)	// framerate
		write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND)	// flags
		message_end()
	}
	
	return FMRES_IGNORED;
}

/*------------------------------------------------------------------------------------
			   [Lasermine Glow]
-------------------------------------------------------------------------------------*/
public Lasermine_Set_Glow(i_Ent) {
	if(!pev_valid(i_Ent) || !get_pcvar_num(cvar_lm[13])) return;
	
	static classname[32], id; 

	pev(i_Ent, pev_classname, classname, 31) 
	if(!equal(classname, Lasermine_Classname)) return;
	
	id = pev(i_Ent,LASERMINE_OWNER)
		
	switch(g_lasermine_id[GLOW][id]) {
		case 1: {
			glow_color_RGB[RED][id] = 255
			glow_color_RGB[GREEN][id] = 255
			glow_color_RGB[BLUE][id] = 255
		}
		case 2: {
			glow_color_RGB[RED][id] = 255
			glow_color_RGB[GREEN][id] = 255
			glow_color_RGB[BLUE][id] = 0
		}
		case 3: {
			glow_color_RGB[RED][id] = 255
			glow_color_RGB[GREEN][id] = 0
			glow_color_RGB[BLUE][id] = 0
		}
		case 4: {
			glow_color_RGB[RED][id] = 0
			glow_color_RGB[GREEN][id] = 255
			glow_color_RGB[BLUE][id] = 0
		}
		case 5: {
			glow_color_RGB[RED][id] = 0
			glow_color_RGB[GREEN][id] = 255
			glow_color_RGB[BLUE][id] = 255
		}
		case 6: {
			glow_color_RGB[RED][id] = glow_color_RGB[CUSTOM_R][id]
			glow_color_RGB[GREEN][id] = glow_color_RGB[CUSTOM_G][id]
			glow_color_RGB[BLUE][id] = glow_color_RGB[CUSTOM_B][id];
		}
		case 0: {	
			if(!get_pcvar_num(cvar_lm[10])) {
				static szColors[16]; get_pcvar_string(cvar_lm[6], szColors, 15)
				new gRed[4], gGreen[4], gBlue[4], iRed, iGreen, iBlue
				parse(szColors, gRed, 3, gGreen, 3, gBlue, 3)
								
				iRed = clamp(str_to_num(gRed), 0, 255)
				iGreen = clamp(str_to_num(gGreen), 0, 255)
				iBlue = clamp(str_to_num(gBlue), 0, 255)
					
				glow_color_RGB[RED][id] = iRed
				glow_color_RGB[GREEN][id] = iGreen
				glow_color_RGB[BLUE][id] = iBlue
			}
			else if(get_pcvar_num(cvar_lm[10])) glow_color_RGB[RED][id] = random_num(0,255), glow_color_RGB[GREEN][id] = random_num(0,255), glow_color_RGB[BLUE][id] = random_num(0,255);
		}
	}
	if(get_pcvar_num(cvar_lm[13])) set_rendering(i_Ent, kRenderFxGlowShell, glow_color_RGB[RED][id], glow_color_RGB[GREEN][id], glow_color_RGB[BLUE][id], g_invisible_effect[id] ? kRenderTransAlpha : kRenderNormal,5);
	else set_rendering(i_Ent, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 5);
	
	return;
}

/*------------------------------------------------------------------------------------
			   [Set Damage Effects]
-------------------------------------------------------------------------------------*/
// Radius Damage
Lasermine_Radius_Damage(i_Ent) {
	if(!pev_valid(i_Ent)) return PLUGIN_HANDLED;
	
	static classname[32], Float:originF[3], Float:g_radius, g_damage, victim, attacker; 

	pev(i_Ent, pev_classname, classname, 31) 
	if(!equal(classname, Lasermine_Classname)) return PLUGIN_HANDLED;
	 
	pev(i_Ent, pev_origin, originF)
	
	g_radius = get_pcvar_float(cvar_lm[3])
	g_damage = get_pcvar_num(cvar_lm[4])
	
	victim = -1
	
	attacker = pev(i_Ent, LASERMINE_OWNER)
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, g_radius)) != 0) {
		ExecuteForward(g_forward[DAMAGED_PRE], g_fwDummyResult, victim, attacker, 1, i_Ent)
		
		if (g_fwDummyResult >= LM_HANDLED || !is_user_alive(victim) || !zp_get_user_zombie(victim)) continue;
		
		set_user_extra_damage(victim, attacker, g_damage, "Lasermine")
		Lasermine_Knockback(i_Ent, get_pcvar_float(cvar_lm[4]), get_pcvar_float(cvar_lm[3]))
		
		ExecuteForward(g_forward[DAMAGED_POST], g_fwDummyResult, victim, attacker, 1, i_Ent)
	}
	
	return PLUGIN_CONTINUE
}

// Knockback
Lasermine_Knockback(iCurrent,Float:Amount,Float:Radius) {
	// Get given parameters
	static Float:vecSrc[3]; pev(iCurrent, pev_origin, vecSrc);
	new ent = -1, Float: tmpdmg = Amount, Float:kickback = 0.0;
	
	// Needed for doing some nice calculations :P
	static Float:Tabsmin[3], Float:Tabsmax[3], Float:vecSpot[3], Float:Aabsmin[3], Float:Aabsmax[3], Float:vecSee[3], trRes;
	static Float:flFraction, Float:vecEndPos[3], Float:distance, Float:origin[3], Float:vecPush[3], Float:invlen, Float:velocity[3];

	// Calculate falloff
	static Float:falloff;
	if (Radius > 0.0) falloff = Amount / Radius;
	else falloff = 1.0;
	
	// Find monsters and players inside a specifiec radius
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, vecSrc, Radius)) != 0) {
		if(!pev_valid(ent) || !is_user_alive(ent) || !(pev(ent, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER))) continue;
	
		kickback = 1.0; tmpdmg = Amount;
		// The following calculations are provided by Orangutanz, THANKS!
		// We use absmin and absmax for the most accurate information
		pev(ent, pev_absmin, Tabsmin); pev(ent, pev_absmax, Tabsmax);
		xs_vec_add(Tabsmin,Tabsmax,Tabsmin); xs_vec_mul_scalar(Tabsmin,0.5,vecSpot);
			
		pev(iCurrent, pev_absmin, Aabsmin); pev(iCurrent, pev_absmax, Aabsmax);
		xs_vec_add(Aabsmin,Aabsmax,Aabsmin); xs_vec_mul_scalar(Aabsmin,0.5,vecSee);
		
		engfunc(EngFunc_TraceLine, vecSee, vecSpot, 0, iCurrent, trRes);
		get_tr2(trRes, TR_flFraction, flFraction);

		// Explosion can 'see' this entity, so hurt them! (or impact through objects has been enabled xD)
		if (flFraction >= 0.9 || get_tr2(trRes, TR_pHit) == ent) {
			// Work out the distance between impact and entity
			get_tr2(trRes, TR_vecEndPos, vecEndPos);
				
			distance = get_distance_f(vecSrc, vecEndPos) * falloff;
			tmpdmg -= distance;
				
			if(tmpdmg < 0.0) tmpdmg = 0.0;
				
			// Kickback Effect
			if(kickback != 0.0) {
				xs_vec_sub(vecSpot,vecSee,origin);
				
				invlen = 1.0/get_distance_f(vecSpot, vecSee);

				xs_vec_mul_scalar(origin,invlen,vecPush);
				pev(ent, pev_velocity, velocity)
				xs_vec_mul_scalar(vecPush,tmpdmg,vecPush);
				xs_vec_mul_scalar(vecPush,kickback,vecPush);
				xs_vec_add(velocity,vecPush,velocity);
					
				if(tmpdmg < 60.0) xs_vec_mul_scalar(velocity,12.0,velocity);
				else xs_vec_mul_scalar(velocity,4.0,velocity);
				
				if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0) set_pev(ent, pev_velocity, velocity);
			}
		}
	}
	return
}

// Explosion
Lasermine_Explosion(iCurrent) {
	static Float:vOrigin[3]; pev(iCurrent,pev_origin,vOrigin);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(99); //99 = KillBeam
	write_short(iCurrent);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord,vOrigin[0]);
	engfunc(EngFunc_WriteCoord,vOrigin[1]);
	engfunc(EngFunc_WriteCoord,vOrigin[2]);
	write_short(boom);
	write_byte(30);
	write_byte(15);
	write_byte(0);
	message_end();
}

// Lasermine Damage
public Lasermine_Damage(iCurrent,isHit) {
	if(isHit < 0) return PLUGIN_CONTINUE
	
	switch(get_pcvar_num(cvar_lm[14])) {
		case 1: if(pev(iCurrent,LASERMINE_HITING) == isHit) return PLUGIN_CONTINUE;
		
		case 2:	{
			if(pev(iCurrent, LASERMINE_HITING) == isHit) {
				static Float:cnt
				static now, htime;now = floatround(get_gametime())

				pev(iCurrent, LASERMINE_COUNT, cnt); htime = floatround(cnt)

				if(now - htime < get_pcvar_num(cvar_lm[16])) return PLUGIN_CONTINUE;

				else set_pev(iCurrent,LASERMINE_COUNT, get_gametime())
			}
			else set_pev(iCurrent,LASERMINE_COUNT, get_gametime())
		}
	}

	static Float:vOrigin[3],Float:vEnd[3], szClassName[32], attacker_id
	attacker_id = pev(iCurrent,LASERMINE_OWNER)
	pev(iCurrent,pev_origin,vOrigin); pev(iCurrent,pev_vuser1,vEnd)
	szClassName[0] = '^0'; pev(isHit, pev_classname, szClassName,32)
	
	ExecuteForward(g_forward[DAMAGED_PRE], g_fwDummyResult, isHit, attacker_id, 0, iCurrent)

	if (g_fwDummyResult >= LM_HANDLED) 
		return PLUGIN_CONTINUE;

	if(is_user_connected(isHit)) {
		if(is_user_alive(isHit) && zp_get_user_zombie(isHit) && !g_lasermine_imune[isHit]) {
			emit_sound(isHit, CHAN_WEAPON, Lasermine_Sounds[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_user_extra_damage(isHit, attacker_id , get_pcvar_num(cvar_lm[1]), "Lasermine")	
		}
	}
	else if(pev_valid(isHit) && !equal(szClassName, Lasermine_Classname) && pev(isHit, pev_takedamage) != DAMAGE_NO) {
		emit_sound(isHit, CHAN_WEAPON, Lasermine_Sounds[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
		ExecuteHamB(Ham_TakeDamage, isHit, 0, attacker_id, get_pcvar_float(cvar_lm[1]), DMG_BLAST) 
	}
	
	ExecuteForward(g_forward[DAMAGED_POST], g_fwDummyResult, isHit, attacker_id, 0, iCurrent)
	
	return PLUGIN_CONTINUE
}

/*------------------------------------------------------------------------------------
		   [Set Solid Mode]
-------------------------------------------------------------------------------------*/
public Lasermine_Touch(player, lm) {
	if(!is_user_alive(player) || !pev_valid(lm) || get_pcvar_num(cvar_lm[24])) return FMRES_IGNORED;
	
	static classname[32]; pev(lm, pev_classname, classname, 31) 
	
	if(equal(classname, Lasermine_Classname)) {
		set_pev(lm, pev_solid, SOLID_NOT)
		set_task(1.0, "solid_again", lm)
	}
	return FMRES_IGNORED 
}	

// Back to Solid
public solid_again(lm) {
	if(!pev_valid(lm)) return FMRES_IGNORED;
	
	static classname[32]; pev(lm, pev_classname, classname, 31) 
	if(!equal(classname, Lasermine_Classname)) return FMRES_IGNORED;
	
	set_pev(lm, pev_solid, SOLID_BBOX);
	
	return FMRES_IGNORED;
}

/*------------------------------------------------------------------------------------
		   [Lasermine Hud]
-------------------------------------------------------------------------------------*/
public Lasermine_Hud(iTaskIndex) {
	static iPlayer; iPlayer = iTaskIndex - TASK_HUD;
	if(!is_user_connected(iPlayer)) {
		remove_task(iTaskIndex)
		return;
	}

	static iEntity, iDummy, cClassname[ 32 ], id, name[32]; 
	get_user_aiming(iPlayer, iEntity, iDummy, 9999); 
	pev(iEntity, pev_classname, cClassname, 31);

	id = pev(iEntity, LASERMINE_OWNER); 
	get_user_name(id, name, charsmax(name));
	if(is_user_alive(iPlayer) && pev_valid(iEntity) && equal(cClassname, Lasermine_Classname) && get_pcvar_num(cvar_lm[8])) {
		set_hudmessage(50, 100, 150, -1.0, 0.60, 0, 6.0, 1.1, 0.0, 0.0, -1);
		show_hudmessage(iPlayer, "%L", iPlayer, "SHOW_LM_STATUS", name, pev(iEntity, pev_health));
	}
} 

/*------------------------------------------------------------------------------------
			   [Basic Bug Prevention]
-------------------------------------------------------------------------------------*/
// Client Connect
public client_putinserver(id) {
	g_lasermine_id[LINE][id] = 0
	g_lasermine_id[GLOW][id] = 0
	
	if(get_pcvar_num(cvar_lm[21]) >= MAX_MODELS) g_lasermine_id[MODEL][id] = MAX_MODELS-1
	else g_lasermine_id[MODEL][id] = get_pcvar_num(cvar_lm[21])

	if(get_pcvar_num(cvar_lm[23]) >= MAX_SPRITES) g_lasermine_id[SPRITE][id] = MAX_SPRITES-1
	else g_lasermine_id[SPRITE][id] = get_pcvar_num(cvar_lm[23])

	g_deployed[id] = 0;
	if(get_pcvar_num(cvar_lm[17])) set_task(5.0, "AutoBind", id);
	set_task(1.0, "Lasermine_Hud", id + TASK_HUD, _, _, "b");
}

// Client Disconect
public client_disconnect(id) {
	RemoveAllTripmines(id);
	remove_task(id + TASK_HUD)
}

// Player Spawn
public Spawn_Event(id) {
	RemoveAllTripmines(id);
	g_lasermine_imune[id] = false
	
	if(get_pcvar_num(cvar_lm[22])) client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MENU_INTRODUCTION")
	
	return PLUGIN_CONTINUE
}

// Player Die
public DeathEvent() {
	static id
	id = read_data(2)
	if(is_user_connected(id)) {
		RemoveAllTripmines(id);
		g_lasermine_imune[id] = false
	}
	return PLUGIN_CONTINUE
}

// Player Infected
public zp_user_infected_post(id)
	RemoveAllTripmines(id);

// Use Antidote / Turn to Special Class
public zp_user_humanized_post(id)
	RemoveAllTripmines(id);

// Round End
public zp_round_ended() {
	for(new id = 1; id <= g_maxplayers; id++) {
		allow_plant = false
		g_lasermine_imune[id] = false
		RemoveAllTripmines(id);
	}
}

// Round Start
public zp_round_started()
	allow_plant = true

// Remove Lasermine
public RemoveAllTripmines(i_Owner) {
	static clsname[32], iEnt;
	iEnt = g_maxplayers + 1;
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", Lasermine_Classname))) {
		if (i_Owner) {
			if(pev(iEnt, LASERMINE_OWNER) != i_Owner) continue;

			clsname[0] = '^0'
			pev(iEnt, pev_classname, clsname, sizeof(clsname)-1);
                
			if (equali(clsname, Lasermine_Classname)) {
				PlaySound(iEnt, STOP_SOUND);
				RemoveEntity(iEnt);
			}
		}
		else set_pev(iEnt, pev_flags, FL_KILLME);
	}
	g_deployed[i_Owner]=0;
}

// Lasermine Glow
public Lasermine_Glow_update(i_Owner) {
	static clsname[32], iEnt;
	iEnt = g_maxplayers + 1;
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", Lasermine_Classname))) {
		if (i_Owner) {
			if(pev(iEnt, LASERMINE_OWNER) != i_Owner) continue;

			clsname[0] = '^0'
			pev(iEnt, pev_classname, clsname, sizeof(clsname)-1);
                
			if (equali(clsname, Lasermine_Classname))
				Lasermine_Set_Glow(iEnt)
		}
	}
}

/*------------------------------------------------------------------------------------
			   [Lasermine Binds]
-------------------------------------------------------------------------------------*/
// Auto Bind (If is enable)
public AutoBind(id) {
	client_cmd(id, "bind v +setlaser")
	client_cmd(id, "bind l +dellaser")
	client_cmd(id, "bind p lasermine_menu")
}

// Manual Bind (In Main Menu)
public MakeBind(id) {
	client_cmd(id, "bind v +setlaser")
	client_cmd(id, "bind l +dellaser")
	client_cmd(id, "bind p lasermine_menu")

	set_hudmessage(100, 255, 100, -1.0, -1.0, 0, 6.0, 6.0, 0.0, 0.0, -1);
	show_hudmessage(id, "%L", id, "STR_MAKE_BIND_SUCEFFULL");

	client_cmd(id, "spk %s", Menu_Sounds[0])
	lm_configs_menu(id);
}

/*===========================================================================================================================================================================================
												[Native Function]
===========================================================================================================================================================================================*/
public native_get_user_lm_imunne(id) return g_lasermine_imune[id];
public native_set_user_lm_imunne(id, bool:isimunne) g_lasermine_imune[id] = isimunne ? true : false;

public native_remove_lasermine(id) RemoveAllTripmines(id);

public native_set_user_ltm_model(id, amount) {
	if(amount >= MAX_MODELS) g_lasermine_id[MODEL][id] = MAX_MODELS-1
	else g_lasermine_id[MODEL][id] = amount
}

public native_get_user_ltm_model(id) return g_lasermine_id[MODEL][id]

public native_set_user_ltm_sprite(id, amount) {
	if(amount >= MAX_SPRITES) g_lasermine_id[SPRITE][id] = MAX_SPRITES-1
	else g_lasermine_id[SPRITE][id] = amount
}

public native_get_user_ltm_sprite(id) return g_lasermine_id[SPRITE][id];

public native_is_valid_lasermine(ent) return is_valid_lasermine(ent);

public native_set_ltm_line_color(id, R, G, B) {
	line_color_RGB[CUSTOM_R][id] = R
	line_color_RGB[CUSTOM_G][id] = G
	line_color_RGB[CUSTOM_B][id] = B
	g_lasermine_id[LINE][id] = 6
}

public native_get_ltm_line_color_id(id) return g_lasermine_id[LINE][id];

public native_set_ltm_glow_color(id, R, G, B) {
	glow_color_RGB[CUSTOM_R][id] = R
	glow_color_RGB[CUSTOM_G][id] = G
	glow_color_RGB[CUSTOM_B][id] = B
	g_lasermine_id[GLOW][id] = 6
	Lasermine_Glow_update(id)
}

public native_get_ltm_glow_color_id(id) return g_lasermine_id[GLOW][id];

public native_lasermine_get_owner(ent) {
	if(!is_valid_lasermine(ent)) return 0;
	
	return pev(ent, LASERMINE_OWNER);
}

public native_set_lasermine_health(ent, amount) {
	if(!is_valid_lasermine(ent)) return 0;
	
	set_pev(ent, pev_health, amount)
	
	return 1;
}

public native_get_lasermine_health(ent) {
	if(!is_valid_lasermine(ent)) return 0;
	
	return pev(ent, pev_health);
}

public native_get_user_lm_deployed_num(id) return g_deployed[id];

/*===========================================================================================================================================================================================
											  [Lasermine Main Menu]
===========================================================================================================================================================================================*/
public lm_configs_menu(id) {
	if(!get_pcvar_num(cvar_lm[22])) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MENU_DISABLE")
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(cvar_lm[12]) && !(get_user_flags(id) & lm_flag_access)) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_NOACCESS");
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	else {
		static menu[1500], len
		len = 0
		len += formatex(menu[len], charsmax(menu) - len, "%L %L^n", id, "MENU_TAG", id, "MENU_CONFIG_TITLE")
		
		len += formatex(menu[len], charsmax(menu) - len, "^n\r1. %s%L", get_pcvar_num(cvar_lm[13]) ? "\w" : "\d", id, "MENU_CHOOSE_GLOW_COLOR");
		len += formatex(menu[len], charsmax(menu) - len, "^n\r2. %s%L", get_pcvar_num(cvar_lm[5]) ? "\w" : "\d", id, "MENU_CHOOSE_LINE_COLOR");
		len += formatex(menu[len], charsmax(menu) - len, "^n\r3. \w%L", id, "MENU_CHOOSE_MODEL");
		len += formatex(menu[len], charsmax(menu) - len, "^n\r4. %s%L",  get_pcvar_num(cvar_lm[5]) ? "\w" : "\d", id, "MENU_CHOOSE_SPRITE");
		len += formatex(menu[len], charsmax(menu) - len, "^n\r5. %s%L %s^n",  get_pcvar_num(cvar_lm[13]) ? "\w" : "\d", id, "MENU_GLOW_INVISIBLE_EFFECT", (g_invisible_effect[id] && get_pcvar_num(cvar_lm[13])) ? "\r[ON]" : "\d[OFF]");
		len += formatex(menu[len], charsmax(menu) - len, "^n\r6. \w%L^n", id, "MENU_MAKE_BIND");
		len += formatex(menu[len], charsmax(menu) - len, "^n\r7. \w%L", id, "MENU_SET_LM");
		len += formatex(menu[len], charsmax(menu) - len, "^n\r8. \w%L", id, "MENU_DEL_LM");
		len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0. \w%L", id, "MENU_EXITNAME");

		// Fix for AMXX custom menus
		if (pev_valid(id) == PDATA_SAFE)
			set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)

		show_menu(id, KEYSMENU, menu, -1, "LM Main Menu")
		client_cmd(id, "spk %s", Menu_Sounds[0])
	}
	return PLUGIN_CONTINUE
}

public lm_configs_menu_handler(id, key) { 
	if(!get_pcvar_num(cvar_lm[22])) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MENU_DISABLE")
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(cvar_lm[12]) && !(get_user_flags(id) & lm_flag_access)) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_NOACCESS");
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	} 

	switch(key+1) {
		case 1: color_menu(id, GLOW) // Choose Glow Color
		case 2: color_menu(id, LINE) // Choose Line Color
		case 3: choose_model_sprite_menu(id, MODEL) // Choose LM Model
		case 4: choose_model_sprite_menu(id, SPRITE) // Choose LM Sprite
		case 5: {
			g_invisible_effect[id] = g_invisible_effect[id] ? false : true	// Invisible Effect
			Lasermine_Glow_update(id)
			lm_configs_menu(id)
		}
		case 6: MakeBind(id) // Manual Bind
		case 7: Create_Lasermine(id), lm_configs_menu(id); // Plant Lasermine
		case 8: Remove_Lasermine(id), lm_configs_menu(id); // Remove Lasermine
		case 9: lm_configs_menu(id)
	}
	return PLUGIN_HANDLED
} 

/*------------------------------------------------------------------------------------
				[Choose Line/Glow Color]
-------------------------------------------------------------------------------------*/
public color_menu(id, mode) {
	if(!get_pcvar_num(cvar_lm[22])) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MENU_DISABLE")
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	if(!get_pcvar_num(cvar_lm[13]) && mode == GLOW) {
		client_cmd(id, "spk %s", Menu_Sounds[1])
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_GLOW_DISABLE")
		lm_configs_menu(id)
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(cvar_lm[12]) && !(get_user_flags(id) & lm_flag_access)) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_NOACCESS");
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	set_hudmessage(100, 255, 100, -1.0, -1.0, 0, 6.0, 6.0, 0.0, 0.0, -1);
	show_hudmessage(id, "%L", id, mode == GLOW ? "STR_CHOOSE_GLOW_COLOR" : "STR_CHOOSE_LINE_COLOR")

	client_cmd(id, "spk %s", Menu_Sounds[0])
	
	static szText[512], szNum[32]
	formatex(szText, charsmax(szText), "%L %L", id, "MENU_TAG", id, mode == GLOW ? "GLOW_COLOR_MENU_TITLE" : "STR_CHOOSE_LINE_COLOR")
	new g_Menu = menu_create(szText, "color_menu_handler")

	for(new i = 1; i <= 7; i++) {
		formatex(szText, charsmax(szText), "%L %s", id, color_lang[i-1], g_lasermine_id[mode][id] == (i == 7 ? 0 : i) ? "\d[\rX\d]" : "\d[]")
		formatex(szNum, charsmax(szNum), "%s%d", mode == GLOW ? "G:" : "L:", i)
		menu_additem(g_Menu, szText, szNum)
	}

	formatex(szText, charsmax(szText), "\w%L", id, "MENU_BACKNAME");
	menu_setprop(g_Menu, MPROP_BACKNAME, szText)
	
	formatex(szText, charsmax(szText), "\w%L", id, "MENU_NEXTNAME");
	menu_setprop(g_Menu, MPROP_NEXTNAME, szText)
	
	formatex(szText, charsmax(szText), "\w%L", id, "MENU_BACK_TO_MAINMENU");
	menu_setprop(g_Menu, MPROP_EXITNAME, szText)
	menu_setprop(g_Menu, MPROP_EXIT, MEXIT_NORMAL)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)

	menu_display(id, g_Menu, 0)  

	return PLUGIN_CONTINUE
}

public color_menu_handler(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		lm_configs_menu(id)
		return PLUGIN_HANDLED
	}
	if(!get_pcvar_num(cvar_lm[22])) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MENU_DISABLE")
		client_cmd(id, "spk %s", Menu_Sounds[1])
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(cvar_lm[12]) && !(get_user_flags(id) & lm_flag_access)) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_NOACCESS");
		client_cmd(id, "spk %s", Menu_Sounds[1])
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	static cmd[32], maccess, callback, iChoice 
	menu_item_getinfo(menu, item, maccess, cmd, charsmax(cmd),_,_, callback) 
	iChoice = str_to_num(cmd[2])

	// Glow
	if(equal(cmd, "G:", 2)) {
		if(!get_pcvar_num(cvar_lm[13])) {
			client_cmd(id, "spk %s", Menu_Sounds[1])
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_GLOW_DISABLE")
			menu_destroy(menu)
			lm_configs_menu(id)
			return PLUGIN_HANDLED
		}

		switch(iChoice) {
			case 1: g_lasermine_id[GLOW][id] = 1
			case 2: g_lasermine_id[GLOW][id] = 2
			case 3: g_lasermine_id[GLOW][id] = 3
			case 4: g_lasermine_id[GLOW][id] = 4
			case 5: g_lasermine_id[GLOW][id] = 5
			case 6:  {
				client_cmd(id, "messagemode ^"[LM]Change_color_glow_R^"")
				set_hudmessage(100, 255, 100, -1.0, -1.0, 0, 6.0, 6.0, 0.0, 0.0, -1);
				show_hudmessage(id, "%L", id, "STR_DEFINE_RED");
			}
			case 7: g_lasermine_id[GLOW][id] = 0
			
		} 
		Lasermine_Glow_update(id)
	}
	// Line
	if(equal(cmd, "L:", 2)) {
		if(!get_pcvar_num(cvar_lm[5])) {
			client_cmd(id, "spk %s", Menu_Sounds[1])
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_LINE_DISABLE")
			menu_destroy(menu)
			lm_configs_menu(id)
			return PLUGIN_HANDLED
		}
		switch(iChoice) {
			case 1: {
				g_lasermine_id[LINE][id] = 1
				line_color_RGB[RED][id] = 255
				line_color_RGB[GREEN][id] = 255
				line_color_RGB[BLUE][id] = 255;
			}
			case 2: {
				g_lasermine_id[LINE][id] = 2
				line_color_RGB[RED][id] = 255
				line_color_RGB[GREEN][id] = 255
				line_color_RGB[BLUE][id] = 0;
			}
			case 3: {
				g_lasermine_id[LINE][id] = 3
				line_color_RGB[RED][id] = 255
				line_color_RGB[GREEN][id] = 0
				line_color_RGB[BLUE][id] = 0;
			}
			case 4: {
				g_lasermine_id[LINE][id] = 4
				line_color_RGB[RED][id] = 0
				line_color_RGB[GREEN][id] = 255
				line_color_RGB[BLUE][id] = 0;
			}
			case 5: {
				g_lasermine_id[LINE][id] = 5
				line_color_RGB[RED][id] = 0
				line_color_RGB[GREEN][id] = 255
				line_color_RGB[BLUE][id] = 255;
			}
			case 6: {
				client_cmd(id, "messagemode ^"[LM]Change_color_line_R^"")
				set_hudmessage(100, 255, 100, -1.0, -1.0, 0, 6.0, 6.0, 0.0, 0.0, -1);
				show_hudmessage(id, "%L", id, "STR_DEFINE_RED");
			}
			case 7: {
				g_lasermine_id[LINE][id] = 0
				static szColors_line[16]
				if(!get_pcvar_num(cvar_lm[11])) {
					get_pcvar_string(cvar_lm[7], szColors_line, 15)
									
					static gRed2[4], gGreen2[4], gBlue2[4], iRed2, iGreen2, iBlue2
					parse(szColors_line, gRed2, 3, gGreen2, 3, gBlue2, 3)
										
					iRed2 = clamp(str_to_num(gRed2), 0, 255)
					iGreen2 = clamp(str_to_num(gGreen2), 0, 255)
					iBlue2 = clamp(str_to_num(gBlue2), 0, 255)
						
					line_color_RGB[RED][id] = iRed2;
					line_color_RGB[GREEN][id] = iGreen2;
					line_color_RGB[BLUE][id] = iBlue2;
				}
				if(get_pcvar_num(cvar_lm[11])) {
					line_color_RGB[RED][id] = random_num(0,255);
					line_color_RGB[GREEN][id] = random_num(0,255);
					line_color_RGB[BLUE][id] = random_num(0,255);
				}
			}
		}
	}

	if(iChoice != 6) client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_COLOR_SUCEFFULL")
	client_cmd(id, "spk %s", Menu_Sounds[0])
	menu_destroy(menu)
	lm_configs_menu(id)
	
	return PLUGIN_CONTINUE 
} 
/*------------------------------------------------------------------------------------
				[Custom Color Command Action]
-------------------------------------------------------------------------------------*/
public change_color_glow_red(id) {
	static param[6]; read_argv(1, param, charsmax(param))
	return define_color(id, RED, GLOW, param)
}

public change_color_glow_green(id) {
	static param[6]; read_argv(1, param, charsmax(param))
	return define_color(id, GREEN, GLOW, param)
}

public change_color_glow_blue(id) {
	static param[6]; read_argv(1, param, charsmax(param))
	return define_color(id, BLUE, GLOW, param)
}

public change_color_line_red(id) {
	static param[6]; read_argv(1, param, charsmax(param))
	return define_color(id, RED, LINE, param);
}

public change_color_line_green(id) {
	static param[6]; read_argv(1, param, charsmax(param))
	return define_color(id, GREEN, LINE, param);
}

public change_color_line_blue(id) {
	static param[6]; read_argv(1, param, charsmax(param))
	return define_color(id, BLUE, LINE, param);
}

stock define_color(id, color_mode, mode, const param[]) {			
	
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;

	for (new x; x < strlen(param); x++) {
		if(!isdigit(param[x])) {
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_DEFINE_COLOR_ERROR1")
			client_cmd(id, "spk %s", Menu_Sounds[1])
			lm_configs_menu(id)
			return PLUGIN_HANDLED        
		}
	}
	static amount
	amount = str_to_num(param)

	if (amount < 0 || amount > 255) {
		lm_configs_menu(id)
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_DEFINE_COLOR_ERROR2")
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED    
	}
	if(get_pcvar_num(cvar_lm[12]) && !(get_user_flags(id) & lm_flag_access)) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_NOACCESS");
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	if(!get_pcvar_num(cvar_lm[22])) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MENU_DISABLE")
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}

	if(mode == GLOW) // Glow
	{
		if(!get_pcvar_num(cvar_lm[13])) {
			client_cmd(id, "spk %s", Menu_Sounds[1])
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_GLOW_DISABLE")
			lm_configs_menu(id)
			return PLUGIN_HANDLED
		}
		else if(color_mode == RED) {
			glow_color_RGB[CUSTOM_R][id] = amount
			client_cmd(id, "messagemode ^"[LM]Change_color_glow_G^"");
			set_hudmessage(100, 255, 100, -1.0, -1.0, 0, 6.0, 6.0, 0.0, 0.0, -1);
			show_hudmessage(id, "%L", id, "STR_DEFINE_GREEN");
		}
		else if(color_mode == GREEN) {
			glow_color_RGB[CUSTOM_G][id] = amount
			client_cmd(id, "messagemode ^"[LM]Change_color_glow_B^"");
			set_hudmessage(100, 255, 100, -1.0, -1.0, 0, 6.0, 6.0, 0.0, 0.0, -1);
			show_hudmessage(id, "%L", id, "STR_DEFINE_BLUE");
		}
		else if(color_mode == BLUE) {
			g_lasermine_id[GLOW][id] = 6
			glow_color_RGB[CUSTOM_B][id] = amount
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_COLOR_SUCEFFULL")
			Lasermine_Glow_update(id)
		}
	}
	else if(mode == LINE) {
		if(!get_pcvar_num(cvar_lm[5])) {
			client_cmd(id, "spk %s", Menu_Sounds[1])
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_LINE_DISABLE")
			lm_configs_menu(id)
			return PLUGIN_HANDLED
		}
		else if(color_mode == RED) {
			line_color_RGB[CUSTOM_R][id] = amount
			client_cmd(id, "messagemode ^"[LM]Change_color_line_G^"");
			set_hudmessage(100, 255, 100, -1.0, -1.0, 0, 6.0, 6.0, 0.0, 0.0, -1);
			show_hudmessage(id, "%L", id, "STR_DEFINE_GREEN");
		}
		else if(color_mode == GREEN) {
			line_color_RGB[CUSTOM_G][id] = amount
			client_cmd(id, "messagemode ^"[LM]Change_color_line_B^"");
			set_hudmessage(100, 255, 100, -1.0, -1.0, 0, 6.0, 6.0, 0.0, 0.0, -1);
			show_hudmessage(id, "%L", id, "STR_DEFINE_BLUE");
		}
		else if(color_mode == BLUE) {
			line_color_RGB[CUSTOM_B][id] = amount
			if(line_color_RGB[CUSTOM_R][id] < 30 && line_color_RGB[CUSTOM_G][id] < 30 && line_color_RGB[CUSTOM_B][id] < 30) {
				client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_DEFINE_COLOR_ERROR3")
				lm_configs_menu(id)
				return PLUGIN_HANDLED
			}

			g_lasermine_id[LINE][id] = 6
			line_color_RGB[RED][id] = line_color_RGB[CUSTOM_R][id]
			line_color_RGB[GREEN][id] = line_color_RGB[CUSTOM_G][id]
			line_color_RGB[BLUE][id] = line_color_RGB[CUSTOM_B][id]
			
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_COLOR_SUCEFFULL")
		}
	}

	lm_configs_menu(id)
	client_cmd(id, "spk %s", Menu_Sounds[0])
	
	return PLUGIN_CONTINUE;
}

/*------------------------------------------------------------------------------------
				[Choose Model/Sprite of Lasermine]
-------------------------------------------------------------------------------------*/
public choose_model_sprite_menu(id, model_sprite) {
	if(get_pcvar_num(cvar_lm[12]) && !(get_user_flags(id) & lm_flag_access)) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_NOACCESS");
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	if(!get_pcvar_num(cvar_lm[22])) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MENU_DISABLE")
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}

	client_cmd(id, "spk %s", Menu_Sounds[0])
	
	static szText[512], szItem[32]
	formatex(szText, charsmax(szText), "%L %L", id, "MENU_TAG", id, model_sprite == MODEL ? "CHOOSE_LM_MODEL_MENU_TITLE" : "CHOOSE_LM_SPR_MENU_TITLE")
	new g_Menu = menu_create(szText, "model_sprite_menu_handler")
	
	if(model_sprite == MODEL)
		for(new i = 0; i < MAX_MODELS; i++) {
			formatex(szText, charsmax(szText), "\w%L %s", id, model_langs[i], g_lasermine_id[MODEL][id] == i ? "\d[\rX\d]" : "\d[]")
			formatex(szItem, charsmax(szItem), "M:%d", i)
			menu_additem(g_Menu, szText, szItem)
		}
	else {
		for(new i = 0; i < MAX_SPRITES; i++) {
			formatex(szText, charsmax(szText), "\w%L %s", id, spr_langs[i], g_lasermine_id[SPRITE][id] == i ? "\d[\rX\d]" : "\d[]")
			formatex(szItem, charsmax(szItem), "S:%d", i)
			menu_additem(g_Menu, szText, szItem)
		}
	}

	menu_setprop(g_Menu, MPROP_EXIT, MEXIT_ALL)
	
	formatex(szText, charsmax(szText), "\w%L", id, "MENU_BACKNAME");
	menu_setprop(g_Menu, MPROP_BACKNAME, szText)
	
	formatex(szText, charsmax(szText), "\w%L", id, "MENU_NEXTNAME");
	menu_setprop(g_Menu, MPROP_NEXTNAME, szText)
	
	formatex(szText, charsmax(szText), "\w%L", id, "MENU_BACK_TO_MAINMENU");
	menu_setprop(g_Menu, MPROP_EXITNAME, szText)

	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)

	menu_display(id, g_Menu, 0) 

	return PLUGIN_CONTINUE
}

public model_sprite_menu_handler(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		lm_configs_menu(id)
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(cvar_lm[12]) && !(get_user_flags(id) & lm_flag_access)) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_NOACCESS");
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	if(!get_pcvar_num(cvar_lm[22])) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MENU_DISABLE")
		client_cmd(id, "spk %s", Menu_Sounds[1])
		return PLUGIN_HANDLED
	}
	
	static cmd[16], maccess, callback, iChoice 
	menu_item_getinfo(menu, item, maccess, cmd, charsmax(cmd),_,_, callback) 
	iChoice = str_to_num(cmd[2])
	
	if(equal(cmd, "M:", 2)) {
		g_lasermine_id[MODEL][id] = iChoice
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MODEL_SUCEFFULL");
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_SAVE_MODEL");
	}
	else if(equal(cmd, "S:", 2)) {
		if(!get_pcvar_num(cvar_lm[5])) {
			client_cmd(id, "spk %s", Menu_Sounds[1])
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_LINE_DISABLE")
			lm_configs_menu(id)
			return PLUGIN_HANDLED
		}
		g_lasermine_id[SPRITE][id] = iChoice
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_SPRITE_SUCEFFULL");
	}
	client_cmd(id, "spk %s", Menu_Sounds[0])
	
	lm_configs_menu(id)
	
	return PLUGIN_CONTINUE 
} 

/*===========================================================================================================================================================================================
												 [Bools]
===========================================================================================================================================================================================*/
bool:is_valid_lasermine(ent) {
	if(!pev_valid(ent)) return false;

	static EntityName[32]; pev(ent, pev_classname, EntityName, 31);
	if(!equal(EntityName, Lasermine_Classname)) return false;
	
	return true;
}

bool:Allowed_Time(id) {
	if(!is_user_alive(id)) return false;

	if(!zp_has_round_started()) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_DELAY");
		return false;
	}
	if (zp_get_user_zombie(id)) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_CBT");
		return false;
	}
	if(!allow_plant) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_ENDROUND");
		return false;
	}

	if(get_pcvar_num(cvar_lm[12])) {
		if(get_user_flags(id) & lm_flag_access) return true;
		else {
			client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_NOACCESS");
			return false;
		}
	}
	return true;
}

bool:Allow_Remove(id) {
	if(!Allowed_Time(id)) return false;
	static tgt,body,Float:vo[3],Float:to[3];
	get_user_aiming(id,tgt,body);
	if(!pev_valid(tgt)) return false;
	pev(id,pev_origin,vo);
	pev(tgt,pev_origin,to);
	if(get_distance_f(vo,to) > get_pcvar_float(cvar_lm[26])) return false;
	
	static EntityName[32];
	pev(tgt, pev_classname, EntityName, 31);
	if(!equal(EntityName, Lasermine_Classname)) return false;
	if(pev(tgt,LASERMINE_OWNER) != id) return false;
	
	return true;
}

bool:Allow_Plant(id) {
	if (!Allowed_Time(id)) return false;

	if (g_deployed[id] >= get_pcvar_num(cvar_lm[0])) {
		client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_MAXDEPLOY");
		return false;
	}
	
	static Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vOrigin[3];
	
	pev(id, pev_origin, vOrigin); velocity_by_aim(id, 128, vTraceDirection);
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd);
	
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0);
	
	static Float:fFraction,Float:vTraceNormal[3]; get_tr2(0, TR_flFraction, fFraction);
	
	// -- We hit something!
	if (fFraction < 1.0) {
		// -- Save results to be used later.
		get_tr2(0, TR_vecEndPos, vTraceEnd);
		get_tr2(0, TR_vecPlaneNormal, vTraceNormal);

		return true;
	}

	client_printcolor(id, "%L %L", id, "CHATTAG", id, "STR_PLANTWALL")
	return false;
}

/*===========================================================================================================================================================================================
												[Stocks]
===========================================================================================================================================================================================*/
// Extra Damage
stock set_user_extra_damage(id, attacker, damage, weaponDescription[]) {
	if (pev(id, pev_takedamage) == DAMAGE_NO || damage <= 0 || !zp_get_user_zombie(id)) 
		return;
 
	if (pev_user_health(id) - damage <= 0) {
		set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
		ExecuteHamB(Ham_Killed, id, attacker, 2);
		set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);
        
		message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"));
		write_byte(attacker);
		write_byte(id);
		write_byte(0);
		write_string(weaponDescription);
		message_end();
                
		if(!get_pcvar_num(cvar_lm[18])) 
			set_pev(attacker, pev_frags, float(get_user_frags(attacker) + 1));
                        
		static kname[32], vname[32], kauthid[32], vauthid[32], kteam[10], vteam[10];
        
		get_user_name(attacker, kname, 31); get_user_team(attacker, kteam, 9); get_user_authid(attacker, kauthid, 31);
		get_user_name(id, vname, 31); get_user_team(id, vteam, 9); get_user_authid(id, vauthid, 31);
                        
		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", kname, get_user_userid(attacker), kauthid, kteam, 
		vname, get_user_userid(id), vauthid, vteam, weaponDescription);
		
		if(get_pcvar_num(cvar_lm[9])) {
			zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + get_pcvar_num(cvar_lm[19]))
			client_printcolor(attacker, "%L %L", attacker, "CHATTAG", attacker, "STR_LM_KILL_RWD", get_pcvar_num(cvar_lm[19]))
		}
	}
	else {
		static origin[3]; get_user_origin(id, origin);
		message_begin(MSG_ONE,get_user_msgid("Damage"),{0,0,0},id);
		write_byte(21);
		write_byte(20);
		write_long(DMG_BLAST);
		write_coord(origin[0]);
		write_coord(origin[1]);
		write_coord(origin[2]);
		message_end();
		set_pev(id, pev_health, pev(id, pev_health) - float(damage));
	}
}

// Colored Chat
stock client_printcolor(const id, const input[], any:...) {
	static msg[191], count, players[32]
	count = 1
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")  // Green
	replace_all(msg, 190, "!y", "^1")  // Yellow
	replace_all(msg, 190, "!t", "^3")  // Team
	
	if (id) players[0] = id; 
	else get_players(players, count, "ch") 

	for (new i = 0; i < count; i++) {
		if (is_user_connected(players[i])) {
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}
	}
}
/*------------------------------------------------------------------------------------
				[Fakemeta Stocks]
-------------------------------------------------------------------------------------*/
stock set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
	static Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}

stock pev_user_health(id) {
	static Float:health
	pev(id,pev_health,health)
	return floatround(health)
}

stock set_user_health(id,health) health > 0 ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);

stock get_user_godmode(index) {
	static Float:val
	pev(index, pev_takedamage, val)
	return (val == DAMAGE_NO)
}

stock set_user_frags(index, frags) {
	set_pev(index, pev_frags, float(frags))
	return 1
}

stock pev_user_frags(index) {
	static Float:frags;
	pev(index,pev_frags,frags);
	return floatround(frags);
}