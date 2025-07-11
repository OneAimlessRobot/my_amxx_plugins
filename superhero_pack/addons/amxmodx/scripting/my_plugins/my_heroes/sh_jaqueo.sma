
#include "../my_include/superheromod.inc"
#include "shield_inc/sh_jaqueo_get_set.inc"
#include "shield_inc/sh_jaqueo_shield.inc"

#define JAQUEO_HUD_TASKID 18382
#define JAQUEO_MORPH_TASKID 28627
new gHeroLevel
new gHasJaqueo[SH_MAXSLOTS+1]
new gmorphed[SH_MAXSLOTS+1]
new teamglow_on
new hud_sync
new Float:scout_mult
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Jaqueo", "1.0", "TastyMedula")
	
	
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("jaqueo_level", "8")
	register_cvar("jaqueo_scout_mult", "8")
	register_cvar("jaqueo_teamglow_on", "8")
	register_cvar("jaqueo_shield_cooldown", "8")
	register_cvar("jaqueo_shield_max_hp", "8")
	register_cvar("jaqueo_shield_radius", "8")
	register_event("ResetHUD","newRound","b")
	gHeroID=shCreateHero(gHeroName, "Jaqueo!", "Jaqueo", true, "jaqueo_level" )
	hud_sync=CreateHudSyncObj()
	register_event("DeathMsg","death","a")
	register_srvcmd("jaqueo_init", "jaqueo_init")
	shRegHeroInit(gHeroName, "jaqueo_init")
	RegisterHam(Ham_CS_RoundRespawn,"player","Ham_respawn");
	RegisterHam(Ham_TakeDamage,"player","Jaqueo_Damage")
	register_srvcmd("jaqueo_kd", "jaqueo_kd")
	shRegKeyDown(gHeroName, "jaqueo_kd")
	register_srvcmd("jaqueo_ku", "jaqueo_ku")
	shRegKeyUp(gHeroName, "jaqueo_ku")
	register_event("CurWeapon", "weapon_change", "be", "1=1")
	
	// Add your code here...
}
//----------------------------------------------------------------------------------------------
switch_model(id)
{
	if ( !sh_is_active() || !is_user_alive(id) || !gHasJaqueo[id]||!is_user_connected(id) ) return
	
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	
	if ( wpnid == CSW_SCOUT ) {
		entity_set_string(id, EV_SZ_viewmodel, JAQUEO_COOL_SCOUT_V_MODEL)
		entity_set_string(id,EV_SZ_weaponmodel, JAQUEO_COOL_SCOUT_P_MODEL)
	}
	else if(wpnid == CSW_AK47){
		entity_set_string(id, EV_SZ_viewmodel, JAQUEO_AK47_V_MODEL)
	}
}
public plugin_natives(){
	
	register_native("client_isnt_hitter","_client_isnt_hitter",0);
	register_native("jaqueo_get_has_jaqueo","_jaqueo_get_has_jaqueo",0);
	register_native("jaqueo_get_hero_id","_jaqueo_get_hero_id",0);
	register_native("jaqueo_get_hero_id","_jaqueo_get_hero_id",0);
	
	
}
public _jaqueo_get_hero_id(iPlugin,iParams){
	
	return gHeroID;
	
}
public _jaqueo_get_has_jaqueo(iPlugin,iParams){
	new id=get_param(1);
	return gHasJaqueo[id]
	
}
public jaqueo_init()
{
	
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	gHasJaqueo[id]=(hasPowers!=0)
	if(gHasJaqueo[id]){
		
		reset_jaqueo_user(id)
		jaqueo_weapons(id)
		jaqueo_tasks(id)
		
		//set_task( 0.2, "jaqueo_loop", id+GRACIETE_HUD_TASKID, "", 0, "b")
	}
	else{
		
		jaqueo_drop_weapons(id)
		reset_jaqueo_user(id)
		jaqueo_unmorph(id+JAQUEO_MORPH_TASKID)
		//remove_task(id+GRACIETE_HUD_TASKID)
	}
	
}
public status_hud(id){
	
	new hud_msg[1000];
	format(hud_msg,500,"[SH] %s:^n",gHeroName);
	
	set_hudmessage(jaqueo_color[0], jaqueo_color[1], jaqueo_color[2], 0.2, 0.2, 0, 0.0, 0.2)
	ShowSyncHudMsg(id, hud_sync, "%s", hud_msg)
	
	
}
public jaqueo_weapons(id){
	
	if(!gHasJaqueo[id]||!is_user_alive(id) ||!sh_is_active()) return
	
	sh_give_weapon(id,CSW_SCOUT)
	sh_give_weapon(id,CSW_AK47)
	
}
public jaqueo_drop_weapons(id){
	
	if(!gHasJaqueo[id]||!is_user_alive(id) ||!sh_is_active()) return
	
	sh_drop_weapon(id,CSW_SCOUT,true)
	sh_drop_weapon(id,CSW_AK47,true)
	
}
public Jaqueo_Damage(this, idinflictor, idattacker, Float:damage, damagebits){
	
	if(!shModActive() || client_isnt_hitter(idattacker)) return HAM_IGNORED
	
	new weapon, bodypart, attacker = get_user_attacker(this, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	if ( (idattacker <= 0 || idattacker > SH_MAXSLOTS )|| (idattacker==this)||!is_user_connected(idattacker)) return HAM_IGNORED
	
	if((weapon==CSW_SCOUT)&&gHasJaqueo[idattacker]){
		new Float:extraDamage = damage * scout_mult - damage
		if (floatround(extraDamage)>0){
			shExtraDamage(this, idattacker, floatround(extraDamage), "Jaqueo scout", headshot)
			
		}
	}
	
	return HAM_IGNORED
	
	
	
}
//----------------------------------------------------------------------------------------------
public jaqueo_loop(id)
{
	id -= JAQUEO_HUD_TASKID
	
	if ( client_isnt_hitter(id)){
		
		return PLUGIN_HANDLED
		
	}
	status_hud(id)
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	gHeroLevel= get_cvar_num("jaqueo_level");
	scout_mult=get_cvar_float("jaqueo_scout_mult")
	teamglow_on=get_cvar_num("jaqueo_teamglow_on")
}
public _client_isnt_hitter(iPlugin,iParams){
	
	new gatling_user=get_param(1);
	
	
	new bool:result=(!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||(gatling_user < 0 || gatling_user > SH_MAXSLOTS))
	if(result) return true
	
	return !gHasJaqueo[gatling_user]
	
}


//----------------------------------------------------------------------------------------------
public newRound(id)
{	
	
	if(!gHasJaqueo[id]||!is_user_alive(id) ||!sh_is_active()) return PLUGIN_HANDLED
	
	reset_jaqueo_user(id)
	jaqueo_weapons(id)
	jaqueo_tasks(id)
	return PLUGIN_HANDLED
	
}
public sh_client_spawn(id){
	
	if(!gHasJaqueo[id]||!is_user_alive(id) ||!sh_is_active()) return PLUGIN_HANDLED
	
	reset_jaqueo_user(id)
	jaqueo_weapons(id)
	jaqueo_tasks(id)
	return PLUGIN_HANDLED
	
	
}
public Ham_respawn(id){
	
	if(!gHasJaqueo[id]||!is_user_alive(id) ||!sh_is_active()) return PLUGIN_HANDLED
	
	reset_jaqueo_user(id)
	jaqueo_weapons(id)
	jaqueo_tasks(id)
	return PLUGIN_HANDLED
	
	
}

//----------------------------------------------------------------------------------------------
public jaqueo_kd()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id) ||!jaqueo_get_has_jaqueo(id)||!shield_loaded(id)) {
		return PLUGIN_CONTINUE
	}
	if(shield_deployed(id)){
		
		sh_sound_deny(id)
		sh_chat_message(id, jaqueo_get_hero_id(), "Shield already on!")
		return PLUGIN_HANDLED
		
	}
	shield_charge_user(id)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public jaqueo_ku()
{
	new temp[6]
	
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id) ||!jaqueo_get_has_jaqueo(id)) {
		return PLUGIN_HANDLED
	}
	
	if(!shield_deployed(id)){
		sh_chat_message(id,jaqueo_get_hero_id(),"Shield not deployed. Action interrupted");
		shield_uncharge_user(id)
		return PLUGIN_HANDLED
	}
	
	
	return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
public sh_round_end(){
	
	
}
public client_disconnected(id){
	
	jaqueo_weapons(id)
	jaqueo_unmorph(id+JAQUEO_MORPH_TASKID)
	reset_jaqueo_user(id)
	
	return PLUGIN_HANDLED
	
}
public death()
{
	new id = read_data(2)
	jaqueo_unmorph(id+JAQUEO_MORPH_TASKID)
	if(gHasJaqueo[id]){
		
		shield_destroy(id)
		jaqueo_drop_weapons(id)
	}
}
public plugin_precache(){
	
	
	precache_model("models/player/jaqueo/jaqueo.mdl")
	precache_model("models/player/jaqueot/jaqueot.mdl")
	precache_model(JAQUEO_AK47_V_MODEL)
	precache_model(JAQUEO_SCOUT_V_MODEL)
	precache_model(JAQUEO_COOL_SCOUT_V_MODEL)
	precache_model(JAQUEO_COOL_SCOUT_P_MODEL)
	precache_model(JAQUEO_COOL_SCOUT_W_MODEL)
	for(new i=0;i<sizeof(jaqueo_cool_scout_sounds);i++){
		
		engfunc(EngFunc_PrecacheSound,jaqueo_cool_scout_sounds[i] );
		
	}
	
}

//----------------------------------------------------------------------------------------------
public jaqueo_tasks(id)
{
	set_task(1.0, "jaqueo_morph", id+JAQUEO_MORPH_TASKID)
	if( teamglow_on){
		set_task(1.0, "jaqueo_glow", id+JAQUEO_MORPH_TASKID, "", 0, "b" )
	}
	
}
//----------------------------------------------------------------------------------------------
public jaqueo_morph(id)
{
	id-=JAQUEO_MORPH_TASKID
	if ( gmorphed[id] || !is_user_alive(id)||!gHasJaqueo[id] ) return
	
	if ( get_user_team(id) == 1 )
	{
		cs_set_user_model(id, "jaqueo")
	}
	if ( get_user_team(id) == 2 )
	{
		cs_set_user_model(id, "jaqueot")
	}
	// Message
	/*set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 7)
	show_hudmessage(id, "M' ready.")*/
	
	gmorphed[id] = true
	
}
//----------------------------------------------------------------------------------------------
public jaqueo_unmorph(id)
{
	id-=JAQUEO_MORPH_TASKID
	if(!is_user_connected(id) ) return
	if ( gmorphed[id] ) {
		// Message
		/*set_hudmessage(50, 205, 50, -1.0, 0.40, 2, 0.02, 4.0, 0.01, 0.1, 7)
		show_hudmessage(id, "Bros I died")*/
		
		cs_reset_user_model(id)
		
		gmorphed[id] = false
		
		if ( teamglow_on ) {
			remove_task(id+JAQUEO_MORPH_TASKID)
			set_user_rendering(id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public jaqueo_glow(id)
{
	id -= JAQUEO_MORPH_TASKID
	
	if ( !is_user_connected(id) ) {
		//Don't want any left over residuals
		remove_task(id+JAQUEO_MORPH_TASKID)
		return
	}
	
	if ( gHasJaqueo[id] && is_user_alive(id)) {
		if ( get_user_team(id) == 1 ) {
			shGlow(id, 255, 0, 0)
		}
		else {
			shGlow(id, 0, 0, 255)
		}
	}
}
public weapon_change(id)
{
	if ( !sh_is_active() || !gHasJaqueo[id] ) return
	
	new weapon= read_data(2)
	//weaponID = read_data(2)
	if ( (weapon != CSW_SCOUT) && (weapon != CSW_AK47)){
		
		return
		
	}
	switch_model(id)
		
}
