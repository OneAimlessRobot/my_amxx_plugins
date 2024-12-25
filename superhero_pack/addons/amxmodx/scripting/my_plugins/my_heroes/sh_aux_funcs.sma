
#include "../my_include/superheromod.inc"
#include <fakemeta_util>
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux funcs"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new smoke, white, fire
new m_trail
new gSpriteLaser,blood1,blood2,sprite1;
new g_msgFade

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_msgFade = get_user_msgid("ScreenFade");
	
	
	// Add your code here...
}

public plugin_natives(){

	register_native("explosion_player","_explosion_player",0);
	register_native("explosion","_explosion",0);
	register_native("track_user","_track_user",0);
	register_native("unradioactive_user","_unradioactive_user",0);
	register_native("make_shockwave","_make_shockwave",0)
	register_native("draw_bbox","_draw_bbox",0);

	

}

trail(vec1[3],vec2[3],const color[4],id){

//BEAMENTPOINTS
		message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0}, id)
		write_byte (0)     //TE_BEAMENTPOINTS 0
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2])
		write_coord(vec2[0])
		write_coord(vec2[1])
		write_coord(vec2[2])
		write_short( gSpriteLaser )
		write_byte(1) // framestart
		write_byte(5) // framerate
		write_byte(2) // life
		write_byte(10) // width
		write_byte(0) // noise
		write_byte( color[0] )     // r, g, b
		write_byte( color[1] )       // r, g, b
		write_byte( color[2])
		write_byte( color[3]) // brightness
		write_byte(300) // speed
		message_end()
}
public track_task(array[],id){
	id-=RADIOACTIVE_TASK_ID
	
	new hud_msg[256]
	new client_name[128]
	new distance, origin[3], eorigin[3],att_origin[3]
	get_user_name(id,client_name,127)
	
	get_user_origin(id, eorigin)
	get_user_origin(array[0], origin)
	get_user_origin(array[0], att_origin)
			
	distance = get_distance(eorigin, origin)
	format(hud_msg,256,"%s.^nDistance: %d^nNumero de teamates: %d^n",client_name,distance,array[2]);
	set_hudmessage(240, 80, 30,  0.0, 0.2, 0, 0.0, 1.0)
	ShowSyncHudMsg(array[0],array[1], "%s", hud_msg)
	detect_user(array[0],id,eorigin);
	trail(eorigin,origin,radioactive_color,array[0])
	for(new i=0;i<array[2];i++){
		if(array[i+5]==array[0]){
			continue
		}
		get_user_origin(array[i+5], origin)
			
		distance = get_distance(eorigin, origin)
		format(hud_msg,127,"%s.^nDistance: %d",client_name,distance);
		set_hudmessage(240, 80, 30,  0.0, 0.2, 0, 0.0, 1.0)
		ShowSyncHudMsg(array[i+5],array[1], "%s", hud_msg)
		detect_user(array[i+5],id,eorigin);
		trail(eorigin,origin,radioactive_color,array[i+5])
		
	}
	sh_set_rendering(id, radioactive_color[0],  radioactive_color[1], radioactive_color[2], radioactive_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, radioactive_color[0], radioactive_color[1], radioactive_color[2],  50)
	aura(id,radioactive_color)
	if(array[3]){
		sh_extra_damage(id,array[0],array[4],"SH_TRACKING",0,SH_DMG_NORM)
	}
	

}

public _make_shockwave(iPlugin,iParams){

	new point[3]
	get_array(1,point,3)
	new Float:radius=get_param_f(2)
	new color[4]
	get_array(3,color,4)


	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 21 )
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2] + 16)
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2] + floatround(radius))
	write_short( white )
	write_byte( 0 )
	write_byte(1)		// frame rate in 0.1's
	write_byte(6)		// life in 0.1's
	write_byte(8)		// line width in 0.1's
	write_byte(1)		// noise amplitude in 0.01's
	write_byte( color[0])
	write_byte( color[1] )
	write_byte( color[2] )
	write_byte( color[3] )
	write_byte( 0 )
	message_end()
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_LAVASPLASH);
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2] + 16)
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE);
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2] + floatround(radius))
	write_short(blood2);
	write_short(blood1);
	write_byte(255);
	write_byte(30);
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_DLIGHT);
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2])
	write_byte( color[0])
	write_byte( color[1] )
	write_byte( color[2] )
	write_byte( color[3] )
	write_byte(8);
	write_byte(60);
	message_end();

}
public _track_user(iPlugin,iParams){
	new hero_id=get_param(1)
	new id=get_param(2)
	new attacker=get_param(3)
	new do_damage=get_param(4)
	new damage= get_param(5)
	new Float:period=get_param_f(6)
	new Float:time=get_param_f(7)
	
	new  radioactive_times=floatround(time/period)
	new players[SH_MAXSLOTS]
	new team_name[32]
	new client_name[128]
	new team_mate_name[128]
	new enemy_name[128]
	new player_count;
	
	get_user_name(id,enemy_name,127)
	get_user_name(attacker,client_name,127)
	
	get_user_team(attacker,team_name,32)
	get_players(players,player_count,"ea",team_name)
	
	for(new i=0;i<player_count;i++){
		
		get_user_name(players[i],team_mate_name,127)
		sh_chat_message(players[i],hero_id,"Your teamate %s has revealed %s's position in the radar!",client_name,enemy_name)
		sh_chat_message(attacker,hero_id,"%s knows!!!",team_mate_name)
	
	}
	new array[5+33]
	array[0] = attacker
	array[1] = CreateHudSyncObj()
	array[2] = player_count
	array[3] = do_damage
	array[4] = damage
	for(new i=0;i<player_count;i++){
	
		array[5+i]=players[i]
	}
	set_task(period,"track_task",id+RADIOACTIVE_TASK_ID,array, sizeof(array),  "a",radioactive_times)
	set_task(floatsub(floatmul(period,float(radioactive_times)),0.1),"unradioactive_task",id+UNRADIOACTIVE_TASK_ID,"", 0,  "a",1)
	return 0



}

detect_user(id,enemy,PlayerCoords[3]){


	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
	write_byte(id)
	write_byte(enemy)           
	write_coord(PlayerCoords[0])
	write_coord(PlayerCoords[1])
	write_coord(PlayerCoords[2])
	message_end()
			
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
	write_byte(enemy)
	message_end()


}

aura(id,const color[4]){

	new origin[3]

	get_user_origin(id, origin, 1)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(15)
	write_byte(color[0])			// r, g, b
	write_byte(color[1])		// r, g, b
	write_byte(color[2])			// r, g, b
	write_byte(3)			// life
	write_byte(1)			// decay
	message_end()

}

public _unradioactive_user(iPlugins,iParams){
	new id=get_param(1)
	remove_task(id+UNRADIOACTIVE_TASK_ID)
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+RADIOACTIVE_TASK_ID)
	return 0



}

public unradioactive_task(id){
	id-=UNRADIOACTIVE_TASK_ID
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+RADIOACTIVE_TASK_ID)
	return 0



}

//----------------------------------------------------------------------------------------------
public move_enemy(parm[])
{
	new victim = parm[3]
	
	new Float:origin[3]
	
	pev(victim,pev_origin,origin)
	
	origin[2]+=100.0
	
	set_pev(victim,pev_origin,origin)
	
	new Float:fl_velocity[3]
	fl_velocity[0] = float(parm[0])
	fl_velocity[1] = float(parm[1])
	fl_velocity[2] = floatabs(float(parm[2]))
	
	set_pev(victim, pev_velocity, fl_velocity)
	
}
public _explosion_player(iPlugin,iParams){
	new hero_id=get_param(1)
	new ent_id=get_param(2)
	new Float:explosion_radius=get_param_f(3)
	new Float:peak_power=get_param_f(4)
	
	
	if(!is_user_connected(ent_id)){
		return
	
	}
	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	explode_fx(iOrigin)
	
	new entlist[33];
	new numfound = find_sphere_class(ent_id,"player", explosion_radius ,entlist, 32);
	
	new CsTeams:idTeam = cs_get_user_team(ent_id)
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		sh_screen_shake(pid,10.0,3.0,10.0)
		if(pid!=ent_id){
			if(cs_get_user_team(pid)==idTeam){
				continue
			}
		}
		damage_player(hero_id,ent_id,ent_id,pid,explosion_radius,peak_power)
		
	}
}
public _explosion(iPlugin,iParams){
	new hero_id=get_param(1)
	new ent_id=get_param(2)
	new Float:explosion_radius=get_param_f(3)
	new Float:peak_power=get_param_f(4)
	
	if(!pev_valid(ent_id)){
	
		return 
	
	}
	
	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	explode_fx(iOrigin)
	
	new entlist[33];
	new numfound = find_sphere_class(ent_id,"player", explosion_radius ,entlist, 32);
	
	new owner_id=pev(ent_id,pev_owner)
	new CsTeams:idTeam = cs_get_user_team(owner_id)
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		sh_screen_shake(pid,10.0,3.0,10.0)
		if(pid!=owner_id){
			if(cs_get_user_team(pid)==idTeam){
				continue
			}
		}
		damage_player(hero_id,ent_id,owner_id,pid,explosion_radius,peak_power)
		
	}
}
damage_player(hero_id,ent_id,owner_id,pid,Float:radius,Float:peak_power){
	
	
	
	new Float:b_vel[3],Float:vOrig[3],Float:usOrig[3]
	
	Entvars_Get_Vector(pid, EV_VEC_origin, vOrig)
	Entvars_Get_Vector(ent_id, EV_VEC_origin, usOrig)
	
	Entvars_Get_Vector(ent_id, EV_VEC_velocity, b_vel)
	
	new Float:distance=get_distance_f(vOrig,usOrig);
	new client_name[128];
	new attacker_name[128];
	get_user_name(pid,client_name,127);
	get_user_name(owner_id,attacker_name,127);
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(pid,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	distance=vector_distance(vic_origin,mine_origin);
	new Float:falloff_coeff= floatmin(1.0,distance/radius);
	new Float:force=peak_power-(peak_power/2.0)*falloff_coeff
	new iforce=floatround(force)
	sh_extra_damage(pid,owner_id,iforce,"SH_Explosion");
	
	b_vel[0]=((vOrig[0] -usOrig[0]) )*force
	b_vel[1]=((vOrig[1] -usOrig[1]) )*force
	b_vel[2]=force
	
	
	if(pid!=owner_id){
		
		new parm[4]
		
		parm[0] = floatround(b_vel[0])
		parm[1] = floatround(b_vel[1])
		parm[2] = floatround(b_vel[2])
		parm[3] = pid
		set_task(0.1, "move_enemy", 0, parm, 4)
		sh_set_stun(pid,3.0,0.5)
	}
	sh_screen_shake(pid,10.0,3.0,10.0)
	unfade_screen_user(pid)
	emit_sound(pid, CHAN_VOICE, crush_stunned, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	sh_chat_message(owner_id,hero_id,"%s was shattered by you!",client_name);
	sh_chat_message(pid,hero_id,"%s shattered you!",attacker_name);
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
//----------------------------------------------------------------------------------------------
laser_line(ent_id,Float:Pos[3], Float:vEnd[3],killbeam)
{
	if ( !pev_valid(ent_id) ) return
	
	static  colors[3]
	
	switch ( cs_get_user_team(pev(ent_id, pev_owner)) )
	{
		case CS_TEAM_T: colors = LineColors[RED]
			case CS_TEAM_CT: colors = LineColors[BLUE]
				default: colors = LineColors[CUSTOM]
	}
	//This is a little cleaner but not much
	if ( killbeam ) {
		//Kill the Beam
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin
		write_byte(TE_KILLBEAM)
		write_short(ent_id) // entity
		message_end()
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin
	write_byte (0)     //TE_BEAMENTPOINTS 0
	write_coord_f(Pos[0])
	write_coord_f(Pos[1])
	write_coord_f(Pos[2])		// start entity
	write_coord_f(vEnd[0])	// end position
	write_coord_f( vEnd[1])
	write_coord_f(vEnd[2])
	write_short(gSpriteLaser)// sprite index
	write_byte(0)		// starting frame
	write_byte(0)		// frame rate in 0.1's
	write_byte(1)		// life in 0.1's
	write_byte(5)		// line width in 0.1's
	write_byte(0)		// noise amplitude in 0.01's
	write_byte(colors[0])	// Red
	write_byte(colors[1])	// Green
	write_byte(colors[2])	// Blue
	write_byte(255)	// brightness
	write_byte(0)		// scroll speed in 0.1's
	message_end()
}
public _draw_bbox(iPlugin,iParams){
	new ent_id=get_param(1)
	new killbeam=get_param(2)
	new Float:bbox_mins[3],Float:bbox_maxs[3],Float:ent_orig[3]
		
	//Example: vex_rld = vex rear left down (z, y, x)
	//left= min
	//right= max

	Entvars_Get_Vector(ent_id, EV_VEC_mins,bbox_mins)
	Entvars_Get_Vector(ent_id, EV_VEC_maxs,bbox_maxs)
	pev(ent_id,pev_origin,ent_orig)
	new Float:vex_rld[3],Float:vex_rlu[3],Float:vex_rrd[3],Float:vex_rru[3];
	new Float:vex_fld[3],Float:vex_flu[3],Float:vex_frd[3],Float:vex_fru[3];
	
	// Rear left down
	vex_rld[0] = ent_orig[0] + bbox_mins[0];
	vex_rld[1] = ent_orig[1] + bbox_mins[1];
	vex_rld[2] = ent_orig[2] + bbox_mins[2];
	
	// Rear left up
	vex_rlu[0] = ent_orig[0] + bbox_mins[0];
	vex_rlu[1] = ent_orig[1] + bbox_mins[1];
	vex_rlu[2] = ent_orig[2] + bbox_maxs[2];
	
	// Rear right down
	vex_rrd[0] = ent_orig[0] + bbox_maxs[0];
	vex_rrd[1] = ent_orig[1] + bbox_mins[1];
	vex_rrd[2] = ent_orig[2] + bbox_mins[2];
	
	// Rear right up
	vex_rru[0] = ent_orig[0] + bbox_maxs[0];
	vex_rru[1] = ent_orig[1] + bbox_mins[1];
	vex_rru[2] = ent_orig[2] + bbox_maxs[2];
	
	// Front left down
	vex_fld[0] = ent_orig[0] + bbox_mins[0];
	vex_fld[1] = ent_orig[1] + bbox_maxs[1];
	vex_fld[2] = ent_orig[2] + bbox_mins[2];
	
	// Front left up
	vex_flu[0] = ent_orig[0] + bbox_mins[0];
	vex_flu[1] = ent_orig[1] + bbox_maxs[1];
	vex_flu[2] = ent_orig[2] + bbox_maxs[2];
	
	// Front right down
	vex_frd[0] = ent_orig[0] + bbox_maxs[0];
	vex_frd[1] = ent_orig[1] + bbox_maxs[1];
	vex_frd[2] = ent_orig[2] + bbox_mins[2];
	
	// Front right up
	vex_fru[0] = ent_orig[0] + bbox_maxs[0];
	vex_fru[1] = ent_orig[1] + bbox_maxs[1];
	vex_fru[2] = ent_orig[2] + bbox_maxs[2];
	
	//draw lines
	
	laser_line(ent_id, vex_rld, vex_rrd, killbeam);
	laser_line(ent_id, vex_rld, vex_rlu, killbeam);
	laser_line(ent_id, vex_rrd, vex_rru, killbeam);
	laser_line(ent_id, vex_rlu, vex_rru, killbeam);
	
	// Front face
	laser_line(ent_id, vex_fld, vex_frd, killbeam);
	laser_line(ent_id, vex_fld, vex_flu, killbeam);
	laser_line(ent_id, vex_frd, vex_fru, killbeam);
	laser_line(ent_id, vex_flu, vex_fru, killbeam);
	
	// Connecting lines
	laser_line(ent_id, vex_rld, vex_fld, killbeam);
	laser_line(ent_id, vex_rlu, vex_flu, killbeam);
	laser_line(ent_id, vex_rrd, vex_frd, killbeam);
	laser_line(ent_id, vex_rru, vex_fru, killbeam);
	
	


}

//-----------------------------------------------------------------------------------------------
explode_fx( vec1[3] )
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
public plugin_precache(){
	
	
	white = precache_model("sprites/shockwave.spr")
	fire = precache_model("sprites/zerogxplode.spr")
	gSpriteLaser = precache_model("sprites/laserbeam.spr")
	engfunc(EngFunc_PrecacheSound,  crush_stunned)
	m_trail = precache_model("sprites/smoke.spr")
	blood1 = precache_model("sprites/blood.spr");
	blood2 = precache_model("sprites/bloodspray.spr");
	precache_sound("ambience/particle_suck2.wav")
	sprite1 = precache_model("sprites/white.spr")
	
	
}

