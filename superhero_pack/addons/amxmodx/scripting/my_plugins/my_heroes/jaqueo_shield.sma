
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "shield_inc/sh_jaqueo_get_set.inc"
#include "shield_inc/sh_jaqueo_shield.inc"


#define PLUGIN "Superhero jaqueo ratty funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new g_jaqueo_shield_cooldown[SH_MAXSLOTS+1];
new g_jaqueo_shield_loaded[SH_MAXSLOTS+1];
new g_jaqueo_shield_deployed[SH_MAXSLOTS+1];
new g_jaqueo_shield[SH_MAXSLOTS+1];
new Float:g_last_attack_release_gametime[SH_MAXSLOTS+1]
new g_normal_ptr[SH_MAXSLOTS+1]

#define MAX_BURST_FIRE_TIME 0.2
#define GUNS_BIT_SUM ((1<<CSW_P228) | (1<<CSW_SCOUT) | (1<<CSW_XM1014) | (1<<CSW_MAC10) | (1<<CSW_AUG) | (1<<CSW_ELITE) | (1<<CSW_FIVESEVEN) | (1<<CSW_UMP45) | (1<<CSW_SG550) | (1<<CSW_GALIL) | (1<<CSW_FAMAS) | (1<<CSW_USP) | (1<<CSW_GLOCK18) | (1<<CSW_AWP) | (1<<CSW_MP5NAVY) | (1<<CSW_M249) | (1<<CSW_M3) | (1<<CSW_M4A1) | (1<<CSW_TMP) | (1<<CSW_G3SG1) | (1<<CSW_DEAGLE) | (1<<CSW_SG552) | (1<<CSW_AK47) | (1<<CSW_P90))
#define BURSTGUNS_BIT_SUM ((1<<CSW_FAMAS) | (1<<CSW_GLOCK18))
new Float:shield_cooldown
new Float:shield_radius
new Float:shield_max_hp
new gSpriteLaser
new hud_sync_charge
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	arrayset(g_jaqueo_shield_cooldown,0,SH_MAXSLOTS+1)
	arrayset(g_jaqueo_shield_loaded,1,SH_MAXSLOTS+1)
	arrayset(g_jaqueo_shield_deployed,0,SH_MAXSLOTS+1)
	arrayset(g_normal_ptr,0,SH_MAXSLOTS+1)
	arrayset(g_last_attack_release_gametime,0.0,SH_MAXSLOTS+1)
	arrayset(g_jaqueo_shield,0,SH_MAXSLOTS+1)

	
	hud_sync_charge=CreateHudSyncObj()
	register_forward(FM_TraceLine,"fw_traceline",1);
	//register_forward(FM_Touch,"touch_shield")
	register_forward(FM_PlayerPreThink, "fwPlayerPreThink")
	register_forward(FM_Think, "shield_think")
	//register_forward(FM_Touch, "shield_touch")
	RegisterHam(Ham_TakeDamage,"player","Shield_Damage",_,true)
	
	// Add your code here...
}

//----------------------------------------------------------------------------------------------
public fwPlayerPreThink(id)
{
	if ((pev(id, pev_oldbuttons) & IN_ATTACK) && !(pev(id, pev_button) & IN_ATTACK)) {
		// the primary attack button is released
		// save the current gametime
		g_last_attack_release_gametime[id] = get_gametime()
	}
}
public Shield_Damage(this, idinflictor, idattacker, Float:damage, damagebits){
	
	if(!shModActive() || !is_user_connected(this)||!is_user_alive(this)||!jaqueo_get_has_jaqueo(this)) return HAM_IGNORED
	
	if(!g_jaqueo_shield_deployed[this]) return HAM_IGNORED

	damage=0.0;
	return HAM_SUPERCEDE



}
public plugin_natives(){

	register_native("clear_shields","_clear_shields",0);
	register_native("reset_jaqueo_user","_reset_jaqueo_user",0);
	register_native("shield_get_user_shield_cooldown","_shield_get_user_shield_cooldown",0)
	register_native("shield_uncharge_user","_shield_uncharge_user",0)
	register_native("shield_charge_user","_shield_charge_user",0)
	register_native("shield_loaded","_shield_loaded",0)
	register_native("shield_deployed","_shield_deployed",0)
	register_native("shield_destroy","_shield_destroy",0)

	

}

public fw_traceline(const Float:start[3], const Float:dest[3],ignore_monsters,id,ptr)
{
	if ( !sh_is_active() ) {
		return FMRES_IGNORED
	}

	if (ignore_monsters) {
		return FMRES_IGNORED
	}
	if(!jaqueo_get_has_jaqueo(id)||!is_user_alive(id)){
	
		return FMRES_IGNORED
	}
	if(!ptr){
	
		return FMRES_IGNORED
	}
	if (!g_normal_ptr[id]) {
		g_normal_ptr[id] = ptr

		return FMRES_IGNORED
	}
	if (is_user_alive(get_tr2(ptr, TR_pHit))) {
		return FMRES_IGNORED
	}
	/*if(ptr<=0){
		sh_chat_message(id,"Invalid tr!!!!! [shrugs shoulders]");
		return FMRES_IGNORED
	}*/
	new ent=get_tr2(ptr, TR_pHit)
	if(!pev_valid(ent)){
		return FMRES_IGNORED
	
	}
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, JAQUEO_SHIELD_CLASSNAME) ) return FMRES_IGNORED
	static clip, ammo, weapon_id
	sh_chat_message(pev(g_jaqueo_shield[id],pev_iuser1),jaqueo_get_hero_id(),"Atingiram-te o shield!");
	
	// get the current weapon index
	weapon_id = get_user_weapon(id, clip, ammo)

	if (!(GUNS_BIT_SUM & (1<<weapon_id))) {
		return FMRES_IGNORED
	}

	static Float:gametime

	// get current game time
	gametime = get_gametime()

	new bool:is_hold_primary_attack = bool:(pev(id, pev_button) & IN_ATTACK)

	if (!(BURSTGUNS_BIT_SUM & (1<<weapon_id))) {
		// the current weapon isn't a burst gun
		if (!is_hold_primary_attack) {
			return FMRES_IGNORED
		}
	}
	else {
		// the current weapon is a burst gun
		if (!is_hold_primary_attack) {
			if (gametime - g_last_attack_release_gametime[id] > MAX_BURST_FIRE_TIME) {
				return FMRES_IGNORED
			}
		}
	}
	static Float:fired_particle_start_origin[3], Float:vector[3]

	// get the player's origin and view offset
	pev(id, pev_origin, fired_particle_start_origin)
	pev(id, pev_view_ofs, vector)

	// get the fired particle start origin
	xs_vec_add(fired_particle_start_origin, vector, fired_particle_start_origin)
	static bool:particle_is_fired ; particle_is_fired = xs_vec_equal(fired_particle_start_origin, start)

	if (particle_is_fired) {
		static Float: vnormal[3], Float:bulletshot[3], Float:v[3], Float:t[3], Float:t2[3], Float:n[3], Float:vdotvnormal, Float:r[3]
		static ptr2, Float:f

		// get the end position of the current trace
		get_tr2(ptr, TR_vecEndPos, vector)
		xs_vec_copy(vector, bulletshot)

		xs_vec_sub(vector, fired_particle_start_origin, vector)

		get_tr2(ptr, TR_vecPlaneNormal, vnormal)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMPOINTS)	// 0
		engfunc(EngFunc_WriteCoord,bulletshot[0]-vnormal[0]*200)
		engfunc(EngFunc_WriteCoord,bulletshot[1]-vnormal[1]*200)
		engfunc(EngFunc_WriteCoord,bulletshot[2]-vnormal[2]*200)
		engfunc(EngFunc_WriteCoord,bulletshot[0]+vnormal[0]*200)
		engfunc(EngFunc_WriteCoord,bulletshot[1]+vnormal[1]*200)
		engfunc(EngFunc_WriteCoord,bulletshot[2]+vnormal[2]*200)
		write_short(gSpriteLaser)
		write_byte(1)		// framestart
		write_byte(1)		// framerate
		write_byte(50)		// life
		write_byte(5)		// width
		write_byte(0)		// noise
		write_byte(0)		// r, g, b
		write_byte(255)		// r, g, b
		write_byte(200)		// r, g, b
		write_byte(200)		// brightness
		write_byte(0)		// speed
		message_end()
		// Calculate boucing bullet
		v[0] = (bulletshot[0] - fired_particle_start_origin[0]) * -1
		v[1] = (bulletshot[1] - fired_particle_start_origin[1]) * -1
		v[2] = (bulletshot[2] - fired_particle_start_origin[2]) * -1

		vdotvnormal = xs_vec_dot(v,vnormal) * 2.0
		xs_vec_mul_scalar(vnormal, vdotvnormal, t)
		xs_vec_sub(t, v, t2)
		xs_vec_normalize(t2,r)
		xs_vec_mul_scalar(r, 2048.0, r)
		xs_vec_add(bulletshot, r, n)

		ptr2 = create_tr2()
		engfunc(EngFunc_TraceLine,bulletshot, n, DONT_IGNORE_MONSTERS, id, ptr2)
		get_tr2(ptr2,TR_flFraction, f)
		free_tr2(ptr2)
	}
	return FMRES_IGNORED
}
public _shield_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	
	uncharge_user(id)


}
public _shield_loaded(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jaqueo_shield_loaded[id]


}
public _shield_destroy(iPlugin,iParams){
	
	new id= get_param(1)
	g_jaqueo_shield_loaded[id]=true;
	g_jaqueo_shield_cooldown[id]=0;
	g_jaqueo_shield_deployed[id]=false;
	if(is_valid_ent(g_jaqueo_shield[id])){
		remove_entity(g_jaqueo_shield[id]);
		g_jaqueo_shield[id]=0;
	}
}
public _shield_deployed(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jaqueo_shield_deployed[id]


}
public _shield_get_user_shield_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_jaqueo_shield_cooldown[id]


}
public plugin_cfg(){

	loadCVARS();
}
public loadCVARS(){
	shield_cooldown=get_cvar_float("jaqueo_shield_cooldown");
	shield_radius=get_cvar_float("jaqueo_shield_radius");
	shield_max_hp=get_cvar_float("jaqueo_shield_max_hp")
}

public _reset_jaqueo_user(iPlugin,iParams){
	
	new id= get_param(1)
	g_jaqueo_shield_loaded[id]=true;
	g_jaqueo_shield_cooldown[id]=0;
	g_jaqueo_shield_deployed[id]=false;
	if(is_valid_ent(g_jaqueo_shield[id])){
		emit_sound(g_jaqueo_shield[id], CHAN_ITEM, shield_hum, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_jaqueo_shield[id]);
		g_jaqueo_shield[id]=0;
	}
	
	
}

public shield_deploy_task(parm[],id){
	
	id-=JAQUEO_DEPLOY_TASKID
	
	new attacker=parm[0];
	new shield_id=parm[1];
	if(!is_valid_ent(shield_id)){
		
		return;
	}
	/*set_pev(shield_id,pev_rendermode,kRenderTransAlpha)
	set_pev(shield_id,pev_renderfx,kRenderFxGlowShell)
	new alpha=camman_camera_minalpha*/
	set_pev(shield_id, pev_iuser1, 1)
	set_pev(shield_id, pev_takedamage, DAMAGE_YES)
	set_pev(shield_id, pev_solid, SOLID_BBOX)
	set_pev(shield_id,pev_owner,pev(shield_id,pev_iuser2))
	new alpha=190
	set_pev(shield_id,pev_renderamt,float(alpha))
	sh_chat_message(attacker,jaqueo_get_hero_id(),"Shield armed!");
	emit_sound(shield_id, CHAN_ITEM,shield_deploy, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_pev(shield_id, pev_nextthink, get_gametime() + JAQUEO_THINK_PERIOD)
}
public plugin_end(){
	
	
}
public plugin_precache(){


	precache_model( "models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
	precache_model(shield_mdl)
	gSpriteLaser = precache_model("sprites/laserbeam.spr")
	engfunc(EngFunc_PrecacheSound,  shield_deploy)
	engfunc(EngFunc_PrecacheSound,  shield_hum)
	engfunc(EngFunc_PrecacheSound,  shield_destroyed)
	
	
}

//----------------------------------------------------------------------------------------------
public shield_think(ent)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, JAQUEO_SHIELD_CLASSNAME) ) return FMRES_IGNORED
	
	static Float:vEnd[3], Float:gametime,Float:Pos[3]
	pev(ent, pev_origin, Pos)
	pev(ent, pev_vuser1, vEnd)
	gametime = get_gametime()
	new owner=pev(ent,pev_iuser2)
	new Float:shield_health=float(pev(ent,pev_health))
	
	if ( (shield_health<1000.0)) {
		if(g_jaqueo_shield[owner]){
			emit_sound(ent, CHAN_ITEM,shield_destroyed, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			sh_chat_message(owner,jaqueo_get_hero_id(),"Shield died!")
			uncharge_user(owner)
		}
		return FMRES_IGNORED
	}
	if(g_jaqueo_shield_deployed[owner]){
		
		new Float:vOrigin[3]
		new Float:vAngles[3]
		new Float:velocity[3]
		Entvars_Get_Vector(owner, EV_VEC_origin, vOrigin)
		Entvars_Get_Vector(owner, EV_VEC_v_angle, vAngles)
		new notFloat_vOrigin[3]
		notFloat_vOrigin[0] = floatround(vOrigin[0])
		notFloat_vOrigin[1] = floatround(vOrigin[1])
		notFloat_vOrigin[2] = floatround(vOrigin[2])
		
		ENT_SetOrigin(g_jaqueo_shield[owner], vOrigin)
		Entvars_Set_Vector(g_jaqueo_shield[owner], EV_VEC_angles, vAngles)
		Entvars_Get_Vector(owner, EV_VEC_velocity, velocity)
		Entvars_Set_Vector(g_jaqueo_shield[owner], EV_VEC_velocity,  velocity)
	
	
		client_print(owner,print_center,"jaqueo shield hp: %0.2f",float(pev(ent,pev_health))-1000.0)
	}
	set_pev(ent, pev_nextthink, gametime + (JAQUEO_THINK_PERIOD))
	return FMRES_IGNORED
}
public _shield_charge_user(iPlugin, iParams){
	
	new id= get_param(1)
	if(!g_jaqueo_shield_loaded[id]){
		
		sh_chat_message(id,jaqueo_get_hero_id(),"Shield not loaded")
		return
	}
	g_jaqueo_shield_loaded[id]=0
	
	new material[128]
	new health[128]	
	g_jaqueo_shield[id] = create_entity( "func_breakable" );
	new NewEnt=g_jaqueo_shield[id]
	if(!is_valid_ent(g_jaqueo_shield[id])||(g_jaqueo_shield[id] == 0)) {
		
		return
	}
	set_pev(NewEnt, pev_classname, JAQUEO_SHIELD_CLASSNAME)
	engfunc(EngFunc_SetModel, NewEnt, shield_mdl)
	float_to_str(1000.0,health,127)
	num_to_str(2,material,127)
	DispatchKeyValue( NewEnt, "material", material );
	DispatchKeyValue( NewEnt, "health", health );
	
	new Float:fl_vecminsx[3]
	new Float:fl_vecmaxsx[3]
	for (new i=0;i<3;i++){
		fl_vecminsx[i]=-shield_radius
		fl_vecmaxsx[i]=shield_radius
	
	}
	Entvars_Set_Vector(g_jaqueo_shield[id], EV_VEC_mins,fl_vecminsx)
	Entvars_Set_Vector(g_jaqueo_shield[id], EV_VEC_maxs,fl_vecmaxsx)
	
	set_pev(NewEnt, pev_health, 0)
	set_pev(NewEnt, pev_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides.
	set_pev(NewEnt, pev_solid, SOLID_NOT)
	set_pev(NewEnt, pev_body, 3)
	set_pev(NewEnt, pev_sequence, 7)	// 7 = TRIPMINE_WORLD
	set_pev(NewEnt, pev_takedamage, DAMAGE_NO)
	set_pev(NewEnt,pev_rendermode,kRenderTransAlpha)
	set_pev(NewEnt,pev_renderfx,kRenderFxGlowShell)
	new alpha=100
	set_pev(NewEnt,pev_renderamt,float(alpha))
	set_pev(g_jaqueo_shield[id],pev_iuser2,id)
	//set_pev(g_jaqueo_shield[id],pev_owner,id)
	new parm[2]
	parm[0]=id
	parm[1]=g_jaqueo_shield[id]
	set_task(shield_cooldown,"load_shield",id+JAQUEO_LOAD_TASKID,"", 0,  "a",1)
	set_task(JAQUEO_CHARGE_PERIOD,"charge_task",id+JAQUEO_CHARGE_TASKID,parm, 2,  "b")
	return
	
	
	
}
uncharge_user(id){
	remove_task(id+JAQUEO_CHARGE_TASKID)
	g_jaqueo_shield_deployed[id]=0
	if(is_valid_ent(g_jaqueo_shield[id])){
		emit_sound(g_jaqueo_shield[id], CHAN_ITEM, shield_hum, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		remove_entity(g_jaqueo_shield[id]);
		g_jaqueo_shield[id]=0;
	}
	g_jaqueo_shield_loaded[id]=1
	return 0
	
	
	
}
public load_shield(id){
	id-=JAQUEO_LOAD_TASKID
	
	g_jaqueo_shield_loaded[id]=1;	
	sh_chat_message(id,jaqueo_get_hero_id(),"Shield loaded");
	
	
}
public charge_task(parm[],id){
	id-=JAQUEO_CHARGE_TASKID
	//if(client_isnt_hitter(id)) return
	
	
	
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	if(!is_valid_ent(g_jaqueo_shield[id])||(g_jaqueo_shield[id] == 0)) {
		return
	}
	ENT_SetOrigin(g_jaqueo_shield[id], vOrigin)
	Entvars_Set_Vector(g_jaqueo_shield[id], EV_VEC_angles, vAngles)
	Entvars_Get_Vector(id, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(g_jaqueo_shield[id], EV_VEC_velocity,  velocity)
	
	
	new hud_msg[128];
	set_pev(g_jaqueo_shield[id],pev_health,floatmin(shield_max_hp,floatadd(float(pev(g_jaqueo_shield[id],pev_health)),floatmul(JAQUEO_CHARGE_PERIOD,JAQUEO_CHARGE_RATE))))
	format(hud_msg,127,"[SH]: Curr charge: %0.2f^n",float(pev(g_jaqueo_shield[id],pev_health)));
	set_hudmessage(jaqueo_color[0], jaqueo_color[1], jaqueo_color[2], -1.0, -1.0, 1, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
	new parm[2]
	parm[0]=id
	parm[1]=g_jaqueo_shield[id]
	
	emit_sound(g_jaqueo_shield[id], CHAN_ITEM,shield_hum, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	if((pev(g_jaqueo_shield[id],pev_health))>=floatround(shield_max_hp)){
	
		g_jaqueo_shield_deployed[id]=1;
		set_pev(g_jaqueo_shield[id],pev_health,1000.0+pev(g_jaqueo_shield[id],pev_health))
		shield_deploy_task(parm,id+JAQUEO_DEPLOY_TASKID)
		remove_task(id+JAQUEO_CHARGE_TASKID)
	}
	
	
	
	
	
	
}
public _clear_shields(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, JAQUEO_SHIELD_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada,  JAQUEO_SHIELD_CLASSNAME)
	}
}
