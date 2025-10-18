/*
 * ReAPI constants (defines, enumerations).
 * Version: 1.11.0 (AMX API v9 [AMX Mod v2010.1+]).
 *
 * Copyright (C) - AMX Mod Dev.
 * This file is provided as is (no warranties).
 *
 *
 ******************************** INFORMATIONS *********************************
 * Most of the constants at the beginning of the file (all the ones starting   *
 * with the "Re" prefix) have been temporary put in this include file for      *
 * some reasons, but keep in mind in the future AMX Mod version they will be   *
 * moved elsewhere. Mainly because this is better to centralize them elsewhere.*
 * Also, I have not added all the ones you may need,                           *
 * but only the "most interesting", so, in other terms, only a few.            *
 *                                                                             *
 * Also, about the "API required (*)" for the Re* functions and hooks,         *
 * this is the value on which API the function has been implemented, but not   *
 * the value you might need for a Re* binary, since my module requires         *
 * different version (check the top of "reapi.inc" to see) for some reasons.   *
 *                                                                             *
 ******************************************************************************/

#if defined _reapi_const_included
	#endinput
#endif
#define _reapi_const_included


/* Macros to fix the annoying "truncated to 31 characters" warning.
 * DO NOT MODIFY THIS! */
#define EVENT_FLASHBANG_GRENADE_EXPLODED       EVENT_FLASHBANG_GRENADE_EXPL
#define EVENT_PLAYER_BLINDED_BY_FLASHBANG      EVENT_PLAYER_BLINDED_BY_FLASH
#define EVENT_TUTOR_NEED_TO_BUY_PRIMARY_WEAPON EVENT_TUTOR_NEED_TO_BUY_PWPN
#define EVENT_TUTOR_NEED_TO_BUY_PRIMARY_AMMO   EVENT_TUTOR_NEED_TO_BUY_PAMMO
#define EVENT_TUTOR_NEED_TO_BUY_SECONDARY_AMMO EVENT_TUTOR_NEED_TO_BUY_SAMMO
#define EVENT_TUTOR_NEED_TO_BUY_DEFUSE_KIT     EVENT_TUTOR_NEED_TO_BUY_DKIT
#define EVENT_RADIO_GET_IN_POSITION_AND_WAIT   EVENT_RADIO_GET_IN_POS_N_WAIT

#define ReAPI_CFGT_RH_IReHLDSServerStatic  ReAPI_CFGT_RH_IReHLDSSVS
#define ReAPI_CFGT_RGCS_ReGameDLLCSFuncs   ReAPI_CFGT_RGCS_RGDLLCSFuncs
#define ReAPI_CFGT_VTC_IVoiceTranscoderAPI ReAPI_CFGT_VTC_IVTCAPI


/***************************** CONSTANTS: ReHLDS ******************************/

/* EmitSound2 functions flags.
 *
 * Note: To use with the "SV_EmitSound2" function. */
#define SND_EMIT2_NOPAS   (1<<0) /* Never check PAS. */
#define SND_EMIT2_INVOKER (1<<1) /* Do not send to the client invoker. */

/* Server states.
 *
 * Note: To use with the "ReAPI_FC_CallFunctionByType<ID|Name>" natives and with the "ReAPI_CFGT_RH_IReHLDSServerData" call function group type and "<Get|Set>State" functions names. */
enum server_state {
	ss_dead    = 0, /* Dead. */
	ss_loading = 1, /* Can load resources (models/sounds/generic/events/consistent files...). */
	ss_active  = 2, /* Active. */
};

/* Command source types.
 *
 * Note: To use with the "ExecuteServerStringCmd" and "ValidateCommand" ReAPI hooks. */
enum cmd_source {
	src_client  = 0, /* Came in over a net connection as a "clc_stringcmd" (it is a client who called it). The "host_client" will be valid during this status. */
	src_command = 1, /* Came from the command buffer. */
};

/* Resource types.
 *
 * Note: To use with the "ReAPI_FC_CallFunctionByType<ID|Name>" natives and with the "ReAPI_CFGT_RH_ReHLDSFuncs" call function group type and "SV_AddResource" function name. */
enum resourcetype {
	t_sound = 0,
	t_skin,
	t_model,
	t_decal,
	t_generic,
	t_eventscript,
	t_world,       /* Note: Fake type for world, is really "t_model". */
	rt_unk,        /* Note: Specific to ReHLDS. */

	rt_max,
};


/************************** CONSTANTS: ReGameDLL_CS ***************************/

/* New entity flags (used in the "pfnAddToFullPack" DLL API function). */
#define EF_FORCEVISIBILITY     2048 /* Force the visibility of an entity (no PVS/PAS checks). */
#define EF_OWNER_VISIBILITY    4096 /* Only the owner can see his entity. */
#define EF_OWNER_NO_VISIBILITY 8192 /* The owner can not see his entity, but the others can. */

/* Custom "iuser3" constants. */
#define PLAYER_CAN_SHOOT        (1<<0)
#define PLAYER_FREEZE_TIME_OVER (1<<1)
#define PLAYER_IN_BOMB_ZONE     (1<<2)
#define PLAYER_HOLDING_SHIELD   (1<<3)
#define PLAYER_PREVENT_DUCK     (1<<4)
#define PLAYER_PREVENT_CLIMB    (1<<5) /* The player can not climb ladder. */

/* Damage constant. */
#if !defined DMG_EXPLOSION
	#define DMG_EXPLOSION (1<<24) /* Damage type of an HE grenade. */
#endif

/* Hit box group. */
#if !defined HIT_SHIELD
	#define HIT_SHIELD 8 /* Shield hit! Captain!!! Teuh ping! */
#endif

/* Player animations types.
 *
 * Note: To use with the "CBasePlayer::SetAnimation" function. */
enum CS_PLAYER_ANIM {
	/* Default ones from the HLSDK. */
	CS_PLAYER_IDLE,
	CS_PLAYER_WALK,
	CS_PLAYER_JUMP,
	CS_PLAYER_SUPERJUMP,
	CS_PLAYER_DIE,
	CS_PLAYER_ATTACK1,

	/* Specific to CS. */
	CS_PLAYER_ATTACK2,
	CS_PLAYER_FLINCH,
	CS_PLAYER_LARGE_FLINCH,
	CS_PLAYER_RELOAD,
	CS_PLAYER_HOLDBOMB,
};

/* Reward types.
 *
 * Note: To use with the "CBasePlayer::AddAccount" function (only the ReGameDLL_CS version, because the standard CS does not have such parameter). */
enum RewardType {
	RT_NONE,

	RT_ROUND_BONUS,
	RT_PLAYER_RESET,
	RT_PLAYER_JOIN,
	RT_PLAYER_SPEC_JOIN,
	RT_PLAYER_BOUGHT_SOMETHING,
	RT_HOSTAGE_TOOK,
	RT_HOSTAGE_RESCUED,
	RT_HOSTAGE_DAMAGED,
	RT_HOSTAGE_KILLED,
	RT_TEAMMATES_KILLED,
	RT_ENEMY_KILLED,
	RT_INTO_GAME,
	RT_VIP_KILLED,
	RT_VIP_RESCUED_MYSELF,
};

/* Item restrictions types.
 *
 * Notes:
 *   To use with the "CBasePlayer::HasRestrictItem" ReAPI hook and maybe other functions.
 *   The extras constants after "ITEM_P90" are specific to the ReGameDLL_CS binary. */
enum ItemID {
	ITEM_NONE = -1,

	/* Default CS's constants. */
	ITEM_SHIELDGUN,
	ITEM_P228,
	ITEM_GLOCK,
	ITEM_SCOUT,
	ITEM_HEGRENADE,
	ITEM_XM1014,
	ITEM_C4,
	ITEM_MAC10,
	ITEM_AUG,
	ITEM_SMOKEGRENADE,
	ITEM_ELITE,
	ITEM_FIVESEVEN,
	ITEM_UMP45,
	ITEM_SG550,
	ITEM_GALIL,
	ITEM_FAMAS,
	ITEM_USP,
	ITEM_GLOCK18,
	ITEM_AWP,
	ITEM_MP5N,
	ITEM_M249,
	ITEM_M3,
	ITEM_M4A1,
	ITEM_TMP,
	ITEM_G3SG1,
	ITEM_FLASHBANG,
	ITEM_DEAGLE,
	ITEM_SG552,
	ITEM_AK47,
	ITEM_KNIFE,
	ITEM_P90,

	/* Extras constants specific to the ReGameDLL_CS binary. */
	ITEM_NVG_RGCS,
	ITEM_DEFUSEKIT_RGCS,
	ITEM_KEVLAR_RGCS,
	ITEM_ASSAULT_RGCS,
	ITEM_LONGJUMP_RGCS,
	ITEM_SODACAN_RGCS,
	ITEM_HEALTHKIT_RGCS,
	ITEM_ANTIDOTE_RGCS,
	ITEM_BATTERY_RGCS,
};

/* Item restrictions types.
 *
 * Note: To use with the "CBasePlayer::HasRestrictItem" ReAPI hook. */
enum ItemRestType {
	ITEM_TYPE_BUYING,   /* When a client buys via the menus. */
	ITEM_TYPE_TOUCHED,  /* When a client touches a "weaponbox", "weapon_shield", "armoury_entity" entity. */
	ITEM_TYPE_EQUIPPED, /* When a client is equipped via the "game_player_equip" entity, or when the default items are given at spawn (from the "CBasePlayer::GiveDefaultItems" game function). */
};

/* Scenario events types for the end round.
 *
 * Note: To use with the "CSGameRules::OnRoundEnd" ReAPI hook. */
enum ScenarioEventEndRound {
	ROUND_NONE,

	ROUND_TARGET_BOMB,
	ROUND_VIP_ESCAPED,
	ROUND_VIP_ASSASSINATED,
	ROUND_TERRORISTS_ESCAPED,
	ROUND_CTS_PREVENT_ESCAPE,
	ROUND_ESCAPING_TERRORISTS_NEUTR,
	ROUND_BOMB_DEFUSED,
	ROUND_CTS_WIN,
	ROUND_TERRORISTS_WIN,
	ROUND_END_DRAW,
	ROUND_ALL_HOSTAGES_RESCUED,
	ROUND_TARGET_SAVED,
	ROUND_HOSTAGE_NOT_RESCUED,
	ROUND_TERRORISTS_NOT_ESCAPED,
	ROUND_VIP_NOT_ESCAPED,
	ROUND_GAME_COMMENCE,
	ROUND_GAME_RESTART,
	ROUND_GAME_OVER,
};

/* Custom death message flags.
 *
 * Note: To use with the "CSGameRules::SendDeathMessage" ReAPI hook (only the ReGameDLL_CS version, because the standard CS does not have such parameter), and with the "iDeathMessageFlags" variable. */
enum DeathMessageFlags {
	PLAYERDEATH_POSITION   = (1<<0), /* Type: Float[3]/Coord/Vector. Description: Position where the victim was killed by the enemy. */
	PLAYERDEATH_ASSISTANT  = (1<<1), /* Type: Byte. Description: ID of the assistant who helped the attacker to kill the victim. */
	PLAYERDEATH_KILLRARITY = (1<<2), /* Type: Short. Description: Sum of bits classification for the rarity of the kill (check the "KillRarity" enumeration list below for details). */
};

/* Classification of various client kill methods in the game.
 *
 * Note: To use with the "CSGameRules::SendDeathMessage" ReAPI hook (only the ReGameDLL_CS version, because the standard CS does not have such parameter), and with the "PLAYERDEATH_KILLRARITY" flag set to the "iDeathMessageFlags" variable, and the value of the "iRarityOfKill" variable. */
enum KillRarity {
	KILLRARITY_HEADSHOT         = (1<<0), /* Headshot. */
	KILLRARITY_KILLER_BLIND     = (1<<1), /* Killer was blind. */
	KILLRARITY_NOSCOPE          = (1<<2), /* No-scope sniper rifle kill. */
	KILLRARITY_PENETRATED       = (1<<3), /* Penetrated kill (through walls). */
	KILLRARITY_THRUSMOKE        = (1<<4), /* Smoke grenade penetration kill (bullets went through smoke). */
	KILLRARITY_ASSISTEDFLASH    = (1<<5), /* Assister helped with a flash. */
	KILLRARITY_DOMINATION_BEGAN = (1<<6), /* Killer client began dominating the victim (NOTE: This flag is set once). */
	KILLRARITY_DOMINATION       = (1<<7), /* Continues domination by the killer. */
	KILLRARITY_REVENGE          = (1<<8), /* Revenge by the killer. */
};

/* Global events types (used by the bots manager and other things as career, tutor, etc.).
 *
 * Note: To use with the "CBotManager::OnEvent" ReAPI hook. */
enum GameEventType {
	EVENT_INVALID = 0,

	EVENT_WEAPON_FIRED,                 /* Tell bots the client is attacking. Parameters: #2 = attacker, #3 = none (null). */
	EVENT_WEAPON_FIRED_ON_EMPTY,        /* Tell bots the client is attacking without clip ammunition. Parameters: #2 = attacker, #3 = none (null). */
	EVENT_WEAPON_RELOADED,              /* Tell bots the client is reloading his weapon. Parameters: #2 = reloader, #3 = none (null). */

	EVENT_HE_GRENADE_EXPLODED,          /* Tell bots the HE grenade has exploded. Parameters: #2 = grenade thrower, #3 = none (null). */
	EVENT_FLASHBANG_GRENADE_EXPLODED,   /* Tell bots the flashbang grenade has exploded Parameters: #2 = grenade thrower, #3 = Explosion origin (converted from vector to CBaseEntity's pointer). */
	EVENT_SMOKE_GRENADE_EXPLODED,       /* Tell bots the smoke grenade has exploded. Parameters: #2 = grenade thrower, #3 = none (null). */
	EVENT_GRENADE_BOUNCED,

	EVENT_BEING_SHOT_AT,
	EVENT_PLAYER_BLINDED_BY_FLASHBANG,  /* Tell bots the client is flashed. Parameters: #2 = flashed client, #3 = none (null). */
	EVENT_PLAYER_FOOTSTEP,              /* Tell bots the client is running. Parameters: #2 = runner client, #3 = none (null). */
	EVENT_PLAYER_JUMPED,                /* Tell bots the client jumped. Parameters: #2 = jumper client, #3 = none (null). */
	EVENT_PLAYER_DIED,                  /* Tell bots the client died. Parameters: #2 = victim, #3 = killer. */
	EVENT_PLAYER_LANDED_FROM_HEIGHT,    /* Tell bots the client has fallen with some damage. Parameters: #2 = landed client, #3 = none (null). */
	EVENT_PLAYER_TOOK_DAMAGE,           /* Tell bots the client took damage. Parameters: #2 = victim, #3 = attacker. */
	EVENT_HOSTAGE_DAMAGED,              /* Tell bots the client has injured a hostage. Parameters: #2 = hostage, #3 = injurer. */
	EVENT_HOSTAGE_KILLED,               /* Tell bots the client has killed a hostage. Parameters: #2 = hostage, #3 = killer. */

	EVENT_DOOR,                         /* Tell bots the door is moving. Parameters: #2 = door, #3 = none (null). */
	EVENT_BREAK_GLASS,                  /* Tell bots the glass has been broken. Parameters: #2 = glass, #3 = none (null). */
	EVENT_BREAK_WOOD,                   /* Tell bots the wood has been broken. Parameters: #2 = wood, #3 = none (null). */
	EVENT_BREAK_METAL,                  /* Tell bots the metal/computer has been broken. Parameters: #2 = metal/computer, #3 = none (null). */
	EVENT_BREAK_FLESH,                  /* Tell bots the flesh has been broken. Parameters: #2 = flesh, #3 = none (null). */
	EVENT_BREAK_CONCRETE,               /* Tell bots the concrete has been broken. Parameters: #2 = concrete, #3 = none (null). */

	EVENT_BOMB_PLANTED,                 /* Tell bots the bomb has been planted. Parameters: #2 = planter, #3 = none (null). */
	EVENT_BOMB_DROPPED,                 /* Tell bots the bomb has been dropped. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_BOMB_PICKED_UP,               /* Let the bots hear the bomb pickup. Parameters: #2 = client that picked up the C4, #3 = none (null). */
	EVENT_BOMB_BEEP,                    /* Let the bots hear the bomb beeping. Parameters: #2 = C4, #3 = none (null). */
	EVENT_BOMB_DEFUSING,                /* Tell the bots someone has started defusing. Parameters: #2 = defuser, #3 = none (null). */
	EVENT_BOMB_DEFUSE_ABORTED,          /* Tell the bots someone has aborted defusing. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_BOMB_DEFUSED,                 /* Tell the bots the bomb is defused. Parameters: #2 = defuser, #3 = none (null). */
	EVENT_BOMB_EXPLODED,                /* Let the bots hear the bomb exploding. Parameters: #2 = none (null), #3 = none (null). */

	EVENT_HOSTAGE_USED,                 /* Tell bots the hostage is used. Parameters: #2 = user, #3 = none (null). */
	EVENT_HOSTAGE_RESCUED,              /* Tell bots the hostage has been rescued. Parameters: #2 = rescuer, #3 = hostage. */
	EVENT_ALL_HOSTAGES_RESCUED,         /* Tell bots all the hostages have been rescued. Parameters: #2 = none (null), #3 = none (null). */

	EVENT_VIP_ESCAPED,                  /* Tell bots the VIP has escaped. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_VIP_ASSASSINATED,             /* Tell bots the VIP has been assassinated. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_TERRORISTS_WIN,               /* Tell bots the terrorists won the round. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_CTS_WIN,                      /* Tell bots the CTs won the round. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_ROUND_DRAW,                   /* Tell bots the round was a draw. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_ROUND_WIN,                    /* Tell carreer the round was a win. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_ROUND_LOSS,                   /* Tell carreer the round was a loss. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_ROUND_START,                  /* Tell bots the round has started (when freeze period has expired). Parameters: #2 = none (null), #3 = none (null). */
	EVENT_PLAYER_SPAWNED,               /* Tell bots the player has spawned. Parameters: #2 = client spawned, #3 = none (null). */
	EVENT_CLIENT_CORPSE_SPAWNED,
	EVENT_BUY_TIME_START,
	EVENT_PLAYER_LEFT_BUY_ZONE,
	EVENT_DEATH_CAMERA_START,
	EVENT_KILL_ALL,
	EVENT_ROUND_TIME,
	EVENT_DIE,
	EVENT_KILL,
	EVENT_HEADSHOT,
	EVENT_KILL_FLASHBANGED,
	EVENT_TUTOR_BUY_MENU_OPENNED,
	EVENT_TUTOR_AUTOBUY,
	EVENT_PLAYER_BOUGHT_SOMETHING,
	EVENT_TUTOR_NOT_BUYING_ANYTHING,
	EVENT_TUTOR_NEED_TO_BUY_PRIMARY_WEAPON,
	EVENT_TUTOR_NEED_TO_BUY_PRIMARY_AMMO,
	EVENT_TUTOR_NEED_TO_BUY_SECONDARY_AMMO,
	EVENT_TUTOR_NEED_TO_BUY_ARMOR,
	EVENT_TUTOR_NEED_TO_BUY_DEFUSE_KIT,
	EVENT_TUTOR_NEED_TO_BUY_GRENADE,
	EVENT_CAREER_TASK_DONE,

	EVENT_START_RADIO_1,
	EVENT_RADIO_COVER_ME,
	EVENT_RADIO_YOU_TAKE_THE_POINT,
	EVENT_RADIO_HOLD_THIS_POSITION,
	EVENT_RADIO_REGROUP_TEAM,
	EVENT_RADIO_FOLLOW_ME,
	EVENT_RADIO_TAKING_FIRE,
	EVENT_START_RADIO_2,
	EVENT_RADIO_GO_GO_GO,
	EVENT_RADIO_TEAM_FALL_BACK,
	EVENT_RADIO_STICK_TOGETHER_TEAM,
	EVENT_RADIO_GET_IN_POSITION_AND_WAIT,
	EVENT_RADIO_STORM_THE_FRONT,
	EVENT_RADIO_REPORT_IN_TEAM,
	EVENT_START_RADIO_3,
	EVENT_RADIO_AFFIRMATIVE,
	EVENT_RADIO_ENEMY_SPOTTED,
	EVENT_RADIO_NEED_BACKUP,
	EVENT_RADIO_SECTOR_CLEAR,
	EVENT_RADIO_IN_POSITION,
	EVENT_RADIO_REPORTING_IN,
	EVENT_RADIO_GET_OUT_OF_THERE,
	EVENT_RADIO_NEGATIVE,
	EVENT_RADIO_ENEMY_DOWN,
	EVENT_END_RADIO,

	EVENT_NEW_MATCH,                    /* Tell bots the game is new (complete reset). Parameters: #2 = none (null), #3 = none (null). */
	EVENT_PLAYER_CHANGED_TEAM,          /* Tell bots the client has switched his team (also called from "pfnClientPutInServer"). Parameters: #2 = switcher, #3 = none (null). */
	EVENT_BULLET_IMPACT,                /* Tell bots the client has shoot at a wall. Parameters: #2 = shooter, #3 = shoot trace end position (converted from vector to CBaseEntity's pointer). */
	EVENT_GAME_COMMENCE,                /* Tell bots the game is commencing. Parameters: #2 = none (null), #3 = none (null). */
	EVENT_WEAPON_ZOOMED,                /* Tell bots the client has switched the zoom of his weapon. Parameters: #2 = zoom switcher, #3 = none (null). */
	EVENT_HOSTAGE_CALLED_FOR_HELP,      /* Tell bots the hostage is talking. Parameters: #2 = listener, #3 = none (null). */

	NUM_GAME_EVENTS,
};


/***************************** CONSTANTS: Reunion *****************************/

/* AuthIDs types.
 *
 * Note: To use with the "GetClientAuthType" function related to the "Reunion" module. */
enum dp_authkind_e {
	DP_AUTH_NONE       = 0,

	DP_AUTH_DPROTO     = 1,
	DP_AUTH_STEAM      = 2,
	DP_AUTH_STEAMEMU   = 3,
	DP_AUTH_REVEMU     = 4,
	DP_AUTH_OLDREVEMU  = 5,
	DP_AUTH_HLTV       = 6,
	DP_AUTH_SC2009     = 7,
	DP_AUTH_AVSMP      = 8,
	DP_AUTH_SXEI       = 9,
	DP_AUTH_REVEMU2013 = 10,
	DP_AUTH_SSE3       = 11,
};

/* AuthIDs key types.
 *
 * Note: To use with the "GetAuthKeyKind" function related to the "Reunion" module. */
enum reu_authkey_kind {
	REU_AK_UNKNOWN = -1,
	REU_AK_STEAM,
	REU_AK_VOLUMEID,
	REU_AK_HDDSN,
	REU_AK_FILEID,
	REU_AK_SXEID,
	REU_AK_OTHER,

	REU_AK_MAX,
};


/**************************** CONSTANTS: ReChecker ****************************/

/* Resource types.
 *
 * Note: To use with some functions/hooks related to the "ReChecker" module. */
enum ResourceType_e {
	RES_TYPE_NONE = 0,

	RES_TYPE_EXISTS,   /* Comparison with the specified hash value. */
	RES_TYPE_MISSING,  /* Check if missing file on client. */
	RES_TYPE_IGNORE,   /* Ignore the specified hash value. */
	RES_TYPE_HASH_ANY, /* Any file with any hash value. */
};


/********************* CONSTANTS: AMX Mod's ReAPI module **********************/

/* Binary types of the Re* projects.
 *
 * Note: To use with the natives that need those informations. */
enum ReAPI_BT {
	ReAPI_BT_ReHLDS,
	ReAPI_BT_ReGameDLL_CS,
	ReAPI_BT_Reunion,
	ReAPI_BT_ReChecker,
	ReAPI_BT_VTC,
};

/* Return types for the native "ReAPI_BF_HasBinaryRunning". */
enum ReAPI_HBRRT {
	ReAPI_HBRRT_NoReBinary,          /* That means the binary type provided is invalid, or, the related binary is not installed/running (no ReHLDS engine, no ReGameDLL_CS game, etc.). */
	ReAPI_HBRRT_InternalCheckFailed, /* The related binary is installed/running, but the "internal" check has failed, that means the "Re" binary is available but my internal requirements for the module have failed.
	                                  * Notes:
	                                  *   The "internal" check is my own major/minor version I require in order to make the functions of a Re* binary available via the module.
	                                  *   This value can not be returned when both booleans "bCheckFunctions" and "bCheckHookChains" are set to false (those last allow to bypass the "internal" check). */
	ReAPI_HBRRT_ExternalCheckFailed, /* The related binary is installed/running, but the "external" check has failed, that means the "Re" binary is available but our own requirements about major/minor have failed.
	                                  * Note: The "external" check is our custom major/minor version we require for a plugin. */
	ReAPI_HBRRT_Success,             /* That means all our check succeed, and everything is available and safe for use. */
};

/* Call function group types.
 *
 * Note: To use with the "ReAPI_FC_GetCallFunctionTypeID" and "ReAPI_FC_CallFunctionByTypeName" natives. */
enum ReAPI_CFGT {
	ReAPI_CFGT_Invalid     = -2, /* Not used. */
	ReAPI_CFGT_Unavailable = -1, /* Not used. */

	/* ReHLDS's specific call functions groups. */
	ReAPI_CFGT_RH_IReHLDSAPI = 0,
	ReAPI_CFGT_RH_ReHLDSFuncs,
	ReAPI_CFGT_RH_IReHLDSServerStatic,
	ReAPI_CFGT_RH_IReHLDSServerData,
	ReAPI_CFGT_RH_IGameClient,
	ReAPI_CFGT_RH_INetChan,

	/* ReGameDLL_CS's specific call functions groups. */
	ReAPI_CFGT_RGCS_IReGameDLLCSAPI = 100,
	ReAPI_CFGT_RGCS_ReGameDLLCSFuncs,
	ReAPI_CFGT_RGCS_CCSEntity,
	ReAPI_CFGT_RGCS_CCSPlayer,
	ReAPI_CFGT_RGCS_CCSPlayerItem,
	ReAPI_CFGT_RGCS_CCSPlayerWeapon,

	/* Reunion's specific call functions groups. */
	ReAPI_CFGT_REU_IReunionAPI = 200,

	/* ReChecker's specific call functions groups. */
	ReAPI_CFGT_RESC_IReCheckerAPI = 300,
	ReAPI_CFGT_RESC_ReCheckerFuncs,
	ReAPI_CFGT_RESC_IResourceBuffer,
	ReAPI_CFGT_RESC_IResponseBuffer,
	ReAPI_CFGT_RESC_IResourceFile,

	/* VTC's specific call functions groups. */
	ReAPI_CFGT_VTC_IVoiceTranscoderAPI = 400,
};

/* Call function types.
 *
 * Note: To use with the "ReAPI_FC_*" natives. */
enum ReAPI_CFT {
	/* The function is invalid/unrecognized (out of range). */
	ReAPI_CFT_Invalid     = -2,

	/* The function is unavailable.
	 * That means the module has it but it can not be used (either the related binary is not running, either its version is lower than the one required for the function). */
	ReAPI_CFT_Unavailable = -1,

	/* Usable functions.
	 *
	 * Notes:
	 *   All the following call functions are classified by binary type (ReHLDS, ReGameDLL_CS, etc.), then by group (non-classes then classes and subclasses), then inside each group, by alphabetic order.
	 *   There is no enumerations for them for two reasons:
	 *     #1: No problem with the annoying "truncated to 31 characters" warning from the compiler (despite I could use a #define for tricking it but I did not).
	 *     #2: The documentation is important for me, and its order too, so I can maintain it as I want from the beginning and also on updates,
	 *         something I could not do with an enumerations list where I will be "forced" to add the new enums at the end, however this will break compatibility with plugins compiled with old includes.
	 *   For coding, just grab the API function name between the quotes then copy it to your natives (ReAPI_FC_GetCallFunctionTypeID, ReAPI_FC_CallFunctionByTypeName), then respect the format between parentheses for the usage, not much complicated...
	 *   There are "Function name (API)" and "Function name (real)", the "API" one is the one you must grab and use with the natives, the other one is the real name of the function (internally),
	 *   but keep in mind it might differs sometimes since Re* projects developers have renamed various functions, or made API functions names differ from internal names for some reasons.
	 *   Also keep in mind I have renamed a few, usually some lower case characters to upper case ones.
	 *
	 *   About the usage format, you have for each of them, the "(..., " before any parameter, those "..." correspond to the base parameters of the "ReAPI_FC_CallFunctionByType<ID|Name>" natives (first parameter until "iStringPoolFlags").
	 *   All the other possible parameters (when present), must be added at the suite and respected (their number, type, etc.) to avoid malfunction or server crash.
	 *   Also, I have taken the freedom to change some formats for a simplied usage with AMX functions (natives, hooks).
	 *   For example functions which originally need a ReHLDS's IGameClient pointer will now need an entity ID (in the 1<->maxclients range).
	 *   But this is similar to the entities-specific functions, where they originally need an edict/CBaseEntity pointer but AMX just needs an ID.
	 *
	 *   About the return types, when a function returns an entity's ID, the natives allowing you to control the return values will return an ID usable for AMX functions (-1 for an invalid entity), rather than an entity's pointer.
	 *   Also, for functions that return a pointer, take care, sometimes, some may return the value of a variable/array address (for C++ formats which return "&<variable>"), or sometimes its value, but I have specified this detail in the descriptions.
	 *
	 *   About the versions required, this might not always be accurate (not my fault, I have basically browsed the commits to figure them out), but because the developers sometimes forgot to update the API version when they added new functions.
	 *   So again, I highly recommend you use the latest versions of those projects, and you "keep up" everytime it is updated, there is nothing wrong at doing this, and this is for the best!
	 *
	 *   About the descriptions and informations in globality, those last may change a bit or be extended in the future, especially when the module will be in "final design" with the next AMX Mod version! */


	/**************************************************************************
	*                    CALL FUNCTIONS -> ENGINE (ReHLDS)                    *
	**************************************************************************/

	/*************************** GROUP: IReHLDSAPI ***************************/

	/* Function name (API): "GetFlightRecorder".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pFlightRecorder).
	 * Return type: Pointer in the "pFlightRecorder" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the value of the "g_FlightRecorder" global variable. */


	/*************************** GROUP: ReHLDSFuncs **************************/

	/* Function name (API): "AddExtDLL".
	 * Function name (real): "AddExtDll_api".
	 * Format (usage): (..., pModuleHandle, &bool:bResult).
	 * Return type: Boolean in the "bResult" variable (false when limit of DLLs reached, however, true).
	 * API required (ReHLDS): v3.1.
	 * Description: Add an external DLL to the list linked with the global variable "g_rgextdll". */

	/* Function name (API): "Cmd_RemoveCmd".
	 * Function name (real): "Cmd_RemoveCmd".
	 * Format (usage): (..., const szCommandName[]).
	 * Return type: None.
	 * API required (ReHLDS): v3.1.
	 * Description: Remove a command. */

	/* Function name (API): "DropClient".
	 * Function name (real): "SV_DropClient_api".
	 * Format (usage):
	 *   (..., iClientID, bool:bCrash, const szReason[], {Float, _}:...).
	 *
	 *   Notes:
	 *     The "bCrash" boolean is to simulate a "crash" on the client (this disconnect him, but he think he crashed!).
	 *     You can use "multi-lines" in the reason by using the "^n" character everytime you have to.
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Eject a client. */

	/* Function name (API): "EV_PlayReliableEvent".
	 * Function name (real): "EV_PlayReliableEvent_api".
	 * Format (usage): (..., iClientID, iEntityID, iEventID, Float:flDelay, pEventArgs).
	 * Return type: None.
	 * API required (ReHLDS): v2.0.
	 * Description: Play a reliable event on a client to an entity ID. */

	/* Function name (API): "FilterUser".
	 * Function name (real): "SV_FilterUser".
	 * Format (usage): (..., pUserIDHandle, &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Check if an AuthID is in the bans list.
	 * Information: The result can be different depending on the CVar "sv_filterban". */

	/* Function name (API): "GetAllowCheats".
	 * Function name (real): "GetAllowCheats_api".
	 * Format (usage): (..., &pAllowCheatsAddress).
	 * Return type: Pointer in the "pAllowCheatsAddress" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the address of the "allow_cheats" global variable. */

	/* Function name (API): "GetBuildNumber".
	 * Function name (real): "GetBuildNumber_api".
	 * Format (usage): (..., &iBuildNumber).
	 * Return type: Integer in the "iBuildNumber" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the build number of the server/engine (HLDS). */

	/* Function name (API): "GetClientFallback".
	 * Function name (real): "GetClientFallback_api".
	 * Format (usage): (..., szFallback[], iFallbackLength).
	 * Return type: String in the "szFallback" array.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the value of the client fallback directory (something like, but does not seem to be used). */

	/* Function name (API): "GetCmdSource".
	 * Function name (real): "GetCmdSource_api".
	 * Format (usage): (..., &pCmdSourceAddress).
	 * Return type: Pointer in the "pCmdSourceAddress" variable.
	 * API required (ReHLDS): v1.2.
	 * Description: Get the address of the "cmd_source" global variable.
	 * Information: This allows you to retrieve the current source (server/client) of a command. */

	/* Function name (API): "GetCvarVars".
	 * Function name (real): "GetCvarVars_api".
	 * Format (usage): (..., &pCVarVars).
	 * Return type: Pointer in the "pCVarVarsHandle" variable.
	 * API required (ReHLDS): v2.2.
	 * Description: Get the value of the "cvar_vars" global variable. */

	/* Function name (API): "GetEntityInit".
	 * Function name (real): "GetEntityInit".
	 * Format (usage): (..., const szClassName[], &pResult).
	 * Return type: Pointer in the "pResult" variable.
	 * API required (ReHLDS): v3.3.
	 * Description: Get the value (handle) of an entity's class name.
	 * Information: This returns an unique pointer matching to a specific entity's class name, and can be used to determine the presence of a such entity in game binary (despite this do not work for classes not properly linked as "gib"). */

	/* Function name (API): "GetEntityInterface".
	 * Function name (real): "GetEntityInterface_api".
	 * Format (usage): (..., &pEntityInterfaceAddress).
	 * Return type: Pointer in the "pEntityInterfaceAddress" variable.
	 * API required (ReHLDS): v1.2.
	 * Description: Get the address of the "gEntityInterface" global variable.
	 * Information: This allows you to retrieve the value of all the DLL API functions ("pfnGameInit", "pfnSpawn", "pfnThink", "pfTouch", etc.). */

	/* Function name (API): "GetFirstCmdFunctionHandle".
	 * Function name (real): "GetFirstCmdFunctionHandle_api".
	 * Format (usage): (..., &pFirstCmdHandle).
	 * Return type: Pointer in the "pFirstCmdHandle" variable.
	 * API required (ReHLDS): v3.7.
	 * Description: Get the value of the "cmd_functions" global variable. */

	/* Function name (API): "GetHostClient".
	 * Function name (real): "GetHostClient_api".
	 * Format (usage): (..., &iHostClientID).
	 * Return type: Integer in the "iHostClientID" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the current host client (based on the current value of the "host_client" global variable). */

	/* Function name (API): "GetHostFrameTime".
	 * Function name (real): "GetHostFrameTime_api".
	 * Format (usage): (..., &Float:flHostFrameTime).
	 * Return type: Float in the "flHostFrameTime" variable.
	 * API required (ReHLDS): v3.7.
	 * Description: Get the host frame time. */

	/* Function name (API): "GetMsgBadRead".
	 * Function name (real): "GetMsgBadRead_api".
	 * Format (usage): (..., &pMsgBadReadAddress).
	 * Return type: Pointer in the "pMsgBadReadAddress" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the address of the "msg_badread" global variable. */

	/* Function name (API): "GetMsgReadCount".
	 * Function name (real): "GetMsgReadCount_api".
	 * Format (usage): (..., &pMsgReadCountAddress).
	 * Return type: Pointer in the "pMsgReadCountAddress" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the address of the "msg_readcount" global variable. */

	/* Function name (API): "GetNetMessage".
	 * Function name (real): "GetNetMessage_api".
	 * Format (usage): (..., &pNetMessageAddress).
	 * Return type: Pointer in the "pNetMessageAddress" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the address of the "net_message" global variable. */

	/* Function name (API): "GetPluginAPI".
	 * Function name (real): "Rehlds_GetPluginApi".
	 * Format (usage): (..., const szName[], &pResult).
	 * Return type: Pointer in the "pResult" variable (this should return the value of a global variable of an external module).
	 * API required (ReHLDS): v2.5.
	 * Description: Get the value (handle) of a plugin API.
	 * Information: This is a custom small class which stores a name and a pointer (usually the address/value of a global variable of an external module), and made for custom external modules (like Reunion, etc.). */

	/* Function name (API): "GetRealTime".
	 * Function name (real): "GetRealTime_api".
	 * Format (usage): (..., &Float:flRealTime).
	 * Return type: Float in the "flRealTime" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the current real time. */

	/* Function name (API): "GSBSecure".
	 * Function name (real): "GSBSecure_api".
	 * Format (usage): (..., &bool:bSecure).
	 * Return type: Boolean in the "bSecure" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Check if the server is secured via Steam. */

	/* Function name (API): "MSG_BeginReading".
	 * Function name (real): "MSG_BeginReading_api".
	 * Format (usage): (...).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_CurrentBit".
	 * Function name (real): "MSG_CurrentBit_api".
	 * Format (usage): (..., &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_EndBitReading".
	 * Function name (real): "MSG_EndBitReading_api".
	 * Format (usage): (..., pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_EndBitWriting".
	 * Function name (real): "MSG_EndBitWriting_api".
	 * Format (usage): (..., pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v2.0.
	 * Description: None. */

	/* Function name (API): "MSG_IsBitReading".
	 * Function name (real): "MSG_IsBitReading_api".
	 * Format (usage): (..., &bool:bResult).
	 * Return type: Boolean in the "bResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_IsBitWriting".
	 * Function name (real): "MSG_IsBitWriting_api".
	 * Format (usage): (..., &bool:bResult).
	 * Return type: Boolean in the "bResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_PeekBits".
	 * Function name (real): "MSG_PeekBits_api".
	 * Format (usage): (..., iBitsNum, &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadAngle".
	 * Function name (real): "MSG_ReadAngle_api".
	 * Format (usage): (..., &Float:flResult).
	 * Return type: Float in the "flResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadBitAngle".
	 * Function name (real): "MSG_ReadBitAngle_api".
	 * Format (usage): (..., iBitsNum, &Float:flResult).
	 * Return type: Float in the "flResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadBitCoord".
	 * Function name (real): "MSG_ReadBitCoord_api".
	 * Format (usage): (..., &Float:flResult).
	 * Return type: Float in the "flResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadBitData".
	 * Function name (real): "MSG_ReadBitData_api".
	 * Format (usage): (..., pDestHandle, iLength, &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadBits".
	 * Function name (real): "MSG_ReadBits_api".
	 * Format (usage): (..., iBitsNum, &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadBitString".
	 * Function name (real): "MSG_ReadBitString_api".
	 * Format (usage): (..., &pszResult, szResult[], iResultLength).
	 * Return type: Pointer in the "pszResult" variable and string in the "szResult" array.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadBitVec3Coord".
	 * Function name (real): "MSG_ReadBitVec3Coord_api".
	 * Format (usage): (..., const Float:vValue[3]).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadBuf".
	 * Function name (real): "MSG_ReadBuf_api".
	 * Format (usage): (..., iSize, pBufferHandle, &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v2.2.
	 * Description: None. */

	/* Function name (API): "MSG_ReadByte".
	 * Function name (real): "MSG_ReadByte_api".
	 * Format (usage): (..., &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadChar".
	 * Function name (real): "MSG_ReadChar_api".
	 * Format (usage): (..., &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadCoord".
	 * Function name (real): "MSG_ReadCoord_api".
	 * Format (usage): (..., &Float:flResult).
	 * Return type: Float in the "flResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadFloat".
	 * Function name (real): "MSG_ReadFloat_api".
	 * Format (usage): (..., &Float:flResult).
	 * Return type: Float in the "flResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadHiresAngle".
	 * Function name (real): "MSG_ReadHiresAngle_api".
	 * Format (usage): (..., &Float:flResult).
	 * Return type: Float in the "flResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadLong".
	 * Function name (real): "MSG_ReadLong_api".
	 * Format (usage): (..., &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadOneBit".
	 * Function name (real): "MSG_ReadOneBit_api".
	 * Format (usage): (..., &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadSBits".
	 * Function name (real): "MSG_ReadSBits_api".
	 * Format (usage): (..., iBitsNum, &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadShort".
	 * Function name (real): "MSG_ReadShort_api".
	 * Format (usage): (..., &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v2.2.
	 * Description: None. */

	/* Function name (API): "MSG_ReadString".
	 * Function name (real): "MSG_ReadString_api".
	 * Format (usage): (..., &pszResult, szResult[], iResultLength).
	 * Return type: Pointer in the "pszResult" variable and string in the "szResult" array.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadStringLine".
	 * Function name (real): "MSG_ReadStringLine_api".
	 * Format (usage): (..., &pszResult, szResult[], iResultLength).
	 * Return type: Pointer in the "pszResult" variable and string in the "szResult" array.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadUserCmd".
	 * Function name (real): "MSG_ReadUsercmd_api".
	 * Format (usage): (..., pToUserCmdHandle, pFromUserCmdHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_ReadVec3Coord".
	 * Function name (real): "MSG_ReadVec3Coord_api".
	 * Format (usage): (..., pSizeBufferHandle, const Float:vValue[3]).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_StartBitReading".
	 * Function name (real): "MSG_StartBitReading_api".
	 * Format (usage): (..., pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_StartBitWriting".
	 * Function name (real): "MSG_StartBitWriting_api".
	 * Format (usage): (..., pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v2.0.
	 * Description: None. */

	/* Function name (API): "MSG_WriteAngle".
	 * Function name (real): "MSG_WriteAngle_api".
	 * Format (usage): (..., pSizeBufferHandle, Float:flValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteBitAngle".
	 * Function name (real): "MSG_WriteBitAngle_api".
	 * Format (usage): (..., Float:flAngle, iBitsNum).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteBitCoord".
	 * Function name (real): "MSG_WriteBitCoord_api".
	 * Format (usage): (..., Float:flValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteBitData".
	 * Function name (real): "MSG_WriteBitData_api".
	 * Format (usage): (..., pSourceHandle, iLength).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteBits".
	 * Function name (real): "MSG_WriteBits_api".
	 * Format (usage): (..., iData, iBitsNum).
	 * Return type: None.
	 * API required (ReHLDS): v2.0.
	 * Description: None. */

	/* Function name (API): "MSG_WriteBitString".
	 * Function name (real): "MSG_WriteBitString_api".
	 * Format (usage): (..., const szValue[]).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteBuf".
	 * Function name (real): "MSG_WriteBuf_api".
	 * Format (usage): (..., pSizeBufferHandle, iSize, pBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v2.2.
	 * Description: None. */

	/* Function name (API): "MSG_WriteByte".
	 * Function name (real): "MSG_WriteByte_api".
	 * Format (usage): (..., pSizeBufferHandle, iValue).
	 * Return type: None.
	 * API required (ReHLDS): v2.2.
	 * Description: None. */

	/* Function name (API): "MSG_WriteBitVec3Coord".
	 * Function name (real): "MSG_WriteBitVec3Coord_api".
	 * Format (usage): (..., const Float:vValue[3]).
	 * Return type: None.
	 * API required (ReHLDS): v2.0.
	 * Description: None. */

	/* Function name (API): "MSG_WriteCoord".
	 * Function name (real): "MSG_WriteCoord_api".
	 * Format (usage): (..., pSizeBufferHandle, Float:flValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteFloat".
	 * Function name (real): "MSG_WriteFloat_api".
	 * Format (usage): (..., pSizeBufferHandle, Float:flValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteHiresAngle".
	 * Function name (real): "MSG_WriteHiresAngle_api".
	 * Format (usage): (..., pSizeBufferHandle, Float:flValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteLong".
	 * Function name (real): "MSG_WriteLong_api".
	 * Format (usage): (..., pSizeBufferHandle, iValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteOneBit".
	 * Function name (real): "MSG_WriteOneBit_api".
	 * Format (usage): (..., iValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteSBits".
	 * Function name (real): "MSG_WriteSBits_api".
	 * Format (usage): (..., iData, iBitsNum).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteShort".
	 * Function name (real): "MSG_WriteShort_api".
	 * Format (usage): (..., pSizeBufferHandle, iValue).
	 * Return type: None.
	 * API required (ReHLDS): v2.2.
	 * Description: None. */

	/* Function name (API): "MSG_WriteString".
	 * Function name (real): "MSG_WriteString_api".
	 * Format (usage): (..., pSizeBufferHandle, const szValue[]).
	 * Return type: None.
	 * API required (ReHLDS): v2.2.
	 * Description: None. */

	/* Function name (API): "MSG_WriteUserCmd".
	 * Function name (real): "MSG_WriteUsercmd_api".
	 * Format (usage): (..., pSizeBufferHandle, pToUserCmdHandle, pFromUserCmdHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "MSG_WriteVec3Coord".
	 * Function name (real): "MSG_WriteVec3Coord_api".
	 * Format (usage): (..., pSizeBufferHandle, const Float:vValue[3]).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "RegisterPluginAPI".
	 * Function name (real): "Rehlds_RegisterPluginApi".
	 * Format (usage): (..., const szName[], pValue).
	 * Return type: None.
	 * API required (ReHLDS): v2.5.
	 * Description: Register a new plugin API.
	 * Information: This is a custom small class which stores a name and a pointer (usually the address/value of a global variable of an external module), and made for custom external modules (like Reunion, etc.). */

	/* Function name (API): "RejectConnection".
	 * Function name (real): "SV_RejectConnection".
	 * Format (usage): (..., pNetAddressHandle, const szReason[], {Float, _}:...).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Reject the connection.
	 * Information: This can be used in conjunction of the function "SV_DropClient" and right before it. */

	/* Function name (API): "RemoveExtDLL".
	 * Function name (real): "RemoveExtDll_api".
	 * Format (usage): (..., pModuleHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.1.
	 * Description: Remove an external DLL from the list linked with the global variable "g_rgextdll". */

	/* Function name (API): "SendUserReg".
	 * Function name (real): "SV_SendUserReg".
	 * Format (usage): (..., pMessageBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Send the user messages (SVC_NEWUSERMSG). */

	/* Function name (API): "SetMoveVars".
	 * Function name (real): "SV_SetMoveVars".
	 * Format (usage): (...).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Update the "movevars" structure of the engine in order to make the variables match to the values of the CVars linked (sv_gravity, sv_stopspeed, etc.). */

	/* Function name (API): "SteamNotifyBotConnect".
	 * Function name (real): "Steam_NotifyBotConnect_api".
	 * Format (usage): (..., iClientID, &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Notify the Steam API a bot (HLTV too from that I recall) has connected. */

	/* Function name (API): "Steam_NotifyClientConnect".
	 * Function name (real): "Steam_NotifyClientConnect_api".
	 * Format (usage): (..., iClientID, pvSteam2Key, uiSteam2Key, &iResult).
	 * Return type: Integer in the "iResult" variable.
	 * API required (ReHLDS): v2.8.
	 * Description: Notify the Steam API a client has connected. */

	/* Function name (API): "Steam_NotifyClientDisconnect".
	 * Function name (real): "Steam_NotifyClientDisconnect_api".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReHLDS): v2.8.
	 * Description: Notify the Steam API a client has disconnected. */

	/* Function name (API): "StripUnprintableAndSpace".
	 * Function name (real): "StripUnprintableAndSpace_api".
	 * Format (usage): (..., pszValue, &bool:bResult).
	 * Return type: Boolean in the "bResult" variable.
	 * API required (ReHLDS): v3.0.
	 * Description: Strips some unprintable and space characters from a string. */

	/* Function name (API): "SV_AddResource".
	 * Function name (real): "SV_AddResource".
	 * Format (usage):
	 *   (..., resourcetype:iResourceType, const szFilePath[], iSize, cFlags, iResourceID).
	 *
	 *   Note: The "iResourceType" is a t_* from "reapi_const.inc" (above).
	 * Return type: None.
	 * API required (ReHLDS): v2.2.
	 * Description: Add a resource to the list of the engine's resources (total list being all-in-one and shared with clients). */

	/* Function name (API): "SV_EmitSound2".
	 * Function name (real): "SV_EmitSound2_api".
	 * Format (usage):
	 *   (..., iEntityID, iReceiverID, iChannel, const szSample[], Float:flVolume, Float:flAttenuation, iFlags, iPitch, iEmitFlags, Float:vOrigin[3], &bool:bResult).
	 *
	 *   Notes:
	 *     The "iEntityID" parameter is the entity which emits the sound (this is only used as origin for the sound), however, specify "0" and an origin in the "vOrigin" vector for a custom one.
	 *     The "iReceiverID" parameter is the receiver client, you can specify "0" to send to everyone, or a specific client (but do not work on a bot).
	 *     The "iEmitFlags" parameter is a SND_EMIT2_* from "reapi_const.inc" (above).
	 * Return type: Boolean in the "bResult" variable (false on failure, true on success).
	 * API required (ReHLDS): v2.12.
	 * Description: Emit a sound (previously precached) from an entity/origin and to a specific target (or everyone). */

	/* Function name (API): "SV_FileInConsistencyList".
	 * Function name (real): "SV_FileInConsistencyList".
	 * Format (usage): (..., const szFilename[], &pConsistencyList, &iResult).
	 * Return type:
	 *   Pointer in the "pConsistencyList" variable.
	 *   Integer in the "iResult" variable (0 when not among the list, 1 when it is).
	 * API required (ReHLDS): v2.7.
	 * Description: Check if a filename is among the consistency resources list. */

	/* Function name (API): "SV_LookupSoundIndex".
	 * Function name (real): "SV_LookupSoundIndex".
	 * Format (usage): (..., const szSample[], &iSoundID).
	 * Return type: Integer in the "iSoundID" variable (0 on failure or a number >= 1 when the sample matches to a valid sound [precached]).
	 * API required (ReHLDS): v2.0.
	 * Description: Return the ID of a sound sample precached via the sounds list of the engine's resources. */

	/* Function name (API): "SV_StartSound".
	 * Function name (real): "SV_StartSound_api".
	 * Format (usage):
	 *   (..., iRecipients, iEntityID, iChannel, const szSample[], iVolume, Float:flAttenuation, iFlags, iPitch).
	 *
	 *   Notes:
	 *     The "iRecipients" parameter must be 0 for "send to everyone", 1 for "send to one".
	 *     The "iVolume" parameter is the volume in the 0<->255 range. Take care, it is not as float format like the classic API function.
	 * Return type: None.
	 * API required (ReHLDS): v2.12.
	 * Description: Emit a sound (previously precached) from an entity (sender). */

	/* Function name (API): "SV_UpdateUserInfo".
	 * Function name (real): "SV_UpdateUserInfo_api".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReHLDS): v2.13.
	 * Description: Update the client's informations (userinfos). */

	/* Function name (API): "SZ_Clear".
	 * Function name (real): "SZ_Clear_api".
	 * Format (usage): (..., pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "SZ_GetSpace".
	 * Function name (real): "SZ_GetSpace".
	 * Format (usage): (..., pSizeBufferHandle, iLength, &pData).
	 * Return type: Pointer in the "pData" variable.
	 * API required (ReHLDS): v2.0.
	 * Description: None. */

	/* Function name (API): "SZ_Print".
	 * Function name (real): "SZ_Print_api".
	 * Format (usage): (..., pSizeBufferHandle, const szValue[]).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "SZ_Write".
	 * Function name (real): "SZ_Write_api".
	 * Format (usage): (..., pSizeBufferHandle, pData, iLength).
	 * Return type: None.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "TokenizeString".
	 * Function name (real): "Cmd_TokenizeString".
	 * Format (usage): (..., const szString[]).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description:
	 *   Tokenize a string.
	 *   This basically reads the string (command line) and split the data into the "cmd_arg<v|s|c>" variables.
	 *   This is the function that updates each command argument once a command is catched.
	 *   For example, when a client types "hi" in the chat, you will have two commands arguments ("cmd_argc" = 2), with "cmd_argv" #0 = "say", then "cmd_argv" #1 = "hi"...
	 *   The "read_arg<v|s|c>" natives from the AMX core allow you to retrieve those informations. */

	/* Function name (API): "WriteDeltaDescriptionsToClient".
	 * Function name (real): "SV_WriteDeltaDescriptionsToClient".
	 * Format (usage): (..., pMessageBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Send the user messages related to the delta descriptions (SVC_DELTADESCRIPTION). */

	/* Function name (API): "WriteMovevarsToClient".
	 * Function name (real): "SV_WriteMovevarsToClient".
	 * Format (usage): (..., pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Update the "movevars" structure of a client in order to make the variables match to the values of the CVars linked (sv_gravity, sv_stopspeed, etc.). */


	/*********************** GROUP: IReHLDSServerStatic **********************/

	/* Function name (API): "GetClient".
	 * Function name (real): None (this gets the value from an array).
	 * Format (usage): (..., iClientID, &pReHLDSIGameClientHandle).
	 * Return type: Pointer in the "pReHLDSIGameClientHandle" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the ReHLDS's "IGameClient" class pointer of a client. */

	/* Function name (API): "GetClient_t".
	 * Function name (real): None (this gets the value from an array).
	 * Format (usage): (..., iClientID, &pEngineClientHandle).
	 * Return type: Pointer in the "pEngineClientHandle" variable.
	 * API required (ReHLDS): v2.0.
	 * Description: Get the engine's "client" structure pointer of a client. */

	/* Function name (API): "GetIndexOfClient_t".
	 * Function name (real): None (this gets the value from a specific calculation).
	 * Format (usage): (..., pEngineClientHandle, &iClientID).
	 * Return type: Integer in the "iClientID" variable.
	 * API required (ReHLDS): v2.0.
	 * Description: Get the client ID from an engine's "client" structure pointer. */

	/* Function name (API): "GetLog".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pLogAddress).
	 * Return type: Pointer in the "pLogAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of the "log" member in the "g_psvs" global variable. */

	/* Function name (API): "GetMaxClients".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iMaxClients).
	 * Return type: Integer in the "iMaxClients" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the maximum number of clients the engine can support (value defined on server launch via the command line parameter "+maxplayers"). */

	/* Function name (API): "GetMaxClientsLimit".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iMaxClientsLimit).
	 * Return type: Integer in the "iMaxClientsLimit" variable.
	 * API required (ReHLDS): v3.4.
	 * Description: Get the maximum number of clients the engine can support (highest limit which can be higher than the real one). */

	/* Function name (API): "GetNextClient_t".
	 * Function name (real): None (this gets the value from a specific calculation).
	 * Format (usage): (..., pEngineClientHandle, &pNextEngineClientHandle).
	 * Return type: Pointer in the "pNextEngineClientHandle" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the next engine's "client" structure pointer of a client. */

	/* Function name (API): "GetSpawnCount".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iSpawnCount).
	 * Return type: Integer in the "iSpawnCount" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the number of "spawn count" (number of change levels performed since server start). */

	/* Function name (API): "IsLogActive".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &bool:bIsLogActive).
	 * Return type: Boolean in the "bIsLogActive" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Check if the server logging is active. */

	/* Function name (API): "IsSecure".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &bool:bIsSecure).
	 * Return type: Boolean in the "bIsSecure" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check if the server is secure. */

	/* Function name (API): "SetSecure".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., bool:bValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set if the server is secure. */

	/* Function name (API): "SetSpawnCount".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iNumber).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the number of "spawn count" (number of change levels performed since server start). */


	/*********************** GROUP: IReHLDSServerData ************************/

	/* Function name (API): "GetClientDLLMD5".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., &pszClientDLLMD5Address, szClientDLLMD5[], iClientDLLMD5Length).
	 * Return type: Pointer in the "pszClientDLLMD5Address" variable and string in the "szClientDLLMD5" array.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the client DLL MD5 value. */

	/* Function name (API): "GetConsistency".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iID, &pConsistencyAddress).
	 * Return type: Pointer in the "pConsistencyAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of a consistency resource. */

	/* Function name (API): "GetConsistencyNum".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iConsistencyNum).
	 * Return type: Integer in the "iConsistencyNum" variable.
	 * API required (ReHLDS): v2.2.
	 * Description: Get the number of consistency resources. */

	/* Function name (API): "GetDatagram".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pDatagramAddress).
	 * Return type: Pointer in the "pDatagramAddress" variable.
	 * API required (ReHLDS): v2.0.
	 * Description: Get the address of the "datagram" member in the "g_psv" global variable. */

	/* Function name (API): "GetDecalNameNum".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iDecalNameNum).
	 * Return type: Integer in the "iDecalNameNum" variable.
	 * API required (ReHLDS): v2.5.
	 * Description: Get the number of decals resources. */

	/* Function name (API): "GetEdict".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iEntityID, &pEdictHandle).
	 * Return type: Pointer in the "pEdictHandle" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of an edict (entity's pointer). */

	/* Function name (API): "GetEntityBaseline".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iEntityID, &pEntityBaselineAddress).
	 * Return type: Pointer in the "pEntityBaselineAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of an entity's baseline. */

	/* Function name (API): "GetEntityInstanceBaselines".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pEntityInstanceBaselinesHandle).
	 * Return type: Pointer in the "pEntityInstanceBaselinesHandle" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value (handle) of a the instance baselines. */

	/* Function name (API): "GetEventPrecache".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iID, &pEventAddress).
	 * Return type: Pointer in the "pEventAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of an event resource. */

	/* Function name (API): "GetLastIndexCheckInPVS".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iLastIDCheckInPVS).
	 * Return type: Integer in the "iLastIDCheckInPVS" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the last entity ID checked in PVS. */

	/* Function name (API): "GetLastIndexCheckTimeInPVS".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &Float:flLastIndexCheckTimeInPVS).
	 * Return type: Float in the "flLastIndexCheckTimeInPVS" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the time of the last entity ID checked in PVS. */

	/* Function name (API): "GetMaxEdicts".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iEdictsMax).
	 * Return type: Integer in the "iEdictsMax" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the maximum number of edicts (entities). */

	/* Function name (API): "GetModel".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iID, &pModelHandle).
	 * Return type: Pointer in the "pModelHandle" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value (handle) of a model resource. */

	/* Function name (API): "GetModelName".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., &pszModelNameAddress, szModelName[], iModelNameLength).
	 * Return type: Pointer in the "pszModelNameAddress" variable and string in the "szModelName" array.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the model name of the server. */

	/* Function name (API): "GetMulticastBuf".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pMulticastBufferAddress).
	 * Return type: Pointer in the "pMulticastBufferAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of the "multicast" member in the "g_psv" global variable. */

	/* Function name (API): "GetName".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., &pszMapNameAddress, szMapName[], iMapNameLength).
	 * Return type: Pointer in the "pszMapNameAddress" variable and string in the "szMapName" array.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the map name of the server. */

	/* Function name (API): "GetNetFrom".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pNetFromAddress).
	 * Return type: Pointer in the "pNetFromAddress" variable.
	 * API required (ReHLDS): v2.13.
	 * Description: Get the address of the "net_from" global variable. */

	/* Function name (API): "GetNumEdicts".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iEdictsNum).
	 * Return type: Integer in the "iEdictsNum" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the number of edicts (entities). */

	/* Function name (API): "GetNumGenericNames".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iGenericNamesNum).
	 * Return type: Integer in the "iGenericNamesNum" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the number of generic resources.
	 * Information: This is not the total number of "generic resources", but the one only related to the resources loaded from the map's .res file. */

	/* Function name (API): "GetOldName".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., &pszOldMapNameAddress, szOldMapName[], iOldMapNameLength).
	 * Return type: Pointer in the "pszOldMapNameAddress" variable and string in the "szOldMapName" array.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the old (previous) map name of the server. */

	/* Function name (API): "GetOldTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &Float:flOldGameTime).
	 * Return type: Float in the "flOldGameTime" variable.
	 * API required (ReHLDS): v3.7.
	 * Description: Get the old game time. */

	/* Function name (API): "GetReliableDatagram".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pReliableDatagramAddress).
	 * Return type: Pointer in the "pReliableDatagramAddress" variable.
	 * API required (ReHLDS): v2.0.
	 * Description: Get the address of the "reliable_datagram" member in the "g_psv" global variable. */

	/* Function name (API): "GetResource".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iID, &pResourceHandle).
	 * Return type: Pointer in the "pResourceHandle" variable.
	 * API required (ReHLDS): v2.7.
	 * Description: Get the value (handle) of a resource. */

	/* Function name (API): "GetResourcesNum".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iResourcesNum).
	 * Return type: Integer in the "iResourcesNum" variable.
	 * API required (ReHLDS): v2.5.
	 * Description: Get the number of total resources. */

	/* Function name (API): "GetSignonBuf".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pSignonBufferAddress).
	 * Return type: Pointer in the "pSignonBufferAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of the "signon" member in the "g_psv" global variable. */

	/* Function name (API): "GetSpectatorBuf".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pSpectatorBufferAddress).
	 * Return type: Pointer in the "pSpectatorBufferAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of the "spectator" member in the "g_psv" global variable. */

	/* Function name (API): "GetStartSpotName".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., &pszStartSpotNameAddress, szStartSpotName[], iStartSpotNameLength).
	 * Return type: Pointer in the "pszStartSpotNameAddress" variable and string in the "szStartSpotName" array.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the start spot name of the server.
	 * Information: This is a custom name which can be added to the command "changelevel" (after the map name) and used later (in the games as custom starting spawn found via target name, instead of "info_player_deathmatch", etc.). */

	/* Function name (API): "GetState".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &server_state:iState).
	 * Return type: Integer in the "iState" variable (a ss_* from "reapi_const.inc" (above)).
	 * API required (ReHLDS): v3.10.
	 * Description: Get the state of the server. */

	/* Function name (API): "GetSteamGameServer".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., &pSteamGameServerHandle).
	 * Return type: Pointer in the "pSteamGameServerHandle" variable.
	 * API required (ReHLDS): v2.13.
	 * Description: Get the value (handle) of the "SteamGameServer" function. */

	/* Function name (API): "GetTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &Float:flGameTime).
	 * Return type: Float in the "flGameTime" variable.
	 * API required (ReHLDS): v2.5.
	 * Description: Get the current game time. */

	/* Function name (API): "GetWorldMapCRC".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &iWorldMapCRC).
	 * Return type: Integer in the "iWorldMapCRC" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the CRC value of the world map. */

	/* Function name (API): "GetWorldModel".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pWorldModelHandle).
	 * Return type: Pointer in the "pWorldModelHandle" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value (handle) of the "worldmodel" member in the "g_psv" global variable. */

	/* Function name (API): "IsActive".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &bool:bIsActive).
	 * Return type: Boolean in the "bIsActive" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check if the server is active. */

	/* Function name (API): "IsPaused".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &bool:bIsPaused).
	 * Return type: Boolean in the "bIsPaused" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check if the server is paused. */

	/* Function name (API): "SetActive".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., bool:bActive).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set if the server is active. */

	/* Function name (API): "SetConsistencyNum".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iNumber).
	 * Return type: None.
	 * API required (ReHLDS): v2.2.
	 * Description: Set the number of consistency resources. */

	/* Function name (API): "SetDecalNameNum".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iNumber).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the number of decals resources. */

	/* Function name (API): "SetLastIndexCheckInPVS".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iLastIDCheckInPVS).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the last entity ID checked in PVS. */

	/* Function name (API): "SetLastIndexCheckTimeInPVS".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., Float:flLastIndexCheckTimeInPVS).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the time of the last entity ID checked in PVS. */

	/* Function name (API): "SetMaxEdicts".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iNumber).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the maximum number of edicts (entities). */

	/* Function name (API): "SetModelName".
	 * Function name (real): None (this sets the value of an array).
	 * Format (usage): (..., const szModelName[]).
	 * Return type: None.
	 * API required (ReHLDS): v2.0.
	 * Description: Set the model name of the server. */

	/* Function name (API): "SetName".
	 * Function name (real): None (this sets the value of an array).
	 * Format (usage): (..., const szMapName[]).
	 * Return type: None.
	 * API required (ReHLDS): v2.13.
	 * Description: Set the map name of the server.
	 * Information: Using this function to alter the map name (or fake it) is a bad method (not recommended). */

	/* Function name (API): "SetNetFrom".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., pNetFrom).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the "net_from" global variable. */

	/* Function name (API): "SetNumEdicts".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iNumber).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the number of edicts (entities). */

	/* Function name (API): "SetNumGenericNames".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iNumber).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the number of generic resources.
	 * Information: This does not set the total number of "generic resources", but the one only related to the resources loaded from the map's .res file. */

	/* Function name (API): "SetOldName".
	 * Function name (real): None (this sets the value of an array).
	 * Format (usage): (..., const szOldMapName[]).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the old (previous) map name of the server. */

	/* Function name (API): "SetPaused".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., bool:bPaused).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set if the server is paused. */

	/* Function name (API): "SetResourcesNum".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iNumber).
	 * Return type: None.
	 * API required (ReHLDS): v2.7.
	 * Description: Set the number of total resources. */

	/* Function name (API): "SetStartSpotName".
	 * Function name (real): None (this sets the value of an array).
	 * Format (usage): (..., const szStartSpotName[]).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the start spot name of the server. */

	/* Function name (API): "SetState".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., server_state:iState).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the state of the server. */

	/* Function name (API): "SetWorldMapCRC".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iWorldMapCRC).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the CRC value of the world map. */

	/* Function name (API): "SetWorldModel".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., pWorldModelHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value (handle) of the "worldmodel" member in the "g_psv" global variable. */


	/*************************** GROUP: IGameClient **************************/

	/* Function name (API): "GetBottomColor".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iColor).
	 * Return type: Integer in the "iColor" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "bottomcolor" member in the engine's "client" structure. */

	/* Function name (API): "GetChokeCount".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iChokeCount).
	 * Return type: Integer in the "iChokeCount" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "chokecount" member in the engine's "client" structure. */

	/* Function name (API): "GetCmdTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flCmdTime).
	 * Return type: Float in the "flCmdTime" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "cmdtime" member in the engine's "client" structure. */

	/* Function name (API): "GetConnectionStartedTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flConnectionStartedTime).
	 * Return type: Float in the "flConnectionStartedTime" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "connection_started" member in the engine's "client" structure. */

	/* Function name (API): "GetConnectTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flConnectTime).
	 * Return type: Float in the "flConnectTime" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "connecttime" member in the engine's "client" structure. */

	/* Function name (API): "GetCRC32MapValue".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iCRC32MapValue).
	 * Return type: Integer in the "iCRC32MapValue" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "crcValue" member in the engine's "client" structure. */

	/* Function name (API): "GetCustomizationData".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pCustomizationDataAddress).
	 * Return type: Pointer in the "pCustomizationDataAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of the client's "customdata" member in the engine's "client" structure. */

	/* Function name (API): "GetDatagram".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pDatagramAddress).
	 * Return type: Pointer in the "pDatagramAddress" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the address of the client's "datagram" member in the engine's "client" structure. */

	/* Function name (API): "GetDeltaSequence".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iDeltaSequence).
	 * Return type: Integer in the "iDeltaSequence" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "delta_sequence" member in the engine's "client" structure. */

	/* Function name (API): "GetEdict".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pEdictHandle).
	 * Return type: Pointer in the "pEdictHandle" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the value of the client's "edict" member in the engine's "client" structure. */

	/* Function name (API): "GetEvents".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pEventsAddress).
	 * Return type: Pointer in the "pEventsAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of the client's "events" member in the engine's "client" structure. */

	/* Function name (API): "GetFrames".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pFramesHandle).
	 * Return type: Pointer in the "pFramesHandle" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "frames" member in the engine's "client" structure. */

	/* Function name (API): "GetHashedCDKey".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iClientID, &pszHashedCDKeyAddress, szHashedCDKey[], iHashedCDKeyLength).
	 * Return type: Pointer in the "pszHashedCDKeyAddress" variable and string in the "szHashedCDKey" array.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "hashedcdkey" member in the engine's "client" structure. */

	/* Function name (API): "GetId".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iID).
	 * Return type:
	 *   Integer in the "iID" variable.
	 *
	 *   Notes:
	 *     This is an "useless function" that returns the same ID as the "iClientID" parameter, but this is decreased to -1.
	 *     So, if the client has 4 as ID, this will return 3 in the "iID" variable.
	 *     This is because the developers have used "ID - 1" style which is confusing and bad (those process in coding should not be used at all).
	 * API required (ReHLDS): v1.0.
	 * Description: Get the ID of a client. */

	/* Function name (API): "GetIgnoreCmdTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flIgnoreCmdTime).
	 * Return type: Float in the "flIgnoreCmdTime" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "ignorecmdtime" member in the engine's "client" structure. */

	/* Function name (API): "GetLastCmd".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pLastCmdAddress).
	 * Return type: Pointer in the "pLastCmdAddress" variable.
	 * API required (ReHLDS): v2.11.
	 * Description: Get the address of the client's "lastcmd" member in the engine's "client" structure. */

	/* Function name (API): "GetLastVoiceTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flLastVoiceTime).
	 * Return type: Float in the "flLastVoiceTime" variable.
	 * API required (ReHLDS): v2.5.
	 * Description: Get the value of the client's "m_lastvoicetime" member in the engine's "client" structure. */

	/* Function name (API): "GetLatency".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flLatency).
	 * Return type: Float in the "flLatency" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "latency" member in the engine's "client" structure. */

	/* Function name (API): "GetLocalTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flLocalTime).
	 * Return type: Float in the "flLocalTime" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "localtime" member in the engine's "client" structure. */

	/* Function name (API): "GetLoopback".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bLoopback).
	 * Return type: Boolean in the "bLoopback" variable.
	 * API required (ReHLDS): v2.5.
	 * Description: Check the value of the client's "m_bLoopback" member in the engine's "client" structure. */

	/* Function name (API): "GetName".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iClientID, &pszNameAddress, szName[], iNameLength).
	 * Return type: Pointer in the "pszNameAddress" variable and string in the "szName" array.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the value of the client's "name" member in the engine's "client" structure.
	 * Information: This gets the name of the client. */

	/* Function name (API): "GetNetChan".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pNetChanAddress).
	 * Return type: Pointer in the "pNetChanAddress" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the address of the CGameClient's "m_NetChan" member variable. */

	/* Function name (API): "GetNetworkUserID".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pNetworkUserIDAddress).
	 * Return type: Pointer in the "pNetworkUserIDAddress" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the address of the client's "network_userid" member in the engine's "client" structure. */

	/* Function name (API): "GetNextMessageIntervalTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flNextMessageIntervalTime).
	 * Return type: Float in the "flNextMessageIntervalTime" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "next_messageinterval" member in the engine's "client" structure. */

	/* Function name (API): "GetNextMessageTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flNextMessageTime).
	 * Return type: Float in the "flNextMessageTime" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "next_messagetime" member in the engine's "client" structure. */

	/* Function name (API): "GetPacketLoss".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flPacketLoss).
	 * Return type: Float in the "flPacketLoss" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "packet_loss" member in the engine's "client" structure. */

	/* Function name (API): "GetPhysInfo".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iClientID, &pszPhysInfoAddress, szPhysInfo[], iPhysInfoLength).
	 * Return type: Pointer in the "pszPhysInfoAddress" variable and string in the "szPhysInfo" array.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "physinfo" member in the engine's "client" structure.
	 * Information: This is the user information buffer which contains the physics keys and values ("slj", etc.) of a client. */

	/* Function name (API): "GetResourcesNeeded".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pResourcesNeededAddress).
	 * Return type: Pointer in the "pResourcesNeededAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of the client's "resourcesneeded" member in the engine's "client" structure. */

	/* Function name (API): "GetResourcesOnHand".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pResourcesOnHandAddress).
	 * Return type: Pointer in the "pResourcesOnHandAddress" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the address of the client's "resourcesonhand" member in the engine's "client" structure. */

	/* Function name (API): "GetSendInfoState".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bSendInfoState).
	 * Return type: Boolean in the "bSendInfoState" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "sendinfo" member in the engine's "client" structure. */

	/* Function name (API): "GetSendInfoTime".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flSendInfoTime).
	 * Return type: Float in the "flSendInfoTime" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "sendinfo_time" member in the engine's "client" structure. */

	/* Function name (API): "GetSendMessageState".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bSendMessageState).
	 * Return type: Boolean in the "bSendMessageState" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "send_message" member in the engine's "client" structure. */

	/* Function name (API): "GetSendResourceCount".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iSendResourceCount).
	 * Return type: Integer in the "iSendResourceCount" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "m_sendrescount" member in the engine's "client" structure. */

	/* Function name (API): "GetSkipMessageState".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bSkipMessageState).
	 * Return type: Boolean in the "bSkipMessageState" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "skip_message" member in the engine's "client" structure. */

	/* Function name (API): "GetSvTimeBase".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &Float:flSvTimeBase).
	 * Return type: Float in the "flSvTimeBase" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "svtimebase" member in the engine's "client" structure. */

	/* Function name (API): "GetTopColor".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iColor).
	 * Return type: Integer in the "iColor" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "topcolor" member in the engine's "client" structure. */

	/* Function name (API): "GetUploadFileHandle".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &pUploadFileHandle).
	 * Return type: Pointer in the "pUploadFileHandle" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "upload" member in the engine's "client" structure. */

	/* Function name (API): "GetUserID".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iUserID).
	 * Return type: Integer in the "iUserID" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "userid" member in the engine's "client" structure. */

	/* Function name (API): "GetUserInfo".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage): (..., iClientID, &pszUserInfoAddress, szUserInfo[], iUserInfoLength).
	 * Return type: Pointer in the "pszUserInfoAddress" variable and string in the "szUserInfo" array.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "userinfo" member in the engine's "client" structure.
	 * Information: This is the user information buffer which contains the user keys and values ("name", "bottom", "topcolor", etc.) of a client. */

	/* Function name (API): "GetViewEntity".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &iViewEntityID).
	 * Return type: Entity ID in the "iViewEntityID" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Get the value of the client's "pViewEntity" member in the engine's "client" structure.
	 * Information: This gets the current view entity ID a client is attached with (as a camera, apache helicopter, etc.). */

	/* Function name (API): "GetVoiceStream".
	 * Function name (real): None (this gets the value of an array).
	 * Format (usage):
	 *   (..., iClientID, iStreamID, &iVoiceStream).
	 *
	 *   Note: The "iStreamID" parameter must be in the 0<->1 range.
	 * Return type: Integer in the "iVoiceStream" variable (0 on failure).
	 * API required (ReHLDS): v2.5.
	 * Description: Get the value of the client's "m_VoiceStreams" member in the engine's "client" structure. */

	/* Function name (API): "HasForceUnmodified".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bHasForceUnmodified).
	 * Return type: Boolean in the "bHasForceUnmodified" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "has_force_unmodified" member in the engine's "client" structure.
	 * Information: This checks if a client has some resources forced to be unmodified (they must match to the server's ones). */

	/* Function name (API): "IsActive".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsActive).
	 * Return type: Boolean in the "bIsActive" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Check the value of the client's "active" member in the engine's "client" structure.
	 * Information: This checks if a client is active. */

	/* Function name (API): "IsClientLagCompensation".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsClientLagCompensation).
	 * Return type: Boolean in the "bIsClientLagCompensation" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "lc" member in the engine's "client" structure. */

	/* Function name (API): "IsClientPredictingWeapons".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsClientPredictingWeapons).
	 * Return type: Boolean in the "bIsClientPredictingWeapons" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "lw" member in the engine's "client" structure.
	 * Information: This checks if a client has the client-side weapon prediction enabled. */

	/* Function name (API): "IsConnected".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsConnected).
	 * Return type: Boolean in the "bIsConnected" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Check the value of the client's "connected" member in the engine's "client" structure.
	 * Information: This checks if a client is connected. */

	/* Function name (API): "IsFakeClient".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsFakeClient).
	 * Return type: Boolean in the "bIsFakeClient" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "fakeclient" member in the engine's "client" structure.
	 * Information: This checks if a client is a bot. */

	/* Function name (API): "IsFullyConnected".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsFullyConnected).
	 * Return type: Boolean in the "bIsFullyConnected" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "fully_connected" member in the engine's "client" structure.
	 * Information: This checks if a client is fully connected. */

	/* Function name (API): "IsHasUserMsgs".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsHasUserMsgs).
	 * Return type: Boolean in the "bIsHasUserMsgs" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "hasusrmsgs" member in the engine's "client" structure.
	 * Information: This checks if a client has received the user messages. */

	/* Function name (API): "IsProxy".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsProxy).
	 * Return type: Boolean in the "bIsProxy" variable.
	 * API required (ReHLDS): v3.8.
	 * Description: Check the value of the client's "proxy" member in the engine's "client" structure.
	 * Information: This checks if a client is a proxy. */

	/* Function name (API): "IsSentNewResponse".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsSentNewResponse).
	 * Return type: Boolean in the "bIsSentNewResponse" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "m_bSentNewResponse" member in the engine's "client" structure. */

	/* Function name (API): "IsSpawned".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsSpawned).
	 * Return type: Boolean in the "bIsSpawned" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Check the value of the client's "spawned" member in the engine's "client" structure.
	 * Information: This checks if a client is spawned. */

	/* Function name (API): "IsUploadDoneRegistering".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsUploadDoneRegistering).
	 * Return type: Boolean in the "bIsUploadDoneRegistering" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "uploaddoneregistering" member in the engine's "client" structure. */

	/* Function name (API): "IsUploading".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., iClientID, &bool:bIsUploading).
	 * Return type: Boolean in the "bIsUploading" variable.
	 * API required (ReHLDS): v3.10.
	 * Description: Check the value of the client's "uploading" member in the engine's "client" structure.
	 * Information: This checks if a client is in "uploading resources process" (in the function "SV_ParseResourceList"). */

	/* Function name (API): "SetActive".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bActive).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Set the value of the client's "active" member in the engine's "client" structure.
	 * Information: This sets if a client is active. */

	/* Function name (API): "SetBottomColor".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, iColor).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "bottomcolor" member in the engine's "client" structure. */

	/* Function name (API): "SetChokeCount".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, iCount).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "chokecount" member in the engine's "client" structure. */

	/* Function name (API): "SetClientLagCompensation".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bIsClientLagCompensation).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "lc" member in the engine's "client" structure. */

	/* Function name (API): "SetClientPredictingWeapons".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bIsClientPredictingWeapons).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "lw" member in the engine's "client" structure.
	 * Information: This checks if a client has the client-side weapon prediction enabled. */

	/* Function name (API): "SetCmdTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flCmdTime).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "cmdtime" member in the engine's "client" structure. */

	/* Function name (API): "SetConnected".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bConnected).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Set the value of the client's "connected" member in the engine's "client" structure.
	 * Information: This sets if a client is connected. */

	/* Function name (API): "SetConnectionStartedTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flConnectionStartedTime).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "connection_started" member in the engine's "client" structure. */

	/* Function name (API): "SetConnectTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flConnectTime).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "connecttime" member in the engine's "client" structure. */

	/* Function name (API): "SetCRC32MapValue".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, iCRC32MapValue).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "crcValue" member in the engine's "client" structure. */

	/* Function name (API): "SetDeltaSequence".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, iDeltaSequence).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "delta_sequence" member in the engine's "client" structure. */

	/* Function name (API): "SetFakeClient".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bFakeClient).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "fakeclient" member in the engine's "client" structure.
	 * Information: This sets if a client is a bot. */

	/* Function name (API): "SetFullyConnected".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bFullyConnected).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "fully_connected" member in the engine's "client" structure.
	 * Information: This sets if a client is fully connected. */

	/* Function name (API): "SetHasForceUnmodified".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bHasForceUnmodified).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "has_force_unmodified" member in the engine's "client" structure.
	 * Information: This sets if a client has some resources forced to be unmodified (they must match to the server's ones). */

	/* Function name (API): "SetHasUserMsgs".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bHasUserMsgs).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "hasusrmsgs" member in the engine's "client" structure.
	 * Information: This sets if a client has received the user messages. */

	/* Function name (API): "SetIgnoreCmdTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flIgnoreCmdTime).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "ignorecmdtime" member in the engine's "client" structure. */

	/* Function name (API): "SetLastCmd".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, pLastCmdAddress).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "lastcmd" member in the engine's "client" structure. */

	/* Function name (API): "SetLastVoiceTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flLastVoiceTime).
	 * Return type: None.
	 * API required (ReHLDS): v2.5.
	 * Description: Set the value of the client's "m_lastvoicetime" member in the engine's "client" structure. */

	/* Function name (API): "SetLatency".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flLatency).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "latency" member in the engine's "client" structure. */

	/* Function name (API): "SetLocalTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flLocalTime).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "localtime" member in the engine's "client" structure. */

	/* Function name (API): "SetNextMessageIntervalTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flNextMessageIntervalTime).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "next_messageinterval" member in the engine's "client" structure. */

	/* Function name (API): "SetNextMessageTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flNextMessageTime).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "next_messagetime" member in the engine's "client" structure. */

	/* Function name (API): "SetPacketLoss".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flPacketLoss).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "packet_loss" member in the engine's "client" structure. */

	/* Function name (API): "SetProxy".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bProxy).
	 * Return type: None.
	 * API required (ReHLDS): v3.8.
	 * Description: Set the value of the client's "proxy" member in the engine's "client" structure.
	 * Information: This sets if a client is a proxy. */

	/* Function name (API): "SetSendInfoState".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bSendInfoState).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "sendinfo" member in the engine's "client" structure. */

	/* Function name (API): "SetSendInfoTime".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flSendInfoTime).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "sendinfo_time" member in the engine's "client" structure. */

	/* Function name (API): "SetSendMessageState".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bSendMessageState).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "send_message" member in the engine's "client" structure. */

	/* Function name (API): "SetSendResourceCount".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, iSendResourceCount).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "m_sendrescount" member in the engine's "client" structure. */

	/* Function name (API): "SetSentNewResponse".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bIsSentNewResponse).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "m_bSentNewResponse" member in the engine's "client" structure. */

	/* Function name (API): "SetSkipMessageState".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bSkipMessageState).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "skip_message" member in the engine's "client" structure. */

	/* Function name (API): "SetSpawned".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bSpawned).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Set the value of the client's "spawned" member in the engine's "client" structure.
	 * Information: This sets if a client has spawned. */

	/* Function name (API): "SetSvTimeBase".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, Float:flSvTimeBase).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "svtimebase" member in the engine's "client" structure. */

	/* Function name (API): "SetTopColor".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, iColor).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "topcolor" member in the engine's "client" structure. */

	/* Function name (API): "SetUploadDoneRegistering".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bUploadDoneRegistering).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "uploaddoneregistering" member in the engine's "client" structure. */

	/* Function name (API): "SetUploadFileHandle".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, pUploadFileHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "upload" member in the engine's "client" structure. */

	/* Function name (API): "SetUploading".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, bool:bUploading).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "uploading" member in the engine's "client" structure.
	 * Information: This sets if a client is in "uploading resources process" (in the function "SV_ParseResourceList"). */

	/* Function name (API): "SetUserID".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, iUserID).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "userid" member in the engine's "client" structure. */

	/* Function name (API): "SetViewEntity".
	 * Function name (real): None (this sets the value of a variable).
	 * Format (usage): (..., iClientID, iViewEntityID).
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "pViewEntity" member in the engine's "client" structure.
	 * Information: This sets the current view entity ID a client is attached with (as a camera, apache helicopter, etc.). */

	/* Function name (API): "SetVoiceStream".
	 * Function name (real): None (this sets the value of an array).
	 * Format (usage):
	 *   (..., iClientID, iStreamID, iVoiceStream).
	 *
	 *   Note: The "iStreamID" parameter must be in the 0<->1 range.
	 * Return type: None.
	 * API required (ReHLDS): v3.10.
	 * Description: Set the value of the client's "m_VoiceStreams" member in the engine's "client" structure. */


	/**************************** GROUP: INetChan ****************************/

	/* Function name (API): "GetMessageBuf".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., pNetChanAddress, &pMsgBufferAddress).
	 * Return type: Pointer in the "pMsgBufferAddress" variable.
	 * API required (ReHLDS): v2.0.
	 * Description: Get the value of the "message" member in the engine's "netchan" structure. */

	/* Function name (API): "GetRemoteAdr".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., pNetChanAddress, &pRemoteAddress).
	 * Return type: Pointer in the "pRemoteAddress" variable.
	 * API required (ReHLDS): v1.0.
	 * Description: Get the value of the "remote_address" member in the engine's "netchan" structure. */


	/**************************************************************************
	*               CALL FUNCTIONS -> GAME -> CS (ReGameDLL_CS)               *
	**************************************************************************/

	/************************* GROUP: IReGameDLLCSAPI ************************/

	/* Function name (API): "BGetICSEntity".
	 * Function name (real): "CReGameApi::BGetICSEntity".
	 * Format (usage): (..., const szVersion[], &bool:bHasICSEntityVersion).
	 * Return type: Boolean in the "bHasICSEntityVersion" variable.
	 * API required (ReGameDLL_CS): v5.11.
	 * Description: Check if the API version of the "ICSEntity" class matches to the one provided. */

	/* Function name (API): "BGetIGameRules".
	 * Function name (real): "CReGameApi::BGetIGameRules".
	 * Format (usage): (..., const szVersion[], &bool:bHasIGameRulesVersion).
	 * Return type: Boolean in the "bHasIGameRulesVersion" variable.
	 * API required (ReGameDLL_CS): v5.11.
	 * Description: Check if the API version of the "IGameRules" class matches to the one provided. */

	/* Function name (API): "GetAmmoInfo".
	 * Function name (real): "AmmoInfo::GetAmmoInfo".
	 * Format (usage): (..., iAmmoTypeID, &pAmmoInfoHandle).
	 * Return type: Pointer in the "pAmmoInfoHandle" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Get the value of an ammunition information structure (AmmoInfo) for a specific ammunition type (via ID).
	 * Information: This gets the value of the structure from the CBasePlayerItem's "m_AmmoInfoArray" member array (specific to ReGameDLL_CS), not from the global array on the standard CS. */

	/* Function name (API): "GetAmmoInfoEx_ID".
	 * Function name (real): "AmmoInfoStruct::GetAmmoInfo".
	 * Format (usage): (..., iAmmoTypeID, &pAmmoInfoStructHandle).
	 * Return type: Pointer in the "pAmmoInfoStructHandle" variable.
	 * API required (ReGameDLL_CS): v5.4.
	 * Description: Get the value of an extended ammunition information structure (AmmoInfoStruct) for a specific ammunition type (via ID). */

	/* Function name (API): "GetAmmoInfoEx_Name".
	 * Function name (real): "AmmoInfoStruct::GetAmmoInfo".
	 * Format (usage): (..., const szAmmoTypeName[], &pAmmoInfoStructHandle).
	 * Return type: Pointer in the "pAmmoInfoStructHandle" variable.
	 * API required (ReGameDLL_CS): v5.4.
	 * Description: Get the value of an extended ammunition information structure (AmmoInfoStruct) for a specific ammunition type (via name). */

	/* Function name (API): "GetGameRules".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pGameRulesHandle).
	 * Return type: Pointer in the "pGameRulesHandle" variable.
	 * API required (ReGameDLL_CS): v2.1.
	 * Description: Get the value of the "g_pGameRules" global variable. */

	/* Function name (API): "GetItemInfo".
	 * Function name (real): "ItemInfo::GetItemInfo".
	 * Format (usage): (..., iInventoryItemTypeID, &pItemInfoHandle).
	 * Return type: Pointer in the "pItemInfoHandle" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Get the value of an item information structure (ItemInfo) for a specific inventory item type (via ID).
	 * Information: This gets the value of the structure from the CBasePlayerItem's "m_ItemInfoArray" member array (specific to ReGameDLL_CS), not from the global array on the standard CS. */

	/* Function name (API): "GetPlayerMove".
	 * Function name (real): None (this gets the value of a variable).
	 * Format (usage): (..., &pPlayerMoveHandle).
	 * Return type: Pointer in the "pPlayerMoveHandle" variable.
	 * API required (ReGameDLL_CS): v2.1.
	 * Description: Get the value of the "pmove" global variable.
	 * Information: This can be used in some "PM_*" functions where the "pPlayerMoveHandle" is not passed as parameter. */

	/* Function name (API): "GetWeaponInfo_ID".
	 * Function name (real): "WeaponInfoStruct::GetWeaponInfo".
	 * Format (usage): (..., iInventoryItemTypeID, &pWeaponInfoStructHandle).
	 * Return type: Pointer in the "pWeaponInfoStructHandle" variable.
	 * API required (ReGameDLL_CS): v2.1.
	 * Description: Get the value of a weapon information structure (WeaponInfoStruct) for a specific inventory item type (via ID). */

	/* Function name (API): "GetWeaponInfo_Name".
	 * Function name (real): "WeaponInfoStruct::GetWeaponInfo".
	 * Format (usage): (..., const szInventoryItemTypeName[], &pWeaponInfoStructHandle).
	 * Return type: Pointer in the "pWeaponInfoStructHandle" variable.
	 * API required (ReGameDLL_CS): v2.1.
	 * Description: Get the value of a weapon information structure (WeaponInfoStruct) for a specific inventory item type (via name). */

	/* Function name (API): "GetWeaponSlot_ID".
	 * Function name (real): "WeaponSlotInfo::GetWeaponSlot".
	 * Format (usage): (..., iInventoryItemTypeID, &pWeaponSlotInfoHandle).
	 * Return type: Pointer in the "pWeaponSlotInfoHandle" variable.
	 * API required (ReGameDLL_CS): v2.1.
	 * Description: Get the value of a weapon slot information structure (WeaponSlotInfo) for a specific inventory item type (via ID). */

	/* Function name (API): "GetWeaponSlot_Name".
	 * Function name (real): "WeaponSlotInfo::GetWeaponSlot".
	 * Format (usage): (..., const szInventoryItemTypeName[], &pWeaponSlotInfoHandle).
	 * Return type: Pointer in the "pWeaponSlotInfoHandle" variable.
	 * API required (ReGameDLL_CS): v2.1.
	 * Description: Get the value of a weapon slot information structure (WeaponSlotInfo) for a specific inventory item type (via name). */


	/************************* GROUP: ReGameDLLCSFuncs ***********************/

	/* Function name (API): "AddAmmoNameToAmmoRegistry".
	 * Function name (real): "AddAmmoNameToAmmoRegistry_api".
	 * Format (usage): (..., const szAmmoName[], &iAmmoID).
	 * Return type: Integer in the "iAmmoID" variable (-1 or ID of the ammunition registered).
	 * API required (ReGameDLL_CS): v5.23.
	 * Description: Add a new ammunition to the list of the existing ones. */

	/* Function name (API): "AddEntityHashValue".
	 * Function name (real): "AddEntityHashValue".
	 * Format (usage):
	 *   (..., iEntityID, const szValue[], iHashType).
	 *
	 *   Note: Specify "0" as "iHashType" parameter for class name type.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description:
	 *   Add an entity to the CS's hashtable (this will allow the game to track it effectively).
	 *
	 *   Note: You do not need to call that function when you use the "CREATE_NAMED_ENTITY" function, since this last automatically adds it to the CS's hashtable. */

	/* Function name (API): "AddMultiDamage".
	 * Function name (real): "AddMultiDamage_api".
	 * Format (usage): (..., iInflictorID, iEntityID, Float:flDamage, iDamageBits).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Specify an entity and some damage values/types to the multidamage accumulator. */

	/* Function name (API): "ApplyMultiDamage".
	 * Function name (real): "ApplyMultiDamage_api".
	 * Format (usage): (..., iInflictorID, iAttackerID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Affect some damage values/types to an entity previously defined by the "AddMultiDamage" function (multidamage accumulator). */

	/* Function name (API): "ClearMultiDamage".
	 * Function name (real): "ClearMultiDamage_api".
	 * Format (usage): (...).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Clear the multidamage accumulator. */

	/* Function name (API): "Cmd_Argc".
	 * Function name (real): "Cmd_Argc_api".
	 * Format (usage): (..., &iArgsNum).
	 * Return type: Integer in the "iArgsNum" variable (number of arguments passed in a command line).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Get the number of arguments from a command line (including the command itself).
	 * Information: Unlike the standard engine functions (something you can call via the "read_arg<v|s|c>" natives from the AMX core), this one has also support for internal commands (autobuy/rebuy and bots). */

	/* Function name (API): "Cmd_Argv".
	 * Function name (real): "Cmd_Argv_api".
	 * Format (usage): (..., iNumber, szArg[], iArgLength).
	 * Return type: String in the "szArg" array (value of the argument).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Get an argument from a command line (including the command itself if the "iNumber" parameter is 0).
	 * Information: Unlike the standard engine functions (something you can call via the "read_arg<v|s|c>" natives from the AMX core), this one has also support for internal commands (autobuy/rebuy and bots). */

	/* Function name (API): "CREATE_NAMED_ENTITY2".
	 * Function name (real): "CREATE_NAMED_ENTITY2".
	 * Format (usage): (..., iszClassName, &iEntityID).
	 * Return type: Entity ID in the "iEntityID" variable.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Create an entity and add it to the CS's hashtable (this will allow the game to track it effectively). */

	/* Function name (API): "CreateWeaponBox".
	 * Function name (real): "CreateWeaponBox_api".
	 * Format (usage): (..., iInventoryItemEntityID, iOwnerID, const szModelPath[], Float:vOrigin[3], Float:vAngles[3], Float:vVelocity[3], Float:flLifetime, bool:bPackAmmo, &iWeaponBoxEntityID).
	 * Return type: Entity ID in the "iWeaponBoxEntityID" variable.
	 * API required (ReGameDLL_CS): v5.23.
	 * Description: Create a weapon box entity (ground entity which stores inventory item(s)). */

	/* Function name (API): "PlantBomb".
	 * Function name (real): "PlantBomb_api".
	 * Format (usage): (..., iOwnerID, Float:vStart[3], Float:vAngles[3], &iC4EntityID).
	 * Return type: Entity ID in the "iC4EntityID" variable.
	 * API required (ReGameDLL_CS): v5.20.
	 * Description: Create a C4 entity (ground bomb grenade). */

	/* Function name (API): "RadiusDamage".
	 * Function name (real): "RadiusDamage_api".
	 * Format (usage):
	 *   (..., const Float:vSource[3], iInflictorID, iAttackerID, Float:flDamage, Float:flRadius, iClassIgnore, iDamageBits).
	 *
	 *   Note: The "flDamage" parameter must be >= 0.0 and the "flRadius" one must be > 0.0 in order to call the function.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Affect damage on a radius area from an origin and entity (inflictor, attacker...). */

	/* Function name (API): "RemoveEntityHashValue".
	 * Function name (real): "RemoveEntityHashValue".
	 * Format (usage):
	 *   (..., iEntityID, const szValue[], iHashType).
	 *
	 *   Note: Specify "0" as "iHashType" parameter for class name type.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Remove an entity from the CS's hashtable (this will allow the game to track it effectively). */

	/* Function name (API): "SpawnGrenade".
	 * Function name (real): "SpawnGrenade_api".
	 * Format (usage):
	 *   (..., iInventoryItemTypeID, iOwnerID, Float:vStart[3], Float:vVelocity[3], Float:flExplodeTime, iTeamID, usEvent, &iGrenadeEntityID).
	 *
	 *   Note: The "flExplodeTime" parameter is not available with a C4 item type, and the "iTeamID" and "useEvent" parameters are not available with a flash and C4 item type, so pass (0.0/0) instead.
	 * Return type: Entity ID in the "iGrenadeEntityID" variable.
	 * API required (ReGameDLL_CS): v5.23.
	 * Description: Create a grenade entity (HE, flash, smoke, C4).
	 * Information: This calls the "CGrenade::Shoot<SatchelCharge|SmokeGrenade|Timed[2]>" functions. */

	/* Function name (API): "SpawnHeadGib".
	 * Function name (real): "SpawnHeadGib_api".
	 * Format (usage): (..., iVictimEntityID, &iGibEntityID).
	 * Return type: Entity ID in the "iGibEntityID" variable.
	 * API required (ReGameDLL_CS): v5.21.
	 * Description: Create a head gib entity. */

	/* Function name (API): "SpawnRandomGibs".
	 * Function name (real): "SpawnRandomGibs_api".
	 * Format (usage): (..., iVictimEntityID, iGibsAmount, iHumanType).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.21.
	 * Description: Create an amount (defined via the parameter "iGibsAmount") of gibs entities. */

	/* Function name (API): "TextureTypePlaySound".
	 * Function name (real): "TextureTypePlaySound_api".
	 * Format (usage): (..., pTraceResultHandle, const Float:vStart[3], const Float:vEnd[3], iBulletType).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.23.
	 * Description: Play a sound based on a trace result simulating a bullet hit (metal, wood, concrete, etc.). */

	/* Function name (API): "UTIL_DecalTrace".
	 * Function name (real): "UTIL_DecalTrace_api".
	 * Format (usage):
	 *   (..., pTraceResultHandle, iDecalNumber).
	 *
	 *   Note: The "iDecalNumber" parameter is a default number among the global decals ("DECAL_*" from filename "decals.h") loaded by the game (range: 0<->41).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.23.
	 * Description: Display a decal on the world or on an entity (BSP models only). */

	/* Function name (API): "UTIL_FindEntityByString".
	 * Function name (real): "UTIL_FindEntityByString".
	 * Format (usage): (..., iStartEntityID, const szType[], const szValue[], &iEntityID).
	 * Return type: Entity ID in the "iEntityID" variable.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Search an entity among all the ones listed in the CS's hashtable.
	 * Informations:
      *   This function can act "a bit illogically", as example, if you put a valid entity ID in the parameter "iStartEntityID" (like 44),
	 *   and if there is no entity found "above that ID" and matching to the "type" and "value", the function will return the latest entity ID matching to your condition (which could be 39 for example). */

	/* Function name (API): "UTIL_Remove".
	 * Function name (real): "UTIL_Remove_api".
	 * Format (usage): (..., iEntityID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.23.
	 * Description: Remove an entity.
	 * Information: This calls the "UTIL_Remove" game function. */

	/* Function name (API): "UTIL_RemoveOther".
	 * Function name (real): "UTIL_RemoveOther_api".
	 * Format (usage):
	 *   (..., const szClassName[], iCount).
	 *
	 *   Note: The "iCount" parameter is available but no longer workable internally, it was originaly there to set up a maximum limit of entities to remove.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Remove all the entities matching to the class name provided.
	 * Information: This calls the "UTIL_Remove" game function. */

	/* Function name (API): "UTIL_ResetEntities".
	 * Function name (real): "UTIL_ResetEntities_api".
	 * Format (usage): (...).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Reset/Remove all the entities of the server (depending of the objects capabilities "FCAP_*", so only when capabilities "FCAP_MUST_RELEASE" or "FCAP_MUST_RESET" are set).
	 * Information: This calls the "UTIL_Remove" or "C*::Restart" game functions. */

	/* Function name (API): "UTIL_RestartOther".
	 * Function name (real): "UTIL_RestartOther_api".
	 * Format (usage): (..., const szClassName[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Reset all the entities matching to the class name provided.
	 * Information: This calls the "C*::Restart" and "FireTargets" game functions. */


	/*************************** GROUP: CCSEntity ****************************/

	/* Function name (API): "FireBuckshots".
	 * Function name (real): "CCSEntity::FireBuckshots". It is a custom function specific to ReGameDLL_CS.
	 * Format (usage): (..., iEntityID, iShots, Float:vSource[3], Float:vDirShooting[3], Float:vSpread[3], Float:flDistance, iTracerFreq, iDamage, iAttackerID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.21.
	 * Description: Fire bullets from an entity and for an usage with a shotgun (this is a replica of the following "CCSEntity::FireBullets", except the code for the damage has been modified to handle the damage provided rather than a hardcoded value of "20", but the devs could have modified the "FireBullets" one instead). */

	/* Function name (API): "FireBullets".
	 * Function name (real): "CCSEntity::FireBullets".
	 * Format (usage): (..., iEntityID, iShots, Float:vSource[3], Float:vDirShooting[3], Float:vSpread[3], Float:flDistance, iBulletType, iTracerFreq, iDamage, iAttackerID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Fire bullets from an entity (classic version currently only used by "func_tank" entities in the ReGameDLL_CS binary, but also used for the Shotguns in the standard CS binary). */

	/* Function name (API): "FireBullets3".
	 * Function name (real): "CCSEntity::FireBullets3".
	 * Format (usage): (..., iEntityID, Float:vSource[3], Float:vDirShooting[3], Float:flSpread, Float:flDistance, iPenetration, iBulletType, iDamage, Float:flRangeModifier, iAttackerID, bool:bPistol, iSharedRandom, Float:vDirection[3]).
	 * Return type: Vector in the "vDirection" array.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Fire bullets from an entity (enhanced version with "basic" penetration power system, etc., used by all the CS's inventory weapons except shotguns). */


	/*************************** GROUP: CCSPlayer ****************************/

	/* Function name (API): "AddAccount".
	 * Function name (real): "CCSPlayer::AddAccount".
	 * Format (usage):
	 *   (..., iClientID, iAmount, RewardType:iRewardType = RT_NONE, bool:bTrackChange).
	 *
	 *   Note: The "iRewardType" parameter is a "RT_*" from "reapi_const.inc" (above).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Add/Remove account (money) to/from a client. */

	/* Function name (API): "ClientCommand".
	 * Function name (real): "CCSPlayer::ClientCommand".
	 * Format (usage): (..., iClientID, const szCommand[], const szArg1[], const szArg2[], const szArg3[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Execute an internal command to a client.
	 * Informations:
	 *   You can use all the commands internally registered in the game's code (function "InternalCommand" in "client.cpp").
	 *   List below:
	 *     "say", "say_team". Note: Do not work properly, so do not use for that, instead, use the "engclient_cmd" native from the AMX core.
	 *     "fullupdate"
	 *     "vote", "votemap"
	 *     "listmaps"
	 *     "timeleft"
	 *     "listplayers"
	 *     "client_buy_open", "client_buy_close"
	 *     "menuselect"
	 *     "chooseteam"
	 *     "showbriefing"
	 *     "ignoremsg", "ignorerad"
	 *     "become_vip"
	 *     "spectate", "specmode", "spec_set_ad", "follownext", "follow"
	 *     "cl_setautobuy", "cl_setrebuy", "cl_autobuy", "cl_rebuy"
	 *     "jointeam", "joinclass"
	 *     "nightvision"
	 *     "radio1", "radio2", "radio3", "smartradio"
	 *     "drop"
	 *     "fov"
	 *     "use", "weapon_*", "lastinv"
	 *     "give"
	 *     "buy", "buyequip", "buyammo1", "buyammo2" */

	/* Function name (API): "Disappear".
	 * Function name (real): "CCSPlayer::Disappear".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Make a client "disappears" (used for a VIP who reaches the goal). */

	/* Function name (API): "DropPlayerItem".
	 * Function name (real): "CCSPlayer::DropPlayerItem".
	 * Format (usage):
	 *   (..., iClientID, const szItemName[], &iWeaponBoxEntityID).
	 *
	 *   Note: If in case the "szItemName" parameter is empty, this will drop the current item the client is holding.
	 * Return type: Entity ID in the "iWeaponBoxEntityID" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Drop an inventory item of a client. */

	/* Function name (API): "DropPrimary".
	 * Function name (real): "CCSPlayer::DropPrimary".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description:
	 *   Drop all the primary inventory items of a client (the ones in the slot #1).
	 *
	 *   Note: The standard CS binary only drops the first inventory item in the slot, while on ReGameDLL_CS, all of them are dropped (fix). */

	/* Function name (API): "DropSecondary".
	 * Function name (real): "CCSPlayer::DropSecondary".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description:
	 *   Drop all the secondary inventory items of a client (the ones in the slot #2).
	 *
	 *   Note: The standard CS binary only drops the first inventory item in the slot, while on ReGameDLL_CS, all of them are dropped (fix). */

	/* Function name (API): "DropShield".
	 * Function name (real): "CCSPlayer::DropShield".
	 * Format (usage): (..., iClientID, bool:bDeploy, &iShieldEntityID).
	 * Return type: Entity ID in the "iShieldEntityID" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Drop the shield of a client. */

	/* Function name (API): "EntSelectSpawnPoint".
	 * Function name (real): "CCSPlayer::EntSelectSpawnPoint".
	 * Format (usage): (..., iClientID, &iSpawnEntityID).
	 * Return type: Entity ID in the "iSpawnEntityID" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Select a spawn point to use for make respawn a client.
	 * Information: This is the internal function used in the "CGameRules::GetPlayerSpawnSpot". */

	/* Function name (API): "GetItemById".
	 * Function name (real): "CCSPlayer::GetItemById".
	 * Format (usage): (..., iClientID, iInventoryItemTypeID, &iInventoryItemEntityID).
	 * Return type: Entity ID in the "iInventoryItemEntityID" variable.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Get the inventory item entity ID of a client (by type ID). */

	/* Function name (API): "GetItemByName".
	 * Function name (real): "CCSPlayer::GetItemByName".
	 * Format (usage): (..., iClientID, const szInventoryItemClassName[], &iInventoryItemEntityID).
	 * Return type: Entity ID in the "iInventoryItemEntityID" variable.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Get the inventory item entity ID of a client (by class name, so by type indirectly). */

	/* Function name (API): "GiveDefaultItems".
	 * Function name (real): "CCSPlayer::GiveDefaultItems".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Remove the current inventory items of a client (by calling the "CBasePlayer::RemoveAllItems" function), then give to him all the default inventory items he should have when he respawns. */

	/* Function name (API): "GiveNamedItem".
	 * Function name (real): "CCSPlayer::GiveNamedItem".
	 * Format (usage): (..., iClientID, const szItemName[], &iItemEntityID).
	 * Return type: Entity ID in the "iItemEntityID" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Create then give an item to a client.
	 * Information: This is the basic version which just calls the standard code of the "CBasePlayer::GiveNamedItem" function, use the following "*Ex" version for more possibilities. */

	/* Function name (API): "GiveNamedItemEx".
	 * Function name (real): "CCSPlayer::GiveNamedItemEx".
	 * Format (usage): (..., iClientID, const szItemName[], &iItemEntityID).
	 * Return type: Entity ID in the "iItemEntityID" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Create then give an item to a client.
	 * Information: This is the extended version of the previous "GiveNamedItem" one, which now includes a special support for the shield and C4, and can also removes the entity when this last failed to be linked to the owner. */

	/* Function name (API): "GiveShield".
	 * Function name (real): "CCSPlayer::GiveShield".
	 * Format (usage): (..., iClientID, bool:bDeploy).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Give a shield to a client. */

	/* Function name (API): "HasNamedPlayerItem".
	 * Function name (real): "CCSPlayer::HasNamedPlayerItem".
	 * Format (usage): (..., iClientID, const szInventoryItemClassName[], &bool:bHasInventoryItem).
	 * Return type: Boolean in the "bHasInventoryItem" variable (false when he has not, true when he has).
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Check if a client has the inventory item specified (by class name, so by type indirectly). */

	/* Function name (API): "HasPlayerItem".
	 * Function name (real): "CCSPlayer::HasPlayerItem".
	 * Format (usage): (..., iClientID, iInventoryItemEntityID, &bool:bHasInventoryItem).
	 * Return type: Boolean in the "bHasInventoryItem" variable (false when he has not, true when he has).
	 * API required (ReGameDLL_CS): v4.2.
	 * Description:
	 *   Check if a client has the inventory item specified (by entity ID).
	 *   But this basically checks for the class name of it, in order to know if has "the type of that item". */

	/* Function name (API): "HintMessageEx".
	 * Function name (real): "CCSPlayer::HintMessageEx".
	 * Format (usage): (..., iClientID, const szMessage[], Float:flDuration, bool:bDisplayIfPlayerDead, bool:bOverride, &bool:bResult).
	 * Return type: Boolean in the "bResult" variable (false when "bDisplayIfPlayerDead" is false and the client is dead, however, true).
	 * API required (ReGameDLL_CS): v5.9.
	 * Description: Display a hint message to a client (DHUD type). */

	/* Function name (API): "IsConnected".
	 * Function name (real): "CCSPlayer::IsConnected".
	 * Format (usage): (..., iClientID, &bool:bIsConnected).
	 * Return type: Boolean in the "bIsConnected" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Check if a client is connected. */

	/* Function name (API): "JoinTeam".
	 * Function name (real): "CCSPlayer::JoinTeam".
	 * Format (usage): (..., iClientID, iTeamID, &bool:bResult).
	 * Return type: Boolean in the "bResult" variable (false when the "iTeamID" parameter is set to 3 [SPECTATOR] and the client already is in, however, true).
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Make a client joins a team.
	 * Information: This is an advanced code that handles many features from the game in order to avoid bugs, except that the C4 is not dropped (but removed) when you move the client to the spectators. */

	/* Function name (API): "MakeBomber".
	 * Function name (real): "CCSPlayer::MakeBomber".
	 * Format (usage): (..., iClientID, &bool:bResult).
	 * Return type: Boolean in the "bResult" variable (false when he can not receive the C4, however, true).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Make a client becomes a bomber carrier! */

	/* Function name (API): "MakeVIP".
	 * Function name (real): "CCSPlayer::MakeVIP".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Make a client becomes the VIP. */

	/* Function name (API): "Observer_SetMode".
	 * Function name (real): "CCSPlayer::Observer_SetMode".
	 * Format (usage): (..., iClientID, iMode).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set the observer mode to a client. */

	/* Function name (API): "OnSpawnEquip".
	 * Function name (real): "CCSPlayer::OnSpawnEquip".
	 * Format (usage): (..., iClientID, bool:bAddDefault, bool:bEquipGame).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Equip a client with inventory items allowed by the game (depending on map or game settings). */

	/* Function name (API): "ReloadWeapons".
	 * Function name (real): "CCSPlayer::ReloadWeapons".
	 * Format (usage):
	 *   (..., iClientID, iInventoryItemEntityID, bool:bForceReload, bool:bForceRefill).
	 *
	 *   Notes:
	 *     The "iInventoryItemEntityID" can be set to -1 in order to reload all the inventory items of a client.
	 *     When the both "bForceReload" and "bForceRefill" parameters are set to false, nothing will be reloaded (internal code to reload not executed),
	 *     except when at least one of the related CVars (mp_auto_reload_weapons, mp_refill_bpammo_weapons) is enabled.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Reload one or all the inventory items of a client. */

	/* Function name (API): "RemoveAllItems".
	 * Function name (real): "CCSPlayer::RemoveAllItems".
	 * Format (usage):
	 *   (..., iClientID, bool:bRemoveSuit).
	 *
	 *   Notes:
	 *     The "bRemoveSuit" parameter is to remove the suit (this will clean up the HUD elements like health, armor, etc., then block a few things after).
	 *     It is usually not recommended to set it to true.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Remove all the items of a client. */

	/* Function name (API): "RemovePlayerItem".
	 * Function name (real): "CCSPlayer::RemovePlayerItem".
	 * Format (usage): (..., iClientID, const szItemName[], &bool:bHasRemoved).
	 * Return type: Boolean in the "bHasRemoved" variable (false on failure, true on success).
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Remove a specifc item from a client.
	 * Informations:
	 *   The internal function uses its own code in order to support extras items that are not in the client's inventory.
	 *   List below:
	 *     item_kevlar
	 *     item_assaultsuit
	 *     item_thighpack
	 *     item_longjump
	 *   It also supports the shield (the code will call the "CCSPlayer::RemoveShield" function), and also has a proper support for the C4. */

	/* Function name (API): "RemovePlayerItemEx".
	 * Function name (real): "CCSPlayer::RemovePlayerItemEx".
	 * Format (usage): (..., iClientID, const szItemName[], bool:bRemoveAmmo, &bool:bHasRemoved).
	 * Return type: Boolean in the "bHasRemoved" variable (false on failure, true on success).
	 * API required (ReGameDLL_CS): v5.6.
	 * Description: Remove a specifc item from a client.
	 * Informations:
	 *   The internal function uses its own code in order to support extras items that are not in the client's inventory.
	 *   List below:
	 *     item_kevlar
	 *     item_assaultsuit
	 *     item_thighpack
	 *     item_longjump
	 *   It also supports the shield (the code will call the "CCSPlayer::RemoveShield" function), and also has a proper support for the C4.
	 *
	 *   This is the extended version of the previous "RemovePlayerItem" one, the only new feature is the "bRemoveAmmo" parameter.
	 *   But keep in mind if you have this parameter enabled and the client has multiple weapons sharing that same ammunition type, this will also remove ammunitions for those other weapons.
	 *   As example, the client has the AK-47 and the G3SG1 which both use the 7.62 NATO ammunition type, you only remove the AK-47, the G3SG1 will no longer have backpack ammunitions. */

	/* Function name (API): "RemoveShield".
	 * Function name (real): "CCSPlayer::RemoveShield".
	 * Format (usage): (..., iClientID, &bool:bHasRemoved).
	 * Return type: Boolean in the "bHasRemoved" variable (false on failure, true on success).
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Remove the shield from a client (Captain is angry! Captain is angry!). */

	/* Function name (API): "RemoveSpawnProtection".
	 * Function name (real): "CCSPlayer::RemoveSpawnProtection".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.7.
	 * Description: Remove the spawn protection from a client. */

	/* Function name (API): "Reset".
	 * Function name (real): "CCSPlayer::Reset".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Reset some datas (score, money, inventory items, etc.) of a client.
	 * Information: This is called by the game rules when the round is restarted. */

	/* Function name (API): "ResetSequenceInfo".
	 * Function name (real): "CCSPlayer::ResetSequenceInfo".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.2.
	 * Description: Reset the sequence informations of a client. */

	/* Function name (API): "SelectSpawnSpot".
	 * Function name (real): "CCSPlayer::SelectSpawnSpot".
	 * Format (usage):
	 *   (..., iClientID, const szClassName[], &iSpawnEntityID, &bool:bFound).
	 *
	 *   Note: Returns in the "iSpawnEntityID" variable the spawn entity found (-1 when not found).
	 * Return type: Boolean in the "bFound" variable.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Select a spawn point to use for make respawn a client (the code performs some checks about the validity of a spawn, including a damage/kill to other clients "stuck with" who may prevent the proper respawn of the client).
	 * Information: This is the internal function used in the "CBasePlayer::EntSelectSpawnPoint". */

	/* Function name (API): "SendItemStatus".
	 * Function name (real): "CCSPlayer::SendItemStatus".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set/Unset the item status of a client (this only works for defuse kit and NVG goggles). */

	/* Function name (API): "SetAnimation".
	 * Function name (real): "CCSPlayer::SetAnimation".
	 * Format (usage):
	 *   (..., iClientID, CS_PLAYER_ANIM:iAnimationType).
	 *
	 *   Note: The "iAnimationType" parameter is a "CS_PLAYER_*" from "reapi_const.inc" (above).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Play a "player animation" for a client. */

	/* Function name (API): "SetBombIcon".
	 * Function name (real): "CCSPlayer::SetBombIcon".
	 * Format (usage): (..., iClientID, bool:bFlash).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set/Unset the bomb icon on the left side of the client's screen. */

	/* Function name (API): "SetNewPlayerModel".
	 * Function name (real): "CCSPlayer::SetNewPlayerModel".
	 * Format (usage): (..., iClientID, const szModelPath[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set a model to a client by using the "pfnSetModel" engine API function, and by setting an internal member related to the model ID.
	 * Information: The model must be precached or the server will crash. */

	/* Function name (API): "SetPlayerModel".
	 * Function name (real): "CCSPlayer::SetPlayerModel".
	 * Format (usage):
	 *   (..., iClientID, bool:bHasC4).
	 *
	 *   Note: The "bHasC4" parameter is not used by the function.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set a model to a client. */

	/* Function name (API): "SetPlayerModelEx".
	 * Function name (real): "CCSPlayer::SetPlayerModelEx".
	 * Format (usage): (..., iClientID, const szModelName[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set a custom model to a client.
	 * Information: This simply alters an internal member (CCSPlayer's "m_szModel") related to the current model the client is using, and will force it until it is reset (on complete round restart). */

	/* Function name (API): "SetProgressBarTime".
	 * Function name (real): "CCSPlayer::SetProgressBarTime".
	 * Format (usage): (..., iClientID, iTime).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set a progress bar to a client (and to all his observers), with a specific duration.
	 * Information: This is the bar you see when you plant/defuse the C4. */

	/* Function name (API): "SetProgressBarTime2".
	 * Function name (real): "CCSPlayer::SetProgressBarTime2".
	 * Format (usage): (..., iClientID, iTime, Float:flTimeElapsed).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set a progress bar to a client (and to all his observers), with a specific duration.
	 * Information: This is the bar you see when you plant/defuse the C4, but this version is extended with time elapsed support. */

	/* Function name (API): "SetScoreAttrib".
	 * Function name (real): "CCSPlayer::SetScoreAttrib".
	 * Format (usage):
	 *   (..., iClientID, iDestID).
	 *
	 *   Note: The "iDestID" parameter must be a valid client (HLTV/human).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Set/Unset the score attribution properties linked to a client (those are the "DEAD", "BOMB", "VIP", "DEFKIT" tags visible on the scoreboard).
	 * Information: This is the function internally used by the following "SetScoreboardAttributes" function. */

	/* Function name (API): "SetScoreboardAttributes".
	 * Function name (real): "CCSPlayer::SetScoreboardAttributes".
	 * Format (usage):
	 *   (..., iClientID, iDestID = -1).
	 *
	 *   Note: Specify a client to target as "iDestID" parameter, or "-1" to target all the clients (that the games usually does).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Update the scoreboard attributes of a client or all the clients.
	 * Information: This calls the previous "SetScoreAttrib" function. */

	/* Function name (API): "SetSpawnProtection".
	 * Function name (real): "CCSPlayer::SetSpawnProtection".
	 * Format (usage): (..., iClientID, Float:flProtectionTime).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.7.
	 * Description: Set the spawn protection to a client. */

	/* Function name (API): "StartDeathCam".
	 * Function name (real): "CCSPlayer::StartDeathCam".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.4.
	 * Description: Associate a client with the "death camera". */

	/* Function name (API): "StartObserver".
	 * Function name (real): "CCSPlayer::StartObserver".
	 * Format (usage): (..., iClientID, Float:vPosition[3], Float:vViewAngles[3]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Start the observer (spectator) mode for a client. */

	/* Function name (API): "SwitchTeam".
	 * Function name (real): "CCSPlayer::SwitchTeam".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Switch a client to the opposite team.
	 * Information: This function is called by the game when it automatically balances the teams, or, on escape maps when all clients are swapped. */

	/* Function name (API): "SwitchWeapon".
	 * Function name (real): "CCSPlayer::SwitchWeapon".
	 * Format (usage): (..., iClientID, iInventoryItemEntityID, &bool:bResult).
	 * Return type: Boolean in the "bResult" variable (false when can not be deployed, however, true).
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Switch the inventory item of a client. */

	/* Function name (API): "TeamChangeUpdate".
	 * Function name (real): "CCSPlayer::TeamChangeUpdate".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v4.2.
	 * Description: Performs a team change update to a client.
	 * Information: This updates the scoreboard according to the current team and the properties of a client. */


	/************************* GROUP: CCSPlayerItem **************************/

	/* Function name (API): "GetItemInfo".
	 * Function name (real): "CCSPlayerItem::GetItemInfo".
	 * Format (usage):
	 *   (..., iInventoryItemEntityID, pItemInfoHandle, &iResult).
	 *
	 *   Note: Specify "0" as "pItemInfoHandle" parameter in order to use the global one of the module.
	 * Return type: Integer in the "iResult" variable (always 1).
	 * API required (ReGameDLL_CS): v5.14.
	 * Description: Copy the values of an item information structure (ItemInfo) of a specific inventory item item (via entity ID).
	 * Information: Once called, the "pItemInfoHandle" variable will contain the values of the CCSPlayerItem's "m_ItemInfo" structure member of the entity ID. */

	/* Function name (API): "SetItemInfo".
	 * Function name (real): "CCSPlayerItem::SetItemInfo".
	 * Format (usage):
	 *    (..., iInventoryItemEntityID, pItemInfoHandle).
	 *
	 *   Note: Specify "0" as "pItemInfoHandle" parameter in order to use the global one of the module.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.4.
	 * Description: Copy the values of an item information structure (ItemInfo) to a specific inventory item (via entity ID).
	 * Information: Once called, the CCSPlayerItem's "m_ItemInfo" structure member of the entity ID will contain the values of the "pItemInfoHandle" variable. */


	/************************* GROUP: CCSPlayerWeapon ************************/

	/* Function name (API): "DefaultDeploy".
	 * Function name (real): "CCSPlayerWeapon::DefaultDeploy".
	 * Format (usage):
	 *   (..., iWeaponEntityID, const szViewModel[], const szWeaponModel[], iAnimationType, const szAnimationExtention[], iSkiplocal, &iResult).
	 *
	 *   Note: The "iSkipLocal" variable is to skip the animation playing in case of the client has prediction (setinfo "cl_lw") enabled.
	 * Return type: Integer in the "iResult" variable (0 when unable to be deployed, 1 on success).
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Deploy a weapon of a client. */

	/* Function name (API): "DefaultReload".
	 * Function name (real): "CCSPlayerWeapon::DefaultReload".
	 * Format (usage): (..., iWeaponEntityID, iClipSize, iAnimationType, Float:flDelay, &iResult).
	 * Return type: Integer in the "iResult" variable (0 when unable to reload, 1 on success).
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Reload a weapon (all except shotguns) of a client. */

	/* Function name (API): "DefaultShotgunReload".
	 * Function name (real): "CCSPlayerWeapon::DefaultShotgunReload".
	 * Format (usage): (..., iWeaponEntityID, iAnimationType, iStartAnimationType, Float:flDelay, Float:flStartDelay, const szReloadSound1[], const szReloadSound2[], &bool:bResult).
	 * Return type: Boolean in the "bResult" variable (false when unable to reload, true on success).
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Reload a weapon (only shotgun) of a client. */

	/* Function name (API): "KickBack".
	 * Function name (real): "CCSPlayerWeapon::KickBack".
	 * Format (usage): (..., iWeaponEntityID, Float:flUpBase, Float:flLateralBase, Float:flUpModifier, Float:flLateralModifier, Float:flUpMax, Float:flLateralMax, iDirectionChange).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Process a kick back effect on the client owning the weapon (this changes the crosshair position, done after shooting). */

	/* Function name (API): "SendWeaponAnim".
	 * Function name (real): "CCSPlayerWeapon::SendWeaponAnim".
	 * Format (usage):
	 *   (..., iWeaponEntityID, iAnimationType, iSkipLocal).
	 *
	 *   Note: The "iSkipLocal" variable is to skip the animation playing in case of the client has prediction (setinfo "cl_lw") enabled.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Play an animation (deploy, shooting, reloading, etc.) on a weapon of a client. */


	/**************************************************************************
	*              CALL FUNCTIONS -> Metamod's module -> Reunion              *
	**************************************************************************/

	/************************** GROUP: IReunionAPI ***************************/

	/* Function name (API): "GetAuthKeyKind".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, &reu_authkey_kind:iAuthIDKeyType).
	 * Return type: Integer in the "iAuthIDType" variable (a REU_AK_* from "reapi_const.inc" (above)).
	 * API required (Reunion): v1.4.
	 * Description: Get the AuthID key type of a client. */

	/* Function name (API): "GetClientAuthData".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, szData[], iDataLength, &iSize).
	 * Return type: Integer in the "iSize" variable.
	 * API required (Reunion): v1.1.
	 * Description: Get the AuthID data of a client (in number of bytes). */

	/* Function name (API): "GetClientAuthDataString".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, szData[], iDataLength, szResult[], iResultLength).
	 * Return type: String in the "szResult" array.
	 * API required (Reunion): v1.1.
	 * Description: Get the AuthID data of a client (in a string). */

	/* Function name (API): "GetClientAuthType".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, &dp_authkind_e:iAuthIDType).
	 * Return type: Integer in the "iAuthIDType" variable (a DP_AUTH_* from "reapi_const.inc" (above)).
	 * API required (Reunion): v1.1.
	 * Description: Get the AuthID type of a client. */

	/* Function name (API): "GetClientProtocol".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, &iProtocolID).
	 * Return type: Integer in the "iProtocolID" variable.
	 * API required (Reunion): v1.1.
	 * Description: Get the protocol of a client. */

	/* Function name (API): "GetDisplaySteamId".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, &iDisplaySteamID).
	 * Return type: Integer in the "iDisplaySteamID" variable.
	 * API required (Reunion): v1.4.
	 * Description: Get the display Steam ID of a client. */

	/* Function name (API): "GetLongAuthId".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, szAuthID[], iAuthIDLength).
	 * Return type: String in the "szAuthID" array.
	 * API required (Reunion): v1.4.
	 * Description: Get the "long" AuthID of a client. */

	/* Function name (API): "GetSerializedId".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, &pSerializedIDAddress).
	 * Return type: Pointer in the "pSerializedIDAddress" variable.
	 * API required (Reunion): v1.4.
	 * Description: Get the address of the client's serialized ID. */

	/* Function name (API): "GetStorageId".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, &pGetStorageIDAddress).
	 * Return type: Pointer in the "pGetStorageIDAddress" variable.
	 * API required (Reunion): v1.4.
	 * Description: Get the address of the client's storage ID. */

	/* Function name (API): "SetConnectTime".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, Float:flTime).
	 * Return type: None.
	 * API required (Reunion): v1.4.
	 * Description: Set the connect time of a client. */


	/**************************************************************************
	*             CALL FUNCTIONS -> Metamod's module -> ReChecker             *
	**************************************************************************/

	/************************* GROUP: ReCheckerFuncs *************************/

	/* Function name (API): "AddQueryFile".
	 * Function name (real): Unknown (no source code).
	 * Format (usage):
	 *   (..., const szFilename[], ResourceType_e:iResourceType, uiHash, const szCallback[], iUniqueID, &pIResourceBufferHandle).
	 *
	 *   Note: The "iResourceType" parameter is a RES_TYPE_* from "reapi_const.inc" (above).
	 * Return type: Pointer in the "pIResourceBufferHandle" variable.
	 * API required (ReChecker): v2.1.
	 * Description: None.
	 * Information: Function not implemented in the module (I need to implement a callback system I have not coded). */

	/* Function name (API): "AddResource".
	 * Function name (real): Unknown (no source code).
	 * Format (usage):
	 *   (..., const szFilename[], const szCommandToExec[], ResourceType_e:iResourceType, uiHash, bool:bBreak, &pIResourceBufferHandle).
	 *
	 *   Note: The "iResourceType" parameter is a RES_TYPE_* from "reapi_const.inc" (above).
	 * Return type: Pointer in the "pIResourceBufferHandle" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Add a resource filename to the list of the ones to check.
	 * Information: Use the return value with the following functions of the ReChecker's "IResourceBuffer" group. */

	/* Function name (API): "ClearQueryFiles".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (...).
	 * Return type: None.
	 * API required (ReChecker): v2.1.
	 * Description: Remove all the files queried. */

	/* Function name (API): "FindResource".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., const szFilename[], &pIResourceBufferHandle).
	 * Return type: Pointer in the "pIResourceBufferHandle" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Find a resource via filename.
	 * Information: Use the return value with the following functions of the ReChecker's "IResourceBuffer" group. */

	/* Function name (API): "GetResource".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., &pIResourceFileHandle).
	 * Return type: Pointer in the "pIResourceFileHandle" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the value (handle) of a resource file.
	 * Information: Use the return value with the following functions of the ReChecker's "IResourceFile" group. */

	/* Function name (API): "GetResponseFile".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, const szFilename[], &pIResponseBufferHandle).
	 * Return type: Pointer in the "pIResponseBufferHandle" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the value (handle) of a response buffer.
	 * Information: Use the return value with the following functions of the ReChecker's "IResponseBuffer" group. */

	/* Function name (API): "IsResourceExists".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iClientID, const szFilename[], &uiHash, &bool:bIsResourceExists).
	 * Return type: Boolean in the "bIsResourceExists" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Check if a resource filename exists. */

	/* Function name (API): "RemoveQueryFile".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., iUniqueID).
	 * Return type: None.
	 * API required (ReChecker): v2.1.
	 * Description: Remove a file queried (via unique ID). */


	/************************ GROUP: IResourceBuffer *************************/

	/* Function name (API): "GetCmdExec".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceBufferHandle, szCommandToExec[], iCommandToExecLength).
	 * Return type: String in the "szCommandToExec" array.
	 * API required (ReChecker): v2.1.
	 * Description: Get the command to execute linked to a resource file. */

	/* Function name (API): "GetFileFlag".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceBufferHandle, &ResourceType_e:iResourceType).
	 * Return type: Integer in the "iResourceType" variable (which is a RES_TYPE_* from "reapi_const.inc" [above]).
	 * API required (ReChecker): v2.1.
	 * Description: Get the resource type of a resource file. */

	/* Function name (API): "GetFileHash".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceBufferHandle, &iFileHash).
	 * Return type: Integer in the "iFileHash" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the hash of a resource file. */

	/* Function name (API): "GetFilename".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceBufferHandle, szFilename[], iFilenameLength).
	 * Return type: String in the "szFilename" array.
	 * API required (ReChecker): v2.1.
	 * Description: Get the filename of a resource file. */

	/* Function name (API): "GetLine".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceBufferHandle, &iLine).
	 * Return type: Integer in the "iLine" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the line of a resource file (probably the size in bytes, I guess). */

	/* Function name (API): "IsAddEx".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceBufferHandle, &bool:bIsAddEx).
	 * Return type: Boolean in the "bIsAddEx" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Check if a resource file has been added via API (externally, like via this module). */

	/* Function name (API): "IsBreak".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceBufferHandle, &bool:bIsBreak).
	 * Return type: Boolean in the "bIsBreak" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Check if a resource file is "break" (next files not checked). */

	/* Function name (API): "IsDuplicate".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceBufferHandle, &bool:bIsDuplicate).
	 * Return type: Boolean in the "bIsDuplicate" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Check if a resource file is duplicated (already in the list). */


	/************************ GROUP: IResponseBuffer *************************/

	/* Function name (API): "GetClientHash".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResponseBufferHandle, &iClientHash).
	 * Return type: Integer in the "iClientHash" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the current client hash linked to a resource file checked. */

	/* Function name (API): "GetFilename".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResponseBufferHandle, szFilename[], iFilenameLength).
	 * Return type: String in the "szFilename" array.
	 * API required (ReChecker): v2.1.
	 * Description: Get the filename linked to a resource file checked. */

	/* Function name (API): "GetGameClient".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResponseBufferHandle, &iClientID).
	 * Return type: Integer in the "iClientID" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the ID of a client linked to a resource file checked. */

	/* Function name (API): "GetPrevHash".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResponseBufferHandle, &iPrevHash).
	 * Return type: Integer in the "iPrevHash" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the previous client hash linked to a resource file checked. */

	/* Function name (API): "GetUserID".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResponseBufferHandle, &iUserID).
	 * Return type: Integer in the "iUserID" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the UserID of a client linked to a resource file checked. */


	/************************* GROUP: IResourceFile **************************/

	/* Function name (API): "FindFilenameOfHash".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceFileHandle, uiHash, szFilename[], iFilenameLength).
	 * Return type: String in the "szFilename" array.
	 * API required (ReChecker): v2.1.
	 * Description: Get the filename of a resource file. */

	/* Function name (API): "GetConsistencyNum".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceFileHandle, &iConsistencyNum).
	 * Return type: Integer in the "iConsistencyNum" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the number of consistency files. */

	/* Function name (API): "GetPrevHash".
	 * Function name (real): Unknown (no source code).
	 * Format (usage): (..., pIResourceFileHandle, &iPrevHash).
	 * Return type: Integer in the "iPrevHash" variable.
	 * API required (ReChecker): v2.1.
	 * Description: Get the previous hash. */


	/**************************************************************************
	*                CALL FUNCTIONS -> Metamod's module -> VTC                *
	**************************************************************************/

	/********************** GROUP: IVoiceTranscoderAPI ***********************/

	/* Function name (API): "BlockClient".
	 * Function name (real): "VoiceTranscoderAPI::BlockClient".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (VTC): v3.1.
	 * Description: Block a client (voice).
	 * Information: This basically refuses the function "SV_ParseVoiceData" for the client. */

	/* Function name (API): "IsClientBlocked".
	 * Function name (real): "VoiceTranscoderAPI::IsClientBlocked".
	 * Format (usage): (..., iClientID, &bool:bIsClientBlocked).
	 * Return type: Boolean in the "bIsClientBlocked" variable.
	 * API required (VTC): v3.1.
	 * Description: Check if a client is blocked. */

	/* Function name (API): "IsClientMuted".
	 * Function name (real): "VoiceTranscoderAPI::IsClientMuted".
	 * Format (usage): (..., iClientID, &bool:bIsClientMuted).
	 * Return type: Boolean in the "bIsClientMuted" variable.
	 * API required (VTC): v2.1.
	 * Description: Check if a client is muted (voice). */

	/* Function name (API): "IsClientSpeaking".
	 * Function name (real): "VoiceTranscoderAPI::IsClientSpeaking".
	 * Format (usage): (..., iClientID, &bool:bIsClientSpeaking).
	 * Return type: Boolean in the "bIsClientSpeaking" variable.
	 * API required (VTC): v2.1.
	 * Description: Check if a client is speaking. */

	/* Function name (API): "MuteClient".
	 * Function name (real): "VoiceTranscoderAPI::MuteClient".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (VTC): v2.1.
	 * Description: Mute a client (voice). */

	/* Function name (API): "PlaySound".
	 * Function name (real): "VoiceTranscoderAPI::PlaySound".
	 * Format (usage): (..., iClientID, const szSample[]).
	 * Return type: None.
	 * API required (VTC): v2.1.
	 * Description: Play a sound to a client. */

	/* Function name (API): "UnblockClient".
	 * Function name (real): "VoiceTranscoderAPI::UnblockClient".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (VTC): v3.1.
	 * Description: Unblock a client (voice). */

	/* Function name (API): "UnmuteClient".
	 * Function name (real): "VoiceTranscoderAPI::UnmuteClient".
	 * Format (usage): (..., iClientID).
	 * Return type: None.
	 * API required (VTC): v2.1.
	 * Description: Unmute a client (voice). */
};

/* Hook function types.
 *
 * Note: To use with the natives of the hooks manager (ReAPI_HM_*). */
enum ReAPI_HFT {
	/* The function is invalid/unrecognized (out of range). */
	ReAPI_HFT_Invalid = -2,

	/* The function is unavailable.
	 * That means the module has it but it can not be used (either the related binary is not running, either its version is lower than the one required for the function). */
	ReAPI_HFT_Unavailable = -1,

	/* Usable functions.
	 *
	 * Notes:
	 *   All the following hook functions are classified by binary type (ReHLDS, ReGameDLL_CS, etc.), then by group (non-classes then classes and subclasses), then inside each group, by alphabetic order.
	 *   There is no enumerations for them for two reasons:
	 *     #1: No problem with the annoying "truncated to 31 characters" warning from the compiler (despite I could use a #define for tricking it but I did not).
	 *     #2: The documentation is important for me, and its order too, so I can maintain it as I want from the beginning and also on updates,
	 *         something I could not do with an enumerations list where I will be "forced" to add the new enums at the end, however this will break compatibility with plugins compiled with old includes.
	 *   For coding, just grab the API function name between the quotes then copy it to your natives (ReAPI_HM_GetHookFunctionTypeID, ReAPI_HM_AddHookByTypeName, etc.), then grab the format between parentheses for the callback, not much complicated...
	 *   There are "Function name (API)" and "Function name (real)", the "API" one is the one you must grab and use with the natives, the other one is the real name of the function (internally),
	 *   but keep in mind it might differs sometimes since Re* projects developers have renamed various functions, or made API functions names differ from internal names for some reasons.
	 *   Also keep in mind I have renamed a few (as "RoundEnd" which has been changed to "CSGameRules::OnRoundEnd", because it is internally a game rules function and I did not like the standard name for it).
	 *
	 *   It is highly important to respect the callback format, however this might just crash the server!
	 *
	 *   About the return types, when a function returns an entity's ID, I have not specified this directly but written the original structure/class type the function returns,
	 *   but keep in mind the natives allowing you to control the return values will return an ID usable for AMX functions, rather than an entity's pointer.
	 *
	 *   About the versions required, this might not always be accurate (not my fault, I have basically browsed the commits to figure them out), but because the developers sometimes forgot to update the API version when they added new functions.
	 *   So again, I highly recommend you use the latest versions of those projects, and you "keep up" everytime it is updated, there is nothing wrong at doing this, and this is for the best!
	 *
	 *   About the descriptions of the ReHLDS's hook functions, those ones may not be fully accurate according to the kind of function, because I do not know much the engine and never took time to deeply look at how it works (the code is more complicated than the games, also in a mess from my opinion, and a few parts might be away from my knowledge).
	 *   So consider some of the descriptions as "indicatives".
	 *   However, I have just put "None" for some of them I was lazy to figure out or do not even care.
	 *
	 *   About the descriptions and informations in globality, those last may change a bit or be extended in the future, especially when the module will be in "final design" with the next AMX Mod version! */


	/**************************************************************************
	*                    HOOK FUNCTIONS -> ENGINE (ReHLDS)                    *
	**************************************************************************/

	/******************************* STANDARD ********************************/

	/* Function name (API): "ClientConnected".
	 * Function name (real): None. Seems to be a custom function added as post notification/event, the standard GoldSrc does not seem to have it.
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Called after a client has connected to the server.
	 * Information: This is called at the end of the "SV_ConnectClient" engine function. */

	/* Function name (API): "Con_Printf".
	 * Function name (real): "Con_Printf".
	 * Format (callback): (const szMessage[]).
	 * Return type: None.
	 * API required (ReHLDS): v3.11.
	 * Description: Called when a console message is sent to the server console in some situations (commands messages like "stats", "status", server logs, etc). */

	/* Function name (API): "CreateFakeClient".
	 * Function name (real): "CreateFakeClient".
	 * Format (callback): (const szName[]).
	 * Return type: Entity's edict pointer (-1 or ID of the new fake client created).
	 * API required (ReHLDS): v3.3.
	 * Description: Called when a fake client (bot) is created. This is a hook of the engine API function. */

	/* Function name (API): "Cvar_DirectSet".
	 * Function name (real): "Cvar_DirectSet".
	 * Format (callback):
	 *   (pCVarHandle, const szNewValue[], iOldValueType, iNewValueType, bool:bChanged).
	 *
	 *   Notes:
	 *     The both first parameters are the ones of the original format, the three last parameters are "custom".
	 *     They basically came from the upcoming AMX Mod version, meantime, the upcoming release will have two more parameters ("szCVarName[]" and "szOldValue[]") and a little different format.
	 *     Those extras parameters are useful in a lot of situations, for easy filtering.
	 *
	 *     Values types (for "i<Old|New>ValueType" variables):
	 *       0 - The value is empty (null length -> "").
	 *       1 - The value is a negative/positive integer number.
	 *       2 - The value is a negative/positive float number.
	 *       3 - The value is a string (something else than a number ...).
	 *
	 *     The "bChanged" boolean is based on the previous value of the actual CVar, this boolean is always updated in consequence of that you do in the hook.
	 *     For example, you change the value of a CVar, the hook "Pre1" will pass "true", but if in case you supercede the hook, the next hooks (Pre2, etc.) will pass "false",
	 *     but the old/new values types and new value will remain the wanted/modified one even if not applied (the "szNewValue" may not match to the "bChanged", so be different than the actual current value),
	 *     so use the parameters natives to retrieve the current value (or simply use the CVar natives).
	 * Return type: None.
	 * API required (ReHLDS): v2.9.
	 * Description: Called when a CVar is set to a value (whatever if new or not). */

	/* Function name (API): "ED_Alloc".
	 * Function name (real): "ED_Alloc".
	 * Format (callback): ().
	 * Return type: Entity's edict pointer (-1 or ID of the new entity created).
	 * API required (ReHLDS): v3.11.
	 * Description: Called when an entity is created.
	 * Information: On success, the entity is a valid edict, but has no private data in that point. */

	/* Function name (API): "ED_Free".
	 * Function name (real): "ED_Free".
	 * Format (callback): (iEntityID).
	 * Return type: None.
	 * API required (ReHLDS): v3.11.
	 * Description: Called when an entity is removed (freed from the server). */

	/* Function name (API): "EV_PlayReliableEvent".
	 * Function name (real): "EV_PlayReliableEvent".
	 * Format (callback): (iClientID, iTargetEntityID, sEventID, Float:flDelay, pEventArgsHandle).
	 * Return type: None.
	 * API required (ReHLDS): v1.2.
	 * Description: Called when a reliable event is played to a client. */

	/* Function name (API): "EV_Precache".
	 * Function name (real): "EV_Precache" (or more known as "pfnPrecacheEvent").
	 * Format (callback): (iType, const szFilePath[]).
	 * Return type: Integer (0 or ID of the event added or already stored).
	 * API required (ReHLDS): v3.12.
	 * Description: Called when an event resource is precached. This is a hook of the engine API function.
	 * Information: This function is made to events files that will be used later by the engine and games. */

	/* Function name (API): "ExecuteServerStringCmd".
	 * Function name (real): "Cmd_ExecuteString_internal". This is basically a post/delayed hook of the "Cmd_ExecuteString" engine function, and where the command line are already tokenized.
	 *   Notes (to developers):
	 *     I think it would have been better to add a PRE hook of the "Cmd_ExecuteString" engine function, before the command line get tokenized,
	 *     so we could alter the whole data and make the changes take effect properly inside this one, and on the server (as changing a path from "exec <file path>", etc.).
	 *     At least, rather than adding the "ValidateCommand" API function I consider almost useless.
	 * Format (callback):
	 *   (const szCommand[], cmd_source:iCommandSourceType, iPerformerID).
	 *
	 *   Notes:
	 *     The "iCommandSourceType" is 1 when sent from the server, and 0 from a client (see the src_* at the top).
	 *     But you can already know that via the "iPerformerID" variable, where 0 will be the server, or a client ID a client.
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Called when a server command (or client being shared with the server) is executed.
	 * Information: You can use this hook to block a server command from being executed, or even use it to block a client from using the famous "status" and "ping" commands (but think at filtering by performer ID). */

	/* Function name (API): "GetEntityInit".
	 * Function name (real): "GetEntityInit_internal".
	 * Format (callback): (const szClassName[]).
	 * Return type: Pointer.
	 * API required (ReHLDS): v3.9.
	 * Description: Called when an entity class name is checked. */

	/* Function name (API): "HandleNetCommand".
	 * Function name (real): "HandleNetCommand".
	 * Format (callback): (iClientID, cOPCode).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Called when a client message is executed. */

	/* Function name (API): "Mod_LoadBrushModel".
	 * Function name (real): "Mod_LoadBrushModel".
	 * Format (callback): (pModelHandle, pBuffer).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Called when a brush model is loaded. */

	/* Function name (API): "Mod_LoadStudioModel".
	 * Function name (real): "Mod_LoadStudioModel".
	 * Format (callback): (pModelHandle, pBuffer).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Called when a studio model is loaded. */

	/* Function name (API): "PF_BuildSoundMsg_I".
	 * Function name (real): "PF_BuildSoundMsg_I" (or more known as "pfnBuildSoundMsg").
	 * Format (callback): (iEntityID, iChannel, const szSample[], Float:flVolume, Float:flAttenuation, iFlags, iPitch, iMsgDestID, iMsgTypeID, Float:vOrigin[3], iMsgTargetID).
	 * Return type: None.
	 * API required (ReHLDS): v1.2.
	 * Description: Called when a sound message is built then emitted. This is a hook of the engine API function. */

	/* Function name (API): "PF_precache_generic_I".
	 * Function name (real): "PF_precache_generic_I" (or more known as "pfnPrecacheGeneric").
	 * Format (callback): (const szFilePath[]).
	 * Return type: Integer (0 or ID of the resource added or already stored).
	 * API required (ReHLDS): v3.12.
	 * Description: Called when a generic resource is precached (any kind of file, like .wad, .tga, .mp3, .wav, etc.). This is a hook of the engine API function. */

	/* Function name (API): "PF_precache_model_I".
	 * Function name (real): "PF_precache_model_I" (or more known as "pfnPrecacheModel").
	 * Format (callback): (const szFilePath[]).
	 * Return type: Integer (0 or ID of the resource [model/sprite] added or already stored).
	 * API required (ReHLDS): v3.12.
	 * Description: Called when a model/sprite resource is precached. This is a hook of the engine API function.
	 * Information: This function is made to precache models/sprites files that will be used later by the engine and games. */

	/* Function name (API): "PF_precache_sound_I".
	 * Function name (real): "PF_precache_sound_I" (or more known as "pfnPrecacheSound").
	 * Format (callback): (const szFilePath[]).
	 * Return type: Integer (0 or ID of the resource [.wav sound] added or already stored).
	 * API required (ReHLDS): v3.12.
	 * Description: Called when a sound resource is precached. This is a hook of the engine API function.
	 * Information: This function is made to precache sounds files that will be used later by the engine and games. */

	/* Function name (API): "PF_Remove_I".
	 * Function name (real): "PF_Remove_I" (or more known as "pfnRemoveEntity").
	 * Format (callback): (iEntityID).
	 * Return type: None.
	 * API required (ReHLDS): v1.2.
	 * Description: Called when an entity is removed. This is a hook of the engine API function.
	 * Information: This function does not catch all the entities removal (the ones by using the "FL_KILLME" flag are not triggered). */

	/* Function name (API): "PreprocessPacket".
	 * Function name (real): "NET_GetPacketPreprocessor".
	 * Format (callback): (pDataHandle, iLength, pNetAddressHandle).
	 * Return type: Boolean.
	 * API required (ReHLDS): v1.0.
	 * Description: None. */

	/* Function name (API): "SerializeSteamId".
	 * Function name (real): "SV_SerializeSteamid".
	 * Format (callback): (pUserIDHandle, pSerializedUserIDHandle).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Called when an UserID is serialized. */

	/* Function name (API): "Steam_GSBUpdateUserData".
	 * Function name (real): "Steam_GSBUpdateUserData".
	 * Format (callback): (ulClientSteamID, const szClientName[], uiScore).
	 * Return type: Boolean.
	 * API required (ReHLDS): v2.5.
	 * Description: Called when the user data (name/frags) of a Steam user is updated. */

	/* Function name (API): "Steam_GSGetSteamID".
	 * Function name (real): "Steam_GSGetSteamID".
	 * Format (callback): ().
	 * Return type: Integer (unsigned long).
	 * API required (ReHLDS): v2.5.
	 * Description: Called when the SteamID64 is retrieved. */

	/* Function name (API): "Steam_NotifyBotConnect".
	 * Function name (real): "Steam_NotifyBotConnect".
	 * Format (callback): (iClientID).
	 * Return type: Integer (0 on failure, 1 on success).
	 * API required (ReHLDS): v1.0.
	 * Description: Called when a bot notifies Steam that he has connected to the server. */

	/* Function name (API): "Steam_NotifyClientConnect".
	 * Function name (real): "Steam_NotifyClientConnect".
	 * Format (callback): (iClientID, pSteam2Key, uiSteam2Key).
	 * Return type: Integer (0 on failure, 1 on success).
	 * API required (ReHLDS): v1.0.
	 * Description: Called when an human notifies Steam that he has connected to the server. */

	/* Function name (API): "Steam_NotifyClientDisconnect".
	 * Function name (real): "Steam_NotifyClientDisconnect".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Called when a client notifies Steam that he has disconnected to the server. */

	/* Function name (API): "SV_ActivateServer".
	 * Function name (real): "SV_ActivateServer".
	 * Format (callback): (iRunPhysics).
	 * Return type: None.
	 * API required (ReHLDS): v2.2.
	 * Description: Called when the server "activates".
	 * Information: This is called on each new map to initialize current map datas. */

	/* Function name (API): "SV_AddResource".
	 * Function name (real): "SV_AddResource".
	 * Format (callback):
	 *   (resourcetype:iResourceType, const szFilePath[], iSize, cFlags, iResourceID).
	 *
	 *   Note: The "iResourceType" is a t_* from "reapi_const.inc" (above).
	 * Return type: None.
	 * API required (ReHLDS): v3.12.
	 * Description:
	 *   Called when a resource is added to the global list of resources that is shared with the clients.
	 *   This is called after all the other "pfnPrecache*" functions, so their datas are pushed into it.
	 * Information: This is called in the "SV_CreateResourceList" engine function. */

	/* Function name (API): "SV_AllowPhysent".
	 * Function name (real): "SV_AllowPhysent". It is a custom function specific to ReHLDS.
	 * Format (callback): (iEntityID, iClientID).
	 * Return type: Boolean (false on refusal, true on agreement).
	 * API required (ReHLDS): v3.13.
	 * Description: Called when an entity is gonna collide with a client.
	 * Informations:
	 *   This can be used to make a semiclip plugin, by refusing collision between two entities, you will allow the client to pass at through the entity.
	 *   But might only be called for clients entities, so for other kind of entities you might use the new DLL API function "pfnShouldCollide". */

	/* Function name (API): "SV_CheckConnectionLessRateLimits".
	 * Function name (real): "SV_CheckConnectionLessRateLimits". It is a custom function specific to ReHLDS.
	 * Format (callback): (pNetAddressHandle, pDataHandle, iLength).
	 * Return type: Boolean.
	 * API required (ReHLDS): v3.6.
	 * Description: None. */

	/* Function name (API): "SV_CheckConsistencyResponse".
	 * Function name (real): "SV_CheckConsistencyResponse_API". It is a custom function specific to ReHLDS.
	 * Format (callback): (iClientID, pResourceHandle, uiHash).
	 * Return type: Boolean.
	 * API required (ReHLDS): v2.0.
	 * Description: None. */

	/* Function name (API): "SV_CheckIPRestrictions".
	 * Function name (real): "SV_CheckIPRestrictions".
	 * Format (callback): (pNetAddressHandle, iAuthProtocol).
	 * Return type: Integer (0 on failure, 1 on success).
	 * API required (ReHLDS): v1.0.
	 * Description:
	 *   Called when the IP of a new client is checked for LAN-only rules.
	 *   The client will be kicked if he can not access to the server (for example, when CVar "sv_lan" is set).
	 * Information: This is called in the "SV_ConnectClient" engine function. */

	/* Function name (API): "SV_CheckKeyInfo".
	 * Function name (real): "SV_CheckKeyInfo".
	 * Format (callback):
	 *   (pNetAddressHandle, szProtocolInfo[], usPort, iAuthProtocol, szRawCertificate[], szCDKey[]).
	 *
	 *   Note: The four last parameters ("usPort" to "szCDKey") are by reference.
	 * Return type: Integer (0 on failure, 1 on success).
	 * API required (ReHLDS): v1.0.
	 * Description:
	 *   Called when some authentification fields of a client are checked.
	 *   The client will be kicked if some of them does not match some criterias.
	 * Information: This is called in the "SV_ConnectClient" engine function. */

	/* Function name (API): "SV_CheckProtocol".
	 * Function name (real): "SV_CheckProtocol".
	 * Format (callback): (pNetAddressHandle, iProtocol).
	 * Return type: Integer (0 on failure, 1 on success).
	 * API required (ReHLDS): v1.0.
	 * Description:
	 *   Called when the protocol of a client is checked.
	 *   The client will be kicked if he can not access to the server due to invalid protocol (not equal).
	 * Information: This is called in the "SV_ConnectClient" engine function. */

	/* Function name (API): "SV_CheckUserInfo".
	 * Function name (real): "SV_CheckUserInfo".
	 * Format (callback):
	 *   (pNetAddressHandle, const szUserInfo[], bool:bIsReconnecting, iReconnectSlot, szName[]).
	 *
	 *   Note: The last parameter ("szName") is by reference.
	 * Return type: Integer (0 on failure, 1 on success).
	 * API required (ReHLDS): v3.12.
	 * Description:
	 *   Called when the client's informations (userinfos) are checked during his connection.
	 *   This function checks if the client's password matches to the server's one, then also some checks about his name, then also HLTV.
	 * Information: This is called in the "SV_ConnectClient" engine function. */

	/* Function name (API): "SV_ClientPrintf".
	 * Function name (real): "SV_ClientPrintf".
	 * Format (callback): (const szMessage[]).
	 * Return type: None.
	 * API required (ReHLDS): v3.12.
	 * Description: Called when a console message is sent to the client console (current host client) in some situations (commands messages like "stats", "status", server logs, etc).
	 * Information: You can use the ReHLDSFuncs's API function "GetHostClient" to retrieve the current client targeted. */

	/* Function name (API): "SV_CompareUserID".
	 * Function name (real): "SV_CompareUserID".
	 * Format (callback): (pUserID1Handle, pUserID2Handle).
	 * Return type: Integer.
	 * API required (ReHLDS): v1.0.
	 * Description: Called when two UserIDs are compared.
	 * Information: This is called in some functions like "SV_BanId_f", etc.. */

	/* Function name (API): "SV_ConnectClient".
	 * Function name (real): "SV_ConnectClient".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: Called when a client connects (major/main function used). */

	/* Function name (API): "SV_CreatePacketEntities".
	 * Function name (real): "SV_CreatePacketEntities".
	 * Format (callback): (iDeltaPackedType, iClientID, pPacketEntitiesHandle, pSizeBufferHandle).
	 * Return type: Integer (size of the message).
	 * API required (ReHLDS): v2.12.
	 * Description: Called when some "packets" are created to be notified to a client.
	 * Information: This is called at the end of the "SV_WriteEntitiesToClient" engine function. */

	/* Function name (API): "SV_DropClient".
	 * Function name (real): "SV_DropClient".
	 * Format (callback): (iClientID, bool:bCrash, const szReason[]).
	 * Return type: None.
	 * API required (ReHLDS): v2.2.
	 * Description: Called when a client disconnects from the server.
	 * Information: Unlike the classic DLL API function (pfnClientDisconnect), this one is called on more cases (at least when a client connects and leaves without reaching the "PutInServer" area). */

	/* Function name (API): "SV_EmitEvents".
	 * Function name (real): "SV_EmitEvents".
	 * Format (callback): (iClientID, pPacketEntitiesHandle, pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v1.2.
	 * Description: Called when some "events" are notified to a client.
	 * Information: This is called at the end of the "SV_WriteEntitiesToClient" engine function. */

	/* Function name (API): "SV_EmitPings".
	 * Function name (real): "SV_EmitPings".
	 * Format (callback): (iClientID, pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v3.11.
	 * Description: Called when the pings of the clients are transmitted to a client.
	 * Information: This is only called when the client presses the button "IN_SCORE" or for a client having a "proxy" status and depending on some conditions. */

	/* Function name (API): "SV_EmitSound2".
	 * Function name (real): "SV_EmitSound2_internal". It is a custom function specific to ReHLDS.
	 * Format (callback): (iEntityID, iReceiverClientID, iChannel, const szSample[], Float:flVolume, Float:flAttenuation, iFlags, iPitch, iEmitFlags, Float:vOrigin[3]).
	 * Return type: Boolean.
	 * API required (ReHLDS): v2.12.
	 * Description:
	 *   Called when a sound is emitted from an entity and to a single client or a group of clients.
	 *   This is an advanced version of the emit sound function which allows to choose a specific target and with a specific channel.
	 *   This version is only called when you use the related function added to the API.
	 *   Meantime, the famous GoldSrc bug with sound not taking in account the current view entity ID (maybe except with the "SND_EMIT2_NOPAS" emit flag specified) of a receiver client still persists with it (Re* projects developers did not fixed this while they should have, rather than fixing other things which does not matter as much).
	 *   I might recommend the usage of the "SVC_SPAWNSTATICSOUND" as alternative and workaround against the PAS bug/problem. */

	/* Function name (API): "SV_EstablishTimeBase".
	 * Function name (real): "SV_EstablishTimeBase".
	 * Format (callback): (iClientID, pUserCmdHandle, iDropped, iNumBackup, iNumCommands).
	 * Return type: None.
	 * API required (ReHLDS): v2.10.
	 * Description: Called when the time base of a client is calculated.
	 * Information: This is called at the end of the "SV_ParseMove" engine function. */

	/* Function name (API): "SV_FinishCertificateCheck".
	 * Function name (real): "SV_FinishCertificateCheck".
	 * Format (callback): (pNetAddressHandle, iAuthProtocol, szRawCertificate[], szUserInfos[]).
	 * Return type: Integer (0 on failure, 1 on success).
	 * API required (ReHLDS): v1.0.
	 * Description:
	 *   Called when the validity of a certificate is checked.
	 *   The client will be kicked on failure.
	 * Information: This is called in the "SV_ConnectClient" engine function. */

	/* Function name (API): "SV_Frame".
	 * Function name (real): "SV_Frame".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReHLDS): v3.7.
	 * Description: Called on each server frame in order to update and trigger various codes (clients messages, Steam infos, etc.). */

	/* Function name (API): "SV_GetIDString".
	 * Function name (real): "SV_GetIDString".
	 * Format (callback): (pUserIDHandle).
	 * Return type: String (AuthID retrieved).
	 * API required (ReHLDS): v1.0.
	 * Description: Called when the AuthID is requested from an UserID. */

	/* Function name (API): "SV_SendServerinfo".
	 * Function name (real): "SV_SendServerinfo".
	 * Format (callback): (pSizeBufferHandle, iClientID).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description:
	 *   Called when the some informations about the server are send to the client.
	 *   This is the function that prints the "BUILD * SERVER (* CRC)" etc., to the client's console. */

	/* Function name (API): "SV_ShouldSendConsistencyList".
	 * Function name (real): "SV_ShouldSendConsistencyList_mod". It is a custom function specific to ReHLDS.
	 * Format (callback): (iClientID, bool:bForceConsistency).
	 * Return type: Boolean.
	 * API required (ReHLDS): v3.8.
	 * Description: Called when the consistency list should be send to a client. */

	/* Function name (API): "SV_Spawn_f".
	 * Function name (real): "SV_Spawn_f".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReHLDS): v2.11.
	 * Description: Called when a client tries to "spawn" by joining the server. Do not confond it with the game's spawn function (CBasePlayer::Spawn)! */

	/* Function name (API): "SV_StartSound".
	 * Function name (real): "SV_StartSound".
	 * Format (callback):
	 *   (iRecipients, iEntityID, iChannel, const szSample[], iVolume, Float:flAttenuation, iFlags, iPitch).
	 *
	 *   Notes:
	 *     The "iRecipients" variable will be 0 for "send to everyone", 1 for "send to one".
	 *     The "iVolume" variable is the volume in the 0<->255 range. Take care, it is not as float format like the classic API function.
	 * Return type: None.
	 * API required (ReHLDS): v1.2.
	 * Description: Called when a sound is emitted.
	 * Informations:
	 *   This is the internal function used by the "pfnEmitSound" engine API function, and also by some other engine codes related to player movement (PM).
	 *   So if ReHLDS is running, using this function to properly catch more "sounds emitted" is a good solution (like the ones emitted from the game's "EMIT_SOUND_DYN" function, etc.). */

	/* Function name (API): "SV_TransferConsistencyInfo".
	 * Function name (real): "SV_TransferConsistencyInfo".
	 * Format (callback): ().
	 * Return type: Integer (number of consistency resources).
	 * API required (ReHLDS): v2.5.
	 * Description: Called when consistency resources are analyzed for various checks. */

	/* Function name (API): "SV_WriteFullClientUpdate".
	 * Function name (real): "SV_WriteFullClientUpdate_internal". It is a custom function specific to ReHLDS.
	 * Format (callback): (iTargetClientID, szInfoBuffer[], iInfoBufferLength, pSizeBufferHandle, iReceiverClientID).
	 * Return type: None.
	 * API required (ReHLDS): v1.3.
	 * Description: Called when the client informations are updated and sent via the "SVC_UPDATEUSERINFO" message.
	 * Informations:
	 *   This is called in the "SV_FullClientUpdate" engine function.
	 *   This new function is basically an enhanced version of the previous, and sends more informations as parameters. */

	/* Function name (API): "SV_WriteVoiceCodec".
	 * Function name (real): "SV_WriteVoiceCodec".
	 * Format (callback): (pSizeBufferHandle).
	 * Return type: None.
	 * API required (ReHLDS): v2.3.
	 * Description: Called when the voice codec is "written" and sent via the "SVC_VOICEINIT" message.
	 * Information: This is called in the "SV_Spawn_f" engine function.  */

	/* Function name (API): "SVC_GetChallenge_mod".
	 * Function name (real): None. It is a custom function specific to ReHLDS.
	 * Format (callback): (const szData[], iChallenge).
	 * Return type: None.
	 * API required (ReHLDS): v1.0.
	 * Description: None.
	 * Information: This is called at the end of the "SVC_GetChallenge" engine function. */

	/* Function name (API): "ValidateCommand".
	 * Function name (real): "ValidateCmd_API". It is a custom function specific to ReHLDS.
	 * Format (callback):
	 *   (const szCommand[], iCommandSourceType, iPerformerID).
	 *
	 *   Notes:
	 *     The "iCommandSourceType" is 1 when sent from the server, and 0 from a client (see the src_* at the top).
	 *     But you can already know that via the "iPerformerID" variable, where 0 will be the server, or a client ID a client.
	 * Return type: Boolean (false on refusal, true on agreement).
	 * API required (ReHLDS): v1.0.
	 * Description: Called right before the custom ReHLDS's hook chain "ExecuteServerStringCmd" API function, used to validate or not the command passed. */


	/**************************************************************************
	*               HOOK FUNCTIONS -> GAME -> CS (ReGameDLL_CS)               *
	**************************************************************************/

	/*************************** STANDARD -> Menu ****************************/

	/* Function name (API): "ShowMenu".
	 * Function name (real): "ShowMenu".
	 * Format (callback): (iClientID, iValidKeysBits, iDisplayTime, iNeedMore, const szText[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a normal (non-VGUI) menu is showed to a client (like team menu, buy menu). */

	/* Function name (API): "ShowVGUIMenu".
	 * Function name (real): "ShowVGUIMenu".
	 * Format (callback): (iClientID, iMenuType, iBitMask, const szOldMenu[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a VGUI menu is showed to a client (like team menu, buy menu).
	 * Informations: This is not called as much as expected (not in all situations) and in consequence not much useful. */


	/**************************** STANDARD -> PM *****************************/

	/* Function name (API): "PM_AirAccelerate".
	 * Function name (real): "PM_AirAccelerate".
	 * Format (callback):
	 *   (Float:vWishDirection[3], Float:flWishSpeed, Float:flAcceleration, pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The three first parameters are the ones of the original format, the two last parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when an air movement is performed by a client.
	 * Information: This is called in the "PM_AirMove" game function.*/

	/* Function name (API): "PM_AirMove".
	 * Function name (real): "PM_AirMove".
	 * Format (callback):
	 *   (iClientID, pPlayerMoveHandle).
	 *
	 *   Note: The first parameter is the one of the original format, the last parameter is "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when an air movement is performed by a client (when "pmove->onground" is not equal to -1). */

	/* Function name (API): "PM_CheckWaterJump".
	 * Function name (real): "PM_CheckWaterJump".
	 * Format (callback):
	 *   (pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The two parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a water jump check is done on a client (when he has his waist underwater, so when EntVars's "waterlevel" is set to "2"). */

	/* Function name (API): "PM_Duck".
	 * Function name (real): "PM_Duck".
	 * Format (callback):
	 *   (pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The two parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called to check if a client is ducking. */

	/* Function name (API): "PM_Init".
	 * Function name (real): "PM_Init".
	 * Format (callback): (pPlayerMoveHandle).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the PM (Player Movement) fields are initialized (global "pmove" variable, stuck table, texture types, etc.). */

	/* Function name (API): "PM_Jump".
	 * Function name (real): "PM_Jump".
	 * Format (callback):
	 *   (pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The two parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a jump movement is performed by a client (when he presses the "jump" button). */

	/* Function name (API): "PM_LadderMove".
	 * Function name (real): "PM_LadderMove".
	 * Format (callback):
	 *   (pLadderHandle, pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The first parameter is the one of the original format, the two last parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a ladder movement is performed by a client. */

	/* Function name (API): "PM_Move".
	 * Function name (real): "PM_Move".
	 * Format (callback): (pPlayerMoveHandle, iServer).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called on each player movement (main function which handles most of those physics in the game). */

	/* Function name (API): "PM_PlayStepSound".
	 * Function name (real): "PM_PlayStepSound".
	 * Format (callback):
	 *   (iStep, Float:flVolume, pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The both first parameters are the ones of the original format, the two last parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a client emits a steps sound. */

	/* Function name (API): "PM_UnDuck".
	 * Function name (real): "PM_UnDuck".
	 * Format (callback):
	 *   (pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The two parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a client tries to unduck. */

	/* Function name (API): "PM_UpdateStepSound".
	 * Function name (real): "PM_UpdateStepSound".
	 * Format (callback):
	 *   (pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The two parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.1.
	 * Description: Called when the step sounds variables are updated. */

	/* Function name (API): "PM_WaterJump".
	 * Function name (real): "PM_WaterJump".
	 * Format (callback):
	 *   (pPlayerMoveHandle, iClientID).
	 *
	 *   Note: The two parameters are "custom" (not alterable via the parameters system).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a water jump movement is performed by a client. */


	/************************ STANDARD -> Grenade/C4 *************************/

	/* Function name (API): "PlantBomb". It is a renaming of an actual function.
	 * Function name (real): "CGrenade::ShootSatchelCharge".
	 * Format (callback): (iOwnerID, Float:vStart[3], Float:vAngles[3]).
	 * Return type: Entity's CGrenade pointer (ID of the C4 created).
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when a C4 entity is created. */

	/* Function name (API): "ThrowFlashbang". It is a renaming of an actual function.
	 * Function name (real): "CGrenade::ShootTimed".
	 * Format (callback): (iOwnerID, Float:vStart[3], Float:vVelocity[3], Float:flExplodeTime).
	 * Return type: Entity's CGrenade pointer (ID of the flashbang grenade created).
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when a flashbang grenade is created. */

	/* Function name (API): "ThrowHeGrenade". It is a renaming of an actual function.
	 * Function name (real): "CGrenade::ShootTimed2".
	 * Format (callback): (iOwnerID, Float:vStart[3], Float:vVelocity[3], Float:flExplodeTime, iTeamID, usEvent).
	 * Return type: Entity's CGrenade pointer (ID of the HE grenade created).
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when a HE grenade is created. */

	/* Function name (API): "ThrowSmokeGrenade". It is a renaming of an actual function.
	 * Function name (real): "CGrenade::ShootSmokeGrenade".
	 * Format (callback): (iOwnerID, Float:vStart[3], Float:vVelocity[3], Float:flExplodeTime, usEvent).
	 * Return type: Entity's CGrenade pointer (ID of the smoke grenade created).
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when a smoke grenade is created. */


	/****************** STANDARD -> Multidamage accumulator ******************/

	/* Function name (API): "AddMultiDamage".
	 * Function name (real): "AddMultiDamage".
	 * Format (callback): (iInflictorID, iTargetEntityID, Float:flDamage, iDamageBits).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the data of the multidamage accumulator is set (usually inside the call of virtual function "*::TraceAttack"). */

	/* Function name (API): "ApplyMultiDamage".
	 * Function name (real): "ApplyMultiDamage".
	 * Format (callback): (iInflictorID, iAttackerID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the data of the multidamage accumulator is applied (usually after the call of virtual function "*::TraceAttack"). */

	/* Function name (API): "ClearMultiDamage".
	 * Function name (real): "ClearMultiDamage".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the data of the multidamage accumulator is cleared (usually before the call of virtual function "*::TraceAttack"). */


	/*********************** STANDARD -> Unclassified ************************/

	/* Function name (API): "BuyGunAmmo".
	 * Function name (real): "BuyGunAmmo".
	 * Format (callback): (iClientID, iInventoryItemEntityID, bool:bBlinkMoney).
	 * Return type: Boolean.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client buys munitions for his inventory items (triggered after the buy process in a loop at through all of his inventory items and until the maximum ammo is reached, but also depending on his money).
	 * Information: This is called in the "BuyAmmo" game function. */

	/* Function name (API): "BuyItem".
	 * Function name (real): "BuyItem".
	 * Format (callback): (iClientID, iSlotID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a client buys an item not being a weapon (triggered after the buy process). */

	/* Function name (API): "BuyWeaponByWeaponID".
	 * Function name (real): "BuyWeaponByWeaponID".
	 * Format (callback): (iClientID, iWeaponTypeID).
	 * Return type: Entity's CBaseEntity pointer (ID of the entity internally created from the "CBasePlayer::GiveNamedItem" function used inside).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client buys an inventory item (triggered after the buy process). */

	/* Function name (API): "CreateWeaponBox".
	 * Function name (real): "CreateWeaponBox". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function.
	 * Format (callback): (iInventoryItemEntityID, iOwnerID, const szModelPath[], Float:vOrigin[3], Float:vAngles[3], Float:vVelocity[3], Float:flLifetime, bool:bPackAmmo).
	 * Return type: Entity's CWeaponBox pointer (ID of the weapon box created).
	 * API required (ReGameDLL_CS): v5.15.
	 * Description: Called when a weapon box entity is created.
	 * Information: This is called in the functions that drop a client's inventory item ("packPlayerItem", "packPlayerNade", "CBasePlayer::DropPlayerItem"), so when a client manually drops it or dies. */

	/* Function name (API): "FreeGameRules".
	 * Function name (real): "FreeGameRules". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (pGameRulesAddress).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.22.
	 * Description: Called when the game rules are freed.
	 * Information: This is called right before the call of the function "InstallGameRules" (in the function "CWorld::Precache"). */

	/* Function name (API): "GetForceCamera".
	 * Function name (real): "GetForceCamera".
	 * Format (callback): (iObserverClientID).
	 * Return type: Integer (a mode in the 0<->2 range which corresponds to the value of the CVars "mp_forcechasecam" or "mp_forcecamera").
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the "force camera" mode is checked.
	 * Information: This is called in the observer functions (CBasePlayer::Observer_<FindNextPlayer|SetMode>). */

	/* Function name (API): "HandleMenu_ChooseAppearance".
	 * Function name (real): "HandleMenu_ChooseAppearance".
	 * Format (callback): (iClientID, iSlotID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client chooses his appearance from the menu (normal/VGUI). */

	/* Function name (API): "HandleMenu_ChooseTeam".
	 * Function name (real): "HandleMenu_ChooseTeam".
	 * Format (callback): (iClientID, iSlotID).
	 * Return type: Integer (0 on failure, 1 on success).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client chooses his team from the menu (normal/VGUI). */

	/* Function name (API): "InstallGameRules".
	 * Function name (real): "InstallGameRules".
	 * Format (callback): ().
	 * Return type: CGameRules's pointer (value of a new "CGameRules" object created according to the game rules defined in the function).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game rules are initialized.
	 * Informations:
	 *   This is a good place to initialize virtual functions based on the value of the "g_pGameRules" object,
	 *   which is returned from that function, despite you do not need that if you use the predefined hooks of the ReGameDLL_CS's API (CSGameRules::*).
	 *   Only use that function as PRE when you wish to modify the game rules (for example, to load the training rules, set the gpGlobals's "deathmatch" value to 0 will do the job).
	 *   However, always use the POST when you initialize virtual functions with the result of it. */

	/* Function name (API): "InternalCommand".
	 * Function name (real): "InternalCommand".
	 * Format (callback): (iClientID, const szCommand[], const szArg1[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client (bot or human) triggers an internal command (autobuy/rebuy, etc.). */

	/* Function name (API): "IsPenetrableEntity".
	 * Function name (real): "IsPenetrableEntity_default". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (Float:vStart[3], Float:vEnd[3], iAttackerID, iHitEntityID).
	 * Return type: Boolean.
	 * API required (ReGameDLL_CS): v5.7.
	 * Description: Called when the "penetration level" is requested from an entity being hit.
	 * Information:
	 *   This is called in the "CBaseEntity::FireBullets3" game function.
	 *   It can be used to disable the penetration power at through a specific entity. */

	/* Function name (API): "PlayerBlind".
	 * Function name (real): "PlayerBlind". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID, iInflictorID, iAttackerID, Float:flFadeTime, Float:flFadeHold, iAlpha, Float:vRGBColor[3]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is blinded by a flashbang grenade.
	 * Information: This is called in the "RadiusFlash" game function. */

	/* Function name (API): "RadiusFlash_TraceLine".
	 * Function name (real): "RadiusFlash_TraceLine_hook". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID, iInflictorID, iAttackerID, Float:vSource[3], Float:vSpot[3], pTraceResultHandle).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a trace line is performed between a source origin (flashbang grenade explosion) and a destination ("vSpot", which is the client view origin).
	 * Information: This is called in the "RadiusFlash" game function, and at two reprises (the first one uses the inflictor as "ignored entity ID", the second one uses the hit entity ID as "ignored entity ID"). */

	/* Function name (API): "SpawnHeadGib".
	 * Function name (real): "SpawnHeadGib".
	 * Format (callback): (iVictimEntityID).
	 * Return type: Entity's CGib pointer (ID of the gib created).
	 * API required (ReGameDLL_CS): v5.17.
	 * Description: Called when a head gib entity is created.
	 * Information: This is called in the "CBaseMonster::GibMonster" game function when the CVar "violence_hgibs" is enabled and only for a victim who has "human gibs", so when a client dies and having gibs enabled. */

	/* Function name (API): "SpawnRandomGibs".
	 * Function name (real): "SpawnRandomGibs".
	 * Format (callback): (iVictimEntityID, iGibsAmount, iHumanType).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.17.
	 * Description: Called when random gibs entities are created (depending on the value of the "iGibsAmount" variable).
	 * Information: This is called in the "CBaseMonster::GibMonster" game function when the CVars "violence_<h|a>gibs" are enabled, so when an entity (human or monster) dies and having gibs enabled. */


	/*********************** CLASS GROUP -> CBaseEntity **********************/

	/************************ CLASS -> CBaseAnimating ************************/

	/* Function name (API): "CBaseAnimating::ResetSequenceInfo".
	 * Function name (real): "CBaseAnimating::ResetSequenceInfo".
	 * Format (callback): (iEntityID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the sequence informations of an entity are reset. */


	/************************* CLASS -> CBaseEntity **************************/

	/* Function name (API): "CBaseEntity::FireBuckshots".
	 * Function name (real): "CBaseEntity::FireBuckshots". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iEntityID, iShotsNum, const Float:vSource[3], const Float:vDirection[3], const Float:vSpread[3], Float:flDistance, iTracerFrequency, iDamage, iAttackerID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.19.
	 * Description: Called when an entity shoots "buck shots" (pellets).
	 * Informations:
	 *   This is called by a client (the "iEntityID" variable will be the shooter client) and only when he shoots with a shotgun (M3/XM1014).
	 *   This is a main function which handles "after shoot effects" (traces, decals, number of pellets to shoot, tracers, damage...).
	 *   This version is a slighly modified version of the "CBaseEntity::FireBullets" function, but just readapted for shotguns. */

	/* Function name (API): "CBaseEntity::FireBullets".
	 * Function name (real): "CBaseEntity::FireBullets".
	 * Format (callback): (iEntityID, iShotsNum, const Float:vSource[3], const Float:vDirection[3], const Float:vSpread[3], Float:flDistance, iBulletType, iTracerFrequency, iDamage, iAttackerID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.19.
	 * Description: Called when an entity shoots standard bullets.
	 * Informations:
	 *   This is only called by the mounted gun entities (class name: "func_tank"), but on the standard CS this is also called when a client shoots with a shotgun.
	 *   This is a main function which handles "after shoot effects" (traces, decals, number of pellets to shoot, tracers, damage...). */

	/* Function name (API): "CBaseEntity::FireBullets3".
	 * Function name (real): "CBaseEntity::FireBullets3".
	 * Format (callback): (iEntityID, const Float:vSource[3], const Float:vDirection[3], Float:flSpread, Float:flDistance, iPenetrationNum, iBulletType, iDamage, Float:flRangeModifier, iAttackerID, bool:bPistol, iSharedRandom).
	 * Return type: Vector.
	 * API required (ReGameDLL_CS): v5.19.
	 * Description: Called when an entity shoots standard bullets.
	 * Informations:
	 *   This is only called by a client and for all the clients's weapons, except for the shotguns.
	 *   This is a main function which handles "after shoot effects" (traces, penetration power, bullet type, damage...). */


	/************************* CLASS -> CBasePlayer **************************/

	/* Function name (API): "CBasePlayer::AddAccount".
	 * Function name (real): "CBasePlayer::AddAccount".
	 * Format (callback): (iClientID, iAmount, RewardType:iRewardType, bool:bTrackChange).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client receives/looses money on some events (buy process, teammate/enemy kill, reward from objectives, etc.).
	 * Information: The ReGameDLL_CS's version has one more parameter (iRewardType) which lets you know from which event it is called (round bonus, hostage rescued, enemy killed, etc.). */

	/* Function name (API): "CBasePlayer::AddPlayerItem".
	 * Function name (real): "CBasePlayer::AddPlayerItem".
	 * Format (callback): (iClientID, iInventoryItemEntityID).
	 * Return type: Integer (0 on failure or added as duplicate, or 1 on success).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when an inventory item is added to a client. */

	/* Function name (API): "CBasePlayer::AddPoints".
	 * Function name (real): "CBasePlayer::AddPoints".
	 * Format (callback): (iClientID, iScore, iAllowNegativeScore).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when score points (positive/negative frags) are added to a client and from a "game_score" entity triggered. */

	/* Function name (API): "CBasePlayer::AddPointsToTeam".
	 * Function name (real): "CBasePlayer::AddPointsToTeam".
	 * Format (callback): (iClientID, iScore, iAllowNegativeScore).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when score points (positive/negative frags) are added to a client's team (excluding him) and from a "game_score" entity triggered. */

	/* Function name (API): "CBasePlayer::Blind".
	 * Function name (real): "CBasePlayer::Blind".
	 * Format (callback): (iClientID, Float:flUntilTime, Float:flHoldTime, Float:flFadeTime, iAlpha).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is blinded by a flashbang grenade. It is a "POST event" which updates some CBasePlayer's members related to flash event.
	 * Information: This is called in the ReGameDLL_CS's "PlayerBlind" game function. */

	/* Function name (API): "CBasePlayer::CanSwitchTeam".
	 * Function name (real): "CBasePlayer::CanSwitchTeam". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID, iTeamID).
	 * Return type: Boolean (false on refusal, true on agreement).
	 * API required (ReGameDLL_CS): v5.4.
	 * Description: Called when the teams are balanced by the game, in order to apply or not some rules about "switching a client to another team".
	 * Information: This is called in the "CHalfLifeMultiplay::BalanceTeams" game function. */

	/* Function name (API): "CBasePlayer::CheckTimeBasedDamage".
	 * Function name (real): "CBasePlayer::CheckTimeBasedDamage".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a time based damage type is checked (damage or health restore which are delayed). */

	/* Function name (API): "CBasePlayer::Classify".
	 * Function name (real): "CBasePlayer::Classify".
	 * Format (callback): (iClientID).
	 * Return type: Integer (a CLASS_*).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the classification (category/group) of a client is requested at various events.
	 * Information: This can be used in some situations to disable/enable some features and change a bit the gameplay. */

	/* Function name (API): "CBasePlayer::DeathSound".
	 * Function name (real): "CBasePlayer::DeathSound".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.21.
	 * Description: Called when a client emits a "death sound" on death.
	 * Information: This is called in the "CBasePlayer::Killed" game function. */

	/* Function name (API): "CBasePlayer::Disappear".
	 * Function name (real): "CBasePlayer::Disappear".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a VIP client "disappears" (once he reaches the target, usually the helicopter... tougoudougoudou!). */

	/* Function name (API): "CBasePlayer::DropIdlePlayer".
	 * Function name (real): "CBasePlayer::DropIdlePlayer". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID, const szReason[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.12.
	 * Description: Called when an idle (AFK) client is kicked.
	 * Information: This requires the CVar "mp_autokick" to be enabled in order to take effect. */

	/* Function name (API): "CBasePlayer::DropPlayerItem".
	 * Function name (real): "CBasePlayer::DropPlayerItem".
	 * Format (callback): (iClientID, const szItemName[]).
	 * Return type:
	 *   Entity's CBaseEntity pointer (ID of the weapon box entity internally created from the "CBaseEntity::Create" function used inside).
	 *
	 *   Note: The original function from the standard CS binary does not have such return value, but returns nothing.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when an inventory item of a client is dropped (manually or automatically in some events, as buying, death, etc.). */

	/* Function name (API): "CBasePlayer::DropShield".
	 * Function name (real): "CBasePlayer::DropShield".
	 * Format (callback): (iClientID, bool:bDeploy).
	 * Return type:
	 *   Entity's CBaseEntity pointer (ID of the shield entity internally created from the "CBaseEntity::Create" function used inside).
	 *
	 *   Note: The original function from the standard CS binary does not have such return value, but returns nothing.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the shield of a client is dropped (manually or automatically in some events, as buying, death, etc.). */

	/* Function name (API): "CBasePlayer::Duck".
	 * Function name (real): "CBasePlayer::Duck".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client presses the "duck" button or is fully ducking.
	 * Information: This is called in the "CBasePlayer::PreThink" game function. */

	/* Function name (API): "CBasePlayer::EntSelectSpawnPoint".
	 * Function name (real): "CBasePlayer::EntSelectSpawnPoint".
	 * Format (callback): (iClientID).
	 * Return type: Entity's edict pointer (-1 or ID of the spawn point entity the client is gonna use for respawning).
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the game checks the "best spawn point" in order to respawn a client in that location.
	 * Information: This is the internal function called in the "CHalfLifeMultiplay::GetPlayerSpawnSpot" game function. */

	/* Function name (API): "CBasePlayer::GetIntoGame".
	 * Function name (real): "CBasePlayer::GetIntoGame". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function.
	 * Format (callback): (iClientID).
	 * Return type: Boolean.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client join the game for the first time (after he picked up a team and an appearance). */

	/* Function name (API): "CBasePlayer::GiveAmmo".
	 * Function name (real): "CBasePlayer::GiveAmmo".
	 * Format (callback): (iClientID, iAmount, const szName[], iMax).
	 * Return type: Integer (-1 on failure or ID of the ammunition type given).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client receives ammunitions (in some events as when the default items are given at spawn, on pickup, on buying, on usage of cheat commands, etc.). */

	/* Function name (API): "CBasePlayer::GiveDefaultItems".
	 * Function name (real): "CBasePlayer::GiveDefaultItems".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client receives the default items provided by the game.
	 * Information: This is not called when maps's custom items are given, or, for a VIP, or, for a client who did not die on the previous round. */

	/* Function name (API): "CBasePlayer::GiveNamedItem".
	 * Function name (real): "CBasePlayer::GiveNamedItem".
	 * Format (callback): (iClientID, const szItemName[]).
	 * Return type: Entity's CBaseEntity pointer (ID of the item entity internally created from the engine's "CreateNamedEntity" function used inside).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client receives an item (in some events as when the default items are given at spawn, on buying, on usage of cheat commands, on pickup, etc.). */

	/* Function name (API): "CBasePlayer::GiveShield".
	 * Function name (real): "CBasePlayer::GiveShield".
	 * Format (callback): (iClientID, bool:bDeploy).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client receives a shield (in some events as when the default items are given at spawn, on buying, on usage of cheat commands, on pickup, etc.). */

	/* Function name (API): "CBasePlayer::HasRestrictItem".
	 * Function name (real): "CBasePlayer::HasRestrictItem". It is a custom function specific to ReGameDLL_CS.
	 *   Note (to developers): The name does not feel good to me, it would have been better to name it "IsItemRestricted"... But well, can happen, then it is done now...
	 * Format (callback): (iClientID, ItemID:iItemTypeID, ItemRestType:iItemRestrictType).
	 * Return type: Boolean (false on refusal, true on agreement).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is gonna buy or receive an item and its restriction status is checked according to conditions.
	 * Informations:
	 *   By default all the items are allowed, but this can be used to restrict an item from being received (with your own conditions).
	 *   This function handles all the inventory items (and extras as NVGs, defuse kit, shield), but not the ammunitions, use the "BuyGunAmmo" hook to restrict this. */

	/* Function name (API): "CBasePlayer::HintMessageEx".
	 * Function name (real): "CBasePlayer::HintMessageEx".
	 * Format (callback): (iClientID, const szMessage[], Float:flDuration, bool:bDisplayIfPlayerDead, bool:bOverride).
	 * Return type: Boolean (false when can not be added to queue, true on success).
	 * API required (ReGameDLL_CS): v5.9.
	 * Description: Called when a director HUD message (big size) is displayed to a client.
	 * Information: This is called by default in various events (like when you team attack, you see a big green message saying "Try to do not injure teammates."...). */

	/* Function name (API): "CBasePlayer::ImpulseCommands".
	 * Function name (real): "CBasePlayer::ImpulseCommands".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called in order to check if the client is pressing an impulse command (flashlight, spray, cheats, etc.).
	 * Information: This is called in the "CBasePlayer::ItemPostFrame" game function, so in each "client frame". */

	/* Function name (API): "CBasePlayer::JoiningThink".
	 * Function name (real): "CBasePlayer::JoiningThink".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.21.
	 * Description: Called when a client "thinks for the join status" (permanently called on each call of "CBasePlayer::PreThink", and only when he is not assigned as specatator or not playing).
	 * Informations:
	 *   This is called in the "CBasePlayer::PreThink" game function.
	 *   This is the function that calls the "CBasePlayer::GetIntoGame" function and links the client to the "introduction camera". */

	/* Function name (API): "CBasePlayer::Jump".
	 * Function name (real): "CBasePlayer::Jump".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client presses the "jump" button.
	 * Information: This is called in the "CBasePlayer::PreThink" game function. */

	/* Function name (API): "CBasePlayer::Killed".
	 * Function name (real): "CBasePlayer::Killed".
	 * Format (callback): (iClientID, iAttackerID, iGib).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is killed or suicide himself.
	 * Information: This is called in the "CBasePlayer::TakeDamage" and "pfnClientKill" DLL API game functions. */

	/* Function name (API): "CBasePlayer::MakeBomber".
	 * Function name (real): "CBasePlayer::MakeBomber". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function.
	 * Format (callback): (iClientID).
	 * Return type: Boolean (false when the C4 weapon can not be given from the ReGameDLL_CS's "CBasePlayer::GiveNamedItemEx" game function, true on success).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game selects a client and gives him the C4.
	 * Information: This is called in the "CHalfLifeMultiplay::GiveC4" game function. */

	/* Function name (API): "CBasePlayer::MakeVIP".
	 * Function name (real): "CBasePlayer::MakeVIP".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game selects a client and gives him the VIP status and properties.
	 * Information: This is called in the "CHalfLifeMultiplay::PickNextVIP" game function (which is called in the "CHalfLifeMultiplay::RestartRound" game function). */

	/* Function name (API): "CBasePlayer::ObjectCaps".
	 * Function name (real): "CBasePlayer::ObjectCaps".
	 * Format (callback): (iClientID).
	 * Return type: Integer (a FCAP_*).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client presses the "use" button.
	 * Informations:
	 *   This is called in the "CBasePlayer::PlayerUse" game function inside the entities research in sphere (the current client using the "use" button is basically not ignored from the research).
	 *   This can be useful to detect a "use" event with an additional check of the "use" button (like "CBasePlayer::<Duck|Jump>" are good for the "duck" and "jump" events), but you can also use the "CBasePlayer::UseEmpty" hook when the client presses that key but nothing is used. */

	/* Function name (API): "CBasePlayer::Observer_FindNextPlayer".
	 * Function name (real): "CBasePlayer::Observer_FindNextPlayer".
	 * Format (callback): (iClientID, bool:bReverse, const szTargetName[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.21.
	 * Description: Called when a client is spectator and when a "next client" is searched in order to be selected as target to observe.
	 * Information: This is called in the "CBasePlayer::Observer_HandleButtons", "CBasePlayer::Observer_CheckTarget", "CBasePlayer::Observer_SetMode" game functions. */

	/* Function name (API): "CBasePlayer::Observer_IsValidTarget".
	 * Function name (real): "CBasePlayer::Observer_IsValidTarget".
	 * Format (callback): (iClientID, iTargetID, bool:bSameTeam).
	 * Return type: Entity's CBasePlayer pointer (ID of the client found as valid target we can observe).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is spectator and selects a target to observe.
	 * Informations:
	 *   This is called in the "CBasePlayer::Observer_FindNextPlayer" game function.
	 *   This can be useful to ignore a client (as an admin) from being watched, or use it in conjunction with the "GetForceCamera" hook in order to make the "Admin Free Look" code. */

	/* Function name (API): "CBasePlayer::Observer_SetMode".
	 * Function name (real): "CBasePlayer::Observer_SetMode".
	 * Format (callback): (iClientID, iMode).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.21.
	 * Description: Called when a client is spectator and changes his observer mode (Locked Chase Cam [1], Free Chase Cam [2], Free Look [3], First Person [4], Free Overview [5], Chase Overview [6], etc.).
	 * Information: This is called in the "CBasePlayer::Observer_HandleButtons" and "CBasePlayer::Observer_CheckTarget" game functions. */

	/* Function name (API): "CBasePlayer::Observer_Think".
	 * Function name (real): "CBasePlayer::Observer_Think".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a client is spectator and when the observer functions (CBasePlayer::Observer_<Check<Properties|Target>|HandleButtons>) are checked (major function called on each client frame).
	 * Information: This is called in the "CBasePlayer::PreThink" game function. */

	/* Function name (API): "CBasePlayer::OnSpawnEquip".
	 * Function name (real): "CBasePlayer::OnSpawnEquip". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function (but in the "CHalfLifeMultiplay::PlayerSpawn" game function).
	 * Format (callback): (iClientID, bool:bAddDefault, bool:bEquipGame).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is equiped (weapons, items, etc.) at his spawn.
	 * Information: This is called in the "CHalfLifeMultiplay::PlayerSpawn" game function. */

	/* Function name (API): "CBasePlayer::Pain".
	 * Function name (real): "CBasePlayer::Pain".
	 * Format (callback): (iClientID, iLastHitGroup, bHasArmor).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.21.
	 * Description: Called when a client emits a "pain sound" on damage reception.
	 * Information: This is called in the "CBasePlayer::TakeDamage" game function. */

	/* Function name (API): "CBasePlayer::PlayerDeathThink".
	 * Function name (real): "CBasePlayer::PlayerDeathThink".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a client died in order to trigger some events related to his death (spawn corpse, check win conditions, respawn him, etc.).
	 * Information: This is called in some death functions ("CBasePlayer::<Disappear|Killed>"). */

	/* Function name (API): "CBasePlayer::PostThink".
	 * Function name (real): "CBasePlayer::PostThink".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is "post thinking".
	 * Information: This is the game version which is called in the "pfnClientPostThink" DLL API function. */

	/* Function name (API): "CBasePlayer::Precache".
	 * Function name (real): "CBasePlayer::Precache".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client spawns in order to reset some datas (members) and load/precache things (like messages). */

	/* Function name (API): "CBasePlayer::PreThink".
	 * Function name (real): "CBasePlayer::PreThink".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is "pre thinking".
	 * Information: This is the game version which is called in the "pfnClientPreThink" DLL API function. */

	/* Function name (API): "CBasePlayer::Radio".
	 * Function name (real): "CBasePlayer::Radio".
	 * Format (callback): (iClientID, const szAudioMessage[], const szTextMessage[], sPitch, bool:bShowIcon).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client plays a radio sound, or, when the games plays it on new round (like "Ok that's go!"). */

	/* Function name (API): "CBasePlayer::RemovePlayerItem".
	 * Function name (real): "CBasePlayer::RemovePlayerItem".
	 * Format (callback): (iClientID, iInventoryItemEntityID).
	 * Return type: Integer (0 on failure when tried to update inventory items listing, or 1 on success).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when an inventory item is removed from a client. */

	/* Function name (API): "CBasePlayer::RemoveSpawnProtection".
	 * Function name (real): "CBasePlayer::RemoveSpawnProtection". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.6.
	 * Description: Called when the spawn protection of a client is removed/disabled (because has expired). */

	/* Function name (API): "CBasePlayer::ResetMaxSpeed".
	 * Function name (real): "CBasePlayer::ResetMaxSpeed".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the maximum speed of a client is reset to the default value, according to some conditions (active item, VIP, observer, etc.). */

	/* Function name (API): "CBasePlayer::RoundRespawn".
	 * Function name (real): "CBasePlayer::RoundRespawn".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is respawned by the game, or in force.
	 * Information: This is called in the "CHalfLifeMultiplay::RestartRound" game function. */

	/* Function name (API): "CBasePlayer::SetAnimation".
	 * Function name (real): "CBasePlayer::SetAnimation".
	 * Format (callback): (iClientID, CS_PLAYER_ANIM:iAnimationType).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when an animation is played to a client (client's skin movement, as shoot, reload, etc.). */

	/* Function name (API): "CBasePlayer::SetClientUserInfoModel".
	 * Function name (real): "CBasePlayer::SetClientUserInfoModel". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID, const szInfoBuffer[], const szNewModelName[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the model of a client (player skin) is changed by the game. */

	/* Function name (API): "CBasePlayer::SetClientUserInfoName".
	 * Function name (real): "CBasePlayer::SetClientUserInfoName". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function (but in the "pfnClientUserInfoChanged" DLL API function).
	 * Format (callback): (iClientID, const szInfoBuffer[], const szNewClientName[]).
	 * Return type: Boolean (false when delayed on next spawn [when the client is dead], true on immediate effect).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the name of a client is changed. */

	/* Function name (API): "CBasePlayer::SetSpawnProtection".
	 * Function name (real): "CBasePlayer::SetSpawnProtection". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID, Float:flProtectionTime).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.6.
	 * Description: Called when the spawn protection of a client is set/enabled. */

	/* Function name (API): "CBasePlayer::Spawn".
	 * Function name (real): "CBasePlayer::Spawn".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client spawns.
	 * Information: Take care, this is also called once on first initialization ("pfnPutInServer" DLL API function). */

	/* Function name (API): "CBasePlayer::StartDeathCam".
	 * Function name (real): "CBasePlayer::StartDeathCam".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.3.
	 * Description: Called when a client is associated with the "death camera" (after his death, when he becomes an observer). */

	/* Function name (API): "CBasePlayer::StartObserver".
	 * Function name (real): "CBasePlayer::StartObserver".
	 * Format (callback): (iClientID, Float:vPosition[3], Float:vViewAngles[3]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client becomes an observer.
	 * Information: This is called when he joins a team and can not respawn yet, after he dies, or when he joins the spectators. */

	/* Function name (API): "CBasePlayer::SwitchTeam".
	 * Function name (real): "CBasePlayer::SwitchTeam".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.4.
	 * Description: Called when a client is switched to another team.
	 * Information: This is called in the "CHalfLifeMultiplay::BalanceTeams" and "CHalfLifeMultiplay::SwapAllPlayers" game functions. */

	/* Function name (API): "CBasePlayer::TakeDamage".
	 * Function name (real): "CBasePlayer::TakeDamage".
	 * Format (callback):
	 *   (iClientID, iInflictorID, iAttackerID, Float:flDamage, iDamageBits).
	 *
	 *   Notes:
	 *     In the hook of that ReGameDLL_CS binary, the "flDamage" variable has been changed to a "reference type", probably in order to have the "final damage received" in a POST hook, but I did not like that new behavior for some reasons.
	 *     So "my hook" has now a behavior similar to the original function (it basically resets the damage for the AMX hook, right after the function gets called, so before the "POST" hooks gets called).
	 *     I mainly did not like that change for two reasons, the first one is the fact this makes me loose the information about the "current damage" we could set from the parameters (knowing the post hooks will pass the "final damage via reference" we could not retrieve the modified one passed in the function [except with a trick], but only the original).
	 *     The other reason is the fact we can easily know, in a POST hook, the damage the client has received, via the entvars "dmg_take" (this should be reliable I think).
	 * Return type: Integer (0 when no damage received [as on teammate attack with FF OFF] or when the damage killed the client, 1 when damage received and client still alive).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client receives damage.
	 * Information: Using the return value of the function in post may not always be a good thing in order to know some informations, mainly because this is quite basic/limited (0|1), while it would have been better to have additional return values (at least one more), or even via sum of bits for extending. */

	/* Function name (API): "CBasePlayer::TakeHealth".
	 * Function name (real): "CBasePlayer::TakeHealth".
	 * Format (callback): (iClientID, Float:flHealth, iDamageBits).
	 * Return type: Integer (0 when the client can not receive/loose health [has godmode or his health is equal/higher than his maximum health], 1 when the client has received/lost health).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client receives health. */

	/* Function name (API): "CBasePlayer::ThrowGrenade".
	 * Function name (real): "CBasePlayer::ThrowGrenade". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID, iWeaponEntityID, Float:vSource[3], Float:vThrow[3], Float:flExplodeTime, usEvent).
	 * Return type: Entity's CGrenade pointer (ID of the HE/flashbang/smoke grenade created).
	 * API required (ReGameDLL_CS): v5.4.
	 * Description: Called when a client throws a grenade.
	 * Information: It is an "all-in-one" hook which calls the CGrenade's functions (CGrenade::Shoot<Timed[2]|SmokeGrenade>) that create the grenades entities according to the type. */

	/* Function name (API): "CBasePlayer::TraceAttack".
	 * Function name (real): "CBasePlayer::TraceAttack".
	 * Format (callback): (iClientID, iInflictorID, Float:flDamage, Float:vDirection[3], pTraceResultHandle, iDamageBits).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when a client is attacked from a hit scan (knife or bullet shot). */

	/* Function name (API): "CBasePlayer::UpdateClientData".
	 * Function name (real): "CBasePlayer::UpdateClientData".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description:
	 *   Called when a client has some of his informations/datas (as members) updated due to some changes (health, armor, FOV, etc.).
	 *   Various game messages will be send in this function.
	 * Information: Do not confond it with the classic "pfnUpdateClientData" DLL API function, this is not the same content and not called at the same places. */

	/* Function name (API): "CBasePlayer::UseEmpty".
	 * Function name (real): "CBasePlayer::UseEmpty". It is a custom function specific to ReGameDLL_CS.
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.10.
	 * Description: Called when a client presses the "use" key and when nothing was used (nothing usable found around).
	 * Information: This is some kind of replacement/customization for a hook using the "pfnEmitSound" engine API function with "common/wpn_denyselect.wav" as sound (this sound is called inside that function). */


	/********************** CLASS -> CBasePlayerWeapon ***********************/

	/* Function name (API): "CBasePlayerWeapon::CanDeploy".
	 * Function name (real): "CBasePlayerWeapon::CanDeploy".
	 * Format (callback): (iWeaponEntityID).
	 * Return type: Integer (0 to refuse, 1 to accept).
	 * API required (ReGameDLL_CS): v5.12.
	 * Description: Called when the weapon entity of a client is gonna be deployed.
	 * Information: It can be used to disable the deploy of the weapon. */

	/* Function name (API): "CBasePlayerWeapon::DefaultDeploy".
	 * Function name (real): "CBasePlayerWeapon::DefaultDeploy".
	 * Format (callback): (iWeaponEntityID, const szViewModel[], const szWeaponModel[], iAnimationType, const szAnimationExtention[], iSkiplocal).
	 * Return type: Integer (0 to refuse, 1 to accept).
	 * API required (ReGameDLL_CS): v5.12.
	 * Description: Called when the weapon entity of a client is deployed.
	 * Informations:
	 *   This is called in the "C*::Deploy" game functions of each weapon.
	 *   Altering the weapons models here is a good and proper way to do that. */

	/* Function name (API): "CBasePlayerWeapon::DefaultReload".
	 * Function name (real): "CBasePlayerWeapon::DefaultReload".
	 * Format (callback): (iWeaponEntityID, iClipSize, iAnimationType, Float:flDelay).
	 * Return type: Integer (0 to refuse, 1 to accept).
	 * API required (ReGameDLL_CS): v5.12.
	 * Description: Called when the weapon entity of a client is reloaded.
	 * Information: This is called in the "C*::Reload" game functions of each weapon. */

	/* Function name (API): "CBasePlayerWeapon::DefaultShotgunReload".
	 * Function name (real): "CBasePlayerWeapon::DefaultShotgunReload". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function (but in the "C<M3|CXM1014>::Reload" game functions).
	 * Format (callback): (iWeaponEntityID, iAnimationType, iStartAnimationType, Float:flDelay, Float:flStartDelay, const szReloadSound1[], const szReloadSound2[]).
	 * Return type: Boolean (false on refusal, true on agreement).
	 * API required (ReGameDLL_CS): v5.12.
	 * Description: Called when the shotgun (M3/XM1014) weapon entity of a client is reloaded.
	 * Information: This is called in the "C<M3|CXM1014>::Reload" game functions. */

	/* Function name (API): "CBasePlayerWeapon::ItemPostFrame".
	 * Function name (real): "CBasePlayerWeapon::ItemPostFrame".
	 * Format (callback): (iWeaponEntityID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the weapon entity of a client is "thinking" (on every client frame).
	 * Information: This is the main function that handles actions of the inventory items (primary attack, secondary attack, reload, empty sound, etc.). */

	/* Function name (API): "CBasePlayerWeapon::KickBack".
	 * Function name (real): "CBasePlayerWeapon::KickBack".
	 * Format (callback): (iWeaponEntityID, Float:flUpBase, Float:flLateralBase, Float:flUpModifier, Float:flLateralModifier, Float:flUpMax, Float:flLateralMax, iDirectionChange).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the weapon entity of a client is shooting is order to apply some punch angles (crosshair recoil).
	 * Information: This is called in the "C*::*Fire" game functions. */

	/* Function name (API): "CBasePlayerWeapon::SendWeaponAnim".
	 * Function name (real): "CBasePlayerWeapon::SendWeaponAnim".
	 * Format (callback):
	 *   (iWeaponEntityID, iAnimationType, iSkipLocal).
	 *
	 *   Note: The "iSkipLocal" variable is to skip the animation playing in case of the client has prediction (setinfo "cl_lw") enabled.
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the weapon entity of a client is playing an animation to him. */


	/***************************** CLASS -> CGib *****************************/

	/* Function name (API): "CGib::BounceGibTouch".
	 * Function name (real): "CGib::BounceGibTouch".
	 * Format (callback): (iGibEntityID, iOtherEntityID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.17.
	 * Description: Called when a gib entity touches another entity. */

	/* Function name (API): "CGib::Spawn".
	 * Function name (real): "CGib::Spawn".
	 * Format (callback): (iGibEntityID, const szGibModelPath[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.17.
	 * Description: Called when a gib entity spawns.
	 * Information: This is called in the "Spawn<Head|Random>Gibs" game functions. */

	/* Function name (API): "CGib::WaitTillLand".
	 * Function name (real): "CGib::WaitTillLand".
	 * Format (callback): (iGibEntityID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.17.
	 * Description: Called when a gib entity thinks.
	 * Information: This is the function which makes the gib fades out slowly, then remove it after (by calling other functions inside, which do the removal job). */


	/*************************** CLASS -> CGrenade ***************************/

	/* Function name (API): "CGrenade::DefuseBombEnd".
	 * Function name (real): "CGrenade::DefuseBombEnd". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function (but in the "CGrenade::C4Think" game function).
	 * Format (callback): (iGrenadeEntityID, iClientID, bool:bDefused).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when the defusal of a C4 entity stops (cancelled or not, where the "bDefused" boolean will be false on cancelling, true on success).
	 * Information: This is called in the "CGrenade::C4Think" game function. */

	/* Function name (API): "CGrenade::DefuseBombStart".
	 * Function name (real): "CGrenade::DefuseBombStart". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function (but in the "CGrenade::Use" game function).
	 * Format (callback): (iGrenadeEntityID, iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when the defusal of a C4 entity starts.
	 * Information: This is called in the "CGrenade::Use" game function. */

	/* Function name (API): "CGrenade::ExplodeBomb". It is a renaming of an actual function.
	 * Function name (real): "CGrenade::Explode2".
	 * Format (callback): (iGrenadeEntityID, pTraceResultHandle, iDamageBits).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when a C4 explodes.
	 * Information: This is called in the "CGrenade::Detonate2" game function. */

	/* Function name (API): "CGrenade::ExplodeFlashbang". It is a renaming of an actual function.
	 * Function name (real): "CGrenade::Explode".
	 * Format (callback): (iGrenadeEntityID, pTraceResultHandle, iDamageBits).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when a flashbang grenade explodes.
	 * Information: This is called in the "CGrenade::Detonate" game function. */

	/* Function name (API): "CGrenade::ExplodeHeGrenade". It is a renaming of an actual function.
	 * Function name (real): "CGrenade::Explode3".
	 * Format (callback): (iGrenadeEntityID, pTraceResultHandle, iDamageBits).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when a HE grenade explodes.
	 * Information: This is called in the "CGrenade::Detonate3" game function. */

	/* Function name (API): "CGrenade::ExplodeSmokeGrenade". It is a renaming of an actual function.
	 * Function name (real): "CGrenade::SG_Detonate".
	 * Format (callback): (iGrenadeEntityID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when a smoke grenade explodes.
	 * Information: This is called in the "CGrenade::SG_TumbleThink" game function. */


	/************************** CLASS -> CWeaponBox **************************/

	/* Function name (API): "CWeaponBox::SetModel".
	 * Function name (real): "CWeaponBox::SetModel". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function (but in some others like "PackPlayerItem", etc.).
	 * Format (callback): (iWeaponBoxEntityID, const szModelPath[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when the model of a weapon box entity is set (at the end of its creation). */


	/**************** CLASS GROUP -> CSGameRules (CGameRules) ****************/

	/****************************** INFORMATIONS ******************************
	 * This is the class name of the API, but the real base class name is     *
	 * "CGameRules", and all of those hooks are only linked to the            *
	 * "CHalfLifeMultiplay" subclass, they will not be called when the other  *
	 * "CHalfLife<Training|Rules>" subclass will be loaded.                   *
	 * Also, those hooks do not pass the value of the "g_pGameRules" variable.*
	 *                                                                        *
	 *************************************************************************/

	/* Function name (API): "CSGameRules::BalanceTeams". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::BalanceTeams".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the teams are balanced by the game. */

	/* Function name (API): "CSGameRules::CanHavePlayerItem". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::CanHavePlayerItem".
	 * Format (callback): (iClientID, iInventoryItemEntityID).
	 * Return type: Integer (0 on failure [death, bot and unusable weapon, already have it with maximum ammunitions], or 1 on success).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the item is gonna be added to a client.
	 * Information: This is called in the "CBasePlayerItem::DefaultTouch" game function and right before the "CBasePlayer::AddPlayerItem" one (so only on buying or given by the game/plugin, but not on pick up from a ground touch). */

	/* Function name (API): "CSGameRules::CanPlayerHearPlayer". It is a renaming of an actual function.
	 * Function name (real): "CCStrikeGameMgrHelper::CanPlayerHearPlayer".
	 * Format (callback): (iListenerID, iSenderID).
	 * Return type: Boolean (false on refusal, true on agreement).
	 * API required (ReGameDLL_CS): v5.5.
	 * Description: Called when the voice status (can listen or not) between two clients is checked. */

	/* Function name (API): "CSGameRules::ChangeLevel". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::ChangeLevel".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the map is changed by the game (on time limit expired, win limit reached, etc.). */

	/* Function name (API): "CSGameRules::CheckMapConditions". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::CheckMapConditions".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the map conditions are checked (on a new map and on a new round).
	 * Informations:
	 *   This basically updates some CGameRules's members related to map objectives.
	 *   It might be wise to call it when you deal with such entities (by removing existing ones, or adding new ones). */

	/* Function name (API): "CSGameRules::CheckWinConditions". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::CheckWinConditions".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the win conditions are checked (on client join/changeteam/death/disconnect, C4 explosion, etc.). */

	/* Function name (API): "CSGameRules::CleanUpMap". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::CleanUpMap".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the map is cleaned up on a new round (this restores or remove some entities, clean up decals).
	 * Information: This is called in the "CHalfLifeMultiplay::RestartRound" game function. */

	/* Function name (API): "CSGameRules::ClientUserInfoChanged". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::ClientUserInfoChanged".
	 * Format (callback): (iClientID, szInfoBuffer[]).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the client user informations (setinfos) are changed.
	 * Information: This is called in the "pfnClientUserInfoChanged" DLL API function. */

	/* Function name (API): "CSGameRules::DeadPlayerWeapons". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::DeadPlayerWeapons".
	 * Format (callback): (iClientID).
	 * Return type: Integer (0 on refusal, 1 on agreement).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the inventory items of a dead client are gonna be dropped (this asks if the game can drop them or not).
	 * Information: This is called in the "CBasePlayer::PackDeadPlayerItems" game function. */

	/* Function name (API): "CSGameRules::DeathNotice". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::DeathNotice".
	 * Format (callback): (iClientID, iAttackerID, iInflictorID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game notifies a death of a client.
	 * Informations:
	 *   This is called in the "CHalfLifeMultiplay::PlayerKilled" game function.
	 *   This is the function that sends the "DeathMsg" message in the top-right corner of the screen, and prints the related line in the current server log file. */

	/* Function name (API): "CSGameRules::FlPlayerFallDamage". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::FlPlayerFallDamage".
	 * Format (callback): (iClientID).
	 * Return type: Float (value of the damage after a fall).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when fall damage is checked and before the game affects the damage to the client.
	 * Information: This is called in the "CBasePlayer::PostThink" game function. */

	/* Function name (API): "CSGameRules::FPlayerCanRespawn". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::FPlayerCanRespawn".
	 * Format (callback): (iClientID).
	 * Return type: Integer (0 on refusal, 1 on agreement).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game checks if a client can be respawned. */

	/* Function name (API): "CSGameRules::FPlayerCanTakeDamage". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::FPlayerCanTakeDamage".
	 * Format (callback): (iClientID, iAttackerID).
	 * Return type: Integer (0 on refusal, 1 on agreement).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game checks if a client can receive damage from an attacker. */

	/* Function name (API): "CSGameRules::FShouldSwitchWeapon". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::FShouldSwitchWeapon".
	 * Format (callback): (iClientID, iInventoryItemEntityID).
	 * Return type: Integer (0 on refusal, 1 on agreement).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game checks if a client can switch to the inventory item.
	 * Information: This is called in the "CBasePlayer::AddPlayerItem" game function. */

	/* Function name (API): "CSGameRules::GetNextBestWeapon". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::GetNextBestWeapon".
	 * Format (callback): (iClientID, iCurrentInventoryItemEntityID).
	 * Return type: Integer (0 when the current weapon can not be holstered or when no best weapon found, 1 when a best weapon has been found).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game checks the "next best weapon" (based on the weight) of a client and make him switch to it.
	 * Information: This is called after some events, as when you drop a weapon, throw your last grenade, etc.. */

	/* Function name (API): "CSGameRules::GetPlayerSpawnSpot". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::GetPlayerSpawnSpot".
	 * Format (callback): (iClientID).
	 * Return type: Entity's edict pointer (-1 or ID of the spawn point entity the client is gonna use for respawning).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game checks the "best spawn point" in order to respawn a client in that location. */

	/* Function name (API): "CSGameRules::GiveC4". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::GiveC4".
	 * Format (callback): ().
	 * Return type: Entity's CBasePlayer pointer (ID of the client who received the C4).
	 * API required (ReGameDLL_CS): v5.25 (since the implementation of the return value).
	 * Description: Called when the game gives the C4 to a client. */

	/* Function name (API): "CSGameRules::GoToIntermission". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::GoToIntermission".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game goes in "intermission" when this has ended (the point before the map change and where the scoreboard is displayed to clients). */

	/* Function name (API): "CSGameRules::OnRoundEnd".
	 *   Notes:
	 *     It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function (but in the "CHalfLifeMultiplay::CheckWinConditions" game function).
	 *     Also, the original API name was just "RoundEnd" but I have added the "On" prefix, then also the "CSGameRules" class.
	 * Function name (real): "CHalfLifeMultiplay::OnRoundEnd".
	 * Format (callback): (iWinStatus, ScenarioEventEndRound:iEventType, Float:flTerminateDelay).
	 * Return type: Boolean (false on refusal [scenario not won], true on agreement [scenario won]).
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the conditions in order to "end the round" are checked. */

	/* Function name (API): "CSGameRules::OnRoundFreezeEnd". It is a custom function specific to ReGameDLL_CS, the standard CS has not the code implemented in a standalone function (but in the "CHalfLifeMultiplay::CheckWinConditions" game function).
	 * Function name (real): "CHalfLifeMultiplay::OnRoundFreezeEnd".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the new round starts (right after the end of the freeze time, when the clients can start moving...). */

	/* Function name (API): "CSGameRules::PlayerGotWeapon". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::PlayerGotWeapon".
	 * Format (callback): (iClientID, iInventoryItemEntityID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the game notifies a client got a weapon in his inventory.
	 * Informationss:
	 *   This is called in the "CBasePlayer::AddPlayerItem" game function.
	 *   The content of that game function is empty (can just only be used as a notification, or, to implement your own when needed). */

	/* Function name (API): "CSGameRules::PlayerKilled". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::PlayerKilled".
	 * Format (callback): (iClientID, iAttackerID, iInflictorID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game notifies and triggers a few things when a client is killed.
	 * Informations:
	 *   This is called in the "CBasePlayer::Killed" game function.
	 *   This is the function that updates the score, rewards money, prints some messages about team kill, etc.. */

	/* Function name (API): "CSGameRules::PlayerSpawn". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::PlayerSpawn".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game equips the client with the "spawn items" and when the spawn protection is set (custom feature specific to the ReGameDLL_CS binary).
	 * Information: This is called in the "CBasePlayer::Spawn" game function. */

	/* Function name (API): "CSGameRules::RemoveGuns". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::RemoveGuns".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the game removes all the ground weapons (classes: "weaponbox", "weapon_shield").
	 * Information: This is called in the "CHalfLifeMultiplay::RestartRound" game function. */

	/* Function name (API): "CSGameRules::RestartRound". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::RestartRound".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description:
	 *   Called when the round is restarted (on each new round).
	 *   Using this function is good in order to replace the "HLTV" message used for detecting new round (with a PRE call type). */

	/* Function name (API): "CSGameRules::SendDeathMessage". It is a custom function specific to ReGameDLL_CS.
	 * Function name (real): "CHalfLifeMultiplay::SendDeathMessage".
	 * Format (callback): (iKillerID, iVictimID, iAssisterID, iInflictorID, const szKillerWeaponName[], DeathMessageFlags:iDeathMessageFlags, KillRarity:iRarityOfKill).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when a death message is sent.
	 * Information: This is called in the "CHalfLifeMultiplay::DeathNotice" game function. */

	/* Function name (API): "CSGameRules::ServerDeactivate". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::ServerDeactivate".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.0.
	 * Description: Called when the map is changed.
	 * Informations:
	 *   This is called in the "pfnServerDeactivate" DLL API function.
	 *   This is called right after the "plugin_end" hook. */

	/* Function name (API): "CSGameRules::TeamFull". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::TeamFull".
	 * Format (callback): (iTeamID).
	 * Return type: Integer (0 on refusal, 1 on agreement).
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the game checks if a team is full (usually when a client selects a team or for the bots).
	 * Information: This performs a comparison between the amount of clients in a team vs the amount of spawns available for it (deals with 4 CHalfLifeMultiplay's members). */

	/* Function name (API): "CSGameRules::TeamStacked". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::TeamStacked".
	 * Format (callback): (iNewTeamID, iCurrentTeamID).
	 * Return type: Integer (0 on refusal, 1 on agreement).
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the game checks if a team is stacked (usually when a client selects a team or for the bots).
	 * Information: This performs a comparison between the amount of clients in a team vs the ones in the opposite team and with the CVar "mp_limitteams" (deals with 3 CHalfLifeMultiplay's members). */

	/* Function name (API): "CSGameRules::Think". It is a renaming of an actual function.
	 * Function name (real): "CHalfLifeMultiplay::Think".
	 * Format (callback): ().
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when the game rules are thinking (major function called on each server frame). */


	/********************** CLASS GROUP -> CBotManager ***********************/

	/* Function name (API): "CBotManager::OnEvent".
	 * Function name (real): "CBotManager::OnEvent".
	 * Format (callback):
	 *   (GameEventType:iEventTypeID, iEntityID, iOtherID).
	 *
	 *   Note: The "iEventTypeID" variable is a "EVENT_*" from "reapi_const.inc" (above).
	 * Return type: None.
	 * API required (ReGameDLL_CS): v5.26.
	 * Description: Called when an event related to the bots occurs in the game.
	 * Information: Some events have invalid/null entities. */


	/**************************************************************************
	*             HOOK FUNCTIONS -> Metamod's module -> ReChecker             *
	**************************************************************************/

	/* Function name (API): "CmdExec".
	 * Function name (real): "CmdExec".
	 * Format (callback): (iClientID, pIResourceBufferHandle, const szCommand[], uiResponseHash).
	 * Return type: None.
	 * API required (ReChecker): v2.1.
	 * Description: Called on command execution. */

	/* Function name (API): "FileConsistencyFinal".
	 * Function name (real): "FileConsistencyFinal".
	 * Format (callback): (iClientID).
	 * Return type: None.
	 * API required (ReChecker): v2.1.
	 * Description: Called on file consistency end process. */

	/* Function name (API): "FileConsistencyProcess".
	 * Function name (real): "FileConsistencyProcess".
	 * Format (callback): (iClientID, pIResourceBufferHandle, iResourceType, uiResponseHash).
	 * Return type: None.
	 * API required (ReChecker): v2.1.
	 * Description: Called on file consistency start process. */
};

/* AMX hook call types.
 *
 * Notes:
 *   To use with the "ReAPI_HM_AddHookByType<ID|Name>" natives.
 *
 *   Those new and advanced call types methods allow to provide more possibilities to coders, and offer features not possible without.
 *   Because the classic "PRE" and "POST" call types were not enough for my opinion, so I had the idea of adding two more call types, used as "post/event" and being very useful in various situations.
 *   They basically make the related hooks "unalterable", which means nothing is taken is account.
 *   So you can not alter the parameters (even the reference ones), and you can not alter the return value (when the function returns something as an entity ID, a boolean, an integer, etc.).
 *   And the following ReAPI_AHRVF_* (ReAPI's AMX Hook Return Value Flag) are not applicable in them, except for the "cancel" modes (ReAPI_AHRVF_CANCEL_*), for some reasons I have only allowed this to be taken in account.
 *   The main goal of those new modes is to know "how this is gonna be as definitive status", so before the call (for the "ReAPI_AHCT_Pre2_Unalterable"), and after the call (for the "ReAPI_AHCT_Post2_Unalterable").
 *   The "ReAPI_AHCT_Post2_Unalterable" type is basically "useless" in a function that has no parameters with reference, and also no return value (classic void), but it is still available even if I could get the rid of it in such functions, via an internal workaround.
 *
 *   For example, you can use the "ReAPI_AHCT_Pre2_Unalterable" call type to act as PRE event, but with final status, and know if the function is gonna be blocked (supercede), and the final parameters that will be passed into it.
 *   But keep in mind that even if a hook using the "ReAPI_AHCT_Pre1_Alterable" type has been blocked (supercede), then if itself or another of the same type has changed the parameters,
 *   the next call types (Pre2, Post1, Post2) will pass the modified parameters even if they could not be applied due to the fact the function has been blocked.
 *   I think that when a function is blocked (supercede) in the "ReAPI_AHCT_Pre1_Alterable" call type, the original parameters will be more appropriated to be passed in the next types instead,
 *   but I did not do that only because we loose that information about the current parameters and how we wanted to modify them.
 *
 *   So if in a Pre2, or Post1 or Post2 hook, you need to deal with the parameters passed, I advice you to do something like this (example with "CBasePlayer::TakeDamage"):
 *     public HOOK_CBP_TakeDamage_Pre2(iClientID, iInflictorID, iAttackerID, Float:flDamage, iDamageBits) {
 *       // Check if the function itself has been blocked, based on the global status (function itself).
 *       if(ReAPI_HM_GetHookReturn(true, false) & ReAPI_AHRVF_Supercede) {
 *         // The function has been blocked (supercede) in a "ReAPI_AHCT_Pre1_Alterable" call type, so retrieve the original value (despite it may not be useful to do some code with this status since the function has been blocked...).
 *         ReAPI_HM_GetFunctionParameter(false, 4, flDamage)
 *       }
 *
 *       // Here is the rest of your plugin's code.
 *       ...
 *       return ReAPI_AHRVF_Ignored
 *     }
 *
 *   The other good alternative is to just skip some of your code from being called (that you could do most of the time instead of the previous example), especially if the function has been blocked, or if the parameters have been modified to a value which does not match to your criterias.
 *   Similar example:
 *     public HOOK_CBP_TakeDamage_Pre2(iClientID, iInflictorID, iAttackerID, Float:flDamage, iDamageBits) {
 *       // Check if the function itself has been blocked, based on the global status (function itself).
 *       // Ignore your next code if the function has been blocked or if the damage parameter has been changed to a value <= 0.0 (the client did not received damage).
 *       if((ReAPI_HM_GetHookReturn(true, false) & ReAPI_AHRVF_Supercede)
 *       || flDamage <= 0.0)
 *         return ReAPI_AHRVF_Ignored
 *
 *       // Here is the rest of your plugin's code which will only take effect when the client has received some damage.
 *       ...
 *       return ReAPI_AHRVF_Ignored
 *     }
 *
 *   If you think, that with the classic PRE and POST types (that you can have with the modules of the other addon, AMX Mod X...) you can do and know all of this properly, the answer is you can not!
 *   Because there could always be a next "PRE" callback which could alter the parameters or block the function, and you can not just predict this!
 *
 *   Which hook call type should you use according to your goals?
 *     If you wish to know things, before the function gets called, both "Pre" call types are for that (but the #2 is more as "event", as specified above).
 *     If you wish to know things, after then function was called, both "Post" call types are for that.
 *     If you wish to alter the parameters of a function, or, prevent it from being executed (internal code of it), you must use the "ReAPI_AHCT_Pre1_Alterable" call type.
 *
 *     However, about the functions that have a return type (non-void), like entity's pointer, boolean, integer, float, etc., you need to use the Post" call types in order to retrieve the original value (despite you might not get the real one if a call type with "Pre1" has blocked the function, but NULL/false/0, etc.).
 *     Also, if you wish to force a return value for a function (via the "ReAPI_HM_SetFunctionReturn" native), both main call types ("Pre1" and "Post1") can do the job, but which one could be the best?
 *     There are situations where you want to enforce a specific return value, and also you might not need to let the binary call the internal code of the function (since you are gonna force the return), so using the "Pre1" call type could be the solution.
 *     But it might be recommended (if in case you really want "the return value" to be the final one and so not overwritten by another following call) to specify the "ReAPI_AHRVF_LOCK_FunctionReturn" return value flag additionally to the "ReAPI_AHRVF_Override" or "ReAPI_AHRVF_Supercede" return value flag.
 *     Without the "ReAPI_AHRVF_LOCK_FunctionReturn" return value flag, a "Post1" call type which will be called after could be capable of changing your return value previously defined, and so, replace it.
 *     Also, if in case letting the original function from being called is not a problem, a "Pre1" call type with the "ReAPI_AHRVF_Override" return value flag instead of the "ReAPI_AHRVF_Supercede" could be better, because if no other "Pre1" call type block it,
 *     a "Post1" call type could be able to retrieve the "original return value", while this information could not be retrieved if you have supercede the function...
 *     However, if you do not wish to block the function call, using the "Post1" for forcing the return value might be the alternative, or better (due to the "overwritting capability"). */
enum ReAPI_AHCT {
	/* First call type on PRE (before the function call):
	 *   Everything is modifiable here, function's parameters (native "ReAPI_HM_SetFunctionParameter") and possible return value (native "ReAPI_HM_SetFunctionReturn").
	 *   All the following ReAPI_AHRVF_* types are accepted and workable. */
	ReAPI_AHCT_Pre1_Alterable,

	/* Second call type on PRE (before the function call):
	 *   Nothing is modifiable here, this only acts as an "event" but still on PRE.
	 *   Only the following ReAPI_AHRVF_CANCEL_* types are accepted and workable. */
	ReAPI_AHCT_Pre2_Unalterable,

	/* First call type on POST (after the function call):
	 *   Only the function's parameters via reference (native "ReAPI_HM_SetFunctionParameter") and possible return value (native "ReAPI_HM_SetFunctionReturn") are modifiable.
	 *   All the following ReAPI_AHRVF_* types are accepted and workable (but their effect will have limits, since this is a POST call type, but you can for example, replace a possible return value defined on a PRE hook). */
	ReAPI_AHCT_Post1_Alterable,

	/* Second call type on POST (after the function call):
	 *   Nothing is modifiable here, this only acts as an "event" but still on POST.
	 *   Only the following ReAPI_AHRVF_CANCEL_* types are accepted and workable. */
	ReAPI_AHCT_Post2_Unalterable,
};

/* AMX hook priority types.
 *
 * Notes:
 *   To use with the "ReAPI_HM_AddHookByType<ID|Name>" natives.
 *
 *   This is designed to set up "importance" level of the AMX hooks depending on the type of plugin or your code.
 *   But keep in mind that the first priority type (ReAPI_AHPT_Beginning), may not be the one you can consider as "high priority" because called in first.
 *   No! The simple reason is that in some situations, the middle (ReAPI_AHPT_Middle) or lastest type (ReAPI_AHPT_End), can have more "priority" than this first.
 *   The explanation is simple, if I take an example with function's parameters modified (via the native "ReAPI_HM_SetFunctionParameter") in multiple hooks using the "ReAPI_AHCT_Pre1_Alterable" call type, the latest AMX hook will basically overwrite the previous values.
 *   The exception can be in case of you use the locked or cancel modes (ReAPI_AHRVF_<LOCK|CANCEL>_*) with the hook using the "ReAPI_AHPT_Beginning" type, but the "locked" modes should only be used on high forcing priority, and the "cancel" ones should never be used.
 *   But to simplify, the "ReAPI_AHPT_Beginning" priority type (and with the "ReAPI_AHRVF_LOCK_*" modes for the parameters/return) should be used on massive enforcement and without compatibility with 3rd-party plugins or original return value,
 *   while the "ReAPI_AHPT_End" should be used for enforcement and with compatibility with 3rd-party plugins or original return values (because you can retrieve the custom parameters, original/custom return value, and base your changes according to them rather than according to the original parameters/return).
 *   However, if you do not want to bother with this, use the "ReAPI_AHPT_Middle" priority type. */
enum ReAPI_AHPT {
	ReAPI_AHPT_Beginning, /* Call the AMX hook before the others. */
	ReAPI_AHPT_Middle,    /* Call the AMX hook normally (no specific priority, it is like it will be called in the middle among all). */
	ReAPI_AHPT_End,       /* Call the AMX hook after the others. */
};

/* Parameters and return manager: Function return method types.
 *
 * Note: To use with the "ReAPI_HM_GetFunctionReturn" native. */
enum ReAPI_FRMT {
	ReAPI_FRMT_Original,       /* Retrieve the original return value of the function. Note: Can be NULL/0 when original function not triggered (on a PRE hook or when blocked), or, even if called. */
	ReAPI_FRMT_Custom,         /* Retrieve the custom return value set by the "ReAPI_HM_SetFunctionReturn" native with the "bCustom" boolean set to true. */
	ReAPI_FRMT_UsableByLocal,  /* Retrieve the original or custom return value (automatic method which uses the value that is "gonna be" used for the function, so either the original, either the custom).
	                            * Notes:
	                            *   This is based on the current AMX hook return value set in the callbacks of the local hook calls (retrievable by the "ReAPI_HM_GetHookReturn" native with the "bGlobal" boolean set to false).
	                            *   I usually do not recommend this method. */
	ReAPI_FRMT_UsableByGlobal, /* Retrieve the original or custom return value (automatic method which uses the value that is "gonna be" used for the function, so either the original, either the custom).
	                            * Notes:
	                            *   This is based on the current AMX hook return value set in the callbacks of the global hook calls (retrievable by the "ReAPI_HM_GetHookReturn" native with the "bGlobal" boolean set to true).
	                            *   I recommend this method rather than the previous one since this is related to the global function itself (which contains all the PRE and POST AMX hooks). */
};

/* AMX hook return value flags.
 *
 * Notes:
 *   To use with the "ReAPI_HM_GetHookReturn" native and in the AMX callbacks (hooks).
 *
 *   The following return value modes are via flags for various important reasons (enhance the programming power with more possibilities). */
enum {
	ReAPI_AHRVF_Unset = 0, /* Return value not set, this is the default value before any call of a set of hooks. */

	/* Main return flags.
	 *
	 * Notes:
	 *   Do not cumulate them together, they are not made for this and there is no need to, even if this will not cause problems internally.
	 *   For the "ReAPI_AHRVF_Override" and "ReAPI_AHRVF_Supercede" modes, those ones must be used when you want to force the function's custom return value to be the custom one instead of the original one (for non-void return functions), even in a "Post1" hook. */
	ReAPI_AHRVF_Ignored   = (1<<0), /* Same as "unset", does not block the function call, and does not apply the function's custom return value but the original one (for non-void return functions). */
	ReAPI_AHRVF_Handled   = (1<<1), /* Same as "ignored", except this can be used when you have modified the parameters, as notification (even if this can be known via the parameters natives). */
	ReAPI_AHRVF_Override  = (1<<2), /* Call the original function, and force the function's custom return value to be the custom one instead of the original one (for non-void return functions). */
	ReAPI_AHRVF_Supercede = (1<<3), /* Block the original function (only in a "Pre1" hook), and force the function's custom return value to be the custom one instead of the original one (for non-void return functions). */

	/* Locked return flags.
	 *
	 * Notes:
	 *   Those following modes should only be used on "high forcing", so usually on a "Pre1" hook when you wish to enforce the parameters or/and return value to be the definitive(s) one(s), no matter what would want the next calls in other plugins.
	 *   For the "ReAPI_AHRVF_LOCK_FunctionReturn" mode, it is recommended to use it with the "ReAPI_AHRVF_Override" or "ReAPI_AHRVF_Supercede" modes, in order to enforce the custom return value you may want,
	 *   however this might not properly take effect knowning the original or the custom return value might be used after, because this mode only locks the possibility to use the "ReAPI_HM_SetFunctionReturn" native, nothing more. */
	ReAPI_AHRVF_LOCK_FunctionParams = (1<<5), /* Lock the function's parameters, that means after that they can no longer be modified via the "ReAPI_HM_SetFunctionParameter" native. So either the original or the current will be used. */
	ReAPI_AHRVF_LOCK_FunctionReturn = (1<<6), /* Lock the function's return, that means after that they can no longer be modified via the "ReAPI_HM_SetFunctionReturn" native. So either the original or the custom will be used (depending on the previous main modes set). */
	ReAPI_AHRVF_LOCK_AMXHookReturn  = (1<<7), /* Unavailable (not implemented). This is a mode destined to lock all of those values, and also for a possible use with a "ReAPI_HM_SetHookReturn" native that is not implemented. */

	/* Cancel return flags.
	 *
	 * Notes:
	 *   Those modes allow to "cancel" (or "break" if you prefer) the calls of the current sets of hooks, or all the following ones.
	 *   That means the next hooks will not be called.
	 *   As recall, a "set of hooks", is "all the callbacks" of a single call type among the four ones available (ReAPI_AHCT_*).
	 *   This feature is available "in case of", but I strongly do not recommend to use those modes!
	 *   Instead, use the "ReAPI_HM_GetHookReturn" native in the next sets of hooks (like I did above in the examples of the "ReAPI_AHCT_*" call types) in order to skip your code from being called when there is no need (function blocked, etc.).
	 *
	 *   If I can give you an example (among a few) why it can be critical to use them, is when you have two hooks for a function, one on PRE, one on POST, and inside you put a global variable you set to true on PRE, false on POST.
	 *   Example:
	 *     new bool:g_bIsInCGameRulesCleanUpMap // Global variable that could be used in another part of the code.
	 *     public HOOK_CGR_CleanUpMap_Pre2() {
	 *       g_bIsInCGameRulesCleanUpMap = true
	 *     }
	 *     public HOOK_CGR_CleanUpMap_Post2() {
	 *       g_bIsInCGameRulesCleanUpMap = false
	 *     }
	 *
	 *     If in case another plugin chooses to "cancel" from a "Pre<1|2>" hook (with the mode "ReAPI_AHRVF_CANCEL_AllPost" for example), the callback "HOOK_CGR_CleanUpMap_Post2" will not be called, and the "g_bIsInCGameRulesCleanUpMap" global variable will not be set to false.
	 *     So this can lead to serious issues in the plugins and depending on the kind of code that have been made on them. */
	ReAPI_AHRVF_CANCEL_Current = (1<<8),  /* Stop/Cancel the current set of hooks. */
	ReAPI_AHRVF_CANCEL_AllPre  = (1<<9),  /* Stop/Cancel all the "PRE" hooks (so all the "ReAPI_AHCT_Pre1_Alterable" and "ReAPI_AHCT_Pre2_Unalterable"), but this can only have effect when you are in a PRE hook. */
	ReAPI_AHRVF_CANCEL_AllPost = (1<<10), /* Stop/Cancel all the "POST" hooks (so all the "ReAPI_AHCT_Post1_Alterable" and "ReAPI_AHCT_Post2_Unalterable"). */
};

/* Strings alteration/attribution methods types.
 *
 * Notes:
 *   To use with the "ReAPI_HM_SetFunction<Parameter|Return>" natives, in the parameter #2 or #3.
 *
 *   This a feature from the future AMX Mod version, but I have removed a few modes for the ReAPI version. */
enum StringAlterationMethodType {
	SAMT_Basic, /* Use classic method for "hardcoded" strings (non-pointer format, direct address of the string passed).
	             * Notes:
	             *   With the functions (parameters alteration...), this should only be used for the ones that pass an hardcoded array and copy the data as "output".
	             *   Like a "reference style" (**pszValue) without being a "real one".
	             *   For example, the "pfnClientConnect" and "pfnInconsistentFile" DLL API functions are concerned (for the reason parameters, where an array is passed). */

	SAMT_Address, /* Use an address of a string (pointer), and make the current variable address point to it. */
	SAMT_Local,   /* Use a global AMX buffer (unavailable).
	               * Note: This automatically redirects to "SAMT_DYNAMIC_NeverRemove". */

	/* Create a new dynamic string on such conditions:
	 *   o The address of the string does not match to any string (null data).
	 *   o The new length is higher than the current one (so we need a bigger string).
	 *   o The "SAMT_DYNAMIC_RemoveWhenNonEqual" method type is specified and the new length differs from the current one.
	 *
	 * However, this will simply alter the data of the existing string (via "memcpy"). */
	SAMT_DYNAMIC_RemoveWhenNonEqual, /* Remove the old string from the memory only when the new length differs from the current one.
	                                  * Note: This is usually critical/unadvised in various situations. */
	SAMT_DYNAMIC_RemoveWhenExceed,   /* Remove the old string from the memory only when the new length is higher than the current one.
	                                  * Note: This is more "safe" than the previous type, but still not as safe as the following one depending on the situations. */
	SAMT_DYNAMIC_NeverRemove,        /* Never remove the old string, even when a new one has been added due to different length.
	                                  * Note: This is a method strongly recommended in various situations, as when you alter a function parameter (in order to prevent crash due to removal of local string passed...). */

	/* Engine's string pool system. */
	SAMT_SP_Engine, /* Note: If in case the standard GoldSrc engine (or even the mighty Xash3D) is running instead of ReHLDS,
	                 * the system will use a string pool for already existing strings (engine fix to prevent useless memory reallocation).
	                 * Also, that string pool is used for lambda strings created by the game (hookable "AllocString" function calls). */

	/* AMX's temporary string pool system. */
	SAMT_TSP, /* Note: By default, any string created with it will be removed 0.05 second later (except when customized). */
};

