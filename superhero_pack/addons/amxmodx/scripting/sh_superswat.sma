// S.W.A.T!

/* CVARS - copy and paste to shconfig.cfg

//SWAT
swat_level 8
swat_armor 200  //how much armor swat has
swat_m4a1mult 1.5  //Damage multiplyer for his M4A1
swat_knifemult 4.0  //Damage multiplyer for his knife.
swat_damage 1000 //How much damage the rocket does.
swat_cooldown 30 //How long till he can use rocket again.
swat_radius 1000  //How powerful the blast is.


*/

#include <amxmod>
#include <Vexd_Utilities>
#include <superheromod>
#include <engine>

// GLOBAL VARIABLES
new gHeroName[]="Swat"
new bool:gHasSwatPower[SH_MAXSLOTS+1]
new explodeModel, laserBeam, ringSprite
new entityCreated[33]
new bool:doesLaserExist = false
new Float:playerPosition[33][3]
new Float:entityPosition[33][3]
new Float:distances[33]
new has_rocket[33]
new bool:g_betweenRounds
new round_delay
new bool:roundfreeze
new bool:is_a_swat[33]
new target[33] //the attacker's target.
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Swat", "1.0", "Tassadarmaster / v2kEazyE / Batman/Gorlag")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("swat_level", "8")
	register_cvar("swat_armor", "200")
	register_cvar("swat_m4a1mult", "1.5")
	register_cvar("swat_knifemult", "4.0")
	register_cvar("swat_damage", "1000")
	register_cvar("swat_cooldown", "30.0")
	register_cvar("swat_radius", "1000")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	shCreateHero(gHeroName, "Colt ICBM", "Fires a (most of the time) 1 hit-ko I.C.B.M", true, "swat_level")

	// REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
	// INIT
	register_srvcmd("swat_init", "swat_init")
	shRegHeroInit(gHeroName, "swat_init")
	register_srvcmd("swat_kd", "swat_kd")
	shRegKeyDown(gHeroName, "swat_kd")

	// EVENTS
	register_event("ResetHUD", "newSpawn","b")
	register_event("CurWeapon", "weaponChange", "be", "1=1")
	register_event("Damage", "swat_damage", "b", "2!0")
	register_event("DeathMsg", "swat_modelReset", "a")

	// Let Server know about Swat's Variable
	shSetMaxHealth(gHeroName, "swat_health")
	shSetMaxArmor(gHeroName, "swat_armor")
	shSetShieldRestrict(gHeroName)

	//Touch event
	register_touch("ICBM_missile", "*", "laser_touch")

}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_model("models/shmod/swat_v_m4a1.mdl")
	precache_model("models/shmod/swat_p_m4a1.mdl")
	precache_model("models/rpgrocket.mdl")
	precache_model("models/player/swat/swat.mdl")
	precache_model("models/shmod/swat_v_knife.mdl")
	precache_model("models/shmod/swat_p_knife.mdl")
	ringSprite = precache_model("sprites/white.spr")
	explodeModel = precache_model("sprites/zerogxplode.spr")
	laserBeam = precache_model("sprites/smoke.spr")
	precache_sound("weapons/egon_run3.wav")
	precache_sound("weapons/egon_windup2.wav")
	precache_sound("weapons/mortar.wav")
	precache_sound("ambience/particle_suck2.wav")
}
//----------------------------------------------------------------------------------------------
public swat_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has the hero
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)

	if (!is_user_connected(id)) return

	//Reset thier shield restrict status
	//Shield restrict MUST be before weapons are given out
	shResetShield(id)

	if ( is_user_alive(id) ) {
		if ( hasPowers ) {
			swat_weapons(id)
			switchmodel(id)
		}
	//This gets run if they had the power but don't anymore
		else if ( !hasPowers && gHasSwatPower[id] ) {
			engclient_cmd(id, "drop", "weapon_m4a1")
			shRemHealthPower(id)
			shRemArmorPower(id)
			if(is_a_swat[id]){
				cs_reset_user_model(id)
				is_a_swat[id] = false
			}
		}
	}
	//Sets this variable to the current status
	gHasSwatPower[id] = (hasPowers != 0)
}
//----------------------------------------------------------------------------------------------
public newSpawn(id)
{
	gPlayerUltimateUsed[id] = false
	if ( shModActive() && gHasSwatPower[id] && is_user_alive(id) ) {
		set_task(0.1, "swat_weapons", id)

		new clip, ammo, wpnid = get_user_weapon(id, clip, ammo)
		if (wpnid != CSW_M4A1 && wpnid > 0) {
			new wpn[32]
			get_weaponname(wpnid, wpn, 31)
			engclient_cmd(id, wpn)
		}
	}
}
//----------------------------------------------------------------------------------------------
public swat_kd()
{
	if ( g_betweenRounds ) return
	
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	if(!is_user_alive(id) || !gHasSwatPower[id]) return
/*
	new entity, body;
	get_user_aiming(id, entity, body)

	if(is_valid_ent(entity)){
		new classname[41]
		entity_get_string(entity, EV_SZ_classname, classname, 40)
		client_print(id, print_chat, "The classname of the entity is %s", classname)
	}
*/ 
	if(gPlayerUltimateUsed[id] || !hasRoundStarted()){
		client_print(id,print_chat,"[SH](S.W.A.T.) Your next I.C.B.M. is not ready yet.")
		playSoundDenySelect(id)
		return
	}
	fireBeam(id)
	if(get_cvar_float("swat_cooldown") > 0.0)
		ultimateTimer(id, get_cvar_float("swat_cooldown"))
}
//-----------------------------------------------------------------------------------------------
public swat_weapons(id)
{
	if ( shModActive() && is_user_alive(id) ) {
		shGiveWeapon(id,"weapon_m4a1")
		shGiveWeapon(id,"weapon_knife")
		shGiveWeapon(id,"item_thighpack")
		if(!is_a_swat[id]){
			cs_set_user_model(id, "swat")
			is_a_swat[id] = true
		}
	}
}
//----------------------------------------------------------------------------------------------
public switchmodel(id)
{
	if ( !is_user_alive(id) ) return

	new clip, ammo, wpnid = get_user_weapon(id, clip, ammo)
	if ( wpnid == CSW_M4A1 ) {
		// Weapon Model change thanks to [CCC]Taz-Devil
		Entvars_Set_String(id, EV_SZ_viewmodel, "models/shmod/swat_v_m4a1.mdl")
		// Weapon Model change for 3rd person view - vittu
		Entvars_Set_String(id, EV_SZ_weaponmodel, "models/shmod/swat_p_m4a1.mdl")
	}
	else if(wpnid == CSW_KNIFE){
		entity_set_string(id, EV_SZ_viewmodel, "models/shmod/swat_v_knife.mdl")
		entity_set_string(id, EV_SZ_weaponmodel, "models/shmod/swat_p_knife.mdl")
	}
}
//----------------------------------------------------------------------------------------------
public weaponChange(id)
{
	if ( !gHasSwatPower[id] || !shModActive() ) return

	new wpnid = read_data(2)
	new clip = read_data(3)

	if ( wpnid != CSW_M4A1 && wpnid != CSW_KNIFE) return

	switchmodel(id)

	// Never Run Out of Ammo!
	if ( clip == 0 ) {
		shReloadAmmo(id)
	}
}
//----------------------------------------------------------------------------------------------
public swat_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) ) return

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0

	if ( attacker <= 0 || attacker > SH_MAXSLOTS ) return

	if ( gHasSwatPower[attacker] && weapon == CSW_M4A1 && is_user_alive(id) ) {
		// do extra damage
		new extraDamage = floatround(damage * get_cvar_float("swat_m4a1mult") - damage)
		if (extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "m4a1", headshot)
	}

	else if(gHasSwatPower[attacker] && weapon == CSW_KNIFE && is_user_alive(id) ){
		new extraDamage = floatround(damage * get_cvar_float("swat_knifemult") - damage)
		if(extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "knife", headshot)
	}
}
//----------------------------------------------------------------------------------------------
public swat_modelReset()
{
	new id = read_data(2)
	if(is_a_swat[id]){
		cs_reset_user_model(id)
		is_a_swat[id] = false
	}
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	gHasSwatPower[id] = false
	entityCreated[id] = 0
	distances[id] = 1000000.0
	target[id] = 0
}
//----------------------------------------------------------------------------------------------
public client_PostThink(id)
{
	if(doesLaserExist == true){
		if(is_user_alive(id))
			entity_get_vector(id, EV_VEC_origin, playerPosition[id])
		if(is_valid_ent(entityCreated[id])){
			entity_get_vector(entityCreated[id], EV_VEC_origin, entityPosition[id])
			new Float:distance = 0.0
			//this part might cause the server to lag, maybe
			for(new counter = 1; counter < 33; counter++){
				if(is_user_alive(counter) && get_user_team(id) != get_user_team(counter)){
					distance = vector_distance(playerPosition[counter], entityPosition[id])
					if(distance == 0.0) distance = 1.0
					if(distance < distances[id]){
						distances[id] = distance  //store the shortest distance
						target[id] = counter    //store the player to be targeted
					}
				}
			}
			guideLaser(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public fireBeam(id)
{
	new beamHead = create_entity("info_target")
	entityCreated[id] = beamHead
	entity_set_string(beamHead, EV_SZ_classname, "ICBM_missile")
	entity_set_edict(beamHead, EV_ENT_owner, id)
	new Float:origin[3], Float:offset[3], Float:angle[3]
	entity_get_vector(id, EV_VEC_origin, origin)
	entity_set_model(beamHead, "models/rpgrocket.mdl")
	entity_set_int(beamHead, EV_INT_effects, EF_LIGHT)
	velocity_by_aim(id, 10, offset)
	origin[0] += offset[0]
	origin[1] += offset[1]
	origin[2] += offset[2]
	entity_set_vector(beamHead, EV_VEC_origin, origin)
	entity_set_int(beamHead, EV_INT_movetype, MOVETYPE_FLY)
	entity_set_int(beamHead, EV_INT_solid, SOLID_BBOX)
	new Float:velocity[3]
	velocity_by_aim(id, 1000, velocity)
	entity_set_vector(beamHead, EV_VEC_velocity, velocity)
	new Float:minBound[3] = {-8.0, -8.0, -8.0}, Float:maxBound[3] = {8.0, 8.0, 8.0}
	entity_set_size(beamHead, minBound, maxBound)
	entity_get_vector(id, EV_VEC_angles, angle)
	entity_set_vector(beamHead, EV_VEC_angles, angle)

	//Makes the trail effect
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)
	write_short(beamHead)
	write_short(laserBeam)
	write_byte(200)  //makes the trail last a long time
	write_byte(100)  //width of trail sprite
	write_byte(255)  //red
	write_byte(0)  //green
	write_byte(0)    //blue
	write_byte(255)  //Makes the trail really bright
	message_end()

	doesLaserExist = true

	emit_sound(beamHead, CHAN_STATIC, "weapons/egon_run3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id, CHAN_STATIC, "weapons/egon_windup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}
//----------------------------------------------------------------------------------------------
public laser_touch(pToucher, pTouched)
{
	if(!is_valid_ent(pToucher)) return PLUGIN_HANDLED
	explode(pToucher)

	return PLUGIN_CONTINUE
}
//-----------------------------------------------------------------------------------------------
public explode(pToucher)
{
	new attacker = entity_get_edict(pToucher, EV_ENT_owner)
	new Float:missileVelocity[3]
	entity_get_vector(pToucher, EV_VEC_velocity, missileVelocity)

	new Float:origin[3]
	new notFloat[3]
	entity_get_vector(pToucher, EV_VEC_origin, origin)
	FVecIVec(origin, notFloat)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(3)  //EXPLOSION
	write_coord(notFloat[0])
	write_coord(notFloat[1])
	write_coord(notFloat[2])
	write_short(explodeModel)
	write_byte(255) //Make the sprite big
	write_byte(20)  //explosion should run at 20 frames per second
	write_byte(0)  //default half-life explosion
	message_end()

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin 
	write_byte(21) 
	write_coord(notFloat[0]) // center position 
	write_coord(notFloat[1]) 
	write_coord(notFloat[2]) 
	write_coord(notFloat[0]) // axis and radius 
	write_coord(notFloat[1]) 
	write_coord(notFloat[2] + 1000) 
	write_short(ringSprite) // sprite index 
	write_byte(0) // starting frame 
	write_byte(1) // frame rate in 0.1's 
	write_byte(50) // life in 0.1's 
	write_byte(8) // line width in 0.1's 
	write_byte(10) // noise amplitude in 0.01's 
	write_byte(255) //colour 
	write_byte(0) 
	write_byte(0) 
	write_byte(255) // brightness 
	write_byte(0) // scroll speed in 0.1's 
	message_end() 


	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(14)
	write_coord(notFloat[0])
	write_coord(notFloat[1])
	write_coord(notFloat[2])
	write_byte(255)
	write_byte(30)
	write_byte(50)
	message_end()



	new const SOUND_STOP = (1 << 5)
	emit_sound(pToucher, CHAN_STATIC, "weapons/egon_run3.wav", 1.0, ATTN_NORM, SOUND_STOP, PITCH_NORM)
	emit_sound(attacker, CHAN_STATIC, "weapons/egon_windup2.wav", 1.0, ATTN_NORM, SOUND_STOP, PITCH_NORM) 
	emit_sound(pToucher, CHAN_AUTO, "weapons/mortar.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(pToucher, CHAN_VOICE, "ambience/particle_suck2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				new id2 = Entvars_Get_Edict(pTouched, EV_ENT_owner)
				AttachView(id2, id2)
				if(has_rocket[id2] == pTouched){
					has_rocket[id2] = 0
				}
				RemoveEntity(pTouched)
				



	remove_entity(pToucher)
	entityCreated[attacker] = 0
		if(has_rocket[id] == pToucher)
		has_rocket[id] = 0
	for(new counter = 0; counter < 33; counter++){
		if(entityCreated[counter] == 0){
			doesLaserExist = false
		}
		else{
			doesLaserExist = true
			break
		}
	}



	//Thanks to the code from Goten
	new FFOn = get_cvar_num("mp_friendlyfire")
	new damageRadius = get_cvar_num("swat_radius")
	new damage, Float:damageRatio
	for(new vic = 1; vic < 33; vic++){
		if(is_user_alive(vic) && (get_user_team(attacker) != get_user_team(vic) || FFOn || vic == attacker)){
			new uOrigin[3]
			get_user_origin(vic, uOrigin, 0)
			new distance = get_distance(notFloat, uOrigin)
			if(distance < damageRadius){
				damageRatio = float(distance)/float(damageRadius)
				damage = get_cvar_num("swat_damage") - floatround(get_cvar_num("swat_damage") * damageRatio)
				if(vic == attacker) damage = floatround(damage/2.0)
				shExtraDamage(vic, attacker, damage, "SWAT ICBM")
				sh_screenShake(vic, 100, 50, 100)
				sh_setScreenFlash(vic, 255, 0, 0, 100, 50)
				new Float:forceFactor[3]
				if(distance < 5){
					forceFactor[0] = missileVelocity[0] * 2.0  
					forceFactor[1] = missileVelocity[1] * 2.0
					forceFactor[2] = (missileVelocity[2] * 2.0) + 700.0
					entity_set_vector(vic, EV_VEC_velocity, forceFactor)
				}
				else{
					forceFactor[0] = (uOrigin[0] - notFloat[0])/distance * 700.0
					forceFactor[1] = (uOrigin[1] - notFloat[1])/distance * 700.0
					forceFactor[2] = 500.0
					entity_set_vector(vic, EV_VEC_velocity, forceFactor)
				}
			}
		}
	}

	new breakable = find_ent_by_class(-1, "func_breakable")
	new bool:hasBeenFound[1200]
	new Float:brushOrigin[3], Float:min[3], Float:max[3]
	while(breakable != 0 && hasBeenFound[breakable] == false){
		//Where the brush is, and the actual entity is
		//is not the same, tested it.
		entity_get_vector(breakable, EV_VEC_mins, min)
		entity_get_vector(breakable, EV_VEC_maxs, max)
		brushOrigin[0] = (min[0] + max[0])/2
		brushOrigin[1] = (min[1] + max[1])/2
		brushOrigin[2] = (min[2] + max[2])/2  
		new Float:distance = vector_distance(origin, brushOrigin)
		if(distance < float(damageRadius)){
			//debugging here;)
			new classname[71], Float:health, Float:takeDamage
			entity_get_string(breakable, EV_SZ_classname, classname, 70)
			takeDamage = entity_get_float(breakable, EV_FL_takedamage)
			health = entity_get_float(breakable, EV_FL_health)

			if(health > 0.0){
				if(takeDamage < 1.0)
					entity_set_float(breakable, EV_FL_takedamage, 1.0)
				new hurt_trigger = create_entity("trigger_hurt")
				entity_set_float(hurt_trigger, EV_FL_dmg, 2000.0)
				DispatchSpawn(hurt_trigger)
				fake_touch(hurt_trigger, breakable)
				remove_entity(hurt_trigger)
				if(entity_get_float(breakable, EV_FL_health) <= 0.0)
					entity_set_float(breakable, EV_FL_takedamage, 0.0)
			}
		}
		hasBeenFound[breakable] = true
		breakable = find_ent_by_class(breakable, "func_breakable")
	}

	new weapon = find_ent_by_class(-1, "weaponbox")
	while(weapon != 0 && hasBeenFound[weapon] == false){
		new Float:weaponOrigin[3], Float:distance
		entity_get_vector(weapon, EV_VEC_origin, weaponOrigin)
		distance = vector_distance(origin, weaponOrigin)
		if(distance < float(damageRadius)){
			new Float:forceFactor[3]
			forceFactor[0] = (weaponOrigin[0] - origin[0])/distance * 700.0
			forceFactor[1] = (weaponOrigin[1] - origin[1])/distance * 700.0
			forceFactor[2] = 500.0
			entity_set_vector(weapon, EV_VEC_velocity, forceFactor)
		}
		hasBeenFound[weapon] = true
		weapon = find_ent_by_class(weapon, "weaponbox")
	}

	hurt_monster(origin, "monster_alien_controller", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_alien_grunt", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_alien_slave", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_apache", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_babycrab", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_barnacle", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_barney", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_bigmomma", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_bloater", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_bullchicken", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_cockroach", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_flyer_flock", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_gargantua", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_gman", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_headcrab", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_houndeye", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_human_assassin", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_human_grunt", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_ichthyosaur", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_leech", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_nihilanth", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_scientist", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_snark", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_tentacle", damageRadius, hasBeenFound)
	hurt_monster(origin, "monster_zombie", damageRadius, hasBeenFound)
	hurt_monster(origin, "hostage_entity", damageRadius, hasBeenFound)
	hurt_monster(origin, "bazooka_missile_ent", damageRadius, hasBeenFound)
	hurt_monster(origin, "demoman_tripmines", damageRadius, hasBeenFound)



	target[attacker] = 0
	distances[attacker] = 1000000.0
}
//---------------------------------------------------------------------------
public guideLaser(id)
{
	new targets = target[id]
	new Float:distance = distances[id]
	if(distance == 1000000.0) return
	new Float:lengthComponent[3]
	lengthComponent[0] = playerPosition[targets][0] - entityPosition[id][0]
	lengthComponent[1] = playerPosition[targets][1] - entityPosition[id][1]
	lengthComponent[2] = playerPosition[targets][2] - entityPosition[id][2]
	new Float:velocity[3]
	velocity[0] = lengthComponent[0]/distance * 1000.0
	velocity[1] = lengthComponent[1]/distance * 1000.0
	velocity[2] = lengthComponent[2]/distance * 1000.0
	//Let's change the angle of the model as well
	lengthComponent[0] /= distance
	lengthComponent[1] /= distance
	lengthComponent[2] /= distance
	new Float:angleOffset[3]
	vector_to_angle(lengthComponent, angleOffset)
	entity_set_vector(entityCreated[id], EV_VEC_angles, angleOffset)
	entity_set_vector(entityCreated[id], EV_VEC_velocity, velocity)
}
//----------------------------------------------------------------------------
public hurt_monster(Float:blastOrigin[3], monsterClassname[], damageRadius, bool:hasBeenFound[])
{
	new monster = find_ent_by_class(-1, monsterClassname)
	new Float:monsterOrigin[3], Float:distance
	while(monster != 0 && hasBeenFound[monster] == false){
		entity_get_vector(monster, EV_VEC_origin, monsterOrigin)
		distance = vector_distance(blastOrigin, monsterOrigin)
		if(distance < float(damageRadius)){
			if(entity_get_float(monster, EV_FL_health) > 0.0){
				if(entity_get_float(monster, EV_FL_takedamage) < 1.0)
					entity_set_float(monster, EV_FL_takedamage, 1.0)
				new hurt_trigger = create_entity("trigger_hurt")
				if(equal(monsterClassname, "bazooka_missile_ent")){
					entity_set_float(hurt_trigger, EV_FL_dmg, 30000.0)  //Make sure it can kill the rocket
				}
				else{
					entity_set_float(hurt_trigger, EV_FL_dmg, 2000.0)
				}
				DispatchSpawn(hurt_trigger)
				fake_touch(hurt_trigger, monster)
				remove_entity(hurt_trigger)
				new Float:forceFactor[3]
				forceFactor[0] = (monsterOrigin[0] - blastOrigin[0])/distance * 700.0
				forceFactor[1] = (monsterOrigin[1] - blastOrigin[1])/distance * 700.0
				forceFactor[2] = 700.0
				entity_set_vector(monster, EV_VEC_velocity, forceFactor)
				if(entity_get_float(monster, EV_FL_health) <= 0.0)
					entity_set_float(monster, EV_FL_takedamage, 0.0)
			}
		}
		hasBeenFound[monster] = true
		monster = find_ent_by_class(monster, monsterClassname)
	}
}
//------------------------------------------------------------------------------------
/*public smartGuide(id, obstruction[3])
{
	new Float:angle[3], Float:velocity[3], Float:temp[3], Float:offset[3]
	entity_get_vector(entityCreated[id], EV_VEC_angles, angle)
	temp[0] = angle[0]
	temp[1] = angle[1]
	temp[2] = angle[2]
	for(; (temp[1] < angle[1] + 360); temp[1] += 10){
		offset[0] = floatcos(temp[1], degrees) * (200)
		offset[1] = floatsin(temp[1], degrees) * (200)
		offset[2] = floatcos(temp[0] + 90, degrees) * (200)
		trace_line(entityCreated[id], entityPosition[id], offset, obstruction)
		if(offset[2] != obstruction[2]){
			temp[0] += 10
		}
		if(vector_distance(entityPosition[id], obstruction) == 200.0){
			velocity[0] = offset[0]/200 * 1000
			velocity[1] = offset[1]/200 * 1000
			velocity[2] = offset[2]/200 * 1000
			entity_set_vector(entityCreated[id], EV_VEC_velocity, velocity)
			entity_set_vector(entityCreated[id], EV_VEC_angles, temp)
*/

//----------------------------------------------------------------------------------------------
public roundstart_delay(){
	round_delay = 0
}
//----------------------------------------------------------------------------------------------
public round_end(){
	
        g_betweenRounds = true
        roundfreeze = false

	new iCurrent
	while ((iCurrent = FindEntity(-1, "ICBM_missile")) > 0) {
		new id = Entvars_Get_Edict(iCurrent, EV_ENT_owner)
		remove_missile(id,iCurrent)
	}
	
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public death_event(){
	new victim
	victim = read_data(2)
	remove_task(victim)
}
//----------------------------------------------------------------------------------------------
remove_missile(id,missile){

	new Float:fl_origin[3]
	Entvars_Get_Vector(missile, EV_VEC_origin, fl_origin)

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(14)
	write_coord(floatround(fl_origin[0]))
	write_coord(floatround(fl_origin[1]))
	write_coord(floatround(fl_origin[2]))
	write_byte (200)
	write_byte (40)
	write_byte (45)
	message_end()

	emit_sound(missile, CHAN_WEAPON, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(missile, CHAN_VOICE, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	has_rocket[id] = 0
	gPlayerUltimateUsed[id]=false
	remove_task(missile)
	remove_task(id)
	AttachView(id,id)
	RemoveEntity(missile)
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public round_start(){
	
	g_betweenRounds = false
	
	roundfreeze = false

	new iCurrent
	while ((iCurrent = FindEntity(-1, "ICBM_missile")) > 0) {
		new id = Entvars_Get_Edict(iCurrent, EV_ENT_owner)
		remove_missile(id,iCurrent)
	}
}
//----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
