// HAWKEYE! - from Marvel Comics. Best Bowman ever, expert marksman. Avengers member.

/* CVARS - copy and paste to shconfig.cfg

//Hawkeye
hawk_level 9
hawk_health 75		//the health power hawkeye starts with... [def=75]
hawk_armor 100		//the armor power hawkeye starts with... [def=100]
hawk_speed 500		//the speed hawkeye can run with AUG or SIG... [def=500]
hawk_showdmg 1		//(0|1) - hide|show bullet damage.. [def=1]
hawk_freewpn 1		//Free Aug if CT / Sig if T [def=1]

*/

//CREDITS
//Thanks to everyone that helped with the autoshoot!
//DON'T CALL Hawkeye A RIP
//THANKS ALOT ASSKICR FOR THE HELP...


/*
* v1.1 - vittu - 12/27/05
*      - Cleaned up code.
*      - Fixed to work with sig correctly.
*      - Changed bodypart aim cvars to defines.
*      - Made it so Sig used for Ts and Aug for CTs
*
*   Hero is a partial rip of Anubis.
*
*/

#include <amxmod>
#include <superheromod>


//Autoshoot settings ***CHANGE AIM TRIGGER HERE*** (0-no 1-yes)
#define HEAD		1	//Default 1
#define CHEST		0	//Default 0
#define STOMACHE	0	//Default 0
#define ARMLEFT	0	//Default 0
#define ARMRIGHT	0	//Default 0
#define LEGLEFT	0	//Default 0
#define LEGRIGHT	0	//Default 0


// GLOBAL VARIABLES
new g_heroName[]="Hawkeye"
new bool:g_hasHawkeye[SH_MAXSLOTS+1]
new g_bodyPart[7] = {
	HEAD,
	CHEST,
	STOMACHE,
	ARMLEFT,
	ARMRIGHT,
	LEGLEFT,
	LEGRIGHT
}
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Hawkeye", "1.1", "a|eX / AssKicR")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("hawk_level", "9")
	register_cvar("hawk_health", "75")
	register_cvar("hawk_armor", "100")
	register_cvar("hawk_speed", "500")
	register_cvar("hawk_showdmg", "1")
	register_cvar("hawk_freewpn", "1")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(g_heroName, "Sig/Aug Auto-shoot", "Auto-shoot and run faster with Sig as T or Aug as CT. Also, see Damage.", false, "hawk_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("hawkeye_init", "hawkeye_init")
	shRegHeroInit(g_heroName, "hawkeye_init")

	// NEW SPAWN
	register_event("ResetHUD", "newSpawn", "b")

	// DAMAGE
	register_event("Damage", "hawkeye_damage", "b", "2!0", "3=0", "4!0")

	// AIM CHECK
	set_task(0.1, "hawkeye_aim", 0, "", 0, "b")

	// Let Server know about Hawkeye's variables
	shSetMaxHealth(g_heroName, "hawk_health")
	shSetMaxArmor(g_heroName, "hawk_armor")
	shSetMaxSpeed(g_heroName, "hawk_speed", "[8][27]")
}
//----------------------------------------------------------------------------------------------
public hawkeye_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1, temp, 5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has the hero
	read_argv(2, temp, 5)
	new hasPowers = str_to_num(temp)

	if ( hasPowers && is_user_alive(id) ) {
		if ( get_cvar_num("hawk_freewpn") ) {
			hawkeye_weapons(id)
		}
	}
	else if ( !hasPowers && g_hasHawkeye[id] && is_user_connected(id) ) {
		if ( get_cvar_num("hawk_freewpn") ) {
			if ( get_user_team(id) == 1 ) engclient_cmd(id, "drop", "weapon_sg552")
			else engclient_cmd(id, "drop", "weapon_aug")
		}
		shRemHealthPower(id)
		shRemArmorPower(id)
		shRemSpeedPower(id)
	}

	g_hasHawkeye[id] = (hasPowers != 0)
}
//----------------------------------------------------------------------------------------------
public newSpawn(id)
{
	if ( g_hasHawkeye[id] && is_user_alive(id) && shModActive() ) {
		if ( get_cvar_num("hawk_freewpn") ) {
			set_task(0.1, "hawkeye_weapons", id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public hawkeye_weapons(id)
{
	if ( is_user_alive(id) ) {
		if ( get_user_team(id) == 1 ) shGiveWeapon(id, "weapon_sg552")
		else shGiveWeapon(id, "weapon_aug")
	}
}
//----------------------------------------------------------------------------------------------
public hawkeye_damage(id)
{
	if ( !shModActive() || !is_user_connected(id) ) return

	if ( get_cvar_num("hawk_showdmg") ) {

		new attacker = get_user_attacker(id)

		if ( attacker <= 0 || attacker > 32 || id <= 0 || id > 32 || id == attacker ) return

		new damage = read_data(2)

		if ( is_user_connected(attacker) && g_hasHawkeye[attacker] ) {
			set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, 78)
			show_hudmessage(attacker, "%i", damage)
		}

		if ( is_user_connected(id) && g_hasHawkeye[id] ) {
			set_hudmessage(200, 0, 0, -1.0, 0.48, 2, 0.1, 4.0, 0.02, 0.02, 80)
			show_hudmessage(id, "%i", damage)
		}
	}
}
//----------------------------------------------------------------------------------------------
public hawkeye_aim()
{
	if ( !shModActive() ) return

	new players[SH_MAXSLOTS], pnum, id
	get_players(players, pnum, "a")

	for (new i = 0; i < pnum; i++) {
		id = players[i]

		if ( is_user_alive(id) && g_hasHawkeye[id] ) {
			new clip, ammo, wpnid = get_user_weapon(id, clip, ammo)

			if ( clip > 0 && ((wpnid == CSW_SG552 && get_user_team(id) == 1) || (wpnid == CSW_AUG && get_user_team(id) == 2)) ) {
				new tid, tbody
				get_user_aiming(id, tid, tbody)

				if ( is_user_alive(tid) && get_user_team(id) != get_user_team(tid) ) {
					--tbody

					if ( g_bodyPart[tbody] ) {
						client_cmd(id, "+attack")
						client_cmd(id, "wait")
						client_cmd(id, "-attack")
						client_cmd(id, "wait")
					}
				}
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
