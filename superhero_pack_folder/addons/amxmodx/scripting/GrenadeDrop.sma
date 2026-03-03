/*******************************************************************
GrenadeDrop ==> Drop grenades on player's death

This is a simple plugin of CS drop grenades on player's death.
And it just a rewrite edition of Aalanche's "CSNadeDrops"( http://forums.alliedmods.net/showthread.php?p=70493 ),
I gained idea & learn much from Aalanche & jopmako, thanks very much! 

-------------------------------------------------------
Modul:

<amxmodx>
<engine>
<fakemeta>

-------------------------------------------------------
CVAR:

amx_gDrop <1|0> //on|off drop grenades

-------------------------------------------------------
Credits:

Aalanche & jopmako & VEN & more...

********************************************************************/
   
#include <amxmodx>
#include <fakemeta>

#define PLUGIN  "Ryu_GrenadeDrop"
#define VERSION "0.2"
#define AUTHOR  "CZ*Ryu"

new Goffset = 10,bool:hadgEnt = false,MAXPLAYERS
new GtypeNum[3] = {4,25,9},GitemID[3][] = {"15","14","18"}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	new modname[32]
	get_modname(modname, 31)
	if ( !equal(modname, "cstrike") )	 pause("ae")
	register_event("HLTV", "Clean_Grenade", "a", "1=0", "2=0")
	register_event("Damage", "Drop_Grenade", "b", "2!=0")
	register_cvar("amx_gDrop", "1")
	MAXPLAYERS = get_maxplayers()
}

public Drop_Grenade(id)
{
	if ( get_cvar_num("amx_gDrop") != 1 || get_user_health(id) > 0 )	return PLUGIN_CONTINUE
	static clip,ammo,gEnt,Float:pOrigin[3],Float:gOrigin[3],i
	pev(id, pev_origin, pOrigin)
	gOrigin[2] = pOrigin[2]
	for ( i=0; i<3; i++ )
	{
		if ( user_has_weapon(id, GtypeNum[i]) )
		{
			get_user_ammo(id, GtypeNum[i], clip, ammo)
			while ( ammo-->0 )
			{
				hadgEnt = true
				gEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "armoury_entity"))
				if ( gEnt)
				{
					fm_set_kvd(gEnt, "item", GitemID[i], "")
					fm_set_kvd(gEnt, "count", "1", "")
					set_pev(gEnt, pev_classname, "droppedgrenade")
					gOrigin[0] = pOrigin[0] + float(Goffset * i)
					gOrigin[1] = pOrigin[1] + float((Goffset+5) * ammo)
					set_pev(gEnt, pev_origin, gOrigin)
					dllfunc(DLLFunc_Spawn, gEnt) 
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public Clean_Grenade()
{
	if ( hadgEnt )
	{
		hadgEnt = false
		new gEnt = -1
		while ( (gEnt = engfunc(EngFunc_FindEntityByString, gEnt, "classname", "droppedgrenade")) > MAXPLAYERS )
			engfunc(EngFunc_RemoveEntity, gEnt)
	}
	return PLUGIN_CONTINUE
}

stock fm_set_kvd(entity, const key[], const value[], const classname[] = "")
{//This is code of VEN's Fakemeta Utilities,thanks
	if (classname[0])	set_kvd(0, KV_ClassName, classname)
	else
	{
		new class[32]
		pev(entity, pev_classname, class, 31)
		set_kvd(0, KV_ClassName, class)
	}
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)
	return dllfunc(DLLFunc_KeyValue, entity, 0)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset134 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2052\\ f0\\ fs16 \n\\ par }
*/
