#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#include "../my_include/superheromod.inc"
#include "../my_heroes/sh_aux_stuff/sh_aux_inc.inc"
#include "../my_heroes/sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "../my_heroes/freeze_fx/freeze_fx.inc"
#include "../my_heroes/custom_grenades/custom_grenades.inc"
#include "../my_include/my_author_header.inc"

#define gVERSION "1.1"
#define GLOCE_DSPT "Icy Powers - Slow down your enemies with your Ice glock"

#define g_model "models/shmod/v_gloce.mdl"

new gloce_glock
new gloce_pct

new gloce_times
new gloce_time




new g_HeroName[] = "Gloce"
new gHeroID

new times_id[SH_MAXSLOTS+1]

public plugin_init()
{
	my_authored_register_func("SUPERHERO Gloce", gVERSION, "[A]tomen",true,AUTHOR)

	//Register Events
	register_event("CurWeapon", "weapon_event", "be", "1=1")


	RegisterHam(Ham_TakeDamage, "player", "fwd_Ham_TakeDamage_post",1,true)

	//Register Cvars
	register_cvar("gloce_level", "7" )
	register_cvar("gloce_version", gVERSION, FCVAR_SERVER|FCVAR_SPONLY)

	gloce_glock = register_cvar("gloce_glock", "1")
	gloce_pct = register_cvar("gloce_percent", "30")

	gloce_times = register_cvar("gloce_times", "5")
	gloce_time = register_cvar("gloce_freeze_time", "5")

	//Create Hero
	gHeroID=shCreateHero(g_HeroName, "Ice Glock", GLOCE_DSPT, false, "gloce_level")

	sh_register_superheromod_weapon_model(gHeroID,CSW_GLOCK18,g_model)

}

//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode){
	if(heroID!=gHeroID) return
	
	if(sh_user_has_hero(id,gHeroID))
	{
		times_id[id] = get_pcvar_num(gloce_times)

	}
}

public sh_client_spawn(id)
{
	if(is_user_alive(id) && sh_is_active() && is_user_connected(id))
	{

		times_id[id] = get_pcvar_num(gloce_times)
		if(sh_user_has_hero(id,gHeroID) && get_pcvar_num(gloce_glock))
		{
			give_custom_grenades(id,GREN_FREEZE,5)
			ham_give_weapon(id, "weapon_glock18")
			ExecuteHam(Ham_GiveAmmo, id, 80, "9mm", 120)
		}
	}

	return HAM_IGNORED
}

public fwd_Ham_TakeDamage_post(id, nothing, Attacker, Float:fDamage)
{
	if(!is_user_connected(Attacker)) return HAM_IGNORED

	else if(is_user_alive(id) && sh_is_active() && is_user_connected(id))
	{
		new Float:fHealth
		pev(id, pev_health, fHealth)

		if(fHealth - fDamage > 0.0)
		{
			new weapon = get_user_weapon(Attacker)
			if((cs_get_user_team(id)!=cs_get_user_team(Attacker))&&(weapon == CSW_GLOCK18) && sh_user_has_hero(Attacker,gHeroID)&& (times_id[Attacker] > 0))
			{
				if(generate_int(0, 100) <= get_pcvar_num(gloce_pct))
				{
					sh_freeze_user(id,get_pcvar_float(gloce_time),130.0)
					times_id[Attacker]--
				}
			}
		}
	}

	return HAM_IGNORED
}

public weapon_event(id)
{
	if(sh_is_active())
	{
		new weaponid = read_data(2)

		if(sh_is_user_frozen(id) && weaponid != CSW_GLOCK18)
		{
			set_pev(id, pev_maxspeed, 130.0)
		}

		else if(sh_is_user_frozen(id) && weaponid == CSW_GLOCK18 && sh_user_has_hero(id,gHeroID))
		{
			set_pev(id, pev_maxspeed, 130.0)

		}
	}

}


public client_connect(id)
{
	times_id[id] = 0
}

public client_disconnected(id)
{
	times_id[id] = 0
}


stock ham_give_weapon(id,weapon[])
{
    if(!equal(weapon,"weapon_",7)) return 0;

    new wEnt = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,weapon));
    if(!pev_valid(wEnt)) return 0;

    set_pev(wEnt,pev_spawnflags,SF_NORESPAWN);
    dllfunc(DLLFunc_Spawn,wEnt);
    
    if(!ExecuteHamB(Ham_AddPlayerItem,id,wEnt))
    {
        if(pev_valid(wEnt)) set_pev(wEnt,pev_flags,pev(wEnt,pev_flags) | FL_KILLME);
        return 0;
    }

    ExecuteHamB(Ham_Item_AttachToPlayer,wEnt,id)
    return 1;
}
