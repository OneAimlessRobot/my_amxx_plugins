#if defined sh_aux_funcs
  #endinput
#endif
#define sh_aux_funcs

#include "../my_include/superheromod.inc"
#include <fakemeta_util>


#define RADIOACTIVE_TASK_ID 73223627
#define UNRADIOACTIVE_TASK_ID 732231123


#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)

#define crush_stunned "shmod/Teliko/chaff/chaff_blow.wav"
#define SUCK_IN_SOUND_FILE_NAME "ambience/particle_suck2.wav"
#define NULL_SOUND "common/null.wav"

#define COLORS_NUM 9
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
	{255, 255, 255}		//White
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
	{255, 255, 255,255}		//White
}

stock Float:null_vector[3]={0.0,0.0,0.0}
stock null_iVector[3]={0,0,0}

stock const tag_color[4]={0,255,255,255}
stock smoke, white, fire
stock m_trail
new g_msgFade
stock gSpriteLaser,blood1,blood2,sprite1;
stock g_iFireSprite, g_iSmokeSprite[2];
stock gSpriteSmoke, gSpriteFire, gSpriteBurning
stock trail(vec1[3],vec2[3],const color[4],id){

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
	trail(eorigin,origin,tag_color,array[0])
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
		trail(eorigin,origin,tag_color,array[i+5])
		
	}
	sh_set_rendering(id, tag_color[0],  tag_color[1], tag_color[2], tag_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, tag_color[0], tag_color[1], tag_color[2],  50)
	aura(id,tag_color)
	if(array[3]){
		sh_extra_damage(id,array[0],array[4],"SH_TRACKING",0,SH_DMG_NORM)
	}
	
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
stock make_shockwave(point[3],Float:radius,const color[4]){



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
	write_byte(10)		// life in 0.1's
	write_byte(8)		// line width in 0.1's
	write_byte(1)		// noise amplitude in 0.01's
	write_byte( color[0])
	write_byte( color[1] )
	write_byte( color[2] )
	write_byte( color[3] )
	write_byte( 0 )
	message_end()
	/*message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
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
	message_end();*/

}
stock track_user(hero_id,id,attacker,do_damage=0,damage=40,Float:period,Float:time){
	
	
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
stock detect_user(id,enemy,PlayerCoords[3]){


	
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

stock aura(id,const color[4]){

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

stock unradioactive_user(id){
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
stock explosion_player(hero_id,ent_id,Float:explosion_radius,Float:peak_power,ignore_owner=0){
	
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
	
	if(!pev_valid(ent_id)||!is_valid_ent(ent_id)){
	
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
	new name_of_player[128];
	get_user_name(owner_id,name_of_player,127)
	//console_print(owner_id,"yeeeyyyyy!!!! Mensagem enviada ao owner na funcao de dmg!!!!^nO nome do owner e %s!!!!^n",name_of_player)
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
		
		get_user_name(pid,name_of_player,127)
		//console_print(owner_id,"yeeeyyyyy!!!! Mensagem enviada ao owner na funcao de dmg!!!!^nO nome do player dmged e %s!!!!^n",name_of_player)
	
	}
}
stock damage_player(hero_id,ent_id,owner_id,pid,Float:radius,Float:peak_power,ignore_owner=1,Float:optional_force=0.0){
	
	
	if(!pev_valid(ent_id)||!is_valid_ent(ent_id)){
	
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
stock laser_line(ent_id,Float:Pos[3], Float:vEnd[3],killbeam)
{
	if ( !pev_valid(ent_id) ) return
	if(!client_hittable(pev(ent_id, pev_owner))) return
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

//-----------------------------------------------------------------------------------------------
stock explode_fx( vec1[3] )
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
stock directed_spark(init_id, end_id)
{
	emit_sound(init_id, CHAN_ITEM, "weapons/electro5.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	emit_sound(end_id, CHAN_ITEM, "weapons/electro5.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 8 )
	write_short(init_id)				// start entity
	write_short(end_id)				// entity
	write_short(gSpriteLaser)		// model
	write_byte( 0 ) 				// starting frame
	write_byte( 30 )  			// frame rate
	write_byte( 1)  			// life
	write_byte( 2)  		// line width
	write_byte(80 )  			// noise amplitude
	write_byte(8)				// r, g, b
	write_byte( 60)				// r, g, b
	write_byte( 8 )				// r, g, b
	write_byte( 110)				// brightness
	write_byte( 8 )				// scroll speed
	message_end()

}
//----------------------------------------------------------------------------------------------
stock blood_spray(vic, vicOrigin[3], scale)
{
	new x, y
	for(new i = 0; i < 2; i++) {
		x = random_num(-10, 10)
		y = random_num(-10, 10)
		for(new j = 0; j < 2; j++) {
			// Blood spray
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(115)				// TE_BLOODSPRITE
			write_coord(vicOrigin[0]+(x*j))	// position
			write_coord(vicOrigin[1]+(y*j))
			write_coord(vicOrigin[2]+21)
			write_short(blood2)	// sprite1 index
			write_short(blood)	// sprite2 index
			write_byte(248) 			// color RED = 248 YELLOW = 196
			write_byte(scale) 			// scale
			message_end()
		}
	}
}
stock trailing_beam(life,ent,const color[4]) {
	if(pev_valid(ent)&&(life>0)){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(22); // TE_BEAMFOLLOW
		write_short(ent); // ball
		write_short(m_trail); // laserbeam
		write_byte(life); // life
		write_byte(5); // width
		write_byte(color[0]); // R
		write_byte(color[1]); // G
		write_byte(color[2]); // B
		write_byte(color[3]); // brightness
		message_end();
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
	precache_sound(NULL_SOUND)
	
	
}

stock bool:client_hittable(vic_userid){
return (is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid)

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
