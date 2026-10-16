 /*
 Version 0.1 posted
 Version 0.2 Fixed by Om3g[A] ( on the original code was some compline errors )
 */
 
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#include <amxmisc>
#include <csx>
#include "../my_include/superheromod.inc"
#include "../my_heroes/sh_aux_stuff/sh_aux_inc.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "../my_heroes/sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


 // GLOBAL VARIABLES
 new gHeroName[]="Storm"
 new gHeroID
 new gStormTimer[SH_MAXSLOTS+1]
 new lightning,Fire

new lightning_bolt_wpn_id
new dmg_source_name_short_lightning_bolt[SAFE_BUFFER_SIZE+1]="lightning_bolt"
new dmg_source_name_log_lightning_bolt[SAFE_BUFFER_SIZE+1]="lightning_bolt"
new STORM_TASK_ID = 0
 //----------------------------------------------------------------------------------------------
 public plugin_init()
 {
	// Plugin Info
	register_plugin("SUPERHERO Storm","0.2","[FTW]-S.W.A.T/Om3g[A]")

	create_cvar("storm_level", "0" )
	create_cvar("storm_cooldown", "30" )
	create_cvar("storm_time", "15")
	create_cvar("storm_radius", "200")
	create_cvar("storm_maxdamage", "15")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID=shCreateHero(gHeroName, "Call Thunder", "Storm calls thunder from the sky - beware!", true, "Storm_level" )
	STORM_TASK_ID = allocate_typed_task_id(player_task)

	lightning_bolt_wpn_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_lightning_bolt,
								dmg_source_name_log_lightning_bolt,
								0)
 }
 //----------------------------------------------------------------------------------------------
 public plugin_precache()
 {
	lightning = engfunc(EngFunc_PrecacheModel,"sprites/lgtning.spr")
	Fire = engfunc(EngFunc_PrecacheModel,"sprites/zerogxplode.spr")
 }
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, sh_init_mode:mode){
	if(heroID!=gHeroID) return

	if (sh_get_user_has_hero(id,gHeroID)) {
		sh_unset_cooldown_flag(id)
		gStormTimer[id] = -1
	}
	remove_task(id+STORM_TASK_ID)

 }
 //----------------------------------------------------------------------------------------------
 public sh_client_death(id)
 {
	if (sh_get_user_has_hero(id,gHeroID))
	{
		if ( gStormTimer[id]>0 )
		{
			remove_task(id+STORM_TASK_ID)
			gStormTimer[id] = -1
		}
	}
	return PLUGIN_HANDLED
 }
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
sh_unset_cooldown_flag(id)
remove_task(id+STORM_TASK_ID)
gStormTimer[id] = -1
return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		Storm_kd(id)
	}
}
}
 //----------------------------------------------------------------------------------------------
 // RESPOND TO KEYDOWN
 public Storm_kd(id) {

	if ( sh_get_cooldown_flag(id))
	{
		sh_sound_deny(id)
		return PLUGIN_HANDLED
	}

	gStormTimer[id]=get_cvar_num("storm_time")+1

	new StormCooldown=get_cvar_num("storm_cooldown")
	if ( StormCooldown>0 ) sh_set_cooldown(id, StormCooldown * 1.0 )

	new args[1]
	args[0] = id 

	set_task(1.0,"Storm_loop",id+STORM_TASK_ID,"",0,"b" )
	set_task(1.0,"randomtime",id+STORM_TASK_ID,args,1,"a", gStormTimer[id])
	
	return PLUGIN_HANDLED
 }
 //----------------------------------------------------------------------------------------------
 public lightningbolt(args[])
 {
 	new id = args[0]

	new Float:origin[3]
	new porigin1[3],porigin2[3],forigin[3]
	new victim, victim2

	victim= pick_random_player(GetPlayers_ExcludeDead)
	victim2= pick_random_player(GetPlayers_ExcludeDead)
	if(!victim ||! victim2){

		return
	}
	get_user_origin(victim,porigin1)
	get_user_origin(victim2,porigin2)
	forigin[0]=(porigin1[0]+porigin2[0])/2
	forigin[1]=(porigin1[1]+porigin2[1])/2
	forigin[2]=(porigin1[2]+porigin2[2])/2
	origin[0]=float(forigin[0]+generate_int(1,500))
	origin[1]=float(forigin[1]+generate_int(1,500))
	origin[2]=float(forigin[2])

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_BEAMPOINTS)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2])+1000000)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2])-20000)
	write_short(lightning)   // model
	write_byte(1) // start frame
	write_byte(20) // framerate
	write_byte(6) // life
	write_byte(500)  // width
	write_byte(2)   // noise
	write_byte(230)   // r, g, b
	write_byte(230)   // r, g, b
	write_byte(50)   // r, g, b
	write_byte(1000)   // brightness
	write_byte(2)      // speed
	message_end()

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_BEAMPOINTS)
	write_coord(floatround(origin[0])-10)
	write_coord(floatround(origin[1])-10)
	write_coord(floatround(origin[2])+1000000)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2])-20000)
	write_short(lightning)   // model
	write_byte(1) // start frame
	write_byte(20) // framerate
	write_byte(6) // life
	write_byte(500)  // width
	write_byte(2)   // noise
	write_byte(230)   // r, g, b
	write_byte(230)   // r, g, b
	write_byte(50)   // r, g, b
	write_byte(1000)   // brightness
	write_byte(2)      // speed
	message_end()

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_BEAMPOINTS)
	write_coord(floatround(origin[0])+10)
	write_coord(floatround(origin[1])+10)
	write_coord(floatround(origin[2])+1000000)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2])-20000)
	write_short(lightning)   // model
	write_byte(1) // start frame
	write_byte(20) // framerate
	write_byte(6) // life
	write_byte(500)  // width
	write_byte(2)   // noise
	write_byte(230)   // r, g, b
	write_byte(230)   // r, g, b
	write_byte(50)   // r, g, b
	write_byte(1000)   // brightness
	write_byte(2)      // speed
	message_end()

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_EXPLOSION)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(Fire)
	write_byte(100)
	write_byte(50)
	write_byte(0)
	message_end()

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_EXPLOSION)
	write_coord(floatround(origin[0])+50)
	write_coord(floatround(origin[1])+50)
	write_coord(floatround(origin[2]))
	write_short(Fire)
	write_byte(100)
	write_byte(100)
	write_byte(0)
	message_end()

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_EXPLOSION)
	write_coord(floatround(origin[0])-50)
	write_coord(floatround(origin[1])-50)
	write_coord(floatround(origin[2]))
	write_short(Fire)
	write_byte(100)
	write_byte(150)
	write_byte(0)
	message_end()

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION2)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_byte(188) // start color
	write_byte(10) // num colors
	message_end()

	DamageRadius(id, origin)
 }
 //----------------------------------------------------------------------------------------------
 public DamageRadius(id,Float: origin[3]) {
	new Float: distanceBetween
	new damage = get_cvar_num("storm_maxdamage")
	new Float: radius = get_cvar_float("storm_radius")
	new FFOn = get_cvar_num("mp_friendlyfire")
	static entlist[33];
	new numfound = find_sphere_class(0,"player", radius ,entlist, 32,origin);
	static vic
	for(new i = 0; i< numfound; i++)
	{	
		vic = entlist[i]

		if( is_user_alive(vic) && ( get_user_team(id) != get_user_team(vic) || FFOn != 0 || vic==id ) )
		{
			new Float:origin1[3]
			pev(vic, pev_origin, origin1)
			distanceBetween = vector_distance(origin, origin1 )

			//client_print(id, print_chat, "debug - origin %d, %d, %d", origin[0],origin[1],origin[2])
			//client_print(id, print_chat, "debug - distanceBetween %d", distanceBetween)

			if( distanceBetween < radius )
			{
				new Float: dRatio = distanceBetween / radius
				new adjdmg = damage - floatround(damage * dRatio)
				sh_extra_damage(vic, id, adjdmg,
								_,_,_,_,_,
								SH_NEW_DMG_ENERGY_BLAST,
								lightning_bolt_wpn_id)
			} // distance
		} // alive target...
	} // loop
 }
 //----------------------------------------------------------------------------------------------
 public randomtime(args[])
 {
 	new id = args[0]

	set_task(generate_int(1,4)*1.0,"lightningbolt",id+STORM_TASK_ID,args,1)
	set_task(generate_int(1,4)*1.0,"lightningbolt",id+STORM_TASK_ID,args,1)
 }
 //----------------------------------------------------------------------------------------------
 public Storm_loop()
 {
 	if (!hasRoundStarted()) return

	for ( new id=1; id< sh_maxplayers()+1; id++ )
	{
		if ( sh_get_user_has_hero(id,gHeroID) && is_user_alive(id)  )
		{
			if ( gStormTimer[id]>0 )
			{
				gStormTimer[id]--
			}
			else
			{
				if ( gStormTimer[id] == 0 )
				{
					gStormTimer[id] = -1
					remove_task(id+STORM_TASK_ID)
				}
			}
		}
	}
 }
 //----------------------------------------------------------------------------------------------
 public client_disconnected(id)
 {
	if ( id <= 0 || id > SH_MAXSLOTS ) return

	// Yeah don't want any left over residuals
	remove_task(id+1337)
	gStormTimer[id] = -1
 }
 //----------------------------------------------------------------------------------------------



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1030\\ f0\\ fs16 \n\\ par }
*/
