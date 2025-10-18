/* ATAC Functions
*
* Copyright © 2006-2007, ATAC Team
*
* This file is provided as is (no warranties).
*
*/

#if defined _atac_included
	#endinput
#endif
#define _atac_included

#pragma reqlib atac

#define ATAC_HOOK_CONTINUE 0
#define ATAC_HOOK_SPAWNED 1
#define ATAC_HOOK_RESET 2

// Register a punishment returns -1 on failure. Allows hooking any forward from [Punishments]
native atac_register_punishment();

// Called when ATAC builds it's Team Kill Menu. You must return with EngFunc_AllocString! [Punishments]
forward atac_punishment_name(victim);

// Called when a punishment is chosen. [Punishments]
forward atac_player_punish(killer, victim);

// Called when a player dies and just before a player respawns. [Punishments]
forward atac_player_reset(killer, victim);

// Called when a player (re)spawns. [Punishments]
forward atac_player_spawn(killer, victim);


// Register a addon returns -1 on failure. Allows hooking any forward from [Addons]
native atac_register_addon();

// Called when a team attack occurs. [Addons]
forward atac_team_attack(attacker, victim, damage);

// Called when a team kill occurs. [Addons]
forward atac_team_kill(killer, victim);

// Called when a team kill increment occurs. This forward can supercede ATAC's banning system by: return PLUGIN_HANDLED [Addons]
forward atac_punished(killer, const name[], const authid[]);


// Returns -1 on failure or plugin index if punishment is valid
native is_punishment_valid(index);

// Returns maximum amount of punishments registered
native get_maxpunishments();

// Gets the amount of Team Attacks done by a player
native get_atac_attacks(id);

// Sets the amount of Team Attacks done by a player
native set_atac_attacks(attacker, amount, victim=0);

// Gets the amount of Team Kills done by a player
native get_atac_kills(id);

// Sets the amount of Team Kills done by a player
// item 0 - No menu, 1 - Show Menu to Victim, anything higher activates a specific punishment
// ignoring TeamKills
native set_atac_kills(killer, amount=-1, victim=0, item=0);
