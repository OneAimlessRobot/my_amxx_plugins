

#define SWAT_M4_P_MODEL "models/shmod/swatm4/p_m4a1.mdl"
#define SWAT_M4_V_MODEL "models/shmod/swatm4/v_m4a1.mdl"
#define SWAT_M4_W_MODEL "models/shmod/swatm4/w_m4a1.mdl"

new const m4_swat_sounds[13][]={"weapons/swatm4/silencer_off.wav",
"weapons/swatm4/silencer_on.wav",
"weapons/swatm4/m4a1-2.wav",
"weapons/swatm4/m4a1_unsil-1.wav",
"weapons/swatm4/m4a1_unsil-2.wav",
"weapons/swatm4/m4a1-1.wav",
"weapons/swatm4/m16a1/foley.wav",
"weapons/swatm4/m16a1/inserting.wav",
"weapons/swatm4/m16a1/magout.wav",
"weapons/swatm4/m16a1/magtap.wav",
"weapons/swatm4/m16a1/m16-1.wav",
"weapons/swatm4/m16a1/boltpull.wav",
"weapons/swatm4/m16a1/magin.wav"}
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"


#if defined AMX98
 #include <cmath>
#endif

new gHeroName[]="S.W.A.T."
new bool:g_hasSwatPower[SH_MAXSLOTS+1]
new has_rocket[33]
new bool:g_betweenRounds
new bool:is_a_swat[33]
new gHeroID
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Swat", "1.0", "SRGrty")

	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	register_cvar("Swat_level", "7")
	register_cvar("Swat_cooldown", "20.0")
	register_cvar("Swat_damage", "40")
	register_cvar("swat_armor", "200")
	register_cvar("swat_m4a1mult", "1.5")
	register_cvar("swat_knifemult", "4.0")
	register_cvar("Swat_velocity", "2000")
	register_cvar("Swat_force", "500.0")		//cannot get this to function properly.
	register_cvar("Swat_radius", "400")
	register_cvar("Swat_obeygravity", "1")	
	register_cvar("Swat_effects", "4")

	gHeroID=shCreateHero(gHeroName, "Nuke", "Fires a (most of the time) 1 hit-ko I.C.B.M", true, "Swat_level")

	g_msgFade = get_user_msgid("ScreenFade");
	//EVENTS
	register_logevent("round_start", 2, "1=Round_Start")
	register_logevent("round_end", 2, "1=Round_End")
	register_logevent("round_end", 2, "1&Restart_Round_")
	register_event("ResetHUD","newRound","b")
	register_event("CurWeapon", "weaponChange", "be", "1=1")
	register_event("Damage", "swat_damage", "b", "2!0")
	register_event("DeathMsg", "swat_modelReset", "a")
	register_event("DeathMsg","death_event","a")	

	shSetMaxHealth(gHeroName, "swat_health")
	shSetMaxArmor(gHeroName, "swat_armor")
	shSetShieldRestrict(gHeroName)
	// KEY DOWN
	register_srvcmd("Swat_kd", "Swat_kd")
	shRegKeyDown(gHeroName, "Swat_kd")

	// INIT
	register_srvcmd("Swat_init", "Swat_init")
	shRegHeroInit(gHeroName, "Swat_init")
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
	gPlayerUltimateUsed[id] = false
	if ( shModActive() && g_hasSwatPower[id] && is_user_alive(id) ) {
		set_task(0.1, "swat_weapons", id)

	}
	return PLUGIN_CONTINUE
}
//-----------------------------------------------------------------------------------------------
public swat_weapons(id)
{
	if ( shModActive() && is_user_alive(id) ) {
		sh_give_weapon(id,CSW_M4A1,true)
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
		Entvars_Set_String(id, EV_SZ_viewmodel, SWAT_M4_V_MODEL)
		// Weapon Model change for 3rd person view - vittu
		Entvars_Set_String(id, EV_SZ_weaponmodel, SWAT_M4_P_MODEL)
	}
	else if(wpnid == CSW_KNIFE){
		entity_set_string(id, EV_SZ_viewmodel, "models/shmod/swat_v_knife.mdl")
		entity_set_string(id, EV_SZ_weaponmodel, "models/shmod/swat_p_knife.mdl")
	}
}
//----------------------------------------------------------------------------------------------
public weaponChange(id)
{
	if ( !g_hasSwatPower[id] || !shModActive() ) return

	new wpnid = read_data(2)
	new clip = read_data(3)

	if ( (wpnid != CSW_M4A1) && (wpnid != CSW_KNIFE)) return

	switchmodel(id)

	// Never Run Out of Ammo!
	if ( clip == 1 ) {
		sh_reload_ammo(id)
	}
}
//----------------------------------------------------------------------------------------------
public swat_damage(id)
{
	if ( !shModActive() || !is_user_alive(id) ) return PLUGIN_CONTINUE

	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0

	if ( (attacker <= 0 || attacker > SH_MAXSLOTS )|| (attacker==id)||!is_user_connected(attacker)) return PLUGIN_CONTINUE

	if ( g_hasSwatPower[attacker] && weapon == CSW_M4A1 && is_user_alive(id) ) {
		// do extra damage
		new extraDamage = floatround(damage * get_cvar_float("swat_m4a1mult") - damage)
		if (extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "swat_m4a1", headshot)
	}

	else if(g_hasSwatPower[attacker] && weapon == CSW_KNIFE && is_user_alive(id) ){
		new extraDamage = floatround(damage * get_cvar_float("swat_knifemult") - damage)
		if(extraDamage > 0) shExtraDamage(id, attacker, extraDamage, "tactical_knife", headshot)
	}
	return PLUGIN_CONTINUE
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
public Swat_init()
{
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id = str_to_num(temp)

	// 2nd Argument is 0 or 1 depending on whether the id has BlackLotus
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	if (!is_user_connected(id)) return

	g_hasSwatPower[id] = (hasPowers != 0)
	//Reset thier shield restrict status
	//Shield restrict MUST be before weapons are given out
	shResetShield(id)

	if (g_hasSwatPower[id]) {
		swat_weapons(id)
		switchmodel(id)
	}
	else {
		sh_drop_weapon(id,CSW_M4A1,true)
		shRemHealthPower(id)
		shRemArmorPower(id)
		if(is_a_swat[id]){
			cs_reset_user_model(id)
			is_a_swat[id] = false
		}
	}
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public Swat_kd()
{
	if ( g_betweenRounds ) return

	// First Argument is an id with Swat Powers!
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	if ( !is_user_alive(id) || !g_hasSwatPower[id]  ) return

	if(sh_get_user_is_asleep(id)) return
	if(sh_get_user_is_chaffed(id)) return

	if ( gPlayerUltimateUsed[id] ) {
		
		if(!is_user_bot(id)){
			client_print(id,print_chat,"[SH](S.W.A.T.) Your next I.C.B.M. is not ready yet.")
			playSoundDenySelect(id)
		}
		return
	}

	make_beam(id)
	ultimateTimer(id, get_cvar_float("Swat_cooldown") * 1.0 )
	return
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_model("models/player/swat/swat.mdl")
	precache_model("models/shmod/swat_v_knife.mdl")
	precache_model("models/shmod/swat_p_knife.mdl")
	for(new i=0;i<sizeof(m4_swat_sounds);i++){
	
		engfunc(EngFunc_PrecacheSound,m4_swat_sounds[i] );
	
	}

	precache_model(SWAT_M4_P_MODEL )
	precache_model(SWAT_M4_V_MODEL )
	precache_model(SWAT_M4_W_MODEL )
	precache_explosion_fx()

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

	if(equal(szClassName, "ICBM_missile")) {
		new damradius = get_cvar_num("Swat_radius")
		new maxdamage = get_cvar_num("Swat_damage")

		if (damradius <= 0) {
			debugMessage("(S.W.A.T.) Damage Radius must be set higher than 0, defaulting to 240",0,0)
			damradius = 240
			set_cvar_num("Swat_radius",damradius)
		}
		if (maxdamage <= 0) {
			debugMessage("(S.W.A.T.) Max Damage must be set higher than 0, defaulting to 14",0,0)
			maxdamage = 14
			set_cvar_num("Swat_damage",maxdamage)
		}

		remove_task(pToucher)
		new Float:fl_vExplodeAt[3]
		Entvars_Get_Vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
		new vExplodeAt[3]
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])
		new id = Entvars_Get_Edict(pToucher, EV_ENT_owner)
		if(has_rocket[id] == pToucher)
		has_rocket[id] = 0

		explosion(gHeroID,pToucher,float(damradius),float(maxdamage))
		

		emit_sound(pToucher, CHAN_WEAPON, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(pToucher, CHAN_VOICE, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		RemoveEntity(pToucher)

	}
}
//----------------------------------------------------------------------------------------------
public make_beam(id)
{
	new args[2]
	new Float:vOrigin[3]
	new Float:vAngles[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	new NewEnt
	NewEnt = create_entity("info_target")
	if(NewEnt == 0) {
		
		if(!is_user_bot(id)){
			client_print(id,print_chat,"[SH](S.W.A.T.) Rocket Failure")
		}
		return PLUGIN_HANDLED
	}

	Entvars_Set_String(NewEnt, EV_SZ_classname, "ICBM_missile")
	ENT_SetModel(NewEnt, "models/rpgrocket.mdl")

	new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
	new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}

	Entvars_Set_Vector(NewEnt, EV_VEC_mins,fl_vecminsx)
	Entvars_Set_Vector(NewEnt, EV_VEC_maxs,fl_vecmaxsx)

	ENT_SetOrigin(NewEnt, vOrigin)
	Entvars_Set_Vector(NewEnt, EV_VEC_angles, vAngles)	
	Entvars_Set_Int(NewEnt, EV_INT_solid, 2)
	Entvars_Set_Int(NewEnt, EV_INT_effects, 64)

	new effects = get_cvar_num("Swat_effects")	

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

	if(get_cvar_num("Swat_obeygravity")) {
		Entvars_Set_Int(NewEnt, EV_INT_movetype, 6)
	}
	else {
		Entvars_Set_Int(NewEnt, EV_INT_movetype, 5)
	}

	Entvars_Set_Edict(NewEnt, EV_ENT_owner, id)
	Entvars_Set_Float(NewEnt, EV_FL_health, 10000.0)
	Entvars_Set_Float(NewEnt, EV_FL_takedamage, 100.0)
	Entvars_Set_Float(NewEnt, EV_FL_dmg_take, 100.0)

	new MissileVel = get_cvar_num("Swat_velocity")
	new Float:fl_iNewVelocity[3]
	//new iNewVelocity[3]
	VelocityByAim(id, MissileVel, fl_iNewVelocity)
	Entvars_Set_Vector(NewEnt, EV_VEC_velocity, fl_iNewVelocity)

	emit_sound(NewEnt, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(NewEnt, CHAN_VOICE, "weapons/rocket1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	args[0] = id
	args[1] = NewEnt

	trail(NewEnt,RED,10,10)
	Entvars_Set_Float(NewEnt, EV_FL_gravity, 0.25)
	set_task(0.1,"guide_rocket_comm",NewEnt,args,2,"b")

	return PLUGIN_HANDLED
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
public client_disconnected(id)
{
	remove_task(id)
}
//----------------------------------------------------------------------------------------------
public client_connect(id)
{
	g_hasSwatPower[id] = false
}
//----------------------------------------------------------------------------------------------
public round_end(){
	
        g_betweenRounds = true

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
	new iCurrent
	while ((iCurrent = FindEntity(-1, "ICBM_missile")) > 0) {
		new id = Entvars_Get_Edict(iCurrent, EV_ENT_owner)
		remove_missile(id,iCurrent)
	}
}
//----------------------------------------------------------------------------------------------
