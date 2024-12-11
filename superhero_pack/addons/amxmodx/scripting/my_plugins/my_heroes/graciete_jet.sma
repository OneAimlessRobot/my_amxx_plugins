
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "q_barrel_inc/sh_graciete_get_set.inc"
#include "q_barrel_inc/sh_q_barrel.inc"
#include "q_barrel_inc/sh_graciete_rocket.inc"


#define PLUGIN "Superhero graciete jetty funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

#pragma dynamic 100000
new g_graciete_jetpack_cooldown[SH_MAXSLOTS+1];
new Float:g_graciete_base_gravity[SH_MAXSLOTS+1];
new g_graciete_jetpack_loaded[SH_MAXSLOTS+1];
new g_graciete_jetpack[SH_MAXSLOTS+1];
new Float:g_graciete_land_power[SH_MAXSLOTS+1];
new bool:g_graciete_power_landing[SH_MAXSLOTS+1];
new bool:g_graciete_leaped[SH_MAXSLOTS+1];
new smoke, white, fire
new m_trail
//const FL_INGROUND2 = (FL_CONVEYOR|FL_ONGROUND|FL_PARTIALGROUND|FL_INWATER|FL_FLOAT)
const FL_INGROUND2=TOUCHING_GROUND
new jet_cooldown
//new Float:berserk_m3_mult
new Float:land_explosion_radius
new Float:jet_velocity
new Float:jet_stomp_fact
new Float:jet_stomp_grav_mult
new g_msgFade
new cmd_forward
new hud_sync_charge
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	arrayset(g_graciete_jetpack_cooldown,0,SH_MAXSLOTS+1)
	arrayset(g_graciete_jetpack_loaded,1,SH_MAXSLOTS+1)
	arrayset(g_graciete_jetpack,0,SH_MAXSLOTS+1)
	arrayset(g_graciete_land_power,0.0,SH_MAXSLOTS+1)
	arrayset(g_graciete_power_landing,false,SH_MAXSLOTS+1)
	arrayset(g_graciete_leaped,false,SH_MAXSLOTS+1)

	cmd_forward=register_forward(FM_CmdStart, "CmdStart");
	
	hud_sync_charge=CreateHudSyncObj()
	g_msgFade = get_user_msgid("ScreenFade");
	
	// Add your code here...
}

public plugin_natives(){

	register_native("clear_jps","_clear_jps",0);
	register_native("reset_graciete_user","_reset_graciete_user",0);
	register_native("jet_get_user_jet_cooldown","_jet_get_user_jet_cooldown",0)
	register_native("jet_get_user_power_landing","_jet_get_user_power_landing",0)
	register_native("jet_uncharge_user","_jet_uncharge_user",0)

	

}
public _jet_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	
	uncharge_user(id)
	sh_reset_min_gravity(id)


}
public _jet_get_user_jet_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_graciete_jetpack_cooldown[id]


}
public _jet_get_user_power_landing(iPlugin,iParams){
	new id=get_param(1)
	
	return g_graciete_power_landing[id]


}
public plugin_cfg(){

	loadCVARS();
}
public loadCVARS(){
	jet_cooldown=get_cvar_num("graciete_jet_cooldown");
	land_explosion_radius=get_cvar_float("graciete_land_explosion_radius");
	jet_velocity=get_cvar_float("graciete_jet_velocity");
	jet_stomp_fact=get_cvar_float("graciete_jet_stomp_fact")
	jet_stomp_grav_mult=get_cvar_float("graciete_jet_stomp_grav_mult")
}

public _reset_graciete_user(iPlugin,iParams){
	
	new id= get_param(1)
	g_graciete_jetpack_loaded[id]=true;
	g_graciete_jetpack_cooldown[id]=0;
	g_graciete_land_power[id]=0.0;
	g_graciete_power_landing[id]=false;
	g_graciete_leaped[id]=false;
	if(is_valid_ent(g_graciete_jetpack[id])){
		remove_entity(g_graciete_jetpack[id]);
		g_graciete_jetpack[id]=0;
	}
	
	
}

public plugin_end(){
	
	
	unregister_forward(FM_CmdStart,cmd_forward);
	
}
public plugin_precache(){
	
	
	white = precache_model("sprites/shockwave.spr")
	fire = precache_model("sprites/zerogxplode.spr")
	m_trail = precache_model("sprites/smoke.spr")
	precache_model(jp_mdl)
	engfunc(EngFunc_PrecacheSound,  jp_jump)
	engfunc(EngFunc_PrecacheSound,  jp_fly)
	engfunc(EngFunc_PrecacheSound,  crush_stunned)
	
	
}

public graciete_cooldown_loop(id){
	id-=GRACIETE_COOLDOWN_TASKID;
	//sh_chat_message(id,gHeroID,"Loop running! %d seconds left!",g_graciete_jetpack_cooldown[id]);
	if(client_isnt_hitter(id)){
		return PLUGIN_HANDLED
		
	}
	if(g_graciete_jetpack_cooldown[id]){
		
		g_graciete_jetpack_cooldown[id]-=1;
		
	}
	return PLUGIN_HANDLED
	
}
charge_user(id){
	if(client_isnt_hitter(id)) return 0
	
	g_graciete_base_gravity[id]=get_user_gravity(id)
	
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	
	g_graciete_jetpack[id]= CreateEntity("info_target")
	
	if(!is_valid_ent(g_graciete_jetpack[id])||(g_graciete_jetpack[id] == 0)) {
		return PLUGIN_HANDLED
	}
	Entvars_Set_String(g_graciete_jetpack[id], EV_SZ_classname, JP_CLASSNAME)
	ENT_SetModel(g_graciete_jetpack[id], jp_mdl)
	
	
	new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
	new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}
	
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_mins,fl_vecminsx)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_maxs,fl_vecmaxsx)
	
	ENT_SetOrigin(g_graciete_jetpack[id], vOrigin)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_angles, vAngles)
	Entvars_Set_Int(g_graciete_jetpack[id], EV_INT_effects, 64)
	Entvars_Set_Int(g_graciete_jetpack[id], EV_INT_solid, 0)
	Entvars_Get_Vector(id, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_velocity,  velocity)
	
	Entvars_Set_Edict(g_graciete_jetpack[id], EV_ENT_owner, id)
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	rockettrail(g_graciete_jetpack[id]+GRACIETE_TRAIL_TASKID)
	set_task(GRACIETE_CHARGE_PERIOD,"charge_task",id+GRACIETE_CHARGE_TASKID,"", 0,  "b")
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+GRACIETE_CHARGE_TASKID)
	g_graciete_power_landing[id]=false
	if(is_valid_ent(g_graciete_jetpack[id])){
		remove_entity(g_graciete_jetpack[id]);
		g_graciete_jetpack[id]=0;
	}
	emit_sound(id, CHAN_ITEM, jp_fly, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	return 0
	
	
	
}
public client_PostThink(id) {
	
	if( client_isnt_hitter(id)) { 
		return
	}
	if(g_graciete_leaped[id]){
		new flags = pev(id, pev_flags)
		if((flags  & FL_INGROUND2)){
			g_graciete_leaped[id]=false
			if(g_graciete_power_landing[id]){
				
				explosion(id);
				g_graciete_land_power[id]=0.0
				
			}
			uncharge_user(id)
			sh_reset_min_gravity(id)
		
		}
	}
}
public CmdStart(id, uc_handle)
{
	if (client_isnt_hitter(id)||!hasRoundStarted()) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	new flags = pev(id, pev_flags)
	if((flags  & FL_INGROUND2)){
		if((button & IN_DUCK)&&(button&IN_JUMP))
		{
			if(!g_graciete_jetpack_loaded[id]){
				
				client_print(id,print_center,"Cant jump yet! %d seconds left!",g_graciete_jetpack_cooldown[id]);
			}
			else{
				graciete_jump(id)
			}
		}
		return FMRES_IGNORED
	}
	if(g_graciete_leaped[id]){
		
			if((weapon==CSW_KNIFE)&&(button & IN_ATTACK2)&&(button & IN_DUCK)){
				if(!g_graciete_power_landing[id]){
					g_graciete_power_landing[id]=true
					charge_user(id)
					return FMRES_IGNORED
				}
			}
	}
	return FMRES_IGNORED;
}
public graciete_jump(id){
	
	emit_sound(id, CHAN_WEAPON, jp_jump, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	g_graciete_jetpack_loaded[id]=false;
	g_graciete_leaped[id]=true;	
	JetpackJump(id, floatround(jet_velocity));
	g_graciete_jetpack_cooldown[id]=jet_cooldown
	set_task(1.0,"graciete_cooldown_loop",id+GRACIETE_COOLDOWN_TASKID,"",0,"a",jet_cooldown);
	set_task(float(jet_cooldown),"load_jetpack",id+GRACIETE_LOAD_TASKID,"",0,"a",1);
	
}
public load_jetpack(id){
	id-=GRACIETE_LOAD_TASKID
	
	g_graciete_jetpack_loaded[id]=true;	
	
	
}
public rockettrail(id)
{
	id-=GRACIETE_TRAIL_TASKID
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BEAMFOLLOW )
	write_short(id) // entity
	write_short(m_trail)  // model
	write_byte( 10)       // life
	write_byte( 15 )        // width
	write_byte(graciete_color[0])			// r, g, b
	write_byte(graciete_color[1])		// r, g, b
	write_byte(graciete_color[2])			// r, g, b
	write_byte(255) // brightness
	
	message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
}
public charge_task(id){
	id-=GRACIETE_CHARGE_TASKID
	if(client_isnt_hitter(id)) return
	
	
	
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
	Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	
	
	if(!is_valid_ent(g_graciete_jetpack[id])||(g_graciete_jetpack[id] == 0)) {
		return
	}
	ENT_SetOrigin(g_graciete_jetpack[id], vOrigin)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_angles, vAngles)
	Entvars_Get_Vector(id, EV_VEC_velocity, velocity)
	Entvars_Set_Vector(g_graciete_jetpack[id], EV_VEC_velocity,  velocity)
	
	set_user_gravity(id,g_graciete_base_gravity[id]*jet_stomp_grav_mult);
	
	new hud_msg[128];
	g_graciete_land_power[id]=floatmin(GRACIETE_MAX_DAMAGE,floatadd(g_graciete_land_power[id],GRACIETE_CHARGE_RATE))
	format(hud_msg,127,"[SH]: Curr charge: %0.2f^n",(g_graciete_land_power[id])
	);
	set_hudmessage(graciete_color[0], graciete_color[1], graciete_color[2], -1.0, -1.0, graciete_color[3], 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
	
	
	
	
	
	
}
public _clear_jps(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, JP_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada,  JP_CLASSNAME)
	}
}

public JetpackJump( id,intensity){
	
	new Float:velocity[3];
	VelocityByAim(id, intensity, velocity);
	new Float:vector_len=vector_length(velocity);
	velocity[0]=velocity[0]/vector_len;
	velocity[1]=velocity[1]/vector_len;
	velocity[2]=velocity[2]/vector_len;
	
	velocity[0]=velocity[0]*float(intensity);
	velocity[1]=velocity[1]*float(intensity);
	velocity[2]=velocity[2]*float(intensity);
	velocity[2]=floatabs(velocity[2])+250;
	set_pev(id, pev_velocity, velocity);
}

//----------------------------------------------------------------------------------------------
public move_enemy(parm[])
{
	new victim = parm[3]
	
	new Float:fl_velocity[3]
	fl_velocity[0] = float(parm[0])
	fl_velocity[1] = float(parm[1])
	fl_velocity[2] = floatabs(float(parm[2]))
	
	set_pev(victim, pev_velocity, fl_velocity)
	
}
public explosion(ent_id){
	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	explode_fx(iOrigin)
	
	new entlist[33];
	new numfound = find_sphere_class(ent_id,"player", land_explosion_radius ,entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new CsTeams:idTeam = cs_get_user_team(ent_id)
		
		new pid = entlist[i];
		
		sh_screen_shake(ent_id,10.0,3.0,10.0)
		if(pid!=ent_id){
			if(cs_get_user_team(pid)==idTeam) continue
		}
		damage_player(ent_id,pid)
		
	}
}
public damage_player(ent_id,pid){
	
	
	
	new Float:b_vel[3],Float:vOrig[3],Float:usOrig[3]
	
	Entvars_Get_Vector(pid, EV_VEC_origin, vOrig)
	Entvars_Get_Vector(ent_id, EV_VEC_origin, usOrig)
	
	Entvars_Get_Vector(ent_id, EV_VEC_velocity, b_vel)
	
	new Float:velocity=vector_length(b_vel)
	new Float:distance=get_distance_f(vOrig,usOrig);
	
	b_vel[0]=((vOrig[0] -usOrig[0]) / distance)*jet_stomp_fact
	b_vel[1]=((vOrig[1] - usOrig[1]) / distance)*jet_stomp_fact
	b_vel[2]=(b_vel[2]*velocity)*jet_stomp_fact
	
	
	if(pid!=ent_id){
		
		new parm[4]
		
		parm[0] = floatround(b_vel[0])
		parm[1] = floatround(b_vel[1])
		parm[2] = floatround(b_vel[2])
		parm[3] = pid
		set_task(0.1, "move_enemy", 0, parm, 4)
		sh_set_stun(pid,3.0,0.5)
	}
	new client_name[128];
	new attacker_name[128];
	get_user_name(pid,client_name,127);
	get_user_name(ent_id,attacker_name,127);
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(pid,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	distance=vector_distance(vic_origin,mine_origin);
	new Float:falloff_coeff= floatmin(1.0,distance/land_explosion_radius);
	sh_extra_damage(pid,ent_id,floatround(g_graciete_land_power[ent_id]-(g_graciete_land_power[ent_id]/2.0)*falloff_coeff),"Graciete pound");
	sh_screen_shake(pid,10.0,3.0,10.0)
	unfade_screen_user(pid)
	emit_sound(pid, CHAN_VOICE, crush_stunned, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	sh_chat_message(ent_id,graciete_get_hero_id(),"%s was shattered by you!",client_name);
	sh_chat_message(pid,graciete_get_hero_id(),"%s shattered you!",attacker_name);
}
unfade_screen_user(id){
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client"  
	write_short(1<<12); // fade lasts this long duration  
	write_short(1<<8); // fade lasts this long hold time  
	write_short(FADE_OUT); // fade type
	write_byte(0); // fade red  
	write_byte(0); // fade green  
	write_byte(0); // fade blue	 
	write_byte(255); // fade alpha	 
	message_end();	
	
}
//-----------------------------------------------------------------------------------------------
public explode_fx( vec1[3] )
{
	// blast circles
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 21 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 16)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 1936)
	write_short( white )
	write_byte( 0 ) // startframe
	write_byte( 0 ) // framerate
	write_byte( 2 ) // life 2
	write_byte( 60 ) // width 16
	write_byte( 0 ) // noise
	write_byte( 255 ) // r
	write_byte( 0 ) // g
	write_byte( 0 ) // b
	write_byte( 255 ) //brightness
	write_byte( 0 ) // speed
	message_end()
	//Explosion2
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 12 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_byte( 188 ) // byte (scale in 0.1's) 188
	write_byte( 10 ) // byte (framerate)
	message_end()
	
	//TE_Explosion
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 3 )
	write_coord(vec1[0] + random_num( -100, 100 ))
	write_coord(vec1[1] + random_num( -100, 100 ))
	write_coord(vec1[2]+ random_num( -50, 50 ))
	write_short( fire )
	write_byte(  random_num(0,20) + 20  ) // byte (scale in 0.1's) 188
	write_byte( 12 ) // byte (framerate)
	write_byte( 0 ) // byte flags
	message_end()
	
	//Smoke
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 5 ) // 5
	write_coord(vec1[0] + random_num( -100, 100 ))
	write_coord(vec1[1] + random_num( -100, 100 ))
	write_coord(vec1[2] + random_num( -50, 50 ))
	write_short( smoke )
	write_byte( 60 )  // 2
	write_byte( 10 )  // 10
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(109)		// decal and ricochet sound
	write_coord(vec1[0])	// pos
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short(0)			// I have no idea what thats supposed to be
	write_byte(28)			// decal
	message_end()
}
