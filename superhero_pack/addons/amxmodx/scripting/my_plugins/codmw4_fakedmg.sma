#include "../include/nvault.inc"
#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../include/hamsandwich.inc"
#include "../include/fakemeta.inc"
#include "../include/fakemeta_util.inc"
#include "../include/engine.inc"
#include "../include/fun.inc"
#include "../include/csx.inc"
#include "../include/cstrike.inc"
#include "../include/Vexd_Utilities.inc"
#include "my_include/codmw4_fakedmg.inc"



#define PLUGIN "Call of Duty: MW4 extrawpns"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


new const DAMAGE_ENTITY_NAME[] = "trigger_hurt"


public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);


}

public plugin_natives(){

	register_native("fake_damage","_fake_damage",0);
	register_native("kill_user","_kill_user",0);
	


}

public _fake_damage(iPlugin,iParams)
{
	new attacker=get_param(1)
	new victim=get_param(2)
	new wpnname[128];
	get_array(3,wpnname,128)
	new Float:takedamage=get_param_f(4)
	new damagetype=get_param(5)
	// Used quite often :D
	static entity, temp[16]
	
	entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, DAMAGE_ENTITY_NAME))
	if (entity)
	{
		// Set the damage inflictor
		set_pev(victim, pev_dmg_inflictor, attacker)
		
		
		// Takedamages only do half damage per attack (damage is damage per second, and it's triggered in 0.5 second intervals).
		// Compensate for that.
		formatex(temp, 15, "%f", takedamage*2)
		set_keyvalue(entity, "dmg", temp, DAMAGE_ENTITY_NAME)
		
		formatex(temp, 15, "%i", damagetype)
		set_keyvalue(entity, "damagetype", temp, DAMAGE_ENTITY_NAME)
		
		set_keyvalue(entity, "origin", "8192 8192 8192", DAMAGE_ENTITY_NAME)
		dllfunc(DLLFunc_Spawn, entity)
		
		set_pev(entity, pev_classname, wpnname)
		set_pev(entity, pev_owner, attacker)
		dllfunc(DLLFunc_Touch, entity, victim)
		set_pev(entity, pev_flags, FL_KILLME)
		
		// Make sure the damage inflictor is not overwritten by the entity
		set_pev(victim, pev_dmg_inflictor, attacker)
		
		return 1
	}
	
	return 0
}
public _kill_user(iPlugin,iParams)
{
	new wpnname[128];
	get_array(1,wpnname,128)
	new victim=get_param(2)
	new attacker=get_param(3)
	// Get some information about the victim
	new flags = pev(victim, pev_flags)
	new bool:isVictimMonster = (flags & FL_MONSTER) ? true : false
	new Float:takeDamage
	
	pev(victim, pev_takedamage, takeDamage)
	
	// We do not cause any damage if the victim has godmode
	if((flags & FL_GODMODE || takeDamage == 0.0))
	{
		return 0
	}
	
	
	new Float:fragIncreasement = 1.0	// By default, a player just gets 1 frag for killing an enemy
	
	
	new Float:frags
	pev(attacker, pev_frags, frags)
	
		// Templay, increase/decrease frags
	if(isVictimMonster)
	{
			// Player's and monsters can't be in the same team I think ^^
		frags += fragIncreasement
	} else {
		if(get_user_team(attacker) != get_user_team(victim))
		{
			frags += fragIncreasement
		} else {
			frags -= fragIncreasement
		}
	}
	set_pev(attacker, pev_frags, frags)
	
	
	// If the player killed a monster, we shouldn't continue on here
	if(isVictimMonster)
	{
		return 1
	}
	
	new aname[32], aauthid[32], ateam[10]
	get_user_name(attacker, aname, 31)
	get_user_team(attacker, ateam, 9)
	get_user_authid(attacker, aauthid, 31)
	
 	if(attacker != victim) 
	{
 		new vname[32], vauthid[32], vteam[10]
		get_user_name(victim, vname, 31)
		get_user_team(victim, vteam, 9)
		get_user_authid(victim, vauthid, 31)
		
		// Log the kill information
		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", 
			aname, get_user_userid(attacker), aauthid, ateam, 
		 	vname, get_user_userid(victim), vauthid, vteam, wpnname)
	} else {
		// User killed himself xD
		log_message("^"%s<%d><%s><%s>^" committed suicide with ^"%s^"", 
			aname, get_user_userid(attacker), aauthid, ateam, wpnname)
	}
	return 1
}
// Fakemeta has no "DispatchKeyValue"
set_keyvalue(entity, key[], data[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, data)
	set_kvd(0, KV_fHandled, 0)
	dllfunc(DLLFunc_KeyValue, entity, 0)
}
