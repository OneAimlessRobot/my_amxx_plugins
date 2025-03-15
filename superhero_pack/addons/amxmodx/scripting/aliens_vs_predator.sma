/*================================================================================
	
		******************************************************
		************** [Aliens vs Predator Mod] **************
		******************************************************

	----------------------
	-*- Licensing Info -*-
	----------------------
	
	Aliens vs Predator Mod
	Copyright (C) 2017 by Crazy
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.

	-------------------
	-*- Description -*-
	-------------------
	
	Aliens vs Predator is a Counter-Strike server side modification, developed as
	an AMX Mod X plugin, which completely revamps the gameplay, turning the
	game into an intense "Aliens vs Predator" survival experience.
	
	Even though it's strongly based on the classic avp mod, it
	takes the concept to a new level by introducing:
	
	* Gameplay Modes: Decimation, Extinction
	
	There is plenty of customization as well, which enables you to create
	several different styles of gameplay. You can:
	
	* Set aliens and predators' health, speed, models and more
	* Change overall map lighting (lightnings available for the dark settings)
	* Set different colors and sizes for nightvision
	* Replace sounds or add some background themes
	* And many more...

	-------------
	-*- Media -*-
	-------------
	
	* (Old version) Gameplay Video 1: http://www.youtube.com/watch?v=grk72Jk8_U8

	--------------------
	-*- Requirements -*-
	--------------------
	
	* Mods: Counter-Strike 1.6 or Condition-Zero
	* AMXX: Version 1.8.0 or later

	--------------------
	-*- Installation -*-
	--------------------
	
	Extract the contents from the .zip file to your server's mod directory
	("cstrike" or "czero"). Make sure to keep folder structure.

	-----------------------
	-*- Official Forums -*-
	-----------------------
	
	For the official Aliens vs Predator thread visit:
	http://forums.alliedmods.net/showthread.php?t=295305
	
	There you can:
	
	* Get the latest releases and early betas
	* Discuss new features and suggestions
	* Share sub-plugins (expansions) for the mod
	* Find the support and help you need
	* Report any bugs you might find
	* And all that sort of stuff...

	-------------------------------
	-*- CVARS and Customization -*-
	-------------------------------
	
	For a complete and in-depth cvar list, look at the aliens_vs_predator.cfg file
	located in the amxmodx\configs directory.
	
	Additionally, you can change player models, sounds, weather effects,
	and some other stuff from the configuration file aliens_vs_predator.ini.

	As for add/remove plugin, you'll find a avp_plugins.ini.

	As for editing attributes of classes, extra items or weapons you'll
	find a avp_marine_classes.ini, avp_alien_classes.ini, avp_predator_classes.ini,
	avp_extra_items.ini, avp_weapons.ini. These files will be automatically updated
	as you install nnew custom classes, items or weapons with new entries for you to 
	edit conveniently.

	--------------------------
	-*- New Gameplay Modes -*-
	--------------------------

	* Decimation:
	   A full armed Marines are to face Aliens. The future of the world
	   is in their hands.
	
	* Extinction:
	   A full armed Predators are to face Aliens. The future of the hunting
	   destiny is in their hands.

	----------------------
	-*- Admin Commands -*-
	----------------------
	
	The following console commands are available:
	
	* avp_marine <target> - Turn someone into a Marine
	* avp_alien <target> - Turn someone into a Alien
	* avp_predator <target> - Turn someone into a Predator
	* avp_respawn <target> - Respawn a user
	* avp_decimation - Start Decimation Mode (*)
	* avp_extinction - Start Extinction Mode (*)

	(*) - These commands can only be used at round start.

	------------------
	-*- Plugin API -*-
	------------------

	From version public evolution v1.0, some natives and forwards have been
	added to ease the development of sub-plugins.
	
	Look for the aliens_vs_predator.inc file in your amxmodx\scripting\include
	folder for the full documented list.

	Look for the avp_examples folder in your amxmodx\scripting\avp_examples
	for some plugin examples.

	---------------
	-*- Credits -*-
	---------------

	* AMXX Dev Team: for all the hard work which made this possible
	* jay-jay: for his hard work on your awesome models.
	* Re.Act!ve: for his nice avp_alien_attack map.
	* MeRcyLeZZ: for his Zombie Mod plugin which I used for reference
	   on earliest stages of development
	* Gamebana / Zombie-Mod.ru: for his nice custom models that I used
	   into this mod.
	* ML Translations: OciXCrom/Crazy (en), Crazy (bp), ACM1PT (es), yas17sin (fr),
	   LiveSixx (ru), Malatya (tr);
	* Sound-Resource: for his nice custom avp sounds that I used into
	   this mode.
	* Beta testers: for all the feedback, bug reports, and suggestions which
	   constantly help improve this mod further
	* And to all avp-mod supporters out there!

	-----------------
	-*- Changelog -*-
	-----------------

	* Beta v0.1: (Mar 2017)
	   - First Release: most of the basic stuff done.
	   - Added: HP display on hud, lighting setting, Predator M134 Gun,
	      custom nightvision and screen fade effect, Chaos Mod, custom config file.

	* Beta v0.2: (Mar 2017)
	   - Added: Admin commands, skybox setting, custom sounds,
	      Berseker Mod, two new predator weapons (Plasma Caster & Spear Gun),
	      customizable speed/nightvision/glow/aura, enable/disable nightvision,
	      new API natives/forwards.
	   - Fixed some bugs.

	* Public Evolution v1.0b: (May 2017)
	   - Added: configuration files (.ini, .cfg), multi-lingual system,
	      player menu/admin menu, marines (humans), class system, extra items,
	      weapons, new API's (register_weapon, register_item, register_class),
	      points (money) system, predator thermal vision, ambience/player/round sounds,
	      fog system, respawn system (like deathmatch),alien custom camera (change with cvar).
	   - Fixed various bugs.

================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <amx_settings_api>
#include <cs_ham_bots_api>
#include <cs_player_models_api>

new const PLUGIN_VERSION[] = "Public Evolution v1.0b";

new const AVP_SETTINGS_FILE[] = "aliens_vs_predator.ini";
new const AVP_MARINECLASSES_FILE[] = "avp_marine_classes.ini";
new const AVP_ALIENCLASSES_FILE[] = "avp_alien_classes.ini";
new const AVP_PREDATORCLASSES_FILE[] = "avp_predator_classes.ini";
new const AVP_WEAPONS_FILE[] = "avp_weapons.ini";
new const AVP_EXTRAITEMS_FILE[] = "avp_extra_items.ini";

const AVP_PLUGIN_HANDLED = 97;

enum _:AlienData
{
	AlienSection[32],
	AlienName[32],
	AlienInfo[32],
	AlienHealth,
	Float:AlienGravity,
	AlienDamage,
	Float:AlienSpeed,
	AlienModel[32],
	AlienClaw[64],
};

enum _:PredatorData
{
	PredatorSection[32],
	PredatorName[32],
	PredatorInfo[32],
	PredatorHealth,
	Float:PredatorGravity,
	Float:PredatorSpeed,
	PredatorModel[32],
};

enum _:MarineData
{
	MarineSection[32],
	MarineName[32],
	MarineInfo[32],
	MarineHealth,
	Float:MarineGravity,
	Float:MarineSpeed,
	MarineModel[32],
};

enum _:WeaponData
{
	WeaponSection[32],
	WeaponName[32],
	WeaponType,
	WeaponPlugin,
	WeaponFuncID,
};

enum _:ItemData
{
	ItemSection[32],
	ItemName[32],
	ItemCost,
	ItemTeam,
	ItemPlugin,
	ItemFuncID,
};

enum _:menu_data
{
	ACTION_CLASS_ALIEN = 0,
	ACTION_CLASS_MARINE,
	ACTION_CLASS_PREDATOR,
	ACTION_BUY_WPRIMARY,
	ACTION_BUY_WSECONDARY,
	ACTION_MAKE_MARINE,
	ACTION_MAKE_ALIEN,
	ACTION_MAKE_PREDATOR,
	ACTION_RESPAWN_USER,
};

enum
{
	ACCESS_ADMIN_MENU[2],
	ACCESS_MAKE_MARINE[2],
	ACCESS_MAKE_ALIEN[2],
	ACCESS_MAKE_PREDATOR[2],
	ACCESS_RESPAWN_USER[2],
	ACCESS_START_DECIMATION[2],
	ACCESS_START_EXTINCTION[2],
	MAX_ACCESS_FLAGS,
};

enum
{
	AMBIENCE_SOUNDS_DECIMATION,
	AMBIENCE_SOUNDS_EXTINCTION,
	MAX_AMBIENCE_SOUNDS,
};

enum
{
	MODE_NONE = 0,
	MODE_DECIMATION,
	MODE_EXTINCTION,
};

enum
{
	WIN_NO_ONE = 0,
	WIN_ALIENS,
	WIN_PREDATORS,
	WIN_MARINES,
};

enum (+= 100)
{
	TASK_NEWROUND = 2000,
	TASK_SHOWHUD,
	TASK_AMBIENCESOUNDS,
	TASK_RESPAWN,
	TASK_SCREENFADE,
	TASK_NVISION,
	TASK_THERMAL,
};

new const PRD_VISION_SOUNDS[][] = {
	"avp_sounds/prd_vision_change_01.wav",
	"avp_sounds/prd_vision_change_02.wav",
	"avp_sounds/prd_vision_mode_end.wav",
	"avp_sounds/prd_vision_thermal.wav"
};

//- Arrays

new Array:g_array_extra_items, Array:g_array_aln_class, Array:g_array_prd_class, Array:g_array_mrn_class, Array:g_array_weapon, Array:sound_win_aliens, Array:sound_win_marines, Array:sound_win_predators, 
Array:sound_win_noone, Array:sound_start_decimation, Array:sound_start_extinction, Array:ambience_sounds_decimation, Array:ambience_sounds_extinction, Array:ambience_duration_decimation, Array:ambience_duration_extinction, 
Array:alien_pain, Array:predator_pain, Array:alien_die, Array:alien_longjump, Array:predator_die, Array:alien_turnedin, Array:predator_turnedin;

//- Constants

new g_isalive[33], g_already_buyed[33], g_honorpoints[33], g_xenopoints[33], g_marinepoints[33], g_marine[33], g_marine_class[33][2],
g_alien_class[33][2], g_predator_class[33][2], g_predator[33], g_alien[33], g_damagedealt_marine[33], g_damagedealt_predator[33],
g_iRenderMode[33], g_iRenderFx[33], Float:g_fRenderAmount[33], Float:g_fRenderColor[33][3], g_damagedealt_alien[33],
g_nvision[33], g_nvisionenabled[33], g_thermal_nvision[33], g_spawntime[33], g_menu_data[33][menu_data]

new g_maxplayers, g_aclass_i, g_pclass_i, g_mclass_i, g_items_i[4], g_weapon_i[3], g_access_flag[MAX_ACCESS_FLAGS], 
model_vknife_predator[64], model_vknife_marine[64], g_blood_spr, g_newround, g_endround, g_SyncMsg[3], g_ambience_sounds[MAX_AMBIENCE_SOUNDS], 
g_decimation_round, g_extinction_round, g_lastplayerleaving;

new g_fwReturnValue, g_fwRoundStarted, g_fwRoundEnded, g_fwUserMarine_attempt, g_fwUserAlien_attempt, g_fwUserPredator_attempt, g_fwUserMarined_pre, 
g_fwUserPredatorized_pre, g_fwUserAlienized_pre, g_fwUserMarined_post, g_fwUserPredatorized_post, g_fwUserAlienized_post;

new g_skybox_enable, g_skybox_texture[32], g_ambience_fog, g_fog_color[3], g_fog_density;

new g_msgCurWeapon, g_msgTextMsg, g_msgScreenFade, g_msgHideWeapon, g_msgHostagePos, g_msgAmmoPickup, g_msgSendAudio,
g_msgWeapPickup, g_msgFog, g_msgScenario, g_msgStatusIcon;

new Float:g_lastleaptime[33], g_cached_leappredator, Float:g_cached_leappredacooldown, g_cached_leapalien, Float:g_cached_leapaliencooldown


//- Pcvars

new cvar_showactivity, cvar_starting_marinepoints, cvar_starting_xenopoints, cvar_starting_honorpoints, cvar_logcommands, cvar_start_delay, cvar_decimation_enable, cvar_decimation_minplayers, cvar_decimation_chance, 
cvar_marine_unlimited, cvar_lighting, cvar_marine_dmgreward, cvar_alien_dmgreward, cvar_predator_damage, cvar_predator_dmgreward, cvar_leapalien, cvar_leapaliencooldown, cvar_leapalienforce, cvar_leapalienheight, 
cvar_leappredator, cvar_leappredatorcooldown, cvar_leappredatorforce, cvar_leappredatorheight, cvar_decimation_respawn, cvar_decimation_redelay, cvar_extinction_respawn, cvar_extinction_redelay, cvar_marine_nvision[5], 
cvar_alien_nvision[5], cvar_predator_nvision[5], cvar_spectator_nvision, cvar_alien_camera, cvar_marine_killreward, cvar_alien_killreward, cvar_predator_killreward;

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

new const BLOCKED_SPAWN_WEAPONS = (1<<CSW_GLOCK18) | (1<<CSW_USP) | (1<<CSW_C4)

new const OFFSET_FOG_DESITY[] = { 0, 0, 0, 0, 111, 18, 3, 58, 111, 18, 125, 58, 66, 96, 27, 59, 90, 101, 60, 59, 90,
			101, 68, 59, 10, 41, 95, 59, 111, 18, 125, 59, 111, 18, 3, 60, 68, 116, 19, 60 }

new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }

new const MAXCLIP[] = { -1, 13, -1, 10, -1, 7, -1, 30, 30, -1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, -1, 7, 30, 30, -1, 50 }

new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE,
			CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4 }

new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }

const AVP_TEAM_MARINE = (1<<0)
const AVP_TEAM_ALIEN = (1<<1)
const AVP_TEAM_PREDATOR = (1<<2)

const AVP_PRIMARY_WEAPON = (1<<0)
const AVP_SECONDARY_WEAPON = (1<<1)

//- Defines

#define PL_ACTION g_menu_data[id][0]

#define ID_SHOWHUD (taskid - TASK_SHOWHUD)
#define ID_RESPAWN (taskid - TASK_RESPAWN)
#define ID_SCREENFADE (taskid - TASK_SCREENFADE)
#define ID_NVISION (taskid - TASK_NVISION)
#define ID_THERMAL (taskid - TASK_THERMAL)

#define REFILL_WEAPONID args[0]

#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && is_user_alive(%1))
#define is_user_valid(%1) (1 <= %1 <= g_maxplayers)

//- HACK: Reset player maxspeed
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

public plugin_natives()
{
	register_library("aliens_vs_predator");

	register_native("avp_register_alien_class", "native_register_alien_class");
	register_native("avp_register_predator_class", "native_register_predator_class");
	register_native("avp_register_marine_class", "native_register_marine_class");
	register_native("avp_register_weapon", "native_register_weapon");
	register_native("avp_register_extra_item", "native_register_extra_item");
	register_native("avp_get_user_alien", "native_get_user_alien", 1);
	register_native("avp_get_user_marine", "native_get_user_marine", 1);
	register_native("avp_get_user_predator", "native_get_user_predator", 1);
	register_native("avp_get_user_marinepoints", "native_get_user_marinepoints", 1);
	register_native("avp_get_user_xenopoints", "native_get_user_xenopoints", 1);
	register_native("avp_get_user_honorpoints", "native_get_user_honorpoints", 1);
	register_native("avp_set_user_marinepoints", "native_set_user_marinepoints", 1);
	register_native("avp_set_user_xenopoints", "native_set_user_xenopoints", 1);
	register_native("avp_set_user_honorpoints", "native_set_user_honorpoints", 1);
	register_native("avp_make_user_marine", "native_make_user_marine", 1);
	register_native("avp_make_user_alien", "native_make_user_alien", 1);
	register_native("avp_make_user_predator", "native_make_user_predator", 1);
	register_native("avp_get_marine_count", "native_get_marine_count", 1);
	register_native("avp_get_alien_count", "native_get_alien_count", 1);
	register_native("avp_get_predator_count", "native_get_predator_count", 1);
	register_native("avp_get_user_marine_class", "native_get_user_marine_class", 1);
	register_native("avp_get_user_alien_class", "native_get_user_alien_class", 1);
	register_native("avp_get_user_predator_class", "native_get_user_predator_class", 1);
	register_native("avp_set_user_marine_class", "native_set_user_marine_class", 1);
	register_native("avp_set_user_alien_class", "native_set_user_alien_class", 1);
	register_native("avp_set_user_predator_class", "native_set_user_predator_class", 1);
	register_native("avp_get_user_next_marine_class", "native_get_user_next_mrn_class", 1);
	register_native("avp_get_user_next_alien_class", "native_get_user_next_aln_class", 1);
	register_native("avp_get_user_next_pred_class", "native_get_user_next_prd_class", 1);
	register_native("avp_is_decimation_round", "native_is_decimation_round", 1);
	register_native("avp_is_extinction_round", "native_is_extinction_round", 1);
	register_native("avp_get_marine_class_id", "native_get_marine_class_id", 1);
	register_native("avp_get_alien_class_id", "native_get_alien_class_id", 1);
	register_native("avp_get_predator_class_id", "native_get_predator_class_id", 1);
	register_native("avp_get_extra_item_id", "native_get_extra_item_id", 1);
	register_native("avp_force_buy_extra_item", "native_force_buy_extra_item", 1);
	register_native("avp_get_weapon_id", "native_get_weapon_id", 1);
	register_native("avp_force_buy_weapon", "native_force_buy_weapon", 1);
}

public plugin_precache()
{
	g_array_aln_class = ArrayCreate(AlienData);
	g_array_prd_class = ArrayCreate(PredatorData);
	g_array_mrn_class = ArrayCreate(MarineData);
	g_array_weapon = ArrayCreate(WeaponData);
	g_array_extra_items = ArrayCreate(ItemData);
	sound_win_marines = ArrayCreate(64, 1);
	sound_win_aliens = ArrayCreate(64, 1);
	sound_win_predators = ArrayCreate(64, 1);
	sound_win_noone = ArrayCreate(64, 1);
	sound_start_decimation = ArrayCreate(64, 1);
	sound_start_extinction = ArrayCreate(64, 1);
	ambience_sounds_decimation = ArrayCreate(64, 1);
	ambience_sounds_extinction = ArrayCreate(64, 1);
	ambience_duration_decimation = ArrayCreate(1, 1);
	ambience_duration_extinction = ArrayCreate(1, 1);
	alien_pain = ArrayCreate(64, 1);
	predator_pain = ArrayCreate(64, 1);
	alien_die = ArrayCreate(64, 1);
	predator_die = ArrayCreate(64, 1);
	alien_longjump = ArrayCreate(64, 1);
	alien_turnedin = ArrayCreate(64, 1);
	predator_turnedin = ArrayCreate(64, 1);

	if (!amx_load_setting_int(AVP_SETTINGS_FILE, "Custom Skies", "ENABLE", g_skybox_enable))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Custom Skies", "ENABLE", 1);
		g_skybox_enable = 1;
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Custom Skies", "SKY NAMES", g_skybox_texture, charsmax(g_skybox_texture)))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Custom Skies", "SKY NAMES", "xen9");
		g_skybox_texture = "xen9";
	}

	if (!amx_load_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG", g_ambience_fog))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG", 1);
		g_ambience_fog = 1;
	}

	if (!amx_load_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG DENSITY", g_fog_density))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG DENSITY", 4);
		g_fog_density = 4;
	}

	if (!amx_load_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG COLOR R", g_fog_color[0]))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG COLOR R", 128);
		g_fog_color[0] = 128;
	}

	if (!amx_load_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG COLOR G", g_fog_color[1]))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG COLOR G", 0);
		g_fog_color[1] = 0;
	}

	if (!amx_load_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG COLOR B", g_fog_color[2]))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Weather Effects", "FOG COLOR B", 0);
		g_fog_color[2] = 0;
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Knife Models", "V_KNIFE MARINE", model_vknife_marine, charsmax(model_vknife_marine)))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Knife Models", "V_KNIFE MARINE", "models/avp_models/marine_knife.mdl");
		model_vknife_marine = "models/avp_models/marine_knife.mdl";
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Knife Models", "V_KNIFE PREDATOR", model_vknife_predator, charsmax(model_vknife_predator)))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Knife Models", "V_KNIFE PREDATOR", "models/avp_models/predator_knife.mdl");
		model_vknife_predator = "models/avp_models/predator_knife.mdl";
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS ADMIN MENU", g_access_flag[ACCESS_ADMIN_MENU], charsmax(g_access_flag[ACCESS_ADMIN_MENU])))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS ADMIN MENU", "d");
		g_access_flag[ACCESS_ADMIN_MENU] = "d";
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS MAKE MARINE", g_access_flag[ACCESS_MAKE_MARINE], charsmax(g_access_flag[ACCESS_MAKE_MARINE])))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS MAKE MARINE", "d");
		g_access_flag[ACCESS_MAKE_MARINE] = "d";
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS MAKE ALIEN", g_access_flag[ACCESS_MAKE_ALIEN], charsmax(g_access_flag[ACCESS_MAKE_ALIEN])))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS MAKE ALIEN", "d");
		g_access_flag[ACCESS_MAKE_ALIEN] = "d";
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS MAKE PREDATOR", g_access_flag[ACCESS_MAKE_PREDATOR], charsmax(g_access_flag[ACCESS_MAKE_PREDATOR])))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS MAKE PREDATOR", "d");
		g_access_flag[ACCESS_MAKE_PREDATOR] = "d";
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS RESPAWN USER", g_access_flag[ACCESS_RESPAWN_USER], charsmax(g_access_flag[ACCESS_RESPAWN_USER])))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS RESPAWN USER", "d");
		g_access_flag[ACCESS_RESPAWN_USER] = "d";
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS START DECIMATION", g_access_flag[ACCESS_START_DECIMATION], charsmax(g_access_flag[ACCESS_START_DECIMATION])))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS START DECIMATION", "d");
		g_access_flag[ACCESS_START_DECIMATION] = "d";
	}

	if (!amx_load_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS START EXTINCTION", g_access_flag[ACCESS_START_EXTINCTION], charsmax(g_access_flag[ACCESS_START_EXTINCTION])))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Access Flags", "ACCESS START EXTINCTION", "d");
		g_access_flag[ACCESS_START_EXTINCTION] = "d";
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Win Sounds", "SOUND WIN MARINES", sound_win_marines))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Win Sounds", "SOUND WIN MARINES", "nm_goodbadugly.wav");
		ArrayPushString(sound_win_marines, "nm_goodbadugly.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Win Sounds", "SOUND WIN ALIENS", sound_win_aliens))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Win Sounds", "SOUND WIN ALIENS", "nm_goodbadugly.wav");
		ArrayPushString(sound_win_aliens, "nm_goodbadugly.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Win Sounds", "SOUND WIN PREDATORS", sound_win_predators))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Win Sounds", "SOUND WIN PREDATORS", "nm_goodbadugly.wav");
		ArrayPushString(sound_win_predators, "nm_goodbadugly.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Win Sounds", "SOUND WIN NOONE", sound_win_noone))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Win Sounds", "SOUND WIN NOONE", "nm_goodbadugly.wav");
		ArrayPushString(sound_win_noone, "nm_goodbadugly.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Round Start Sounds", "ROUND DECIMATION", sound_start_decimation))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Round Start Sounds", "ROUND DECIMATION", "nm_goodbadugly.wav");
		ArrayPushString(sound_start_decimation, "nm_goodbadugly.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Round Start Sounds", "ROUND EXTINCTION", sound_start_extinction))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Round Start Sounds", "ROUND EXTINCTION", "nm_goodbadugly.wav");
		ArrayPushString(sound_start_extinction, "nm_goodbadugly.wav");
	}

	if (!amx_load_setting_int(AVP_SETTINGS_FILE, "Ambience Sounds", "DECIMATION ENABLE", g_ambience_sounds[AMBIENCE_SOUNDS_DECIMATION]))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Ambience Sounds", "DECIMATION ENABLE", 1);
		g_ambience_sounds[AMBIENCE_SOUNDS_DECIMATION] = 1;
	}

	if (!amx_load_setting_int_arr(AVP_SETTINGS_FILE, "Ambience Sounds", "DECIMATION DURATIONS", ambience_duration_decimation))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Ambience Sounds", "DECIMATION DURATIONS", 14);
		ArrayPushCell(ambience_duration_decimation, 14);
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Ambience Sounds", "DECIMATION SOUNDS", ambience_sounds_decimation))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Ambience Sounds", "DECIMATION SOUNDS", "nm_goodbadugly.wav");
		ArrayPushString(ambience_sounds_decimation, "nm_goodbadugly.wav");
	}

	if (!amx_load_setting_int(AVP_SETTINGS_FILE, "Ambience Sounds", "EXTINCTION ENABLE", g_ambience_sounds[AMBIENCE_SOUNDS_EXTINCTION]))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Ambience Sounds", "EXTINCTION ENABLE", 1);
		g_ambience_sounds[AMBIENCE_SOUNDS_EXTINCTION] = 1;
	}

	if (!amx_load_setting_int_arr(AVP_SETTINGS_FILE, "Ambience Sounds", "EXTINCTION DURATIONS", ambience_duration_extinction))
	{
		amx_save_setting_int(AVP_SETTINGS_FILE, "Ambience Sounds", "EXTINCTION DURATIONS", 14);
		ArrayPushCell(ambience_duration_extinction, 14);
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Ambience Sounds", "EXTINCTION SOUNDS", ambience_sounds_extinction))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Ambience Sounds", "EXTINCTION SOUNDS", "nm_goodbadugly.wav");
		ArrayPushString(ambience_sounds_extinction, "nm_goodbadugly.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Player Sounds", "ALIEN TURNEDIN", alien_turnedin))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Player Sounds", "ALIEN TURNEDIN", "avp_sounds/alien_turnedin.wav");
		ArrayPushString(alien_turnedin, "avp_sounds/alien_turnedin.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Player Sounds", "PREDATOR TURNEDIN", predator_turnedin))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Player Sounds", "PREDATOR TURNEDIN", "avp_sounds/prd_turnedin.wav");
		ArrayPushString(predator_turnedin, "avp_sounds/prd_turnedin.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Player Sounds", "ALIEN PAIN", alien_pain))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Player Sounds", "ALIEN PAIN", "avp_sounds/alien_pain_01.wav");
		ArrayPushString(alien_pain, "avp_sounds/alien_pain_01.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Player Sounds", "ALIEN DIE", alien_die))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Player Sounds", "ALIEN DIE", "avp_sounds/alien_die_01.wav");
		ArrayPushString(alien_die, "avp_sounds/alien_die_01.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Player Sounds", "ALIEN LONGJUMP", alien_longjump))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Player Sounds", "ALIEN LONGJUMP", "avp_sounds/alien_longjump.wav");
		ArrayPushString(alien_longjump, "avp_sounds/alien_longjump.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Player Sounds", "PREDATOR PAIN", predator_pain))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Player Sounds", "PREDATOR PAIN", "avp_sounds/prd_pain_01.wav");
		ArrayPushString(predator_pain, "avp_sounds/prd_pain_01.wav");
	}

	if (!amx_load_setting_string_arr(AVP_SETTINGS_FILE, "Player Sounds", "PREDATOR DIE", predator_die))
	{
		amx_save_setting_string(AVP_SETTINGS_FILE, "Player Sounds", "PREDATOR DIE", "avp_sounds/prd_die_01.wav");
		ArrayPushString(predator_die, "avp_sounds/prd_die_01.wav");
	}

	if (g_skybox_enable)
	{
		new szSky[32];
		formatex(szSky, charsmax(szSky), "gfx/env/%sbk.tga", g_skybox_texture);
		engfunc(EngFunc_PrecacheGeneric, szSky);
		formatex(szSky, charsmax(szSky), "gfx/env/%sdn.tga", g_skybox_texture);
		engfunc(EngFunc_PrecacheGeneric, szSky);
		formatex(szSky, charsmax(szSky), "gfx/env/%sft.tga", g_skybox_texture);
		engfunc(EngFunc_PrecacheGeneric, szSky);
		formatex(szSky, charsmax(szSky), "gfx/env/%slf.tga", g_skybox_texture);
		engfunc(EngFunc_PrecacheGeneric, szSky);
		formatex(szSky, charsmax(szSky), "gfx/env/%srt.tga", g_skybox_texture);
		engfunc(EngFunc_PrecacheGeneric, szSky);
		formatex(szSky, charsmax(szSky), "gfx/env/%sup.tga", g_skybox_texture);
		engfunc(EngFunc_PrecacheGeneric, szSky);
	}

	engfunc(EngFunc_PrecacheModel, model_vknife_predator);
	engfunc(EngFunc_PrecacheModel, model_vknife_marine);

	new sound[64];

	for (new i = 0; i < ArraySize(sound_win_marines); i++)
	{
		ArrayGetString(sound_win_marines, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(sound_win_aliens); i++)
	{
		ArrayGetString(sound_win_aliens, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(sound_win_predators); i++)
	{
		ArrayGetString(sound_win_predators, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(sound_win_noone); i++)
	{
		ArrayGetString(sound_win_noone, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(sound_start_decimation); i++)
	{
		ArrayGetString(sound_start_decimation, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(sound_start_extinction); i++)
	{
		ArrayGetString(sound_start_extinction, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	if (g_ambience_sounds[AMBIENCE_SOUNDS_DECIMATION])
	{
		for (new i = 0; i < ArraySize(ambience_sounds_decimation); i++)
		{
			ArrayGetString(ambience_sounds_decimation, i, sound, charsmax(sound));
			engfunc(EngFunc_PrecacheSound, sound);
		}
	}

	if (g_ambience_sounds[AMBIENCE_SOUNDS_EXTINCTION])
	{
		for (new i = 0; i < ArraySize(ambience_sounds_extinction); i++)
		{
			ArrayGetString(ambience_sounds_extinction, i, sound, charsmax(sound));
			engfunc(EngFunc_PrecacheSound, sound);
		}
	}

	for (new i = 0; i < ArraySize(alien_pain); i++)
	{
		ArrayGetString(alien_pain, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(alien_die); i++)
	{
		ArrayGetString(alien_die, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(alien_longjump); i++)
	{
		ArrayGetString(alien_longjump, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(alien_turnedin); i++)
	{
		ArrayGetString(alien_turnedin, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(predator_turnedin); i++)
	{
		ArrayGetString(predator_turnedin, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(predator_pain); i++)
	{
		ArrayGetString(predator_pain, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < ArraySize(predator_die); i++)
	{
		ArrayGetString(predator_die, i, sound, charsmax(sound));
		engfunc(EngFunc_PrecacheSound, sound);
	}

	for (new i = 0; i < sizeof PRD_VISION_SOUNDS; i++)
	{
		engfunc(EngFunc_PrecacheSound, PRD_VISION_SOUNDS[i]);
	}

	g_blood_spr = precache_model("sprites/blood.spr");
	precache_model("models/rpgrocket.mdl");
}

public plugin_init()
{
	if (!g_aclass_i) set_fail_state("No alien classes loaded!");
	else if (!g_pclass_i) set_fail_state("No predator classes loaded!");
	else if (!g_mclass_i) set_fail_state("No marine classes loaded!");

	register_plugin("Aliens vs Predator", PLUGIN_VERSION, "Crazy");

	register_dictionary("aliens_vs_predator.txt");

	register_cvar("avp_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	set_cvar_string("avp_version", PLUGIN_VERSION);

	register_clcmd("say avpmenu", "menu_game");
	register_clcmd("say /avpmenu", "menu_game");
	register_clcmd("chooseteam", "clcmd_changeteam");
	register_clcmd("jointeam", "clcmd_changeteam");
	register_clcmd("nightvision", "clcmd_nightvision");

	register_concmd("avp_marine", "cmd_marine", _, "<target> - Turn someone into a Marine", 0);
	register_concmd("avp_alien", "cmd_alien", _, "<target> - Turn someone into a Alien", 0);
	register_concmd("avp_predator", "cmd_predator", _, "<target> - Turn someone into a Predator", 0);
	register_concmd("avp_respawn", "cmd_respawn", _, "<target> - Respawn a dead player", 0);
	register_concmd("avp_decimation", "cmd_decimation", _, "- Start Decimation Mod", 0);
	register_concmd("avp_extinction", "cmd_extinction", _, "- Start Extinction Mod", 0);

	cvar_logcommands = register_cvar("avp_logcommands", "1");
	cvar_lighting = register_cvar("avp_lighting", "a");
	cvar_start_delay = register_cvar("avp_start_delay", "5");
	cvar_showactivity = get_cvar_pointer("amx_show_activity");
	cvar_starting_marinepoints = register_cvar("avp_starting_marinepoints", "0");
	cvar_starting_xenopoints = register_cvar("avp_starting_xenopoints", "0");
	cvar_starting_honorpoints = register_cvar("avp_starting_honorpoints", "0");
	cvar_spectator_nvision = register_cvar("avp_spectator_nvision", "1");

	cvar_decimation_enable = register_cvar("avp_decimation_enable", "1");
	cvar_decimation_minplayers = register_cvar("avp_decimation_minplayers", "2");
	cvar_decimation_chance = register_cvar("avp_decimation_chance", "3");
	cvar_decimation_respawn = register_cvar("avp_decimation_respawn", "3");
	cvar_decimation_redelay = register_cvar("avp_decimation_respawn_delay", "7");

	cvar_extinction_respawn = register_cvar("avp_extinction_respawn", "3");
	cvar_extinction_redelay = register_cvar("avp_extinction_respawn_delay", "7");

	cvar_marine_unlimited = register_cvar("avp_marine_unlimited_ammo", "1");
	cvar_marine_dmgreward = register_cvar("avp_marine_damage_reward", "300");
	cvar_marine_killreward = register_cvar("avp_marine_killreward", "10");
	cvar_marine_nvision[0] = register_cvar("avp_marine_nvision", "0");
	cvar_marine_nvision[1] = register_cvar("avp_marine_nvision_radius", "30");
	cvar_marine_nvision[2] = register_cvar("avp_marine_nvision_R", "255");
	cvar_marine_nvision[3] = register_cvar("avp_marine_nvision_G", "255");
	cvar_marine_nvision[4] = register_cvar("avp_marine_nvision_B", "255");

	cvar_alien_dmgreward = register_cvar("avp_alien_damage_reward", "300");
	cvar_alien_killreward = register_cvar("avp_alien_killreward", "10");
	cvar_alien_camera = register_cvar("avp_alien_camera", "1");
	cvar_leapalien = register_cvar("avp_alien_leap", "1");
	cvar_leapaliencooldown = register_cvar("avp_alien_leap_cooldown", "6.0");
	cvar_leapalienforce = register_cvar("avp_alien_leap_force", "600");
	cvar_leapalienheight = register_cvar("avp_alien_leap_height", "300");
	cvar_alien_nvision[0] = register_cvar("avp_alien_nvision", "1");
	cvar_alien_nvision[1] = register_cvar("avp_alien_nvision_radius", "30");
	cvar_alien_nvision[2] = register_cvar("avp_alien_nvision_R", "0");
	cvar_alien_nvision[3] = register_cvar("avp_alien_nvision_G", "255");
	cvar_alien_nvision[4] = register_cvar("avp_alien_nvision_B", "0");

	cvar_predator_damage = register_cvar("avp_predator_wrist_blades_damage", "100");
	cvar_predator_killreward = register_cvar("avp_predator_killreward", "10");
	cvar_predator_dmgreward = register_cvar("avp_predator_damage_reward", "300");
	cvar_leappredator = register_cvar("avp_predator_leap", "1");
	cvar_leappredatorcooldown = register_cvar("avp_predator_leap_cooldown", "6.0");
	cvar_leappredatorforce = register_cvar("avp_predator_leap_force", "400");
	cvar_leappredatorheight = register_cvar("avp_predator_leap_height", "300");
	cvar_predator_nvision[0] = register_cvar("avp_predator_nvision", "1");
	cvar_predator_nvision[1] = register_cvar("avp_predator_nvision_radius", "70");
	cvar_predator_nvision[2] = register_cvar("avp_predator_nvision_R", "255");
	cvar_predator_nvision[3] = register_cvar("avp_predator_nvision_G", "0");
	cvar_predator_nvision[4] = register_cvar("avp_predator_nvision_B", "0");

	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn");
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	RegisterHam(Ham_AddPlayerItem, "player", "fw_AddPlayerItem");
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled");
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "fw_Knife_Deploy_Post", 1);
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "fw_ResetMaxSpeed_Post", 1);
	RegisterHam(Ham_BloodColor, "player", "fw_BloodColor");
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack");
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon");
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon");
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon");
	RegisterHam(Ham_Player_PreThink, "player", "fw_Player_PreThink");
	RegisterHamBots(Ham_Spawn, "fw_PlayerSpawn");
	RegisterHamBots(Ham_Spawn, "fw_PlayerSpawn_Post", 1);
	RegisterHamBots(Ham_AddPlayerItem, "fw_AddPlayerItem");
	RegisterHamBots(Ham_Killed, "fw_PlayerKilled");
	RegisterHamBots(Ham_Killed, "fw_PlayerKilled_Post", 1);
	RegisterHamBots(Ham_Player_ResetMaxSpeed, "fw_ResetMaxSpeed_Post", 1);
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage");
	RegisterHamBots(Ham_BloodColor, "fw_BloodColor")
	RegisterHamBots(Ham_TraceAttack, "fw_TraceAttack");
	RegisterHamBots(Ham_Player_PreThink, "fw_Player_PreThink");

	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
	register_event("AmmoX", "event_ammo_x", "be");
	register_logevent("logevent_round_start", 2, "1=Round_Start");
	register_logevent("logevent_round_end", 2, "1=Round_End");

	g_msgCurWeapon = get_user_msgid("CurWeapon");
	g_msgAmmoPickup = get_user_msgid("AmmoPickup");
	g_msgWeapPickup = get_user_msgid("WeapPickup");
	g_msgScenario = get_user_msgid("Scenario");
	g_msgStatusIcon = get_user_msgid("StatusIcon");
	g_msgHostagePos = get_user_msgid("HostagePos");
	g_msgSendAudio = get_user_msgid("SendAudio");
	g_msgHideWeapon = get_user_msgid("HideWeapon");
	g_msgTextMsg = get_user_msgid("TextMsg");
	g_msgScreenFade = get_user_msgid("ScreenFade");
	g_msgFog = get_user_msgid("Fog");

	g_fwRoundStarted = CreateMultiForward("avp_round_started", ET_IGNORE, FP_CELL, FP_CELL);
	g_fwRoundEnded = CreateMultiForward("avp_round_ended", ET_IGNORE, FP_CELL);
	g_fwUserAlien_attempt = CreateMultiForward("avp_user_alienize_attempt", ET_IGNORE, FP_CELL);
	g_fwUserMarine_attempt = CreateMultiForward("avp_user_marineze_attempt", ET_IGNORE, FP_CELL);
	g_fwUserPredator_attempt = CreateMultiForward("avp_user_predatorize_attempt", ET_IGNORE, FP_CELL);
	g_fwUserMarined_pre = CreateMultiForward("avp_user_marined_pre", ET_IGNORE, FP_CELL);
	g_fwUserAlienized_pre = CreateMultiForward("avp_user_alienized_pre", ET_IGNORE, FP_CELL);
	g_fwUserPredatorized_pre = CreateMultiForward("avp_user_predatorized_pre", ET_IGNORE, FP_CELL);
	g_fwUserMarined_post = CreateMultiForward("avp_user_marined_post", ET_IGNORE, FP_CELL);
	g_fwUserAlienized_post = CreateMultiForward("avp_user_alienized_post", ET_IGNORE, FP_CELL);
	g_fwUserPredatorized_post = CreateMultiForward("avp_user_predatorized_post", ET_IGNORE, FP_CELL);

	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1);
	register_forward(FM_EmitSound, "fw_EmitSound");
	register_forward(FM_CmdStart, "fw_CmdStart");

	register_message(g_msgTextMsg, "message_textmsg")
	register_message(g_msgWeapPickup, "message_weappickup");
	register_message(g_msgAmmoPickup, "message_ammopickup");
	register_message(g_msgScenario, "message_scenario");
	register_message(g_msgStatusIcon, "message_statusicon");
	register_message(g_msgHostagePos, "message_hostagepos");
	register_message(g_msgSendAudio, "message_sendaudio");
	register_message(g_msgCurWeapon, "message_cur_weapon");

	g_SyncMsg[0] = CreateHudSyncObj(10);
	g_SyncMsg[1] = CreateHudSyncObj(100);
	g_SyncMsg[2] = CreateHudSyncObj(1000);

	if (g_skybox_enable) set_cvar_string("sv_skyname", g_skybox_texture);

	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)

	g_maxplayers = get_maxplayers()
}

public plugin_cfg()
{
	new cfgdir[32];
	get_configsdir(cfgdir, charsmax(cfgdir));
	server_cmd("exec %s/aliens_vs_predator.cfg", cfgdir);

	set_task(5.0, "lighting_effects", _, _, _, "b");
}

public client_putinserver(id)
{
	reset_vars(id);

	g_marinepoints[id] = get_pcvar_num(cvar_starting_marinepoints);
	g_xenopoints[id] = get_pcvar_num(cvar_starting_xenopoints);
	g_honorpoints[id] = get_pcvar_num(cvar_starting_honorpoints);
	g_marine_class[id][0] = 0;
	g_predator_class[id][0] = 0;
	g_alien_class[id][0] = 0;
	g_damagedealt_marine[id] = 0;
	g_damagedealt_alien[id] = 0;
	g_damagedealt_predator[id] = 0;
}

public client_disconnect(id)
{
	if (g_isalive[id])
		check_round(id);

	g_isalive[id] = false;

	reset_vars(id);
}

//- Events

public event_new_round()
{
	g_decimation_round = false;
	g_extinction_round = false;
	g_newround = true;
	g_endround = false;

	remove_task(TASK_NEWROUND);
	set_task(2.0 + get_pcvar_float(cvar_start_delay), "task_new_round", TASK_NEWROUND);

	set_task(2.0, "task_welcome_message");
}

public logevent_round_start()
{
	static entity;

	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", "hostage_entity")) != 0)
	{
		if (!is_valid_ent(entity))
			continue;

		entity_set_origin(entity, Float:{5000.0,5000.0,5000.0});
	}
}

public logevent_round_end()
{
	g_endround = true;

	new sound[64];

	if (!fn_GetAliens() && fn_GetMarines() > fn_GetPredators())
	{
		set_hudmessage(0, 0, 255, -1.0, 0.25, 1, 6.0, 6.0, 1.0, 1.0, -1);
		ShowSyncHudMsg(0, g_SyncMsg[2], "%L", LANG_PLAYER, "WIN_MARINES");

		ArrayGetString(sound_win_marines, random_num(0, ArraySize(sound_win_marines) - 1), sound, charsmax(sound));
	
		ExecuteForward(g_fwRoundEnded, g_fwReturnValue, WIN_MARINES);
	}
	else if (!fn_GetAliens() && fn_GetPredators() > fn_GetMarines())
	{
		set_hudmessage(255, 0, 0, -1.0, 0.25, 1, 6.0, 6.0, 1.0, 1.0, -1);
		ShowSyncHudMsg(0, g_SyncMsg[2], "%L", LANG_PLAYER, "WIN_PREDATORS");

		ArrayGetString(sound_win_predators, random_num(0, ArraySize(sound_win_predators) - 1), sound, charsmax(sound));
	
		ExecuteForward(g_fwRoundEnded, g_fwReturnValue, WIN_PREDATORS);
	}
	else if (!fn_GetMarines() || !fn_GetPredators())
	{
		set_hudmessage(0, 255, 0, -1.0, 0.25, 1, 6.0, 6.0, 1.0, 1.0, -1);
		ShowSyncHudMsg(0, g_SyncMsg[2], "%L", LANG_PLAYER, "WIN_ALIENS");

		ArrayGetString(sound_win_aliens, random_num(0, ArraySize(sound_win_aliens) - 1), sound, charsmax(sound));
	
		ExecuteForward(g_fwRoundEnded, g_fwReturnValue, WIN_ALIENS);
	}
	else
	{
		set_hudmessage(150, 150, 0, -1.0, 0.25, 1, 6.0, 2.0, 1.0, 1.0, -1);
		ShowSyncHudMsg(0, g_SyncMsg[2], "%L", LANG_PLAYER, "WIN_NOONE");

		ArrayGetString(sound_win_noone, random_num(0, ArraySize(sound_win_noone) - 1), sound, charsmax(sound));
	
		ExecuteForward(g_fwRoundEnded, g_fwReturnValue, WIN_NO_ONE);
	}

	remove_task(TASK_AMBIENCESOUNDS);

	PlaySound(0, sound);

	balance_teams();
}

public event_ammo_x(id)
{
	if (g_alien[id])
		return;
	
	static type;
	type = read_data(1);
	
	if (type >= sizeof AMMOWEAPON)
		return;
	
	static weapon;
	weapon = AMMOWEAPON[type];
	
	if (MAXBPAMMO[weapon] <= 2)
		return;
	
	static amount;
	amount = read_data(2);
	
	if (get_pcvar_num(cvar_marine_unlimited))
	{
		if (amount < MAXBPAMMO[weapon])
		{
			static args[1];
			args[0] = weapon;
			set_task(0.1, "refill_bpammo", id, args, sizeof args);
		}
	}
}

//- Task Functions

public task_respawn_user(taskid)
{
	if (g_endround || is_user_alive(ID_RESPAWN))
	{
		remove_task(taskid);
		return;
	}

	ExecuteHam(Ham_CS_RoundRespawn, ID_RESPAWN);
	remove_task(taskid);
}

public task_show_hud(taskid)
{
	static id; id = ID_SHOWHUD;

	if (is_user_bot(id) || g_endround)
	{
		remove_task(taskid);
		return;
	}

	if (!is_user_alive(id))
	{
		id = entity_get_int(id, EV_INT_iuser2);

		if (!is_user_alive(id)) return;
	}

	static red, green, blue, szHud[100];

	if (g_alien[id])
	{
		static eAlienData[AlienData];
		ArrayGetArray(g_array_aln_class, g_alien_class[id][1], eAlienData);

		red = 0;
		green = 255;
		blue = 0;

		format(szHud, charsmax(szHud), "[ %L: %d | %L: %i | %L: %s ]", ID_SHOWHUD, "HEALTH", get_user_health(id), ID_SHOWHUD, "XENOPOINTS", g_xenopoints[id], ID_SHOWHUD, "CLASS", eAlienData[AlienName]); 
	}
	else if (g_predator[id])
	{
		static ePredatorData[PredatorData];
		ArrayGetArray(g_array_prd_class, g_predator_class[id][1], ePredatorData);

		red = 255;
		green = 0;
		blue = 0;
		format(szHud, charsmax(szHud), "[ %L: %d | %L: %i | %L: %s ]", ID_SHOWHUD, "HEALTH", get_user_health(id), ID_SHOWHUD, "HONORPOINTS", g_honorpoints[id], ID_SHOWHUD, "CLASS", ePredatorData[PredatorName])
	}
	else
	{
		static eMarineData[MarineData];
		ArrayGetArray(g_array_mrn_class, g_marine_class[id][1], eMarineData);

		red = 0;
		green = 40;
		blue = 255;
		format(szHud, charsmax(szHud), "[ %L: %d | %L: %i | %L: %s ]", ID_SHOWHUD, "HEALTH", get_user_health(id), ID_SHOWHUD, "MARINEPOINTS", g_marinepoints[id], ID_SHOWHUD, "CLASS", eMarineData[MarineName])
	}

	if (id != ID_SHOWHUD)
	{
		set_hudmessage(red, green, blue, -1.0, 0.8, 0, 6.0, 1.1, 0.0, 0.0, -1);
		ShowSyncHudMsg(ID_SHOWHUD, g_SyncMsg[0], "[ %L: %s ]^n%s", ID_SHOWHUD, "SPECTATING", get_player_name(id), szHud);
	}
	else
	{
		set_hudmessage(red, green, blue, 0.02, 0.87, 0, 6.0, 1.1, 0.0, 0.0, -1);
		ShowSyncHudMsg(ID_SHOWHUD, g_SyncMsg[0], szHud);
	}

	set_hudmessage(red, green, blue, -1.0, 0.05, 0, 6.0, 1.1, 0.0, 0.0, -1);
	ShowSyncHudMsg(ID_SHOWHUD, g_SyncMsg[1], "[ Җ - Aliens vs Predators - Җ ]^nBy: ϽЯΔΖϒ");
}

public task_welcome_message()
{
	avp_colored_print(0, "!gҖ !y|> !gAliens vs Predator %s !y<| !gҖ", PLUGIN_VERSION);
	avp_colored_print(0, "!g[AvP] !y%L", LANG_PLAYER, "WELCOME_MSG");

	if (task_exists(TASK_NEWROUND))
	{
		set_hudmessage(150, 150, 0, -1.0, 0.25, 2, 0.1, 2.0, 0.1, 0.1, -1);
		ShowSyncHudMsg(0, g_SyncMsg[2], ">>> Aliens vs Predator <<<");
	}
}

public task_new_round()
{
	start_mode(MODE_NONE, 0);
}

public task_set_user_nvision(taskid)
{
	static id;
	id = ID_NVISION;

	if (!is_user_alive(ID_NVISION))
	{
		id = entity_get_int(id, EV_INT_iuser2);
		if (!is_user_alive(id)) return;

	}

	static origin[3];
	get_user_origin(id, origin);

	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NVISION)
	write_byte(TE_DLIGHT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	
	if (g_alien[id])
	{
		write_byte(get_pcvar_num(cvar_alien_nvision[1]))
		write_byte(get_pcvar_num(cvar_alien_nvision[2]))
		write_byte(get_pcvar_num(cvar_alien_nvision[3]))
		write_byte(get_pcvar_num(cvar_alien_nvision[4]))
	}
	else if (g_predator[id])
	{
		if(g_thermal_nvision[id])
		{
			write_byte(get_pcvar_num(cvar_predator_nvision[1]))
			write_byte(0)
			write_byte(0)
			write_byte(255)
		}
		else
		{
			write_byte(get_pcvar_num(cvar_predator_nvision[1]))
			write_byte(get_pcvar_num(cvar_predator_nvision[2]))
			write_byte(get_pcvar_num(cvar_predator_nvision[3]))
			write_byte(get_pcvar_num(cvar_predator_nvision[4]))
		}
	}
	else
	{
		write_byte(get_pcvar_num(cvar_marine_nvision[1]))
		write_byte(get_pcvar_num(cvar_marine_nvision[2]))
		write_byte(get_pcvar_num(cvar_marine_nvision[3]))
		write_byte(get_pcvar_num(cvar_marine_nvision[4]))
	}

	write_byte(2)
	write_byte(0)
	message_end()
}

public task_thermal_sound(taskid)
{
	static id;
	id = ID_THERMAL;

	if (!is_user_alive(id))
	{
		remove_task(taskid);
		return;
	}

	emit_sound(id, CHAN_STATIC, PRD_VISION_SOUNDS[3], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
	emit_sound(id, CHAN_STATIC, PRD_VISION_SOUNDS[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public task_screen_fade(taskid)
{
	static id; id = ID_SCREENFADE;

	if (!is_user_alive(id))
	{
		id = entity_get_int(id, EV_INT_iuser2);
		if (!is_user_alive(id)) return;
	}

	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, ID_SCREENFADE)
	write_short(0)
	write_short(0)	
	write_short(0x0004)	

	if (g_alien[id])
	{
		write_byte(0)
		write_byte(50)
		write_byte(0)
	}
	else if (g_predator[id])
	{
		if (g_thermal_nvision[id])
		{
			write_byte(0)
			write_byte(0)
			write_byte(180)
		}
		else
		{
			write_byte(180)
			write_byte(0)
			write_byte(0)
		}
	}
	else
	{
		write_byte(0)
		write_byte(0)
		write_byte(0)
	}

	write_byte(70)
	message_end()
}

//- Ham Forwards

public fw_PlayerSpawn(id)
{
	g_spawntime[id] = get_systime();
}

public fw_PlayerSpawn_Post(id)
{
	if (!is_user_alive(id) || !cs_get_user_team(id))
		return;

	g_isalive[id] = true;

	message_begin(MSG_ONE_UNRELIABLE, g_msgHideWeapon, _, id)
	write_byte(1<<3)
	message_end()

	drop_user_weapons(id, 1);
	drop_user_weapons(id, 2);

	reset_vars(id);
	set_view(id, CAMERA_NONE);

	remove_task(id+TASK_SHOWHUD);
	set_task(1.0, "task_show_hud", id+TASK_SHOWHUD, _, _, "b");

	if (g_decimation_round)
	{
		if (cs_get_user_team(id) == CS_TEAM_T)
			alienme(id);
		else
			marineme(id);

		return;
	}
	else if (g_extinction_round)
	{
		if (cs_get_user_team(id) == CS_TEAM_T)
			alienme(id);
		else
			predatorme(id);

		return;
	}

	g_marine[id] = true;

	if (is_user_bot(id)) g_marine_class[id][0] = random_num(0, g_mclass_i - 1);

	g_marine_class[id][1] = g_marine_class[id][0];

	new class_data[MarineData];
	ArrayGetArray(g_array_mrn_class, g_marine_class[id][0], class_data)

	set_user_health(id, class_data[MarineHealth]);
	set_user_gravity(id, class_data[MarineGravity]);
	cs_set_player_model(id, class_data[MarineModel]);

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	if (is_user_bot(id))
	{
		static random;
		random = random_num(0, g_weapon_i[0] - 1);
		force_bot_buy_weapon(id, random);
	}

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
}

public fw_AddPlayerItem(id, entity)
{
	if (((get_systime() - g_spawntime[id]) > 1) || !(BLOCKED_SPAWN_WEAPONS & (1<<cs_get_weapon_id(entity))))
		return HAM_IGNORED;

	entity_set_int(entity, EV_INT_flags, FL_KILLME);
	SetHamReturnInteger(false);

	return HAM_SUPERCEDE;
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if (victim == attacker)
		return;

	if (g_alien[attacker])
	{
		if (get_pcvar_num(cvar_alien_killreward) > 0)
			g_xenopoints[attacker] += get_pcvar_num(cvar_alien_killreward);
	}
	else if (g_predator[attacker])
	{
		if (get_pcvar_num(cvar_predator_killreward) > 0)
			g_honorpoints[attacker] += get_pcvar_num(cvar_predator_killreward);
	}
	else if (g_marine[attacker])
	{
		if (get_pcvar_num(cvar_marine_killreward) > 0)
			g_marinepoints[attacker] += get_pcvar_num(cvar_marine_killreward);
	}
}

public fw_PlayerKilled_Post(victim)
{
	g_isalive[victim] = false;

	if (g_predator[victim] && g_thermal_nvision[victim])
		play_ambience_sound(victim);

	set_view(victim, CAMERA_NONE);

	g_nvision[victim] = false;
	g_nvisionenabled[victim] = false;
	g_thermal_nvision[victim] = false;

	remove_task(victim+TASK_SCREENFADE);
	remove_task(victim+TASK_NVISION);
	remove_task(victim+TASK_THERMAL);

	if (!is_user_bot(victim))
	{
		set_task(1.0, "task_screen_fade", victim+TASK_SCREENFADE, _, _, "b");

		if (get_pcvar_num(cvar_spectator_nvision))
		{
			g_nvision[victim] = true;

			if (get_pcvar_num(cvar_spectator_nvision) == 1)
			{
				set_task(0.1, "task_set_user_nvision", victim+TASK_NVISION, _, _, "b");
				g_nvisionenabled[victim] = true;
			}
		}
	}

	if (g_decimation_round)
	{
		switch (get_pcvar_num(cvar_decimation_respawn))
		{
			case 0: return;
			case 1: if (cs_get_user_team(victim) != CS_TEAM_T) return;
			case 2: if (cs_get_user_team(victim) != CS_TEAM_CT) return;
		}

		set_task(get_pcvar_float(cvar_decimation_redelay), "task_respawn_user", victim+TASK_RESPAWN);
	}
	else if (g_extinction_round)
	{
		switch (get_pcvar_num(cvar_extinction_respawn))
		{
			case 0: return;
			case 1: if (cs_get_user_team(victim) != CS_TEAM_T) return;
			case 2: if (cs_get_user_team(victim) != CS_TEAM_CT) return;
		}

		set_task(get_pcvar_float(cvar_extinction_redelay), "task_respawn_user", victim+TASK_RESPAWN);
	}
}

public fw_ResetMaxSpeed_Post(id)
{
	if (!is_user_alive(id))
		return;

	if (g_alien[id])
	{
		new eAlienData[AlienData];
		ArrayGetArray(g_array_aln_class, g_alien_class[id][0], eAlienData);

		set_user_maxspeed(id, eAlienData[AlienSpeed]);
	}
	else if (g_predator[id])
	{
		new ePredatorData[PredatorData];
		ArrayGetArray(g_array_prd_class, g_predator_class[id][0], ePredatorData);

		set_user_maxspeed(id, ePredatorData[PredatorSpeed]);
	}
	else
	{
		new eMarineData[MarineData];
		ArrayGetArray(g_array_mrn_class, g_marine_class[id][0], eMarineData);

		set_user_maxspeed(id, eMarineData[MarineSpeed]);
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, dmg_bits)
{
	if (!is_user_alive(attacker))
		return HAM_IGNORED;

	if (cs_get_user_team(victim) == cs_get_user_team(attacker))
		return HAM_IGNORED;

	if (g_newround || g_endround)
		return HAM_SUPERCEDE;

	if (g_alien[attacker])
	{
		new eAlienData[AlienData];
		ArrayGetArray(g_array_aln_class, g_alien_class[attacker][1], eAlienData);

		SetHamParamFloat(4, float(eAlienData[AlienDamage]));

		if (get_pcvar_num(cvar_alien_dmgreward) > 0)
		{
			g_damagedealt_alien[attacker] += eAlienData[AlienDamage];

			while (g_damagedealt_alien[attacker] > get_pcvar_num(cvar_alien_dmgreward))
			{
				g_xenopoints[attacker]++;
				g_damagedealt_alien[attacker] -= get_pcvar_num(cvar_alien_dmgreward);
			}
		}

		return HAM_IGNORED;
	}
	else if (g_predator[attacker])
	{
		if (get_user_weapon(attacker) == CSW_KNIFE)
			SetHamParamFloat(4, get_pcvar_float(cvar_predator_damage));

		if (get_pcvar_num(cvar_predator_dmgreward) > 0)
		{
			g_damagedealt_predator[attacker] += floatround(damage);

			while (g_damagedealt_predator[attacker] > get_pcvar_num(cvar_predator_dmgreward))
			{
				g_honorpoints[attacker]++;
				g_damagedealt_predator[attacker] -= get_pcvar_num(cvar_predator_dmgreward);
			}
		}

		return HAM_IGNORED;
	}
	else if (g_marine[attacker])
	{
		if (get_pcvar_num(cvar_marine_dmgreward) > 0)
		{
			g_damagedealt_marine[attacker] += floatround(damage);

			while (g_damagedealt_marine[attacker] > get_pcvar_num(cvar_marine_dmgreward))
			{
				g_marinepoints[attacker]++;
				g_damagedealt_marine[attacker] -= get_pcvar_num(cvar_marine_dmgreward);
			}
		}

		return HAM_IGNORED;
	}

	return HAM_IGNORED;
}

public fw_Knife_Deploy_Post(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	new id = get_pdata_cbase(entity, 41, 4);

	if (!is_user_alive(id))
		return HAM_IGNORED;

	if (g_alien[id])
	{
		new class_data[AlienData];
		ArrayGetArray(g_array_aln_class, g_alien_class[id][1], class_data);

		entity_set_string(id, EV_SZ_viewmodel, class_data[AlienClaw]);
		entity_set_string(id, EV_SZ_weaponmodel, "");
	}
	else if (g_predator[id])
	{
		entity_set_string(id, EV_SZ_viewmodel, model_vknife_predator);
		entity_set_string(id, EV_SZ_weaponmodel, "");
	}
	else
		entity_set_string(id, EV_SZ_viewmodel, model_vknife_marine);

	return HAM_IGNORED;
}

public fw_BloodColor(id)
{
	SetHamReturnInteger(-1);
	return HAM_SUPERCEDE;
}

public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
	if (victim == attacker || !is_user_alive(attacker))
		return HAM_IGNORED;

	if (g_newround || g_endround)
		return HAM_SUPERCEDE;

	if (cs_get_user_team(attacker) == cs_get_user_team(victim))
		return HAM_SUPERCEDE;

	new origin[3], hitpoint, weapon;
	get_user_origin(victim, origin);
	get_user_attacker(attacker, weapon, hitpoint);

	switch (hitpoint)
	{
		case 1: get_user_origin(victim, origin, 1)
		case 2: origin[2] += 25
		case 3: origin[2] += 10
		case 4:
		{
			origin[2] += 10
			origin[0] += 5
			origin[1] += 5
		}
		case 5:
		{
			origin[2]+=10
			origin[0] -= 5
			origin[1] -= 5
		}
		case 6:
		{
			origin[2] -= 10
			origin[0] += 5
			origin[1] += 5
		}
		case 7:
		{
			origin[2] -= 10
			origin[0] -= 5
			origin[1] -= 5
		}
	}

	static color;

	if (g_alien[victim] || g_predator[victim])
		color = 83;
	else
		color = 248;

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(g_blood_spr)
	write_short(g_blood_spr)
	write_byte(color)
	write_byte(10)
	message_end()

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(g_blood_spr)
	write_short(g_blood_spr)
	write_byte(color)
	write_byte(12)
	message_end()

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(g_blood_spr)
	write_short(g_blood_spr)
	write_byte(color)
	write_byte(15)
	message_end()

	return HAM_IGNORED;
}

public fw_TouchWeapon(entity, id)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED;

	if (!is_user_alive(id))
		return HAM_IGNORED;

	static impulse;
	impulse = entity_get_int(entity, EV_INT_impulse);

	if (g_alien[id] || (g_marine[id] && impulse > 500000) || (g_predator[id] && impulse <= 500000))
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

public fw_Player_PreThink(id)
{
	if (!is_user_alive(id) || g_marine[id])
		return HAM_IGNORED;

	static Float:cooldown, Float:current_time;

	if (g_alien[id])
	{
		if (!g_cached_leapalien) return HAM_IGNORED;
		cooldown = g_cached_leapaliencooldown;
	}
	else if (g_predator[id])
	{
		if (!g_cached_leappredator) return HAM_IGNORED;
		cooldown = g_cached_leappredacooldown;
	}

	current_time = get_gametime();

	if (current_time - g_lastleaptime[id] < cooldown)
		return HAM_IGNORED;

	static button, flags;
	button = entity_get_int(id, EV_INT_button);
	flags = entity_get_int(id, EV_INT_flags);

	if (!is_user_bot(id) && !(button & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
		return HAM_IGNORED;

	if (get_user_speed(id) < 80 || !(flags & FL_ONGROUND))
		return HAM_IGNORED;

	static Float:velocity[3];

	velocity_by_aim(id, g_predator[id] ? get_pcvar_num(cvar_leappredatorforce) : get_pcvar_num(cvar_leapalienforce), velocity)
	
	velocity[2] = g_predator[id] ? get_pcvar_float(cvar_leappredatorheight) : get_pcvar_float(cvar_leapalienheight)
	
	entity_set_vector(id, EV_VEC_velocity, velocity);

	if (g_alien[id])
		play_array_sound(id, CHAN_VOICE, alien_longjump);
	
	g_lastleaptime[id] = current_time;

	return HAM_HANDLED;
}

//- Forwards

public fw_AddToFullPack_Post(es_handle, e, ent, host, flags, player, pSet)
{
	if (!player) return FMRES_IGNORED;

	if (g_thermal_nvision[player])
	{
		static color[3];
		color[0] = 150;
		color[1] = 255;
		color[2] = 0;

		set_es(es_handle, ES_RenderMode, kRenderNormal);
		set_es(es_handle, ES_RenderFx, kRenderFxGlowShell);
		set_es(es_handle, ES_RenderAmt, 25);
		set_es(es_handle, ES_RenderColor, color);

		return FMRES_HANDLED;
	}
	else
	{
		if (host != ent) return FMRES_IGNORED;

		set_es(es_handle, ES_RenderMode, g_iRenderMode[host]);
		set_es(es_handle, ES_RenderFx, g_iRenderFx[host]);
		set_es(es_handle, ES_RenderAmt, g_fRenderAmount[host]);
		set_es(es_handle, ES_RenderColor, g_fRenderColor[host]);
	}

	return FMRES_IGNORED;
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;

	if (!is_user_connected(id) || g_marine[id])
		return FMRES_IGNORED;

	static sound[64];

	//- Player being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if (g_alien[id])
		{
			ArrayGetString(alien_pain, random_num(0, ArraySize(alien_pain) - 1), sound, charsmax(sound));
			emit_sound(id, channel, sound, volume, attn, flags, pitch);
		}
		else
		{
			ArrayGetString(predator_pain, random_num(0, ArraySize(predator_pain) - 1), sound, charsmax(sound));
			emit_sound(id, channel, sound, volume, attn, flags, pitch);
		}

		return FMRES_SUPERCEDE;
	}

	//- Player die
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		if (g_alien[id])
		{
			ArrayGetString(alien_die, random_num(0, ArraySize(alien_die) - 1), sound, charsmax(sound));
			emit_sound(id, channel, sound, volume, attn, flags, pitch);
		}
		else
		{
			ArrayGetString(predator_die, random_num(0, ArraySize(predator_die) - 1), sound, charsmax(sound));
			emit_sound(id, channel, sound, volume, attn, flags, pitch);
		}

		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public fw_CmdStart(id, uc_handle, seed)
{
	if (get_uc(uc_handle, UC_Impulse) != 100)
		return FMRES_IGNORED;

	set_uc(uc_handle, UC_Impulse, 0);
	return FMRES_HANDLED;
}

//- Public functions

public menu_game(id)
{
	new szBuffer[100];

	formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_GAME_TITLE");
	new menu = menu_create(szBuffer, "menu_game_handler");

	if (!is_user_alive(id) || !g_weapon_i[0] || g_already_buyed[id] || !g_marine[id])
		formatex(szBuffer, charsmax(szBuffer), "\d%L", id, "MENU_WEAPON");
	else
		formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_WEAPON");

	menu_additem(menu, szBuffer, "1");

	if (!is_user_alive(id) || (g_marine[id] && !g_items_i[1]) || (g_alien[id] && !g_items_i[2]) || (g_predator[id] && !g_items_i[3]))
		formatex(szBuffer, charsmax(szBuffer), "\d%L", id, "MENU_EXTRA_ITEMS");
	else
		formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_EXTRA_ITEMS");

	menu_additem(menu, szBuffer, "2");

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_CLASS");
	menu_additem(menu, szBuffer, "3");

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_ADMIN");
	menu_additem(menu, szBuffer, "4");

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, szBuffer);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
}

public menu_game_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	switch (item)
	{
		case 0:
		{
			if (!is_user_alive(id) || g_already_buyed[id] || !g_marine[id])
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_CANNOT_BUY");
				menu_game(id);
			}
			else if (!g_weapon_i[0])
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NOLOADED_WEAPONS");
				menu_game(id);
			}
			else if (g_weapon_i[1] > 0)
			{
				PL_ACTION = ACTION_BUY_WPRIMARY;
				menu_weapons(id, 0, 1);
			}
			else if (!g_weapon_i[1] && g_weapon_i[2] > 0)
			{
				PL_ACTION = ACTION_BUY_WSECONDARY;
				menu_weapons(id, 0, 2);
			}
		}
		case 1:
		{
			if (!is_user_alive(id))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_CANNOT_BUY");
				menu_game(id);
			}
			else if (((g_marine[id] && !g_items_i[1]) || (g_alien[id] && !g_items_i[2]) || (g_predator[id] && !g_items_i[3])))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NOLOADED_ITEMS");
				menu_game(id);
			}
			else
				menu_extra_items(id, .page = 0);
		}
		case 2:
		{
			menu_class(id);
		}
		case 3:
		{
			if (!has_flag(id, g_access_flag[ACCESS_ADMIN_MENU]))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NO_ACCESS");
				menu_game(id);
			}
			else
				menu_admin(id, .page = 0);
		}
	}

	return PLUGIN_HANDLED;
}

public menu_extra_items(id, page)
{
	new szBuffer[100];

	formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_EXTRA_ITEMS_TITLE");
	new menu = menu_create(szBuffer, "menu_extra_items_handler");

	new szNum[3], szItem[32], eItemData[ItemData], g_points;

	if (g_marine[id]) g_points = g_marinepoints[id];
	else if (g_alien[id]) g_points = g_xenopoints[id];
	else g_points = g_honorpoints[id];

	for (new i = 0; i < g_items_i[0]; i++)
	{
		ArrayGetArray(g_array_extra_items, i, eItemData);

		if ((g_marine[id] && eItemData[ItemTeam] != AVP_TEAM_MARINE) || (g_predator[id] && eItemData[ItemTeam] != AVP_TEAM_PREDATOR) || (g_alien[id] && eItemData[ItemTeam] != AVP_TEAM_ALIEN))
			continue;

		if (eItemData[ItemCost] > g_points)
			formatex(szItem, charsmax(szItem), "\d%s [%i]", eItemData[ItemName], eItemData[ItemCost]);
		else
			formatex(szItem, charsmax(szItem), "%s \r[%i]", eItemData[ItemName], eItemData[ItemCost]);

		num_to_str(i, szNum, charsmax(szNum));

		menu_additem(menu, szItem, szNum);
	}

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_BACK");
	menu_setprop(menu, MPROP_BACKNAME, szBuffer);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, page);
}

public menu_extra_items_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new access, szNum[3], callback, g_points;
	menu_item_getinfo(menu, item, access, szNum, charsmax(szNum), _, _, callback);

	if (g_marine[id]) g_points = g_marinepoints[id];
	else if (g_predator[id]) g_points = g_honorpoints[id];
	else g_points = g_xenopoints[id];

	menu_destroy(menu);

	new itemid = str_to_num(szNum);
	new eItemData[ItemData];

	ArrayGetArray(g_array_extra_items, itemid, eItemData);

	if (g_points < eItemData[ItemCost])
	{
		avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NO_ENOUGH_MONEY");
		menu_extra_items(id, .page = item / 7);
	}
	else
	{
		if (g_marine[id]) g_marinepoints[id] = g_marinepoints[id] - eItemData[ItemCost];
		else if (g_alien[id]) g_xenopoints[id] = g_xenopoints[id] - eItemData[ItemCost];
		else g_honorpoints[id] = g_honorpoints[id] - eItemData[ItemCost];

		callfunc_begin_i(eItemData[ItemFuncID], eItemData[ItemPlugin]);
		callfunc_push_int(id);
		callfunc_end();
	}
	
	return PLUGIN_HANDLED;
}

public menu_admin(id, page)
{
	new szBuffer[100];

	formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_ADMIN_TITLE");
	new menu = menu_create(szBuffer, "menu_admin_handler");

	if (has_flag(id, g_access_flag[ACCESS_MAKE_MARINE]))
		formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_MAKE_MARINE");
	else
		formatex(szBuffer, charsmax(szBuffer), "\d%L", id, "MENU_MAKE_MARINE");

	menu_additem(menu, szBuffer, "1");

	if (has_flag(id, g_access_flag[ACCESS_MAKE_ALIEN]))
		formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_MAKE_ALIEN");
	else
		formatex(szBuffer, charsmax(szBuffer), "\d%L", id, "MENU_MAKE_ALIEN");

	menu_additem(menu, szBuffer, "2");

	if (has_flag(id, g_access_flag[ACCESS_MAKE_PREDATOR]))
		formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_MAKE_PREDATOR");
	else
		formatex(szBuffer, charsmax(szBuffer), "\d%L", id, "MENU_MAKE_PREDATOR");

	menu_additem(menu, szBuffer, "3");

	if (has_flag(id, g_access_flag[ACCESS_RESPAWN_USER]))
		formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_RESPAWN_USER");
	else
		formatex(szBuffer, charsmax(szBuffer), "\d%L", id, "MENU_RESPAWN_USER");

	menu_additem(menu, szBuffer, "4");

	if (has_flag(id, g_access_flag[ACCESS_START_DECIMATION]) && allowed_decimation())
		formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_START_DECIMATION");
	else
		formatex(szBuffer, charsmax(szBuffer), "\d%L", id, "MENU_START_DECIMATION");

	menu_additem(menu, szBuffer, "5");

	if (has_flag(id, g_access_flag[ACCESS_START_EXTINCTION]) && allowed_extinction())
		formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_START_EXTINCTION");
	else
		formatex(szBuffer, charsmax(szBuffer), "\d%L", id, "MENU_START_EXTINCTION");

	menu_additem(menu, szBuffer, "6");

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_BACK");
	menu_setprop(menu, MPROP_BACKNAME, szBuffer);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, page);
}	

public menu_admin_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	switch (item)
	{
		case 0:
		{
			if (!has_flag(id, g_access_flag[ACCESS_MAKE_MARINE]))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NO_ACCESS");
				menu_admin(id, 0);
			}
			else
			{
				PL_ACTION = ACTION_MAKE_MARINE;
				menu_players_list(id, .page = 0);
			}
		}
		case 1:
		{
			if (!has_flag(id, g_access_flag[ACCESS_MAKE_ALIEN]))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NO_ACCESS");
				menu_admin(id, 0);
			}
			else
			{
				PL_ACTION = ACTION_MAKE_ALIEN;
				menu_players_list(id, .page = 0);
			}
		}
		case 2:
		{
			if (!has_flag(id, g_access_flag[ACCESS_MAKE_PREDATOR]))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NO_ACCESS");
				menu_admin(id, 0);
			}
			else
			{
				PL_ACTION = ACTION_MAKE_PREDATOR;
				menu_players_list(id, .page = 0);
			}
		}
		case 3:
		{
			if (!has_flag(id, g_access_flag[ACCESS_RESPAWN_USER]))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NO_ACCESS");
				menu_admin(id, 0);
			}
			else
			{
				PL_ACTION = ACTION_RESPAWN_USER;
				menu_players_list(id, .page = 0);
			}
		}
		case 4:
		{
			if (!has_flag(id, g_access_flag[ACCESS_START_DECIMATION]))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NO_ACCESS");
				menu_admin(id, 0);
			}
			else if (!allowed_decimation())
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NOT");
				menu_admin(id, 0);
			}
			else
			{
				if (get_pcvar_num(cvar_logcommands))
				{
					static logdata[100], authid[32], ip[16]
					get_user_authid(id, authid, charsmax(authid))
					get_user_ip(id, ip, charsmax(ip), 1)
					formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", get_player_name(id), authid, ip, LANG_SERVER, "CMD_DECIMATION", get_playersnum(), g_maxplayers);
					log_to_file("aliens_vs_predator.log", logdata)
				}

				switch (get_pcvar_num(cvar_showactivity))
				{
					case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %L", LANG_PLAYER, "CMD_DECIMATION")
					case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %L", get_player_name(id), LANG_PLAYER, "CMD_DECIMATION")
				}

				remove_task(TASK_NEWROUND);
				start_mode(MODE_DECIMATION, 0);
			}
		}
		case 5:
		{
			if (!has_flag(id, g_access_flag[ACCESS_START_EXTINCTION]))
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NO_ACCESS");
				menu_admin(id, 0);
			}
			else if (!allowed_extinction())
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NOT");
				menu_admin(id, 0);
			}
			else
			{
				if (get_pcvar_num(cvar_logcommands))
				{
					static logdata[100], authid[32], ip[16]
					get_user_authid(id, authid, charsmax(authid))
					get_user_ip(id, ip, charsmax(ip), 1)
					formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", get_player_name(id), authid, ip, LANG_SERVER, "CMD_EXTINCTION", get_playersnum(), g_maxplayers);
					log_to_file("aliens_vs_predator.log", logdata)
				}

				switch (get_pcvar_num(cvar_showactivity))
				{
					case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %L", LANG_PLAYER, "CMD_EXTINCTION")
					case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %L", get_player_name(id), LANG_PLAYER, "CMD_EXTINCTION")
				}

				remove_task(TASK_NEWROUND);
				start_mode(MODE_EXTINCTION, 0);
			}
		}
	}

	return PLUGIN_HANDLED;
}

public menu_players_list(id, page)
{
	new szBuffer[100];

	switch (PL_ACTION)
	{
		case ACTION_MAKE_MARINE: formatex(szBuffer, charsmax(szBuffer), "\r< AvP | %L >", id, "MENU_MAKE_MARINE_TITLE");
		case ACTION_MAKE_ALIEN: formatex(szBuffer, charsmax(szBuffer), "\r< AvP | %L >", id, "MENU_MAKE_ALIEN_TITLE");
		case ACTION_MAKE_PREDATOR: formatex(szBuffer, charsmax(szBuffer), "\r< AvP | %L >", id, "MENU_MAKE_PREDATOR_TITLE");
		case ACTION_RESPAWN_USER: formatex(szBuffer, charsmax(szBuffer), "\r< AvP | %L >", id, "MENU_RESPAWN_USER_TITLE");
	}
	
	new menu = menu_create(szBuffer, "menu_players_list_handler");

	new players[32], pnum, player, szUserId[32], szName[64], szClass[32];
	get_players(players, pnum);

	for (--pnum; pnum >= 0; pnum--)
	{
		player = players[pnum];

		if (g_marine[player]) formatex(szClass, charsmax(szClass), "%L", id, "CLASS_MARINE");
		else if (g_predator[player]) formatex(szClass, charsmax(szClass), "%L", id, "CLASS_PREDATOR");
		else if (g_alien[player]) formatex(szClass, charsmax(szClass), "%L", id, "CLASS_ALIEN");
		else formatex(szClass, charsmax(szClass), "%L", id, "CLASS_UNDEFINED");

		if (!allowed_action(id, player))
			format(szName, charsmax(szName), "\d%s [%s]", get_player_name(player), szClass);
		else
			format(szName, charsmax(szName), "%s \r[%s]", get_player_name(player), szClass);

		formatex(szUserId, charsmax(szUserId), "%d", get_user_userid(player));
		menu_additem(menu, szName, szUserId);
	}

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_BACK");
	menu_setprop(menu, MPROP_BACKNAME, szBuffer);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, page);
	return PLUGIN_HANDLED;
}

public menu_players_list_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new szUserId[32], szPlayerName[32], player, access, callback;
	menu_item_getinfo(menu, item, access, szUserId, charsmax(szUserId), szPlayerName, charsmax(szPlayerName), callback);

	if ((player = find_player("k", str_to_num(szUserId))) && allowed_action(id, player))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)

		switch (PL_ACTION)
		{
			case ACTION_MAKE_MARINE:
			{
				formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", get_player_name(id), authid, ip, get_player_name(player), LANG_SERVER, "CMD_MARINE", get_playersnum(), g_maxplayers);

				switch (get_pcvar_num(cvar_showactivity))
				{
					case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %s %L", get_player_name(player), LANG_PLAYER, "CMD_MARINE")
					case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %s %L", get_player_name(id), get_player_name(player), LANG_PLAYER, "CMD_MARINE")
				}

				marineme(player);
			}
			case ACTION_MAKE_ALIEN:
			{
				formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", get_player_name(id), authid, ip, get_player_name(player), LANG_SERVER, "CMD_ALIEN", get_playersnum(), g_maxplayers);

				switch (get_pcvar_num(cvar_showactivity))
				{
					case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %s %L", get_player_name(player), LANG_PLAYER, "CMD_ALIEN")
					case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %s %L", get_player_name(id), get_player_name(player), LANG_PLAYER, "CMD_ALIEN")
				}

				alienme(player);
			}
			case ACTION_MAKE_PREDATOR:
			{
				formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", get_player_name(id), authid, ip, get_player_name(player), LANG_SERVER, "CMD_PREDATOR", get_playersnum(), g_maxplayers);

				switch (get_pcvar_num(cvar_showactivity))
				{
					case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %s %L", get_player_name(player), LANG_PLAYER, "CMD_PREDATOR")
					case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %s %L", get_player_name(id), get_player_name(player), LANG_PLAYER, "CMD_PREDATOR")
				}

				predatorme(player);
			}
			case ACTION_RESPAWN_USER:
			{
				formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", get_player_name(id), authid, ip, get_player_name(player), LANG_SERVER, "CMD_RESPAWN", get_playersnum(), g_maxplayers);

				switch (get_pcvar_num(cvar_showactivity))
				{
					case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %s %L", get_player_name(player), LANG_PLAYER, "CMD_RESPAWN")
					case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %s %L", get_player_name(id), get_player_name(player), LANG_PLAYER, "CMD_RESPAWN")
				}
				
				ExecuteHam(Ham_CS_RoundRespawn, player);
			}
		}

		if (get_pcvar_num(cvar_logcommands))
			log_to_file("aliens_vs_predator.log", logdata)
	}
	else
		avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_NOT");

	menu_players_list(id, .page = item / 7);
	return PLUGIN_HANDLED;
}

public menu_weapons(id, page, weapon)
{
	new szBuffer[100];

	switch (weapon)
	{
		case 1: formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_WPRIMARY_TITLE");
		case 2: formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_WSECONDARY_TITLE");
	}

	new menu = menu_create(szBuffer, "menu_weapons_handler");

	new szNum[3], szWeapon[32], eWeaponData[WeaponData];

	for (new i = 0; i < g_weapon_i[0]; i++)
	{
		ArrayGetArray(g_array_weapon, i, eWeaponData);

		if ((weapon == 1 && eWeaponData[WeaponType] == AVP_SECONDARY_WEAPON) || (weapon == 2 && eWeaponData[WeaponType] == AVP_PRIMARY_WEAPON))
			continue;

		formatex(szWeapon, charsmax(szWeapon), "%s", eWeaponData[WeaponName]);

		num_to_str(i, szNum, charsmax(szNum));

		menu_additem(menu, szWeapon, szNum);
	}
	
	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_BACK");
	menu_setprop(menu, MPROP_BACKNAME, szBuffer);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, page);
}

public menu_weapons_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new access, szNum[3], callback;
	menu_item_getinfo(menu, item, access, szNum, charsmax(szNum), _, _, callback);

	g_already_buyed[id] = true;

	if (PL_ACTION == ACTION_BUY_WPRIMARY && g_weapon_i[2])
	{
		PL_ACTION = ACTION_BUY_WSECONDARY;
		menu_weapons(id, 0, 2);
	}
	else menu_destroy(menu);

	new itemid = str_to_num(szNum);
	new eWeaponData[WeaponData];
	ArrayGetArray(g_array_weapon, itemid, eWeaponData);
	
	callfunc_begin_i(eWeaponData[WeaponFuncID], eWeaponData[WeaponPlugin]);
	callfunc_push_int(id);
	callfunc_end();

	return PLUGIN_HANDLED;
}

public menu_class(id)
{
	new szBuffer[100];

	formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_CLASS_TITLE");
	new menu = menu_create(szBuffer, "menu_class_handler");

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_CLASS_MARINE");
	menu_additem(menu, szBuffer, "1");

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_CLASS_ALIEN");
	menu_additem(menu, szBuffer, "2");

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_CLASS_PREDATOR");
	menu_additem(menu, szBuffer, "3");

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, szBuffer);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
}

public menu_class_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	switch (item)
	{
		case 0: PL_ACTION = ACTION_CLASS_MARINE;
		case 1: PL_ACTION = ACTION_CLASS_ALIEN;
		case 2: PL_ACTION = ACTION_CLASS_PREDATOR;
	}

	menu_class_list(id, .page = 0);

	return PLUGIN_HANDLED;
}

public menu_class_list(id, page)
{
	new szBuffer[100];

	switch (PL_ACTION)
	{
		case ACTION_CLASS_MARINE: formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_CLASS_MARINE_TITLE");
		case ACTION_CLASS_ALIEN: formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_CLASS_ALIEN_TITLE");
		case ACTION_CLASS_PREDATOR: formatex(szBuffer, charsmax(szBuffer), "\r< AvP - %L >", id, "MENU_CLASS_PREDATOR_TITLE");
	}

	new menu = menu_create(szBuffer, "menu_class_list_handler");

	switch (PL_ACTION)
	{
		case ACTION_CLASS_MARINE:
		{
			new class_data[MarineData], szNum[3], szClass[64];

			for (new i = 0; i < g_mclass_i; i++)
			{
				ArrayGetArray(g_array_mrn_class, i, class_data);

				if (g_marine_class[id][0] == i)
					formatex(szClass, charsmax(szClass), "\d%s [=%s=]", class_data[MarineName], class_data[MarineInfo]);
				else
					formatex(szClass, charsmax(szClass), "%s \r[=%s=]", class_data[MarineName], class_data[MarineInfo]);

				num_to_str(i, szNum, charsmax(szNum));

				menu_additem(menu, szClass, szNum);
			}
		}
		case ACTION_CLASS_ALIEN:
		{
			new class_data[AlienData], szNum[3], szClass[64];

			for (new i = 0; i < g_aclass_i; i++)
			{
				ArrayGetArray(g_array_aln_class, i, class_data);

				if (g_alien_class[id][0] == i)
					formatex(szClass, charsmax(szClass), "\d%s [=%s=]", class_data[AlienName], class_data[AlienInfo]);
				else
					formatex(szClass, charsmax(szClass), "%s \r[=%s=]", class_data[AlienName], class_data[AlienInfo]);

				num_to_str(i, szNum, charsmax(szNum));

				menu_additem(menu, szClass, szNum);
			}
		}
		case ACTION_CLASS_PREDATOR:
		{
			new class_data[AlienData], szNum[3], szClass[64];

			for (new i = 0; i < g_pclass_i; i++)
			{
				ArrayGetArray(g_array_prd_class, i, class_data);

				if (g_predator_class[id][0] == i)
					formatex(szClass, charsmax(szClass), "\d%s [=%s=]", class_data[PredatorName], class_data[PredatorInfo]);
				else
					formatex(szClass, charsmax(szClass), "%s \r[=%s=]", class_data[PredatorName], class_data[PredatorInfo]);

				num_to_str(i, szNum, charsmax(szNum));

				menu_additem(menu, szClass, szNum);
			}
		}
	}

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, szBuffer);

	formatex(szBuffer, charsmax(szBuffer), "%L", id, "MENU_BACK");
	menu_setprop(menu, MPROP_BACKNAME, szBuffer);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, page);
}

public menu_class_list_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new access, szNum[3], callback, classid;
	menu_item_getinfo(menu, item, access, szNum, charsmax(szNum), _, _, callback);
	classid = str_to_num(szNum);
	menu_destroy(menu);

	switch (PL_ACTION)
	{
		case ACTION_CLASS_MARINE:
		{
			if (g_marine_class[id][0] == classid)
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_ALREADY_INUSE");
				menu_class_list(id, .page = item / 7);
			}
			else
			{
				g_marine_class[id][0] = classid;

				new class_data[MarineData];
				ArrayGetArray(g_array_mrn_class, classid, class_data);
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_SELECT_CLASS");
				avp_colored_print(id, "!g[AvP] !y%s : !gHealth: !y%i | !gGravity: !y%f | !gSpeed: !y%f", class_data[MarineName], class_data[MarineHealth], class_data[MarineGravity], class_data[MarineSpeed]);
			}
		}
		case ACTION_CLASS_ALIEN:
		{
			if (g_alien_class[id][0] == classid)
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_ALREADY_INUSE");
				menu_class_list(id, .page = item / 7);
			}
			else
			{
				g_alien_class[id][0] = classid;

				new class_data[AlienData];
				ArrayGetArray(g_array_aln_class, classid, class_data);
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_SELECT_CLASS");
				avp_colored_print(id, "!g[AvP] !y%s : !gHealth: !y%i | !gDamage: !y%i | !gGravity: !y%f | !gSpeed: !y%f", class_data[AlienName], class_data[AlienHealth], class_data[AlienDamage], class_data[AlienGravity], class_data[AlienSpeed]);
			}
		}
		case ACTION_CLASS_PREDATOR:
		{
			if (g_predator_class[id][0] == classid)
			{
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_ALREADY_INUSE");
				menu_class_list(id, .page = item / 7);
			}
			else
			{
				g_predator_class[id][0] = classid;

				new class_data[PredatorData];
				ArrayGetArray(g_array_prd_class, classid, class_data);
				avp_colored_print(id, "!g[AvP] !y%L", id, "CMD_SELECT_CLASS");
				avp_colored_print(id, "!g[AvP] !y%s : !gHealth: !y%i | !gGravity: !y%f | !gSpeed: !y%f", class_data[PredatorName], class_data[PredatorHealth], class_data[PredatorGravity], class_data[PredatorSpeed]);
			}
		}
	}

	return PLUGIN_HANDLED;
}

public lighting_effects()
{
	cache_vars();

	if (g_ambience_fog)
	{
		static desity;
		desity = (4 * g_fog_density);

		message_begin(MSG_ALL, g_msgFog, {0,0,0}, 0)
		write_byte(g_fog_color[0]) //- Red
		write_byte(g_fog_color[1]) //- Green
		write_byte(g_fog_color[2]) //- Blue
		write_byte(OFFSET_FOG_DESITY[desity]) //- SD
		write_byte(OFFSET_FOG_DESITY[desity+1]) //- ED
		write_byte(OFFSET_FOG_DESITY[desity+2]) //- D1
		write_byte(OFFSET_FOG_DESITY[desity+3]) //- D2
		message_end()
	}

	static lighting[2];
	get_pcvar_string(cvar_lighting, lighting, charsmax(lighting));
	strtolower(lighting);

	if (lighting[0] == '0')
		return;

	set_lights(lighting);
}

public ambience_sound_effects(taskid)
{
	static sound[64], random, duration, players[32], pnum, id;

	if (g_decimation_round)
	{
		random = random_num(0, ArraySize(ambience_sounds_decimation) - 1);
		ArrayGetString(ambience_sounds_decimation, random, sound, charsmax(sound));
		duration = ArrayGetCell(ambience_duration_decimation, random);
	}
	else if (g_extinction_round)
	{
		random = random_num(0, ArraySize(ambience_sounds_extinction) - 1);
		ArrayGetString(ambience_sounds_extinction, random, sound, charsmax(sound));
		duration = ArrayGetCell(ambience_duration_extinction, random);
	}

	get_players(players, pnum, "c");

	for (--pnum; pnum >= 0; pnum--)
	{
		id = players[pnum];

		if (!g_thermal_nvision[id])
			PlaySound(id, sound);
	}

	set_task(float(duration), "ambience_sound_effects", TASK_AMBIENCESOUNDS);
}

//- Private functions

check_round(leaving_player)
{
	if (g_newround)
		return;

	static players[32], pnum, id;
	get_players(players, pnum, "a");

	if (pnum < 2)
		return;

	if (g_alien[leaving_player] && fn_GetAliens() == 1)
	{
		if ((fn_GetMarines() == 1 && !fn_GetPredators()) || (fn_GetPredators() == 1 && !fn_GetMarines()))
			return;

		while ((id = get_random_user("a")) == leaving_player) { }

		avp_colored_print(0, "!g[AvP] !y%L", LANG_PLAYER, "LAST_ALIEN_LEFT", get_player_name(id));

		g_lastplayerleaving = true;

		alienme(id);

		g_lastplayerleaving = false;
	}
	else if (g_predator[leaving_player] && fn_GetPredators() == 1 && !fn_GetMarines())
	{
		if (fn_GetAliens() == 1)
			return;

		while ((id = get_random_user("a")) == leaving_player) { }

		avp_colored_print(0, "!g[AvP] !y%L", LANG_PLAYER, "LAST_PREDATOR_LEFT", get_player_name(id));

		g_lastplayerleaving = true;

		predatorme(id);

		g_lastplayerleaving = false;
	}
	else if (g_marine[leaving_player] && fn_GetMarines() == 1 && !fn_GetPredators())
	{
		if (fn_GetAliens() == 1)
			return;

		while ((id = get_random_user("a")) == leaving_player) { }

		avp_colored_print(0, "!g[AvP] !y%L", LANG_PLAYER, "LAST_MARINE_LEFT", get_player_name(id));

		g_lastplayerleaving = true;

		marineme(id);

		g_lastplayerleaving = false;
	}
}

cache_vars()
{
	g_cached_leapalien = get_pcvar_num(cvar_leapalien)
	g_cached_leapaliencooldown = get_pcvar_float(cvar_leapaliencooldown)
	g_cached_leappredator = get_pcvar_num(cvar_leappredator)
	g_cached_leappredacooldown = get_pcvar_float(cvar_leappredatorcooldown)
}

start_mode(mode, id)
{
	new players[32], pnum;
	get_players(players, pnum, "a");

	if ((mode == MODE_NONE && random_num(1, get_pcvar_num(cvar_decimation_chance)) == get_pcvar_num(cvar_decimation_enable) && pnum >= get_pcvar_num(cvar_decimation_minplayers)) || mode == MODE_DECIMATION)
	{
		g_decimation_round = true;

		for (--pnum; pnum >= 0; pnum--)
		{
			id = players[pnum];

			if (cs_get_user_team(id) == CS_TEAM_T)
				alienme(id);
			else
				if (!g_marine[id]) marineme(id);
		}

		set_hudmessage(150, 150, 0, -1.0, 0.25, 1, 6.0, 2.0, 1.0, 1.0, -1);
		ShowSyncHudMsg(0, g_SyncMsg[2], "%L", LANG_PLAYER, "NOTICE_DECIMATION");

		static random, sound[64];
		random = random_num(0, ArraySize(sound_start_decimation) - 1);
		ArrayGetString(sound_start_decimation, random, sound, charsmax(sound));
		PlaySound(0, sound);

		ExecuteForward(g_fwRoundStarted, g_fwReturnValue, MODE_DECIMATION, 0);
	}
	else
	{
		g_extinction_round = true;

		for (--pnum; pnum >= 0; pnum--)
		{
			id = players[pnum];

			if (cs_get_user_team(id) == CS_TEAM_T)
				alienme(id);
			else
				predatorme(id);
		}

		set_hudmessage(150, 150, 0, -1.0, 0.25, 1, 6.0, 2.0, 1.0, 1.0, -1);
		ShowSyncHudMsg(0, g_SyncMsg[2], "%L", LANG_PLAYER, "NOTICE_EXTINCTION");

		static random, sound[64];
		random = random_num(0, ArraySize(sound_start_extinction) - 1);
		ArrayGetString(sound_start_extinction, random, sound, charsmax(sound));
		PlaySound(0, sound);

		ExecuteForward(g_fwRoundStarted, g_fwReturnValue, MODE_EXTINCTION, 0);
	}

	if ((g_ambience_sounds[AMBIENCE_SOUNDS_DECIMATION] && g_decimation_round) || (g_ambience_sounds[AMBIENCE_SOUNDS_EXTINCTION] && g_extinction_round))
	{
		remove_task(TASK_AMBIENCESOUNDS);
		set_task(2.0, "ambience_sound_effects", TASK_AMBIENCESOUNDS);
	}

	g_newround = false;
}

reset_vars(id)
{
	g_already_buyed[id] = false;
	g_marine[id] = false;
	g_predator[id] = false;
	g_alien[id] = false;
	g_nvision[id] = false;
	g_nvisionenabled[id] = false;
	g_thermal_nvision[id] = false;

	remove_task(id+TASK_SCREENFADE);
	remove_task(id+TASK_NVISION);
	remove_task(id+TASK_THERMAL);

	if (g_thermal_nvision[id])
		emit_sound(id, CHAN_STATIC, PRD_VISION_SOUNDS[3], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);

}

marineme(id)
{
	ExecuteForward(g_fwUserMarine_attempt, g_fwReturnValue, id);

	if (g_fwReturnValue >= AVP_PLUGIN_HANDLED && !g_newround && fn_GetMarines() > g_lastplayerleaving)
		return;

	ExecuteForward(g_fwUserMarined_pre, g_fwReturnValue, id);

	if (g_predator[id] && g_thermal_nvision[id])
	{
		emit_sound(id, CHAN_STATIC, PRD_VISION_SOUNDS[3], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		play_ambience_sound(id);
	}

	reset_vars(id);

	g_marine[id] = true;

	set_view(id, CAMERA_NONE);

	drop_user_weapons(id, 1);
	drop_user_weapons(id, 2);

	if (cs_get_user_team(id) != CS_TEAM_CT)
		cs_set_user_team(id, CS_TEAM_CT);

	if (is_user_bot(id))
		g_marine_class[id][0] = random(g_mclass_i);
	else
	{
		set_task(1.0, "task_screen_fade", id+TASK_SCREENFADE, _, _, "b");
	
		if (get_pcvar_num(cvar_marine_nvision[0]) > 0)
		{
			g_nvision[id] = true;

			if (get_pcvar_num(cvar_marine_nvision[0]) == 1)
			{
				g_nvisionenabled[id] = true;
				set_task(0.1, "task_set_user_nvision", id+TASK_NVISION, _, _, "b")
			}
		}
	}

	g_marine_class[id][1] = g_marine_class[id][0];

	new class_data[MarineData];
	ArrayGetArray(g_array_mrn_class, g_marine_class[id][0], class_data)

	set_user_health(id, class_data[MarineHealth]);
	set_user_gravity(id, class_data[MarineGravity]);
	cs_set_player_model(id, class_data[MarineModel]);

	strip_user_weapons(id);
	give_item(id, "weapon_knife");
	
	if (is_user_bot(id))
	{
		static random;
		random = random_num(0, g_weapon_i[0] - 1);
		force_bot_buy_weapon(id, random);
	}

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	menu_game(id);

	ExecuteForward(g_fwUserMarined_post, g_fwReturnValue, id);
}

predatorme(id)
{
	ExecuteForward(g_fwUserPredator_attempt, g_fwReturnValue, id);

	if (g_fwReturnValue >= AVP_PLUGIN_HANDLED && !g_newround && fn_GetPredators() > g_lastplayerleaving)
		return;

	ExecuteForward(g_fwUserPredatorized_pre, g_fwReturnValue, id);

	reset_vars(id);

	g_predator[id] = true;

	set_view(id, CAMERA_NONE);

	drop_user_weapons(id, 1);
	drop_user_weapons(id, 2);

	play_array_sound(id, CHAN_VOICE, predator_turnedin);

	if (cs_get_user_team(id) != CS_TEAM_CT)
		cs_set_user_team(id, CS_TEAM_CT);

	if (is_user_bot(id))
		g_predator_class[id][0] = random(g_pclass_i);
	else
	{
		set_task(1.0, "task_screen_fade", id+TASK_SCREENFADE, _, _, "b");

		if (get_pcvar_num(cvar_predator_nvision[0]) > 0)
		{
			g_nvision[id] = true;

			if (get_pcvar_num(cvar_predator_nvision[0]) == 1)
			{
				set_task(0.1, "task_set_user_nvision", id+TASK_NVISION, _, _, "b")
				g_nvisionenabled[id] = true;
			}
		}
	}

	g_predator_class[id][1] = g_predator_class[id][0];

	new class_data[PredatorData];
	ArrayGetArray(g_array_prd_class, g_predator_class[id][0], class_data)

	set_user_health(id, class_data[PredatorHealth]);
	set_user_gravity(id, class_data[PredatorGravity]);
	cs_set_player_model(id, class_data[PredatorModel]);

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	menu_game(id);

	ExecuteForward(g_fwUserPredatorized_post, g_fwReturnValue, id);
}

alienme(id)
{
	ExecuteForward(g_fwUserAlien_attempt, g_fwReturnValue, id);

	if (g_fwReturnValue >= AVP_PLUGIN_HANDLED && !g_newround && fn_GetAliens() > g_lastplayerleaving)
		return;

	ExecuteForward(g_fwUserAlienized_pre, g_fwReturnValue, id);

	if (g_predator[id] && g_thermal_nvision[id])
	{
		emit_sound(id, CHAN_STATIC, PRD_VISION_SOUNDS[3], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		play_ambience_sound(id);
	}

	reset_vars(id);

	g_alien[id] = true;

	switch (get_pcvar_num(cvar_alien_camera))
	{
		case 1: set_view(id, CAMERA_UPLEFT);
		case 2: set_view(id, CAMERA_3RDPERSON);
	}

	drop_user_weapons(id, 1);
	drop_user_weapons(id, 2);

	if (cs_get_user_team(id) != CS_TEAM_T)
		cs_set_user_team(id, CS_TEAM_T);

	play_array_sound(id, CHAN_VOICE, alien_turnedin);

	if (is_user_bot(id))
		g_alien_class[id][0] = random(g_aclass_i);
	else
	{
		set_task(1.0, "task_screen_fade", id+TASK_SCREENFADE, _, _, "b");

		if (get_pcvar_num(cvar_alien_nvision[0]) > 0)
		{
			g_nvision[id] = true;

			if (get_pcvar_num(cvar_alien_nvision[0]) == 1)
			{
				set_task(0.1, "task_set_user_nvision", id+TASK_NVISION, _, _, "b")
				g_nvisionenabled[id] = true;
			}
		}
	}

	g_alien_class[id][1] = g_alien_class[id][0];

	new class_data[AlienData];
	ArrayGetArray(g_array_aln_class, g_alien_class[id][0], class_data)

	set_user_health(id, class_data[AlienHealth]);
	set_user_gravity(id, class_data[AlienGravity]);
	cs_set_player_model(id, class_data[AlienModel]);

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	ExecuteHamB(Ham_Player_ResetMaxSpeed, id);

	menu_game(id);

	ExecuteForward(g_fwUserAlienized_post, g_fwReturnValue, id);
}

force_bot_buy_weapon(id, weaponid)
{
	if (g_weapon_i[1] <= 0)
		return;

	new eWeaponData[WeaponData];

	ArrayGetArray(g_array_weapon, weaponid, eWeaponData);

	if (eWeaponData[WeaponType] != AVP_PRIMARY_WEAPON)
	{
		static random;
		random = random_num(0, g_weapon_i[0] - 1);
		force_bot_buy_weapon(id, random);
		return;
	}

	callfunc_begin_i(eWeaponData[WeaponFuncID], eWeaponData[WeaponPlugin]);
	callfunc_push_int(id);
	callfunc_end();
}

play_ambience_sound(id)
{
	if ((g_ambience_sounds[AMBIENCE_SOUNDS_DECIMATION] && g_decimation_round) || (g_ambience_sounds[AMBIENCE_SOUNDS_EXTINCTION] && g_extinction_round))
	{
		static sound[64], random;

		if (g_decimation_round)
		{
			random = random_num(0, ArraySize(ambience_sounds_decimation) - 1);
			ArrayGetString(ambience_sounds_decimation, random, sound, charsmax(sound));
		}
		else if (g_extinction_round)
		{
			random = random_num(0, ArraySize(ambience_sounds_extinction) - 1);
			ArrayGetString(ambience_sounds_extinction, random, sound, charsmax(sound));
		}

		PlaySound(id, sound);
	}
}

get_player_name(id)
{
	new szName[32];
	get_user_name(id, szName, charsmax(szName));

	return szName;
}

get_random_user(const flags[]="", const team[]="")
{
	new players[32], pnum;
	get_players(players, pnum, flags, team);

	return (pnum > 0) ? players[random(pnum)] : -1;
}

balance_teams()
{
	new players[32], pnum;
	get_players(players, pnum);
	
	if (pnum < 1) return;
	
	static iTerrors, iMaxTerrors, id;
	iMaxTerrors = pnum/2;
	iTerrors = 0;

	for (--pnum; pnum >= 0; pnum--)
	{
		id = players[pnum];

		new CsTeams:team = cs_get_user_team(id);

		if (team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED)
			continue;

		if (team != CS_TEAM_CT)
			cs_set_user_team(id, CS_TEAM_CT);
	}
	
	while (iTerrors < iMaxTerrors)
	{
		id = get_random_user("e", "CT");
		
		if (random_num(0, 1))
		{
			cs_set_user_team(id, CS_TEAM_T);
			iTerrors++;
		}
	}
}

allowed_decimation()
{
	static players[32], pnum;
	get_players(players, pnum, "a");

	if (!g_newround || g_endround || pnum < get_pcvar_num(cvar_decimation_minplayers))
		return false;

	return true;
}

allowed_extinction()
{
	if (!g_newround || g_endround)
		return false;

	return true;
}

allowed_respawn(id)
{
	static CsTeams:team;
	team = cs_get_user_team(id);

	if (is_user_alive(id) || g_endround || team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED)
		return false;

	return true;
}

allowed_action(id, player)
{
	if ((!is_user_alive(player) && PL_ACTION != ACTION_RESPAWN_USER) || (is_user_alive(player) && PL_ACTION == ACTION_RESPAWN_USER) || (PL_ACTION == ACTION_MAKE_MARINE && !allowed_marine(player)) || (PL_ACTION == ACTION_MAKE_PREDATOR && !allowed_predator(player)) || (PL_ACTION == ACTION_MAKE_ALIEN && !allowed_alien(player)))
		return false;

	return true;
}

allowed_alien(id)
{
	if (!is_user_alive(id) || g_newround || g_endround || g_alien[id] || (g_predator[id] && fn_GetPredators() == 1 && !fn_GetMarines()) || (g_marine[id] && fn_GetMarines() == 1 && !fn_GetPredators()))
		return false;

	return true;
}

allowed_marine(id)
{
	if (!is_user_alive(id) || g_newround || g_endround || g_marine[id] || (g_alien[id] && fn_GetAliens() == 1))
		return false;

	return true;
}

allowed_predator(id)
{
	if (!is_user_alive(id) || g_newround || g_endround || g_predator[id] || (g_alien[id] && fn_GetAliens() == 1))
		return false;

	return true;
}

fn_GetMarines()
{
	new players[32], pnum, id, iMarines;
	get_players(players, pnum, "a");

	iMarines = 0;

	for (--pnum; pnum >= 0; pnum--)
	{
		id = players[pnum];

		if (g_marine[id])
			iMarines++;
	}

	return iMarines;
}

fn_GetAliens()
{
	new players[32], pnum, id, iAliens;
	get_players(players, pnum, "a");

	iAliens = 0;

	for (--pnum; pnum >= 0; pnum--)
	{
		id = players[pnum];

		if (g_alien[id])
			iAliens++;
	}

	return iAliens;
}

fn_GetPredators()
{
	new players[32], pnum, id, iPredators;
	get_players(players, pnum, "a");

	iPredators = 0;

	for (--pnum; pnum >= 0; pnum--)
	{
		id = players[pnum];

		if (g_predator[id])
			iPredators++;
	}

	return iPredators;
}

PlaySound(const index, const sound[])
{
	if (equal(sound[strlen(sound)-5], ".mp3"))
		client_cmd(index, "mp3 play ^"sound/%s^"", sound)
	else
		client_cmd(index, "speak ^"sound/%s^"", sound)
}

//- Client commands

public clcmd_changeteam(id)
{
	static CsTeams:team;
	team = cs_get_user_team(id);

	if (team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED)
		return PLUGIN_CONTINUE;

	menu_game(id);
	return PLUGIN_HANDLED;
}

public clcmd_nightvision(id)
{
	if (g_predator[id])
	{
		if (!g_nvision[id] && !g_thermal_nvision[id])
		{
			g_nvisionenabled[id] = true;
			g_nvision[id] = true;

			emit_sound(id, CHAN_AUTO, PRD_VISION_SOUNDS[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

			remove_task(id+TASK_NVISION);
			set_task(0.1, "task_set_user_nvision", id+TASK_NVISION, _, _, "b")
		}
		else if (g_nvision[id])
		{
			PlaySound(id, "");

			g_nvision[id] = false;
			g_thermal_nvision[id] = true;
			g_nvisionenabled[id] = true;

			emit_sound(id, CHAN_AUTO, PRD_VISION_SOUNDS[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			emit_sound(id, CHAN_STATIC, PRD_VISION_SOUNDS[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
			remove_task(id+TASK_THERMAL);
			set_task(20.0, "task_thermal_sound", id+TASK_THERMAL, _, _, "b");

			remove_task(id+TASK_NVISION);
			set_task(0.1, "task_set_user_nvision", id+TASK_NVISION, _, _, "b")
		}
		else if (g_thermal_nvision[id])
		{
			g_thermal_nvision[id] = false;
			g_nvisionenabled[id] = false;

			emit_sound(id, CHAN_STATIC, PRD_VISION_SOUNDS[3], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(id, CHAN_AUTO, PRD_VISION_SOUNDS[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

			remove_task(id+TASK_THERMAL);
			remove_task(id+TASK_NVISION);

			play_ambience_sound(id);
		}
	}
	else
	{
		if (g_nvision[id])
		{
			g_nvisionenabled[id] = !(g_nvisionenabled[id]);
				
			remove_task(id+TASK_NVISION);
			if (g_nvisionenabled[id]) set_task(0.1, "task_set_user_nvision", id+TASK_NVISION, _, _, "b")
		}
	}

	return PLUGIN_HANDLED;
}

public cmd_marine(id, level, cid)
{
	if (!cmd_access(id, read_flags(g_access_flag[ACCESS_MAKE_MARINE]), cid, 2))
		return PLUGIN_HANDLED;

	static arg[32], player;
	read_argv(1, arg, charsmax(arg));
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));

	if (!player) return PLUGIN_HANDLED;

	if (!allowed_marine(player))
	{
		client_print(id, print_console, "[AvP] %L", id, "CMD_NOT");
		return PLUGIN_HANDLED;
	}

	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %s %L", get_player_name(player), LANG_PLAYER, "CMD_MARINE")
		case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %s %L", get_player_name(id), get_player_name(player), LANG_PLAYER, "CMD_MARINE")
	}

	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", get_player_name(id), authid, ip, get_player_name(player), LANG_SERVER, "CMD_MARINE", get_playersnum(), g_maxplayers);
		log_to_file("aliens_vs_predator.log", logdata)
	}

	marineme(player);

	return PLUGIN_HANDLED;
}

public cmd_alien(id, level, cid)
{
	if (!cmd_access(id, read_flags(g_access_flag[ACCESS_MAKE_ALIEN]), cid, 2))
		return PLUGIN_HANDLED;

	static arg[32], player;
	read_argv(1, arg, charsmax(arg));
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));

	if (!player) return PLUGIN_HANDLED;

	if (!allowed_alien(player))
	{
		client_print(id, print_console, "[AvP] %L", id, "CMD_NOT");
		return PLUGIN_HANDLED;
	}

	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %s %L", get_player_name(player), LANG_PLAYER, "CMD_ALIEN")
		case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %s %L", get_player_name(id), get_player_name(player), LANG_PLAYER, "CMD_ALIEN")
	}

	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", get_player_name(id), authid, ip, get_player_name(player), LANG_SERVER, "CMD_ALIEN", get_playersnum(), g_maxplayers);
		log_to_file("aliens_vs_predator.log", logdata)
	}

	alienme(player);

	return PLUGIN_HANDLED;
}

public cmd_predator(id, level, cid)
{
	if (!cmd_access(id, read_flags(g_access_flag[ACCESS_MAKE_PREDATOR]), cid, 2))
		return PLUGIN_HANDLED;

	static arg[32], player;
	read_argv(1, arg, charsmax(arg));
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));

	if (!player) return PLUGIN_HANDLED;

	if (!allowed_predator(player))
	{
		client_print(id, print_console, "[AvP] %L", id, "CMD_NOT");
		return PLUGIN_HANDLED;
	}

	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %s %L", get_player_name(player), LANG_PLAYER, "CMD_PREDATOR")
		case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %s %L", get_player_name(id), get_player_name(player), LANG_PLAYER, "CMD_PREDATOR")
	}

	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", get_player_name(id), authid, ip, get_player_name(player), LANG_SERVER, "CMD_PREDATOR", get_playersnum(), g_maxplayers);
		log_to_file("aliens_vs_predator.log", logdata)
	}

	predatorme(player);

	return PLUGIN_HANDLED;
}

public cmd_respawn(id, level, cid)
{
	if (!cmd_access(id, read_flags(g_access_flag[ACCESS_RESPAWN_USER]), cid, 2))
		return PLUGIN_HANDLED;

	static arg[32], player;
	read_argv(1, arg, charsmax(arg));
	player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);

	if (!player) return PLUGIN_HANDLED;

	if (!allowed_respawn(player))
	{
		client_print(id, print_console, "[AvP] %L", id, "CMD_NOT");
		return PLUGIN_HANDLED;
	}

	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %s %L", get_player_name(player), LANG_PLAYER, "CMD_RESPAWN")
		case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %s %L", get_player_name(id), get_player_name(player), LANG_PLAYER, "CMD_RESPAWN")
	}

	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", get_player_name(id), authid, ip, get_player_name(player), LANG_SERVER, "CMD_RESPAWN", get_playersnum(), g_maxplayers);
		log_to_file("aliens_vs_predator.log", logdata)
	}

	ExecuteHam(Ham_CS_RoundRespawn, player);

	return PLUGIN_HANDLED;
}

public cmd_decimation(id, level, cid)
{
	if (!cmd_access(id, read_flags(g_access_flag[ACCESS_START_DECIMATION]), cid, 1))
		return PLUGIN_HANDLED;

	if (!allowed_decimation())
	{
		client_print(id, print_console, "[AvP] %L", id, "CMD_NOT");
		return PLUGIN_HANDLED;
	}

	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %L", LANG_PLAYER, "CMD_DECIMATION")
		case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %L", get_player_name(id), LANG_PLAYER, "CMD_DECIMATION")
	}

	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", get_player_name(id), authid, ip, LANG_SERVER, "CMD_DECIMATION", get_playersnum(), g_maxplayers);
		log_to_file("aliens_vs_predator.log", logdata)
	}

	remove_task(TASK_NEWROUND);
	start_mode(MODE_DECIMATION, 0);

	return PLUGIN_HANDLED;
}

public cmd_extinction(id, level, cid)
{
	if (!cmd_access(id, read_flags(g_access_flag[ACCESS_START_EXTINCTION]), cid, 1))
		return PLUGIN_HANDLED;

	if (!allowed_extinction())
	{
		client_print(id, print_console, "[AvP] %L", id, "CMD_NOT");
		return PLUGIN_HANDLED;
	}

	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: avp_colored_print(0, "!g[AvP] !yADMIN - %L", LANG_PLAYER, "CMD_EXTINCTION")
		case 2: avp_colored_print(0, "!g[AvP] !yADMIN %s - %L", get_player_name(id), LANG_PLAYER, "CMD_EXTINCTION")
	}

	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", get_player_name(id), authid, ip, LANG_SERVER, "CMD_EXTINCTION", get_playersnum(), g_maxplayers);
		log_to_file("aliens_vs_predator.log", logdata)
	}

	remove_task(TASK_NEWROUND);
	start_mode(MODE_EXTINCTION, 0);

	return PLUGIN_HANDLED;
}

//- Message functions

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	if (!is_user_alive(msg_entity) ||g_alien[msg_entity])
		return;

	if (get_msg_arg_int(1) != 1)
		return;

	if (get_pcvar_num(cvar_marine_unlimited) <= 1)
		return;

	static weapon;
	weapon = get_msg_arg_int(2);

	if (MAXBPAMMO[weapon] > 2)
	{
		static weapon_ent;
		weapon_ent = get_pdata_cbase(msg_entity, 373, 5);

		if (is_valid_ent(weapon_ent)) cs_set_weapon_ammo(weapon_ent, MAXCLIP[weapon]);

		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]);
	}
}

public refill_bpammo(const args[], id)
{
	if (!is_user_alive(id) || g_alien[id])
		return;
	
	set_msg_block(g_msgAmmoPickup, BLOCK_ONCE);
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[REFILL_WEAPONID], AMMOTYPE[REFILL_WEAPONID], MAXBPAMMO[REFILL_WEAPONID]);
}

public message_textmsg()
{
	static textmsg[22];
	get_msg_arg_string(2, textmsg, charsmax(textmsg));
	
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		logevent_round_end();
	}
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public message_ammopickup(msg_id, msg_dest, msg_entity)
{
	if (g_alien[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public message_weappickup(msg_id, msg_dest, msg_entity)
{
	if (g_alien[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8];
		get_msg_arg_string(2, sprite, charsmax(sprite));
		
		if (equal(sprite, "hostage"))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public message_statusicon(msg_id, msg_dest, msg_entity)
{
	static szIcon[8];
	get_msg_arg_string(2, szIcon, 7);

	if(equal(szIcon, "buyzone") && get_msg_arg_int(1))
	{
		set_pdata_int(msg_entity, 235, get_pdata_int(msg_entity, 235) & ~(1<<0));

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message_hostagepos()
{
	return PLUGIN_HANDLED;
}

public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

//- Natives

public native_register_alien_class(plugin, params)
{
	new class_data[AlienData];

	get_string(1, class_data[AlienName], charsmax(class_data[AlienName]));
	get_string(1, class_data[AlienSection], charsmax(class_data[AlienSection]));
	get_string(2, class_data[AlienInfo], charsmax(class_data[AlienInfo]));
	class_data[AlienHealth] = get_param(3);
	class_data[AlienGravity] = _:get_param_f(4);
	class_data[AlienDamage] = get_param(5);
	class_data[AlienSpeed] = _:get_param_f(6);
	get_string(7, class_data[AlienModel], charsmax(class_data[AlienModel]));
	get_string(8, class_data[AlienClaw], charsmax(class_data[AlienClaw]));

	if (!amx_load_setting_string(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "NAME", class_data[AlienName], charsmax(class_data[AlienName])))
		amx_save_setting_string(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "NAME", class_data[AlienName]);

	if (!amx_load_setting_string(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "INFO", class_data[AlienInfo], charsmax(class_data[AlienInfo])))
		amx_save_setting_string(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "INFO", class_data[AlienInfo]);

	if (!amx_load_setting_string(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "MODEL", class_data[AlienModel], charsmax(class_data[AlienModel])))
		amx_save_setting_string(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "MODEL", class_data[AlienModel]);

	if (!amx_load_setting_int(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "HEALTH", class_data[AlienHealth]))
		amx_save_setting_int(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "HEALTH", class_data[AlienHealth]);

	if (!amx_load_setting_float(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "GRAVITY", class_data[AlienGravity]))
		amx_save_setting_float(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "GRAVITY", class_data[AlienGravity]);

	if (!amx_load_setting_int(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "DAMAGE", class_data[AlienDamage]))
		amx_save_setting_int(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "DAMAGE", class_data[AlienDamage]);

	if (!amx_load_setting_float(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "SPEED", class_data[AlienSpeed]))
		amx_save_setting_float(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "SPEED", class_data[AlienSpeed]);

	if (!amx_load_setting_string(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "CLAW", class_data[AlienClaw], charsmax(class_data[AlienClaw])))
		amx_save_setting_string(AVP_ALIENCLASSES_FILE, class_data[AlienSection], "CLAW", class_data[AlienClaw]);

	new szBuffer[64];
	format(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", class_data[AlienModel], class_data[AlienModel]);
	engfunc(EngFunc_PrecacheModel, szBuffer);

	engfunc(EngFunc_PrecacheModel, class_data[AlienClaw]);

	ArrayPushArray(g_array_aln_class, class_data);

	g_aclass_i++;
	return g_aclass_i-1;
}

public native_register_predator_class(plugin, params)
{
	new class_data[PredatorData];

	get_string(1, class_data[PredatorName], charsmax(class_data[PredatorName]));
	get_string(1, class_data[PredatorSection], charsmax(class_data[PredatorSection]));
	get_string(2, class_data[PredatorInfo], charsmax(class_data[PredatorInfo]));
	class_data[PredatorHealth] = get_param(3);
	class_data[PredatorGravity] = _:get_param_f(4);
	class_data[PredatorSpeed] = _:get_param_f(5);
	get_string(6, class_data[PredatorModel], charsmax(class_data[PredatorModel]));

	if (!amx_load_setting_string(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "NAME", class_data[PredatorName], charsmax(class_data[PredatorName])))
		amx_save_setting_string(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "NAME", class_data[PredatorName]);

	if (!amx_load_setting_string(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "INFO", class_data[PredatorInfo], charsmax(class_data[PredatorInfo])))
		amx_save_setting_string(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "INFO", class_data[PredatorInfo]);

	if (!amx_load_setting_string(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "MODEL", class_data[PredatorModel], charsmax(class_data[PredatorModel])))
		amx_save_setting_string(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "MODEL", class_data[PredatorModel]);

	if (!amx_load_setting_int(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "HEALTH", class_data[PredatorHealth]))
		amx_save_setting_int(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "HEALTH", class_data[PredatorHealth]);

	if (!amx_load_setting_float(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "GRAVITY", class_data[PredatorGravity]))
		amx_save_setting_float(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "GRAVITY", class_data[PredatorGravity]);

	if (!amx_load_setting_float(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "SPEED", class_data[PredatorSpeed]))
		amx_save_setting_float(AVP_PREDATORCLASSES_FILE, class_data[PredatorSection], "SPEED", class_data[PredatorSpeed]);

	new szBuffer[64];
	format(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", class_data[PredatorModel], class_data[PredatorModel]);
	engfunc(EngFunc_PrecacheModel, szBuffer);

	ArrayPushArray(g_array_prd_class, class_data);

	g_pclass_i++;
	return g_pclass_i-1;
}

public native_register_marine_class(plugin, params)
{
	new class_data[MarineData];

	get_string(1, class_data[MarineName], charsmax(class_data[MarineName]));
	get_string(1, class_data[MarineSection], charsmax(class_data[MarineSection]));
	get_string(2, class_data[MarineInfo], charsmax(class_data[MarineInfo]));
	class_data[MarineHealth] = get_param(3);
	class_data[MarineGravity] = _:get_param_f(4);
	class_data[MarineSpeed] = _:get_param_f(5);
	get_string(6, class_data[MarineModel], charsmax(class_data[MarineModel]));

	if (!amx_load_setting_string(AVP_MARINECLASSES_FILE, class_data[MarineSection], "NAME", class_data[MarineName], charsmax(class_data[MarineName])))
		amx_save_setting_string(AVP_MARINECLASSES_FILE, class_data[MarineSection], "NAME", class_data[MarineName]);

	if (!amx_load_setting_string(AVP_MARINECLASSES_FILE, class_data[MarineSection], "INFO", class_data[MarineInfo], charsmax(class_data[MarineInfo])))
		amx_save_setting_string(AVP_MARINECLASSES_FILE, class_data[MarineSection], "INFO", class_data[MarineInfo]);

	if (!amx_load_setting_string(AVP_MARINECLASSES_FILE, class_data[MarineSection], "MODEL", class_data[MarineModel], charsmax(class_data[MarineModel])))
		amx_save_setting_string(AVP_MARINECLASSES_FILE, class_data[MarineSection], "MODEL", class_data[MarineModel]);

	if (!amx_load_setting_int(AVP_MARINECLASSES_FILE, class_data[MarineSection], "HEALTH", class_data[MarineHealth]))
		amx_save_setting_int(AVP_MARINECLASSES_FILE, class_data[MarineSection], "HEALTH", class_data[MarineHealth]);

	if (!amx_load_setting_float(AVP_MARINECLASSES_FILE, class_data[MarineSection], "GRAVITY", class_data[MarineGravity]))
		amx_save_setting_float(AVP_MARINECLASSES_FILE, class_data[MarineSection], "GRAVITY", class_data[MarineGravity]);

	if (!amx_load_setting_float(AVP_MARINECLASSES_FILE, class_data[MarineSection], "SPEED", class_data[MarineSpeed]))
		amx_save_setting_float(AVP_MARINECLASSES_FILE, class_data[MarineSection], "SPEED", class_data[MarineSpeed]);

	new szBuffer[64];
	format(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", class_data[MarineModel], class_data[MarineModel]);
	engfunc(EngFunc_PrecacheModel, szBuffer);

	ArrayPushArray(g_array_mrn_class, class_data);

	g_mclass_i++;
	return g_mclass_i-1;
}

public native_register_weapon(plugin, params)
{
	new eWeaponData[WeaponData];

	get_string(1, eWeaponData[WeaponName], charsmax(eWeaponData[WeaponName]));
	get_string(1, eWeaponData[WeaponSection], charsmax(eWeaponData[WeaponSection]));
	eWeaponData[WeaponType] = get_param(3);
	eWeaponData[WeaponPlugin] = plugin;

	new szHandler[32];
	get_string(2, szHandler, charsmax(szHandler));
	eWeaponData[WeaponFuncID] = get_func_id(szHandler, plugin);

	if (!amx_load_setting_string(AVP_WEAPONS_FILE, eWeaponData[WeaponSection], "NAME", eWeaponData[WeaponName], charsmax(eWeaponData[WeaponName])))
		amx_save_setting_string(AVP_WEAPONS_FILE, eWeaponData[WeaponSection], "NAME", eWeaponData[WeaponName]);

	if (!amx_load_setting_int(AVP_WEAPONS_FILE, eWeaponData[WeaponSection], "TYPE", eWeaponData[WeaponType]))
		amx_save_setting_int(AVP_WEAPONS_FILE, eWeaponData[WeaponSection], "TYPE", eWeaponData[WeaponType]);

	ArrayPushArray(g_array_weapon, eWeaponData);

	switch (eWeaponData[WeaponType])
	{
		case AVP_PRIMARY_WEAPON: g_weapon_i[1]++;
		case AVP_SECONDARY_WEAPON: g_weapon_i[2]++;
	}

	g_weapon_i[0]++;
	return (g_weapon_i[0] - 1);
}

public native_register_extra_item(plugin, params)
{
	new eitem_data[ItemData];

	get_string(1, eitem_data[ItemName], charsmax(eitem_data[ItemName]));
	get_string(1, eitem_data[ItemSection], charsmax(eitem_data[ItemSection]));
	eitem_data[ItemCost] = get_param(2);
	eitem_data[ItemTeam] = get_param(4);
	eitem_data[ItemPlugin] = plugin;

	new szHandler[32];
	get_string(3, szHandler, charsmax(szHandler));
	eitem_data[ItemFuncID] = get_func_id(szHandler, plugin);

	if (!amx_load_setting_string(AVP_EXTRAITEMS_FILE, eitem_data[ItemSection], "NAME", eitem_data[ItemName], charsmax(eitem_data[ItemName])))
		amx_save_setting_string(AVP_EXTRAITEMS_FILE, eitem_data[ItemSection], "NAME", eitem_data[ItemName]);

	if (!amx_load_setting_int(AVP_EXTRAITEMS_FILE, eitem_data[ItemSection], "COST", eitem_data[ItemCost]))
		amx_save_setting_int(AVP_EXTRAITEMS_FILE, eitem_data[ItemSection], "COST", eitem_data[ItemCost]);

	if (!amx_load_setting_int(AVP_EXTRAITEMS_FILE, eitem_data[ItemSection], "TEAM", eitem_data[ItemTeam]))
		amx_save_setting_int(AVP_EXTRAITEMS_FILE, eitem_data[ItemSection], "TEAM", eitem_data[ItemTeam]);

	ArrayPushArray(g_array_extra_items, eitem_data);

	switch (eitem_data[ItemTeam])
	{
		case AVP_TEAM_MARINE: g_items_i[1]++;
		case AVP_TEAM_ALIEN: g_items_i[2]++;
		case AVP_TEAM_PREDATOR: g_items_i[3]++;
	}

	g_items_i[0]++;
	return (g_items_i[0] - 1);
}

public native_get_user_marine(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return -1;
	}

	return g_marine[id];
}

public native_get_user_alien(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return -1;
	}

	return g_alien[id];
}

public native_get_user_predator(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return -1;
	}

	return g_predator[id];
}

public native_get_user_marinepoints(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return -1;
	}

	return g_marinepoints[id];
}

public native_get_user_xenopoints(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return -1;
	}

	return g_xenopoints[id];
}

public native_get_user_honorpoints(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return -1;
	}

	return g_honorpoints[id];
}

public native_set_user_marinepoints(id, amount)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return false;
	}

	g_marinepoints[id] = amount;
	return true;
}

public native_set_user_xenopoints(id, amount)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return false;
	}

	g_xenopoints[id] = amount;
	return true;
}

public native_set_user_honorpoints(id, amount)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return false;
	}

	g_honorpoints[id] = amount;
	return true;
}

public native_make_user_marine(id)
{
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return false;
	}

	if (!allowed_marine(id))
		return false;

	marineme(id);
	return true;
}

public native_make_user_alien(id)
{
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return false;
	}

	if (!allowed_alien(id))
		return false;

	alienme(id);
	return true;
}

public native_make_user_predator(id)
{
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id);
		return false;
	}

	if (!allowed_predator(id))
		return false;

	predatorme(id);
	return true;
}

public native_get_marine_count()
{
	return fn_GetMarines();
}

public native_get_alien_count()
{
	return fn_GetAliens();
}

public native_get_predator_count()
{
	return fn_GetPredators();
}

public native_get_user_marine_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return -1;
	}

	return g_marine_class[id][0];
}

public native_get_user_alien_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return -1;
	}

	return g_alien_class[id][0];
}

public native_get_user_predator_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return -1;
	}

	return g_predator_class[id][0];
}

public native_set_user_marine_class(id, classid)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return false;
	}

	if (classid < 0 || classid >= g_mclass_i)
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid class ID (%d)", classid)
		return false;
	}

	g_marine_class[id][0] = classid;
	return true;
}

public native_set_user_alien_class(id, classid)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return false;
	}

	if (classid < 0 || classid >= g_aclass_i)
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid class ID (%d)", classid)
		return false;
	}

	g_alien_class[id][0] = classid;
	return true;
}

public native_set_user_predator_class(id, classid)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return false;
	}

	if (classid < 0 || classid >= g_pclass_i)
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid class ID (%d)", classid)
		return false;
	}

	g_predator_class[id][0] = classid;
	return true;
}

public native_get_user_next_mrn_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return -1;
	}

	return g_marine_class[id][1];
}

public native_get_user_next_aln_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return -1;
	}

	return g_alien_class[id][1];
}

public native_get_user_next_prd_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid Player (%d)", id)
		return -1;
	}

	return g_predator_class[id][1];
}

public native_is_decimation_round()
{
	return g_decimation_round;
}

public native_is_extinction_round()
{
	return g_extinction_round;
}

public native_get_marine_class_id(const name[])
{
	param_convert(1);

	static i, eMarineData[MarineData];

	for (i = 0; i < g_aclass_i; i++)
	{
		ArrayGetArray(g_array_mrn_class, i, eMarineData);

		if (equali(name, eMarineData[MarineName]))
			return i;
	}

	return -1;
}

public native_get_alien_class_id(const name[])
{
	param_convert(1);

	static i, eAlienData[AlienData];

	for (i = 0; i < g_aclass_i; i++)
	{
		ArrayGetArray(g_array_aln_class, i, eAlienData);

		if (equali(name, eAlienData[AlienName]))
			return i;
	}

	return -1;
}

public native_get_predator_class_id(const name[])
{
	param_convert(1);

	static i, ePredatorData[PredatorData];

	for (i = 0; i < g_aclass_i; i++)
	{
		ArrayGetArray(g_array_prd_class, i, ePredatorData);

		if (equali(name, ePredatorData[PredatorName]))
			return i;
	}

	return -1;
}

public native_get_extra_item_id(const name[])
{
	param_convert(1);

	static i, eItemData[ItemData];

	for (i = 0; i < g_items_i[0]; i++)
	{
		ArrayGetArray(g_array_extra_items, i, eItemData);

		if (equali(name, eItemData[ItemName]))
			return i;
	}

	return -1;
}

public native_force_buy_extra_item(id, itemid, ignorecost)
{
	static g_points, eItemData[ItemData];

	if (itemid < 0 || itemid >= g_items_i[0])
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid item ID (%d)", itemid);
		return false;
	}

	if (!ArrayGetArray(g_array_extra_items, itemid, eItemData))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid item ID (%d)", itemid);
		return false;
	}

	if (g_marine[id]) g_points = g_marinepoints[id];
	else if (g_predator[id]) g_points = g_honorpoints[id];
	else g_points = g_xenopoints[id];

	if (!ignorecost)
	{
		if (g_points < eItemData[ItemCost])
		{
			return false;
		}
		else
		{
			g_points = g_points - eItemData[ItemCost];
		}
	}

	callfunc_begin_i(eItemData[ItemFuncID], eItemData[ItemPlugin]);
	callfunc_push_int(id);
	callfunc_end();
	return true;
}

public native_get_weapon_id(const name[])
{
	param_convert(1);

	static i, eWeaponData[WeaponData];

	for (i = 0; i < g_weapon_i[0]; i++)
	{
		ArrayGetArray(g_array_weapon, i, eWeaponData);

		if (equali(name, eWeaponData[WeaponName]))
			return i;
	}

	return -1;
}

public native_force_buy_weapon(id, weaponid)
{
	static eWeaponData[WeaponData];

	if (weaponid < 0 || weaponid >= g_weapon_i[0])
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid weapon ID (%d)", weaponid);
		return false;
	}

	if (!ArrayGetArray(g_array_weapon, weaponid, eWeaponData))
	{
		log_error(AMX_ERR_NATIVE, "[AvP] Invalid weapon ID (%d)", weaponid);
		return false;
	}

	callfunc_begin_i(eWeaponData[WeaponFuncID], eWeaponData[WeaponPlugin]);
	callfunc_push_int(id);
	callfunc_end();
	return true;
}

//- Stocks

stock play_array_sound(id, channel, Array:soundarray)
{
	static sound[64];
	ArrayGetString(soundarray, random_num(0, ArraySize(soundarray) - 1), sound, charsmax(sound));
	emit_sound(id, channel, sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

stock drop_user_weapons(id, slot)
{
	static weapons[32], num, i, weaponid;
	num = 0
	get_user_weapons(id, weapons, num)
	
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i];
		
		if ((slot == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (slot == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			static wname[32];
			get_weaponname(weaponid, wname, charsmax(wname));
			
			engclient_cmd(id, "drop", wname);
			cs_set_user_bpammo(id, weaponid, 0);
		}
	}
}

stock get_user_speed(id)
{
	new Float:velocity[3];
	entity_get_vector(id, EV_VEC_velocity, velocity);
	
	return floatround(vector_length(velocity));
}

stock avp_colored_print(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)

	replace_all(msg, 190, "!g", "^4"); //- Green
	replace_all(msg, 190, "!y", "^1"); //- Yellow
	replace_all(msg, 190, "!t", "^3"); //- Tr=Red Ct=Blue Spec=White

	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}