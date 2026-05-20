#if defined sh_shard_cannon_funcs
  #endinput
#endif
#define sh_shard_cannon_funcs

#define SHARD_CANNON_DAMAGE 62 // 122 for Zombie

#define SHARD_CANNON_CLIP 6
#define SHARD_CANNON_BPAMMO 80

#define SHARD_CANNON_SPEED 0.75

#define SHARD_CANNON_MODEL_V "models/shmod/adriano/shard_cannon/v_shard_cannon.mdl"
#define SHARD_CANNON_MODEL_P "models/shmod/adriano/shard_cannon/p_shard_cannon.mdl"
#define SHARD_CANNON_MODEL_W "models/shmod/adriano/shard_cannon/w_shard_cannon.mdl"


enum
{
	ANIME_IDLE = 0,
	ANIME_SHOOT,
	ANIME_SHOOT2,
	ANIME_SHOOT3,
	ANIME_SHOOT4,
	ANIME_SHOOT5,
	ANIM_INSERT,
	ANIM_AFTER_RELOAD,
	ANIM_START_RELOAD,
	ANIM_DRAW
}

enum
{
	EVENT_NONE = 0,
	EVENT_ATTACK1,
	EVENT_ATTACK2,
	EVENT_RELOAD
}

#define CSW_SHARD_CANNON CSW_DEAGLE

#define WEAPON_SECRETCODE 24062015
#define OLD_W_MODEL "models/w_deagle.mdl"
#define OLD_EVENT "events/deagle.sc"

// MACROS


native shard_cannon_set_shard_cannon(id)
native shard_cannon_unset_shard_cannon(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
