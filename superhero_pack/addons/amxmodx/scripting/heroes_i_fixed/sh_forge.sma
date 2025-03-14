//Forge - 	1.x update by heliumdream
//				recode based on Missiles Launcher 3.8.2 (amx_ejl_missiles.sma)
//				by Eric Lidman & jtp10181

/*
//Forge
Forge_cooldown 6 		//How long it takes Forge to reload
Forge_damage 80			//How much damage will be dealt (According to how far away missile is)
Forge_velocity 2000		//Speed of Forge's missile
Forge_force 500.0		//How much player hit by missile will fly up into the air with
Forge_radius 400		//The radius from where missile hit people will be damaged
Forge_obeygravity 0		//Makes missile obey server gravity rules 1 -yes, 0 - no
Forge_effects 2			//1 Regualy missile, no effects
						//2 Yellow sprites around missile - laggy
						//3 Light given off around missile
						//4 2 & 3 combined								
*/


#include <amxmod>
//#include <amxmisc>
#include <Vexd_Utilities>
#include <superheromod>

//#if defined AMX98
//  #include <cmath>
//#endif

new gHeroName[]="Forge"
new bool:g_hasForgePower[SH_MAXSLOTS+1]

//new sprite, sprite1, sprite2, sprite3
//new beam, boom
new beam, sprite1, sprite2, sprite3
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Forge", "1.0", "SRGrty")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	register_cvar("Forge_level", "7")
	register_cvar("Forge_cooldown", "20.0")
	register_cvar("Forge_damage", "40")
	//register_cvar("Forge_randmg", "1")
	//register_cvar("Forge_mindmg", "15")
	//register_cvar("Forge_maxdmg", "60")
	register_cvar("Forge_velocity", "2000")
	register_cvar("Forge_force", "500.0")		//cannot get this to function properly.
	register_cvar("Forge_radius", "400")
	register_cvar("Forge_obeygravity", "1")	
	register_cvar("Forge_effects", "4")

	shCreateHero(gHeroName, "Missiles", "Fires Concussion Missiles to blow people up!", true, "Forge_level")

	//EVENTS
	//register_logevent("round_start", 2, "1=Round_Start")
	//register_logevent("round_end", 2, "1=Round_End")
	//register_logevent("round_end", 2, "1&Restart_Round_")
	register_event("ResetHUD","newRound","b")
	register_event("DeathMsg","death_event","a")	

	// KEY DOWN
	register_srvcmd("Forge_kd", "Forge_kd")
	shRegKeyDown(gHeroName, "Forge_kd")

	// INIT
	register_srvcmd("Forge_init", "Forge_init")
	shRegHeroInit(gHeroName, "Forge_init")
}
//----------------------------------------------------------------------------------------------
public Forge_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has BlackLotus
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)

	g_hasForgePower[id] = (hasPowers != 0)
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public Forge_kd()
{
	if ( !hasRoundStarted() ) return PLUGIN_HANDLED

	// First Argument is an id with Forge Powers!
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	if ( !is_user_alive(id) || !g_hasForgePower[id]  ) return PLUGIN_HANDLED
	if ( gPlayerUltimateUsed[id] ) {
		playSoundDenySelect(id)
		return PLUGIN_HANDLED
	}

	make_beam(id)
	ultimateTimer(id, get_cvar_float("Forge_cooldown") * 1.0 )

	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	beam = precache_model("sprites/smoke.spr")
	//boom = precache_model("sprites/zerogxplode.spr")
	//sprite = precache_model("sprites/zbeam6.spr")
	sprite1 = precache_model("sprites/fire.spr")
	sprite2 = precache_model("sprites/explode1.spr")
	sprite3 = precache_model("sprites/steam1.spr")

	precache_model("models/rpgrocket.mdl")

	precache_sound("weapons/rocketfire1.wav")
	precache_sound("weapons/rocket1.wav")	
}
//----------------------------------------------------------------------------------------------
#if defined AMX_NEW
public vexd_pfntouch(pToucher, pTouched) {
	entity_touch(pToucher, pTouched)
}

public entity_touch(entity1, entity2) {
	new pToucher = entity1
	new pTouched = entity2
#else
public vexd_pfntouch(pToucher, pTouched) {
#endif

	if ( !is_valid_ent(pToucher) ) return

	new szClassName[32]
	Entvars_Get_String(pToucher, EV_SZ_classname, szClassName, 31)

	if(equal(szClassName, "concussion_missile")) {
		new damradius = get_cvar_num("Forge_radius")
		new maxdamage = get_cvar_num("Forge_damage")

		if (damradius <= 0) {
			debugMessage("(Forge) Damage Radius must be set higher than 0, defaulting to 240",0,0)
			damradius = 240
			set_cvar_num("Forge_radius",damradius)
		}
		if (maxdamage <= 0) {
			debugMessage("(Forge) Max Damage must be set higher than 0, defaulting to 14",0,0)
			maxdamage = 14
			set_cvar_num("Forge_damage",maxdamage)
		}

		remove_task(pToucher)
		new Float:fl_vExplodeAt[3]
		Entvars_Get_Vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
		new vExplodeAt[3]
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])
		new id = Entvars_Get_Edict(pToucher, EV_ENT_owner)
		new origin[3],dist,i,Float:dRatio,damage

		for ( i = 1; i <= SH_MAXSLOTS; i++) {

			if( !is_user_alive(i) ) continue
			get_user_origin(i,origin)
			dist = get_distance(origin,vExplodeAt)
			if (dist <= damradius) {

				dRatio = floatdiv(float(dist),float(damradius))
				damage = maxdamage - floatround( maxdamage * dRatio)

				shExtraDamage(i, id, damage, "Concussion Missile" )

				//cannot get this to function properly
				new Float: force = get_cvar_float("Forge_force")
				//new Float: force = ForgeForce - (ForgeForce * dRatio)
									
				new Float:fl_vicVelocity[3]

				fl_vicVelocity[0] = 0.0 
				fl_vicVelocity[1] = 0.0
				//fl_vicVelocity[2] = 500.0 - (500.0 * dRatio)
				fl_vicVelocity[2] = force - (force * dRatio)

				set_pev(i, pev_velocity, fl_vicVelocity)

				//client_print(i,print_chat,"%f = %f - ( %f * %f )", force - (force * dRatio) , force , force , dRatio)

			}
		}

//		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
//		write_byte(3)
//		write_coord(vExplodeAt[0])
//		write_coord(vExplodeAt[1])
//		write_coord(vExplodeAt[2])
//		write_short(boom)
//		write_byte(100)
//		write_byte(15)
//		write_byte(0)
//		message_end()

		emit_sound(pToucher, CHAN_WEAPON, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(pToucher, CHAN_VOICE, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		forge_boom(vExplodeAt)

		RemoveEntity(pToucher)

		if ( is_valid_ent(pTouched) ) {
			new szClassName2[32]
			Entvars_Get_String(pTouched, EV_SZ_classname, szClassName2, 31)

			if(equal(szClassName2, "concussion_missile")) {
				remove_task(pTouched)
				emit_sound(pTouched, CHAN_WEAPON, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				emit_sound(pTouched, CHAN_VOICE, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				//new id2 = Entvars_Get_Edict(pTouched, EV_ENT_owner)
				//AttachView(id2, id2)
				//if(has_rocket[id2] == pTouched){
				//	has_rocket[id2] = 0
				//	is_heat_rocket[id2] = 0
				//	is_scan_rocket[id2] = 0
				//}
				RemoveEntity(pTouched)
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
public forge_boom(Explorigin[])
{
//	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
//	write_byte(12)
//	write_coord(Explorigin[0])
//	write_coord(Explorigin[1])
//	write_coord(Explorigin[2])
//	write_byte(188)
//	write_byte(10)
//	message_end()

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 21 )
	write_coord(Explorigin[0])
	write_coord(Explorigin[1])
	write_coord(Explorigin[2] + 16)
	write_coord(Explorigin[0])
	write_coord(Explorigin[1])
	write_coord(Explorigin[2] + 1936)
	write_short( sprite1 )
	write_byte( 0 )
	write_byte( 0 )
	write_byte( 2 )
	write_byte( 128 )
	write_byte( 0 )
	write_byte( 188 )
	write_byte( 220 )
	write_byte( 255 )
	write_byte( 255 )
	write_byte( 0 )
	message_end()

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 3 )
	write_coord(Explorigin[0])
	write_coord(Explorigin[1])
	write_coord(Explorigin[2])
	write_short( sprite2 )
	write_byte( 60 )
	write_byte( 10 )
	write_byte( 0 )
	message_end()

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 5 )
	write_coord(Explorigin[0])
	write_coord(Explorigin[1])
	write_coord(Explorigin[2])
	write_short( sprite3 )
	write_byte( 10 )
	write_byte( 10 )
	message_end()
}
//----------------------------------------------------------------------------------------------
public make_beam(id)
{
	new args[2]
	new Float:vOrigin[3]
	new Float:vAngles[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	//new notFloat_vOrigin[3]
	//notFloat_vOrigin[0] = floatround(vOrigin[0])
	//notFloat_vOrigin[1] = floatround(vOrigin[1])
	//notFloat_vOrigin[2] = floatround(vOrigin[2])

	new NewEnt
	NewEnt = CreateEntity("info_target")
	if(NewEnt == 0) {
		client_print(id,print_chat,"[SH](Forge) Rocket Failure")
		return PLUGIN_HANDLED
	}

	Entvars_Set_String(NewEnt, EV_SZ_classname, "concussion_missile")
	ENT_SetModel(NewEnt, "models/rpgrocket.mdl")

	new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
	new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}

	Entvars_Set_Vector(NewEnt, EV_VEC_mins,fl_vecminsx)
	Entvars_Set_Vector(NewEnt, EV_VEC_maxs,fl_vecmaxsx)

	ENT_SetOrigin(NewEnt, vOrigin)
	Entvars_Set_Vector(NewEnt, EV_VEC_angles, vAngles)	
	Entvars_Set_Int(NewEnt, EV_INT_solid, 2)
	//Entvars_Set_Int(NewEnt, EV_INT_effects, 64)

	new effects = get_cvar_num("Forge_effects")	

	if ( effects == 1 ){ // normal
		Entvars_Set_Int(NewEnt, EV_INT_effects, 2)
	}
	else if ( effects == 2 ){ // sprites (yellow) arround missile
		Entvars_Set_Int(NewEnt, EV_INT_effects, 4)
	}
	else if ( effects == 3 ){ // light around missile
		Entvars_Set_Int(NewEnt, EV_INT_effects, 1)
	}
	else if ( effects == 4 ){ // both light and sprites around missle (default)
		Entvars_Set_Int(NewEnt, EV_INT_effects, 7)
	}
	else {
		Entvars_Set_Int(NewEnt, EV_INT_effects, 64)
	}

	if(get_cvar_num("Forge_obeygravity")) {
		Entvars_Set_Int(NewEnt, EV_INT_movetype, 6)
	}
	else {
		Entvars_Set_Int(NewEnt, EV_INT_movetype, 5)
	}

	Entvars_Set_Edict(NewEnt, EV_ENT_owner, id)
	Entvars_Set_Float(NewEnt, EV_FL_health, 10000.0)
	Entvars_Set_Float(NewEnt, EV_FL_takedamage, 100.0)
	Entvars_Set_Float(NewEnt, EV_FL_dmg_take, 100.0)

	new MissileVel = get_cvar_num("Forge_velocity")
	new Float:fl_iNewVelocity[3]
	//new iNewVelocity[3]
	VelocityByAim(id, MissileVel, fl_iNewVelocity)
	Entvars_Set_Vector(NewEnt, EV_VEC_velocity, fl_iNewVelocity)
	//iNewVelocity[0] = floatround(fl_iNewVelocity[0])
	//iNewVelocity[1] = floatround(fl_iNewVelocity[1])
	//iNewVelocity[2] = floatround(fl_iNewVelocity[2])

	emit_sound(NewEnt, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(NewEnt, CHAN_VOICE, "weapons/rocket1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	args[0] = id
	args[1] = NewEnt

	make_trail(NewEnt)
	Entvars_Set_Float(NewEnt, EV_FL_gravity, 0.25)
	set_task(0.1,"guide_rocket_comm",NewEnt,args,2,"b")
	//set_task(get_cvar_float("bazooka_fuel"),"rocket_fuel_timer",NewEnt,args,16)

	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
make_trail(NewEnt)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)
	write_short(NewEnt)
	write_short(beam)
	write_byte(45)
	write_byte(4)
	write_byte(254)
	write_byte(254)
	write_byte(254)
	write_byte(100)
	message_end()
}
//----------------------------------------------------------------------------------------------
public guide_rocket_comm(args[])
{
	new ent = args[1]
	if (!is_valid_ent(ent)) return
	new Float:missile_health = Entvars_Get_Float(ent, EV_FL_health)
	if(missile_health < 10000.0)
		vexd_pfntouch(ent,0)
}
//----------------------------------------------------------------------------------------------
//public rocket_fuel_timer(args[]) {
//	new ent = args[1]
//	new id = args[0]
//	remove_task(ent)
//	if (!is_valid_ent(ent)) return
//	Entvars_Set_Int(ent, EV_INT_effects, 2)
//	Entvars_Set_Int(ent, EV_INT_rendermode,0)
//	Entvars_Set_Float(ent, EV_FL_gravity, 1.0)
//	Entvars_Set_Int(ent, EV_INT_iuser1, 0)
//	emit_sound(ent, CHAN_WEAPON, "debris/beamstart8.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM )
//	emit_sound(ent, CHAN_VOICE, "ambience/rocket_steam1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
//	if(args[11] == 1){
//		set_hudmessage(250,10,10,-1.0,0.45, 0, 0.0, 1.5, 0.5, 0.15, 54)
//		show_hudmessage(id,"WARNING: FUEL TANK EMPTY^nCONTROLS DISENGAGED")
//	}
//	set_task(0.1,"guide_rocket_comm",ent,args,16,"b")
//}
//public client_connect(id)
//	//no real tasks to set
//}
//----------------------------------------------------------------------------------------------
public client_disconnect(id)
{
	remove_task(id)
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
	gPlayerUltimateUsed[id]=false
	RemoveByClass(id)//For some reason, sometimes if you were hit with own missile, entity would not be removed, so that is what this is for

	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public RemoveByClass(id)
{

	new missiles = -1
	while((missiles = find_ent_by_class(missiles, "concussion_missile")))
		remove_entity(missiles)

//	new ent = 0
//	do{
//		ent = find_entity(ent,classname,"concussion_missile")
//		if (ent > 0)
//		RemoveEntity(ent)
//	}
//	while (ent)
}
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
public death_event(){
	new victim
	victim = read_data(2)
	remove_task(victim)
}
//----------------------------------------------------------------------------------------------
//public round_end(){
//
//	roundfreeze = true
//
//	if(has_rocket[i] > 0)
//		remove_missile(i,has_rocket[i])
//
//	return PLUGIN_CONTINUE
//}
//----------------------------------------------------------------------------------------------
//public round_start(){
//
//	roundfreeze = false
//
//	new iCurrent
//	while ((iCurrent = FindEntity(-1, "bazooka_missile_ent")) > 0) {
//		new id = Entvars_Get_Edict(iCurrent, EV_ENT_owner)
//		remove_missile(id,iCurrent)
//	}
//	return PLUGIN_CONTINUE
//}
//----------------------------------------------------------------------------------------------
