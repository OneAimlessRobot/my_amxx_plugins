#if defined sh_aux_funcs
  #endinput
#endif
#define sh_aux_funcs

#include "../my_include/superheromod.inc"
#include <fakemeta_util>


#define RADIOACTIVE_TASK_ID 73223627
#define UNRADIOACTIVE_TASK_ID 732231123

#define MATH_PI  3.1415926535897932384626433832795028841971

#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)
#define crush_stunned "shmod/Teliko/chaff/chaff_blow.wav"
#define SUCK_IN_SOUND_FILE_NAME "ambience/particle_suck2.wav"
#define NULL_SOUND "common/null.wav"

#define COLORS_NUM 11
//Colors To Pick From
#define CUSTOM		0
#define RED		1
#define GREEN		2
#define BLUE		3
#define LTBLUE		4
#define YELLOW		5
#define PURPLE		6
#define ORANGE		7
#define WHITE		8
#define PINK		9
#define LTGREEN     10

#define NULL_SOUND_FILENAME "common/null.wav"

#define BLOOD_COLOR_RED		247
#define BLOOD_COLOR_YELLOW	195
#define BLOOD_STREAM_RED	70
#define BLOOD_STREAM_YELLOW	60
#define BLOOD_SM_NUM 8
#define BLOOD_LG_NUM 2
stock blood_large_red[BLOOD_LG_NUM] = {204,205},
	blood_small_red[BLOOD_SM_NUM] = {190,191,192,193,194,195,196,197}


static const burn_decal[5] = {199,200,201,202,203}
stock Offset[8][3] = {{0,0,10},{0,0,30},{0,0,16},{0,0,10},{4,4,16},{-4,-4,16},{4,4,-12},{-4,-4,-12}}
stock g_msgFade
//Color definitions
stock const LineColors[COLORS_NUM][3] = {
	{150, 150, 150},	//Custom
	{255, 0, 0},		//Red
	{0, 255, 0},		//Green
	{0, 0, 255},		//Blue
	{0, 255, 255},		//Light Blue
	{255, 255, 0},		//Yellow
	{255, 0, 255},		//Purple
	{255, 128, 0},		//Orange
	{255, 255, 255},	//White
	{250, 92, 163},      //Pink
	{111,255,111}      //Light Green
}
stock const LineColorsWithAlpha[COLORS_NUM][4] = {
	{150, 150, 150,255},	//Custom
	{255, 0, 0,255},		//Red
	{0, 255, 0,100},		//Green
	{0, 0, 255,255},		//Blue
	{0, 255, 255,255},		//Light Blue
	{255, 255, 0,255},		//Yellow
	{255, 0, 255,255},		//Purple
	{255, 128, 0,255},		//Orange
	{255, 255, 255,255},	//White
	{250, 92, 163,255},      //Pink
	{111,255,111,40}      //Light Green
}

stock const Float:g_fReloadDelay[CSW_P90+1] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50, 
	2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70, 
	0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}
stock Float:null_vector[3]={0.0,0.0,0.0}
stock null_iVector[3]={0,0,0}

stock Float:x_vector[3]={1.0,0.0,0.0}
stock x_iVector[3]={1,0,0}
stock Float:y_vector[3]={0.0,1.0,0.0}
stock y_iVector[3]={0,1,0}
stock Float:z_vector[3]={0.0,0.0,1.0}
stock z_iVector[3]={0,0,1}


stock const tag_color[4]={0,255,255,255}
stock smoke, white, fire
stock m_trail
stock gSpriteLaser,blood1,blood2,sprite1;
stock g_iFireSprite, g_iSmokeSprite[2];
stock gSpriteSmoke, gSpriteFire, gSpriteBurning
stock hero_spawn_hud_msg_sync
stock tracker_hud_msg_sync
//gibs
stock mdl_gib_head,mdl_gib_meat,mdl_gib_flesh,spr_blood_spray,spr_blood_drop,mdl_gib_spine,mdl_gib_lung,mdl_gib_legbone
stock trail_custom(ent_id,color[4]={255,255,255,255},life=3,width=10){

		if(pev_valid(ent_id)!=2){
		
			return
		}
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(ent_id) // entity
		write_short(m_trail)  // model
		write_byte( life )       // life
		write_byte( width )        // width
		write_byte(color[0])			// r, g, b
		write_byte(color[1])		// r, g, b
		write_byte(color[2])			// r, g, b
		write_byte(color[3]) // brightness
		message_end()
}
stock trail(ent_id,color_const=PINK,life=3,width=10){

		if(pev_valid(ent_id)!=2){
		
			return
		}
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(ent_id) // entity
		write_short(m_trail)  // model
		write_byte( life )       // life
		write_byte( width )        // width
		write_byte(LineColorsWithAlpha[color_const][0])			// r, g, b
		write_byte(LineColorsWithAlpha[color_const][1])		// r, g, b
		write_byte(LineColorsWithAlpha[color_const][2])			// r, g, b
		write_byte(LineColorsWithAlpha[color_const][3]) // brightness
		message_end()
}
stock make_sparks(Float:the_pos[3]){
	

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, the_pos[0])
	engfunc(EngFunc_WriteCoord, the_pos[1])
	engfunc(EngFunc_WriteCoord, the_pos[2])
	message_end();	
	
}

stock random_fire(Origin[3], ent, Float:radius) {

	static iRange, iOrigin[3], g_g, i;

	iRange = floatround(radius);

	for (i = 1; i <= 5; i++) {

		g_g = 1;

		iOrigin[0] = Origin[0] + random_num(-iRange, iRange);
		iOrigin[1] = Origin[1] + random_num(-iRange, iRange);
		iOrigin[2] = Origin[2];
		iOrigin[2] = ground_z(iOrigin, ent);

		while (get_distance(iOrigin, Origin) > iRange) {		// If iOrigin is too far away, recalculate its position

			iOrigin[0] = Origin[0] + random_num(-iRange, iRange);
			iOrigin[1] = Origin[1] + random_num(-iRange, iRange);
			iOrigin[2] = Origin[2];

			if (++g_g >= ANTI_LAGG) {
				iOrigin[2] = ground_z(iOrigin, ent, 1);
			} else {
				iOrigin[2] = ground_z(iOrigin, ent);
			}
		}

		new rand = random_num(5, 15);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_SPRITE);
		write_coord(iOrigin[0]);	// Position
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2] + rand * 5);
		write_short(g_iFireSprite);	// Sprite index
		write_byte(rand);		// Scale
		write_byte(100);		// Brightness
		message_end();
	}

	// One smoke puff for each call to random_fire, regardless of number of flames
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SMOKE);
	write_coord(iOrigin[0]);			// Position
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 120);
	write_short(g_iSmokeSprite[random_num(0, 1)]);	// Sprite index
	write_byte(random_num(10, 30));			// Scale
	write_byte(random_num(10, 20));			// Framerate
	message_end();

}
stock make_fire(id, Float:rad){

	new radius=floatround(rad)
	new rx, ry, rz, Float:forigin[3]
	rx = random_num(-radius, radius)
	ry = random_num(-radius, radius)
	rz = random_num(-radius, radius)

	pev(id, pev_origin, forigin)

	// Additive sprite, plays 1 cycle
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)		// 17
	engfunc(EngFunc_WriteCoord, forigin[0] + rx)	// coord, coord, coord (position)
	engfunc(EngFunc_WriteCoord, forigin[1] + ry)
	engfunc(EngFunc_WriteCoord, forigin[2] + 10 + rz)
	write_short(gSpriteBurning)	// short (sprite index)
	write_byte(30)		// byte (scale in 0.1's)
	write_byte(200)		// byte (brightness)
	message_end()

	// Smoke
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SMOKE)		// 5
	engfunc(EngFunc_WriteCoord, forigin[0] + (rx*2))	// coord, coord, coord (position)
	engfunc(EngFunc_WriteCoord, forigin[1] + (ry*2))
	engfunc(EngFunc_WriteCoord, forigin[2] + 100 + (rz*2))
	write_short(gSpriteSmoke)	// short (sprite index)
	write_byte(60)		// byte (scale in 0.1's)
	write_byte(15)		// byte (framerate)
	message_end()


}
stock make_shockwave(point[3],Float:radius,const color[4],shockwave_frame_rate=1,shockwave_life=10,shockwave_line_width=8,shockwave_amplitude=1){



	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( TE_BEAMCYLINDER)
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2] + 16)
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2] + floatround(radius))
	write_short( white )
	write_byte( 0 )
	write_byte(shockwave_frame_rate)		// frame rate in 0.1's
	write_byte(shockwave_life)		// life in 0.1's
	write_byte(shockwave_line_width)		// line width
	write_byte(shockwave_amplitude)		// noise amplitude in 0.01's
	write_byte( color[0])
	write_byte( color[1] )
	write_byte( color[2] )
	write_byte( color[3] )
	write_byte(0)
	message_end()

}

stock detect_user(id,enemy,Float:origin[3]={0.0,0.0,0.0}){


	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
	write_byte(1)
	write_byte(enemy)
	write_coord_f(origin[0])
	write_coord_f(origin[1])
	write_coord_f(origin[2])
	message_end()

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
	write_byte(enemy)
	message_end()


}
public track_task(array[],id){
	id-=RADIOACTIVE_TASK_ID
	if(!client_hittable(id)){
		
		unradioactive_user(id);
		return
	}
	new hud_msg[256]
	new client_name[128]
	new distance, origin[3], eorigin[3],att_origin[3]
	new Float:Pos[3],Float:vEnd[3]
	get_user_name(id,client_name,127)
	
	get_user_origin(id, eorigin)
	get_user_origin(array[0], origin)
	get_user_origin(array[0], att_origin)
			
	distance = get_distance(eorigin, origin)
	format(hud_msg,256,"%s.^nDistance: %d^n",client_name,distance);
	set_hudmessage(LineColorsWithAlpha[ORANGE][0], LineColorsWithAlpha[ORANGE][1], LineColorsWithAlpha[ORANGE][2],  0.0, 0.2, 0, 0.0, 1.0)
	ShowSyncHudMsg(array[0],array[1],"%s", hud_msg)
	detect_user(array[0],id,vEnd);
	IVecFVec(origin,Pos)
	IVecFVec(eorigin,vEnd)
	laser_line(array[0],Pos,vEnd,true,{LTBLUE,LTBLUE,LTBLUE})
	for(new i=0;i<array[2];i++){
		if(!client_hittable(array[i+5])){
		
			continue
		}
		get_user_origin(array[i+5], origin)
			
		distance = get_distance(eorigin, origin)
		format(hud_msg,127,"%s.^nDistance: %d^n",client_name,distance);
		ShowSyncHudMsg(array[i+5],array[1], "%s", hud_msg)
		detect_user(array[i+5],id,vEnd);
		IVecFVec(origin,Pos)
		laser_line(array[i+5],Pos,vEnd,true,{LTBLUE,LTBLUE,LTBLUE})
		
	}
	sh_set_rendering(id, tag_color[0],  tag_color[1], tag_color[2], tag_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, tag_color[0], tag_color[1], tag_color[2],  50)
	new the_fucking_argument[4];
	copy(the_fucking_argument,4,tag_color)
	aura(id,the_fucking_argument)
	if(array[3]){
		sh_extra_damage(id,array[0],array[4],"SH_TRACKING",0,SH_DMG_NORM)
	}
	
}


stock track_user(id,attacker,do_damage=0,damage=40,Float:period,Float:time){
	
	
	new  radioactive_times=floatround(time/period)
	new players[SH_MAXSLOTS]
	new team_name[32]
	new client_name[128]
	new enemy_name[128]
	new player_count;
	
	get_user_name(id,enemy_name,127)
	get_user_name(attacker,client_name,127)
	
	get_user_team(attacker,team_name,32)
	get_players(players,player_count,"eah",team_name)
	
	new array[5+SH_MAXSLOTS+1]
	arrayset(array,-1,sizeof array)
	array[0] = attacker
	array[1] = CreateHudSyncObj()
	array[2] = player_count
	array[3] = do_damage
	array[4] = damage
	for(new i=0;i<player_count;i++){
		
		if(client_hittable(players[i])){
			array[5+i]=players[i]
		}
	}
	set_task(period,"track_task",id+RADIOACTIVE_TASK_ID,array, sizeof(array),  "a",radioactive_times)
	set_task(floatsub(floatmul(period,float(radioactive_times)),0.1),"unradioactive_task",id+UNRADIOACTIVE_TASK_ID,"", 0,  "a",1)
	return 0



}
stock suck_in_sound(ent_id,make_sound){

	if(!is_valid_ent(ent_id)) return PLUGIN_CONTINUE
	
	new Float:fl_origin[3]
	Entvars_Get_Vector(ent_id, EV_VEC_origin, fl_origin)

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(14)
	write_coord(floatround(fl_origin[0]))
	write_coord(floatround(fl_origin[1]))
	write_coord(floatround(fl_origin[2]))
	write_byte (200)
	write_byte (40)
	write_byte (45)
	message_end()
	if(make_sound){
		emit_sound(ent_id, CHAN_WEAPON, SUCK_IN_SOUND_FILE_NAME, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(ent_id, CHAN_VOICE, SUCK_IN_SOUND_FILE_NAME, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return PLUGIN_CONTINUE
}
stock aura(id,const color[4]={255,255,255,255},life=3,decay=1){

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
	write_byte(life)			// life
	write_byte(decay)			// decay
	message_end()

}

stock heal_stream(id, x,color_index=LTGREEN)
{
	
	new origin[3]
	
	get_user_origin(id, origin, 1)
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 8 )
	write_short(id)				// start entity
	write_short(x)				// entity
	write_short(white)		// model
	write_byte( 0 ) 				// starting frame
	write_byte( 30 )  			// frame rate
	write_byte( 1)  			// life
	write_byte( 45)  		// line width
	write_byte( 0 )  			// noise amplitude
	write_byte( LineColorsWithAlpha[color_index][0] )				// r, g, b
	write_byte( LineColorsWithAlpha[color_index][1] )				// r, g, b
	write_byte( LineColorsWithAlpha[color_index][2] )				// r, g, b
	write_byte( LineColorsWithAlpha[color_index][3] )				// brightness
	write_byte( 8 )				// scroll speed
	message_end()
	
}
stock unradioactive_user(id){
	remove_task(id+UNRADIOACTIVE_TASK_ID)
	remove_task(id+RADIOACTIVE_TASK_ID)
	if(client_hittable(id)){
		set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	}
	return 0



}

public unradioactive_task(id){
	id-=UNRADIOACTIVE_TASK_ID
	remove_task(id+RADIOACTIVE_TASK_ID)
	if(client_hittable(id)){
		set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	}
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
public move_entity(parm[])
{
	new victim = parm[3]
	
	new Float:origin[3]
	
	if(!is_valid_ent(victim)){
		
		return;
	}
	if((pev_valid(victim)!=2)){
	
		return 
	
	}
	pev(victim,pev_origin,origin)
	
	origin[2]+=100.0
	
	set_pev(victim,pev_origin,origin)
	
	new Float:fl_velocity[3]
	fl_velocity[0] = float(parm[0])
	fl_velocity[1] = float(parm[1])
	fl_velocity[2] = floatabs(float(parm[2]))
	
	set_pev(victim, pev_velocity, fl_velocity)
	
}
stock explosion_player(hero_id,ent_id,Float:explosion_radius,Float:peak_power,ignore_owner=0){
	
	if(!is_user_connected(ent_id)){
		return
	
	}
	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	explode_fx(iOrigin,floatround(explosion_radius))
	
	new entlist[33];
	new numfound = find_sphere_class(ent_id,"player", explosion_radius ,entlist, 32);
	
	new CsTeams:idTeam = cs_get_user_team(ent_id)
		
	for (new i=0; i < numfound; i++)
	{	
			
		new pid = entlist[i];
		
		if(!client_hittable(pid)){
			continue
		
		}
		sh_screen_shake(pid,10.0,3.0,10.0)
		if(pid!=ent_id){
			if(cs_get_user_team(pid)==idTeam){
				continue
			}
		}
		damage_player(hero_id,ent_id,ent_id,pid,explosion_radius,peak_power,ignore_owner)
		
	}
}
stock explosion(hero_id,ent_id,Float:explosion_radius,Float:peak_power){
	
	if((pev_valid(ent_id)!=2)){
	
		return 
	
	}
	
	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	explode_fx(iOrigin,floatround(explosion_radius))
	
	new entlist[33];
	new numfound = find_sphere_class(ent_id,"player", explosion_radius ,entlist, 32);
	
	new owner_id=pev(ent_id,pev_owner)
	new name_of_player[128];
	get_user_name(owner_id,name_of_player,127)
	new CsTeams:idTeam = cs_get_user_team(owner_id)
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		if(!client_hittable(pid)){
			continue
		
		}
		sh_screen_shake(pid,10.0,3.0,10.0)
		if(pid!=owner_id){
			if(cs_get_user_team(pid)==idTeam){
				continue
			}
		}
		damage_player(hero_id,ent_id,owner_id,pid,explosion_radius,peak_power)

	}
}
stock explosion_custom_entity(ent_id,Float:explosion_radius,Float:peak_power,ent_classname[]="player"){
	
	if((pev_valid(ent_id)!=2)){
	
		return 
	
	}
	
	new Float:fOrigin[3];
	entity_get_vector( ent_id, EV_VEC_origin, fOrigin);
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	explode_fx(iOrigin,floatround(explosion_radius))
	
	new entlist[33];
	new numfound = find_sphere_class(ent_id,ent_classname, explosion_radius ,entlist, 32);
	
	new owner_id=pev(ent_id,pev_owner)
	for (new i=0; i < numfound; i++)
	{		
		new eid = entlist[i];
		
		if(!is_valid_ent(eid)){
			
			continue;
		}
		if(pev_valid(eid)!=2){
			continue
		
		}
		damage_entity(ent_id,owner_id,eid,explosion_radius,peak_power)
	}
}
stock damage_player(hero_id,ent_id,owner_id,pid,Float:radius,Float:peak_power,ignore_owner=1,Float:optional_force=0.0){
	
	
	if((pev_valid(ent_id)!=2)){
	
		return 
	
	}
	if(!is_user_connected(owner_id)){
	
		return 
	
	}
	if(!is_user_connected(pid)){
	
		return 
	
	}
	if(is_user_connected(pid)&&(pid==owner_id)){
		
		if(ignore_owner){
			
			return
			
		}
		
		
	
	}
	
	new Float:b_vel[3],Float:vOrig[3],Float:usOrig[3]
	
	new parm[4]
	
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
	new Float:force,Float:damage,idamage
	damage=peak_power-(peak_power/2.0)*falloff_coeff
	idamage=floatround(damage)
	if(optional_force!=0.0){
		force=optional_force-(optional_force/2.0)*falloff_coeff
	}
	else{
		force=damage
	}	
	sh_extra_damage(pid,owner_id,idamage,"SH_Explosion");
	
	b_vel[0]=((vOrig[0] -usOrig[0]) )*force
	b_vel[1]=((vOrig[1] -usOrig[1]) )*force
	b_vel[2]=force
	
		
	parm[0] = floatround(b_vel[0])
	parm[1] = floatround(b_vel[1])
	parm[2] = floatround(b_vel[2])
	parm[3] = pid
	set_task(0.1, "move_enemy", 0, parm, 4)
	sh_set_stun(pid,3.0,0.5)
	
	sh_screen_shake(pid,10.0,3.0,10.0)
	unfade_screen_user(pid)
	emit_sound(pid, CHAN_VOICE, crush_stunned, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	sh_chat_message(owner_id,hero_id,"%s was shattered by you!",client_name);
	sh_chat_message(pid,hero_id,"%s shattered you!",attacker_name);
}
stock damage_entity(ent_id,owner_id,tg_id,Float:radius,Float:peak_power,ignore_owner=1,Float:optional_force=0.0){
	
	
	if((pev_valid(ent_id)!=2)||(pev_valid(tg_id)!=2)){
	
		return 
	
	}
	
	if(is_user_connected(tg_id)&&(tg_id==owner_id)){
		
		if(ignore_owner){
			
			return
			
		}
		
		
	
	}
	new Float:b_vel[3],Float:vOrig[3],Float:usOrig[3]
	
	new parm[4]
	
	Entvars_Get_Vector(tg_id, EV_VEC_origin, vOrig)
	Entvars_Get_Vector(ent_id, EV_VEC_origin, usOrig)
	
	Entvars_Get_Vector(ent_id, EV_VEC_velocity, b_vel)
	
	new Float:distance=get_distance_f(vOrig,usOrig);
	new Float:vic_origin[3],Float:mine_origin[3];
	entity_get_vector(tg_id,EV_VEC_origin,vic_origin);
	entity_get_vector(ent_id,EV_VEC_origin,mine_origin);
	distance=vector_distance(vic_origin,mine_origin);
	new Float:falloff_coeff= floatmin(1.0,distance/radius);
	new Float:force,Float:damage,idamage
	damage=peak_power-(peak_power/2.0)*falloff_coeff
	idamage=floatround(damage)
	if(optional_force!=0.0){
		force=optional_force-(optional_force/2.0)*falloff_coeff
	}
	else{
		force=damage
	}
	new this_ent_owner = entity_get_edict(tg_id, EV_ENT_owner)
	if(client_hittable(this_ent_owner)){
		ExecuteHam(Ham_TakeDamage, tg_id, ent_id, owner_id, float(idamage), 0);
	}
	if(!is_valid_ent(tg_id)){
		
		return;
	}
	if(pev_valid(tg_id)!=2){
		
		return
	
	}
	b_vel[0]=((vOrig[0] -usOrig[0]) )*force
	b_vel[1]=((vOrig[1] -usOrig[1]) )*force
	b_vel[2]=force
	
		
	parm[0] = floatround(b_vel[0])
	parm[1] = floatround(b_vel[1])
	parm[2] = floatround(b_vel[2])
	parm[3] = tg_id
	set_task(0.1, "move_entity", 0, parm, 4)
}

stock unfade_screen_user(id){
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
stock laser_line(ent_id,Float:Pos[3], Float:vEnd[3],killbeam,color_constants[3]={RED,BLUE,CUSTOM})
{
	if ( !pev_valid(ent_id) ) return
	static  colors[3]
	if(client_hittable(pev(ent_id, pev_owner))){
	
		switch ( cs_get_user_team(pev(ent_id, pev_owner)) )
		{
			case CS_TEAM_T: colors = LineColors[color_constants[0]]
				case CS_TEAM_CT: colors = LineColors[color_constants[1]]
					default: colors = LineColors[color_constants[2]]
		}
	}
	else{

		colors=LineColors[color_constants[2]]
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
stock draw_bbox(ent_id,killbeam){
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
stock gun_shot_decal(Float:vec[3]){
	
	new decal_id = burn_decal[random_num(0,4)]
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 109 ) // decal and ricochet sound
	write_coord_f( vec[0] ) //pos
	write_coord_f( vec[1] )
	write_coord_f( vec[2] )
	write_short (0) // I have no idea what thats supposed to be
	write_byte (decal_id) //decal
	message_end()	
}
//-----------------------------------------------------------------------------------------------
stock explode_fx( vec1[3] ,radius)
{
	// blast circles
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 21 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 16)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + radius*3)
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
	write_byte( radius ) // byte (scale in 0.1's) 188
	write_byte( 10 ) // byte (framerate)
	message_end()
	
	//TE_Explosion
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 3 )
	write_coord(vec1[0] + random_num( -100, 100 ))
	write_coord(vec1[1] + random_num( -100, 100 ))
	write_coord(vec1[2]+ random_num( -50, 50 ))
	write_short( fire )
	write_byte(  radius/9  ) // byte (scale in 0.1's) 188
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
	write_byte( radius/14 )  // 2
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
stock directed_spark(init_id, end_id,girth=10,veins=10,glowing=255,ramming_pace=8,color_constant=GREEN)
{
	emit_sound(init_id, CHAN_ITEM, "weapons/electro5.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 8 )
	write_short(init_id)				// start entity
	write_short(end_id)				// entity
	write_short(gSpriteLaser)		// model
	write_byte( 0 ) 				// starting frame
	write_byte( 30 )  			// frame rate
	write_byte( 1)  			// life
	write_byte(girth)  		// line width
	write_byte(veins)  			// noise amplitude
	write_byte(LineColors[color_constant][0])				// r, g, b
	write_byte(LineColors[color_constant][1])				// r, g, b
	write_byte(LineColors[color_constant][2])				// r, g, b
	write_byte( glowing)				// brightness
	write_byte( ramming_pace )				// scroll speed
	message_end()

}


//----------------------------------------------------------------------------------------------
stock blood_spray(Float:vicOrigin[3], scale)
{
	new Float:x
	new Float:y
	for(new i = 0; i < 2; i++) {
		x = float(random_num(-10, 10))
		y = float(random_num(-10, 10))
		for(new Float:j = 0.0; j < 2.0; j+=1.0) {
			// Blood spray
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(115)				// TE_BLOODSPRITE
			write_coord_f(vicOrigin[0]+(x*j))	// position
			write_coord_f(vicOrigin[1]+(y*j))
			write_coord_f(vicOrigin[2]+21.0)
			write_short(blood2)	// sprite1 index
			write_short(blood1)	// sprite2 index
			write_byte(248) 			// color RED = 248 YELLOW = 196
			write_byte(scale) 			// scale
			message_end()
		}
	}
}

stock glow(id, r, g, b,a, on) {
	if(on) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderTransAlpha, a)
	}
	else{
		set_rendering(id, kRenderFxNone, r, g, b,  kRenderTransAlpha, a)
	}
}
stock multiply_3d_vector_by_scalar(Float:in_vec[3],Float:scalar,Float:out_vec[3]){
	
	for(new i=0;i<3;i++){
		out_vec[i]=in_vec[i]*scalar
			
	}

}
stock add_3d_vectors(Float:a_vec[3],Float:b_vec[3],Float:out_vec[3]){
	
	for(new i=0;i<3;i++){
		out_vec[i]=a_vec[i]+b_vec[i]
			
	}

}
stock sub_3d_vectors(Float:a_vec[3],Float:b_vec[3],Float:out_vec[3]){
	
	for(new i=0;i<3;i++){
		out_vec[i]=a_vec[i]-b_vec[i]
			
	}

}
stock mirror_3d_vec(Float:in_vec[3],Float:out_vec[3]){
	
	for(new i=0;i<3;i++){
		out_vec[i]=in_vec[i]*1.0
			
	}

}

stock Float:dot_product( Float:input_a[3], Float:input_b[3], vec_size = 3) {
	
	new Float:result = 0.0;
	for (new i = 0; i < vec_size; i++) {
		
		result += input_a[i] * input_b[i];
		
	}
	return result;
	
}

stock Float:angle_between_vectors_radians(Float:input_a[3], Float:input_b[3], vec_size = 3) {
	
	
	new Float:dot_product_between_vecs = dot_product(input_a, input_b, vec_size);
	new Float:vector_len_product = VecLength(input_a) * VecLength(input_b);
	new Float:before_last = (dot_product_between_vecs / (vector_len_product));
	before_last = floatclamp(before_last, -1.0, 1.0);
	new Float:angle_between_input_a_and_input_b = floatacos(before_last,anglemode:radian);
	return angle_between_input_a_and_input_b;
	
}
stock prepare_shero_aux_lib(){
	
	xs_seed(get_systime(0));
	hero_spawn_hud_msg_sync =CreateHudSyncObj()
	tracker_hud_msg_sync =CreateHudSyncObj()
}
//----------------------------------------------------------------------------------------------
stock precache_explosion_fx(){

	white = precache_model("sprites/shockwave.spr")
	fire = precache_model("sprites/zerogxplode.spr")
	gSpriteLaser = precache_model("sprites/laserbeam.spr")
	engfunc(EngFunc_PrecacheSound,  crush_stunned)
	m_trail = precache_model("sprites/smoke.spr")
	blood1 = precache_model("sprites/blood.spr");
	white = precache_model("sprites/shockwave.spr")
	blood2 = precache_model("sprites/bloodspray.spr");
	precache_sound(SUCK_IN_SOUND_FILE_NAME)
	sprite1 = precache_model("sprites/white.spr")
	g_iFireSprite = precache_model("sprites/flame.spr");
	g_iSmokeSprite[0] = precache_model("sprites/black_smoke3.spr");
	g_iSmokeSprite[1] = precache_model("sprites/steam1.spr");
	gSpriteSmoke = precache_model("sprites/steam1.spr")
	gSpriteFire = precache_model("sprites/explode1.spr")
	gSpriteBurning = precache_model("sprites/xfire.spr")
	precache_gibs()
	precache_sound(NULL_SOUND)
	prepare_shero_aux_lib()
	
	
}

stock bool:client_hittable(vic_userid,optional_bool=1){
	if(vic_userid<=0){
		
		return false;
	}
	if(pev_valid(vic_userid)!=2){
		
		return false;
	}
	if(!is_user_connected(vic_userid)){
		
		return false;
	}
	return (((is_user_alive(vic_userid))?true:false)&&optional_bool);

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
//NOT MINE!//Original plugin stuff 
//register_plugin("Ultimate Gore","1.6","JTP10181")
/************************************************************
* FX FUNCTIONS
************************************************************/

stock fx_invisible(id)
{
	if(is_user_connected(id)){
		set_pev(id, pev_renderfx, kRenderFxNone)
		set_pev(id, pev_rendermode, kRenderTransAlpha)
		set_pev(id, pev_renderamt, 0.0)
	}
}

stock fx_blood(origin[3],origin2[3],HitPlace,bool:alien=false)
{
	//Crash Checks
	if (HitPlace < 0 || HitPlace > 7) HitPlace = 0
	new rDistance = get_distance(origin,origin2) ? get_distance(origin,origin2) : 1

	new rX = ((origin[0]-origin2[0]) * 300) / rDistance
	new rY = ((origin[1]-origin2[1]) * 300) / rDistance
	new rZ = ((origin[2]-origin2[2]) * 300) / rDistance

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSTREAM)
	write_coord(origin[0]+Offset[HitPlace][0])
	write_coord(origin[1]+Offset[HitPlace][1])
	write_coord(origin[2]+Offset[HitPlace][2])
	write_coord(rX) // x
	write_coord(rY) // y
	write_coord(rZ) // z
	write_byte(alien?BLOOD_STREAM_YELLOW:BLOOD_STREAM_RED) // color
	write_byte(random_num(100,200)) // speed
	message_end()
}
stock strip_weapon_for_my_grenade_heroes(id,const message[]="You ran out",classid=CSW_DEAGLE,bool:optional_bool=true){

	if(optional_bool){
		if(!is_user_bot(id)){
			client_print(id, print_center, message)
		}
		ham_strip_user_weapon(id, classid, _, false);
		sh_drop_weapon(id,classid,true)
		cs_set_user_bpammo(id, classid,0);
	}
}
stock fx_bleed(origin[3],bool:alien=false)
{
	// Blood spray
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSTREAM)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(random_num(-360,360)) // x
	write_coord(random_num(-360,360)) // y
	write_coord(-10) // z
	write_byte(alien?BLOOD_STREAM_YELLOW:BLOOD_STREAM_RED) // color
	write_byte(random_num(50,100)) // speed
	message_end()
}

stock fx_blood_small(origin[3],num)
{
	// Write Small splash decal
	for (new j = 0; j < num; j++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+random_num(-100,100))
		write_coord(origin[1]+random_num(-100,100))
		write_coord(origin[2]-36)
		write_byte(blood_small_red[random_num(0,BLOOD_SM_NUM - 1)]) // index
		message_end()
	}
}

stock fx_blood_large(origin[3],num)
{
	// Write Large splash decal
	for (new i = 0; i < num; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+random_num(-50,50))
		write_coord(origin[1]+random_num(-50,50))
		write_coord(origin[2]-36)
		write_byte(blood_large_red[random_num(0,BLOOD_LG_NUM - 1)]) // index
		message_end()
	}
}

stock fx_gib_explode(origin[3],origin2[3])
{
	new flesh[2]
	flesh[0] = mdl_gib_flesh
	flesh[1] = mdl_gib_meat
	new mult = 80, gibtime = 400 //40 seconds
						

	new rDistance = get_distance(origin,origin2) ? get_distance(origin,origin2) : 1
	new rX = ((origin[0]-origin2[0]) * mult) / rDistance
	new rY = ((origin[1]-origin2[1]) * mult) / rDistance
	new rZ = ((origin[2]-origin2[2]) * mult) / rDistance
	new rXm = rX >= 0 ? 1 : -1
	new rYm = rY >= 0 ? 1 : -1
	new rZm = rZ >= 0 ? 1 : -1

	// Gib explosions

	// Head
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+40)
	write_coord(rX + (rXm * random_num(0,80)))
	write_coord(rY + (rYm * random_num(0,80)))
	write_coord(rZ + (rZm * random_num(80,200)))
	write_angle(random_num(0,360))
	write_short(mdl_gib_head)
	write_byte(0) // bounce
	write_byte(gibtime) // life
	message_end()

	// Parts
	for(new i = 0; i < 4; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(rX + (rXm * random_num(0,80)))
		write_coord(rY + (rYm * random_num(0,80)))
		write_coord(rZ + (rZm * random_num(80,200)))
		write_angle(random_num(0,360))
		write_short(flesh[random_num(0,1)])
		write_byte(0) // bounce
		write_byte(gibtime) // life
		message_end()
	}

	// Spine
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+30)
	write_coord(rX + (rXm * random_num(0,80)))
	write_coord(rY + (rYm * random_num(0,80)))
	write_coord(rZ + (rZm * random_num(80,200)))
	write_angle(random_num(0,360))
	write_short(mdl_gib_spine)
	write_byte(0) // bounce
	write_byte(gibtime) // life
	message_end()

	// Lung
	for(new i = 0; i <= 1; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]+10)
		write_coord(rX + (rXm * random_num(0,80)))
		write_coord(rY + (rYm * random_num(0,80)))
		write_coord(rZ + (rZm * random_num(80,200)))
		write_angle(random_num(0,360))
		write_short(mdl_gib_lung)
		write_byte(0) // bounce
		write_byte(gibtime) // life
		message_end()
	}

	//Legs
	for(new i = 0; i <= 1; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]-10)
		write_coord(rX + (rXm * random_num(0,80)))
		write_coord(rY + (rYm * random_num(0,80)))
		write_coord(rZ + (rZm * random_num(80,200)))
		write_angle(random_num(0,360))
		write_short(mdl_gib_legbone)
		write_byte(0) // bounce
		write_byte(gibtime) // life
		message_end()
	}

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+20)
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(BLOOD_COLOR_RED) // color index
	write_byte(10) // size
	message_end()
}

stock fx_extra_blood(origin[3])
{
	new x, y, z

	for(new i = 0; i < 3; i++) {
		x = random_num(-15,15)
		y = random_num(-15,15)
		z = random_num(-20,25)
		for(new j = 0; j < 2; j++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0]+(x*j))
			write_coord(origin[1]+(y*j))
			write_coord(origin[2]+(z*j))
			write_short(spr_blood_spray)
			write_short(spr_blood_drop)
			write_byte(BLOOD_COLOR_RED) // color index
			write_byte(15) // size
			message_end()
		}
	}
}

stock fx_headshot(origin[3])
{
	new Sprays = 8

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+40)
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(BLOOD_COLOR_RED) // color index
	write_byte(15) // size
	message_end()

	// Blood sprays
	for (new i = 0; i < Sprays; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BLOODSTREAM)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]+40)
		write_coord(random_num(-30,30)) // x
		write_coord(random_num(-30,30)) // y
		write_coord(random_num(80,300)) // z
		write_byte(BLOOD_STREAM_RED) // color
		write_byte(random_num(100,200)) // speed
		message_end()
	}
}
stock precache_gibs()
{
	spr_blood_drop = precache_model("sprites/blood.spr")
	spr_blood_spray = precache_model("sprites/bloodspray.spr")

	mdl_gib_flesh = precache_model("models/Fleshgibs.mdl")
	mdl_gib_meat = precache_model("models/GIB_B_Gib.mdl")
	mdl_gib_head = precache_model("models/GIB_Skull.mdl")
	
	mdl_gib_spine = precache_model("models/GIB_B_Bone.mdl")
	mdl_gib_lung = precache_model("models/GIB_Lung.mdl")
	mdl_gib_legbone = precache_model("models/GIB_Legbone.mdl")
}
